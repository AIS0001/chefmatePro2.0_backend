const { db } = require('../config/dbconnection');
const { requireShopId } = require('../helpers/shopScope');

let loyaltyTablesReady = false;

const getCreatedBy = (req) =>
  req?.user?.uname || req?.user?.name || req?.user?.email || 'system';

const toInt = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? Math.floor(parsed) : fallback;
};

const toNumber = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const normalizeProgramName = (value) => String(value || '').trim();

const ensureColumn = async (tableName, columnName, definitionSql) => {
  const [rows] = await db.query(
    `
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = ?
        AND COLUMN_NAME = ?
      LIMIT 1
    `,
    [tableName, columnName]
  );

  if (!rows.length) {
    await db.query(`ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${definitionSql}`);
  }
};

const ensureLoyaltyTables = async () => {
  if (loyaltyTablesReady) return;

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_members (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      customer_id INT NOT NULL,
      loyalty_code VARCHAR(64) NOT NULL,
      tier_name VARCHAR(50) NOT NULL DEFAULT 'Basic',
      points_balance INT NOT NULL DEFAULT 0,
      lifetime_points INT NOT NULL DEFAULT 0,
      status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
      enrolled_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uniq_loyalty_member (shop_id, customer_id),
      UNIQUE KEY uniq_loyalty_code (shop_id, loyalty_code),
      KEY idx_loyalty_members_shop (shop_id),
      KEY idx_loyalty_members_customer (customer_id),
      CONSTRAINT fk_loyalty_members_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_programs (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      program_name VARCHAR(120) NOT NULL,
      description TEXT NULL,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      earn_spend_amount DECIMAL(10,2) NOT NULL DEFAULT 20.00,
      earn_points INT NOT NULL DEFAULT 1,
      redeem_points_required INT NOT NULL DEFAULT 100,
      redeem_value DECIMAL(10,2) NOT NULL DEFAULT 50.00,
      minimum_redeem_points INT NOT NULL DEFAULT 100,
      expiry_months INT NOT NULL DEFAULT 6,
      birthday_reward_type ENUM('NONE', 'FREE_DESSERT', 'COUPON', 'CUSTOM') NOT NULL DEFAULT 'FREE_DESSERT',
      birthday_reward_value VARCHAR(255) NULL,
      created_by VARCHAR(120) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_loyalty_programs_shop (shop_id),
      KEY idx_loyalty_programs_active (shop_id, is_active)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_member_programs (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      program_id INT NOT NULL,
      member_id INT NOT NULL,
      points_balance INT NOT NULL DEFAULT 0,
      lifetime_points INT NOT NULL DEFAULT 0,
      status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
      enrolled_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      last_activity_at TIMESTAMP NULL DEFAULT NULL,
      expires_at DATETIME NULL DEFAULT NULL,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uniq_loyalty_member_program (shop_id, program_id, member_id),
      KEY idx_loyalty_member_program_shop (shop_id),
      KEY idx_loyalty_member_program_program (program_id),
      KEY idx_loyalty_member_program_member (member_id),
      CONSTRAINT fk_loyalty_member_program_program FOREIGN KEY (program_id) REFERENCES loyalty_programs(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_member_program_member FOREIGN KEY (member_id) REFERENCES loyalty_members(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_offers (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      program_id INT NOT NULL,
      offer_name VARCHAR(150) NOT NULL,
      offer_type ENUM('DISCOUNT_AMOUNT', 'DISCOUNT_PERCENT', 'FREE_ITEM') NOT NULL,
      points_required INT NOT NULL,
      discount_amount DECIMAL(10,2) NULL,
      discount_percent DECIMAL(8,2) NULL,
      free_item_id INT NULL,
      free_item_name VARCHAR(120) NULL,
      min_bill_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
      max_discount_amount DECIMAL(10,2) NULL,
      offer_description TEXT NULL,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      start_at DATETIME NULL,
      end_at DATETIME NULL,
      created_by VARCHAR(120) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_loyalty_offers_shop (shop_id),
      KEY idx_loyalty_offers_program (program_id),
      KEY idx_loyalty_offers_active (is_active),
      CONSTRAINT fk_loyalty_offers_program FOREIGN KEY (program_id) REFERENCES loyalty_programs(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_redemptions (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      program_id INT NOT NULL,
      member_program_id INT NOT NULL,
      member_id INT NOT NULL,
      customer_id INT NOT NULL,
      bill_id INT NULL,
      offer_id INT NULL,
      offer_name VARCHAR(150) NULL,
      offer_type VARCHAR(40) NULL,
      points_used INT NOT NULL,
      discount_value DECIMAL(10,2) NOT NULL DEFAULT 0,
      free_item_name VARCHAR(120) NULL,
      note VARCHAR(255) NULL,
      created_by VARCHAR(120) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_loyalty_redemptions_shop (shop_id),
      KEY idx_loyalty_redemptions_member (member_id),
      KEY idx_loyalty_redemptions_customer (customer_id),
      KEY idx_loyalty_redemptions_bill (bill_id),
      CONSTRAINT fk_loyalty_redemptions_program FOREIGN KEY (program_id) REFERENCES loyalty_programs(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_redemptions_member_program FOREIGN KEY (member_program_id) REFERENCES loyalty_member_programs(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_redemptions_member FOREIGN KEY (member_id) REFERENCES loyalty_members(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_redemptions_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_redemptions_offer FOREIGN KEY (offer_id) REFERENCES loyalty_offers(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_notification_queue (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      member_id INT NOT NULL,
      customer_id INT NOT NULL,
      channel ENUM('LINE', 'SMS') NOT NULL DEFAULT 'LINE',
      template_key VARCHAR(100) NOT NULL,
      message TEXT NOT NULL,
      status ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
      payload_json JSON NULL,
      error_message VARCHAR(255) NULL,
      sent_at DATETIME NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_loyalty_notification_shop (shop_id),
      KEY idx_loyalty_notification_status (status),
      KEY idx_loyalty_notification_customer (customer_id),
      CONSTRAINT fk_loyalty_notification_member FOREIGN KEY (member_id) REFERENCES loyalty_members(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_notification_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS loyalty_transactions (
      id INT NOT NULL AUTO_INCREMENT,
      shop_id INT NOT NULL,
      member_id INT NOT NULL,
      customer_id INT NOT NULL,
      bill_id INT NULL,
      transaction_type ENUM('EARN', 'REDEEM', 'ADJUST') NOT NULL,
      points_delta INT NOT NULL,
      note VARCHAR(255) NULL,
      created_by VARCHAR(120) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_loyalty_tx_shop (shop_id),
      KEY idx_loyalty_tx_member (member_id),
      KEY idx_loyalty_tx_customer (customer_id),
      KEY idx_loyalty_tx_bill (bill_id),
      CONSTRAINT fk_loyalty_tx_member FOREIGN KEY (member_id) REFERENCES loyalty_members(id) ON DELETE CASCADE,
      CONSTRAINT fk_loyalty_tx_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  await ensureColumn('loyalty_transactions', 'program_id', 'INT NULL AFTER customer_id');
  await ensureColumn('loyalty_transactions', 'member_program_id', 'INT NULL AFTER program_id');
  await ensureColumn('loyalty_transactions', 'offer_id', 'INT NULL AFTER bill_id');
  await ensureColumn('loyalty_transactions', 'offer_name', 'VARCHAR(150) NULL AFTER offer_id');

  loyaltyTablesReady = true;
};

const getOrCreateDefaultProgram = async (connection, shopId, req) => {
  const [rows] = await connection.query(
    `
      SELECT *
      FROM loyalty_programs
      WHERE shop_id = ? AND is_active = 1
      ORDER BY id ASC
      LIMIT 1
    `,
    [shopId]
  );

  if (rows.length) return rows[0];

  const [insertResult] = await connection.query(
    `
      INSERT INTO loyalty_programs (
        shop_id,
        program_name,
        description,
        is_active,
        earn_spend_amount,
        earn_points,
        redeem_points_required,
        redeem_value,
        minimum_redeem_points,
        expiry_months,
        birthday_reward_type,
        birthday_reward_value,
        created_by
      ) VALUES (?, ?, ?, 1, 20.00, 1, 100, 50.00, 100, 6, 'FREE_DESSERT', 'Free dessert', ?)
    `,
    [
      shopId,
      'Starter Program',
      'Recommended starter setup for small restaurants',
      getCreatedBy(req),
    ]
  );

  const [createdRows] = await connection.query(
    'SELECT * FROM loyalty_programs WHERE id = ? LIMIT 1',
    [insertResult.insertId]
  );

  return createdRows[0];
};

const ensureMemberProgram = async (connection, shopId, memberId, programId, expiryMonths = 6) => {
  const [rows] = await connection.query(
    `
      SELECT *
      FROM loyalty_member_programs
      WHERE shop_id = ? AND member_id = ? AND program_id = ?
      LIMIT 1
    `,
    [shopId, memberId, programId]
  );

  if (rows.length) return rows[0];

  await connection.query(
    `
      INSERT INTO loyalty_member_programs (
        shop_id,
        program_id,
        member_id,
        points_balance,
        lifetime_points,
        status,
        enrolled_on,
        expires_at
      ) VALUES (?, ?, ?, 0, 0, 'active', NOW(), DATE_ADD(NOW(), INTERVAL ? MONTH))
    `,
    [shopId, programId, memberId, expiryMonths]
  );

  const [createdRows] = await connection.query(
    `
      SELECT *
      FROM loyalty_member_programs
      WHERE shop_id = ? AND member_id = ? AND program_id = ?
      LIMIT 1
    `,
    [shopId, memberId, programId]
  );

  return createdRows[0];
};

const queueLoyaltyLineNotification = async (
  connection,
  { shopId, memberId, customerId, templateKey, message, payload = null }
) => {
  await connection.query(
    `
      INSERT INTO loyalty_notification_queue (
        shop_id,
        member_id,
        customer_id,
        channel,
        template_key,
        message,
        status,
        payload_json
      ) VALUES (?, ?, ?, 'LINE', ?, ?, 'PENDING', ?)
    `,
    [shopId, memberId, customerId, templateKey, message, payload ? JSON.stringify(payload) : null]
  );
};

const getLoyaltyPrograms = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const [rows] = await db.query(
      `
        SELECT *
        FROM loyalty_programs
        WHERE shop_id = ?
        ORDER BY is_active DESC, id DESC
      `,
      [shopId]
    );

    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Error fetching loyalty programs:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch loyalty programs' });
  }
};

const createLoyaltyProgram = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const programName = normalizeProgramName(req.body?.program_name);
    if (!programName) {
      return res.status(400).json({ success: false, message: 'program_name is required' });
    }

    const payload = {
      description: String(req.body?.description || '').trim() || null,
      isActive: req.body?.is_active === undefined ? 1 : (req.body.is_active ? 1 : 0),
      earnSpendAmount: toNumber(req.body?.earn_spend_amount, 20),
      earnPoints: Math.max(toInt(req.body?.earn_points, 1), 1),
      redeemPointsRequired: Math.max(toInt(req.body?.redeem_points_required, 100), 1),
      redeemValue: toNumber(req.body?.redeem_value, 50),
      minimumRedeemPoints: Math.max(toInt(req.body?.minimum_redeem_points, 100), 1),
      expiryMonths: Math.max(toInt(req.body?.expiry_months, 6), 1),
      birthdayRewardType: String(req.body?.birthday_reward_type || 'FREE_DESSERT'),
      birthdayRewardValue: String(req.body?.birthday_reward_value || 'Free dessert'),
    };

    const [result] = await connection.query(
      `
        INSERT INTO loyalty_programs (
          shop_id,
          program_name,
          description,
          is_active,
          earn_spend_amount,
          earn_points,
          redeem_points_required,
          redeem_value,
          minimum_redeem_points,
          expiry_months,
          birthday_reward_type,
          birthday_reward_value,
          created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        shopId,
        programName,
        payload.description,
        payload.isActive,
        payload.earnSpendAmount,
        payload.earnPoints,
        payload.redeemPointsRequired,
        payload.redeemValue,
        payload.minimumRedeemPoints,
        payload.expiryMonths,
        payload.birthdayRewardType,
        payload.birthdayRewardValue,
        getCreatedBy(req),
      ]
    );

    const [rows] = await connection.query('SELECT * FROM loyalty_programs WHERE id = ? LIMIT 1', [result.insertId]);
    return res.status(201).json({ success: true, data: rows[0] });
  } catch (error) {
    console.error('Error creating loyalty program:', error);
    return res.status(500).json({ success: false, message: 'Failed to create loyalty program' });
  } finally {
    connection.release();
  }
};

const updateLoyaltyProgram = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const programId = toInt(req.params.program_id, 0);
    if (!programId) {
      return res.status(400).json({ success: false, message: 'program_id is required' });
    }

    const [existingRows] = await connection.query(
      'SELECT * FROM loyalty_programs WHERE id = ? AND shop_id = ? LIMIT 1',
      [programId, shopId]
    );

    if (!existingRows.length) {
      return res.status(404).json({ success: false, message: 'Loyalty program not found' });
    }

    const existing = existingRows[0];

    const updates = {
      programName: normalizeProgramName(req.body?.program_name) || existing.program_name,
      description: req.body?.description !== undefined ? (String(req.body.description || '').trim() || null) : existing.description,
      isActive: req.body?.is_active !== undefined ? (req.body.is_active ? 1 : 0) : existing.is_active,
      earnSpendAmount: req.body?.earn_spend_amount !== undefined ? toNumber(req.body.earn_spend_amount, existing.earn_spend_amount) : existing.earn_spend_amount,
      earnPoints: req.body?.earn_points !== undefined ? Math.max(toInt(req.body.earn_points, existing.earn_points), 1) : existing.earn_points,
      redeemPointsRequired: req.body?.redeem_points_required !== undefined
        ? Math.max(toInt(req.body.redeem_points_required, existing.redeem_points_required), 1)
        : existing.redeem_points_required,
      redeemValue: req.body?.redeem_value !== undefined ? toNumber(req.body.redeem_value, existing.redeem_value) : existing.redeem_value,
      minimumRedeemPoints: req.body?.minimum_redeem_points !== undefined
        ? Math.max(toInt(req.body.minimum_redeem_points, existing.minimum_redeem_points), 1)
        : existing.minimum_redeem_points,
      expiryMonths: req.body?.expiry_months !== undefined ? Math.max(toInt(req.body.expiry_months, existing.expiry_months), 1) : existing.expiry_months,
      birthdayRewardType: req.body?.birthday_reward_type !== undefined ? String(req.body.birthday_reward_type) : existing.birthday_reward_type,
      birthdayRewardValue: req.body?.birthday_reward_value !== undefined ? String(req.body.birthday_reward_value || '') : existing.birthday_reward_value,
    };

    await connection.query(
      `
        UPDATE loyalty_programs
        SET program_name = ?,
            description = ?,
            is_active = ?,
            earn_spend_amount = ?,
            earn_points = ?,
            redeem_points_required = ?,
            redeem_value = ?,
            minimum_redeem_points = ?,
            expiry_months = ?,
            birthday_reward_type = ?,
            birthday_reward_value = ?
        WHERE id = ? AND shop_id = ?
      `,
      [
        updates.programName,
        updates.description,
        updates.isActive,
        updates.earnSpendAmount,
        updates.earnPoints,
        updates.redeemPointsRequired,
        updates.redeemValue,
        updates.minimumRedeemPoints,
        updates.expiryMonths,
        updates.birthdayRewardType,
        updates.birthdayRewardValue,
        programId,
        shopId,
      ]
    );

    const [rows] = await connection.query('SELECT * FROM loyalty_programs WHERE id = ? AND shop_id = ? LIMIT 1', [programId, shopId]);
    return res.status(200).json({ success: true, data: rows[0] });
  } catch (error) {
    console.error('Error updating loyalty program:', error);
    return res.status(500).json({ success: false, message: 'Failed to update loyalty program' });
  } finally {
    connection.release();
  }
};

const createStarterProgramSetup = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();
    await connection.beginTransaction();

    const [existingRows] = await connection.query(
      `
        SELECT id
        FROM loyalty_programs
        WHERE shop_id = ? AND program_name = 'Starter Program'
        LIMIT 1
      `,
      [shopId]
    );

    let programId = existingRows[0]?.id || null;

    if (!programId) {
      const [programResult] = await connection.query(
        `
          INSERT INTO loyalty_programs (
            shop_id,
            program_name,
            description,
            is_active,
            earn_spend_amount,
            earn_points,
            redeem_points_required,
            redeem_value,
            minimum_redeem_points,
            expiry_months,
            birthday_reward_type,
            birthday_reward_value,
            created_by
          ) VALUES (?, 'Starter Program', ?, 1, 20, 1, 100, 50, 100, 6, 'FREE_DESSERT', 'Free dessert', ?)
        `,
        [shopId, 'Recommended starter setup for small restaurants', getCreatedBy(req)]
      );
      programId = programResult.insertId;
    }

    const [offers] = await connection.query(
      'SELECT id FROM loyalty_offers WHERE shop_id = ? AND program_id = ? LIMIT 1',
      [shopId, programId]
    );

    if (!offers.length) {
      await connection.query(
        `
          INSERT INTO loyalty_offers (
            shop_id,
            program_id,
            offer_name,
            offer_type,
            points_required,
            discount_amount,
            min_bill_amount,
            offer_description,
            is_active,
            created_by
          ) VALUES (?, ?, '100 Points = 50 THB', 'DISCOUNT_AMOUNT', 100, 50, 0, 'Starter redeem offer', 1, ?)
        `,
        [shopId, programId, getCreatedBy(req)]
      );
    }

    await connection.commit();

    return res.status(200).json({
      success: true,
      message: 'Starter loyalty setup is ready',
      data: {
        program_id: programId,
        earn_rule: '1 point per 20 THB',
        redeem_rule: '100 points = 50 THB',
        minimum_redeem_points: 100,
        expiry_months: 6,
        birthday_reward: 'Free dessert',
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error creating starter loyalty setup:', error);
    return res.status(500).json({ success: false, message: 'Failed to create starter setup' });
  } finally {
    connection.release();
  }
};

const getLoyaltyOffers = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const programId = toInt(req.query?.program_id, 0);
    const params = [shopId];
    let query = `
      SELECT *
      FROM loyalty_offers
      WHERE shop_id = ?
    `;

    if (programId) {
      query += ' AND program_id = ?';
      params.push(programId);
    }

    query += ' ORDER BY is_active DESC, points_required ASC, id DESC';

    const [rows] = await db.query(query, params);
    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Error fetching loyalty offers:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch loyalty offers' });
  }
};

const createLoyaltyOffer = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const programId = toInt(req.body?.program_id, 0);
    const offerName = String(req.body?.offer_name || '').trim();
    const offerType = String(req.body?.offer_type || '').trim();
    const pointsRequired = Math.max(toInt(req.body?.points_required, 0), 0);

    if (!programId || !offerName || !offerType || pointsRequired <= 0) {
      return res.status(400).json({
        success: false,
        message: 'program_id, offer_name, offer_type and points_required are required',
      });
    }

    await connection.query(
      `
        INSERT INTO loyalty_offers (
          shop_id,
          program_id,
          offer_name,
          offer_type,
          points_required,
          discount_amount,
          discount_percent,
          free_item_id,
          free_item_name,
          min_bill_amount,
          max_discount_amount,
          offer_description,
          is_active,
          start_at,
          end_at,
          created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        shopId,
        programId,
        offerName,
        offerType,
        pointsRequired,
        req.body?.discount_amount !== undefined ? toNumber(req.body.discount_amount, 0) : null,
        req.body?.discount_percent !== undefined ? toNumber(req.body.discount_percent, 0) : null,
        req.body?.free_item_id !== undefined ? toInt(req.body.free_item_id, 0) || null : null,
        req.body?.free_item_name ? String(req.body.free_item_name).trim() : null,
        toNumber(req.body?.min_bill_amount, 0),
        req.body?.max_discount_amount !== undefined ? toNumber(req.body.max_discount_amount, 0) : null,
        req.body?.offer_description ? String(req.body.offer_description).trim() : null,
        req.body?.is_active === undefined ? 1 : (req.body.is_active ? 1 : 0),
        req.body?.start_at || null,
        req.body?.end_at || null,
        getCreatedBy(req),
      ]
    );

    return res.status(201).json({ success: true, message: 'Offer created successfully' });
  } catch (error) {
    console.error('Error creating loyalty offer:', error);
    return res.status(500).json({ success: false, message: 'Failed to create loyalty offer' });
  } finally {
    connection.release();
  }
};

const updateLoyaltyOffer = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const offerId = toInt(req.params.offer_id, 0);
    if (!offerId) {
      return res.status(400).json({ success: false, message: 'offer_id is required' });
    }

    const [rows] = await connection.query(
      'SELECT * FROM loyalty_offers WHERE id = ? AND shop_id = ? LIMIT 1',
      [offerId, shopId]
    );

    if (!rows.length) {
      return res.status(404).json({ success: false, message: 'Offer not found' });
    }

    const existing = rows[0];

    await connection.query(
      `
        UPDATE loyalty_offers
        SET offer_name = ?,
            offer_type = ?,
            points_required = ?,
            discount_amount = ?,
            discount_percent = ?,
            free_item_id = ?,
            free_item_name = ?,
            min_bill_amount = ?,
            max_discount_amount = ?,
            offer_description = ?,
            is_active = ?,
            start_at = ?,
            end_at = ?
        WHERE id = ? AND shop_id = ?
      `,
      [
        req.body?.offer_name !== undefined ? String(req.body.offer_name).trim() : existing.offer_name,
        req.body?.offer_type !== undefined ? String(req.body.offer_type).trim() : existing.offer_type,
        req.body?.points_required !== undefined ? Math.max(toInt(req.body.points_required, existing.points_required), 0) : existing.points_required,
        req.body?.discount_amount !== undefined ? toNumber(req.body.discount_amount, 0) : existing.discount_amount,
        req.body?.discount_percent !== undefined ? toNumber(req.body.discount_percent, 0) : existing.discount_percent,
        req.body?.free_item_id !== undefined ? toInt(req.body.free_item_id, 0) || null : existing.free_item_id,
        req.body?.free_item_name !== undefined ? String(req.body.free_item_name || '').trim() || null : existing.free_item_name,
        req.body?.min_bill_amount !== undefined ? toNumber(req.body.min_bill_amount, 0) : existing.min_bill_amount,
        req.body?.max_discount_amount !== undefined ? toNumber(req.body.max_discount_amount, 0) : existing.max_discount_amount,
        req.body?.offer_description !== undefined ? String(req.body.offer_description || '').trim() || null : existing.offer_description,
        req.body?.is_active !== undefined ? (req.body.is_active ? 1 : 0) : existing.is_active,
        req.body?.start_at !== undefined ? req.body.start_at : existing.start_at,
        req.body?.end_at !== undefined ? req.body.end_at : existing.end_at,
        offerId,
        shopId,
      ]
    );

    return res.status(200).json({ success: true, message: 'Offer updated successfully' });
  } catch (error) {
    console.error('Error updating loyalty offer:', error);
    return res.status(500).json({ success: false, message: 'Failed to update loyalty offer' });
  } finally {
    connection.release();
  }
};

const getLoyaltyCustomers = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const [rows] = await db.query(
      `
        SELECT
          c.id AS customer_id,
          c.name,
          c.contact,
          c.email,
          lm.id AS member_id,
          lm.loyalty_code,
          lm.tier_name,
          lm.points_balance,
          lm.lifetime_points,
          lm.status,
          lm.enrolled_on,
          COUNT(lmp.id) AS enrolled_programs
        FROM customers c
        LEFT JOIN loyalty_members lm
          ON lm.customer_id = c.id
         AND lm.shop_id = c.shop_id
        LEFT JOIN loyalty_member_programs lmp
          ON lmp.member_id = lm.id
         AND lmp.shop_id = lm.shop_id
        WHERE c.shop_id = ?
        GROUP BY c.id, c.name, c.contact, c.email, lm.id, lm.loyalty_code, lm.tier_name, lm.points_balance, lm.lifetime_points, lm.status, lm.enrolled_on
        ORDER BY c.name ASC
      `,
      [shopId]
    );

    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Error fetching loyalty customers:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch loyalty customers' });
  }
};

const enrollLoyaltyMember = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const customerId = toInt(req.body?.customer_id, 0);
    let programId = toInt(req.body?.program_id, 0);

    if (!customerId) {
      return res.status(400).json({ success: false, message: 'customer_id is required' });
    }

    await connection.beginTransaction();

    const [customerRows] = await connection.query(
      'SELECT id, name FROM customers WHERE id = ? AND shop_id = ? LIMIT 1',
      [customerId, shopId]
    );

    if (!customerRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Customer not found for this shop' });
    }

    const [existingRows] = await connection.query(
      'SELECT id, points_balance, lifetime_points FROM loyalty_members WHERE shop_id = ? AND customer_id = ? LIMIT 1',
      [shopId, customerId]
    );

    let memberId = existingRows[0]?.id || null;

    if (!memberId) {
      const loyaltyCode = `LOY-${shopId}-${customerId}`;
      const [memberInsert] = await connection.query(
        `
          INSERT INTO loyalty_members
            (shop_id, customer_id, loyalty_code, tier_name, points_balance, lifetime_points, status)
          VALUES (?, ?, ?, 'Basic', 0, 0, 'active')
        `,
        [shopId, customerId, loyaltyCode]
      );
      memberId = memberInsert.insertId;
    }

    if (!programId) {
      const defaultProgram = await getOrCreateDefaultProgram(connection, shopId, req);
      programId = defaultProgram.id;
    }

    const [programRows] = await connection.query(
      'SELECT * FROM loyalty_programs WHERE id = ? AND shop_id = ? LIMIT 1',
      [programId, shopId]
    );

    if (!programRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Loyalty program not found' });
    }

    const memberProgram = await ensureMemberProgram(
      connection,
      shopId,
      memberId,
      programId,
      programRows[0].expiry_months || 6
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Customer enrolled in loyalty program',
      data: {
        member_id: memberId,
        member_program_id: memberProgram.id,
        program_id: programId,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error enrolling loyalty member:', error);
    return res.status(500).json({ success: false, message: 'Failed to enroll loyalty member' });
  } finally {
    connection.release();
  }
};

const getLoyaltyTransactions = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.params.member_id, 0);
    if (!memberId) {
      return res.status(400).json({ success: false, message: 'member_id is required' });
    }

    const [rows] = await db.query(
      `
        SELECT
          lt.id,
          lt.member_id,
          lt.member_program_id,
          lt.program_id,
          lp.program_name,
          lt.customer_id,
          lt.bill_id,
          lt.offer_id,
          lt.offer_name,
          lt.transaction_type,
          lt.points_delta,
          lt.note,
          lt.created_by,
          lt.created_at
        FROM loyalty_transactions lt
        LEFT JOIN loyalty_programs lp ON lp.id = lt.program_id
        WHERE lt.shop_id = ? AND lt.member_id = ?
        ORDER BY lt.created_at DESC, lt.id DESC
      `,
      [shopId, memberId]
    );

    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Error fetching loyalty transactions:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch loyalty transactions' });
  }
};

const createLoyaltyTransaction = async (req, res, mode) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.body?.member_id, 0);
    let programId = toInt(req.body?.program_id, 0);
    const billId = req.body?.bill_id ? toInt(req.body.bill_id, 0) : null;
    const note = (req.body?.note || '').toString().trim() || null;

    if (!memberId) {
      return res.status(400).json({ success: false, message: 'member_id is required' });
    }

    await connection.beginTransaction();

    const [memberRows] = await connection.query(
      `
        SELECT id, customer_id, points_balance, lifetime_points
        FROM loyalty_members
        WHERE id = ? AND shop_id = ?
        FOR UPDATE
      `,
      [memberId, shopId]
    );

    if (!memberRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Loyalty member not found' });
    }

    const member = memberRows[0];

    if (!programId) {
      const defaultProgram = await getOrCreateDefaultProgram(connection, shopId, req);
      programId = defaultProgram.id;
    }

    const [programRows] = await connection.query(
      'SELECT * FROM loyalty_programs WHERE id = ? AND shop_id = ? LIMIT 1',
      [programId, shopId]
    );

    if (!programRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Loyalty program not found' });
    }

    const program = programRows[0];
    const memberProgram = await ensureMemberProgram(
      connection,
      shopId,
      member.id,
      programId,
      program.expiry_months || 6
    );

    const [memberProgramRows] = await connection.query(
      `
        SELECT *
        FROM loyalty_member_programs
        WHERE id = ? AND shop_id = ?
        FOR UPDATE
      `,
      [memberProgram.id, shopId]
    );

    const lockedMemberProgram = memberProgramRows[0];

    let pointsDelta = 0;

    if (mode === 'EARN') {
      const rawPoints = toInt(req.body?.points, 0);
      const billAmount = toNumber(req.body?.bill_amount, 0);
      if (rawPoints > 0) {
        pointsDelta = rawPoints;
      } else {
        const spendForEarn = Math.max(toNumber(program.earn_spend_amount, 20), 0.01);
        const earnPoints = Math.max(toInt(program.earn_points, 1), 1);
        pointsDelta = Math.floor((billAmount / spendForEarn) * earnPoints);
      }
      if (pointsDelta <= 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Provide points or bill_amount to earn points' });
      }
    } else if (mode === 'REDEEM') {
      const redeemPoints = toInt(req.body?.points, 0);
      if (redeemPoints <= 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'points must be greater than 0 for redemption' });
      }
      pointsDelta = -redeemPoints;
      if (lockedMemberProgram.points_balance + pointsDelta < 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Insufficient loyalty points' });
      }
    } else if (mode === 'ADJUST') {
      pointsDelta = toInt(req.body?.points_delta, 0);
      if (pointsDelta === 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'points_delta must be non-zero' });
      }
      if (lockedMemberProgram.points_balance + pointsDelta < 0) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Adjustment would make points negative' });
      }
    }

    const newProgramBalance = lockedMemberProgram.points_balance + pointsDelta;
    const newMemberBalance = member.points_balance + pointsDelta;
    const lifetimeIncrement = pointsDelta > 0 ? pointsDelta : 0;

    await connection.query(
      `
        UPDATE loyalty_member_programs
        SET points_balance = ?,
            lifetime_points = lifetime_points + ?,
            last_activity_at = NOW(),
            expires_at = DATE_ADD(NOW(), INTERVAL ? MONTH)
        WHERE id = ? AND shop_id = ?
      `,
      [newProgramBalance, lifetimeIncrement, program.expiry_months || 6, lockedMemberProgram.id, shopId]
    );

    await connection.query(
      `
        UPDATE loyalty_members
        SET points_balance = ?,
            lifetime_points = lifetime_points + ?
        WHERE id = ? AND shop_id = ?
      `,
      [newMemberBalance, lifetimeIncrement, member.id, shopId]
    );

    await connection.query(
      `
        INSERT INTO loyalty_transactions
          (shop_id, member_id, member_program_id, program_id, customer_id, bill_id, transaction_type, points_delta, note, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [shopId, member.id, lockedMemberProgram.id, program.id, member.customer_id, billId, mode, pointsDelta, note, getCreatedBy(req)]
    );

    await queueLoyaltyLineNotification(connection, {
      shopId,
      memberId: member.id,
      customerId: member.customer_id,
      templateKey: mode === 'EARN' ? 'LOYALTY_EARNED' : (mode === 'REDEEM' ? 'LOYALTY_REDEEMED' : 'LOYALTY_ADJUSTED'),
      message:
        mode === 'EARN'
          ? `You earned ${pointsDelta} loyalty points in ${program.program_name}.`
          : mode === 'REDEEM'
            ? `You redeemed ${Math.abs(pointsDelta)} loyalty points in ${program.program_name}.`
            : `Your loyalty points were adjusted by ${pointsDelta} in ${program.program_name}.`,
      payload: { program_id: program.id, points_delta: pointsDelta, bill_id: billId || null },
    });

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: `Loyalty ${mode.toLowerCase()} transaction saved`,
      data: {
        member_id: member.id,
        member_program_id: lockedMemberProgram.id,
        program_id: program.id,
        customer_id: member.customer_id,
        points_delta: pointsDelta,
        points_balance: newProgramBalance,
        total_points_balance: newMemberBalance,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error creating loyalty transaction:', error);
    return res.status(500).json({ success: false, message: 'Failed to save loyalty transaction' });
  } finally {
    connection.release();
  }
};

const getEligibleOffers = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.query?.member_id, 0);
    let programId = toInt(req.query?.program_id, 0);
    const billAmount = toNumber(req.query?.bill_amount, 0);

    if (!memberId) {
      return res.status(400).json({ success: false, message: 'member_id is required' });
    }

    const connection = await db.getConnection();
    try {
      if (!programId) {
        const defaultProgram = await getOrCreateDefaultProgram(connection, shopId, req);
        programId = defaultProgram.id;
      }

      const memberProgram = await ensureMemberProgram(connection, shopId, memberId, programId, 6);

      const [offerRows] = await connection.query(
        `
          SELECT
            lo.*,
            ? AS current_bill_amount,
            ? AS current_points_balance,
            CASE
              WHEN lo.points_required <= ?
                AND lo.min_bill_amount <= ?
                AND lo.is_active = 1
                AND (lo.start_at IS NULL OR lo.start_at <= NOW())
                AND (lo.end_at IS NULL OR lo.end_at >= NOW())
              THEN 1
              ELSE 0
            END AS is_eligible
          FROM loyalty_offers lo
          WHERE lo.shop_id = ?
            AND lo.program_id = ?
            AND lo.is_active = 1
          ORDER BY lo.points_required ASC, lo.id ASC
        `,
        [billAmount, memberProgram.points_balance, memberProgram.points_balance, billAmount, shopId, programId]
      );

      return res.status(200).json({
        success: true,
        data: {
          member_program_id: memberProgram.id,
          points_balance: memberProgram.points_balance,
          offers: offerRows,
        },
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Error fetching eligible loyalty offers:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch eligible offers' });
  }
};

const redeemOffer = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.body?.member_id, 0);
    let programId = toInt(req.body?.program_id, 0);
    const offerId = toInt(req.body?.offer_id, 0);
    const billId = req.body?.bill_id ? toInt(req.body.bill_id, 0) : null;
    const billAmount = toNumber(req.body?.bill_amount, 0);
    const note = String(req.body?.note || '').trim() || null;

    if (!memberId || !offerId) {
      return res.status(400).json({ success: false, message: 'member_id and offer_id are required' });
    }

    await connection.beginTransaction();

    if (!programId) {
      const defaultProgram = await getOrCreateDefaultProgram(connection, shopId, req);
      programId = defaultProgram.id;
    }

    const [memberRows] = await connection.query(
      `
        SELECT id, customer_id, points_balance
        FROM loyalty_members
        WHERE id = ? AND shop_id = ?
        FOR UPDATE
      `,
      [memberId, shopId]
    );

    if (!memberRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Loyalty member not found' });
    }

    const member = memberRows[0];

    const [offerRows] = await connection.query(
      `
        SELECT *
        FROM loyalty_offers
        WHERE id = ?
          AND shop_id = ?
          AND program_id = ?
          AND is_active = 1
        LIMIT 1
      `,
      [offerId, shopId, programId]
    );

    if (!offerRows.length) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Offer not found for this loyalty program' });
    }

    const offer = offerRows[0];

    const memberProgram = await ensureMemberProgram(connection, shopId, member.id, programId, 6);

    const [memberProgramRows] = await connection.query(
      `
        SELECT *
        FROM loyalty_member_programs
        WHERE id = ? AND shop_id = ?
        FOR UPDATE
      `,
      [memberProgram.id, shopId]
    );

    const lockedMemberProgram = memberProgramRows[0];

    if (lockedMemberProgram.points_balance < offer.points_required) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Insufficient points for this offer' });
    }

    if (billAmount < toNumber(offer.min_bill_amount, 0)) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Bill amount is below offer minimum requirement' });
    }

    const pointsDelta = -Math.abs(toInt(offer.points_required, 0));
    const nextProgramBalance = lockedMemberProgram.points_balance + pointsDelta;
    const nextMemberBalance = member.points_balance + pointsDelta;

    let discountValue = 0;
    if (offer.offer_type === 'DISCOUNT_AMOUNT') {
      discountValue = Math.max(toNumber(offer.discount_amount, 0), 0);
    }
    if (offer.offer_type === 'DISCOUNT_PERCENT') {
      discountValue = (billAmount * Math.max(toNumber(offer.discount_percent, 0), 0)) / 100;
      if (offer.max_discount_amount !== null && offer.max_discount_amount !== undefined) {
        discountValue = Math.min(discountValue, Math.max(toNumber(offer.max_discount_amount, 0), 0));
      }
    }

    await connection.query(
      `
        UPDATE loyalty_member_programs
        SET points_balance = ?,
            last_activity_at = NOW(),
            expires_at = DATE_ADD(NOW(), INTERVAL 6 MONTH)
        WHERE id = ? AND shop_id = ?
      `,
      [nextProgramBalance, lockedMemberProgram.id, shopId]
    );

    await connection.query(
      `
        UPDATE loyalty_members
        SET points_balance = ?
        WHERE id = ? AND shop_id = ?
      `,
      [nextMemberBalance, member.id, shopId]
    );

    const [txResult] = await connection.query(
      `
        INSERT INTO loyalty_transactions
          (shop_id, member_id, member_program_id, program_id, customer_id, bill_id, offer_id, offer_name, transaction_type, points_delta, note, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'REDEEM', ?, ?, ?)
      `,
      [
        shopId,
        member.id,
        lockedMemberProgram.id,
        programId,
        member.customer_id,
        billId,
        offer.id,
        offer.offer_name,
        pointsDelta,
        note || `Redeemed ${offer.offer_name}`,
        getCreatedBy(req),
      ]
    );

    const [redemptionResult] = await connection.query(
      `
        INSERT INTO loyalty_redemptions (
          shop_id,
          program_id,
          member_program_id,
          member_id,
          customer_id,
          bill_id,
          offer_id,
          offer_name,
          offer_type,
          points_used,
          discount_value,
          free_item_name,
          note,
          created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        shopId,
        programId,
        lockedMemberProgram.id,
        member.id,
        member.customer_id,
        billId,
        offer.id,
        offer.offer_name,
        offer.offer_type,
        Math.abs(pointsDelta),
        discountValue,
        offer.offer_type === 'FREE_ITEM' ? (offer.free_item_name || null) : null,
        note,
        getCreatedBy(req),
      ]
    );

    await queueLoyaltyLineNotification(connection, {
      shopId,
      memberId: member.id,
      customerId: member.customer_id,
      templateKey: 'LOYALTY_REDEEMED_OFFER',
      message: `You redeemed ${offer.offer_name} using ${Math.abs(pointsDelta)} points.`,
      payload: {
        offer_id: offer.id,
        redemption_id: redemptionResult.insertId,
        transaction_id: txResult.insertId,
        discount_value: discountValue,
      },
    });

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Offer redeemed successfully',
      data: {
        transaction_id: txResult.insertId,
        redemption_id: redemptionResult.insertId,
        member_id: member.id,
        member_program_id: lockedMemberProgram.id,
        program_id: programId,
        offer_id: offer.id,
        offer_type: offer.offer_type,
        offer_name: offer.offer_name,
        points_used: Math.abs(pointsDelta),
        points_balance: nextProgramBalance,
        total_points_balance: nextMemberBalance,
        discount_value: discountValue,
        free_item_name: offer.offer_type === 'FREE_ITEM' ? (offer.free_item_name || null) : null,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error redeeming loyalty offer:', error);
    return res.status(500).json({ success: false, message: 'Failed to redeem loyalty offer' });
  } finally {
    connection.release();
  }
};

const getRedemptionHistory = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.query?.member_id, 0);
    const customerId = toInt(req.query?.customer_id, 0);

    const params = [shopId];
    let query = `
      SELECT
        lr.*,
        lp.program_name,
        c.name AS customer_name,
        c.contact AS customer_contact
      FROM loyalty_redemptions lr
      LEFT JOIN loyalty_programs lp ON lp.id = lr.program_id
      LEFT JOIN customers c ON c.id = lr.customer_id
      WHERE lr.shop_id = ?
    `;

    if (memberId) {
      query += ' AND lr.member_id = ?';
      params.push(memberId);
    }

    if (customerId) {
      query += ' AND lr.customer_id = ?';
      params.push(customerId);
    }

    query += ' ORDER BY lr.created_at DESC, lr.id DESC LIMIT 500';

    const [rows] = await db.query(query, params);
    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Error fetching redemption history:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch redemption history' });
  }
};

const getLoyaltyAnalytics = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const [overviewRows] = await db.query(
      `
        SELECT
          COUNT(DISTINCT lm.id) AS total_members,
          COUNT(DISTINCT lmp.id) AS total_member_programs,
          COALESCE(SUM(lm.points_balance), 0) AS total_points_balance,
          COALESCE(SUM(lm.lifetime_points), 0) AS total_lifetime_points,
          COALESCE(SUM(lr.points_used), 0) AS total_points_redeemed,
          COALESCE(SUM(lr.discount_value), 0) AS total_discount_given
        FROM loyalty_members lm
        LEFT JOIN loyalty_member_programs lmp ON lmp.member_id = lm.id AND lmp.shop_id = lm.shop_id
        LEFT JOIN loyalty_redemptions lr ON lr.member_id = lm.id AND lr.shop_id = lm.shop_id
        WHERE lm.shop_id = ?
      `,
      [shopId]
    );

    const [topCustomerRows] = await db.query(
      `
        SELECT
          lm.id AS member_id,
          lm.customer_id,
          c.name AS customer_name,
          c.contact,
          lm.points_balance,
          lm.lifetime_points,
          COALESCE(SUM(lr.points_used), 0) AS points_redeemed,
          COALESCE(SUM(lr.discount_value), 0) AS total_discount_received,
          COUNT(lr.id) AS total_redemptions
        FROM loyalty_members lm
        LEFT JOIN customers c ON c.id = lm.customer_id
        LEFT JOIN loyalty_redemptions lr ON lr.member_id = lm.id AND lr.shop_id = lm.shop_id
        WHERE lm.shop_id = ?
        GROUP BY lm.id, lm.customer_id, c.name, c.contact, lm.points_balance, lm.lifetime_points
        ORDER BY lm.lifetime_points DESC, lm.points_balance DESC
        LIMIT 20
      `,
      [shopId]
    );

    const [programRows] = await db.query(
      `
        SELECT
          lp.id,
          lp.program_name,
          lp.is_active,
          COUNT(DISTINCT lmp.member_id) AS enrolled_members,
          COALESCE(SUM(lmp.points_balance), 0) AS points_balance,
          COALESCE(SUM(lmp.lifetime_points), 0) AS lifetime_points,
          COALESCE(SUM(lr.points_used), 0) AS redeemed_points,
          COALESCE(SUM(lr.discount_value), 0) AS discount_given
        FROM loyalty_programs lp
        LEFT JOIN loyalty_member_programs lmp ON lmp.program_id = lp.id AND lmp.shop_id = lp.shop_id
        LEFT JOIN loyalty_redemptions lr ON lr.program_id = lp.id AND lr.shop_id = lp.shop_id
        WHERE lp.shop_id = ?
        GROUP BY lp.id, lp.program_name, lp.is_active
        ORDER BY lp.id DESC
      `,
      [shopId]
    );

    const [inactiveRows] = await db.query(
      `
        SELECT
          lm.id AS member_id,
          c.name AS customer_name,
          c.contact,
          MAX(lt.created_at) AS last_transaction_at
        FROM loyalty_members lm
        LEFT JOIN customers c ON c.id = lm.customer_id
        LEFT JOIN loyalty_transactions lt ON lt.member_id = lm.id AND lt.shop_id = lm.shop_id
        WHERE lm.shop_id = ?
        GROUP BY lm.id, c.name, c.contact
        HAVING last_transaction_at IS NULL OR last_transaction_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
        ORDER BY last_transaction_at ASC
        LIMIT 50
      `,
      [shopId]
    );

    return res.status(200).json({
      success: true,
      data: {
        overview: overviewRows[0] || {},
        top_customers: topCustomerRows,
        programs: programRows,
        inactive_customers: inactiveRows,
      },
    });
  } catch (error) {
    console.error('Error fetching loyalty analytics:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch loyalty analytics' });
  }
};

const enqueueMarketingNotification = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    await ensureLoyaltyTables();

    const memberId = toInt(req.body?.member_id, 0);
    const customerId = toInt(req.body?.customer_id, 0);
    const templateKey = String(req.body?.template_key || '').trim();
    const message = String(req.body?.message || '').trim();

    if (!memberId || !customerId || !templateKey || !message) {
      return res.status(400).json({
        success: false,
        message: 'member_id, customer_id, template_key and message are required',
      });
    }

    await queueLoyaltyLineNotification(connection, {
      shopId,
      memberId,
      customerId,
      templateKey,
      message,
      payload: req.body?.payload_json || null,
    });

    return res.status(201).json({ success: true, message: 'LINE notification queued' });
  } catch (error) {
    console.error('Error queueing marketing notification:', error);
    return res.status(500).json({ success: false, message: 'Failed to queue notification' });
  } finally {
    connection.release();
  }
};

const earnPoints = async (req, res) => createLoyaltyTransaction(req, res, 'EARN');
const redeemPoints = async (req, res) => createLoyaltyTransaction(req, res, 'REDEEM');
const adjustPoints = async (req, res) => createLoyaltyTransaction(req, res, 'ADJUST');

// Public endpoint — no auth required
// GET /loyalty/public/check?member_id=<id>&shop_id=<id>
//   or                    ?contact=<phone>&shop_id=<id>
const getPublicMemberInfo = async (req, res) => {
  try {
    // Rate-limit basic: return minimal safe data only
    await ensureLoyaltyTables();

    const shopId = toInt(req.query.shop_id, 0);
    if (!shopId) {
      return res.status(400).json({ success: false, error: 'shop_id is required', message: 'shop_id is required' });
    }

    let memberRow = null;

    if (req.query.member_id) {
      const memberId = toInt(req.query.member_id, 0);
      const [rows] = await db.query(
        `SELECT lm.id AS member_id, lm.loyalty_code, lm.tier_name, lm.points_balance, lm.lifetime_points,
                lm.enrolled_on, c.name, c.contact
         FROM loyalty_members lm
         JOIN customers c ON c.id = lm.customer_id
         WHERE lm.shop_id = ? AND lm.id = ?
         LIMIT 1`,
        [shopId, memberId]
      );
      memberRow = rows[0] || null;
    } else if (req.query.contact) {
      // Sanitize: only allow digits and + for phone numbers
      const contact = String(req.query.contact).replace(/[^0-9+\-\s]/g, '').slice(0, 20);
      const [rows] = await db.query(
        `SELECT lm.id AS member_id, lm.loyalty_code, lm.tier_name, lm.points_balance, lm.lifetime_points,
                lm.enrolled_on, c.name, c.contact
         FROM loyalty_members lm
         JOIN customers c ON c.id = lm.customer_id
         WHERE lm.shop_id = ? AND c.contact = ?
         LIMIT 1`,
        [shopId, contact]
      );
      memberRow = rows[0] || null;
    } else {
      return res.status(400).json({ success: false, error: 'member_id or contact is required', message: 'member_id or contact is required' });
    }

    if (!memberRow) {
      return res.status(404).json({ success: false, error: 'Member not found', message: 'Member not found' });
    }

    // Fetch last 20 redemptions (safe public data only)
    const [redemptions] = await db.query(
      `SELECT lr.id, lr.offer_name, lr.offer_type, lr.points_used, lr.discount_value,
              lr.free_item_name, lr.created_at AS redeemed_at
       FROM loyalty_redemptions lr
       WHERE lr.shop_id = ? AND lr.member_id = ?
       ORDER BY lr.created_at DESC, lr.id DESC
       LIMIT 20`,
      [shopId, memberRow.member_id]
    );

    return res.status(200).json({
      success: true,
      member: {
        member_id: memberRow.member_id,
        name: memberRow.name,
        loyalty_code: memberRow.loyalty_code,
        tier_name: memberRow.tier_name,
        points_balance: memberRow.points_balance,
        lifetime_points: memberRow.lifetime_points,
        enrolled_on: memberRow.enrolled_on,
      },
      redemptions,
    });
  } catch (error) {
    console.error('Error in getPublicMemberInfo:', error);
    return res.status(500).json({ success: false, error: 'Failed to fetch member info', message: 'Failed to fetch member info' });
  }
};

module.exports = {
  getLoyaltyPrograms,
  createLoyaltyProgram,
  updateLoyaltyProgram,
  createStarterProgramSetup,
  getLoyaltyOffers,
  createLoyaltyOffer,
  updateLoyaltyOffer,
  getLoyaltyCustomers,
  enrollLoyaltyMember,
  getLoyaltyTransactions,
  earnPoints,
  redeemPoints,
  adjustPoints,
  getEligibleOffers,
  redeemOffer,
  getRedemptionHistory,
  getLoyaltyAnalytics,
  enqueueMarketingNotification,
  getPublicMemberInfo,
};
