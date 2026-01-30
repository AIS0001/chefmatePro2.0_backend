/**
 * Stock Management Service
 * Handles all stock operations with unit conversions and smart deduction
 */

const { db } = require('../config/dbconnection');

class StockService {
  /**
   * Add stock to inventory
   * @param {number} productId - Product/Item ID
   * @param {number} unitId - Unit ID to add
   * @param {number} quantity - Quantity to add
   * @param {number} userId - User adding stock
   * @param {string} referenceType - Type of reference (PURCHASE, ADJUSTMENT, etc.)
   * @param {number} referenceId - ID from reference table
   * @param {string} notes - Additional notes
   */
  async addStock(productId, unitId, quantity, userId, referenceType = 'MANUAL', referenceId = null, notes = '') {
    try {
      const connection = await db.getConnection();
      
      // Start transaction
      await connection.beginTransaction();

      try {
        // Validate product and unit exist
        const [productCheck] = await connection.query(
          'SELECT id FROM items WHERE id = ?',
          [productId]
        );
        
        if (productCheck.length === 0) {
          throw new Error('Product not found');
        }

        const [unitCheck] = await connection.query(
          'SELECT id, unit_name, ml_capacity FROM product_units WHERE id = ? AND product_id = ?',
          [unitId, productId]
        );

        if (unitCheck.length === 0) {
          throw new Error('Unit not found for this product');
        }

        // Record transaction
        await connection.query(
          `INSERT INTO stock_transactions 
           (product_id, transaction_type, unit_id, quantity, reference_type, reference_id, user_id, notes, quantity_in_ml)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            productId,
            'ADD',
            unitId,
            quantity,
            referenceType,
            referenceId,
            userId,
            notes,
            unitCheck[0].ml_capacity ? quantity * unitCheck[0].ml_capacity : null
          ]
        );

        // Update or create stock balance
        const [existingBalance] = await connection.query(
          'SELECT id, current_quantity FROM stock_balance WHERE product_id = ? AND unit_id = ?',
          [productId, unitId]
        );

        if (existingBalance.length > 0) {
          await connection.query(
            'UPDATE stock_balance SET current_quantity = current_quantity + ? WHERE product_id = ? AND unit_id = ?',
            [quantity, productId, unitId]
          );
        } else {
          await connection.query(
            'INSERT INTO stock_balance (product_id, unit_id, current_quantity) VALUES (?, ?, ?)',
            [productId, unitId, quantity]
          );
        }

        await connection.commit();

        return {
          success: true,
          message: 'Stock added successfully',
          productId,
          unitId,
          quantity,
          timestamp: new Date()
        };

      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }

    } catch (error) {
      throw new Error(`Failed to add stock: ${error.message}`);
    }
  }

  /**
   * Remove stock from inventory (for sales, waste, etc.)
   * Intelligently removes from largest units first
   */
  async removeStock(productId, unitId, quantity, userId, referenceType = 'SALE', referenceId = null, notes = '') {
    try {
      const connection = await db.getConnection();
      
      await connection.beginTransaction();

      try {
        // Check if quantity is available
        const [balance] = await connection.query(
          'SELECT available_quantity FROM stock_balance WHERE product_id = ? AND unit_id = ?',
          [productId, unitId]
        );

        if (balance.length === 0) {
          throw new Error('No stock available for this unit');
        }

        if (balance[0].available_quantity < quantity) {
          throw new Error(`Insufficient stock. Available: ${balance[0].available_quantity}, Required: ${quantity}`);
        }

        // Record transaction
        await connection.query(
          `INSERT INTO stock_transactions 
           (product_id, transaction_type, unit_id, quantity, reference_type, reference_id, user_id, notes)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            productId,
            'REMOVE',
            unitId,
            quantity,
            referenceType,
            referenceId,
            userId,
            notes
          ]
        );

        // Deduct from stock balance
        await connection.query(
          'UPDATE stock_balance SET current_quantity = current_quantity - ? WHERE product_id = ? AND unit_id = ?',
          [quantity, productId, unitId]
        );

        await connection.commit();

        return {
          success: true,
          message: 'Stock removed successfully',
          productId,
          unitId,
          quantity,
          timestamp: new Date()
        };

      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }

    } catch (error) {
      throw new Error(`Failed to remove stock: ${error.message}`);
    }
  }

  /**
   * Get current stock level for a product
   */
  async getStockLevel(productId, unitId = null) {
    try {
      let query = `
        SELECT 
          sb.id,
          sb.product_id,
          sb.unit_id,
          pu.unit_name,
          pu.ml_capacity,
          sb.current_quantity,
          sb.reserved_quantity,
          sb.available_quantity,
          i.iname as product_name
        FROM stock_balance sb
        JOIN product_units pu ON sb.unit_id = pu.id
        JOIN items i ON sb.product_id = i.id
        WHERE sb.product_id = ?
      `;

      const params = [productId];

      if (unitId) {
        query += ' AND sb.unit_id = ?';
        params.push(unitId);
      }

      query += ' ORDER BY pu.is_base_unit DESC, pu.ml_capacity DESC';

      const [results] = await db.query(query, params);
      return results;

    } catch (error) {
      throw new Error(`Failed to get stock level: ${error.message}`);
    }
  }

  /**
   * Get unit conversions for a product
   * Returns all possible conversions and their factors
   */
  async getUnitConversions(productId) {
    try {
      const [results] = await db.query(
        `SELECT 
          sc.id,
          sc.product_id,
          pu1.unit_name as from_unit,
          pu2.unit_name as to_unit,
          pu1.id as from_unit_id,
          pu2.id as to_unit_id,
          sc.conversion_factor,
          pu1.ml_capacity as from_ml_capacity,
          pu2.ml_capacity as to_ml_capacity
        FROM stock_conversions sc
        JOIN product_units pu1 ON sc.from_unit_id = pu1.id
        JOIN product_units pu2 ON sc.to_unit_id = pu2.id
        WHERE sc.product_id = ? AND sc.is_active = 1
        ORDER BY pu1.ml_capacity DESC, pu2.ml_capacity DESC`,
        [productId]
      );

      return results;

    } catch (error) {
      throw new Error(`Failed to get conversions: ${error.message}`);
    }
  }

  /**
   * Convert quantity from one unit to another
   * Smart conversion with ML capacity consideration for liquor
   */
  async convertUnits(productId, fromUnitId, toUnitId, quantity) {
    try {
      // Get unit details
      const [units] = await db.query(
        `SELECT id, unit_name, ml_capacity 
         FROM product_units 
         WHERE id IN (?, ?) AND product_id = ?`,
        [fromUnitId, toUnitId, productId]
      );

      if (units.length < 2) {
        throw new Error('One or both units not found for this product');
      }

      const fromUnit = units.find(u => u.id === fromUnitId);
      const toUnit = units.find(u => u.id === toUnitId);

      if (!fromUnit || !toUnit) {
        throw new Error('Invalid units');
      }

      // Get conversion factor
      const [conversion] = await db.query(
        `SELECT conversion_factor 
         FROM stock_conversions 
         WHERE product_id = ? AND from_unit_id = ? AND to_unit_id = ? AND is_active = 1`,
        [productId, fromUnitId, toUnitId]
      );

      if (conversion.length === 0) {
        throw new Error('No conversion rule found between these units');
      }

      const convertedQuantity = quantity * conversion[0].conversion_factor;

      return {
        success: true,
        from: {
          unitId: fromUnitId,
          unitName: fromUnit.unit_name,
          quantity: quantity,
          mlCapacity: fromUnit.ml_capacity
        },
        to: {
          unitId: toUnitId,
          unitName: toUnit.unit_name,
          quantity: convertedQuantity,
          mlCapacity: toUnit.ml_capacity
        },
        conversionFactor: conversion[0].conversion_factor
      };

    } catch (error) {
      throw new Error(`Unit conversion failed: ${error.message}`);
    }
  }

  /**
   * Smart removal for liquor - can sell in different serving sizes
   * E.g., Remove from 1 bottle when selling 30ML peg
   */
  async removeStockWithVariants(productId, variantId, quantity, userId, referenceId = null, notes = '') {
    try {
      const connection = await db.getConnection();
      
      await connection.beginTransaction();

      try {
        // Get variant details
        const [variant] = await connection.query(
          `SELECT 
            pv.id,
            pv.product_id,
            pv.variant_name,
            pv.base_unit_id,
            pv.quantity_in_base_unit,
            pv.ml_quantity,
            pu.ml_capacity
          FROM product_variants pv
          JOIN product_units pu ON pv.base_unit_id = pu.id
          WHERE pv.id = ? AND pv.product_id = ?`,
          [variantId, productId]
        );

        if (variant.length === 0) {
          throw new Error('Variant not found');
        }

        const variantDetail = variant[0];
        const baseUnitQuantityNeeded = quantity * variantDetail.quantity_in_base_unit;

        // Check if enough base unit stock
        const [balance] = await connection.query(
          'SELECT available_quantity FROM stock_balance WHERE product_id = ? AND unit_id = ?',
          [productId, variantDetail.base_unit_id]
        );

        if (balance.length === 0 || balance[0].available_quantity < baseUnitQuantityNeeded) {
          throw new Error(
            `Insufficient base unit stock. Available: ${balance[0]?.available_quantity || 0}, Required: ${baseUnitQuantityNeeded}`
          );
        }

        // Record transaction for the variant
        await connection.query(
          `INSERT INTO stock_transactions 
           (product_id, transaction_type, unit_id, quantity, quantity_in_ml, reference_type, reference_id, user_id, notes)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            productId,
            'REMOVE',
            variantDetail.base_unit_id,
            baseUnitQuantityNeeded,
            variantDetail.ml_quantity ? quantity * variantDetail.ml_quantity : null,
            'SALE',
            referenceId,
            userId,
            `Sold as ${quantity}x ${variantDetail.variant_name}. ${notes}`
          ]
        );

        // Deduct from stock balance
        await connection.query(
          'UPDATE stock_balance SET current_quantity = current_quantity - ? WHERE product_id = ? AND unit_id = ?',
          [baseUnitQuantityNeeded, productId, variantDetail.base_unit_id]
        );

        await connection.commit();

        return {
          success: true,
          message: 'Stock removed successfully',
          productId,
          variantId,
          variantName: variantDetail.variant_name,
          quantitySold: quantity,
          baseUnitQuantityRemoved: baseUnitQuantityNeeded,
          mlRemoved: variantDetail.ml_quantity ? quantity * variantDetail.ml_quantity : null,
          timestamp: new Date()
        };

      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }

    } catch (error) {
      throw new Error(`Failed to remove stock with variant: ${error.message}`);
    }
  }

  /**
   * Get all variants for a product
   */
  async getProductVariants(productId) {
    try {
      const [variants] = await db.query(
        `SELECT 
          pv.id,
          pv.product_id,
          pv.variant_name,
          pv.base_unit_id,
          pv.quantity_in_base_unit,
          pv.ml_quantity,
          pv.selling_price,
          pv.cost_price,
          pv.is_active,
          pu.unit_name as base_unit_name,
          pu.ml_capacity as base_unit_ml_capacity
        FROM product_variants pv
        JOIN product_units pu ON pv.base_unit_id = pu.id
        WHERE pv.product_id = ? AND pv.is_active = 1
        ORDER BY pv.ml_quantity ASC`,
        [productId]
      );

      return variants;

    } catch (error) {
      throw new Error(`Failed to get variants: ${error.message}`);
    }
  }

  /**
   * Get complete stock report for a product
   */
  async getStockReport(productId) {
    try {
      // Get product details
      const [product] = await db.query(
        'SELECT id, iname, unit FROM items WHERE id = ?',
        [productId]
      );

      if (product.length === 0) {
        throw new Error('Product not found');
      }

      // Get all units and balances
      const stockLevels = await this.getStockLevel(productId);

      // Get variants
      const variants = await this.getProductVariants(productId);

      // Get recent transactions
      const [transactions] = await db.query(
        `SELECT 
          st.id,
          st.transaction_type,
          pu.unit_name,
          st.quantity,
          st.quantity_in_ml,
          st.reference_type,
          st.notes,
          st.transaction_date
        FROM stock_transactions st
        JOIN product_units pu ON st.unit_id = pu.id
        WHERE st.product_id = ?
        ORDER BY st.transaction_date DESC
        LIMIT 50`,
        [productId]
      );

      return {
        product: product[0],
        currentStock: stockLevels,
        variants: variants,
        recentTransactions: transactions
      };

    } catch (error) {
      throw new Error(`Failed to get stock report: ${error.message}`);
    }
  }

  /**
   * Get low stock alerts
   */
  async getLowStockAlerts() {
    try {
      const [alerts] = await db.query(
        `SELECT 
          i.id,
          i.iname as product_name,
          i.min_stock,
          sb.unit_id,
          pu.unit_name,
          sb.current_quantity,
          sb.available_quantity,
          CASE 
            WHEN sb.available_quantity <= 0 THEN 'OUT_OF_STOCK'
            WHEN sb.available_quantity < (i.min_stock * 0.5) THEN 'CRITICAL'
            WHEN sb.available_quantity < i.min_stock THEN 'LOW'
          END as alert_level
        FROM stock_balance sb
        JOIN product_units pu ON sb.unit_id = pu.id
        JOIN items i ON sb.product_id = i.id
        WHERE sb.available_quantity < i.min_stock
        ORDER BY sb.available_quantity ASC`
      );

      return alerts;

    } catch (error) {
      throw new Error(`Failed to get low stock alerts: ${error.message}`);
    }
  }
}

module.exports = new StockService();
