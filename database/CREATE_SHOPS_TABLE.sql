-- ======================================================================
-- SHOPS TABLE DEFINITION
-- Run this FIRST before adding foreign keys
-- ======================================================================

CREATE TABLE IF NOT EXISTS `shops` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `alias` VARCHAR(100),
  `address` TEXT,
  `phone` VARCHAR(20),
  `email` VARCHAR(100),
  `status` INT DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_shop_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ======================================================================
-- INSERT DEFAULT SHOP (if not already exists)
-- ======================================================================

INSERT IGNORE INTO `shops` (`id`, `name`, `alias`, `status`) 
VALUES (1, 'Default Shop', 'DEFAULT', 1);

-- ======================================================================
-- VERIFICATION
-- ======================================================================

-- SELECT * FROM `shops`;
