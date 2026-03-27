/**
 * PAYMENT & SUBSCRIPTION CONTROLLER
 * Manages subscription plans, payments, and billing for shops
 */

const { db } = require('../config/dbconnection');

const getSubscriptionPlanSchemaMeta = async (connection) => {
  const [columns] = await connection.query('SHOW COLUMNS FROM subscription_plans');
  const set = new Set((columns || []).map((col) => col.Field));

  const monthlyField = set.has('monthly_price') ? 'monthly_price' : (set.has('price_per_month') ? 'price_per_month' : null);
  const maxTablesField = set.has('max_tables') ? 'max_tables' : (set.has('max_terminals') ? 'max_terminals' : null);

  return {
    columns: set,
    monthlyField,
    maxTablesField,
    hasQuarterly: set.has('quarterly_price'),
    hasYearly: set.has('yearly_price')
  };
};

const normalizeDate = (dateValue) => {
  const date = new Date(dateValue);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString().split('T')[0];
};

const getPlanAmountByType = (planRow, subscriptionType) => {
  const type = String(subscriptionType || 'MONTHLY').toUpperCase();
  const monthly = Number(planRow?.monthly_price ?? planRow?.price_per_month ?? 0);
  const quarterly = Number(planRow?.quarterly_price ?? 0);
  const yearly = Number(planRow?.yearly_price ?? 0);

  if (type === 'YEARLY') return yearly > 0 ? yearly : monthly * 12;
  if (type === 'QUARTERLY') return quarterly > 0 ? quarterly : monthly * 3;
  return monthly;
};

const addBillingCycle = (baseDate, paymentType = 'MONTHLY') => {
  const date = new Date(baseDate);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  const normalizedType = String(paymentType || 'MONTHLY').toUpperCase();
  if (normalizedType === 'YEARLY') {
    date.setFullYear(date.getFullYear() + 1);
  } else if (normalizedType === 'QUARTERLY') {
    date.setMonth(date.getMonth() + 3);
  } else {
    date.setMonth(date.getMonth() + 1);
  }

  return normalizeDate(date);
};

const createNextCyclePaymentIfNeeded = async (connection, paymentRecord) => {
  if (!paymentRecord?.subscription_id) {
    return null;
  }

  const nextDueDate = addBillingCycle(paymentRecord.due_date || new Date(), paymentRecord.payment_type);
  if (!nextDueDate) {
    return null;
  }

  // Avoid duplicate next-cycle records for the same due date.
  const [existingNextCycle] = await connection.query(
    `SELECT id
     FROM payment_records
     WHERE shop_id = ?
       AND subscription_id = ?
       AND due_date = ?
       AND payment_status IN ('PENDING', 'FAILED', 'CANCELLED')
     LIMIT 1`,
    [paymentRecord.shop_id, paymentRecord.subscription_id, nextDueDate]
  );

  if (existingNextCycle && existingNextCycle.length > 0) {
    await connection.query(
      `UPDATE shop_subscriptions
       SET status = 'ACTIVE', renewal_date = ?, updated_at = NOW()
       WHERE id = ?`,
      [nextDueDate, paymentRecord.subscription_id]
    );
    return existingNextCycle[0].id;
  }

  const [nextPaymentResult] = await connection.query(
    `INSERT INTO payment_records (
      shop_id, subscription_id, amount, currency, payment_method, payment_status,
      due_date, payment_type, notes, created_by
    ) VALUES (?, ?, ?, ?, ?, 'PENDING', ?, ?, ?, ?)`,
    [
      paymentRecord.shop_id,
      paymentRecord.subscription_id,
      paymentRecord.amount,
      paymentRecord.currency || 'USD',
      paymentRecord.payment_method,
      nextDueDate,
      paymentRecord.payment_type || 'MONTHLY',
      `Auto-generated next cycle after payment #${paymentRecord.id} completion`,
      paymentRecord.created_by || null
    ]
  );

  await connection.query(
    `UPDATE shop_subscriptions
     SET status = 'ACTIVE', renewal_date = ?, updated_at = NOW()
     WHERE id = ?`,
    [nextDueDate, paymentRecord.subscription_id]
  );

  return nextPaymentResult.insertId;
};

// =====================================================
// SUBSCRIPTION PLANS CONTROLLER
// =====================================================

/**
 * Get all subscription plans
 */
exports.getSubscriptionPlans = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();

    const meta = await getSubscriptionPlanSchemaMeta(connection);
    const orderBy = meta.monthlyField || 'id';
    const query = `SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY ${orderBy} ASC`;
    const [results] = await connection.query(query);

    const normalizedPlans = (results || []).map((plan) => ({
      ...plan,
      monthly_price: Number(plan.monthly_price ?? plan.price_per_month ?? 0),
      quarterly_price: plan.quarterly_price != null ? Number(plan.quarterly_price) : null,
      yearly_price: plan.yearly_price != null ? Number(plan.yearly_price) : null,
      max_tables: plan.max_tables ?? plan.max_terminals ?? null
    }));

    res.status(200).json({
      success: true,
      data: normalizedPlans
    });

  } catch (error) {
    console.error('Error fetching subscription plans:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch subscription plans',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Create or update subscription plan
 */
exports.upsertSubscriptionPlan = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const planId = req.params.id || req.body.id;
    const {
      name,
      monthly_price,
      price_per_month,
      quarterly_price,
      yearly_price,
      max_users,
      max_tables,
      max_terminals,
      description
    } = req.body;

    const meta = await getSubscriptionPlanSchemaMeta(connection);

    if (!name) {
      return res.status(400).json({ success: false, error: 'Plan name is required' });
    }

    const monthlyValue = monthly_price ?? price_per_month ?? 0;
    const maxTablesValue = max_tables ?? max_terminals ?? 1;

    let result;
    if (planId) {
      // Update
      const updateFields = ['name = ?'];
      const updateParams = [name];

      if (meta.monthlyField) {
        updateFields.push(`${meta.monthlyField} = ?`);
        updateParams.push(monthlyValue);
      }
      if (meta.hasQuarterly) {
        updateFields.push('quarterly_price = ?');
        updateParams.push(quarterly_price ?? 0);
      }
      if (meta.hasYearly) {
        updateFields.push('yearly_price = ?');
        updateParams.push(yearly_price ?? 0);
      }
      if (meta.columns.has('max_users')) {
        updateFields.push('max_users = ?');
        updateParams.push(max_users ?? 1);
      }
      if (meta.maxTablesField) {
        updateFields.push(`${meta.maxTablesField} = ?`);
        updateParams.push(maxTablesValue);
      }
      if (meta.columns.has('description')) {
        updateFields.push('description = ?');
        updateParams.push(description ?? null);
      }

      const updateQuery = `UPDATE subscription_plans SET ${updateFields.join(', ')} WHERE id = ?`;
      updateParams.push(planId);
      [result] = await connection.query(updateQuery, updateParams);
    } else {
      // Create
      const columns = ['name'];
      const values = [name];

      if (meta.monthlyField) {
        columns.push(meta.monthlyField);
        values.push(monthlyValue);
      }
      if (meta.hasQuarterly) {
        columns.push('quarterly_price');
        values.push(quarterly_price ?? 0);
      }
      if (meta.hasYearly) {
        columns.push('yearly_price');
        values.push(yearly_price ?? 0);
      }
      if (meta.columns.has('max_users')) {
        columns.push('max_users');
        values.push(max_users ?? 1);
      }
      if (meta.maxTablesField) {
        columns.push(meta.maxTablesField);
        values.push(maxTablesValue);
      }
      if (meta.columns.has('description')) {
        columns.push('description');
        values.push(description ?? null);
      }

      const placeholders = columns.map(() => '?').join(', ');
      const insertQuery = `INSERT INTO subscription_plans (${columns.join(', ')}) VALUES (${placeholders})`;
      [result] = await connection.query(insertQuery, values);
    }

    res.status(200).json({
      success: true,
      message: planId ? 'Plan updated successfully' : 'Plan created successfully',
      plan_id: planId || result.insertId
    });

  } catch (error) {
    console.error('Error upserting plan:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to save plan',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// =====================================================
// SHOP SUBSCRIPTIONS CONTROLLER
// =====================================================

/**
 * Get shop subscription
 */
exports.getShopSubscription = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { shop_id } = req.params;

    const query = `
      SELECT ss.*, sp.name as plan_name, sp.monthly_price, sp.quarterly_price, sp.yearly_price
      FROM shop_subscriptions ss
      JOIN subscription_plans sp ON ss.plan_id = sp.id
      WHERE ss.shop_id = ?
      ORDER BY ss.id DESC
      LIMIT 1
    `;

    const [results] = await connection.query(query, [shop_id]);

    if (!results || results.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'No active subscription found'
      });
    }

    res.status(200).json({
      success: true,
      data: results[0]
    });

  } catch (error) {
    console.error('Error fetching shop subscription:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch subscription',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get all shop subscriptions with shop and latest payment snapshot
 */
exports.getAllShopSubscriptions = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { status } = req.query;
    const meta = await getSubscriptionPlanSchemaMeta(connection);
    const monthlyExpr = meta.monthlyField ? `COALESCE(sp.${meta.monthlyField}, 0)` : '0';
    const quarterlyExpr = meta.hasQuarterly ? 'COALESCE(sp.quarterly_price, 0)' : '0';
    const yearlyExpr = meta.hasYearly ? 'COALESCE(sp.yearly_price, 0)' : '0';

    let query = `
      SELECT
        ss.*,
        s.name as shop_name,
        sp.name as plan_name,
        ${monthlyExpr} as monthly_price,
        ${quarterlyExpr} as quarterly_price,
        ${yearlyExpr} as yearly_price,
        pr.id as latest_payment_id,
        pr.payment_status as latest_payment_status,
        pr.due_date as latest_due_date,
        pr.amount as latest_amount
      FROM shop_subscriptions ss
      LEFT JOIN shops s ON ss.shop_id = s.id
      LEFT JOIN subscription_plans sp ON ss.plan_id = sp.id
      LEFT JOIN payment_records pr ON pr.id = (
        SELECT p2.id
        FROM payment_records p2
        WHERE p2.subscription_id = ss.id
        ORDER BY p2.due_date DESC, p2.id DESC
        LIMIT 1
      )
      WHERE 1=1
    `;

    const params = [];
    if (status) {
      query += ' AND ss.status = ?';
      params.push(status);
    }

    query += ' ORDER BY ss.updated_at DESC, ss.id DESC';
    const [results] = await connection.query(query, params);

    res.status(200).json({
      success: true,
      data: results
    });
  } catch (error) {
    console.error('Error fetching subscriptions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch subscriptions',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Create or update shop subscription
 */
exports.upsertShopSubscription = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { plan_id, subscription_type, start_date, end_date, renewal_date, auto_create_payment = false } = req.body;
    const shop_id = req.body.shop_id || req.params.shop_id;

    if (!shop_id || !plan_id || !subscription_type) {
      return res.status(400).json({
        success: false,
        error: 'shop_id, plan_id, and subscription_type are required'
      });
    }

    // Calculate dates if not provided
    let actualStart = start_date ? new Date(start_date) : new Date();
    let actualEnd = end_date ? new Date(end_date) : new Date();
    
    if (!end_date) {
      if (subscription_type === 'MONTHLY') {
        actualEnd.setMonth(actualEnd.getMonth() + 1);
      } else if (subscription_type === 'QUARTERLY') {
        actualEnd.setMonth(actualEnd.getMonth() + 3);
      } else if (subscription_type === 'YEARLY') {
        actualEnd.setFullYear(actualEnd.getFullYear() + 1);
      }
    }

    let actualRenewal = renewal_date ? new Date(renewal_date) : actualEnd;

    const [planRows] = await connection.query('SELECT * FROM subscription_plans WHERE id = ? LIMIT 1', [plan_id]);
    if (!planRows || planRows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid subscription plan selected'
      });
    }
    const selectedPlan = planRows[0];

    // Check for existing subscription
    const existingQuery = 'SELECT id FROM shop_subscriptions WHERE shop_id = ? AND status = "ACTIVE"';
    const [existing] = await connection.query(existingQuery, [shop_id]);

    let result;
    const normalizedStartDate = actualStart.toISOString().split('T')[0];
    const normalizedEndDate = actualEnd.toISOString().split('T')[0];
    const normalizedRenewalDate = actualRenewal.toISOString().split('T')[0];

    let subscriptionId;
    if (existing && existing.length > 0) {
      // Update existing
      const updateQuery = `
        UPDATE shop_subscriptions 
        SET plan_id = ?, subscription_type = ?, start_date = ?, end_date = ?, renewal_date = ?
        WHERE shop_id = ? AND status = "ACTIVE"
      `;
      [result] = await connection.query(updateQuery, [
        plan_id, subscription_type, 
        normalizedStartDate,
        normalizedEndDate,
        normalizedRenewalDate,
        shop_id
      ]);
      subscriptionId = existing[0].id;
    } else {
      // Create new
      const insertQuery = `
        INSERT INTO shop_subscriptions (shop_id, plan_id, subscription_type, start_date, end_date, renewal_date)
        VALUES (?, ?, ?, ?, ?, ?)
      `;
      [result] = await connection.query(insertQuery, [
        shop_id, plan_id, subscription_type,
        normalizedStartDate,
        normalizedEndDate,
        normalizedRenewalDate
      ]);
      subscriptionId = result.insertId;
    }

    let createdPaymentId = null;
    if (auto_create_payment) {
      const [existingPendingPayment] = await connection.query(
        `SELECT id
         FROM payment_records
         WHERE shop_id = ?
           AND subscription_id = ?
           AND due_date = ?
           AND payment_status IN ('PENDING', 'FAILED', 'CANCELLED')
         LIMIT 1`,
        [shop_id, subscriptionId, normalizedRenewalDate]
      );

      if (!existingPendingPayment || existingPendingPayment.length === 0) {
        const defaultAmount = getPlanAmountByType(selectedPlan, subscription_type);
        const [createdPayment] = await connection.query(
          `INSERT INTO payment_records (
            shop_id, subscription_id, amount, payment_method, payment_status,
            due_date, payment_type, notes
          ) VALUES (?, ?, ?, ?, 'PENDING', ?, ?, ?)`,
          [
            shop_id,
            subscriptionId,
            defaultAmount,
            'BANK_TRANSFER',
            normalizedRenewalDate,
            subscription_type,
            'Auto-created while assigning subscription plan'
          ]
        );
        createdPaymentId = createdPayment.insertId;
      } else {
        createdPaymentId = existingPendingPayment[0].id;
      }
    }

    res.status(200).json({
      success: true,
      message: existing && existing.length > 0 ? 'Subscription updated' : 'Subscription created',
      subscription_id: subscriptionId,
      payment_id: createdPaymentId
    });

  } catch (error) {
    console.error('Error upserting subscription:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to save subscription',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// =====================================================
// PAYMENT RECORDS CONTROLLER
// =====================================================

/**
 * Get all payment records with filters
 */
exports.getPaymentRecords = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { shop_id, payment_status, page = 1, limit = 20 } = req.query;

    let query = 'SELECT * FROM payment_records WHERE 1=1';
    const params = [];

    if (shop_id) {
      query += ' AND shop_id = ?';
      params.push(shop_id);
    }

    if (payment_status) {
      query += ' AND payment_status = ?';
      params.push(payment_status);
    }

    // Get total count
    const countQuery = query.replace(/SELECT \*/, 'SELECT COUNT(*) as total');
    const [countResults] = await connection.query(countQuery, params);
    const total = countResults[0].total;

    // Get paginated results
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const finalQuery = query + ' ORDER BY due_date DESC LIMIT ? OFFSET ?';
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
    console.error('Error fetching payment records:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch payment records',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get shop payment history
 */
exports.getShopPaymentHistory = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { shop_id } = req.params;
    const { limit = 12 } = req.query;

    const query = `
      SELECT * FROM payment_records 
      WHERE shop_id = ? 
      ORDER BY due_date DESC
      LIMIT ?
    `;

    const [results] = await connection.query(query, [shop_id, parseInt(limit)]);

    res.status(200).json({
      success: true,
      data: results
    });

  } catch (error) {
    console.error('Error fetching payment history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch payment history',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Create payment record
 */
exports.createPaymentRecord = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const {
      shop_id,
      subscription_id,
      amount,
      payment_method,
      due_date,
      payment_type = 'MONTHLY',
      notes,
      reference_number,
      payment_status = 'PENDING',
      paid_date,
      transaction_id,
      created_by
    } = req.body;

    if (!shop_id || !amount || !payment_method || !due_date) {
      return res.status(400).json({
        success: false,
        error: 'shop_id, amount, payment_method, and due_date are required'
      });
    }

    // Resolve subscription from active record if not explicitly provided.
    let resolvedSubscriptionId = subscription_id;
    if (!resolvedSubscriptionId) {
      const [activeSubs] = await connection.query(
        `SELECT id
         FROM shop_subscriptions
         WHERE shop_id = ? AND status = 'ACTIVE'
         ORDER BY id DESC
         LIMIT 1`,
        [shop_id]
      );
      resolvedSubscriptionId = activeSubs?.[0]?.id || null;
    }

    const normalizedStatus = String(payment_status || 'PENDING').toUpperCase();
    const finalPaidDate = normalizedStatus === 'COMPLETED'
      ? (paid_date || normalizeDate(new Date()))
      : null;

    const query = `
      INSERT INTO payment_records (
        shop_id, subscription_id, amount, payment_method, due_date,
        payment_type, notes, reference_number, payment_status, paid_date, transaction_id, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const [result] = await connection.query(query, [
      shop_id,
      resolvedSubscriptionId,
      amount,
      payment_method,
      due_date,
      payment_type,
      notes,
      reference_number,
      normalizedStatus,
      finalPaidDate,
      transaction_id || null,
      created_by || null
    ]);

    let nextPaymentId = null;
    if (normalizedStatus === 'COMPLETED') {
      const [newPaymentRows] = await connection.query('SELECT * FROM payment_records WHERE id = ? LIMIT 1', [result.insertId]);
      if (newPaymentRows && newPaymentRows.length > 0) {
        nextPaymentId = await createNextCyclePaymentIfNeeded(connection, newPaymentRows[0]);
      }
    }

    res.status(201).json({
      success: true,
      message: 'Payment record created successfully',
      payment_id: result.insertId,
      next_payment_id: nextPaymentId
    });

  } catch (error) {
    console.error('Error creating payment record:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create payment record',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Update payment record status (mark as paid, failed, etc.)
 */
exports.updatePaymentStatus = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { id } = req.params;
    const { payment_status, paid_date, transaction_id, notes } = req.body;

    if (!payment_status) {
      return res.status(400).json({
        success: false,
        error: 'payment_status is required'
      });
    }

    const normalizedStatus = String(payment_status).toUpperCase();

    const [existingPaymentRows] = await connection.query(
      'SELECT * FROM payment_records WHERE id = ? LIMIT 1',
      [id]
    );

    if (!existingPaymentRows || existingPaymentRows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Payment record not found'
      });
    }

    const existingPayment = existingPaymentRows[0];
    const wasAlreadyCompleted = String(existingPayment.payment_status || '').toUpperCase() === 'COMPLETED';

    let query = 'UPDATE payment_records SET payment_status = ?';
    const params = [normalizedStatus];

    if (paid_date || normalizedStatus === 'COMPLETED') {
      query += ', paid_date = ?';
      params.push(paid_date || normalizeDate(new Date()));
    }

    if (transaction_id) {
      query += ', transaction_id = ?';
      params.push(transaction_id);
    }

    if (notes) {
      query += ', notes = ?';
      params.push(notes);
    }

    query += ' WHERE id = ?';
    params.push(id);

    const [result] = await connection.query(query, params);

    // If payment completed, activate subscription
    let nextPaymentId = null;
    if (normalizedStatus === 'COMPLETED') {
      const [updatedPaymentRows] = await connection.query('SELECT * FROM payment_records WHERE id = ? LIMIT 1', [id]);
      const updatedPayment = updatedPaymentRows?.[0];

      if (updatedPayment?.subscription_id) {
        await connection.query(
          `UPDATE shop_subscriptions
           SET status = 'ACTIVE', updated_at = NOW()
           WHERE id = ?`,
          [updatedPayment.subscription_id]
        );
      }

      if (!wasAlreadyCompleted && updatedPayment) {
        nextPaymentId = await createNextCyclePaymentIfNeeded(connection, updatedPayment);
      }
    }

    res.status(200).json({
      success: true,
      message: 'Payment status updated successfully',
      next_payment_id: nextPaymentId
    });

  } catch (error) {
    console.error('Error updating payment status:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update payment status',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

// =====================================================
// PAYMENT STATUS CHECK FOR LOGIN
// =====================================================

/**
 * Check if shop has active subscription and payment is paid
 * Returns: { isActive: true/false, message: string }
 */
exports.checkShopPaymentStatus = async (shop_id) => {
  try {
    const [subscriptionRows] = await db.query(
      `SELECT id, renewal_date, status
       FROM shop_subscriptions
       WHERE shop_id = ?
       ORDER BY id DESC
       LIMIT 1`,
      [shop_id]
    );

    if (!subscriptionRows || subscriptionRows.length === 0) {
      // Trial grace period for newly created shops with no configured subscription yet.
      const [shopRows] = await db.query('SELECT id, created_at FROM shops WHERE id = ? LIMIT 1', [shop_id]);
      const shop = shopRows?.[0];
      const trialDays = Number(process.env.DEFAULT_SUBSCRIPTION_TRIAL_DAYS || 14);

      if (shop?.created_at) {
        const createdAt = new Date(shop.created_at);
        const trialEndsAt = new Date(createdAt);
        trialEndsAt.setDate(trialEndsAt.getDate() + trialDays);

        if (trialEndsAt > new Date()) {
          return {
            isActive: true,
            status: 'TRIAL',
            message: `Trial access active until ${trialEndsAt.toDateString()}`,
            trialEndsAt: normalizeDate(trialEndsAt)
          };
        }
      }

      return {
        isActive: false,
        status: 'NO_SUBSCRIPTION',
        message: 'No active subscription found. Please assign a subscription plan from Super Admin > Payment.'
      };
    }

    const subscription = subscriptionRows[0];

    if (subscription.status === 'SUSPENDED') {
      return {
        isActive: false,
        status: 'SUSPENDED',
        message: 'Subscription is suspended. Contact support to resume.'
      };
    }

    if (subscription.status === 'CANCELLED') {
      return {
        isActive: false,
        status: 'CANCELLED',
        message: 'Subscription is cancelled. Please renew to continue.'
      };
    }

    if (subscription.status === 'EXPIRED') {
      return {
        isActive: false,
        status: 'EXPIRED',
        message: 'Subscription is expired. Please renew to continue.'
      };
    }

    const [overdueRows] = await db.query(
      `SELECT id, due_date, payment_status
       FROM payment_records
       WHERE shop_id = ?
         AND subscription_id = ?
         AND payment_status IN ('PENDING', 'FAILED', 'CANCELLED')
         AND due_date <= CURDATE()
       ORDER BY due_date ASC, id ASC
       LIMIT 1`,
      [shop_id, subscription.id]
    );

    if (overdueRows && overdueRows.length > 0) {
      const dueDate = overdueRows[0].due_date;
      return {
        isActive: false,
        status: 'PAYMENT_OVERDUE',
        message: `Payment overdue since ${new Date(dueDate).toDateString()}. Please pay subscription fee to continue.`,
        dueDate
      };
    }

    const [latestPaymentRows] = await db.query(
      `SELECT id, payment_status, due_date
       FROM payment_records
       WHERE shop_id = ?
         AND subscription_id = ?
       ORDER BY due_date DESC, id DESC
       LIMIT 1`,
      [shop_id, subscription.id]
    );

    const latestPayment = latestPaymentRows?.[0];

    if (latestPayment && String(latestPayment.payment_status || '').toUpperCase() !== 'COMPLETED') {
      const latestDueDate = latestPayment.due_date ? new Date(latestPayment.due_date) : null;
      const today = new Date();

      if (latestDueDate && latestDueDate <= today) {
        return {
          isActive: false,
          status: 'PAYMENT_PENDING',
          message: `Payment is pending. Due date: ${new Date(latestPayment.due_date).toDateString()}`,
          dueDate: latestPayment.due_date
        };
      }
    }

    if (!latestPayment && subscription.renewal_date && new Date(subscription.renewal_date) <= new Date()) {
      return {
        isActive: false,
        status: 'PAYMENT_OVERDUE',
        message: `Payment overdue since ${new Date(subscription.renewal_date).toDateString()}. Please pay subscription fee to continue.`,
        dueDate: subscription.renewal_date
      };
    }

    return {
      isActive: true,
      status: 'ACTIVE',
      message: 'Subscription is active',
      renewalDate: subscription.renewal_date,
      nextDueDate: latestPayment?.due_date || subscription.renewal_date
    };

  } catch (error) {
    console.error('Error checking payment status:', error);
    return {
      isActive: false,
      status: 'ERROR',
      message: 'Error checking subscription status'
    };
  }
};

// =====================================================
// ANALYTICS & REPORTING
// =====================================================

/**
 * Get payment statistics
 */
exports.getPaymentStats = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { shop_id } = req.query;

    let whereClause = '1=1';
    const params = [];

    if (shop_id) {
      whereClause += ' AND shop_id = ?';
      params.push(shop_id);
    }

    const query = `
      SELECT 
        COUNT(*) as total_payments,
        SUM(CASE WHEN payment_status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_payments,
        SUM(CASE WHEN payment_status = 'PENDING' THEN 1 ELSE 0 END) as pending_payments,
        SUM(CASE WHEN payment_status = 'OVERDUE' THEN 1 ELSE 0 END) as overdue_payments,
        SUM(CASE WHEN payment_status = 'COMPLETED' THEN amount ELSE 0 END) as total_collected,
        SUM(CASE WHEN payment_status != 'COMPLETED' THEN amount ELSE 0 END) as total_pending
      FROM payment_records
      WHERE ${whereClause}
    `;

    const [results] = await connection.query(query, params);

    res.status(200).json({
      success: true,
      data: results[0] || {}
    });

  } catch (error) {
    console.error('Error getting payment stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get statistics',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};

/**
 * Get overdue payments
 */
exports.getOverduePayments = async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    const { page = 1, limit = 20 } = req.query;

    const query = `
      SELECT 
        pr.*,
        s.name as shop_name,
        DATEDIFF(CURDATE(), pr.due_date) as days_overdue
      FROM payment_records pr
      JOIN shops s ON pr.shop_id = s.id
      WHERE pr.payment_status IN ('PENDING', 'FAILED')
        AND pr.due_date < CURDATE()
      ORDER BY pr.due_date ASC
      LIMIT ? OFFSET ?
    `;

    const offset = (parseInt(page) - 1) * parseInt(limit);
    const [results] = await connection.query(query, [parseInt(limit), offset]);

    // Get count
    const countQuery = `
      SELECT COUNT(*) as total FROM payment_records 
      WHERE payment_status IN ('PENDING', 'FAILED')
        AND due_date < CURDATE()
    `;
    const [countResults] = await connection.query(countQuery);

    res.status(200).json({
      success: true,
      data: results,
      pagination: {
        total: countResults[0].total,
        page: parseInt(page),
        limit: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Error getting overdue payments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get overdue payments',
      details: error.message
    });
  } finally {
    if (connection) connection.release();
  }
};
