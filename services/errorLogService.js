const fs = require('fs');
const path = require('path');

/**
 * ERROR LOGGING SERVICE
 * Handles writing API errors to log files for monitoring
 */

const logsDir = path.join(__dirname, '../logs');

// Ensure logs directory exists
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

/**
 * Generate filename based on date (YYYY-MM-DD format)
 * Creates separate logs per day
 */
const getLogFileName = () => {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `error-${year}-${month}-${day}.log`;
};

/**
 * Format log entry with timestamp and metadata
 */
const formatLogEntry = (logData) => {
  const timestamp = new Date().toISOString();
  return JSON.stringify({
    timestamp,
    ...logData
  });
};

/**
 * Write error log to file
 * @param {Object} logData - Error information
 * @param {number} logData.statusCode - HTTP status code
 * @param {string} logData.method - HTTP method (GET, POST, etc.)
 * @param {string} logData.endpoint - API endpoint
 * @param {string} logData.error - Error message
 * @param {number} logData.shopId - Shop ID
 * @param {string} logData.userId - User ID
 * @param {number} logData.responseTime - Response time in ms
 * @param {string} logData.ip - Client IP address
 */
const logApiError = (logData) => {
  try {
    const logFile = path.join(logsDir, getLogFileName());
    const logEntry = formatLogEntry(logData);
    
    // Append to log file with newline separator
    fs.appendFileSync(logFile, logEntry + '\n', 'utf-8');
    
    // Also log to console in development
    if (process.env.NODE_ENV !== 'production') {
      console.error(`[API ERROR LOG] ${logEntry}`);
    }
    
    return true;
  } catch (error) {
    console.error('Failed to write error log:', error);
    return false;
  }
};

/**
 * Get logs for a specific date
 * @param {string} date - Date in YYYY-MM-DD format
 * @returns {Array} Array of log entries
 */
const getLogsByDate = (date) => {
  try {
    const logFile = path.join(logsDir, `error-${date}.log`);
    
    if (!fs.existsSync(logFile)) {
      return [];
    }
    
    const content = fs.readFileSync(logFile, 'utf-8');
    const logs = content
      .split('\n')
      .filter(line => line.trim())
      .map(line => {
        try {
          return JSON.parse(line);
        } catch (e) {
          return null;
        }
      })
      .filter(log => log !== null);
    
    return logs;
  } catch (error) {
    console.error('Error reading log file:', error);
    return [];
  }
};

/**
 * Get logs for a date range
 * @param {string} startDate - Start date in YYYY-MM-DD format
 * @param {string} endDate - End date in YYYY-MM-DD format
 * @returns {Array} Array of log entries
 */
const getLogsByDateRange = (startDate, endDate) => {
  try {
    const logs = [];
    let currentDate = new Date(startDate);
    const end = new Date(endDate);
    
    while (currentDate <= end) {
      const year = currentDate.getFullYear();
      const month = String(currentDate.getMonth() + 1).padStart(2, '0');
      const day = String(currentDate.getDate()).padStart(2, '0');
      const dateStr = `${year}-${month}-${day}`;
      
      const dateLogs = getLogsByDate(dateStr);
      logs.push(...dateLogs);
      
      currentDate.setDate(currentDate.getDate() + 1);
    }
    
    return logs;
  } catch (error) {
    console.error('Error reading log range:', error);
    return [];
  }
};

/**
 * Get logs filtered by shop ID
 * @param {number} shopId - Shop ID
 * @param {number} limit - Number of logs to return (default 100)
 * @returns {Array} Array of log entries
 */
const getLogsByShopId = (shopId, limit = 100) => {
  try {
    const todayDate = new Date();
    const year = todayDate.getFullYear();
    const month = String(todayDate.getMonth() + 1).padStart(2, '0');
    const day = String(todayDate.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    
    const logs = getLogsByDate(dateStr);
    return logs
      .filter(log => log.shopId === shopId)
      .slice(-limit);
  } catch (error) {
    console.error('Error filtering logs by shop:', error);
    return [];
  }
};

/**
 * Get logs filtered by status code
 * @param {number} statusCode - HTTP status code
 * @param {number} limit - Number of logs to return (default 50)
 * @returns {Array} Array of log entries
 */
const getLogsByStatusCode = (statusCode, limit = 50) => {
  try {
    const todayDate = new Date();
    const year = todayDate.getFullYear();
    const month = String(todayDate.getMonth() + 1).padStart(2, '0');
    const day = String(todayDate.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    
    const logs = getLogsByDate(dateStr);
    return logs
      .filter(log => log.statusCode === statusCode)
      .slice(-limit);
  } catch (error) {
    console.error('Error filtering logs by status code:', error);
    return [];
  }
};

/**
 * Get all available log files
 * @returns {Array} Array of log file names
 */
const getAvailableLogFiles = () => {
  try {
    return fs.readdirSync(logsDir)
      .filter(file => file.startsWith('error-') && file.endsWith('.log'))
      .sort()
      .reverse();
  } catch (error) {
    console.error('Error reading log files:', error);
    return [];
  }
};

/**
 * Get log statistics for a date
 * @param {string} date - Date in YYYY-MM-DD format
 * @returns {Object} Statistics for the date
 */
const getLogStatistics = (date) => {
  try {
    const logs = getLogsByDate(date);
    
    if (logs.length === 0) {
      return {
        totalErrors: 0,
        byStatusCode: {},
        byEndpoint: {},
        byShop: {}
      };
    }
    
    const stats = {
      totalErrors: logs.length,
      byStatusCode: {},
      byEndpoint: {},
      byShop: {},
      byMethod: {}
    };
    
    logs.forEach(log => {
      // Count by status code
      stats.byStatusCode[log.statusCode] = (stats.byStatusCode[log.statusCode] || 0) + 1;
      
      // Count by endpoint
      stats.byEndpoint[log.endpoint] = (stats.byEndpoint[log.endpoint] || 0) + 1;
      
      // Count by shop
      stats.byShop[log.shopId || 'unknown'] = (stats.byShop[log.shopId || 'unknown'] || 0) + 1;
      
      // Count by method
      stats.byMethod[log.method] = (stats.byMethod[log.method] || 0) + 1;
    });
    
    return stats;
  } catch (error) {
    console.error('Error calculating statistics:', error);
    return {};
  }
};

/**
 * Clear old logs (older than specified days)
 * @param {number} days - Number of days to keep (default 30)
 */
const clearOldLogs = (days = 30) => {
  try {
    const files = fs.readdirSync(logsDir);
    const now = Date.now();
    const deleteOlderThan = days * 24 * 60 * 60 * 1000;
    
    files.forEach(file => {
      if (file.startsWith('error-') && file.endsWith('.log')) {
        const filePath = path.join(logsDir, file);
        const stats = fs.statSync(filePath);
        
        if (now - stats.mtimeMs > deleteOlderThan) {
          fs.unlinkSync(filePath);
          console.log(`Deleted old log file: ${file}`);
        }
      }
    });
  } catch (error) {
    console.error('Error clearing old logs:', error);
  }
};

module.exports = {
  logApiError,
  getLogsByDate,
  getLogsByDateRange,
  getLogsByShopId,
  getLogsByStatusCode,
  getAvailableLogFiles,
  getLogStatistics,
  clearOldLogs
};
