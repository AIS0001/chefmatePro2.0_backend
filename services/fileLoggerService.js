/**
 * FILE LOGGER UTILITY
 * Writes error logs to text files organized by date and shop
 * Files are created in: /logs/year/month/day/shop_id/
 */

const fs = require('fs');
const path = require('path');

// Main logs directory
const LOGS_DIR = path.join(__dirname, '../../logs');

/**
 * Ensure directory exists, create if not
 */
function ensureDirectoryExists(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

/**
 * Get the log file path based on date and shop_id
 * Path: /logs/YYYY/MM/DD/shop_id/errors.log
 */
function getLogFilePath(shop_id, date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  
  const logDir = path.join(LOGS_DIR, year.toString(), month, day, shop_id.toString());
  ensureDirectoryExists(logDir);
  
  return path.join(logDir, 'errors.log');
}

/**
 * Write error log to file
 */
function logErrorToFile(errorData) {
  try {
    const {
      shop_id,
      user_id,
      error_type,
      error_code,
      error_message,
      error_stack,
      module,
      route,
      method,
      query_params,
      request_body,
      ip_address,
      user_agent,
      severity = 'MEDIUM'
    } = errorData;

    if (!shop_id) {
      console.error('⚠️ Error log requires shop_id');
      return false;
    }

    // Format timestamp
    const timestamp = new Date().toISOString();
    
    // Get log file path
    const logFile = getLogFilePath(shop_id);
    
    // Build log entry
    const logEntry = `
═══════════════════════════════════════════════════════════════
[${timestamp}] ERROR LOG - SHOP ID: ${shop_id}
═══════════════════════════════════════════════════════════════
Severity: ${severity}
Error Type: ${error_type}
Error Code: ${error_code || 'N/A'}
Module: ${module || 'N/A'}
Route: ${method || 'N/A'} ${route || 'N/A'}
User ID: ${user_id || 'N/A'}
IP Address: ${ip_address || 'N/A'}

MESSAGE:
${error_message}

${error_stack ? 'STACK TRACE:\n' + error_stack : ''}

${query_params ? 'QUERY PARAMS:\n' + JSON.stringify(query_params, null, 2) : ''}

${request_body ? 'REQUEST BODY:\n' + JSON.stringify(request_body, null, 2) : ''}

User Agent: ${user_agent || 'N/A'}
───────────────────────────────────────────────────────────────\n`;

    // Append to log file
    fs.appendFileSync(logFile, logEntry, 'utf8');
    
    console.log(`✓ Error logged to: ${logFile}`);
    return true;

  } catch (error) {
    console.error('❌ Failed to write error log:', error.message);
    return false;
  }
}

/**
 * Read all error logs for a shop on a specific date
 * Returns formatted string with all errors
 */
function readErrorLogs(shop_id, date = new Date()) {
  try {
    const logFile = getLogFilePath(shop_id, date);
    
    if (!fs.existsSync(logFile)) {
      return `No error logs found for shop ${shop_id} on ${date.toDateString()}`;
    }
    
    const content = fs.readFileSync(logFile, 'utf8');
    return content;
    
  } catch (error) {
    console.error('❌ Failed to read error logs:', error.message);
    return `Error reading logs: ${error.message}`;
  }
}

/**
 * Get all error log files for a shop between date range
 * Returns array of file paths
 */
function getErrorLogFiles(shop_id, startDate, endDate) {
  try {
    const files = [];
    const current = new Date(startDate);
    
    while (current <= endDate) {
      const logFile = getLogFilePath(shop_id, current);
      
      if (fs.existsSync(logFile)) {
        files.push({
          path: logFile,
          date: new Date(current),
          size: fs.statSync(logFile).size
        });
      }
      
      // Move to next day
      current.setDate(current.getDate() + 1);
    }
    
    return files;
    
  } catch (error) {
    console.error('❌ Failed to get log files:', error.message);
    return [];
  }
}

/**
 * Get all logs for a specific date across all shops
 * Returns object with shop_id as key
 */
function getErrorLogsByDate(date = new Date()) {
  try {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    const dateDir = path.join(LOGS_DIR, year.toString(), month, day);
    
    if (!fs.existsSync(dateDir)) {
      return {};
    }
    
    const shops = fs.readdirSync(dateDir);
    const result = {};
    
    shops.forEach(shopId => {
      const logFile = path.join(dateDir, shopId, 'errors.log');
      if (fs.existsSync(logFile)) {
        result[shopId] = {
          content: fs.readFileSync(logFile, 'utf8'),
          size: fs.statSync(logFile).size,
          path: logFile
        };
      }
    });
    
    return result;
    
  } catch (error) {
    console.error('❌ Failed to get logs by date:', error.message);
    return {};
  }
}

/**
 * Search logs for specific error type or message
 */
function searchErrorLogs(shop_id, searchTerm, startDate, endDate) {
  try {
    const logFiles = getErrorLogFiles(shop_id, startDate, endDate);
    const results = [];
    
    logFiles.forEach(file => {
      const content = fs.readFileSync(file.path, 'utf8');
      
      if (content.toLowerCase().includes(searchTerm.toLowerCase())) {
        results.push({
          date: file.date,
          path: file.path,
          matches: content
        });
      }
    });
    
    return results;
    
  } catch (error) {
    console.error('❌ Failed to search logs:', error.message);
    return [];
  }
}

/**
 * Delete old log files (older than specified days)
 */
function cleanupOldLogs(daysToKeep = 30) {
  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
    
    let deletedCount = 0;
    
    function removeOldFiles(dir) {
      if (!fs.existsSync(dir)) return;
      
      fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          removeOldFiles(fullPath);
          // Remove empty directory
          try {
            fs.rmdirSync(fullPath);
          } catch (e) {}
        } else if (stat.mtime < cutoffDate) {
          fs.unlinkSync(fullPath);
          deletedCount++;
        }
      });
    }
    
    removeOldFiles(LOGS_DIR);
    console.log(`✓ Cleanup complete: ${deletedCount} old log files removed`);
    
    return deletedCount;
    
  } catch (error) {
    console.error('❌ Failed to cleanup logs:', error.message);
    return 0;
  }
}

/**
 * Remove all file-based logs under LOGS_DIR
 */
function clearAllLogs() {
  try {
    let deletedFiles = 0;

    function countFiles(dir) {
      if (!fs.existsSync(dir)) return;
      fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
          countFiles(fullPath);
        } else {
          deletedFiles++;
        }
      });
    }

    if (fs.existsSync(LOGS_DIR)) {
      countFiles(LOGS_DIR);
      fs.rmSync(LOGS_DIR, { recursive: true, force: true });
    }

    // Recreate base logs directory for future writes.
    ensureDirectoryExists(LOGS_DIR);

    return { success: true, deletedFiles };
  } catch (error) {
    console.error('❌ Failed to clear all logs:', error.message);
    return { success: false, error: error.message, deletedFiles: 0 };
  }
}

/**
 * Get log directory statistics
 */
function getLogStatistics() {
  try {
    if (!fs.existsSync(LOGS_DIR)) {
      return { totalSize: 0, fileCount: 0, shops: {} };
    }
    
    let totalSize = 0;
    let fileCount = 0;
    const shops = {};
    
    function walkDir(dir) {
      fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          walkDir(fullPath);
        } else {
          totalSize += stat.size;
          fileCount++;
          
          // Extract shop_id from path if possible
          const pathParts = fullPath.split(path.sep);
          const shopIndex = pathParts.findIndex(p => !isNaN(p) && p.length <= 4);
          if (shopIndex > 0) {
            const shopId = pathParts[shopIndex];
            if (!shops[shopId]) {
              shops[shopId] = { files: 0, size: 0 };
            }
            shops[shopId].files++;
            shops[shopId].size += stat.size;
          }
        }
      });
    }
    
    walkDir(LOGS_DIR);
    
    return {
      totalSize: (totalSize / 1024 / 1024).toFixed(2) + ' MB',
      fileCount,
      shops
    };
    
  } catch (error) {
    console.error('❌ Failed to get statistics:', error.message);
    return { error: error.message };
  }
}

module.exports = {
  logErrorToFile,
  readErrorLogs,
  getErrorLogFiles,
  getErrorLogsByDate,
  searchErrorLogs,
  cleanupOldLogs,
  clearAllLogs,
  getLogStatistics,
  ensureDirectoryExists,
  LOGS_DIR
};
