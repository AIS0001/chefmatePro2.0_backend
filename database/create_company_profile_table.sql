-- Create Company Profile Table
-- This table stores company information and settings
-- Run on the chefmatepro database

CREATE TABLE IF NOT EXISTS `company_profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL COMMENT 'Foreign key to shops table for multi-tenant data isolation',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Company name (required)',
  `tax_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tax identification number (required)',
  `phone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary phone number (required)',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary email address (required)',
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Complete address (required)',
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Company website URL',
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'City',
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'State/Province',
  `zip_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ZIP/Postal code',
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Country',
  `logo` longblob COMMENT 'Company logo image (BLOB)',
  `logo_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Logo MIME type (e.g., image/png)',
  `logo_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Original logo filename',
  `qr_code` longblob COMMENT 'QR code image (BLOB)',
  `qr_code_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QR code MIME type',
  `qr_code_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Original QR code filename',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank name',
  `account_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank account number',
  `account_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Account holder name',
  `routing_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank routing number',
  `swift_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SWIFT/BIC code',
  `payment_methods` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Accepted payment methods',
  `terms_and_conditions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Terms and conditions text',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
  `created_by` int DEFAULT NULL COMMENT 'User ID who created the record',
  `updated_by` int DEFAULT NULL COMMENT 'User ID who last updated the record',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active status (1=active, 0=inactive)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_shop_tax_id` (`shop_id`, `tax_id`),
  UNIQUE KEY `unique_shop_email` (`shop_id`, `email`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_company_name` (`name`),
  KEY `idx_city` (`city`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_company_profile_search` (`shop_id`, `name`, `email`, `city`),
  KEY `idx_company_profile_status` (`shop_id`, `is_active`, `created_at`),
  CONSTRAINT `fk_company_profile_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company information and settings - Multi-tenant per shop';

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS `company_profile_before_update`;

-- Create trigger to auto-update the updated_at timestamp
DELIMITER $$
CREATE TRIGGER `company_profile_before_update` BEFORE UPDATE ON `company_profile` FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$
DELIMITER ;
