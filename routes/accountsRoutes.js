const express = require('express');
const router = express.Router();
const { isAuthorize } = require('../middleware/auth');
const accountsController = require('../controllers/accountsController');

/**
 * ACCOUNTS & ANALYTICS ROUTES
 * All routes for financial analytics and sales dashboards
 */

// ============================================
// SALES SUMMARY CARDS
// ============================================

/**
 * @route   GET /api/accounts/sales/today
 * @desc    Get today's sales summary with payment breakdown
 * @access  Private
 * @returns {Object} Today's sales metrics
 */
router.get(
  '/sales/today',
  isAuthorize,
  accountsController.getTodaySalesSummary
);

/**
 * @route   GET /api/accounts/sales/weekly
 * @desc    Get weekly sales summary (last 7 days)
 * @access  Private
 * @returns {Object} Weekly sales with daily breakdown
 */
router.get(
  '/sales/weekly',
  isAuthorize,
  accountsController.getWeeklySalesSummary
);

/**
 * @route   GET /api/accounts/sales/monthly
 * @desc    Get monthly sales summary with projections
 * @access  Private
 * @returns {Object} Monthly sales metrics
 */
router.get(
  '/sales/monthly',
  isAuthorize,
  accountsController.getMonthlySalesSummary
);

/**
 * @route   GET /api/accounts/sales/range
 * @desc    Get sales summary for custom date range
 * @access  Private
 * @query   startDate, endDate (YYYY-MM-DD format)
 * @returns {Object} Custom period sales metrics
 */
router.get(
  '/sales/range',
  isAuthorize,
  accountsController.getDateRangeSalesSummary
);

// ============================================
// REVENUE ANALYTICS
// ============================================

/**
 * @route   GET /api/accounts/revenue/comparison
 * @desc    Get revenue comparison across different periods
 * @access  Private
 * @returns {Object} Comparative revenue data with growth percentages
 */
router.get(
  '/revenue/comparison',
  isAuthorize,
  accountsController.getRevenueComparison
);

/**
 * @route   GET /api/accounts/revenue/hourly
 * @desc    Get hourly sales distribution for today
 * @access  Private
 * @returns {Object} Hour-by-hour revenue breakdown
 */
router.get(
  '/revenue/hourly',
  isAuthorize,
  accountsController.getHourlySalesDistribution
);

// ============================================
// PAYMENT MODE ANALYTICS
// ============================================

/**
 * @route   GET /api/accounts/payments/distribution
 * @desc    Get payment mode distribution
 * @access  Private
 * @query   period (today|week|month) - Default: today
 * @returns {Object} Payment method breakdown with percentages
 */
router.get(
  '/payments/distribution',
  isAuthorize,
  accountsController.getPaymentModeDistribution
);

// ============================================
// TOP PERFORMERS
// ============================================

/**
 * @route   GET /api/accounts/top/items
 * @desc    Get top selling items
 * @access  Private
 * @query   limit (number) - Default: 10
 * @query   period (today|week|month) - Default: month
 * @returns {Object} Top selling items with revenue data
 */
router.get(
  '/top/items',
  isAuthorize,
  accountsController.getTopSellingItems
);

/**
 * @route   GET /api/accounts/top/categories
 * @desc    Get category-wise sales performance
 * @access  Private
 * @query   period (today|week|month) - Default: month
 * @returns {Object} Category performance with revenue percentages
 */
router.get(
  '/top/categories',
  isAuthorize,
  accountsController.getCategoryPerformance
);

// ============================================
// PROFIT & LOSS
// ============================================

/**
 * @route   GET /api/accounts/profit-loss
 * @desc    Get profit & loss summary
 * @access  Private
 * @query   period (today|week|month) - Default: month
 * @returns {Object} Revenue, expenses, and profit margins
 */
router.get(
  '/profit-loss',
  isAuthorize,
  accountsController.getProfitLossSummary
);

// ============================================
// DASHBOARD OVERVIEW
// ============================================

/**
 * @route   GET /api/accounts/dashboard
 * @desc    Get complete accounts dashboard overview
 * @access  Private
 * @returns {Object} Comprehensive dashboard metrics
 */
router.get(
  '/dashboard',
  isAuthorize,
  accountsController.getAccountsDashboard
);

// ============================================
// PENDING INVOICES
// ============================================

/**
 * @route   GET /api/accounts/order-items/pending-invoice
 * @desc    Get pending invoice records (unbilled order items)
 * @access  Private
 * @query   shop_id (optional) - Shop identifier
 * @returns {Object} Array of pending invoice items with totals
 */
router.get(
  '/order-items/pending-invoice',
  isAuthorize,
  accountsController.getPendingInvoiceItems
);

module.exports = router;
