/**
 * Stock Management Controller
 * Handles HTTP requests for stock management operations
 */

const stockService = require('../services/stockService');
const { validationResult } = require('express-validator');

class StockController {
  /**
   * Add stock to inventory
   * POST /api/stock/add
   */
  async addStock(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        unitId,
        quantity,
        referenceType = 'PURCHASE',
        referenceId = null,
        notes = ''
      } = req.body;

      const userId = req.user?.id || null;

      const result = await stockService.addStock(
        productId,
        unitId,
        quantity,
        userId,
        referenceType,
        referenceId,
        notes
      );

      res.json({
        success: true,
        message: 'Stock added successfully',
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Remove stock from inventory
   * POST /api/stock/remove
   */
  async removeStock(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        unitId,
        quantity,
        referenceType = 'SALE',
        referenceId = null,
        notes = ''
      } = req.body;

      const userId = req.user?.id || null;

      const result = await stockService.removeStock(
        productId,
        unitId,
        quantity,
        userId,
        referenceType,
        referenceId,
        notes
      );

      res.json({
        success: true,
        message: 'Stock removed successfully',
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Remove stock using product variants (for liquor serving sizes)
   * POST /api/stock/remove-variant
   */
  async removeStockWithVariant(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        variantId,
        quantity,
        referenceId = null,
        notes = ''
      } = req.body;

      const userId = req.user?.id || null;

      const result = await stockService.removeStockWithVariants(
        productId,
        variantId,
        quantity,
        userId,
        referenceId,
        notes
      );

      res.json({
        success: true,
        message: 'Stock removed successfully',
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get current stock level for a product
   * GET /api/stock/level/:productId
   * Query params: ?unitId=optional
   */
  async getStockLevel(req, res) {
    try {
      const { productId } = req.params;
      const { unitId } = req.query;

      const result = await stockService.getStockLevel(productId, unitId);

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get all units and conversions for a product
   * GET /api/stock/units/:productId
   */
  async getUnits(req, res) {
    try {
      const { productId } = req.params;

      const [units] = await require('../config/dbconnection').db.query(
        `SELECT 
          id,
          product_id,
          unit_name,
          unit_type,
          conversion_factor,
          is_base_unit,
          ml_capacity,
          purchase_price,
          selling_price,
          is_active
        FROM product_units
        WHERE product_id = ? AND is_active = 1
        ORDER BY is_base_unit DESC, ml_capacity DESC`,
        [productId]
      );

      res.json({
        success: true,
        data: units
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get unit conversions for a product
   * GET /api/stock/conversions/:productId
   */
  async getConversions(req, res) {
    try {
      const { productId } = req.params;

      const result = await stockService.getUnitConversions(productId);

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Convert quantity between units
   * POST /api/stock/convert
   */
  async convertUnits(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        fromUnitId,
        toUnitId,
        quantity
      } = req.body;

      const result = await stockService.convertUnits(
        productId,
        fromUnitId,
        toUnitId,
        quantity
      );

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get all variants for a product
   * GET /api/stock/variants/:productId
   */
  async getVariants(req, res) {
    try {
      const { productId } = req.params;

      const result = await stockService.getProductVariants(productId);

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Create a new product variant
   * POST /api/stock/variants/create
   */
  async createVariant(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        variantName,
        baseUnitId,
        quantityInBaseUnit,
        mlQuantity,
        sellingPrice,
        costPrice = 0
      } = req.body;

      const [result] = await require('../config/dbconnection').db.query(
        `INSERT INTO product_variants 
         (product_id, variant_name, base_unit_id, quantity_in_base_unit, ml_quantity, selling_price, cost_price)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [productId, variantName, baseUnitId, quantityInBaseUnit, mlQuantity, sellingPrice, costPrice]
      );

      res.status(201).json({
        success: true,
        message: 'Variant created successfully',
        data: {
          id: result.insertId,
          productId,
          variantName,
          baseUnitId,
          quantityInBaseUnit,
          mlQuantity,
          sellingPrice,
          costPrice
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get complete stock report for a product
   * GET /api/stock/report/:productId
   */
  async getStockReport(req, res) {
    try {
      const { productId } = req.params;

      const result = await stockService.getStockReport(productId);

      res.json({
        success: true,
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get low stock alerts
   * GET /api/stock/alerts/low-stock
   */
  async getLowStockAlerts(req, res) {
    try {
      const result = await stockService.getLowStockAlerts();

      res.json({
        success: true,
        data: result,
        count: result.length
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get stock transaction history
   * GET /api/stock/history/:productId
   * Query params: ?limit=20&offset=0&type=ADD|REMOVE|SALE
   */
  async getTransactionHistory(req, res) {
    try {
      const { productId } = req.params;
      const { limit = 50, offset = 0, type } = req.query;

      let query = `
        SELECT 
          st.id,
          st.transaction_type,
          st.quantity,
          st.quantity_in_ml,
          st.reference_type,
          st.reference_id,
          st.notes,
          pu.unit_name,
          st.user_id,
          st.transaction_date
        FROM stock_transactions st
        JOIN product_units pu ON st.unit_id = pu.id
        WHERE st.product_id = ?
      `;

      const params = [productId];

      if (type) {
        query += ' AND st.transaction_type = ?';
        params.push(type);
      }

      query += ' ORDER BY st.transaction_date DESC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));

      const [transactions] = await require('../config/dbconnection').db.query(query, params);

      res.json({
        success: true,
        data: transactions,
        limit,
        offset
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Create product unit (Bottle, Can, Peg, etc.)
   * POST /api/stock/units/create
   */
  async createUnit(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        unitName,
        unitType = 'DERIVED',
        conversionFactor = 1,
        isBaseUnit = false,
        mlCapacity = null,
        purchasePrice = 0,
        sellingPrice = 0
      } = req.body;

      const [result] = await require('../config/dbconnection').db.query(
        `INSERT INTO product_units 
         (product_id, unit_name, unit_type, conversion_factor, is_base_unit, ml_capacity, purchase_price, selling_price)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [productId, unitName, unitType, conversionFactor, isBaseUnit ? 1 : 0, mlCapacity, purchasePrice, sellingPrice]
      );

      res.status(201).json({
        success: true,
        message: 'Unit created successfully',
        data: {
          id: result.insertId,
          productId,
          unitName,
          unitType,
          conversionFactor,
          isBaseUnit,
          mlCapacity,
          purchasePrice,
          sellingPrice
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Create unit conversion rule
   * POST /api/stock/conversions/create
   */
  async createConversion(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        fromUnitId,
        toUnitId,
        conversionFactor
      } = req.body;

      const [result] = await require('../config/dbconnection').db.query(
        `INSERT INTO stock_conversions 
         (product_id, from_unit_id, to_unit_id, conversion_factor)
         VALUES (?, ?, ?, ?)`,
        [productId, fromUnitId, toUnitId, conversionFactor]
      );

      res.status(201).json({
        success: true,
        message: 'Conversion rule created successfully',
        data: {
          id: result.insertId,
          productId,
          fromUnitId,
          toUnitId,
          conversionFactor
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get all stock information
   * GET /api/stock/all
   */
  async getAllStock(req, res) {
    try {
      const { categoryId, minStock } = req.query;

      let query = `
        SELECT 
          i.id,
          i.iname as product_name,
          i.min_stock,
          sb.unit_id,
          pu.unit_name,
          pu.ml_capacity,
          sb.current_quantity,
          sb.reserved_quantity,
          sb.available_quantity
        FROM stock_balance sb
        JOIN product_units pu ON sb.unit_id = pu.id
        JOIN items i ON sb.product_id = i.id
        WHERE 1=1
      `;

      const params = [];

      if (categoryId) {
        query += ' AND i.catid = ?';
        params.push(categoryId);
      }

      if (minStock) {
        query += ' AND sb.available_quantity < i.min_stock';
      }

      query += ' ORDER BY i.iname ASC, pu.is_base_unit DESC';

      const [results] = await require('../config/dbconnection').db.query(query, params);

      res.json({
        success: true,
        data: results,
        count: results.length
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Update/Set closing stock (absolute quantity)
   * POST /api/stock/update-closing
   */
  async updateClosingStock(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        unitId,
        closingQuantity,
        notes = 'Closing stock update'
      } = req.body;

      const userId = req.user?.id || null;

      // Get current stock
      const [currentStock] = await require('../config/dbconnection').db.query(
        'SELECT current_quantity FROM stock_balance WHERE product_id = ? AND unit_id = ?',
        [productId, unitId]
      );

      const currentQty = currentStock.length > 0 ? parseFloat(currentStock[0].current_quantity) : 0;
      const newQty = parseFloat(closingQuantity);
      const difference = newQty - currentQty;

      if (difference === 0) {
        return res.json({
          success: true,
          message: 'No change in stock quantity',
          data: { currentQuantity: currentQty, closingQuantity: newQty }
        });
      }

      // Add or remove based on difference
      const transactionType = difference > 0 ? 'ADJUST_IN' : 'ADJUST_OUT';
      const referenceType = 'CLOSING_STOCK';
      
      if (difference > 0) {
        // Add stock
        await stockService.addStock(
          productId,
          unitId,
          Math.abs(difference),
          userId,
          referenceType,
          null,
          notes
        );
      } else {
        // Remove stock
        await stockService.removeStock(
          productId,
          unitId,
          Math.abs(difference),
          userId,
          referenceType,
          null,
          notes
        );
      }

      res.json({
        success: true,
        message: 'Closing stock updated successfully',
        data: {
          previousQuantity: currentQty,
          closingQuantity: newQty,
          difference: difference,
          transactionType
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Adjust stock (manual correction)
   * POST /api/stock/adjust
   */
  async adjustStock(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const {
        productId,
        unitId,
        adjustmentType, // 'ADD' or 'REMOVE'
        quantity,
        reason = 'Manual adjustment',
        notes = ''
      } = req.body;

      const userId = req.user?.id || null;
      const referenceType = 'ADJUSTMENT';

      if (adjustmentType === 'ADD') {
        await stockService.addStock(
          productId,
          unitId,
          quantity,
          userId,
          referenceType,
          null,
          `${reason}. ${notes}`.trim()
        );
      } else if (adjustmentType === 'REMOVE') {
        await stockService.removeStock(
          productId,
          unitId,
          quantity,
          userId,
          referenceType,
          null,
          `${reason}. ${notes}`.trim()
        );
      } else {
        return res.status(400).json({
          success: false,
          message: 'Invalid adjustmentType. Must be ADD or REMOVE'
        });
      }

      res.json({
        success: true,
        message: `Stock ${adjustmentType.toLowerCase()}ed successfully`,
        data: {
          productId,
          unitId,
          adjustmentType,
          quantity,
          reason
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get closing stock report for all items
   * GET /api/stock/reports/closing-stock
   */
  async getClosingStockReport(req, res) {
    try {
      const { categoryId, date } = req.query;
      const reportDate = date || new Date().toISOString().split('T')[0];

      let query = `
        SELECT 
          i.id as product_id,
          i.iname as product_name,
          i.catid as category_id,
          pu.id as unit_id,
          pu.unit_name,
          pu.ml_capacity,
          pu.purchase_price,
          pu.selling_price,
          sb.current_quantity,
          sb.reserved_quantity,
          sb.available_quantity,
          (sb.current_quantity * pu.purchase_price) as stock_value_cost,
          (sb.current_quantity * pu.selling_price) as stock_value_selling,
          i.min_stock,
          CASE 
            WHEN sb.available_quantity <= 0 THEN 'OUT_OF_STOCK'
            WHEN sb.available_quantity < i.min_stock THEN 'LOW_STOCK'
            ELSE 'OK'
          END as stock_status
        FROM stock_balance sb
        JOIN product_units pu ON sb.unit_id = pu.id
        JOIN items i ON sb.product_id = i.id
        WHERE pu.is_base_unit = 1
      `;

      const params = [];

      if (categoryId) {
        query += ' AND i.catid = ?';
        params.push(categoryId);
      }

      query += ' ORDER BY i.iname ASC';

      const [stockData] = await require('../config/dbconnection').db.query(query, params);

      // Calculate totals
      const summary = {
        totalItems: stockData.length,
        totalStockValueCost: stockData.reduce((sum, item) => sum + parseFloat(item.stock_value_cost || 0), 0),
        totalStockValueSelling: stockData.reduce((sum, item) => sum + parseFloat(item.stock_value_selling || 0), 0),
        outOfStock: stockData.filter(item => item.stock_status === 'OUT_OF_STOCK').length,
        lowStock: stockData.filter(item => item.stock_status === 'LOW_STOCK').length,
        reportDate
      };

      res.json({
        success: true,
        data: {
          summary,
          items: stockData
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get purchase-stock reconciliation report
   * GET /api/stock/reports/purchase-reconciliation
   */
  async getPurchaseReconciliationReport(req, res) {
    try {
      const { startDate, endDate, productId } = req.query;

      let query = `
        SELECT 
          i.id as product_id,
          i.iname as product_name,
          pu.unit_name,
          
          -- Purchase data
          COALESCE(SUM(CASE WHEN st.transaction_type = 'ADD' AND st.reference_type = 'PURCHASE' THEN st.quantity ELSE 0 END), 0) as total_purchased,
          COALESCE(SUM(CASE WHEN st.transaction_type = 'ADD' AND st.reference_type = 'PURCHASE' THEN st.quantity * pu.purchase_price ELSE 0 END), 0) as purchase_value,
          
          -- Sales/Usage data
          COALESCE(SUM(CASE WHEN st.transaction_type = 'REMOVE' AND st.reference_type = 'SALE' THEN st.quantity ELSE 0 END), 0) as total_sold,
          
          -- Waste/Damage data
          COALESCE(SUM(CASE WHEN st.transaction_type = 'REMOVE' AND st.reference_type IN ('WASTE', 'DAMAGE') THEN st.quantity ELSE 0 END), 0) as total_wasted,
          
          -- Adjustments
          COALESCE(SUM(CASE WHEN st.transaction_type = 'ADD' AND st.reference_type IN ('ADJUSTMENT', 'CLOSING_STOCK') THEN st.quantity ELSE 0 END), 0) as adjustments_in,
          COALESCE(SUM(CASE WHEN st.transaction_type = 'REMOVE' AND st.reference_type IN ('ADJUSTMENT', 'CLOSING_STOCK') THEN st.quantity ELSE 0 END), 0) as adjustments_out,
          
          -- Current stock
          sb.current_quantity,
          sb.available_quantity,
          
          -- Last purchase date
          MAX(CASE WHEN st.reference_type = 'PURCHASE' THEN st.transaction_date END) as last_purchase_date
          
        FROM items i
        JOIN product_units pu ON i.id = pu.product_id AND pu.is_base_unit = 1
        LEFT JOIN stock_transactions st ON i.id = st.product_id AND st.unit_id = pu.id
        LEFT JOIN stock_balance sb ON i.id = sb.product_id AND sb.unit_id = pu.id
        WHERE 1=1
      `;

      const params = [];

      if (productId) {
        query += ' AND i.id = ?';
        params.push(productId);
      }

      if (startDate) {
        query += ' AND st.transaction_date >= ?';
        params.push(startDate);
      }

      if (endDate) {
        query += ' AND st.transaction_date <= ?';
        params.push(endDate);
      }

      query += ' GROUP BY i.id, pu.id ORDER BY i.iname ASC';

      const [reportData] = await require('../config/dbconnection').db.query(query, params);

      // Calculate summary
      const summary = {
        totalPurchased: reportData.reduce((sum, item) => sum + parseFloat(item.total_purchased || 0), 0),
        totalPurchaseValue: reportData.reduce((sum, item) => sum + parseFloat(item.purchase_value || 0), 0),
        totalSold: reportData.reduce((sum, item) => sum + parseFloat(item.total_sold || 0), 0),
        totalWasted: reportData.reduce((sum, item) => sum + parseFloat(item.total_wasted || 0), 0),
        period: {
          startDate: startDate || 'All time',
          endDate: endDate || 'Present'
        }
      };

      res.json({
        success: true,
        data: {
          summary,
          items: reportData
        }
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new StockController();
