/**
 * Purchase Management Controller
 * Handles purchase orders, suppliers, and stock procurement
 */

const purchaseService = require('../services/purchaseService');
const { validationResult } = require('express-validator');

class PurchaseController {
  /**
   * Create new purchase order
   * POST /api/purchase/create
   */
  async createPurchase(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { purchaseData, items } = req.body;
      const userId = req.user?.id || null;

      const result = await purchaseService.createPurchase(purchaseData, items, userId);

      res.status(201).json({
        success: true,
        message: 'Purchase order created successfully',
        data: result
      });

    } catch (error) {
      console.error('Create Purchase Error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  /**
   * Get purchase details
   * GET /api/purchase/:id
   */
  async getPurchaseDetails(req, res) {
    try {
      const { id } = req.params;

      const result = await purchaseService.getPurchaseDetails(id);

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
   * Get all purchases
   * GET /api/purchase/all
   */
  async getAllPurchases(req, res) {
    try {
      const filters = {
        supplierId: req.query.supplierId,
        startDate: req.query.startDate,
        endDate: req.query.endDate,
        paymentStatus: req.query.paymentStatus,
        limit: req.query.limit
      };

      const result = await purchaseService.getAllPurchases(filters);

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
   * Add payment to purchase
   * POST /api/purchase/:id/payment
   */
  async addPayment(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const { id } = req.params;
      const userId = req.user?.id || null;

      const result = await purchaseService.addPayment(id, req.body, userId);

      res.json({
        success: true,
        message: 'Payment added successfully',
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
   * Get all suppliers
   * GET /api/purchase/suppliers
   */
  async getAllSuppliers(req, res) {
    try {
      const result = await purchaseService.getAllSuppliers();

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
   * Create supplier
   * POST /api/purchase/suppliers/create
   */
  async createSupplier(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const result = await purchaseService.createSupplier(req.body);

      res.status(201).json({
        success: true,
        message: 'Supplier created successfully',
        data: result
      });

    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new PurchaseController();
