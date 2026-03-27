const errorLogService = require('../services/errorLogService');

/**
 * ERROR LOG CONTROLLER
 * Handles retrieving and analyzing API error logs for super admin
 */

/**
 * Get logs for today or specific date
 * @route   GET /api/super-admin/logs/by-date
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @access  Super Admin only
 */
const getLogsByDate = async (req, res) => {
  try {
    let { date } = req.query;

    if (!date) {
      const today = new Date();
      date = today.toISOString().split('T')[0];
    }

    // Validate date format
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid date format. Use YYYY-MM-DD'
      });
    }

    const logs = errorLogService.getLogsByDate(date);

    res.json({
      success: true,
      data: {
        date,
        count: logs.length,
        logs
      }
    });
  } catch (error) {
    console.error('Error fetching logs by date:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch logs',
      details: error.message
    });
  }
};

/**
 * Get logs for date range
 * @route   GET /api/super-admin/logs/by-range
 * @query   startDate (YYYY-MM-DD)
 * @query   endDate (YYYY-MM-DD)
 * @access  Super Admin only
 */
const getLogsByDateRange = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        error: 'startDate and endDate are required in YYYY-MM-DD format'
      });
    }

    if (!/^\d{4}-\d{2}-\d{2}$/.test(startDate) || !/^\d{4}-\d{2}-\d{2}$/.test(endDate)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid date format. Use YYYY-MM-DD'
      });
    }

    const logs = errorLogService.getLogsByDateRange(startDate, endDate);

    res.json({
      success: true,
      data: {
        startDate,
        endDate,
        count: logs.length,
        logs
      }
    });
  } catch (error) {
    console.error('Error fetching logs by range:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch logs',
      details: error.message
    });
  }
};

/**
 * Get logs for specific shop
 * @route   GET /api/super-admin/logs/by-shop/:shopId
 * @param   shopId - Shop ID
 * @query   limit (default 100)
 * @access  Super Admin only
 */
const getLogsByShop = async (req, res) => {
  try {
    const { shopId } = req.params;
    const { limit = 100 } = req.query;

    if (!shopId) {
      return res.status(400).json({
        success: false,
        error: 'shopId is required'
      });
    }

    const logs = errorLogService.getLogsByShopId(parseInt(shopId), parseInt(limit));

    res.json({
      success: true,
      data: {
        shopId: parseInt(shopId),
        limit: parseInt(limit),
        count: logs.length,
        logs
      }
    });
  } catch (error) {
    console.error('Error fetching logs by shop:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch logs',
      details: error.message
    });
  }
};

/**
 * Get logs by HTTP status code
 * @route   GET /api/super-admin/logs/by-status/:statusCode
 * @param   statusCode - HTTP status code (404, 500, etc.)
 * @query   limit (default 50)
 * @access  Super Admin only
 */
const getLogsByStatusCode = async (req, res) => {
  try {
    const { statusCode } = req.params;
    const { limit = 50 } = req.query;

    if (!statusCode) {
      return res.status(400).json({
        success: false,
        error: 'statusCode is required'
      });
    }

    const logs = errorLogService.getLogsByStatusCode(parseInt(statusCode), parseInt(limit));

    res.json({
      success: true,
      data: {
        statusCode: parseInt(statusCode),
        limit: parseInt(limit),
        count: logs.length,
        logs
      }
    });
  } catch (error) {
    console.error('Error fetching logs by status code:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch logs',
      details: error.message
    });
  }
};

/**
 * Get log statistics for a date
 * @route   GET /api/super-admin/logs/statistics
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @access  Super Admin only
 */
const getLogStatistics = async (req, res) => {
  try {
    let { date } = req.query;

    if (!date) {
      const today = new Date();
      date = today.toISOString().split('T')[0];
    }

    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid date format. Use YYYY-MM-DD'
      });
    }

    const stats = errorLogService.getLogStatistics(date);

    res.json({
      success: true,
      data: {
        date,
        statistics: stats
      }
    });
  } catch (error) {
    console.error('Error fetching log statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch statistics',
      details: error.message
    });
  }
};

/**
 * Get list of available log files
 * @route   GET /api/super-admin/logs/available
 * @access  Super Admin only
 */
const getAvailableLogFiles = async (req, res) => {
  try {
    const files = errorLogService.getAvailableLogFiles();

    res.json({
      success: true,
      data: {
        count: files.length,
        files
      }
    });
  } catch (error) {
    console.error('Error fetching available logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch available logs',
      details: error.message
    });
  }
};

/**
 * Get log summary (quick overview)
 * @route   GET /api/super-admin/logs/summary
 * @query   date (YYYY-MM-DD format, defaults to today)
 * @access  Super Admin only
 */
const getLogSummary = async (req, res) => {
  try {
    let { date } = req.query;

    if (!date) {
      const today = new Date();
      date = today.toISOString().split('T')[0];
    }

    const stats = errorLogService.getLogStatistics(date);
    const logs = errorLogService.getLogsByDate(date);

    // Get the most common errors
    const sortedByCount = Object.entries(stats.byStatusCode || {})
      .map(([code, count]) => ({ code: parseInt(code), count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    res.json({
      success: true,
      data: {
        date,
        overview: {
          totalErrors: stats.totalErrors || 0,
          topStatusCodes: sortedByCount,
          affectedEndpoints: Object.keys(stats.byEndpoint || {}).length || 0,
          affectedShops: Object.keys(stats.byShop || {}).length || 0
        },
        statistics: stats
      }
    });
  } catch (error) {
    console.error('Error fetching log summary:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch summary',
      details: error.message
    });
  }
};

module.exports = {
  getLogsByDate,
  getLogsByDateRange,
  getLogsByShop,
  getLogsByStatusCode,
  getLogStatistics,
  getAvailableLogFiles,
  getLogSummary
};
