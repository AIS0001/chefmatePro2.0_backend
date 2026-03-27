/**
 * MONITORING & SUPPORT CONTROLLER
 * Manages error logs and support tickets for super admin
 */

const { db } = require('../config/dbconnection');

// =====================================================
// ERROR LOGS CONTROLLER
// =====================================================

/**
 * Get all error logs with filters and pagination
 * Query params: shop_id, error_type, severity, status, page, limit, search
 */
exports.getErrorLogs = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();

    const {
      shop_id,
      error_type,
      severity,
      status = 'OPEN',
      page = 1,
      limit = 20,
      search
    } = req.query;

    let query = 'SELECT * FROM error_logs WHERE 1=1';
    const params = [];

    if (shop_id) {
      query += ' AND shop_id = ?';
      params.push(shop_id);
    }

    if (error_type) {
      query += ' AND error_type = ?';
      params.push(error_type);
    }

    if (severity) {
      query += ' AND severity = ?';
      params.push(severity);
    }

    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    if (search) {
      query += ' AND (error_message LIKE ? OR module LIKE ? OR route LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    // Get total count
    const countQuery = query.replace(/SELECT \*/, 'SELECT COUNT(*) as total');
    const [countResults] = await connection.query(countQuery, params);
    const total = countResults[0].total;

    // Get paginated results
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const finalQuery = query + ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    const finalParams = [...params, parseInt(limit), offset];

    const [results] = await connection.query(finalQuery, finalParams);

    res.status(200).json({
      success: true,
      data: results,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Error fetching error logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch error logs',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get single error log details
 */
exports.getErrorLogDetail = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { id } = req.params;

    const query = 'SELECT * FROM error_logs WHERE id = ?';
    const [results] = await connection.query(query, [id]);

    if (!results || results.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Error log not found'
      });
    }

    res.status(200).json({
      success: true,
      data: results[0]
    });

  } catch (error) {
    console.error('Error fetching error log detail:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch error log',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Update error log status and notes
 */
exports.updateErrorLogStatus = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { id } = req.params;
    const { status, notes } = req.body;

    const updateFields = [];
    const updateParams = [];

    if (status) {
      updateFields.push('status = ?');
      updateParams.push(status);
      
      if (status === 'RESOLVED') {
        updateFields.push('resolved_at = NOW()');
      }
    }

    if (notes) {
      updateFields.push('notes = ?');
      updateParams.push(notes);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No fields to update'
      });
    }

    updateParams.push(id);
    const query = `UPDATE error_logs SET ${updateFields.join(', ')} WHERE id = ?`;

    const [result] = await connection.query(query, updateParams);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'Error log not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Error log updated successfully'
    });

  } catch (error) {
    console.error('Error updating error log:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update error log',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Log an error (called from application)
 */
exports.logError = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
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
    } = req.body;

    if (!shop_id || !error_type || !error_message) {
      return res.status(400).json({
        success: false,
        error: 'shop_id, error_type, and error_message are required'
      });
    }

    const query = `
      INSERT INTO error_logs (
        shop_id, user_id, error_type, error_code, error_message, 
        error_stack, module, route, method, query_params, request_body,
        ip_address, user_agent, severity
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const params = [
      shop_id, user_id, error_type, error_code, error_message,
      error_stack, module, route, method, 
      query_params ? JSON.stringify(query_params) : null,
      request_body ? JSON.stringify(request_body) : null,
      ip_address, user_agent, severity
    ];

    const [result] = await connection.query(query, params);

    res.status(201).json({
      success: true,
      message: 'Error logged successfully',
      error_log_id: result.insertId
    });

  } catch (error) {
    console.error('Error logging error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to log error',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// =====================================================
// SUPPORT TICKETS CONTROLLER
// =====================================================

/**
 * Get support tickets with filters and pagination
 */
exports.getSupportTickets = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();

    const {
      shop_id,
      category,
      status = 'OPEN',
      priority,
      assigned_to,
      page = 1,
      limit = 20,
      search
    } = req.query;

    let query = `
      SELECT st.*, s.name as shop_name, u1.name as created_by_name, CONCAT(COALESCE(u2.first_name, ''), ' ', COALESCE(u2.last_name, '')) as assigned_to_name
      FROM support_tickets st
      LEFT JOIN shops s ON st.shop_id = s.id
      LEFT JOIN users u1 ON st.user_id = u1.id
      LEFT JOIN super_admin_users u2 ON st.assigned_to = u2.id
      WHERE 1=1
    `;
    const params = [];

    if (shop_id) {
      query += ' AND st.shop_id = ?';
      params.push(shop_id);
    }

    if (category) {
      query += ' AND st.category = ?';
      params.push(category);
    }

    if (status) {
      query += ' AND st.status = ?';
      params.push(status);
    }

    if (priority) {
      query += ' AND st.priority = ?';
      params.push(priority);
    }

    if (assigned_to) {
      query += ' AND st.assigned_to = ?';
      params.push(assigned_to);
    }

    if (search) {
      query += ' AND (st.subject LIKE ? OR st.ticket_number LIKE ? OR st.description LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    // Get total count
    const countQuery = query.replace(
      /SELECT st\.\*, s\.name.*FROM support_tickets/,
      'SELECT COUNT(*) as total FROM support_tickets'
    ).split('LEFT JOIN')[0] + ' WHERE 1=1';

    let countParams = [];
    if (shop_id) {
      countParams.push(shop_id);
    }
    if (category) {
      countParams.push(category);
    }
    if (status) {
      countParams.push(status);
    }
    if (priority) {
      countParams.push(priority);
    }
    if (assigned_to) {
      countParams.push(assigned_to);
    }
    if (search) {
      countParams.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    let countSql = 'SELECT COUNT(*) as total FROM support_tickets WHERE 1=1';
    if (shop_id) countSql += ' AND shop_id = ?';
    if (category) countSql += ' AND category = ?';
    if (status) countSql += ' AND status = ?';
    if (priority) countSql += ' AND priority = ?';
    if (assigned_to) countSql += ' AND assigned_to = ?';
    if (search) countSql += ' AND (subject LIKE ? OR ticket_number LIKE ? OR description LIKE ?)';

    const [countResults] = await connection.query(countSql, params);
    const total = countResults[0].total;

    // Get paginated results
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const finalQuery = query + ' ORDER BY st.created_at DESC LIMIT ? OFFSET ?';
    const finalParams = [...params, parseInt(limit), offset];

    const [results] = await connection.query(finalQuery, finalParams);

    res.status(200).json({
      success: true,
      data: results,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Error fetching support tickets:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch support tickets',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get single ticket with comments
 */
exports.getSupportTicketDetail = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { id } = req.params;

    // Get ticket details
    const ticketQuery = `
      SELECT st.*, s.name as shop_name, u1.name as created_by_name, CONCAT(COALESCE(u2.first_name, ''), ' ', COALESCE(u2.last_name, '')) as assigned_to_name
      FROM support_tickets st
      LEFT JOIN shops s ON st.shop_id = s.id
      LEFT JOIN users u1 ON st.user_id = u1.id
      LEFT JOIN super_admin_users u2 ON st.assigned_to = u2.id
      WHERE st.id = ?
    `;

    const [ticketResults] = await connection.query(ticketQuery, [id]);

    if (!ticketResults || ticketResults.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    // Get comments
    const commentsQuery = `
      SELECT stc.*, COALESCE(u.name, CONCAT(COALESCE(sau.first_name, ''), ' ', COALESCE(sau.last_name, '')), sau.username, 'Admin') as user_name
      FROM support_ticket_comments stc
      LEFT JOIN users u ON stc.user_id = u.id
      LEFT JOIN super_admin_users sau ON stc.user_id = sau.id
      WHERE stc.ticket_id = ?
      ORDER BY stc.created_at ASC
    `;

    const [comments] = await connection.query(commentsQuery, [id]);

    res.status(200).json({
      success: true,
      ticket: ticketResults[0],
      comments: comments || []
    });

  } catch (error) {
    console.error('Error fetching ticket detail:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch ticket',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Create support ticket
 */
exports.createSupportTicket = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const {
      shop_id,
      user_id,
      category,
      subject,
      description,
      priority = 'MEDIUM',
      error_log_id,
      created_by
    } = req.body;
    const creatorId = created_by || req.user?.id || null;

    if (!shop_id || !category || !subject || !description) {
      return res.status(400).json({
        success: false,
        error: 'shop_id, category, subject, and description are required'
      });
    }

    // Generate ticket number
    const date = new Date();
    const dateStr = date.toISOString().split('T')[0].replace(/-/g, '');
    const randomNum = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    const ticketNumber = `TICKET-${shop_id}-${dateStr}-${randomNum}`;

    const query = `
      INSERT INTO support_tickets (
        shop_id, user_id, ticket_number, category, subject, description,
        priority, error_log_id, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const params = [
      shop_id, user_id, ticketNumber, category, subject, description,
      priority, error_log_id, creatorId
    ];

    const [result] = await connection.query(query, params);

    res.status(201).json({
      success: true,
      message: 'Support ticket created successfully',
      ticket_id: result.insertId,
      ticket_number: ticketNumber
    });

  } catch (error) {
    console.error('Error creating support ticket:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create ticket',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Update support ticket
 */
exports.updateSupportTicket = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { id } = req.params;
    const { status, priority, assigned_to, notes, resolution } = req.body;

    let query = 'UPDATE support_tickets SET ';
    const params = [];
    const updateFields = [];

    if (status) {
      updateFields.push('status = ?');
      params.push(status);
      if (status === 'RESOLVED' || status === 'CLOSED') {
        updateFields.push('resolved_at = NOW()');
      }
    }

    if (priority) {
      updateFields.push('priority = ?');
      params.push(priority);
    }

    if (assigned_to !== undefined) {
      updateFields.push('assigned_to = ?');
      params.push(assigned_to);
    }

    if (notes) {
      updateFields.push('notes = ?');
      params.push(notes);
    }

    if (resolution) {
      updateFields.push('resolution = ?');
      params.push(resolution);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No fields to update'
      });
    }

    updateFields.push('updated_at = NOW()');
    params.push(id);
    query += updateFields.join(', ') + ' WHERE id = ?';

    const [result] = await connection.query(query, params);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Ticket updated successfully'
    });

  } catch (error) {
    console.error('Error updating ticket:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update ticket',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Add comment to support ticket
 */
exports.addTicketComment = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { ticket_id } = req.params;
    const { user_id, comment, is_internal = 0, attachment_url } = req.body;
    const commenterId = user_id || req.user?.id || null;

    if (!commenterId || !comment) {
      return res.status(400).json({
        success: false,
        error: 'user_id and comment are required'
      });
    }

    // Verify ticket exists
    const ticketCheck = 'SELECT id FROM support_tickets WHERE id = ?';
    const [ticketExists] = await connection.query(ticketCheck, [ticket_id]);

    if (!ticketExists || ticketExists.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    const query = `
      INSERT INTO support_ticket_comments (ticket_id, user_id, comment, is_internal, attachment_url)
      VALUES (?, ?, ?, ?, ?)
    `;

    const [result] = await connection.query(query, [
      ticket_id, commenterId, comment, is_internal, attachment_url
    ]);

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
      comment_id: result.insertId
    });

  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add comment',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get dashboard statistics
 */
exports.getMonitoringStats = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { shop_id } = req.query;

    let whereClause = '';
    let params = [];

    if (shop_id) {
      whereClause = ' WHERE shop_id = ?';
      params.push(shop_id);
    }

    // Error logs stats
    const errorStatsQuery = `
      SELECT 
        COUNT(*) as total_errors,
        SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) as open_errors,
        SUM(CASE WHEN severity = 'CRITICAL' THEN 1 ELSE 0 END) as critical_errors,
        SUM(CASE WHEN severity = 'HIGH' THEN 1 ELSE 0 END) as high_errors
      FROM error_logs${whereClause}
    `;

    // Support tickets stats
    const ticketStatsQuery = `
      SELECT 
        COUNT(*) as total_tickets,
        SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) as open_tickets,
        SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) as in_progress_tickets,
        SUM(CASE WHEN priority = 'URGENT' THEN 1 ELSE 0 END) as urgent_tickets
      FROM support_tickets${whereClause}
    `;

    const [errorStats] = await connection.query(errorStatsQuery, params);
    const [ticketStats] = await connection.query(ticketStatsQuery, params);

    res.status(200).json({
      success: true,
      data: {
        errors: errorStats[0] || {},
        tickets: ticketStats[0] || {}
      }
    });

  } catch (error) {
    console.error('Error getting stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get statistics',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// =====================================================
// FILE-BASED ERROR LOGS CONTROLLER
// =====================================================

/**
 * Get error logs from text files (JSON formatted)
 * Reads from /logs/ directory with flat structure
 */
exports.getFileErrorLogs = async (req, res) => {
  try {
    const fileLogger = require('../services/fileLoggerService');
    const { date_from, date_to, page = 1, limit = 20 } = req.query;

    // Get date range (default to last 30 days if not specified)
    let startDate = new Date();
    let endDate = new Date();
    
    if (date_from) {
      startDate = new Date(date_from);
    } else {
      startDate = new Date(new Date().setDate(new Date().getDate() - 30));
    }

    if (date_to) {
      endDate = new Date(date_to);
    }

    // Get log files for date range
    const logFileObjects = fileLogger.getErrorLogFiles(null, startDate, endDate);
    
    if (!logFileObjects || logFileObjects.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        pagination: { total: 0, page: 1, limit: 20, pages: 0 }
      });
    }

    // Parse all logs from files
    let allLogs = [];
    logFileObjects.forEach(fileObj => {
      const logs = fileLogger.parseJsonLogs(fileObj.path);
      allLogs = allLogs.concat(logs);
    });

    // Sort by timestamp (newest first)
    allLogs.sort((a, b) => {
      const timeA = new Date(a.timestamp || 0);
      const timeB = new Date(b.timestamp || 0);
      return timeB - timeA;
    });

    // Apply pagination
    const total = allLogs.length;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const paginatedLogs = allLogs.slice(offset, offset + parseInt(limit));

    res.status(200).json({
      success: true,
      data: paginatedLogs,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Error reading file logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to read error log files',
      details: error.message
    });
  }
};

/**
 * Get log statistics from files
 */
exports.getFileLogStatistics = async (req, res) => {
  try {
    const fileLogger = require('../services/fileLoggerService');
    const stats = fileLogger.getLogStatistics();

    res.status(200).json({
      success: true,
      data: stats
    });

  } catch (error) {
    console.error('Error getting file statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get file statistics',
      details: error.message
    });
  }
};

/**
 * Search error logs in files
 */
exports.searchFileErrorLogs = async (req, res) => {
  try {
    const fileLogger = require('../services/fileLoggerService');
    const { search_term, date_from, date_to } = req.query;

    if (!search_term) {
      return res.status(400).json({
        success: false,
        error: 'search_term is required'
      });
    }

    const startDate = date_from ? new Date(date_from) : new Date(new Date().setDate(new Date().getDate() - 30));
    const endDate = date_to ? new Date(date_to) : new Date();

    // Get log files
    const logFileObjects = fileLogger.getErrorLogFiles(null, startDate, endDate);

    if (!logFileObjects || logFileObjects.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        totalResults: 0
      });
    }

    // Search through all logs in files
    let results = [];
    logFileObjects.forEach(fileObj => {
      const logs = fileLogger.parseJsonLogs(fileObj.path);
      const matches = logs.filter(log => {
        const searchLower = search_term.toLowerCase();
        return (
          (log.error && log.error.toLowerCase().includes(searchLower)) ||
          (log.endpoint && log.endpoint.toLowerCase().includes(searchLower)) ||
          (log.statusCode && log.statusCode.toString().includes(search_term)) ||
          (log.method && log.method.toLowerCase().includes(searchLower))
        );
      });
      
      results = results.concat(matches);
    });

    // Sort by timestamp (newest first)
    results.sort((a, b) => {
      const timeA = new Date(a.timestamp || 0);
      const timeB = new Date(b.timestamp || 0);
      return timeB - timeA;
    });

    res.status(200).json({
      success: true,
      data: results,
      totalResults: results.length
    });

  } catch (error) {
    console.error('Error searching logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to search logs',
      details: error.message
    });
  }
};

/**
 * Clear error logs from database and file system
 */
exports.clearAllErrorLogs = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const fileLogger = require('../services/fileLoggerService');

    const [deleteResult] = await connection.query('DELETE FROM error_logs');
    const fileClearResult = fileLogger.clearAllLogs();

    if (!fileClearResult.success) {
      return res.status(500).json({
        success: false,
        error: 'Database logs cleared, but failed to clear file logs',
        details: fileClearResult.error,
        databaseDeletedCount: deleteResult.affectedRows || 0,
        fileDeletedCount: fileClearResult.deletedFiles || 0
      });
    }

    res.status(200).json({
      success: true,
      message: 'All logs cleared successfully',
      databaseDeletedCount: deleteResult.affectedRows || 0,
      fileDeletedCount: fileClearResult.deletedFiles || 0
    });
  } catch (error) {
    console.error('Error clearing all logs:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to clear logs',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

