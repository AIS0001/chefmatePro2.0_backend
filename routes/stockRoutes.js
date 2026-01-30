/**
 * Stock Management Routes
 * Routes for managing inventory with unit conversions
 */

const express = require('express');
const { body, param, query } = require('express-validator');
const stockController = require('../controllers/stockController');
const { isAuthorize } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(isAuthorize);

/**
 * STOCK ADDITION ENDPOINTS
 */

/**
 * POST /api/stock/add
 * Add stock to inventory
 * Body: {
 *   productId: number,
 *   unitId: number,
 *   quantity: number,
 *   referenceType?: string (PURCHASE|ADJUSTMENT|etc),
 *   referenceId?: number,
 *   notes?: string
 * }
 */
router.post(
  '/add',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('unitId').isInt({ min: 1 }).withMessage('Unit ID must be a positive integer'),
    body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be a positive number'),
    body('referenceType').optional().isString().trim(),
    body('notes').optional().isString().trim()
  ],
  stockController.addStock
);

/**
 * STOCK REMOVAL ENDPOINTS
 */

/**
 * POST /api/stock/remove
 * Remove stock from inventory
 * Body: {
 *   productId: number,
 *   unitId: number,
 *   quantity: number,
 *   referenceType?: string (SALE|WASTE|DAMAGE),
 *   referenceId?: number,
 *   notes?: string
 * }
 */
router.post(
  '/remove',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('unitId').isInt({ min: 1 }).withMessage('Unit ID must be a positive integer'),
    body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be a positive number'),
    body('referenceType').optional().isString().trim(),
    body('notes').optional().isString().trim()
  ],
  stockController.removeStock
);

/**
 * POST /api/stock/remove-variant
 * Remove stock using product variant (for liquor serving sizes)
 * Example: Sell 2x 30ML pegs from a bottle of whiskey
 * Body: {
 *   productId: number,
 *   variantId: number (e.g., 30ML peg variant),
 *   quantity: number (how many pegs to sell),
 *   referenceId?: number (bill ID, order ID),
 *   notes?: string
 * }
 */
router.post(
  '/remove-variant',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('variantId').isInt({ min: 1 }).withMessage('Variant ID must be a positive integer'),
    body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be a positive number'),
    body('notes').optional().isString().trim()
  ],
  stockController.removeStockWithVariant
);

/**
 * STOCK INQUIRY ENDPOINTS
 */

/**
 * GET /api/stock/level/:productId
 * Get current stock level for a product
 * Query: ?unitId=optional
 */
router.get(
  '/level/:productId',
  [param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer')],
  stockController.getStockLevel
);

/**
 * GET /api/stock/all
 * Get all stock information
 * Query: ?categoryId=optional&minStock=true (for low stock only)
 */
router.get(
  '/all',
  [
    query('categoryId').optional().isInt({ min: 1 }),
    query('minStock').optional().isBoolean()
  ],
  stockController.getAllStock
);

/**
 * GET /api/stock/report/:productId
 * Get complete stock report for a product
 * Includes: current stock, variants, recent transactions
 */
router.get(
  '/report/:productId',
  [param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer')],
  stockController.getStockReport
);

/**
 * GET /api/stock/history/:productId
 * Get stock transaction history
 * Query: ?limit=20&offset=0&type=ADD|REMOVE|SALE
 */
router.get(
  '/history/:productId',
  [
    param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 500 }),
    query('offset').optional().isInt({ min: 0 }),
    query('type').optional().isIn(['ADD', 'REMOVE', 'SALE', 'ADJUST'])
  ],
  stockController.getTransactionHistory
);

/**
 * GET /api/stock/alerts/low-stock
 * Get low stock alerts
 */
router.get(
  '/alerts/low-stock',
  stockController.getLowStockAlerts
);

/**
 * UNIT MANAGEMENT ENDPOINTS
 */

/**
 * GET /api/stock/units/:productId
 * Get all units for a product
 * Example response: [
 *   { id: 1, unit_name: 'Bottle', ml_capacity: 750, selling_price: 3000 },
 *   { id: 2, unit_name: '30ML Peg', ml_capacity: 30, selling_price: 150 }
 * ]
 */
router.get(
  '/units/:productId',
  [param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer')],
  stockController.getUnits
);

/**
 * POST /api/stock/units/create
 * Create a new unit for a product
 * Body: {
 *   productId: number,
 *   unitName: string (e.g., 'Bottle', '30ML Peg', 'Can'),
 *   unitType: string ('BASE'|'DERIVED'),
 *   mlCapacity?: number (for liquor - ML capacity),
 *   sellingPrice?: number,
 *   purchasePrice?: number
 * }
 * Example: Create 30ML peg for whiskey
 * {
 *   productId: 126,
 *   unitName: '30ML Peg',
 *   unitType: 'DERIVED',
 *   mlCapacity: 30,
 *   sellingPrice: 150
 * }
 */
router.post(
  '/units/create',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('unitName').notEmpty().trim().withMessage('Unit name is required'),
    body('unitType').isIn(['BASE', 'DERIVED']).withMessage('Unit type must be BASE or DERIVED'),
    body('mlCapacity').optional().isInt({ min: 1 }),
    body('sellingPrice').optional().isFloat({ min: 0 }),
    body('purchasePrice').optional().isFloat({ min: 0 })
  ],
  stockController.createUnit
);

/**
 * UNIT CONVERSION ENDPOINTS
 */

/**
 * GET /api/stock/conversions/:productId
 * Get all unit conversions for a product
 * Example: Get conversion rules between bottle and pegs
 */
router.get(
  '/conversions/:productId',
  [param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer')],
  stockController.getConversions
);

/**
 * POST /api/stock/conversions/create
 * Create a unit conversion rule
 * Body: {
 *   productId: number,
 *   fromUnitId: number,
 *   toUnitId: number,
 *   conversionFactor: number (multiply from_unit by this to get to_unit)
 * }
 * Example: 1 bottle = 25 pegs of 30ML
 * {
 *   productId: 126,
 *   fromUnitId: 1 (Bottle),
 *   toUnitId: 2 (30ML Peg),
 *   conversionFactor: 25
 * }
 */
router.post(
  '/conversions/create',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('fromUnitId').isInt({ min: 1 }).withMessage('From Unit ID must be a positive integer'),
    body('toUnitId').isInt({ min: 1 }).withMessage('To Unit ID must be a positive integer'),
    body('conversionFactor').isFloat({ min: 0.0001 }).withMessage('Conversion factor must be a positive number')
  ],
  stockController.createConversion
);

/**
 * POST /api/stock/convert
 * Convert quantity from one unit to another
 * Body: {
 *   productId: number,
 *   fromUnitId: number,
 *   toUnitId: number,
 *   quantity: number
 * }
 * Example: Convert 1 bottle to pegs
 * Returns: 1 bottle = 25 pegs
 */
router.post(
  '/convert',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('fromUnitId').isInt({ min: 1 }).withMessage('From Unit ID must be a positive integer'),
    body('toUnitId').isInt({ min: 1 }).withMessage('To Unit ID must be a positive integer'),
    body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be a positive number')
  ],
  stockController.convertUnits
);

/**
 * PRODUCT VARIANT ENDPOINTS
 */

/**
 * GET /api/stock/variants/:productId
 * Get all variants for a product
 * Example: Get all serving sizes for whiskey (30ML peg, 60ML, full bottle)
 */
router.get(
  '/variants/:productId',
  [param('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer')],
  stockController.getVariants
);

/**
 * POST /api/stock/variants/create
 * Create a product variant (serving size)
 * Body: {
 *   productId: number,
 *   variantName: string (e.g., '30ML Peg', '60ML', 'Full Bottle'),
 *   baseUnitId: number (the unit this variant is based on),
 *   quantityInBaseUnit: number (how much of base unit = 1 variant),
 *   mlQuantity?: number (ML quantity for this variant),
 *   sellingPrice: number,
 *   costPrice?: number
 * }
 * Example: Create 30ML peg variant for whiskey
 * {
 *   productId: 126,
 *   variantName: '30ML Peg - Whiskey',
 *   baseUnitId: 1 (Bottle),
 *   quantityInBaseUnit: 0.04 (750ML/750 * 30),
 *   mlQuantity: 30,
 *   sellingPrice: 150,
 *   costPrice: 120
 * }
 */
router.post(
  '/variants/create',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('variantName').notEmpty().trim().withMessage('Variant name is required'),
    body('baseUnitId').isInt({ min: 1 }).withMessage('Base Unit ID must be a positive integer'),
    body('quantityInBaseUnit').isFloat({ min: 0.0001 }).withMessage('Quantity in base unit must be a positive number'),
    body('mlQuantity').optional().isInt({ min: 1 }),
    body('sellingPrice').isFloat({ min: 0 }).withMessage('Selling price is required'),
    body('costPrice').optional().isFloat({ min: 0 })
  ],
  stockController.createVariant
);

/**
 * STOCK ADJUSTMENT & CLOSING ENDPOINTS
 */

/**
 * POST /api/stock/update-closing
 * Update closing stock (set absolute quantity)
 * Use this for day-end closing stock reconciliation
 * Body: {
 *   productId: number,
 *   unitId: number,
 *   closingQuantity: number (absolute quantity to set),
 *   notes?: string
 * }
 * Example: Set closing stock for whiskey bottles to 10
 * {
 *   productId: 126,
 *   unitId: 1,
 *   closingQuantity: 10,
 *   notes: 'Day end closing stock - Jan 30, 2026'
 * }
 */
router.post(
  '/update-closing',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('unitId').isInt({ min: 1 }).withMessage('Unit ID must be a positive integer'),
    body('closingQuantity').isFloat({ min: 0 }).withMessage('Closing quantity must be a non-negative number'),
    body('notes').optional().isString().trim()
  ],
  stockController.updateClosingStock
);

/**
 * POST /api/stock/adjust
 * Manual stock adjustment (add or remove with reason)
 * Body: {
 *   productId: number,
 *   unitId: number,
 *   adjustmentType: string ('ADD'|'REMOVE'),
 *   quantity: number,
 *   reason: string (why adjustment is needed),
 *   notes?: string
 * }
 * Example: Add damaged stock back after correction
 * {
 *   productId: 126,
 *   unitId: 1,
 *   adjustmentType: 'ADD',
 *   quantity: 2,
 *   reason: 'Stock count correction - physical verification',
 *   notes: 'Found 2 bottles in storage room'
 * }
 */
router.post(
  '/adjust',
  [
    body('productId').isInt({ min: 1 }).withMessage('Product ID must be a positive integer'),
    body('unitId').isInt({ min: 1 }).withMessage('Unit ID must be a positive integer'),
    body('adjustmentType').isIn(['ADD', 'REMOVE']).withMessage('Adjustment type must be ADD or REMOVE'),
    body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be a positive number'),
    body('reason').notEmpty().trim().withMessage('Reason is required for stock adjustment'),
    body('notes').optional().isString().trim()
  ],
  stockController.adjustStock
);

/**
 * STOCK REPORTS
 */

/**
 * GET /api/stock/reports/closing-stock
 * Get closing stock report for all items
 * Shows current stock levels with valuations
 * Query params:
 *   - categoryId?: number (filter by category)
 *   - date?: date (YYYY-MM-DD, default: today)
 * 
 * Returns:
 * - Summary: total items, stock value (cost & selling), out of stock count
 * - Items: product details, quantities, values, stock status
 * 
 * Example: GET /api/stock/reports/closing-stock?date=2026-01-30
 */
router.get(
  '/reports/closing-stock',
  [
    query('categoryId').optional().isInt({ min: 1 }),
    query('date').optional().isDate()
  ],
  stockController.getClosingStockReport
);

/**
 * GET /api/stock/reports/purchase-reconciliation
 * Get purchase-to-stock reconciliation report
 * Shows purchases, sales, waste, adjustments, and current stock
 * Query params:
 *   - startDate?: date (YYYY-MM-DD)
 *   - endDate?: date (YYYY-MM-DD)
 *   - productId?: number (specific product)
 * 
 * Returns:
 * - Summary: total purchased, purchase value, total sold, total wasted
 * - Items: detailed breakdown per product with last purchase date
 * 
 * Example: GET /api/stock/reports/purchase-reconciliation?startDate=2026-01-01&endDate=2026-01-31
 */
router.get(
  '/reports/purchase-reconciliation',
  [
    query('startDate').optional().isDate(),
    query('endDate').optional().isDate(),
    query('productId').optional().isInt({ min: 1 })
  ],
  stockController.getPurchaseReconciliationReport
);

module.exports = router;
