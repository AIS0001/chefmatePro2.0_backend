/**
 * SHOP MANAGEMENT CONTROLLER
 * Handles shop-specific operations by shop owners/managers
 */

const { db } = require('../config/dbconnection');

const connection = {
  query: (sql, params, callback) => {
    let queryParams = params;
    let queryCallback = callback;

    if (typeof params === 'function') {
      queryCallback = params;
      queryParams = [];
    }

    if (typeof queryCallback === 'function') {
      db.query(sql, queryParams)
        .then(([rows]) => queryCallback(null, rows))
        .catch((err) => queryCallback(err));
      return;
    }

    return db.query(sql, queryParams).then(([rows]) => rows);
  },
};

const queryAsync = (sql, params = []) => new Promise((resolve, reject) => {
  connection.query(sql, params, (err, rows) => {
    if (err) return reject(err);
    resolve(rows);
  });
});

/**
 * Get current shop profile
 */
exports.getShopProfile = async (req, res) => {
  try {
    const shopId = req.shop_id;

    const query = `
      SELECT
        s.*,
        sp.name as plan_name,
        sp.price_per_month,
        sp.max_terminals,
        sp.max_users,
        sp.storage_quota_gb,
        0 as total_staff,
        0 as total_users
      FROM shops s
      LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
      WHERE s.id = ?
      LIMIT 1
    `;

    const results = await queryAsync(query, [shopId]);

    if (results.length === 0) {
      return res.status(404).json({ error: 'Shop not found' });
    }

    res.json({ success: true, data: results[0] });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch shop profile', details: error.message });
  }
};

/**
 * Update shop profile (by shop admin)
 */
exports.updateShopProfile = (req, res) => {
  try {
    const shopId = req.shop_id;
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
      shopId,
    ];

    connection.query(query, params, (err) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to update shop profile', details: err });
      }

      res.json({ success: true, message: 'Shop profile updated successfully' });
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get shop staff and users
 */
exports.getShopStaff = (req, res) => {
  try {
    const shopId = req.shop_id;
    const { role } = req.query;

    let query = `
      SELECT 
        u.id,
        u.username,
        u.email,
        u.first_name,
        u.last_name,
        u.phone_number,
        u.role,
        sa.role as shop_role,
        u.is_active,
        u.created_at,
        sa.assigned_at
      FROM users u
      LEFT JOIN shop_admins sa ON u.id = sa.user_id AND sa.shop_id = ?
      WHERE u.shop_id = ?
    `;

    const params = [shopId, shopId];

    if (role) {
      query += ' AND u.role = ?';
      params.push(role);
    }

    query += ' ORDER BY sa.assigned_at DESC, u.created_at DESC';

    connection.query(query, params, (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch staff', details: err });
      }

      res.json({ success: true, data: results });
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Add staff member to shop
 */
exports.addStaffMember = (req, res) => {
  try {
    const shopId = req.shop_id;
    const { user_id, role } = req.body;

    if (!user_id || !role) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if user exists and belongs to this shop
    const userCheckQuery = `SELECT id FROM users WHERE id = ? AND shop_id = ?`;
    connection.query(userCheckQuery, [user_id, shopId], (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'User not found in this shop' });
      }

      // Add to shop_admins
      const insertQuery = `
        INSERT INTO shop_admins (shop_id, user_id, role, assigned_by, is_active)
        VALUES (?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE role = ?, is_active = 1
      `;

      connection.query(insertQuery, [shopId, user_id, role, req.user.id, role], (insertErr) => {
        if (insertErr) {
          return res.status(500).json({ error: 'Failed to add staff', details: insertErr });
        }

        res.json({ success: true, message: 'Staff member added successfully' });
      });
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Remove staff member
 */
exports.removeStaffMember = (req, res) => {
  try {
    const shopId = req.shop_id;
    const { staff_id } = req.params;

    const query = 'DELETE FROM shop_admins WHERE shop_id = ? AND user_id = ?';

    connection.query(query, [shopId, staff_id], (err) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to remove staff', details: err });
      }

      res.json({ success: true, message: 'Staff member removed successfully' });
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get shop analytics/statistics
 */
exports.getShopAnalytics = (req, res) => {
  try {
    const shopId = req.shop_id;
    const { days = 30, metrics } = req.query;

    const analyticsQueries = {
      totalBills: `
        SELECT COUNT(*) as count, SUM(grand_total) as total_amount
        FROM bills
        WHERE shop_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
      `,
      topItems: `
        SELECT 
          oi.name,
          COUNT(*) as frequency,
          SUM(oi.total_price) as total_sales
        FROM order_items oi
        JOIN bills b ON oi.bill_id = b.id
        WHERE b.shop_id = ? AND b.created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
        GROUP BY oi.name
        ORDER BY total_sales DESC
        LIMIT 10
      `,
      dailyRevenue: `
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as orders,
          SUM(grand_total) as revenue
        FROM bills
        WHERE shop_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
        GROUP BY DATE(created_at)
        ORDER BY date ASC
      `,
      paymentMethods: `
        SELECT 
          payment_mode,
          COUNT(*) as count,
          SUM(grand_total) as total
        FROM bills
        WHERE shop_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
        GROUP BY payment_mode
      `,
    };

    const results = {};
    let completed = 0;
    let errors = [];

    const executeAnalyticsQuery = (metric) => {
      connection.query(analyticsQueries[metric], [shopId, parseInt(days)], (err, result) => {
        if (err) {
          errors.push({ metric, error: err.message });
        } else {
          results[metric] = result;
        }

        completed++;
        if (completed === Object.keys(analyticsQueries).length) {
          res.json({
            success: errors.length === 0,
            data: results,
            errors: errors.length > 0 ? errors : undefined,
          });
        }
      });
    };

    Object.keys(analyticsQueries).forEach(executeAnalyticsQuery);
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Update subscription plan
 */
exports.upgradeSubscription = (req, res) => {
  try {
    const shopId = req.shop_id;
    const { plan_id } = req.body;

    if (!plan_id) {
      return res.status(400).json({ error: 'Plan ID required' });
    }

    // Verify plan exists
    const planCheckQuery = 'SELECT * FROM subscription_plans WHERE id = ? AND is_active = 1';
    connection.query(planCheckQuery, [plan_id], (err, plans) => {
      if (err) {
        return res.status(500).json({ error: 'Database error', details: err });
      }

      if (plans.length === 0) {
        return res.status(404).json({ error: 'Plan not found' });
      }

      // Update shop subscription
      const updateQuery = `
        UPDATE shops SET 
          subscription_plan_id = ?,
          subscription_start_date = NOW(),
          subscription_end_date = DATE_ADD(NOW(), INTERVAL 1 YEAR),
          updated_by = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;

      connection.query(updateQuery, [plan_id, req.user.id, shopId], (updateErr) => {
        if (updateErr) {
          return res.status(500).json({ error: 'Failed to update subscription', details: updateErr });
        }

        res.json({
          success: true,
          message: 'Subscription plan updated successfully',
          plan: plans[0],
        });
      });
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

/**
 * Get subscription overview: plan info, payment summary, history
 */
exports.getSubscriptionOverview = async (req, res) => {
  try {
    const shopId = req.shop_id;
    const limit = Math.min(parseInt(req.query.limit, 10) || 50, 200);

    let shopRows = [];
    try {
      const shopQueryPrimary = `
        SELECT
          s.id AS shop_id,
          s.subscription_status AS shop_subscription_status,
          sp.name AS plan_name,
          sp.price_per_month,
          COALESCE(s.subscription_start_date, ss.start_date) AS start_date,
          COALESCE(s.subscription_end_date, ss.end_date) AS end_date,
          COALESCE(ss.subscription_type, 'MONTHLY') AS subscription_type,
          COALESCE(ss.renewal_date, s.subscription_end_date) AS renewal_date,
          CASE
            WHEN s.subscription_end_date IS NULL THEN 'N/A'
            WHEN s.subscription_end_date >= CURDATE() THEN 'ACTIVE'
            ELSE 'EXPIRED'
          END AS subscription_status
        FROM shops s
        LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
        LEFT JOIN shop_subscriptions ss ON ss.shop_id = s.id AND ss.status = 'ACTIVE'
        WHERE s.id = ?
        LIMIT 1
      `;
      shopRows = await queryAsync(shopQueryPrimary, [shopId]);
    } catch (primaryErr) {
      try {
        const shopQueryFallback = `
          SELECT
            s.id AS shop_id,
            NULL AS shop_subscription_status,
            sp.name AS plan_name,
            sp.price_per_month,
            s.subscription_start_date AS start_date,
            s.subscription_end_date AS end_date,
            'MONTHLY' AS subscription_type,
            s.subscription_end_date AS renewal_date,
            CASE
              WHEN s.subscription_end_date IS NULL THEN 'N/A'
              WHEN s.subscription_end_date >= CURDATE() THEN 'ACTIVE'
              ELSE 'EXPIRED'
            END AS subscription_status
          FROM shops s
          LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
          WHERE s.id = ?
          LIMIT 1
        `;
        shopRows = await queryAsync(shopQueryFallback, [shopId]);
      } catch (fallbackErr) {
        const shopQueryMinimal = `
          SELECT
            s.id AS shop_id,
            NULL AS shop_subscription_status,
            sp.name AS plan_name,
            sp.price_per_month,
            NULL AS start_date,
            NULL AS end_date,
            'MONTHLY' AS subscription_type,
            NULL AS renewal_date,
            'N/A' AS subscription_status
          FROM shops s
          LEFT JOIN subscription_plans sp ON s.subscription_plan_id = sp.id
          WHERE s.id = ?
          LIMIT 1
        `;
        shopRows = await queryAsync(shopQueryMinimal, [shopId]);
      }
    }

    const shopRow = shopRows[0] || {};

    let paymentSummary = {
      total_paid_amount: 0,
      paid_count: 0,
      total_unpaid_amount: 0,
      unpaid_count: 0,
      overdue_amount: 0,
    };
    let nextDueRows = [];
    let paymentHistory = [];

    try {
      const summaryRows = await queryAsync(
        `
          SELECT
            COALESCE(SUM(CASE WHEN payment_status = 'COMPLETED' THEN amount ELSE 0 END), 0) AS total_paid_amount,
            COUNT(CASE WHEN payment_status = 'COMPLETED' THEN 1 END) AS paid_count,
            COALESCE(SUM(CASE WHEN payment_status IN ('PENDING','FAILED','CANCELLED') THEN amount ELSE 0 END), 0) AS total_unpaid_amount,
            COUNT(CASE WHEN payment_status IN ('PENDING','FAILED','CANCELLED') THEN 1 END) AS unpaid_count,
            COALESCE(SUM(CASE WHEN payment_status IN ('PENDING','FAILED','CANCELLED') AND due_date < CURDATE() THEN amount ELSE 0 END), 0) AS overdue_amount
          FROM payment_records
          WHERE shop_id = ?
        `,
        [shopId]
      );
      paymentSummary = summaryRows[0] || paymentSummary;

      nextDueRows = await queryAsync(
        `
          SELECT id, amount, payment_status, due_date, payment_method, payment_type, reference_number
          FROM payment_records
          WHERE shop_id = ? AND payment_status IN ('PENDING','FAILED')
          ORDER BY due_date ASC
          LIMIT 1
        `,
        [shopId]
      );

      paymentHistory = await queryAsync(
        `
          SELECT id, amount, payment_status, due_date, paid_date, payment_method, payment_type, reference_number
          FROM payment_records
          WHERE shop_id = ?
          ORDER BY due_date DESC
          LIMIT ?
        `,
        [shopId, limit]
      );
    } catch (paymentErr) {
      // payment_records table or fields may not exist in some schema snapshots.
    }

    const nextDuePayment = nextDueRows[0] || (() => {
      const fallbackDueDate = shopRow.renewal_date || shopRow.end_date || null;
      if (!fallbackDueDate) return null;
      return {
        id: null,
        amount: shopRow.price_per_month || 0,
        payment_status: 'PENDING',
        due_date: fallbackDueDate,
        payment_method: null,
        payment_type: shopRow.subscription_type || 'MONTHLY',
        reference_number: null,
      };
    })();

    const normalizedStatus = String(shopRow.shop_subscription_status || '').trim().toUpperCase();
    const resolvedSubscriptionStatus = normalizedStatus || shopRow.subscription_status || 'N/A';

    res.json({
      success: true,
      data: {
        shop_id: shopId,
        subscription: {
          plan_name: shopRow.plan_name || null,
          price_per_month: shopRow.price_per_month || null,
          price_per_year: shopRow.price_per_month ? (shopRow.price_per_month * 12) : null,
          subscription_type: shopRow.subscription_type || null,
          start_date: shopRow.start_date || null,
          end_date: shopRow.end_date || null,
          renewal_date: shopRow.renewal_date || null,
          subscription_status: resolvedSubscriptionStatus,
        },
        payment_summary: paymentSummary,
        next_due_payment: nextDuePayment,
        payment_history: paymentHistory,
      },
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error', details: error.message });
  }
};

module.exports = exports;
