-- Clear all records from items and related tables (in correct order due to foreign key constraints)

-- First, clear stock_transactions (references product_units)
DELETE FROM `stock_transactions`;
ALTER TABLE `stock_transactions` AUTO_INCREMENT = 1;

-- Then clear product_units (referenced by items)
DELETE FROM `product_units`;
ALTER TABLE `product_units` AUTO_INCREMENT = 1;

-- Clear all records from items table
DELETE FROM `items`;

-- Reset auto-increment counter
ALTER TABLE `items` AUTO_INCREMENT = 1;
