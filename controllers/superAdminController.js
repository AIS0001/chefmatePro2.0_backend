/**
 * SUPER ADMIN CONTROLLER - COMPLETE IMPLEMENTATION
 * Manages all shops across the SaaS platform with full features
 */

const { db } = require('../config/dbconnection');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const os = require('os');
const { normalizeBillPrefix } = require('../helpers/shopBillPrefix');

let lastProcessCpuSample = {
  usage: process.cpuUsage(),
  time: process.hrtime.bigint()
};

let lastSystemCpuSample = {
  snapshot: os.cpus().map((cpu) => {
    const total = Object.values(cpu.times).reduce((sum, value) => sum + value, 0);
    return {
      idle: cpu.times.idle,
      total
    };
  })
};

function getProcessCpuUsagePercent() {
  const currentUsage = process.cpuUsage();
  const currentTime = process.hrtime.bigint();
  const elapsedMicros = Number(currentTime - lastProcessCpuSample.time) / 1000;
  const usageDelta = process.cpuUsage(lastProcessCpuSample.usage);

  lastProcessCpuSample = {
    usage: currentUsage,
    time: currentTime
  };

  if (elapsedMicros <= 0) {
    return 0;
  }

  const cpuMicros = usageDelta.user + usageDelta.system;
  const cpuPercent = (cpuMicros / elapsedMicros) * 100;
  return Number(Math.min(100, Math.max(0, cpuPercent)).toFixed(2));
}

function getSystemCpuUsagePercent() {
  const currentSnapshot = os.cpus().map((cpu) => {
    const total = Object.values(cpu.times).reduce((sum, value) => sum + value, 0);
    return {
      idle: cpu.times.idle,
      total
    };
  });

  const previousSnapshot = lastSystemCpuSample.snapshot;
  lastSystemCpuSample = { snapshot: currentSnapshot };

  if (!Array.isArray(previousSnapshot) || previousSnapshot.length !== currentSnapshot.length) {
    return 0;
  }

  let idleDelta = 0;
  let totalDelta = 0;

  for (let index = 0; index < currentSnapshot.length; index += 1) {
    idleDelta += currentSnapshot[index].idle - previousSnapshot[index].idle;
    totalDelta += currentSnapshot[index].total - previousSnapshot[index].total;
  }

  if (totalDelta <= 0) {
    return 0;
  }

  const usagePercent = (1 - (idleDelta / totalDelta)) * 100;
  return Number(Math.min(100, Math.max(0, usagePercent)).toFixed(2));
}

function getPrimaryServerIp() {
  const interfaces = os.networkInterfaces();

  for (const addresses of Object.values(interfaces)) {
    if (!Array.isArray(addresses)) {
      continue;
    }

    const externalIpv4 = addresses.find((address) => address && address.family === 'IPv4' && !address.internal);
    if (externalIpv4?.address) {
      return externalIpv4.address;
    }
  }

  return '127.0.0.1';
}

function getRuntimeEnvironmentName() {
  return process.env.APP_ENV || process.env.NODE_ENV || 'development';
}

// =====================================================
// AUTHENTICATION
// =====================================================

/**
 * Super Admin Login
 */
exports.login = async (req, res) => {
  let connection;
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Get connection from pool
    connection = await db.getConnection();

    // Find super admin user
    const query = 'SELECT * FROM super_admin_users WHERE username = ? OR email = ?';
    const [results] = await connection.query(query, [username, username]);

    if (!results || results.length === 0) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    const user = results[0];

    // Check if user is active
    if (!user.is_active) {
      return res.status(401).json({ error: 'Account is inactive' });
    }

    // Check if account is locked
    if (user.account_locked_until && new Date(user.account_locked_until) > new Date()) {
      return res.status(401).json({ error: 'Account is temporarily locked. Please try again later' });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      // Increment login attempts
      const loginAttempts = (user.login_attempts || 0) + 1;
      const shouldLock = loginAttempts >= 5;
      const lockUntil = shouldLock ? new Date(Date.now() + 15 * 60 * 1000) : null; // Lock for 15 minutes

      const updateQuery = `
        UPDATE super_admin_users 
        SET login_attempts = ?, account_locked_until = ?
        WHERE id = ?
      `;

      await connection.query(updateQuery, [loginAttempts, lockUntil, user.id]);

      if (shouldLock) {
        return res.status(401).json({ error: 'Account locked due to multiple failed login attempts' });
      }
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    // Reset login attempts on successful login
    const resetQuery = `
      UPDATE super_admin_users 
      SET login_attempts = 0, account_locked_until = NULL, last_login = NOW()
      WHERE id = ?
    `;

    await connection.query(resetQuery, [user.id]);

    // Generate JWT token
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        is_super_admin: true
      },
      process.env.JWT_SECRET || 'your_jwt_secret_key',
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role,
        phone_number: user.phone_number,
        is_super_admin: true
      },
      skip_mac_verification: true,
      bypass_device_auth: true
    });
  } catch (error) {
    console.error('Super Admin Login Error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Change Super Admin Password
 */
exports.changePassword = async (req, res) => {
  let connection;
  try {
    const { old_password, new_password, confirm_password } = req.body;
    const user_id = req.user?.id;

    if (!user_id) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    if (!old_password || !new_password || !confirm_password) {
      return res.status(400).json({ error: 'All password fields are required' });
    }

    if (new_password !== confirm_password) {
      return res.status(400).json({ error: 'New passwords do not match' });
    }

    if (new_password.length < 8) {
      return res.status(400).json({ error: 'New password must be at least 8 characters long' });
    }

    connection = await db.getConnection();

    // Get user's current password hash
    const query = 'SELECT password_hash FROM super_admin_users WHERE id = ?';
    const [results] = await connection.query(query, [user_id]);

    if (!results || results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = results[0];

    // Verify old password
    const isPasswordValid = await bcrypt.compare(old_password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(new_password, 10);

    // Update password
    const updateQuery = 'UPDATE super_admin_users SET password_hash = ?, updated_at = NOW() WHERE id = ?';
    await connection.query(updateQuery, [hashedPassword, user_id]);

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    console.error('Change Password Error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get Current Super Admin Profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user_id = req.user?.id;

    if (!user_id) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const query = `
      SELECT id, username, email, first_name, last_name, phone_number, role, is_active, last_login, created_at, updated_at
      FROM super_admin_users 
      WHERE id = ?
    `;

    const [results] = await db.query(query, [user_id]);

    if (!results || results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, data: results[0] });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// SHOP MANAGEMENT
// =====================================================

/**
 * Get all shops (with pagination and filters)
 */
exports.getAllShops = async (req, res) => {
  try {
    const page = req.query.page || 1;
    const limit = req.query.limit || 10;
    const offset = (page - 1) * limit;
    const status = req.query.status; // Filter by status
    const search = req.query.search; // Search by name or code

    let query = 'SELECT * FROM shops WHERE 1=1';
    let countQuery = 'SELECT COUNT(*) as total FROM shops WHERE 1=1';
    const params = [];

    if (status) {
      query += ' AND subscription_status = ?';
      countQuery += ' AND subscription_status = ?';
      params.push(status);
    }

    if (search) {
      query += ' AND (name LIKE ? OR shop_code LIKE ?)';
      countQuery += ' AND (name LIKE ? OR shop_code LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    const countParams = [...params];

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0]?.total || 0;

    const [results] = await db.query(query, [...params, Number(limit), Number(offset)]);

    res.json({
      success: true,
      data: results,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get single shop details
 */
exports.getShopDetails = async (req, res) => {
  try {
    const { shop_id } = req.params;

    const query = `
      SELECT 
        s.*,
        sp.name as plan_name,
        sp.price_per_month,
        COUNT(DISTINCT sa.id) as total_admins,
        COUNT(DISTINCT u.id) as total_users
      FROM shops s
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      LEFT JOIN shop_admins sa ON s.id = sa.shop_id
      LEFT JOIN users u ON s.id = u.shop_id
      WHERE s.id = ?
      GROUP BY s.id
    `;

    const [results] = await db.query(query, [shop_id]);

    if (!results || results.length === 0) {
      return res.status(404).json({ error: 'Shop not found' });
    }

    res.json({ success: true, data: results[0] });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Create new shop
 */
exports.createShop = async (req, res) => {
  try {
    const connection = await db.getConnection();
    const {
      name,
      shop_code,
      bill_prefix,
      tax_id,
      phone_number,
      email,
      address,
      city,
      state,
      zip_code,
      country,
      website,
      contact_person,
      contact_person_phone,
      subscription_plan_id
    } = req.body;

    // Validation
    if (!name || !shop_code || !tax_id || !phone_number || !email || !address) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const normalizedBillPrefix = normalizeBillPrefix(bill_prefix, name);

    if (!normalizedBillPrefix || normalizedBillPrefix.length < 2) {
      return res.status(400).json({ error: 'Bill prefix must contain at least 2 letters or numbers' });
    }

    // Resolve plan limits from subscription_plans instead of trusting client payload.
    const planId = Number(subscription_plan_id) || 1;
    const [planRows] = await connection.query(
      'SELECT id, max_terminals, max_users, storage_quota_gb FROM subscription_plans WHERE id = ? AND is_active = 1 LIMIT 1',
      [planId]
    );

    if (!planRows || planRows.length === 0) {
      return res.status(400).json({ error: 'Invalid subscription plan selected' });
    }

    const query = `
      INSERT INTO shops 
      (name, shop_code, bill_prefix, tax_id, phone_number, email, address, city, state, 
       zip_code, country, website, contact_person, contact_person_phone,
       subscription_plan_id,
       subscription_status, subscription_start_date, subscription_end_date, created_by, is_active)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), ?, 1)
    `;

    const params = [
      name,
      shop_code,
      normalizedBillPrefix,
      tax_id,
      phone_number,
      email,
      address,
      city || null,
      state || null,
      zip_code || null,
      country || null,
      website || null,
      contact_person || null,
      contact_person_phone || null,
      planRows[0].id,
      'trial',
      req.user.id,
    ];

    let result;
    try {
      const [insertResult] = await connection.query(query, params);
      result = insertResult;
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Shop code, bill prefix, or Tax ID already exists' });
      }
      throw err;
    } finally {
      connection.release();
    }

    // Create initial company info record for the shop
    try {
      await db.query(
        `INSERT INTO company_profile (shop_id, name, tax_id, phone_number, email, address) VALUES (?, ?, ?, ?, ?, ?)`,
        [result.insertId, name, tax_id || '', phone_number, email, address]
      );
    } catch (companyErr) {
      console.error('Failed to create companyinfo record:', companyErr);
    }

    res.json({
      success: true,
      message: 'Shop created successfully',
      shop_id: result.insertId,
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update shop details
 */
exports.updateShop = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const updates = req.body;

    let query = 'UPDATE shops SET ';
    const params = [];

    const allowedFields = [
      'name', 'bill_prefix', 'phone_number', 'email', 'address', 'city', 'state',
      'zip_code', 'country', 'website', 'contact_person', 'contact_person_phone',
      'subscription_status', 'no_of_terminals', 'max_users', 'storage_quota_gb',
    ];

    const updateFields = [];
    for (const field of allowedFields) {
      if (field in updates) {
        if (field === 'bill_prefix') {
          const normalizedBillPrefix = normalizeBillPrefix(updates[field], updates.name || '');

          if (!normalizedBillPrefix || normalizedBillPrefix.length < 2) {
            return res.status(400).json({ error: 'Bill prefix must contain at least 2 letters or numbers' });
          }

          updateFields.push(`${field} = ?`);
          params.push(normalizedBillPrefix);
          continue;
        }

        updateFields.push(`${field} = ?`);
        params.push(updates[field]);
      }
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    query += updateFields.join(', ') + ', updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?';
    params.push(req.user.id, shop_id);

    try {
      await db.query(query, params);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(400).json({ error: 'Bill prefix must be unique for each shop' });
      }
      throw err;
    }

    // Sync companyinfo with any updated name/contact/address fields
    const companyFields = ['name', 'tax_id', 'phone_number', 'email', 'address'];
    const companyUpdates = [];
    const companyParams = [];
    for (const field of companyFields) {
      if (field in updates) {
        companyUpdates.push(`${field} = ?`);
        companyParams.push(updates[field]);
      }
    }
    if (companyUpdates.length > 0) {
      companyParams.push(shop_id);
      await db.query(
        `UPDATE company_profile SET ${companyUpdates.join(', ')} WHERE shop_id = ?`,
        companyParams
      ).catch(err => console.error('Failed to sync companyinfo on shop update:', err));
    }

    res.json({ success: true, message: 'Shop updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Activate/Deactivate shop
 */
exports.toggleShopStatus = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const { is_active } = req.body;

    const query = `UPDATE shops SET is_active = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`;

    await db.query(query, [is_active ? 1 : 0, req.user.id, shop_id]);
    res.json({
      success: true,
      message: `Shop ${is_active ? 'activated' : 'deactivated'} successfully`,
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Hard delete a shop and all shop-scoped records
 */
exports.deleteShop = async (req, res) => {
  let connection;

  try {
    const { shop_id } = req.params;
    const shopId = Number(shop_id);

    if (!Number.isInteger(shopId) || shopId <= 0) {
      return res.status(400).json({ error: 'Invalid shop_id' });
    }

    connection = await db.getConnection();
    await connection.beginTransaction();

    const [shopRows] = await connection.query('SELECT id, name FROM shops WHERE id = ? LIMIT 1', [shopId]);
    if (!shopRows || shopRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ error: 'Shop not found' });
    }

    // Collect all base tables containing a shop_id column.
    const [shopIdColumnTables] = await connection.query(
      `SELECT DISTINCT c.table_name AS tableName, c.column_name AS columnName
       FROM information_schema.columns c
       INNER JOIN information_schema.tables t
         ON t.table_schema = c.table_schema
        AND t.table_name = c.table_name
       WHERE c.table_schema = DATABASE()
         AND c.column_name = 'shop_id'
         AND c.table_name <> 'shops'
         AND t.table_type = 'BASE TABLE'`
    );

    // Also collect direct foreign-key references to shops.id (covers non-standard FK column names).
    const [shopFkTables] = await connection.query(
      `SELECT DISTINCT k.table_name AS tableName, k.column_name AS columnName
       FROM information_schema.key_column_usage k
       INNER JOIN information_schema.tables t
         ON t.table_schema = k.table_schema
        AND t.table_name = k.table_name
       WHERE k.table_schema = DATABASE()
         AND k.referenced_table_name = 'shops'
         AND k.referenced_column_name = 'id'
         AND k.table_name <> 'shops'
         AND t.table_type = 'BASE TABLE'`
    );

    const tableMap = new Map();
    [...shopIdColumnTables, ...shopFkTables].forEach((entry) => {
      const tableName = entry.tableName;
      const columnName = entry.columnName;
      if (!tableName || !columnName) {
        return;
      }
      const key = `${tableName}::${columnName}`;
      tableMap.set(key, { tableName, columnName });
    });

    const deleteTargets = Array.from(tableMap.values());
    const deletionSummary = [];

    for (const target of deleteTargets) {
      const sql = `DELETE FROM \`${target.tableName}\` WHERE \`${target.columnName}\` = ?`;
      const [deleteResult] = await connection.query(sql, [shopId]);
      deletionSummary.push({
        table: target.tableName,
        column: target.columnName,
        affectedRows: deleteResult.affectedRows || 0,
      });
    }

    const [shopDeleteResult] = await connection.query('DELETE FROM shops WHERE id = ?', [shopId]);
    if (!shopDeleteResult || shopDeleteResult.affectedRows === 0) {
      await connection.rollback();
      return res.status(500).json({ error: 'Failed to delete shop record' });
    }

    await connection.commit();

    res.json({
      success: true,
      message: `Shop "${shopRows[0].name}" and related records deleted successfully`,
      data: {
        shop_id: shopId,
        cascaded_tables: deletionSummary,
      },
    });
  } catch (error) {
    if (connection) {
      try {
        await connection.rollback();
      } catch (_) {
        // noop
      }
    }
    res.status(500).json({ error: 'Server error', details: error.message });
  } finally {
    if (connection) {
      connection.release();
    }
  }
};

// =====================================================
// SHOP USER MANAGEMENT (users table)
// =====================================================

/**
 * Get ALL users across all shops (for User Management page)
 */
exports.getAllUsers = async (req, res) => {
  try {
    const { search, shop_id, type, status } = req.query;
    let query = `
      SELECT u.id, u.shop_id, u.user_uuid, u.name, u.uname, u.contact, u.email, u.type, u.status, u.last_loggedin,
             s.name as shop_name, s.shop_code
      FROM users u
      LEFT JOIN shops s ON u.shop_id = s.id
      WHERE 1=1
    `;
    const params = [];

    if (search) {
      query += ' AND (u.name LIKE ? OR u.email LIKE ? OR u.uname LIKE ? OR s.name LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }
    if (shop_id) {
      query += ' AND u.shop_id = ?';
      params.push(shop_id);
    }
    if (type) {
      query += ' AND u.type = ?';
      params.push(type);
    }
    if (status !== undefined && status !== '') {
      query += ' AND u.status = ?';
      params.push(parseInt(status));
    }

    query += ' ORDER BY u.id DESC';

    const [results] = await db.query(query, params);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Create a new user and assign to a shop (from User Management page)
 */
exports.createUser = async (req, res) => {
  try {
    const { name, password, contact, email, type, shop_id } = req.body;

    if (!name || !password || !type || !shop_id) {
      return res.status(400).json({ error: 'Missing required fields: name, password, type, shop_id' });
    }

    // Validate shop exists
    const [shopRows] = await db.query('SELECT id, name FROM shops WHERE id = ?', [shop_id]);
    if (!shopRows || shopRows.length === 0) {
      return res.status(404).json({ error: 'Shop not found' });
    }

    const uname = String(Math.floor(10000 + Math.random() * 90000));
    const hashedPassword = await bcrypt.hash(password, 10);
    const { v4: uuidv4 } = require('uuid');
    const user_uuid = uuidv4();

    const query = `
      INSERT INTO users (shop_id, user_uuid, name, uname, pass, contact, email, type, status, last_loggedin)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, '')
    `;

    const [result] = await db.query(query, [
      shop_id, user_uuid, name, uname, hashedPassword,
      contact || '', email || '', type
    ]);

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: {
        user_id: result.insertId,
        shop_id: parseInt(shop_id),
        name, uname, type,
        shop_name: shopRows[0].name
      }
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'A user with this data already exists' });
    }
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update a user (from User Management page)
 */
exports.updateUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { name, contact, email, type, status, password, shop_id } = req.body;

    const updates = [];
    const params = [];

    if (name !== undefined) { updates.push('name = ?'); params.push(name); }
    if (contact !== undefined) { updates.push('contact = ?'); params.push(contact); }
    if (email !== undefined) { updates.push('email = ?'); params.push(email); }
    if (type !== undefined) { updates.push('type = ?'); params.push(type); }
    if (status !== undefined) { updates.push('status = ?'); params.push(status); }
    if (shop_id !== undefined) { updates.push('shop_id = ?'); params.push(shop_id); }
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push('pass = ?');
      params.push(hashedPassword);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    const query = `UPDATE users SET ${updates.join(', ')} WHERE id = ?`;
    params.push(user_id);

    const [result] = await db.query(query, params);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, message: 'User updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Delete a user (terminate)
 */
exports.deleteUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    const [result] = await db.query('DELETE FROM users WHERE id = ?', [user_id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get all users for a specific shop
 */
exports.getShopUsers = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const query = `
      SELECT id, shop_id, user_uuid, name, uname, contact, email, type, status, last_loggedin
      FROM users
      WHERE shop_id = ?
      ORDER BY id DESC
    `;
    const [results] = await db.query(query, [shop_id]);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Create a new user for a specific shop (admin, cashier, account, etc.)
 */
exports.createShopUser = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const { name, password, contact, email, type } = req.body;

    if (!name || !password || !type) {
      return res.status(400).json({ error: 'Missing required fields: name, password, type' });
    }

    // Validate shop exists
    const [shopRows] = await db.query('SELECT id, name FROM shops WHERE id = ?', [shop_id]);
    if (!shopRows || shopRows.length === 0) {
      return res.status(404).json({ error: 'Shop not found' });
    }

    // Generate a random 5-digit username (uname) like existing users
    const uname = String(Math.floor(10000 + Math.random() * 90000));

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate UUID
    const { v4: uuidv4 } = require('uuid');
    const user_uuid = uuidv4();

    const query = `
      INSERT INTO users (shop_id, user_uuid, name, uname, pass, contact, email, type, status, last_loggedin)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, '')
    `;

    const [result] = await db.query(query, [
      shop_id,
      user_uuid,
      name,
      uname,
      hashedPassword,
      contact || '',
      email || '',
      type
    ]);

    res.status(201).json({
      success: true,
      message: 'Shop user created successfully',
      data: {
        user_id: result.insertId,
        shop_id: parseInt(shop_id),
        name,
        uname,
        type,
        shop_name: shopRows[0].name
      }
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'A user with this UUID already exists' });
    }
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update a shop user
 */
exports.updateShopUser = async (req, res) => {
  try {
    const { shop_id, user_id } = req.params;
    const { name, contact, email, type, status, password } = req.body;

    const updates = [];
    const params = [];

    if (name !== undefined) { updates.push('name = ?'); params.push(name); }
    if (contact !== undefined) { updates.push('contact = ?'); params.push(contact); }
    if (email !== undefined) { updates.push('email = ?'); params.push(email); }
    if (type !== undefined) { updates.push('type = ?'); params.push(type); }
    if (status !== undefined) { updates.push('status = ?'); params.push(status ? 1 : 0); }
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push('pass = ?');
      params.push(hashedPassword);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    const query = `UPDATE users SET ${updates.join(', ')} WHERE id = ? AND shop_id = ?`;
    params.push(user_id, shop_id);

    const [result] = await db.query(query, params);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found in this shop' });
    }

    res.json({ success: true, message: 'Shop user updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Delete a shop user
 */
exports.deleteShopUser = async (req, res) => {
  try {
    const { shop_id, user_id } = req.params;
    const [result] = await db.query('DELETE FROM users WHERE id = ? AND shop_id = ?', [user_id, shop_id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found in this shop' });
    }

    res.json({ success: true, message: 'Shop user deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// BILLING MANAGEMENT
// =====================================================

/**
 * Get billing information for a shop
 */
exports.getShopBilling = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const { months = 12 } = req.query;

    const paymentRecordsQuery = `
      SELECT
        pr.id,
        pr.shop_id,
        DATE_SUB(pr.due_date, INTERVAL CASE pr.payment_type
          WHEN 'YEARLY' THEN 12
          WHEN 'QUARTERLY' THEN 3
          ELSE 1
        END MONTH) as billing_period_start,
        pr.due_date as billing_period_end,
        pr.amount as amount_due,
        CASE WHEN pr.payment_status = 'COMPLETED' THEN pr.amount ELSE 0 END as amount_paid,
        CASE
          WHEN pr.payment_status = 'COMPLETED' THEN 'paid'
          WHEN pr.payment_status IN ('CANCELLED', 'REFUNDED') THEN 'cancelled'
          WHEN pr.payment_status = 'FAILED' THEN 'overdue'
          WHEN pr.payment_status = 'PENDING' AND pr.due_date < CURDATE() THEN 'overdue'
          ELSE 'pending'
        END as billing_status,
        pr.payment_type,
        pr.payment_method,
        pr.payment_status,
        pr.reference_number,
        pr.transaction_id,
        pr.notes,
        pr.created_at,
        pr.updated_at,
        sp.name as plan_name,
        sp.price_per_month
      FROM payment_records pr
      LEFT JOIN shop_subscriptions ss ON pr.subscription_id = ss.id
      LEFT JOIN subscription_plans sp ON ss.plan_id = sp.id
      WHERE pr.shop_id = ?
      ORDER BY pr.due_date DESC, pr.id DESC
      LIMIT ?
    `;

    const [paymentRows] = await db.query(paymentRecordsQuery, [shop_id, parseInt(months)]);

    // Backward compatibility: fallback for old deployments that still use shop_billing table.
    if (paymentRows && paymentRows.length > 0) {
      return res.json({ success: true, data: paymentRows });
    }

    const legacyQuery = `
      SELECT
        sb.*,
        sp.name as plan_name,
        sp.price_per_month
      FROM shop_billing sb
      LEFT JOIN subscription_plans sp ON sb.plan_id = sp.id
      WHERE sb.shop_id = ?
      ORDER BY sb.billing_period_start DESC
      LIMIT ?
    `;

    const [legacyRows] = await db.query(legacyQuery, [shop_id, parseInt(months)]);
    return res.json({ success: true, data: legacyRows });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get dashboard statistics
 */
exports.getDashboardStats = async (req, res) => {
  try {
    const { shop_id, start_date, end_date } = req.query;
    const hasShopFilter = !!shop_id;
    const hasDateRange = !!(start_date && end_date);

    const shopFilter = hasShopFilter ? ' AND s.id = ?' : '';
    const userFilter = hasShopFilter ? ' AND u.shop_id = ?' : '';
    const paymentFilter = hasShopFilter ? ' AND pr.shop_id = ?' : '';
    const paymentDateFilter = hasDateRange ? ' AND DATE(COALESCE(pr.paid_date, pr.created_at)) BETWEEN ? AND ?' : '';
    const pendingDateFilter = hasDateRange ? ' AND DATE(pr.created_at) BETWEEN ? AND ?' : '';
    const billDateFilter = hasDateRange ? ' AND DATE(fb.inv_date) BETWEEN ? AND ?' : '';

    const withShopAndDate = () => {
      const params = [];
      if (hasShopFilter) params.push(shop_id);
      if (hasDateRange) params.push(start_date, end_date);
      return params;
    };

    const withShopOnly = () => (hasShopFilter ? [shop_id] : []);

    const [totalShops] = await db.query(
      `SELECT COUNT(*) as count FROM shops s WHERE COALESCE(s.is_active, 1) = 1${shopFilter}`,
      withShopOnly()
    );

    const [activeShops] = await db.query(
      `SELECT COUNT(*) as count FROM shops s WHERE COALESCE(s.is_active, 1) = 1 AND s.subscription_status = 'active'${shopFilter}`,
      withShopOnly()
    );

    const [totalUsers] = await db.query(
      `SELECT COUNT(*) as count FROM users u WHERE 1=1${userFilter}`,
      withShopOnly()
    );

    const [totalRevenue] = await db.query(
      `SELECT COALESCE(SUM(pr.amount), 0) as total
       FROM payment_records pr
       WHERE pr.payment_status = 'COMPLETED'${paymentFilter}${paymentDateFilter}`,
      withShopAndDate()
    );

    const [pendingBills] = await db.query(
      `SELECT COUNT(*) as count
       FROM payment_records pr
       WHERE pr.payment_status IN ('PENDING', 'FAILED')${paymentFilter}${pendingDateFilter}`,
      withShopAndDate()
    );

    let lastMonthRevenue;
    if (hasDateRange) {
      [lastMonthRevenue] = await db.query(
        `SELECT COALESCE(SUM(pr.amount), 0) as total
         FROM payment_records pr
         WHERE pr.payment_status = 'COMPLETED'${paymentFilter}${paymentDateFilter}`,
        withShopAndDate()
      );
    } else {
      [lastMonthRevenue] = await db.query(
        `SELECT COALESCE(SUM(pr.amount), 0) as total
         FROM payment_records pr
         WHERE pr.payment_status = 'COMPLETED'
           AND DATE(COALESCE(pr.paid_date, pr.created_at)) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)${paymentFilter}`,
        withShopOnly()
      );
    }

    const [subscriptionDistribution] = await db.query(
      `SELECT COALESCE(sp.name, 'Unassigned') as name, COUNT(*) as count
       FROM shops s
       LEFT JOIN subscription_plans sp ON sp.id = s.subscription_plan_id
       WHERE COALESCE(s.is_active, 1) = 1${shopFilter}
       GROUP BY sp.id, sp.name
       ORDER BY count DESC`,
      withShopOnly()
    );

    const [topShops] = await db.query(
      `SELECT
         s.id,
         s.name,
         COUNT(fb.id) as total_bills,
         COALESCE(SUM(fb.grand_total), 0) as total_sales
       FROM shops s
       LEFT JOIN final_bill fb ON fb.shop_id = s.id
       WHERE COALESCE(s.is_active, 1) = 1${shopFilter}${billDateFilter}
       GROUP BY s.id, s.name
       ORDER BY total_sales DESC
       LIMIT 10`,
      withShopAndDate()
    );

    res.json({
      success: true,
      data: {
        totalShops,
        activeShops,
        totalUsers,
        totalRevenue,
        pendingBills,
        lastMonthRevenue,
        subscriptionDistribution,
        topShops,
        dateRange: hasDateRange ? { start_date, end_date } : null
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// AUDIT LOGS
// =====================================================

/**
 * Get audit logs
 */
exports.getAuditLogs = async (req, res) => {
  try {
    const { shop_id, action, days = 30 } = req.query;
    const page = req.query.page || 1;
    const limit = req.query.limit || 20;
    const offset = (page - 1) * limit;

    let query = `SELECT * FROM shop_audit_logs WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)`;
    const params = [days];

    if (shop_id) {
      query += ' AND shop_id = ?';
      params.push(shop_id);
    }

    if (action) {
      query += ' AND action = ?';
      params.push(action);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(Number(limit), Number(offset));

    const [results] = await db.query(query, params);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// SUPER ADMIN USER MANAGEMENT
// =====================================================

/**
 * Get all super admin users
 */
exports.getSuperAdminUsers = async (req, res) => {
  try {
    const query = `
      SELECT sau.id, sau.username, sau.email, sau.first_name, sau.last_name, sau.role, sau.shop_id, 
             sau.is_active, sau.last_login, sau.created_at,
             s.name as shop_name, s.shop_code
      FROM super_admin_users sau
      LEFT JOIN shops s ON sau.shop_id = s.id
      ORDER BY sau.created_at DESC
    `;

    const [results] = await db.query(query);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Create new super admin user
 */
exports.createSuperAdminUser = async (req, res) => {
  try {
    const { username, email, password, first_name, last_name, role, phone_number, shop_id } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Missing required fields: username, email, password' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const query = `
      INSERT INTO super_admin_users 
      (username, email, password_hash, first_name, last_name, phone_number, role, shop_id, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())
    `;

    const [result] = await db.query(query, [
      username,
      email,
      hashedPassword,
      first_name || null,
      last_name || null,
      phone_number || null,
      role || 'super_admin',
      shop_id || null
    ]);

    res.status(201).json({
      success: true,
      message: 'Super admin user created successfully',
      user_id: result.insertId
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Username or email already exists' });
    }
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update super admin user
 */
exports.updateSuperAdminUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { first_name, last_name, role, phone_number, is_active, shop_id } = req.body;

    if (!user_id) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    let query = 'UPDATE super_admin_users SET ';
    const params = [];
    const updates = [];

    if (first_name !== undefined) {
      updates.push('first_name = ?');
      params.push(first_name);
    }
    if (last_name !== undefined) {
      updates.push('last_name = ?');
      params.push(last_name);
    }
    if (role !== undefined) {
      updates.push('role = ?');
      params.push(role);
    }
    if (phone_number !== undefined) {
      updates.push('phone_number = ?');
      params.push(phone_number);
    }
    if (is_active !== undefined) {
      updates.push('is_active = ?');
      params.push(is_active ? 1 : 0);
    }
    if (shop_id !== undefined) {
      updates.push('shop_id = ?');
      params.push(shop_id || null);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    query += updates.join(', ') + ', updated_at = NOW() WHERE id = ?';
    params.push(user_id);

    const [result] = await db.query(query, params);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Super admin user not found' });
    }

    res.json({ success: true, message: 'Super admin user updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Delete super admin user
 */
exports.deleteSuperAdminUser = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    const query = 'DELETE FROM super_admin_users WHERE id = ?';

    const [result] = await db.query(query, [user_id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Super admin user not found' });
    }

    res.json({ success: true, message: 'Super admin user deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// SUBSCRIPTION PLANS MANAGEMENT
// =====================================================

/**
 * Get all subscription plans
 */
exports.getSubscriptionPlans = async (req, res) => {
  try {
    const query = `SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY price_per_month ASC`;
    const [results] = await db.query(query);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Create subscription plan
 */
exports.createSubscriptionPlan = async (req, res) => {
  try {
    const { name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features } = req.body;

    if (!name || !price_per_month) {
      return res.status(400).json({ error: 'Missing required fields: name, price_per_month' });
    }

    const query = `
      INSERT INTO subscription_plans 
      (name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())
    `;

    const featuresJson = features ? JSON.stringify(features) : JSON.stringify([]);
    const [result] = await db.query(query, [
      name,
      description || null,
      price_per_month,
      max_terminals || 1,
      max_users || 5,
      storage_quota_gb || 10,
      featuresJson
    ]);

    res.status(201).json({
      success: true,
      message: 'Subscription plan created successfully',
      plan_id: result.insertId
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update subscription plan
 */
exports.updateSubscriptionPlan = async (req, res) => {
  try {
    const { plan_id } = req.params;
    const { name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features, is_active } = req.body;

    if (!plan_id) {
      return res.status(400).json({ error: 'Plan ID is required' });
    }

    let query = 'UPDATE subscription_plans SET ';
    const params = [];
    const updates = [];

    if (name !== undefined) {
      updates.push('name = ?');
      params.push(name);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      params.push(description);
    }
    if (price_per_month !== undefined) {
      updates.push('price_per_month = ?');
      params.push(price_per_month);
    }
    if (max_terminals !== undefined) {
      updates.push('max_terminals = ?');
      params.push(max_terminals);
    }
    if (max_users !== undefined) {
      updates.push('max_users = ?');
      params.push(max_users);
    }
    if (storage_quota_gb !== undefined) {
      updates.push('storage_quota_gb = ?');
      params.push(storage_quota_gb);
    }
    if (features !== undefined) {
      updates.push('features = ?');
      params.push(JSON.stringify(features));
    }
    if (is_active !== undefined) {
      updates.push('is_active = ?');
      params.push(is_active ? 1 : 0);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    query += updates.join(', ') + ', updated_at = NOW() WHERE id = ?';
    params.push(plan_id);

    const [result] = await db.query(query, params);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Subscription plan not found' });
    }

    res.json({ success: true, message: 'Subscription plan updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Delete subscription plan
 */
exports.deleteSubscriptionPlan = async (req, res) => {
  try {
    const { plan_id } = req.params;

    if (!plan_id) {
      return res.status(400).json({ error: 'Plan ID is required' });
    }

    // Set is_active to 0 instead of deleting (soft delete)
    const query = 'UPDATE subscription_plans SET is_active = 0, updated_at = NOW() WHERE id = ?';

    const [result] = await db.query(query, [plan_id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Subscription plan not found' });
    }

    res.json({ success: true, message: 'Subscription plan deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

// =====================================================
// ANALYTICS & REPORTING
// =====================================================

/**
 * Get revenue analytics
 */
exports.getRevenueAnalytics = async (req, res) => {
  try {
    const { period = 'monthly', months = 12 } = req.query;

    let query;
    let groupBy;

    if (period === 'daily') {
      groupBy = 'DATE(billing_period_start)';
    } else if (period === 'yearly') {
      groupBy = 'YEAR(billing_period_start)';
    } else {
      groupBy = 'YEAR_MONTH(billing_period_start)';
    }

    query = `
      SELECT 
        ${groupBy} as period,
        SUM(amount_paid) as total_revenue,
        COUNT(DISTINCT shop_id) as shops_count,
        AVG(amount_paid) as avg_payment,
        COUNT(*) as transactions_count
      FROM shop_billing
      WHERE billing_status = 'paid'
        AND billing_period_start >= DATE_SUB(NOW(), INTERVAL ? MONTH)
      GROUP BY ${groupBy}
      ORDER BY period DESC
    `;

    const [results] = await db.query(query, [months]);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get shop comparison analytics
 */
exports.getShopComparison = async (req, res) => {
  try {
    const query = `
      SELECT 
        s.id,
        s.name,
        s.shop_code,
        s.subscription_status,
        sp.name as plan_name,
        COUNT(DISTINCT u.id) as user_count,
        COALESCE(SUM(sb.amount_paid), 0) as total_revenue,
        COUNT(DISTINCT sb.id) as payment_count
      FROM shops s
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      LEFT JOIN users u ON s.id = u.shop_id
      LEFT JOIN shop_billing sb ON s.id = sb.shop_id AND sb.billing_status = 'paid'
      WHERE s.is_active = 1
      GROUP BY s.id
      ORDER BY total_revenue DESC
    `;

    const [results] = await db.query(query);
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get system health metrics
 */
exports.getSystemHealth = async (req, res) => {
  try {
    const { shop_id, start_date, end_date } = req.query;
    const hasShopFilter = !!shop_id;
    const hasDateRange = !!(start_date && end_date);

    const shopFilter = hasShopFilter ? ' AND s.id = ?' : '';
    const userFilter = hasShopFilter ? ' AND u.shop_id = ?' : '';
    const paymentFilter = hasShopFilter ? ' AND pr.shop_id = ?' : '';
    const rangeFilter = hasDateRange ? ' AND DATE(COALESCE(pr.paid_date, pr.created_at)) BETWEEN ? AND ?' : '';

    const withShopAndRange = () => {
      const params = [];
      if (hasShopFilter) params.push(shop_id);
      if (hasDateRange) params.push(start_date, end_date);
      return params;
    };
    const withShopOnly = () => (hasShopFilter ? [shop_id] : []);
    const health = {
      totalShops: 0,
      activeUsers: 0,
      todayBills: 0,
      todayRevenue: 0,
      dbSize: 0
    };

    try {
      const [rows] = await db.query(
        `SELECT COUNT(*) as count FROM shops s WHERE COALESCE(s.is_active, 1) = 1${shopFilter}`,
        withShopOnly()
      );
      health.totalShops = Number(rows?.[0]?.count || 0);
    } catch {}

    try {
      const [rows] = await db.query(
        `SELECT COUNT(*) as count FROM users u WHERE 1=1${userFilter}`,
        withShopOnly()
      );
      health.activeUsers = Number(rows?.[0]?.count || 0);
    } catch {}

    try {
      const dateClause = hasDateRange ? rangeFilter : ' AND DATE(pr.created_at) = CURDATE()';
      const [rows] = await db.query(
        `SELECT COUNT(*) as count
         FROM payment_records pr
         WHERE 1=1${paymentFilter}${dateClause}`,
        hasDateRange ? withShopAndRange() : withShopOnly()
      );
      health.todayBills = Number(rows?.[0]?.count || 0);
    } catch {}

    try {
      const dateClause = hasDateRange ? rangeFilter : ' AND DATE(COALESCE(pr.paid_date, pr.created_at)) = CURDATE()';
      const [rows] = await db.query(
        `SELECT COALESCE(SUM(pr.amount), 0) as total
         FROM payment_records pr
         WHERE pr.payment_status = 'COMPLETED'${paymentFilter}${dateClause}`,
        hasDateRange ? withShopAndRange() : withShopOnly()
      );
      health.todayRevenue = Number(rows?.[0]?.total || 0);
    } catch {}

    try {
      const [rows] = await db.query(
        'SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as size_mb FROM information_schema.TABLES WHERE table_schema = DATABASE()'
      );
      health.dbSize = Number(rows?.[0]?.size_mb || 0);
    } catch {}

    // Server-level health snapshot
    const toMB = (bytes) => Number((bytes / 1024 / 1024).toFixed(2));
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;
    const memUsagePercent = totalMem > 0 ? Number(((usedMem / totalMem) * 100).toFixed(2)) : 0;
    const processCpuUsagePercent = getProcessCpuUsagePercent();
    const systemCpuUsagePercent = getSystemCpuUsagePercent();

    const runtimeMemory = process.memoryUsage();
    const serverHealth = {
      timestamp: new Date().toISOString(),
      hostname: os.hostname(),
      environment: getRuntimeEnvironmentName(),
      primaryIp: getPrimaryServerIp(),
      uptimeSeconds: Math.floor(process.uptime()),
      uptimeHuman: `${Math.floor(process.uptime() / 3600)}h ${Math.floor((process.uptime() % 3600) / 60)}m`,
      platform: os.platform(),
      release: os.release(),
      nodeVersion: process.version,
      cpuCores: os.cpus()?.length || 0,
      cpuModel: os.cpus()?.[0]?.model || 'Unknown',
      cpuUsagePercent: systemCpuUsagePercent,
      processCpuUsagePercent,
      loadAverage: os.loadavg(),
      memory: {
        totalMB: toMB(totalMem),
        usedMB: toMB(usedMem),
        freeMB: toMB(freeMem),
        usagePercent: memUsagePercent
      },
      processMemory: {
        rssMB: toMB(runtimeMemory.rss),
        heapTotalMB: toMB(runtimeMemory.heapTotal),
        heapUsedMB: toMB(runtimeMemory.heapUsed),
        externalMB: toMB(runtimeMemory.external)
      },
      database: {
        status: 'unknown',
        pingMs: null
      }
    };

    try {
      const pingStart = Date.now();
      await db.query('SELECT 1');
      serverHealth.database.status = 'up';
      serverHealth.database.pingMs = Date.now() - pingStart;
    } catch {
      serverHealth.database.status = 'down';
    }

    health.server = serverHealth;
    health.dateRange = hasDateRange ? { start_date, end_date } : null;

    res.json({ success: true, data: health });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

module.exports = exports;
