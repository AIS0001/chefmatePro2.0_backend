-- =====================================================
-- CHEFMATE PRO - SAAS MIGRATION SCRIPT
-- Convert Single Tenant to Multi-Tenant Database
-- =====================================================
-- Add shop_id to core tables to support multiple shops

-- ===== DISABLE FOREIGN KEY CHECKS DURING MIGRATION =====
SET FOREIGN_KEY_CHECKS=0;

-- =====================================================
-- STEP 1: CREATE SHOPS MANAGEMENT TABLE
-- =====================================================
DROP TABLE IF EXISTS `shops`;
CREATE TABLE `shops` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL COMMENT 'Shop/Restaurant name',
  `shop_code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique shop identifier',
  `tax_id` VARCHAR(100) NOT NULL COMMENT 'Tax identification number',
  `phone_number` VARCHAR(50) NOT NULL COMMENT 'Primary phone',
  `email` VARCHAR(255) NOT NULL COMMENT 'Shop email',
  `address` TEXT NOT NULL COMMENT 'Full address',
  `city` VARCHAR(100) DEFAULT NULL,
  `state` VARCHAR(100) DEFAULT NULL,
  `zip_code` VARCHAR(20) DEFAULT NULL,
  `country` VARCHAR(100) DEFAULT NULL,
  `website` VARCHAR(255) DEFAULT NULL,
  `logo` LONGBLOB COMMENT 'Shop logo',
  `logo_type` VARCHAR(50) DEFAULT NULL,
  `logo_name` VARCHAR(255) DEFAULT NULL,
  `contact_person` VARCHAR(255) DEFAULT NULL,
  `contact_person_phone` VARCHAR(50) DEFAULT NULL,
  `subscription_status` ENUM('active', 'inactive', 'trial', 'suspended') DEFAULT 'trial',
  `subscription_plan_id` INT DEFAULT NULL,
  `subscription_start_date` DATETIME DEFAULT NULL,
  `subscription_end_date` DATETIME DEFAULT NULL,
  `no_of_terminals` INT DEFAULT 1,
  `max_users` INT DEFAULT 10,
  `storage_quota_gb` INT DEFAULT 50,
  `database_prefix` VARCHAR(50) COMMENT 'Optional: for database sharding',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT '1=active, 0=inactive',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` INT DEFAULT NULL,
  `updated_by` INT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_shop_code` (`shop_code`),
  UNIQUE KEY `unique_tax_id` (`tax_id`),
  KEY `idx_shop_name` (`name`),
  KEY `idx_subscription_status` (`subscription_status`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Multi-tenant shop/restaurant information';

-- =====================================================
-- STEP 2: CREATE SUPER ADMIN AND ROLE MANAGEMENT TABLES
-- =====================================================
DROP TABLE IF EXISTS `super_admin_users`;
CREATE TABLE `super_admin_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100) DEFAULT NULL,
  `last_name` VARCHAR(100) DEFAULT NULL,
  `phone_number` VARCHAR(50) DEFAULT NULL,
  `role` ENUM('super_admin', 'admin', 'support', 'billing') DEFAULT 'super_admin',
  `permissions` JSON COMMENT 'JSON array of permissions',
  `profile_image` LONGBLOB,
  `profile_image_type` VARCHAR(50) DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `last_login` DATETIME DEFAULT NULL,
  `login_attempts` INT DEFAULT 0,
  `account_locked_until` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username` (`username`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Super admin users for managing all shops';

-- =====================================================
-- STEP 3: CREATE SHOP ADMIN ASSIGNMENT TABLE
-- =====================================================
DROP TABLE IF EXISTS `shop_admins`;
CREATE TABLE `shop_admins` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `shop_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `role` ENUM('owner', 'manager', 'admin', 'staff') DEFAULT 'admin',
  `permissions` JSON COMMENT 'Shop-specific permissions',
  `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `assigned_by` INT DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_shop_user` (`shop_id`, `user_id`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Shop admin and staff assignments';

-- =====================================================
-- STEP 4: CREATE SUBSCRIPTION PLANS TABLE
-- =====================================================
DROP TABLE IF EXISTS `subscription_plans`;
CREATE TABLE `subscription_plans` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL COMMENT 'Plan name (Basic, Pro, Premium)',
  `description` TEXT,
  `price_per_month` DECIMAL(10,2) NOT NULL,
  `max_terminals` INT DEFAULT 1,
  `max_users` INT DEFAULT 5,
  `storage_quota_gb` INT DEFAULT 10,
  `features` JSON COMMENT 'JSON array of included features',
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Available subscription plans';

-- ===== INSERT DEFAULT PLANS =====
INSERT INTO `subscription_plans` (`name`, `description`, `price_per_month`, `max_terminals`, `max_users`, `storage_quota_gb`, `features`, `is_active`) VALUES
('Starter', 'Perfect for small restaurants', 99.99, 1, 5, 10, '["POS", "Basic Reports", "Customer Management"]', 1),
('Professional', 'For growing restaurants', 299.99, 3, 15, 50, '["POS", "Advanced Reports", "Customer Management", "Inventory", "Staff Management"]', 1),
('Enterprise', 'For large restaurant chains', 999.99, 10, 50, 200, '["POS", "Advanced Reports", "Customer Management", "Inventory", "Staff Management", "Multi-location", "API Access", "Custom Integration"]', 1);

-- =====================================================
-- TEMP INSERT DEFAULT SHOP (moved here before ALTER TABLEs)
-- =====================================================
INSERT INTO `shops` 
(`id`, `name`, `shop_code`, `tax_id`, `phone_number`, `email`, `address`, `city`, `state`, `zip_code`, `country`, `subscription_status`, `subscription_plan_id`, `subscription_start_date`, `subscription_end_date`, `no_of_terminals`, `max_users`, `storage_quota_gb`, `is_active`, `created_at`)
VALUES 
(1, 'Default Shop', 'DEFAULT001', '0205569006468', '+66-839194134', 'info@chefmate.com', '371/6-8 Moo 10, Muang Pattaya, Bang Lamung District, Chon Buri 20150', 'Bangkok', 'Bangkok', '20150', 'Thailand', 'active', 2, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), 1, 10, 50, 1, NOW());

-- =====================================================
-- STEP 5: CREATE BILLING AND PAYMENT TRACKING TABLE
-- =====================================================
DROP TABLE IF EXISTS `shop_billing`;
CREATE TABLE `shop_billing` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `shop_id` INT NOT NULL,
  `billing_period_start` DATE NOT NULL,
  `billing_period_end` DATE NOT NULL,
  `plan_id` INT DEFAULT NULL,
  `amount_due` DECIMAL(10,2) NOT NULL,
  `amount_paid` DECIMAL(10,2) DEFAULT 0,
  `tax_amount` DECIMAL(10,2) DEFAULT 0,
  `billing_status` ENUM('pending', 'sent', 'paid', 'cancelled', 'overdue') DEFAULT 'pending',
  `payment_method` VARCHAR(100) DEFAULT NULL,
  `invoice_number` VARCHAR(100) UNIQUE,
  `payment_date` DATETIME DEFAULT NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans`(`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_billing_status` (`billing_status`),
  KEY `idx_billing_period` (`billing_period_start`, `billing_period_end`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Subscription billing records for each shop';

-- =====================================================
-- STEP 6: CREATE AUDIT LOG TABLE
-- =====================================================
DROP TABLE IF EXISTS `shop_audit_logs`;
CREATE TABLE `shop_audit_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `shop_id` INT DEFAULT NULL,
  `user_id` INT DEFAULT NULL,
  `action` VARCHAR(100) NOT NULL,
  `entity_type` VARCHAR(100) COMMENT 'Table name being modified',
  `entity_id` INT COMMENT 'ID of modified record',
  `old_values` JSON COMMENT 'Previous values',
  `new_values` JSON COMMENT 'New values',
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for all admin actions across shops';

-- =====================================================
-- STEP 7: NOW ADD shop_id TO EXISTING TABLES
-- =====================================================
-- NOTE: If any table doesn't exist, comment out its ALTER statement
-- Tables to verify exist before running:
-- ✓ users, categories, items, item_images
-- ✓ bills, advance_final_bill, advance_orders, advance_order_items
-- ✓ bill_edit_logs, cash_drawer, purchase_order, stock
-- ✓ company_profile, printer_config, device_auth
-- Optional: order_items, customers, vendors, etc.
-- =====================================================

-- Add shop_id to users table
ALTER TABLE `users` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

ALTER TABLE `units` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to categories table
ALTER TABLE `categories` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to customers table (customer_details or similar - adjust based on actual table)
-- ALTER TABLE `customer_details` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to items table (products)
ALTER TABLE `items` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to item_images table
ALTER TABLE `item_images` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to bills/invoices table
ALTER TABLE `final_bill` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to advance_final_bill table
ALTER TABLE `advance_final_bill` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to advance_orders table
ALTER TABLE `advance_orders` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to advance_order_items table
ALTER TABLE `advance_order_items` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to bill_edit_logs table
ALTER TABLE `bill_edit_logs` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to cash_drawer table
ALTER TABLE `cash_drawer` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to vendor tables if they exist
-- ALTER TABLE `vendors` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to purchase_order or stock related tables
ALTER TABLE `purchase_orders` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to inventory/stock table
ALTER TABLE `stock_balance` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

ALTER TABLE `stock_conversions` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);


ALTER TABLE `stock_transactions` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);



-- Add shop_id to company_profile (convert to per-shop profiles)
ALTER TABLE `company_profile` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD UNIQUE KEY `unique_tax_id_shop` (`tax_id`, `shop_id`),
ADD KEY `idx_shop_id` (`shop_id`),
DROP KEY `unique_tax_id`,
DROP KEY `unique_email`,
ADD UNIQUE KEY `unique_email_shop` (`email`, `shop_id`);

-- Add shop_id to printer_config table
ALTER TABLE `printer_config` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to device_auth table
ALTER TABLE `device_auth_settings` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
ADD KEY `idx_shop_id` (`shop_id`);

-- =====================================================
-- OPTIONAL TABLES - UNCOMMENT IF THEY EXIST IN YOUR DB
-- =====================================================

-- Add shop_id to order_items table (if exists)
-- ALTER TABLE `order_items` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to order_items_gst table (if exists)
-- ALTER TABLE `order_items_gst` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to customers/customer_details table (if exists)
-- ALTER TABLE `customer_details` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to vendors table (if exists)
-- ALTER TABLE `vendors` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- Add shop_id to vending_machine table (if exists)
-- ALTER TABLE `vending_machine` 
-- ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
-- ADD FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE,
-- ADD KEY `idx_shop_id` (`shop_id`);

-- =====================================================
-- STEP 8: CREATE INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_shops_subscription_status ON shops(subscription_status, is_active);
CREATE INDEX idx_shops_created_at ON shops(created_at);
CREATE INDEX idx_shop_billing_by_shop ON shop_billing(shop_id, billing_period_start);
CREATE INDEX shop table already exist only add alter command to add shop id  ON shop_audit_logs(shop_id, action, created_at);

-- ===================================================
-- MIGRATION COMPLETE
-- ===================================================
-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=1;

-- Next steps:
-- 1. Update backend middleware to enforce shop_id context
-- 2. Create super admin dashboard
-- 3. Update API endpoints to filter by shop_id
-- 4. Create shop management pages
-- 5. Implement tenant isolation in queries
-- ===================================================
