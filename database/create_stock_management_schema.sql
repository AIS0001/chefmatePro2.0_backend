-- Enhanced Stock Management System
-- This schema supports complex inventory tracking with unit conversions

-- Drop existing tables if they exist (for fresh install)
-- DROP TABLE IF EXISTS `stock_conversions`;
-- DROP TABLE IF EXISTS `stock_transactions`;
-- DROP TABLE IF EXISTS `product_units`;
-- DROP TABLE IF EXISTS `product_variants`;

-- =====================================================
-- Table: product_units
-- Stores base units for products
-- =====================================================
CREATE TABLE IF NOT EXISTS `product_units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `unit_name` varchar(50) NOT NULL COMMENT 'e.g., Bottle, Can, Piece, Liter, ML',
  `unit_type` varchar(20) NOT NULL COMMENT 'BASE, DERIVED',
  `conversion_factor` decimal(10,2) DEFAULT 1.00 COMMENT 'Conversion factor to base unit',
  `is_base_unit` tinyint(1) DEFAULT 0,
  `ml_capacity` int(11) DEFAULT NULL COMMENT 'For liquor bottles - ML capacity',
  `purchase_price` decimal(10,2) DEFAULT 0.00,
  `selling_price` decimal(10,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_product_units_item` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- Table: stock_conversions
-- Defines conversion rules between units
-- =====================================================
CREATE TABLE IF NOT EXISTS `stock_conversions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `from_unit_id` int(11) NOT NULL,
  `to_unit_id` int(11) NOT NULL,
  `conversion_factor` decimal(10,4) NOT NULL COMMENT 'Multiply from_unit by this to get to_unit',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_conversion` (`product_id`),
  KEY `idx_from_unit` (`from_unit_id`),
  KEY `idx_to_unit` (`to_unit_id`),
  UNIQUE KEY `unique_conversion` (`product_id`, `from_unit_id`, `to_unit_id`),
  CONSTRAINT `fk_conversion_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversion_from_unit` FOREIGN KEY (`from_unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversion_to_unit` FOREIGN KEY (`to_unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- Table: stock_transactions
-- Tracks all stock additions and deductions with reasons
-- =====================================================
CREATE TABLE IF NOT EXISTS `stock_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `transaction_type` varchar(20) NOT NULL COMMENT 'ADD, REMOVE, ADJUST, SALE',
  `unit_id` int(11) NOT NULL,
  `quantity` decimal(10,4) NOT NULL,
  `quantity_in_ml` decimal(15,2) DEFAULT NULL COMMENT 'For liquor - quantity in ML',
  `reference_type` varchar(50) DEFAULT NULL COMMENT 'PURCHASE, SALE, WASTE, DAMAGE, INVENTORY_ADJUSTMENT',
  `reference_id` int(11) DEFAULT NULL COMMENT 'ID from related table',
  `user_id` int(11) DEFAULT NULL,
  `notes` text,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_transaction_date` (`transaction_date`),
  KEY `idx_reference` (`reference_type`, `reference_id`),
  CONSTRAINT `fk_stock_trans_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stock_trans_unit` FOREIGN KEY (`unit_id`) REFERENCES `product_units` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- Table: stock_balance
-- Real-time stock balance for each unit
-- =====================================================
CREATE TABLE IF NOT EXISTS `stock_balance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `current_quantity` decimal(10,4) NOT NULL DEFAULT 0,
  `reserved_quantity` decimal(10,4) NOT NULL DEFAULT 0 COMMENT 'Quantity reserved for pending orders',
  `available_quantity` decimal(10,4) GENERATED ALWAYS AS (`current_quantity` - `reserved_quantity`) STORED,
  `last_updated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_product_unit` (`product_id`, `unit_id`),
  KEY `idx_product_stock` (`product_id`),
  CONSTRAINT `fk_stock_balance_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stock_balance_unit` FOREIGN KEY (`unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- Table: product_variants
-- For items like Whiskey with different serving sizes
-- =====================================================
CREATE TABLE IF NOT EXISTS `product_variants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `variant_name` varchar(100) NOT NULL COMMENT 'e.g., Whiskey 30ML Peg, Whiskey 60ML, Full Bottle',
  `base_unit_id` int(11) NOT NULL COMMENT 'Unit it is based on (e.g., Bottle)',
  `quantity_in_base_unit` decimal(10,4) NOT NULL COMMENT 'e.g., 0.25 bottles = 1 peg of 30ML',
  `ml_quantity` int(11) DEFAULT NULL COMMENT 'e.g., 30 for 30ML peg',
  `selling_price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_variant` (`product_id`),
  KEY `idx_base_unit` (`base_unit_id`),
  CONSTRAINT `fk_variant_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_variant_base_unit` FOREIGN KEY (`base_unit_id`) REFERENCES `product_units` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- Sample Data for Testing
-- =====================================================

-- Example: Add units for Whiskey (750ML bottle)
-- INSERT INTO product_units (product_id, unit_name, unit_type, conversion_factor, is_base_unit, ml_capacity, selling_price) 
-- VALUES 
-- (126, 'Bottle', 'BASE', 1.00, 1, 750, 3000),
-- (126, '30ML Peg', 'DERIVED', 0.04, 0, 30, 150),
-- (126, '60ML Peg', 'DERIVED', 0.08, 0, 60, 300),
-- (126, 'ML', 'DERIVED', 0.00133, 0, NULL, 0);

-- Example: Add units for Coke
-- INSERT INTO product_units (product_id, unit_name, unit_type, conversion_factor, is_base_unit, selling_price)
-- VALUES
-- (127, 'Can', 'BASE', 1.00, 1, NULL, 80),
-- (127, 'Piece', 'BASE', 1.00, 1, NULL, 80),
-- (127, 'Crate', 'DERIVED', 24.00, 0, NULL, 0);

-- Example: Add stock conversions for Whiskey
-- INSERT INTO stock_conversions (product_id, from_unit_id, to_unit_id, conversion_factor)
-- SELECT p.id, pu1.id, pu2.id, 25 
-- FROM items p
-- JOIN product_units pu1 ON p.id = pu1.product_id AND pu1.unit_name = 'Bottle'
-- JOIN product_units pu2 ON p.id = pu2.product_id AND pu2.unit_name = '30ML Peg'
-- WHERE p.id = 126;
