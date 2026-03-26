/**
 * SUPER ADMIN CONTROLLER - COMPLETE IMPLEMENTATION
 * Manages all shops across the SaaS platform with full features
 */

const connection = require('../config/dbconnection');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// =====================================================
// SHOP MANAGEMENT
// =====================================================

/**
 * Get all shops (with pagination and filters)
 */
exports.getAllShops = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const status = req.query.status;
    const search = req.query.search;
    const sortBy = req.query.sortBy || 'created_at';
    const sortOrder = req.query.sortOrder === 'asc' ? 'ASC' : 'DESC';

    let query = `
      SELECT 
        s.*,
        sp.name as plan_name,
        sp.price_per_month,
        COUNT(DISTINCT u.id) as total_users,
        COUNT(DISTINCT sb.id) as total_bills
      FROM shops s
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      LEFT JOIN users u ON s.id = u.shop_id
      LEFT JOIN bills sb ON s.id = sb.shop_id
      WHERE 1=1
    `;
    
    let countQuery = 'SELECT COUNT(DISTINCT s.id) as total FROM shops s WHERE 1=1';
    const params = [];

    if (status) {
      query += ' AND s.subscription_status = ?';
      countQuery += ' AND s.subscription_status = ?';
      params.push(status);
    }

    if (search) {
      query += ' AND (s.name LIKE ? OR s.shop_code LIKE ? OR s.email LIKE ?)';
      countQuery += ' AND (s.name LIKE ? OR s.shop_code LIKE ? OR s.email LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    query += ` GROUP BY s.id ORDER BY s.${sortBy} ${sortOrder} LIMIT ? OFFSET ?`;
    const countParams = [...params];

    connection.query(countQuery, countParams, (countErr, countResult) => {
      if (countErr) {
        console.error('Count query error:', countErr);
        return res.status(500).json({ success: false, error: 'Failed to count shops' });
      }

      const total = countResult[0].total;

      connection.query(query, [...params, limit, offset], (err, results) => {
        if (err) {
          console.error('Query error:', err);
          return res.status(500).json({ success: false, error: 'Failed to fetch shops' });
        }

        res.json({
          success: true,
          data: results,
          pagination: {
            total,
            page,
            limit,
            pages: Math.ceil(total / limit),
          },
        });
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Get single shop details with comprehensive info
 */
exports.getShopDetails = async (req, res) => {
  try {
    const { shop_id } = req.params;

    const query = `
      SELECT 
        s.*,
        sp.name as plan_name,
        sp.price_per_month,
        sp.max_terminals,
        sp.max_users,
        sp.storage_quota_gb as plan_storage_quota,
        COUNT(DISTINCT sa.id) as total_admins,
        COUNT(DISTINCT u.id) as total_staff,
        SUM(CASE WHEN sb.bill_date >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN sb.bill_amount ELSE 0 END) as last_30_days_sales,
        COUNT(DISTINCT CASE WHEN sb.bill_date >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN sb.id END) as last_30_days_bills
      FROM shops s
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      LEFT JOIN shop_admins sa ON s.id = sa.shop_id AND sa.is_active = 1
      LEFT JOIN users u ON s.id = u.shop_id AND u.is_active = 1
      LEFT JOIN bills sb ON s.id = sb.shop_id
      WHERE s.id = ?
      GROUP BY s.id
    `;

    connection.query(query, [shop_id], (err, results) => {
      if (err) {
        console.error('Error fetching shop details:', err);
        return res.status(500).json({ success: false, error: 'Failed to fetch shop' });
      }

      if (results.length === 0) {
        return res.status(404).json({ success: false, error: 'Shop not found' });
      }

      res.json({ success: true, data: results[0] });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Create new shop
 */
exports.createShop = async (req, res) => {
  try {
    const {
      name,
      shop_code,
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
      subscription_plan_id,
      no_of_terminals,
      max_users,
      storage_quota_gb,
    } = req.body;

    // Validation
    if (!name || !shop_code || !tax_id || !phone_number || !email || !address) {
      return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    const query = `
      INSERT INTO shops 
      (name, shop_code, tax_id, phone_number, email, address, city, state, 
       zip_code, country, website, contact_person, contact_person_phone,
       subscription_plan_id, no_of_terminals, max_users, storage_quota_gb, 
       subscription_status, subscription_start_date, subscription_end_date, created_by, is_active)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'trial', NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), ?, 1)
    `;

    const params = [
      name,
      shop_code,
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
      subscription_plan_id || 1,
      no_of_terminals || 1,
      max_users || 10,
      storage_quota_gb || 50,
      req.user.id,
    ];

    connection.query(query, params, (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(400).json({ success: false, error: 'Shop code or Tax ID already exists' });
        }
        console.error('Error creating shop:', err);
        return res.status(500).json({ success: false, error: 'Failed to create shop' });
      }

      // Log action
      logAuditAction(result.insertId, req.user.id, 'CREATE_SHOP', `Created shop: ${name}`);

      res.json({ 
        success: true, 
        message: 'Shop created successfully',
        data: { shop_id: result.insertId }
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Update shop details
 */
exports.updateShop = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const {
      name,
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
    } = req.body;

    const query = `
      UPDATE shops SET 
        name = COALESCE(?, name),
        phone_number = COALESCE(?, phone_number),
        email = COALESCE(?, email),
        address = COALESCE(?, address),
        city = COALESCE(?, city),
        state = COALESCE(?, state),
        zip_code = COALESCE(?, zip_code),
        country = COALESCE(?, country),
        website = COALESCE(?, website),
        contact_person = COALESCE(?, contact_person),
        contact_person_phone = COALESCE(?, contact_person_phone),
        updated_by = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `;

    const params = [
      name || null,
      phone_number || null,
      email || null,
      address || null,
      city || null,
      state || null,
      zip_code || null,
      country || null,
      website || null,
      contact_person || null,
      contact_person_phone || null,
      req.user.id,
      shop_id,
    ];

    connection.query(query, params, (err, result) => {
      if (err) {
        console.error('Error updating shop:', err);
        return res.status(500).json({ success: false, error: 'Failed to update shop' });
      }

      logAuditAction(shop_id, req.user.id, 'UPDATE_SHOP', 'Updated shop details');

      res.json({ success: true, message: 'Shop updated successfully' });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Activate/Deactivate shop
 */
exports.toggleShopStatus = async (req, res) => {
  try {
    const { shop_id } = req.params;
    const { status } = req.body; // 'active', 'inactive', 'trial', 'suspended'

    if (!['active', 'inactive', 'trial', 'suspended'].includes(status)) {
      return res.status(400).json({ success: false, error: 'Invalid status' });
    }

    const query = `
      UPDATE shops SET 
        subscription_status = ?,
        updated_by = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `;

    connection.query(query, [status, req.user.id, shop_id], (err, result) => {
      if (err) {
        console.error('Error updating status:', err);
        return res.status(500).json({ success: false, error: 'Failed to update status' });
      }

      logAuditAction(shop_id, req.user.id, 'UPDATE_SHOP_STATUS', `Changed status to ${status}`);

      res.json({ success: true, message: `Shop status changed to ${status}` });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
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

    const query = `
      SELECT 
        sb.*,
        sp.name as plan_name,
        sp.price_per_month
      FROM shop_billing sb
      LEFT JOIN subscription_plans sp ON sb.plan_id = sp.id
      WHERE sb.shop_id = ?
      ORDER BY sb.billing_period_start DESC
      LIMIT 12
    `;

    connection.query(query, [shop_id], (err, results) => {
      if (err) {
        console.error('Error fetching billing:', err);
        return res.status(500).json({ success: false, error: 'Failed to fetch billing info' });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Get platform dashboard statistics
 */
exports.getDashboardStats = async (req, res) => {
  try {
    const statsQueries = {
      totalShops: 'SELECT COUNT(*) as count FROM shops WHERE is_active = 1',
      activeShops: 'SELECT COUNT(*) as count FROM shops WHERE subscription_status = "active"',
      totalUsers: 'SELECT COUNT(*) as count FROM users WHERE is_active = 1',
      totalRevenue: 'SELECT COALESCE(SUM(amount_paid), 0) as total FROM shop_billing WHERE billing_status = "paid"',
      pendingBills: 'SELECT COUNT(*) as count FROM shop_billing WHERE billing_status = "pending"',
      lastMonthRevenue: `SELECT COALESCE(SUM(amount_paid), 0) as total FROM shop_billing 
                         WHERE billing_status = "paid" AND billing_period_start >= DATE_SUB(NOW(), INTERVAL 1 MONTH)`,
      subscriptionDistribution: `SELECT sp.name, COUNT(s.id) as count 
                                  FROM shops s
                                  LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
                                  GROUP BY sp.id`,
      topShops: `SELECT s.id, s.name, s.shop_code, COUNT(DISTINCT b.id) as total_bills,
                        SUM(b.bill_amount) as total_sales
                 FROM shops s
                 LEFT JOIN bills b ON s.id = b.shop_id AND b.bill_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                 GROUP BY s.id
                 ORDER BY total_sales DESC
                 LIMIT 5`
    };

    const stats = {};
    let completedQueries = 0;

    Object.keys(statsQueries).forEach(key => {
      connection.query(statsQueries[key], (err, results) => {
        if (!err) {
          stats[key] = results.length > 0 ? results : [];
        }
        completedQueries++;

        if (completedQueries === Object.keys(statsQueries).length) {
          res.json({ success: true, data: stats });
        }
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Get revenue analytics
 */
exports.getRevenueAnalytics = async (req, res) => {
  try {
    const period = req.query.period || '30'; // days

    const query = `
      SELECT 
        DATE(sb.billing_period_start) as date,
        SUM(sb.amount_paid) as daily_revenue,
        COUNT(DISTINCT sb.shop_id) as active_shops
      FROM shop_billing sb
      WHERE sb.billing_status = 'paid' 
        AND sb.billing_period_start >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY DATE(sb.billing_period_start)
      ORDER BY date ASC
    `;

    connection.query(query, [period], (err, results) => {
      if (err) {
        console.error('Error fetching revenue analytics:', err);
        return res.status(500).json({ success: false, error: 'Failed to fetch analytics' });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Get audit logs
 */
exports.getAuditLogs = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const shopId = req.query.shop_id;

    let query = 'SELECT * FROM shop_audit_logs WHERE 1=1';
    let countQuery = 'SELECT COUNT(*) as total FROM shop_audit_logs WHERE 1=1';
    const params = [];

    if (shopId) {
      query += ' AND shop_id = ?';
      countQuery += ' AND shop_id = ?';
      params.push(shopId);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    const countParams = [...params];

    connection.query(countQuery, countParams, (countErr, countResult) => {
      if (countErr) {
        return res.status(500).json({ success: false, error: 'Failed to count logs' });
      }

      connection.query(query, [...params, limit, offset], (err, results) => {
        if (err) {
          return res.status(500).json({ success: false, error: 'Failed to fetch logs' });
        }

        res.json({
          success: true,
          data: results,
          pagination: {
            total: countResult[0].total,
            page,
            limit,
            pages: Math.ceil(countResult[0].total / limit),
          },
        });
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

// =====================================================
// SUBSCRIPTION PLANS
// =====================================================

/**
 * Get all subscription plans
 */
exports.getSubscriptionPlans = async (req, res) => {
  try {
    const query = 'SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY price_per_month ASC';

    connection.query(query, (err, results) => {
      if (err) {
        return res.status(500).json({ success: false, error: 'Failed to fetch plans' });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Create subscription plan
 */
exports.createSubscriptionPlan = async (req, res) => {
  try {
    const { name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features } = req.body;

    if (!name || !price_per_month) {
      return res.status(400).json({ success: false, error: 'Name and price are required' });
    }

    const query = `
      INSERT INTO subscription_plans 
      (name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features, is_active)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1)
    `;

    const params = [
      name,
      description || null,
      price_per_month,
      max_terminals || 1,
      max_users || 5,
      storage_quota_gb || 10,
      JSON.stringify(features || []),
    ];

    connection.query(query, params, (err, result) => {
      if (err) {
        console.error('Error creating plan:', err);
        return res.status(500).json({ success: false, error: 'Failed to create plan' });
      }

      res.json({ success: true, message: 'Plan created successfully', data: { plan_id: result.insertId } });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Update subscription plan
 */
exports.updateSubscriptionPlan = async (req, res) => {
  try {
    const { plan_id } = req.params;
    const { name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features } = req.body;

    const query = `
      UPDATE subscription_plans SET 
        name = COALESCE(?, name),
        description = COALESCE(?, description),
        price_per_month = COALESCE(?, price_per_month),
        max_terminals = COALESCE(?, max_terminals),
        max_users = COALESCE(?, max_users),
        storage_quota_gb = COALESCE(?, storage_quota_gb),
        features = COALESCE(?, features),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `;

    const params = [
      name || null,
      description || null,
      price_per_month || null,
      max_terminals || null,
      max_users || null,
      storage_quota_gb || null,
      features ? JSON.stringify(features) : null,
      plan_id,
    ];

    connection.query(query, params, (err) => {
      if (err) {
        console.error('Error updating plan:', err);
        return res.status(500).json({ success: false, error: 'Failed to update plan' });
      }

      res.json({ success: true, message: 'Plan updated successfully' });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Delete subscription plan
 */
exports.deleteSubscriptionPlan = async (req, res) => {
  try {
    const { plan_id } = req.params;

    // Check if any shops use this plan
    const checkQuery = 'SELECT COUNT(*) as count FROM shops WHERE subscription_plan_id = ?';

    connection.query(checkQuery, [plan_id], (err, results) => {
      if (err || results[0].count > 0) {
        return res.status(400).json({ success: false, error: 'Cannot delete plan in use' });
      }

      const query = 'UPDATE subscription_plans SET is_active = 0 WHERE id = ?';
      connection.query(query, [plan_id], (err) => {
        if (err) {
          return res.status(500).json({ success: false, error: 'Failed to delete plan' });
        }

        res.json({ success: true, message: 'Plan deleted successfully' });
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
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
    const query = 'SELECT id, username, email, first_name, last_name, role, is_active, last_login, created_at FROM super_admin_users ORDER BY created_at DESC';

    connection.query(query, (err, results) => {
      if (err) {
        return res.status(500).json({ success: false, error: 'Failed to fetch users' });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Create super admin user
 */
exports.createSuperAdminUser = async (req, res) => {
  try {
    const { username, email, password, first_name, last_name, role } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);

    const query = `
      INSERT INTO super_admin_users 
      (username, email, password_hash, first_name, last_name, role, is_active)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `;

    connection.query(query, [username, email, hashedPassword, first_name || null, last_name || null, role || 'admin'], (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(400).json({ success: false, error: 'Username or email already exists' });
        }
        return res.status(500).json({ success: false, error: 'Failed to create user' });
      }

      res.json({ success: true, message: 'User created successfully', data: { user_id: result.insertId } });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Update super admin user
 */
exports.updateSuperAdminUser = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { first_name, last_name, role, is_active } = req.body;

    const query = `
      UPDATE super_admin_users SET 
        first_name = COALESCE(?, first_name),
        last_name = COALESCE(?, last_name),
        role = COALESCE(?, role),
        is_active = COALESCE(?, is_active),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `;

    connection.query(query, [first_name || null, last_name || null, role || null, is_active !== undefined ? is_active : null, user_id], (err) => {
      if (err) {
        return res.status(500).json({ success: false, error: 'Failed to update user' });
      }

      res.json({ success: true, message: 'User updated successfully' });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Delete super admin user
 */
exports.deleteSuperAdminUser = async (req, res) => {
  try {
    const { user_id } = req.params;

    const query = 'UPDATE super_admin_users SET is_active = 0 WHERE id = ?';

    connection.query(query, [user_id], (err) => {
      if (err) {
        return res.status(500).json({ success: false, error: 'Failed to delete user' });
      }

      res.json({ success: true, message: 'User deleted successfully' });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
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
        COUNT(DISTINCT u.id) as total_users,
        COUNT(DISTINCT b.id) as total_bills,
        SUM(b.bill_amount) as total_sales,
        AVG(b.bill_amount) as avg_bill_value,
        sp.name as subscription_plan
      FROM shops s
      LEFT JOIN users u ON s.id = u.shop_id
      LEFT JOIN bills b ON s.id = b.shop_id
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      WHERE s.is_active = 1
      GROUP BY s.id
      ORDER BY total_sales DESC
    `;

    connection.query(query, (err, results) => {
      if (err) {
        return res.status(500).json({ success: false, error: 'Failed to fetch comparison data' });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

/**
 * Get system health metrics
 */
exports.getSystemHealth = async (req, res) => {
  try {
    const queries = {
      totalShops: 'SELECT COUNT(*) as count FROM shops',
      activeUsers: 'SELECT COUNT(*) as count FROM users WHERE is_active = 1',
      dbSize: 'SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb FROM information_schema.TABLES WHERE table_schema = DATABASE()',
      todayBills: 'SELECT COUNT(*) as count FROM bills WHERE DATE(bill_date) = DATE(NOW())',
      todayRevenue: 'SELECT SUM(bill_amount) as total FROM bills WHERE DATE(bill_date) = DATE(NOW())',
    };

    const health = {};
    let completed = 0;

    Object.keys(queries).forEach(key => {
      connection.query(queries[key], (err, results) => {
        if (!err && results.length > 0) {
          const resultKey = Object.keys(results[0])[0];
          health[key] = results[0][resultKey];
        }
        completed++;

        if (completed === Object.keys(queries).length) {
          res.json({ success: true, data: health });
        }
      });
    });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Server error', details: error.message });
  }
};

// =====================================================
// HELPER FUNCTIONS
// =====================================================

/**
 * Log audit action
 */
function logAuditAction(shopId, userId, action, details) {
  try {
    const query = `
      INSERT INTO shop_audit_logs 
      (shop_id, user_id, action, details, created_at)
      VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
    `;

    connection.query(query, [shopId, userId, action, details], (err) => {
      if (err) {
        console.error('Error logging action:', err);
      }
    });
  } catch (error) {
    console.error('Audit logging error:', error);
  }
}

module.exports.exports = module.exports;
