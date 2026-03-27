-- ======================================================================
-- ADD SHOP_ID COLUMN TO ALL TABLES (EXCLUDING SUPER ADMIN TABLES)
-- ======================================================================

-- ======================================================================
-- 1. ORDERS TABLE
-- ======================================================================
ALTER TABLE `orders` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_orders_shop_id` ON `orders` (`shop_id`);

-- ======================================================================
-- 2. ORDER ITEMS TABLE
-- ======================================================================
ALTER TABLE `order_items` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_order_items_shop_id` ON `order_items` (`shop_id`);

-- ======================================================================
-- 3. FINAL BILL TABLE
-- ======================================================================
ALTER TABLE `final_bill` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_final_bill_shop_id` ON `final_bill` (`shop_id`);

ALTER TABLE `subcategory` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_subcategory_shop_id` ON `subcategory` (`shop_id`);


ALTER TABLE `ledger_entries` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_ledger_entries_shop_id` ON `ledger_entries` (`shop_id`);


ALTER TABLE `payment_vouchers` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_payment_vouchers_shop_id` ON `payment_vouchers` (`shop_id`);
-- ======================================================================
-- 4. USERS TABLE
-- ======================================================================
ALTER TABLE `users` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`,
ADD COLUMN `user_uuid` VARCHAR(36) UNIQUE;

CREATE INDEX `idx_users_shop_id` ON `users` (`shop_id`);
CREATE INDEX `idx_users_uuid` ON `users` (`user_uuid`);

-- ======================================================================
-- 5. ITEMS TABLE
-- ======================================================================
ALTER TABLE `items` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_items_shop_id` ON `items` (`shop_id`);

-- ======================================================================
-- 6. CUSTOMERS TABLE
-- ======================================================================
ALTER TABLE `customers` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_customers_shop_id` ON `customers` (`shop_id`);

-- ======================================================================
-- 7. DAY CLOSE SUMMARY TABLE
-- ======================================================================
ALTER TABLE `day_close_summary` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_day_close_summary_shop_id` ON `day_close_summary` (`shop_id`);

-- ======================================================================
-- 8. QUOTATIONS TABLE
-- ======================================================================
ALTER TABLE `quotation` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_quotation_shop_id` ON `quotation` (`shop_id`);

-- ======================================================================
-- 9. QUOTATION ITEMS TABLE
-- ======================================================================
ALTER TABLE `quotation_items` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_quotation_items_shop_id` ON `quotation_items` (`shop_id`);

-- ======================================================================
-- 10. ORDER ITEMS GST TABLE
-- ======================================================================
ALTER TABLE `order_items_gst` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_order_items_gst_shop_id` ON `order_items_gst` (`shop_id`);

-- ======================================================================
-- 11. PRINTER CONFIG TABLE
-- ======================================================================
ALTER TABLE `printer_config` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_printer_config_shop_id` ON `printer_config` (`shop_id`);

-- ======================================================================
-- 12. PAYMENT METHODS TABLE
-- ======================================================================
ALTER TABLE `payment_methods` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_payment_methods_shop_id` ON `payment_methods` (`shop_id`);

-- ======================================================================
-- 13. TABLE CATEGORIES TABLE
-- ======================================================================
ALTER TABLE `table_category` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_table_categories_shop_id` ON `table_categories` (`shop_id`);

-- ======================================================================
-- 14. TABLES TABLE
-- ======================================================================
ALTER TABLE `tablelist` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_tables_shop_id` ON `tablelist` (`shop_id`);

-- ======================================================================
-- 15. DEVICE AUTH TABLE
-- ======================================================================
ALTER TABLE `user_devices` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_user_devices_shop_id` ON `user_devices` (`shop_id`);

-- ======================================================================
-- 16. STOCK TABLE
-- ======================================================================
ALTER TABLE `stock` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_stock_shop_id` ON `stock` (`shop_id`);

-- ======================================================================
-- 17. STOCK MOVEMENT TABLE
-- ======================================================================
ALTER TABLE `stock_movement` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_stock_movement_shop_id` ON `stock_movement` (`shop_id`);

-- ======================================================================
-- 18. SETTINGS TABLE
-- ======================================================================
ALTER TABLE `settings` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_settings_shop_id` ON `settings` (`shop_id`);

-- ======================================================================
-- 19. FEATURES TABLE
-- ======================================================================
ALTER TABLE `features` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_features_shop_id` ON `features` (`shop_id`);

-- ======================================================================
-- 20. USER FEATURES TABLE
-- ======================================================================
ALTER TABLE `user_features` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_user_features_shop_id` ON `user_features` (`shop_id`);


ALTER TABLE `printer_settings` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_printer_settings_shop_id` ON `printer_settings` (`shop_id`);

ALTER TABLE `printer_settings` 
ADD COLUMN `shop_id` INT DEFAULT 1 NOT NULL AFTER `id`;

CREATE INDEX `idx_printer_settings_shop_id` ON `printer_settings` (`shop_id`);

-- ======================================================================
-- NOTES
-- ======================================================================
-- All tables now have:
-- 1. shop_id column with default value 1
-- 2. Index on shop_id for query performance
-- 
-- Tables EXCLUDED (Super Admin Related):
-- - super_admin_users
-- - admin_logs
-- - super_admin_settings
--
-- Do NOT add foreign key constraints here if tables are being migrated
-- from existing data. Foreign keys should be added in a separate script
-- after data verification.
