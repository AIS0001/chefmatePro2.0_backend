-- ============================================================
-- PAYMENT & SUBSCRIPTION MANAGEMENT TABLES
-- ============================================================

-- ============================================================
-- SUBSCRIPTION PLANS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS `subscription_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Plan name (Basic, Pro, Premium)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `price_per_month` decimal(10,2) NOT NULL,
  `max_terminals` int DEFAULT '1',
  `max_users` int DEFAULT '5',
  `storage_quota_gb` int DEFAULT '10',
  `features` json DEFAULT NULL COMMENT 'JSON array of included features',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Available subscription plans';

-- ============================================================
-- SHOP SUBSCRIPTIONS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS `shop_subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `plan_id` int NOT NULL,
  `subscription_type` enum('MONTHLY','QUARTERLY','YEARLY') COLLATE utf8mb4_unicode_ci DEFAULT 'MONTHLY',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `renewal_date` date NOT NULL COMMENT 'When next payment is due',
  `status` enum('ACTIVE','SUSPENDED','CANCELLED','EXPIRED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `auto_renew` tinyint(1) DEFAULT 1,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_plan_id` (`plan_id`),
  KEY `idx_renewal_date` (`renewal_date`),
  KEY `idx_status` (`status`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Shop subscription records';

-- ============================================================
-- PAYMENT RECORDS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS `payment_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `subscription_id` int DEFAULT NULL,
  `amount` decimal(10, 2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'CREDIT_CARD, BANK_TRANSFER, CASH, UPI, CHEQUE, etc.',
  `payment_status` enum('PENDING','COMPLETED','FAILED','CANCELLED','REFUNDED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Payment gateway transaction ID',
  `due_date` date NOT NULL,
  `paid_date` date DEFAULT NULL COMMENT 'When payment was actually received',
  `invoice_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `payment_type` enum('MONTHLY','QUARTERLY','YEARLY') COLLATE utf8mb4_unicode_ci DEFAULT 'MONTHLY',
  `reference_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int DEFAULT NULL COMMENT 'Super admin user ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_subscription_id` (`subscription_id`),
  KEY `idx_due_date` (`due_date`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_paid_date` (`paid_date`),
  KEY `idx_shop_status_due` (`shop_id`, `payment_status`, `due_date`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`subscription_id`) REFERENCES `shop_subscriptions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payment records for subscriptions';

-- ============================================================
-- PAYMENT REMINDERS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS `payment_reminders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `payment_record_id` int DEFAULT NULL,
  `reminder_type` enum('DUE_REMINDER','OVERDUE_WARNING','SUSPENSION_NOTICE') COLLATE utf8mb4_unicode_ci DEFAULT 'DUE_REMINDER',
  `days_before_due` int DEFAULT 0 COMMENT '0=on due date, negative=days after due date',
  `sent_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `acknowledged` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_payment_record_id` (`payment_record_id`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`payment_record_id`) REFERENCES `payment_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payment reminder notifications';

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Insert subscription plans
INSERT IGNORE INTO `subscription_plans` (id, name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features, is_active, created_at, updated_at) 
VALUES 
(1, 'Starter', 'Perfect for small restaurants', 500.00, 1, 5, 10, '[\"POS\", \"Basic Reports\", \"Customer Management\"]', 1, NOW(), NOW()),
(2, 'Professional', 'For growing restaurants', 1500.00, 3, 15, 50, '[\"POS\", \"Advanced Reports\", \"Customer Management\", \"Inventory\", \"Staff Management\"]', 1, NOW(), NOW()),
(3, 'Enterprise', 'For large restaurant chains', 2500.00, 10, 50, 200, '[\"POS\", \"Advanced Reports\", \"Customer Management\", \"Inventory\", \"Staff Management\", \"Multi-location\", \"API Access\", \"Custom Integration\"]', 1, NOW(), NOW());

-- Insert sample shop subscription
INSERT IGNORE INTO `shop_subscriptions` (shop_id, plan_id, subscription_type, start_date, end_date, renewal_date, status) 
VALUES 
(1, 1, 'MONTHLY', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 MONTH), 'ACTIVE');

-- Insert sample payment record
INSERT IGNORE INTO `payment_records` (shop_id, subscription_id, amount, currency, payment_method, payment_status, due_date, payment_type) 
VALUES 
(1, 1, 500.00, 'USD', 'BANK_TRANSFER', 'PENDING', DATE_ADD(CURDATE(), INTERVAL 1 MONTH), 'MONTHLY');
