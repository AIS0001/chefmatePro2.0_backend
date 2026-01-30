/**
 * Purchase Management Service
 * Handles purchase orders, stock updates, and supplier management
 */

const { db } = require('../config/dbconnection');
const stockService = require('./stockService');

class PurchaseService {
  /**
   * Create a new purchase order with items
   */
  async createPurchase(purchaseData, items, userId) {
    const connection = await db.getConnection();
    
    try {
      await connection.beginTransaction();

      // Generate purchase number
      const purchaseNumber = await this.generatePurchaseNumber(connection);

      // Insert purchase order
      const [purchaseResult] = await connection.query(
        `INSERT INTO purchase_orders 
         (purchase_number, supplier_id, purchase_date, invoice_number, invoice_date, 
          total_amount, tax_amount, discount_amount, net_amount, payment_status, 
          payment_method, notes, created_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          purchaseNumber,
          purchaseData.supplierId,
          purchaseData.purchaseDate,
          purchaseData.invoiceNumber || null,
          purchaseData.invoiceDate || null,
          purchaseData.totalAmount || 0,
          purchaseData.taxAmount || 0,
          purchaseData.discountAmount || 0,
          purchaseData.netAmount || 0,
          purchaseData.paymentStatus || 'PENDING',
          purchaseData.paymentMethod || null,
          purchaseData.notes || '',
          userId
        ]
      );

      const purchaseId = purchaseResult.insertId;

      // Insert purchase items and update stock
      for (const item of items) {
        // Insert purchase item
        await connection.query(
          `INSERT INTO purchase_items 
           (purchase_id, product_id, unit_id, quantity, unit_price, tax_rate, 
            tax_amount, total_amount, batch_number, expiry_date, notes)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            purchaseId,
            item.productId,
            item.unitId,
            item.quantity,
            item.unitPrice,
            item.taxRate || 0,
            item.taxAmount || 0,
            item.totalAmount,
            item.batchNumber || null,
            item.expiryDate || null,
            item.notes || ''
          ]
        );

        // Add stock using stockService
        await this.addStockFromPurchase(
          connection,
          item.productId,
          item.unitId,
          item.quantity,
          userId,
          purchaseId,
          `Purchase ${purchaseNumber}`
        );
      }

      // Record payment if paid
      if (purchaseData.paymentStatus === 'PAID' && purchaseData.netAmount > 0) {
        await connection.query(
          `INSERT INTO purchase_payments 
           (purchase_id, payment_date, amount, payment_method, notes, created_by)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [
            purchaseId,
            purchaseData.purchaseDate,
            purchaseData.netAmount,
            purchaseData.paymentMethod,
            'Full payment on purchase',
            userId
          ]
        );
      }

      await connection.commit();

      return {
        purchaseId,
        purchaseNumber,
        message: 'Purchase order created and stock updated successfully'
      };

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Add stock from purchase (internal method)
   */
  async addStockFromPurchase(connection, productId, unitId, quantity, userId, purchaseId, notes) {
    // Get unit info for ML calculation
    const [unitInfo] = await connection.query(
      'SELECT ml_capacity FROM product_units WHERE id = ?',
      [unitId]
    );

    const quantityInMl = unitInfo[0]?.ml_capacity ? quantity * unitInfo[0].ml_capacity : null;

    // Record transaction
    await connection.query(
      `INSERT INTO stock_transactions 
       (product_id, transaction_type, unit_id, quantity, quantity_in_ml, 
        reference_type, reference_id, user_id, notes)
       VALUES (?, 'ADD', ?, ?, ?, 'PURCHASE', ?, ?, ?)`,
      [productId, unitId, quantity, quantityInMl, purchaseId, userId, notes]
    );

    // Update stock balance
    const [existingStock] = await connection.query(
      'SELECT id, current_quantity FROM stock_balance WHERE product_id = ? AND unit_id = ?',
      [productId, unitId]
    );

    if (existingStock.length > 0) {
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
  }

  /**
   * Generate purchase number (PO-2026-0001)
   */
  async generatePurchaseNumber(connection) {
    const year = new Date().getFullYear();
    const prefix = `PO-${year}-`;

    const [result] = await connection.query(
      `SELECT purchase_number FROM purchase_orders 
       WHERE purchase_number LIKE ? 
       ORDER BY id DESC LIMIT 1`,
      [`${prefix}%`]
    );

    if (result.length === 0) {
      return `${prefix}0001`;
    }

    const lastNumber = parseInt(result[0].purchase_number.split('-')[2]);
    const newNumber = (lastNumber + 1).toString().padStart(4, '0');
    return `${prefix}${newNumber}`;
  }

  /**
   * Get purchase details
   */
  async getPurchaseDetails(purchaseId) {
    const [purchase] = await db.query(
      `SELECT 
        po.*,
        s.name as supplier_name,
        s.company_name,
        s.contact as supplier_phone,
        s.email as supplier_email
       FROM purchase_orders po
       JOIN suppliers s ON po.supplier_id = s.id
       WHERE po.id = ?`,
      [purchaseId]
    );

    if (purchase.length === 0) {
      throw new Error('Purchase order not found');
    }

    const [items] = await db.query(
      `SELECT 
        pi.*,
        i.iname as product_name,
        pu.unit_name
       FROM purchase_items pi
       JOIN items i ON pi.product_id = i.id
       JOIN product_units pu ON pi.unit_id = pu.id
       WHERE pi.purchase_id = ?`,
      [purchaseId]
    );

    const [payments] = await db.query(
      `SELECT * FROM purchase_payments WHERE purchase_id = ? ORDER BY payment_date DESC`,
      [purchaseId]
    );

    return {
      ...purchase[0],
      items,
      payments
    };
  }

  /**
   * Get all purchases
   */
  async getAllPurchases(filters = {}) {
    let query = `
      SELECT 
        po.id,
        po.purchase_number,
        po.purchase_date,
        po.invoice_number,
        po.net_amount,
        po.payment_status,
        s.name as supplier_name,
        s.company_name,
        COUNT(pi.id) as total_items
      FROM purchase_orders po
      JOIN suppliers s ON po.supplier_id = s.id
      LEFT JOIN purchase_items pi ON po.id = pi.purchase_id
      WHERE 1=1
    `;

    const params = [];

    if (filters.supplierId) {
      query += ' AND po.supplier_id = ?';
      params.push(filters.supplierId);
    }

    if (filters.startDate) {
      query += ' AND po.purchase_date >= ?';
      params.push(filters.startDate);
    }

    if (filters.endDate) {
      query += ' AND po.purchase_date <= ?';
      params.push(filters.endDate);
    }

    if (filters.paymentStatus) {
      query += ' AND po.payment_status = ?';
      params.push(filters.paymentStatus);
    }

    query += ' GROUP BY po.id ORDER BY po.purchase_date DESC, po.id DESC';

    if (filters.limit) {
      query += ' LIMIT ?';
      params.push(parseInt(filters.limit));
    }

    const [purchases] = await db.query(query, params);
    return purchases;
  }

  /**
   * Add payment to purchase
   */
  async addPayment(purchaseId, paymentData, userId) {
    const connection = await db.getConnection();
    
    try {
      await connection.beginTransaction();

      // Get purchase details
      const [purchase] = await connection.query(
        'SELECT net_amount FROM purchase_orders WHERE id = ?',
        [purchaseId]
      );

      if (purchase.length === 0) {
        throw new Error('Purchase order not found');
      }

      // Get total paid
      const [totalPaid] = await connection.query(
        'SELECT COALESCE(SUM(amount), 0) as total FROM purchase_payments WHERE purchase_id = ?',
        [purchaseId]
      );

      const remaining = purchase[0].net_amount - totalPaid[0].total;

      if (paymentData.amount > remaining) {
        throw new Error(`Payment amount exceeds remaining balance (${remaining})`);
      }

      // Insert payment
      await connection.query(
        `INSERT INTO purchase_payments 
         (purchase_id, payment_date, amount, payment_method, reference_number, notes, created_by)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          purchaseId,
          paymentData.paymentDate,
          paymentData.amount,
          paymentData.paymentMethod,
          paymentData.referenceNumber || null,
          paymentData.notes || '',
          userId
        ]
      );

      // Update payment status
      const newTotal = totalPaid[0].total + paymentData.amount;
      let paymentStatus = 'PARTIAL';
      if (newTotal >= purchase[0].net_amount) {
        paymentStatus = 'PAID';
      }

      await connection.query(
        'UPDATE purchase_orders SET payment_status = ? WHERE id = ?',
        [paymentStatus, purchaseId]
      );

      await connection.commit();

      return {
        message: 'Payment added successfully',
        paymentStatus,
        totalPaid: newTotal,
        remaining: purchase[0].net_amount - newTotal
      };

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  /**
   * Get all suppliers
   */
  async getAllSuppliers() {
    const [suppliers] = await db.query(
      `SELECT 
        id,
        name as supplier_name,
        company_name,
        contact as phone,
        email,
        taxid,
        address,
        COALESCE(is_active, 1) as is_active
       FROM suppliers 
       WHERE COALESCE(is_active, 1) = 1 
       ORDER BY name ASC`
    );
    return suppliers;
  }

  /**
   * Create supplier
   */
  async createSupplier(supplierData) {
    const [result] = await db.query(
      `INSERT INTO suppliers 
       (name, company_name, contact, email, address, taxid)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        supplierData.supplierName,
        supplierData.companyName || null,
        supplierData.phone || null,
        supplierData.email || null,
        supplierData.address || null,
        supplierData.taxid || null
      ]
    );

    return {
      id: result.insertId,
      ...supplierData
    };
  }
}

module.exports = new PurchaseService();
