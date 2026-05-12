-- Loyalty Program Tables
-- Safe to run multiple times

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
  CONSTRAINT fk_loyalty_members_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  CONSTRAINT fk_loyalty_tx_member
    FOREIGN KEY (member_id) REFERENCES loyalty_members(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_loyalty_tx_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
