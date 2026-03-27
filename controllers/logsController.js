/**
 * LOGS CONTROLLER
 * Handles retrieval and display of application log files
 */

const fs = require('fs');
const path = require('path');

const logsDir = path.join(__dirname, '..', 'logs');

/**
 * Get list of all log files
 */
const getLogFiles = async (req, res) => {
  try {
    if (!fs.existsSync(logsDir)) {
      return res.json({ success: true, data: [], message: 'No logs directory found' });
    }

    const files = fs.readdirSync(logsDir);
    const logFiles = files.filter(file => file.endsWith('.log') || file.endsWith('.txt'));
    
    // Get file stats for size and modification time
    const filesWithStats = logFiles.map(file => {
      const filePath = path.join(logsDir, file);
      const stats = fs.statSync(filePath);
      return {
        name: file,
        size: stats.size,
        sizeKB: (stats.size / 1024).toFixed(2),
        modifiedAt: stats.mtime,
        modifiedDate: stats.mtime.toLocaleDateString(),
        modifiedTime: stats.mtime.toLocaleTimeString()
      };
    });

    res.json({ 
      success: true, 
      data: filesWithStats.sort((a, b) => b.modifiedAt - a.modifiedAt),
      count: filesWithStats.length
    });
  } catch (error) {
    console.error('Error reading logs directory:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to read logs directory',
      error: error.message 
    });
  }
};

/**
 * Get content of a specific log file
 */
const getLogContent = async (req, res) => {
  try {
    const { filename } = req.params;
    const { limit = 100, offset = 0 } = req.query;

    // Security: prevent directory traversal
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid filename' 
      });
    }

    const filePath = path.join(logsDir, filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ 
        success: false, 
        message: 'Log file not found' 
      });
    }

    // Read file content
    let content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n').filter(line => line.trim());
    const totalLines = lines.length;

    // Parse JSON logs if applicable
    let parsedLogs = [];
    if (filename.endsWith('.log')) {
      parsedLogs = lines.map((line, index) => {
        try {
          return { ...JSON.parse(line), lineNumber: index + 1 };
        } catch (e) {
          return { raw: line, lineNumber: index + 1, error: 'Failed to parse JSON' };
        }
      });
    } else {
      parsedLogs = lines.map((line, index) => ({ raw: line, lineNumber: index + 1 }));
    }

    // Apply pagination
    const startIdx = parseInt(offset);
    const endIdx = startIdx + parseInt(limit);
    const paginatedLogs = parsedLogs.slice(startIdx, endIdx);

    res.json({
      success: true,
      data: paginatedLogs,
      pagination: {
        total: totalLines,
        limit: parseInt(limit),
        offset: startIdx,
        pages: Math.ceil(totalLines / limit)
      },
      filename: filename,
      fileSize: fs.statSync(filePath).size
    });
  } catch (error) {
    console.error('Error reading log file:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to read log file',
      error: error.message 
    });
  }
};

/**
 * Clear a log file (optional admin only feature)
 */
const clearLogFile = async (req, res) => {
  try {
    const { filename } = req.params;

    // Security: prevent directory traversal
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid filename' 
      });
    }

    const filePath = path.join(logsDir, filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ 
        success: false, 
        message: 'Log file not found' 
      });
    }

    // Clear file content
    fs.writeFileSync(filePath, '');

    res.json({
      success: true,
      message: `Log file ${filename} has been cleared`
    });
  } catch (error) {
    console.error('Error clearing log file:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to clear log file',
      error: error.message 
    });
  }
};

/**
 * Download a log file
 */
const downloadLogFile = async (req, res) => {
  try {
    const { filename } = req.params;

    // Security: prevent directory traversal
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid filename' 
      });
    }

    const filePath = path.join(logsDir, filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ 
        success: false, 
        message: 'Log file not found' 
      });
    }

    res.download(filePath, filename);
  } catch (error) {
    console.error('Error downloading log file:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to download log file',
      error: error.message 
    });
  }
};

module.exports = {
  getLogFiles,
  getLogContent,
  clearLogFile,
  downloadLogFile
};
