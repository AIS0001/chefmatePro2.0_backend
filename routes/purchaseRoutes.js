/**
 * Purchase Management Routes
 * Routes for managing purchase orders, suppliers, and stock procurement
 */

const express = require('express');
const { body, param, query } = require('express-validator');
const purchaseController = require('../controllers/purchaseController');
const { isAuthorize } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(isAuthorize);

/**
 * POST /api/purchase/create
 * Create a new purchase order
 * Body: {
 *   purchaseData: {
 *     supplierId: number,
 *     purchaseDate: date (YYYY-MM-DD),
 *     invoiceNumber?: string,
 *     invoiceDate?: date,
 *     totalAmount?: number,
 *     taxAmount?: number,
 *     discountAmount?: number,
 *     netAmount: number,
 *     paymentStatus?: 'PENDING'|'PARTIAL'|'PAID',
 *     paymentMethod?: string,
 *     notes?: string
 *   },
 *   items: [
 *     {
 *       productId: number,
 *       unitId: number,
 *       quantity: number,
 *       unitPrice: number,
 *       taxRate?: number,
 *       taxAmount?: number,
 *       totalAmount: number,
 *       batchNumber?: string,
 *       expiryDate?: date,
 *       notes?: string
 *     }
 *   ]
 * }
 * 
 * Example:
 * {
 *   "purchaseData": {
 *     "supplierId": 1,
 *     "purchaseDate": "2026-01-30",
 *     "invoiceNumber": "INV-2026-001",
 *     "invoiceDate": "2026-01-30",
 *     "totalAmount": 10000,
 *     "taxAmount": 1800,
 *     "discountAmount": 200,
 *     "netAmount": 11600,
 *     "paymentStatus": "PAID",
 *     "paymentMethod": "BANK_TRANSFER",
 *     "notes": "Monthly liquor purchase"
 *   },
 *   "items": [
 *     {
 *       "productId": 22,
 *       "unitId": 1,
 *       "quantity": 10,
 *       "unitPrice": 500,
 *       "taxRate": 18,
 *       "taxAmount": 900,
 *       "totalAmount": 5900,
 *       "batchNumber": "BATCH-001"
 *     },
 *     {
 *       "productId": 23,
 *       "unitId": 5,
 *       "quantity": 12,
 *       "unitPrice": 480,
 *       "taxRate": 18,
 *       "taxAmount": 900,
 *       "totalAmount": 5700
 *     }
 *   ]
 * }
 */
router.post(
  '/create',
  [
    body('purchaseData').isObject().withMessage('Purchase data is required'),
    body('purchaseData.supplierId').isInt({ min: 1 }).withMessage('Supplier ID is required'),
    body('purchaseData.purchaseDate').isDate().withMessage('Purchase date is required'),
    body('purchaseData.netAmount').isFloat({ min: 0 }).withMessage('Net amount is required'),
    body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
    body('items.*.productId').isInt({ min: 1 }).withMessage('Product ID is required'),
    body('items.*.unitId').isInt({ min: 1 }).withMessage('Unit ID is required'),
    body('items.*.quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be positive'),
    body('items.*.unitPrice').isFloat({ min: 0 }).withMessage('Unit price is required'),
    body('items.*.totalAmount').isFloat({ min: 0 }).withMessage('Total amount is required')
  ],
  purchaseController.createPurchase
);

/**
 * GET /api/purchase/:id
 * Get purchase order details
 * Returns: Purchase info, items, and payment history
 */
router.get(
  '/:id',
  [param('id').isInt({ min: 1 }).withMessage('Purchase ID must be a positive integer')],
  purchaseController.getPurchaseDetails
);

/**
 * GET /api/purchase/all
 * Get all purchase orders
 * Query params:
 *   - supplierId?: number
 *   - startDate?: date (YYYY-MM-DD)
 *   - endDate?: date (YYYY-MM-DD)
 *   - paymentStatus?: 'PENDING'|'PARTIAL'|'PAID'
 *   - limit?: number
 * 
 * Example: GET /api/purchase/all?startDate=2026-01-01&endDate=2026-01-31&paymentStatus=PENDING
 */
router.get(
  '/all',
  [
    query('supplierId').optional().isInt({ min: 1 }),
    query('startDate').optional().isDate(),
    query('endDate').optional().isDate(),
    query('paymentStatus').optional().isIn(['PENDING', 'PARTIAL', 'PAID']),
    query('limit').optional().isInt({ min: 1, max: 1000 })
  ],
  purchaseController.getAllPurchases
);

/**
 * POST /api/purchase/:id/payment
 * Add payment to purchase order
 * Body: {
 *   paymentDate: date (YYYY-MM-DD),
 *   amount: number,
 *   paymentMethod: string (CASH|CARD|UPI|BANK_TRANSFER),
 *   referenceNumber?: string,
 *   notes?: string
 * }
 * 
 * Example:
 * {
 *   "paymentDate": "2026-01-30",
 *   "amount": 5000,
 *   "paymentMethod": "UPI",
 *   "referenceNumber": "UPI123456789",
 *   "notes": "Partial payment"
 * }
 */
router.post(
  '/:id/payment',
  [
    param('id').isInt({ min: 1 }).withMessage('Purchase ID must be a positive integer'),
    body('paymentDate').isDate().withMessage('Payment date is required'),
    body('amount').isFloat({ min: 0.01 }).withMessage('Amount must be positive'),
    body('paymentMethod').notEmpty().trim().withMessage('Payment method is required'),
    body('referenceNumber').optional().trim(),
    body('notes').optional().trim()
  ],
  purchaseController.addPayment
);

/**
 * SUPPLIER MANAGEMENT
 */

/**
 * GET /api/purchase/suppliers
 * Get all active suppliers
 */
router.get(
  '/suppliers',
  purchaseController.getAllSuppliers
);

/**
 * POST /api/purchase/suppliers/create
 * Create a new supplier
 * Body: {
 *   supplierName: string,
 *   companyName?: string,
 *   phone?: string,
 *   email?: string,
 *   address?: string,
 *   taxid?: string
 * }
 * 
 * Example:
 * {
 *   "supplierName": "Rahul Verma",
 *   "companyName": "Premium Liquors Pvt Ltd",
 *   "phone": "9876543214",
 *   "email": "rahul@premiumliquors.com",
 *   "address": "123 Business Park, Mumbai",
 *   "taxid": "27AABCP1234R1Z5"
 * }
 */
router.post(
  '/suppliers/create',
  [
    body('supplierName').notEmpty().trim().withMessage('Supplier name is required'),
    body('companyName').optional().trim(),
    body('phone').optional().trim(),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().trim(),
    body('taxid').optional().trim()
  ],
  purchaseController.createSupplier
);

module.exports = router;

module.exports = router;
