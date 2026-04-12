/**
 * MONITORING & SUPPORT CONTROLLER
 * Manages error logs and support tickets for super admin
 */

const { db } = require('../config/dbconnection');
const { requireShopId } = require('../helpers/shopScope');

const BASE_TICKET_COLUMNS = [
  'id',
  'shop_id',
  'ticket_number',
  'user_id',
  'assigned_to',
  'category',
  'subject',
  'description',
  'priority',
  'status',
  'error_log_id',
  'notes',
  'resolution',
  'created_by',
  'created_at',
  'updated_at',
  'resolved_at'
];

const UNRESOLVED_STATUSES = ['OPEN', 'IN_PROGRESS', 'PENDING_CUSTOMER', 'ON_HOLD'];
let supportSchemaCache = null;

const buildTicketColumnSelection = async (connection) => {
  const schema = await getSupportSchema(connection);
  const columns = BASE_TICKET_COLUMNS.map((column) => `st.${column}`);

  columns.push(
    schema.ticketColumns.has('progress_stage') ? 'st.progress_stage' : 'NULL AS progress_stage',
    schema.ticketColumns.has('stage_updated_at') ? 'st.stage_updated_at' : 'NULL AS stage_updated_at',
    schema.ticketColumns.has('closed_at') ? 'st.closed_at' : 'NULL AS closed_at',
    schema.ticketColumns.has('resolved_by') ? 'st.resolved_by' : 'NULL AS resolved_by',
    schema.ticketColumns.has('closed_by') ? 'st.closed_by' : 'NULL AS closed_by'
  );

  return columns.join(', ');
};

const getSupportSchema = async (connection) => {
  if (supportSchemaCache) {
    return supportSchemaCache;
  }

  const [rows] = await connection.query(
    `SELECT TABLE_NAME, COLUMN_NAME
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME IN ('support_tickets', 'support_ticket_comments')`
  );

  supportSchemaCache = rows.reduce(
    (accumulator, row) => {
      if (row.TABLE_NAME === 'support_tickets') {
        accumulator.ticketColumns.add(row.COLUMN_NAME);
      }
      if (row.TABLE_NAME === 'support_ticket_comments') {
        accumulator.commentColumns.add(row.COLUMN_NAME);
      }
      return accumulator;
    },
    {
      ticketColumns: new Set(),
      commentColumns: new Set()
    }
  );

  return supportSchemaCache;
};

const normalizeStatusFilter = (status) => {
  if (!status) {
    return null;
  }

  const normalized = String(status).trim().toUpperCase();
  if (!normalized) {
    return null;
  }

  if (normalized === 'NOT_RESOLVED' || normalized === 'UNRESOLVED') {
    return [...UNRESOLVED_STATUSES];
  }

  if (normalized === 'RESOLVED_OR_CLOSED') {
    return ['RESOLVED', 'CLOSED'];
  }

  return [normalized];
};

const applyStatusFilter = (queryParts, params, status) => {
  const statuses = normalizeStatusFilter(status);
  if (!statuses || statuses.length === 0) {
    return;
  }

  if (statuses.length === 1) {
    queryParts.push('st.status = ?');
    params.push(statuses[0]);
    return;
  }

  queryParts.push(`st.status IN (${statuses.map(() => '?').join(', ')})`);
  params.push(...statuses);
};

const buildSupportTicketBaseQuery = async (connection) => {
  const ticketColumns = await buildTicketColumnSelection(connection);

  return `
    SELECT ${ticketColumns},
      s.name AS shop_name,
      requester.name AS requester_name,
      COALESCE(
        CONCAT(COALESCE(assignee.first_name, ''), ' ', COALESCE(assignee.last_name, '')),
        assignee.username
      ) AS assigned_to_name
    FROM support_tickets st
    LEFT JOIN shops s ON st.shop_id = s.id
    LEFT JOIN users requester ON st.user_id = requester.id
    LEFT JOIN super_admin_users assignee ON st.assigned_to = assignee.id
  `;
};

const buildSupportCommentsQuery = (includeInternalComments) => {
  let query = `
    SELECT stc.*, COALESCE(
      u.name,
      CONCAT(COALESCE(sau.first_name, ''), ' ', COALESCE(sau.last_name, '')),
      sau.username,
      'Support'
    ) AS user_name
    FROM support_ticket_comments stc
    LEFT JOIN users u ON stc.user_id = u.id
    LEFT JOIN super_admin_users sau ON stc.user_id = sau.id
    WHERE stc.ticket_id = ?
  `;

  if (!includeInternalComments) {
    query += ' AND COALESCE(stc.is_internal, 0) = 0';
  }

  query += ' ORDER BY stc.created_at ASC';
  return query;
};

const buildSupportTicketWhereClause = ({
  shopId,
  category,
  status,
  priority,
  assignedTo,
  search,
  ticketId
}) => {
  const conditions = [];
  const params = [];

  if (ticketId) {
    conditions.push('st.id = ?');
    params.push(ticketId);
  }

  if (shopId) {
    conditions.push('st.shop_id = ?');
    params.push(shopId);
  }

  if (category) {
    conditions.push('st.category = ?');
    params.push(category);
  }

  applyStatusFilter(conditions, params, status);

  if (priority) {
    conditions.push('st.priority = ?');
    params.push(priority);
  }

  if (assignedTo) {
    conditions.push('st.assigned_to = ?');
    params.push(assignedTo);
  }

  if (search) {
    const searchTerm = `%${search}%`;
    conditions.push('(st.subject LIKE ? OR st.ticket_number LIKE ? OR st.description LIKE ?)');
    params.push(searchTerm, searchTerm, searchTerm);
  }

  return {
    clause: conditions.length > 0 ? ` WHERE ${conditions.join(' AND ')}` : '',
    params
  };
};

const fetchSupportTickets = async ({
  connection,
  filters,
  page,
  limit
}) => {
  const baseQuery = await buildSupportTicketBaseQuery(connection);
  const { clause, params } = buildSupportTicketWhereClause(filters);

  const countSql = `SELECT COUNT(*) AS total FROM support_tickets st${clause}`;
  const [countResults] = await connection.query(countSql, params);
  const total = countResults[0]?.total || 0;

  const offset = (Number(page) - 1) * Number(limit);
  const finalQuery = `${baseQuery}${clause} ORDER BY st.created_at DESC LIMIT ? OFFSET ?`;
  const [results] = await connection.query(finalQuery, [...params, Number(limit), offset]);

  return {
    results,
    total,
    page: Number(page),
    limit: Number(limit)
  };
};

const fetchSupportTicketDetail = async ({
  connection,
  ticketId,
  shopId,
  includeInternalComments
}) => {
  const baseQuery = await buildSupportTicketBaseQuery(connection);
  const { clause, params } = buildSupportTicketWhereClause({ ticketId, shopId });
  const [ticketResults] = await connection.query(`${baseQuery}${clause} LIMIT 1`, params);

  if (!ticketResults || ticketResults.length === 0) {
    return null;
  }

  const commentsQuery = buildSupportCommentsQuery(includeInternalComments);
  const [comments] = await connection.query(commentsQuery, [ticketId]);

  return {
    ticket: ticketResults[0],
    comments: comments || []
  };
};

const insertSupportTicket = async ({
  connection,
  payload,
  userId,
  createdBy,
  progressStage
}) => {
  const schema = await getSupportSchema(connection);
  const columns = [
    'shop_id',
    'user_id',
    'ticket_number',
    'category',
    'subject',
    'description',
    'priority',
    'error_log_id',
    'created_by'
  ];
  const values = [
    payload.shop_id,
    userId,
    payload.ticket_number,
    payload.category,
    payload.subject,
    payload.description,
    payload.priority || 'MEDIUM',
    payload.error_log_id || null,
    createdBy
  ];

  if (schema.ticketColumns.has('progress_stage')) {
    columns.push('progress_stage');
    values.push(progressStage || 'New');
  }

  if (schema.ticketColumns.has('stage_updated_at')) {
    columns.push('stage_updated_at');
    values.push(new Date());
  }

  const placeholders = columns.map(() => '?').join(', ');
  const query = `INSERT INTO support_tickets (${columns.join(', ')}) VALUES (${placeholders})`;
  return connection.query(query, values);
};

const updateSupportTicketRecord = async ({ connection, ticketId, updates, actorId }) => {
  const schema = await getSupportSchema(connection);
  const fields = [];
  const params = [];

  if (updates.status) {
    const normalizedStatus = String(updates.status).trim().toUpperCase();
    fields.push('status = ?');
    params.push(normalizedStatus);

    if (normalizedStatus === 'RESOLVED') {
      fields.push('resolved_at = NOW()');
      if (schema.ticketColumns.has('resolved_by')) {
        fields.push('resolved_by = ?');
        params.push(actorId || null);
      }
    }

    if (normalizedStatus === 'CLOSED') {
      fields.push('resolved_at = COALESCE(resolved_at, NOW())');
      if (schema.ticketColumns.has('closed_at')) {
        fields.push('closed_at = NOW()');
      }
      if (schema.ticketColumns.has('closed_by')) {
        fields.push('closed_by = ?');
        params.push(actorId || null);
      }
    }
  }

  if (updates.priority) {
    fields.push('priority = ?');
    params.push(updates.priority);
  }

  if (updates.assigned_to !== undefined) {
    fields.push('assigned_to = ?');
    params.push(updates.assigned_to || null);
  }

  if (updates.notes !== undefined) {
    fields.push('notes = ?');
    params.push(updates.notes || null);
  }

  if (updates.resolution !== undefined) {
    fields.push('resolution = ?');
    params.push(updates.resolution || null);
  }

  if (schema.ticketColumns.has('progress_stage') && updates.progress_stage !== undefined) {
    fields.push('progress_stage = ?');
    params.push(updates.progress_stage || null);
  }

  if (schema.ticketColumns.has('stage_updated_at') && updates.progress_stage !== undefined) {
    fields.push('stage_updated_at = NOW()');
  }

  if (fields.length === 0) {
    return { affectedRows: 0, skipped: true };
  }

  fields.push('updated_at = NOW()');
  params.push(ticketId);

  const [result] = await connection.query(
    `UPDATE support_tickets SET ${fields.join(', ')} WHERE id = ?`,
    params
  );

  return result;
};

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
    const { shop_id, category, status = 'OPEN', priority, assigned_to, page = 1, limit = 20, search } = req.query;
    const { results, total } = await fetchSupportTickets({
      connection,
      filters: {
        shopId: shop_id,
        category,
        status,
        priority,
        assignedTo: assigned_to,
        search
      },
      page,
      limit
    });

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

    const detail = await fetchSupportTicketDetail({
      connection,
      ticketId: id,
      shopId: null,
      includeInternalComments: true
    });

    if (!detail) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    res.status(200).json({
      success: true,
      ticket: detail.ticket,
      comments: detail.comments
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
      created_by,
      progress_stage
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

    const [result] = await insertSupportTicket({
      connection,
      payload: {
        shop_id,
        ticket_number: ticketNumber,
        category,
        subject,
        description,
        priority,
        error_log_id
      },
      userId: user_id || null,
      createdBy: creatorId,
      progressStage: progress_stage
    });

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
    const result = await updateSupportTicketRecord({
      connection,
      ticketId: id,
      updates: req.body,
      actorId: req.user?.id || null
    });

    if (result.skipped) {
      return res.status(400).json({
        success: false,
        error: 'No fields to update'
      });
    }

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

exports.getShopSupportTickets = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      return;
    }

    const { category, status = '', priority, page = 1, limit = 20, search } = req.query;
    const { results, total } = await fetchSupportTickets({
      connection,
      filters: {
        shopId,
        category,
        status,
        priority,
        search
      },
      page,
      limit
    });

    res.status(200).json({
      success: true,
      data: results,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching shop support tickets:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch support tickets',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

exports.getShopSupportTicketDetail = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      return;
    }

    const detail = await fetchSupportTicketDetail({
      connection,
      ticketId: req.params.id,
      shopId,
      includeInternalComments: false
    });

    if (!detail) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    res.status(200).json({
      success: true,
      ticket: detail.ticket,
      comments: detail.comments
    });
  } catch (error) {
    console.error('Error fetching shop support ticket detail:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch support ticket',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

exports.createShopSupportTicket = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      return;
    }

    const { category, subject, description, priority = 'MEDIUM', error_log_id } = req.body;
    if (!category || !subject || !description) {
      return res.status(400).json({
        success: false,
        error: 'category, subject, and description are required'
      });
    }

    const date = new Date();
    const dateStr = date.toISOString().split('T')[0].replace(/-/g, '');
    const randomNum = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    const ticketNumber = `TICKET-${shopId}-${dateStr}-${randomNum}`;

    const [result] = await insertSupportTicket({
      connection,
      payload: {
        shop_id: shopId,
        ticket_number: ticketNumber,
        category,
        subject,
        description,
        priority,
        error_log_id
      },
      userId: req.user?.id || null,
      createdBy: null,
      progressStage: 'New'
    });

    res.status(201).json({
      success: true,
      message: 'Support ticket created successfully',
      ticket_id: result.insertId,
      ticket_number: ticketNumber
    });
  } catch (error) {
    console.error('Error creating shop support ticket:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create support ticket',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

exports.addShopTicketComment = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      return;
    }

    const { ticket_id } = req.params;
    const { comment, attachment_url } = req.body;

    if (!comment) {
      return res.status(400).json({
        success: false,
        error: 'comment is required'
      });
    }

    const [ticketRows] = await connection.query(
      'SELECT id FROM support_tickets WHERE id = ? AND shop_id = ? LIMIT 1',
      [ticket_id, shopId]
    );

    if (!ticketRows || ticketRows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Ticket not found'
      });
    }

    const [result] = await connection.query(
      `INSERT INTO support_ticket_comments (ticket_id, user_id, comment, is_internal, attachment_url)
       VALUES (?, ?, ?, 0, ?)`,
      [ticket_id, req.user?.id || null, comment, attachment_url || null]
    );

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
      comment_id: result.insertId
    });
  } catch (error) {
    console.error('Error adding shop ticket comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add comment',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

exports.getShopSupportTicketStats = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      return;
    }

    const [statsRows] = await connection.query(
      `SELECT
        COUNT(*) AS total_tickets,
        SUM(CASE WHEN status IN ('OPEN', 'IN_PROGRESS', 'PENDING_CUSTOMER', 'ON_HOLD') THEN 1 ELSE 0 END) AS unresolved_tickets,
        SUM(CASE WHEN status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_tickets,
        SUM(CASE WHEN status = 'CLOSED' THEN 1 ELSE 0 END) AS closed_tickets
       FROM support_tickets
       WHERE shop_id = ?`,
      [shopId]
    );

    res.status(200).json({
      success: true,
      data: statsRows[0] || {}
    });
  } catch (error) {
    console.error('Error fetching shop support ticket stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch support ticket stats',
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

