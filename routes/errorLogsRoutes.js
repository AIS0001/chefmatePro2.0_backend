const express = require('express');
const router = express.Router();
const { isAuthorize } = require('../middleware/auth');
const { isSuperAdmin } = require('../middleware/superAdminAuth');
const errorLogController = require('../controllers/errorLogController');

/**
 * ERROR LOGS ROUTES
 * Super Admin endpoints for monitoring API errors
 * All routes require super admin authentication
 */

/**
 * @route   GET /api/super-admin/logs/by-date
 * @desc    Get error logs for specific date
 * @access  Super Admin only
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @returns {Object} Error logs for the date
 */
router.get(
  '/logs/by-date',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogsByDate
);

/**
 * @route   GET /api/super-admin/logs/by-range
 * @desc    Get error logs for date range
 * @access  Super Admin only
 * @query   startDate (YYYY-MM-DD format)
 * @query   endDate (YYYY-MM-DD format)
 * @returns {Object} Error logs for the range
 */
router.get(
  '/logs/by-range',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogsByDateRange
);

/**
 * @route   GET /api/super-admin/logs/by-shop/:shopId
 * @desc    Get error logs for specific shop
 * @access  Super Admin only
 * @param   shopId (Shop identifier)
 * @query   limit (default 100)
 * @returns {Object} Error logs for the shop
 */
router.get(
  '/logs/by-shop/:shopId',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogsByShop
);

/**
 * @route   GET /api/super-admin/logs/by-status/:statusCode
 * @desc    Get error logs by HTTP status code
 * @access  Super Admin only
 * @param   statusCode (404, 500, etc.)
 * @query   limit (default 50)
 * @returns {Object} Error logs with specific status code
 */
router.get(
  '/logs/by-status/:statusCode',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogsByStatusCode
);

/**
 * @route   GET /api/super-admin/logs/statistics
 * @desc    Get error log statistics for a date
 * @access  Super Admin only
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @returns {Object} Statistics grouped by status code, endpoint, shop, method
 */
router.get(
  '/logs/statistics',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogStatistics
);

/**
 * @route   GET /api/super-admin/logs/available
 * @desc    Get list of available error log files
 * @access  Super Admin only
 * @returns {Object} List of log files with dates
 */
router.get(
  '/logs/available',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getAvailableLogFiles
);

/**
 * @route   GET /api/super-admin/logs/summary
 * @desc    Get error log summary/overview
 * @access  Super Admin only
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @returns {Object} Summary with top errors, affected shops, etc.
 */
router.get(
  '/logs/summary',
  isAuthorize,
  isSuperAdmin,
  errorLogController.getLogSummary
);

module.exports = router;
