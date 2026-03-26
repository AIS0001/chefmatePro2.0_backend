-- ======================================================================
-- ADD SHOP_ID WITH FOREIGN KEY CONSTRAINTS
-- ======================================================================

-- First, ensure the shops table exists (if not already)
-- CREATE TABLE IF NOT EXISTS `shops` (
--   `id` INT PRIMARY KEY AUTO_INCREMENT,
--   `name` VARCHAR(255) NOT NULL,
--   `status` INT DEFAULT 1,
--   `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ======================================================================
-- 1. DAY CLOSE SUMMARY TABLE
-- ======================================================================

ALTER TABLE `day_close_summary` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_day_close_summary_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Create index for better performance
CREATE INDEX `idx_day_close_summary_shop_id` ON `day_close_summary` (`shop_id`);

-- ======================================================================
-- 2. ORDERS TABLE
-- ======================================================================

ALTER TABLE `orders` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_orders_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_orders_shop_id` ON `orders` (`shop_id`);

-- ======================================================================
-- 3. ORDER ITEMS TABLE
-- ======================================================================

ALTER TABLE `order_items` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_order_items_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_order_items_shop_id` ON `order_items` (`shop_id`);

-- ======================================================================
-- 4. FINAL BILL TABLE
-- ======================================================================

ALTER TABLE `final_bill` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_final_bill_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_final_bill_shop_id` ON `final_bill` (`shop_id`);

-- ======================================================================
-- 5. USERS TABLE
-- ======================================================================

ALTER TABLE `users` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_users_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_users_shop_id` ON `users` (`shop_id`);

-- ======================================================================
-- 6. ITEMS TABLE
-- ======================================================================

ALTER TABLE `items` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_items_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_items_shop_id` ON `items` (`shop_id`);

-- ======================================================================
-- 7. CUSTOMERS TABLE
-- ======================================================================

ALTER TABLE `customers` 
ADD COLUMN `shop_id` INT DEFAULT 1 AFTER `id`,
ADD CONSTRAINT `fk_customers_shop_id` 
FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX `idx_customers_shop_id` ON `customers` (`shop_id`);

-- ======================================================================
-- VERIFICATION QUERIES
-- ======================================================================

-- Verify all tables have shop_id
-- SELECT TABLE_NAME, COLUMN_NAME 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE COLUMN_NAME = 'shop_id' AND TABLE_SCHEMA = 'chefmatepro2';

-- Verify all foreign keys
-- SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME 
-- FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
-- WHERE REFERENCED_TABLE_NAME = 'shops' AND TABLE_SCHEMA = 'chefmatepro2';
