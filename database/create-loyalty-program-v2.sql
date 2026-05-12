-- Loyalty Program V2 (Multi-program, offers, redemptions, notifications)
-- Safe migration for existing installations.

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @ddl := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'loyalty_transactions'
        AND COLUMN_NAME = 'program_id'
    ),
    'SELECT 1',
    'ALTER TABLE loyalty_transactions ADD COLUMN program_id INT NULL AFTER customer_id'
  )
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'loyalty_transactions'
        AND COLUMN_NAME = 'member_program_id'
    ),
    'SELECT 1',
    'ALTER TABLE loyalty_transactions ADD COLUMN member_program_id INT NULL AFTER program_id'
  )
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'loyalty_transactions'
        AND COLUMN_NAME = 'offer_id'
    ),
    'SELECT 1',
    'ALTER TABLE loyalty_transactions ADD COLUMN offer_id INT NULL AFTER bill_id'
  )
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'loyalty_transactions'
        AND COLUMN_NAME = 'offer_name'
    ),
    'SELECT 1',
    'ALTER TABLE loyalty_transactions ADD COLUMN offer_name VARCHAR(150) NULL AFTER offer_id'
  )
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
