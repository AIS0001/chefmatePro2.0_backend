-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 13, 2026 at 09:13 AM
-- Server version: 8.4.7
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `chefmatepro_2`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `GetActiveCompanyInfo`$$
CREATE DEFINER=`chefmatepro2`@`localhost` PROCEDURE `GetActiveCompanyInfo` ()   BEGIN
  SELECT * FROM `company_profile` 
  WHERE `is_active` = 1 
  ORDER BY `created_at` DESC 
  LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `GetUserFeatures`$$
CREATE DEFINER=`chefmatepro2`@`localhost` PROCEDURE `GetUserFeatures` (IN `p_user_id` INT)   BEGIN
    SELECT 
        feature_code,
        feature_name,
        feature_category,
        is_enabled,
        feature_level,
        usage_limit,
        current_usage,
        usage_status
    FROM v_user_features
    WHERE user_id = p_user_id
    ORDER BY feature_category, feature_name;
END$$

DROP PROCEDURE IF EXISTS `UpdateCompanyInfo`$$
CREATE DEFINER=`chefmatepro2`@`localhost` PROCEDURE `UpdateCompanyInfo` (IN `p_id` INT, IN `p_name` VARCHAR(255), IN `p_tax_id` VARCHAR(100), IN `p_phone` VARCHAR(50), IN `p_email` VARCHAR(255), IN `p_address` TEXT, IN `p_website` VARCHAR(255), IN `p_city` VARCHAR(100), IN `p_state` VARCHAR(100), IN `p_zip` VARCHAR(20), IN `p_country` VARCHAR(100), IN `p_updated_by` INT)   BEGIN
  UPDATE `company_profile` 
  SET 
    `name` = p_name,
    `tax_id` = p_tax_id,
    `phone_number` = p_phone,
    `email` = p_email,
    `address` = p_address,
    `website` = p_website,
    `city` = p_city,
    `state` = p_state,
    `zip_code` = p_zip,
    `country` = p_country,
    `updated_by` = p_updated_by,
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = p_id;
END$$

DROP PROCEDURE IF EXISTS `UpdateFeatureUsage`$$
CREATE DEFINER=`chefmatepro2`@`localhost` PROCEDURE `UpdateFeatureUsage` (IN `p_user_id` INT, IN `p_feature_code` VARCHAR(50), IN `p_increment` INT)   BEGIN
    INSERT INTO feature_usage (user_id, feature_code, current_usage)
    VALUES (p_user_id, p_feature_code, p_increment)
    ON DUPLICATE KEY UPDATE 
        current_usage = current_usage + p_increment,
        updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `advance_final_bill`
--

DROP TABLE IF EXISTS `advance_final_bill`;
CREATE TABLE IF NOT EXISTS `advance_final_bill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `customer_id` int DEFAULT NULL,
  `inv_date` date NOT NULL,
  `inv_time` time(6) NOT NULL,
  `table_number` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `discount_type` varchar(10) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `discount_value` float NOT NULL,
  `discount_amount` float NOT NULL,
  `subtotal_afterdiscount` float NOT NULL DEFAULT '0',
  `tax` decimal(15,2) NOT NULL,
  `roundoff` float NOT NULL DEFAULT '0',
  `grand_total` decimal(15,2) NOT NULL,
  `payment_mode` enum('Cash','Credit','Card','UPI','Split') COLLATE utf8mb4_general_ci NOT NULL,
  `setup_dte` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `final_billed` tinyint(1) NOT NULL,
  `bill_generated_by` varchar(15) COLLATE utf8mb4_general_ci NOT NULL,
  `pickup_date` date NOT NULL,
  `pickup_time` time(6) DEFAULT NULL,
  `special_note` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `order_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `created_by` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `advance_orders`
--

DROP TABLE IF EXISTS `advance_orders`;
CREATE TABLE IF NOT EXISTS `advance_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `userid` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  `order_number` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `advance_order_items`
--

DROP TABLE IF EXISTS `advance_order_items`;
CREATE TABLE IF NOT EXISTS `advance_order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `order_id` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` int NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `advance_order_items_gst`
--

DROP TABLE IF EXISTS `advance_order_items_gst`;
CREATE TABLE IF NOT EXISTS `advance_order_items_gst` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` int NOT NULL,
  `uom` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `rate` decimal(10,2) NOT NULL,
  `cgst` decimal(10,2) NOT NULL,
  `sgst` decimal(10,2) NOT NULL,
  `igst` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bill_edit_logs`
--

DROP TABLE IF EXISTS `bill_edit_logs`;
CREATE TABLE IF NOT EXISTS `bill_edit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `bill_id` int NOT NULL,
  `order_item_id` int DEFAULT NULL,
  `action` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `old_qty` decimal(10,2) DEFAULT NULL,
  `new_qty` decimal(10,2) DEFAULT NULL,
  `old_total` decimal(10,2) DEFAULT NULL,
  `new_total` decimal(10,2) DEFAULT NULL,
  `old_subtotal` decimal(10,2) DEFAULT NULL,
  `new_subtotal` decimal(10,2) DEFAULT NULL,
  `old_subtotal_afterdiscount` decimal(10,2) DEFAULT NULL,
  `new_subtotal_afterdiscount` decimal(10,2) DEFAULT NULL,
  `old_tax` decimal(10,2) DEFAULT NULL,
  `new_tax` decimal(10,2) DEFAULT NULL,
  `old_total_amount` decimal(10,2) DEFAULT NULL,
  `new_total_amount` decimal(10,2) DEFAULT NULL,
  `old_round_off` decimal(10,2) DEFAULT NULL,
  `new_round_off` decimal(10,2) DEFAULT NULL,
  `old_grand_total` decimal(10,2) DEFAULT NULL,
  `new_grand_total` decimal(10,2) DEFAULT NULL,
  `old_discount_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `new_discount_type` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `old_discount_value` decimal(10,2) DEFAULT NULL,
  `new_discount_value` decimal(10,2) DEFAULT NULL,
  `user_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `user_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `terminal_id` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip_address` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `modified_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bill_edit_logs_bill_id` (`bill_id`),
  KEY `idx_bill_edit_logs_order_item_id` (`order_item_id`),
  KEY `idx_bill_edit_logs_modified_at` (`modified_at`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `blocked_mac_addresses`
--

DROP TABLE IF EXISTS `blocked_mac_addresses`;
CREATE TABLE IF NOT EXISTS `blocked_mac_addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mac_address` varchar(17) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci COMMENT 'Why blocked',
  `blocked_by_user_id` int DEFAULT NULL COMMENT 'Admin who blocked',
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mac_address` (`mac_address`),
  KEY `idx_mac_address` (`mac_address`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cash_drawer`
--

DROP TABLE IF EXISTS `cash_drawer`;
CREATE TABLE IF NOT EXISTS `cash_drawer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `open_date` date NOT NULL,
  `opening_cash` decimal(10,2) NOT NULL DEFAULT '0.00',
  `closing_cash` decimal(10,2) NOT NULL DEFAULT '0.00',
  `expected_cash` decimal(10,2) NOT NULL DEFAULT '0.00',
  `cash_difference` decimal(10,2) NOT NULL DEFAULT '0.00',
  `cash_in` decimal(10,2) NOT NULL DEFAULT '0.00',
  `cash_out` decimal(10,2) NOT NULL DEFAULT '0.00',
  `opened_by` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `closed_by` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `opening_time` timestamp NULL DEFAULT NULL,
  `closing_time` timestamp NULL DEFAULT NULL,
  `status` enum('open','closed') COLLATE utf8mb4_general_ci DEFAULT 'open',
  `notes` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_open_date` (`open_date`),
  KEY `idx_status` (`status`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cash_drawer`
--

INSERT INTO `cash_drawer` (`id`, `shop_id`, `open_date`, `opening_cash`, `closing_cash`, `expected_cash`, `cash_difference`, `cash_in`, `cash_out`, `opened_by`, `closed_by`, `opening_time`, `closing_time`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(20, 4, '2026-03-27', 0.00, 300.00, 300.00, 0.00, 0.00, 0.00, NULL, '63651', NULL, '2026-03-27 04:31:30', 'closed', '', '2026-03-27 11:31:30', '2026-03-27 11:31:30'),
(22, 5, '2026-03-31', 0.00, 1760.00, 1760.00, 0.00, 0.00, 0.00, NULL, '18594', NULL, '2026-04-02 07:46:38', 'closed', '', '2026-04-02 07:46:39', '2026-04-02 07:46:39'),
(23, 5, '2026-04-01', 0.00, 1030.00, 1030.00, 0.00, 0.00, 0.00, NULL, '18594', NULL, '2026-04-05 06:51:54', 'closed', '', '2026-04-05 06:51:55', '2026-04-05 06:51:55'),
(24, 8, '2026-04-05', 2000.00, 320.00, 300.00, 20.00, 0.00, 0.00, NULL, '79969', NULL, '2026-04-05 07:56:58', 'closed', 'fguyuyfyuv hggklhjhjhgioipojiou kjp', '2026-04-05 07:56:58', '2026-04-05 07:56:58'),
(25, 8, '2026-04-06', 0.00, 1040.00, 1014.00, 26.00, 0.00, 0.00, NULL, '79969', NULL, '2026-05-10 08:53:05', 'closed', '', '2026-05-10 08:53:05', '2026-05-10 08:53:05'),
(26, 5, '2026-04-02', 0.00, 9650.00, 9650.00, 0.00, 0.00, 0.00, NULL, '18594', NULL, '2026-05-10 09:23:43', 'closed', '', '2026-05-10 09:23:43', '2026-05-10 09:23:43'),
(27, 5, '2026-04-03', 2000.00, 500.00, 570.00, -15.00, 0.00, 55.00, NULL, '18594', NULL, '2026-05-10 14:02:42', 'closed', 'expenses 55 short 15', '2026-05-10 14:02:42', '2026-05-10 14:02:42'),
(28, 5, '2026-04-04', 2000.00, 800.00, 810.00, 0.00, 0.00, 10.00, NULL, '18594', NULL, '2026-05-10 14:08:44', 'closed', '', '2026-05-10 14:08:44', '2026-05-10 14:08:44');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `name` varchar(233) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `shop_id`, `name`) VALUES
(46, 4, 'Food'),
(47, 5, 'Food'),
(48, 5, 'Liquer'),
(49, 7, 'Indian Food'),
(50, 7, 'Thai Food'),
(51, 7, 'Drinks'),
(52, 8, 'LIQUEUR'),
(53, 8, 'DRINKS'),
(54, 8, 'CUISINE'),
(55, 8, 'BREAKFAST'),
(56, 9, 'Food'),
(57, 9, 'Liquer'),
(58, 9, 'Room');

-- --------------------------------------------------------

--
-- Table structure for table `companyinfo`
--

DROP TABLE IF EXISTS `companyinfo`;
CREATE TABLE IF NOT EXISTS `companyinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `tax_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `address` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_profile`
--

DROP TABLE IF EXISTS `company_profile`;
CREATE TABLE IF NOT EXISTS `company_profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Company name (required)',
  `tax_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tax identification number (required)',
  `phone_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary phone number (required)',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary email address (required)',
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Complete address (required)',
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Company website URL',
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'City',
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'State/Province',
  `zip_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ZIP/Postal code',
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Country',
  `logo` longblob COMMENT 'Company logo image (BLOB)',
  `logo_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Logo MIME type (e.g., image/png)',
  `logo_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Original logo filename',
  `qr_code` longblob COMMENT 'QR code image (BLOB)',
  `qr_code_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QR code MIME type',
  `qr_code_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Original QR code filename',
  `bank_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank name',
  `account_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank account number',
  `account_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Account holder name',
  `routing_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bank routing number',
  `swift_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SWIFT/BIC code',
  `payment_methods` text COLLATE utf8mb4_unicode_ci COMMENT 'Accepted payment methods',
  `terms_and_conditions` text COLLATE utf8mb4_unicode_ci COMMENT 'Terms and conditions text',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
  `created_by` int DEFAULT NULL COMMENT 'User ID who created the record',
  `updated_by` int DEFAULT NULL COMMENT 'User ID who last updated the record',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Active status (1=active, 0=inactive)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tax_id_shop` (`tax_id`,`shop_id`),
  UNIQUE KEY `unique_email_shop` (`email`,`shop_id`),
  KEY `idx_company_name` (`name`),
  KEY `idx_city` (`city`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_company_profile_search` (`name`,`email`,`city`),
  KEY `idx_company_profile_status` (`is_active`,`created_at`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company information and settings';

--
-- Dumping data for table `company_profile`
--

INSERT INTO `company_profile` (`id`, `shop_id`, `name`, `tax_id`, `phone_number`, `email`, `address`, `website`, `city`, `state`, `zip_code`, `country`, `logo`, `logo_type`, `logo_name`, `qr_code`, `qr_code_type`, `qr_code_name`, `bank_name`, `account_number`, `account_name`, `routing_number`, `swift_code`, `payment_methods`, `terms_and_conditions`, `created_at`, `updated_at`, `created_by`, `updated_by`, `is_active`) VALUES
(3, 4, 'Cloud7', '4525545465', '+6698653256', 'cloud7@gmail.com', 'Sout Pataya Chonburi', 'https://www.cloud7.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-27 09:55:23', '2026-03-27 16:09:03', NULL, NULL, 1),
(5, 5, 'Demo Restaurant', '12345678930', '+661234567898', 'demo@gmail.com', '125/56,Near Demo,Demo City China ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-28 19:32:43', '2026-05-13 08:33:55', NULL, NULL, 1),
(7, 7, 'JASLEEN RESTAURANT', 'xxxxxxxxxxxxx', '+66 84 848 6868', 'info@jasleenindianfood.com', '100 21 Soi Kamala 12, Kamala Kathu District, Phuket 83150, Thailand', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-29 05:14:44', '2026-03-29 05:14:44', NULL, NULL, 1),
(9, 8, 'SUNRISE CAFE & RESTAURANT', 'XXXXXXXX', '+66-805401625', 'rajkirthwal@outlook.com', '31/3 Sukhumvit Soi 48 Phra Khanong Khlong Toei Bangkok', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-02 08:21:56', '2026-05-08 07:23:14', NULL, NULL, 1),
(11, 9, 'WELCOME SUIT', '0205565021365', '+66-800062602', 'welcomesuit@gmail.com', '249/29-30 Moo 10, Muang Pattaya, Bang Lamung District, Chon Buri 20150', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-13 06:32:41', '2026-05-13 08:38:02', NULL, NULL, 1);

--
-- Triggers `company_profile`
--
DROP TRIGGER IF EXISTS `company_profile_before_update`;
DELIMITER $$
CREATE TRIGGER `company_profile_before_update` BEFORE UPDATE ON `company_profile` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `coresetting`
--

DROP TABLE IF EXISTS `coresetting`;
CREATE TABLE IF NOT EXISTS `coresetting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  `tax_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `region` varchar(33) COLLATE utf8mb4_general_ci NOT NULL,
  `currency` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(33) COLLATE utf8mb4_general_ci NOT NULL,
  `valid_till` date NOT NULL,
  `status` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coresetting`
--

INSERT INTO `coresetting` (`id`, `customer_name`, `tax_type`, `region`, `currency`, `type`, `valid_till`, `status`) VALUES
(11, 'Banglore Cafe', 'VAT', 'TH', 'THB', 'Basic', '2026-06-14', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL,
  `contact` bigint NOT NULL,
  `email` varchar(233) NOT NULL,
  `taxid` varchar(233) DEFAULT NULL,
  `address` varchar(233) DEFAULT NULL,
  `createdon` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `shop_id`, `name`, `contact`, `email`, `taxid`, `address`, `createdon`) VALUES
(22, 5, 'See Yong', 11111111111, 'ggkjbjk@gmail.com', '', 'nhknji', '2026-03-31 16:07:30'),
(23, 5, 'Vinod Kumar Kumar', 9816846663, 'axialtour@gmail.com', '', 'vill tikkar rajputan po bumbloo', '2026-03-31 17:04:23'),
(24, 5, 'Cicada', 992799977, 'cicada@gmail.com', '', 'Pattaya', '2026-05-12 07:08:37');

-- --------------------------------------------------------

--
-- Table structure for table `day_close_summary`
--

DROP TABLE IF EXISTS `day_close_summary`;
CREATE TABLE IF NOT EXISTS `day_close_summary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `close_date` date NOT NULL,
  `total_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `cash_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `upi_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `card_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `qr_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `bank_transfer_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `online_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `entertainment_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `other_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_orders` int NOT NULL DEFAULT '0',
  `total_items_sold` int NOT NULL DEFAULT '0',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `net_sales` decimal(12,2) NOT NULL DEFAULT '0.00',
  `opened_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `closed_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opening_time` timestamp NULL DEFAULT NULL,
  `closing_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('open','closed') COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `close_date_shop_id` (`close_date`,`shop_id`),
  KEY `idx_status` (`status`),
  KEY `idx_day_close_summary_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `day_close_summary`
--

INSERT INTO `day_close_summary` (`id`, `shop_id`, `close_date`, `total_sales`, `cash_sales`, `upi_sales`, `card_sales`, `qr_sales`, `bank_transfer_sales`, `online_sales`, `entertainment_sales`, `other_sales`, `total_orders`, `total_items_sold`, `discount_amount`, `tax_amount`, `net_sales`, `opened_by`, `closed_by`, `opening_time`, `closing_time`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(25, 4, '2026-03-27', 300.00, 300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 2, 0.00, 0.00, 300.00, NULL, '63651', NULL, '2026-03-27 04:31:30', 'closed', '', '2026-03-27 11:31:30', '2026-03-27 11:31:30'),
(27, 5, '2026-03-31', 5740.00, 1760.00, 0.00, 610.00, 0.00, 0.00, 0.00, 0.00, 0.00, 10, 45, 0.00, 0.00, 5740.00, NULL, '18594', NULL, '2026-04-02 07:46:38', 'closed', '', '2026-04-02 07:46:39', '2026-04-02 07:46:39'),
(28, 5, '2026-04-01', 4135.00, 1030.00, 0.00, 0.00, 1890.00, 0.00, 0.00, 0.00, 0.00, 5, 36, 0.00, 0.00, 4135.00, NULL, '18594', NULL, '2026-04-05 06:51:54', 'closed', '', '2026-04-05 06:51:55', '2026-04-05 06:51:55'),
(29, 8, '2026-04-05', 1200.00, 300.00, 0.00, 900.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2, 12, 0.00, 0.00, 1200.00, NULL, '79969', NULL, '2026-04-05 07:56:58', 'closed', 'fguyuyfyuv hggklhjhjhgioipojiou kjp', '2026-04-05 07:56:58', '2026-04-05 07:56:58'),
(30, 8, '2026-04-06', 3049.00, 1014.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2035.00, 0.00, 10, 18, 0.00, 0.00, 3049.00, NULL, '79969', NULL, '2026-05-10 08:53:05', 'closed', '', '2026-05-10 08:53:05', '2026-05-10 08:53:05'),
(31, 8, '2026-05-09', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, NULL, '79969', NULL, '2026-05-10 08:53:17', 'closed', '', '2026-05-10 08:53:17', '2026-05-10 08:53:17'),
(32, 5, '2026-04-02', 9650.00, 9650.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4, 81, 0.00, 0.00, 9650.00, NULL, '18594', NULL, '2026-05-10 09:23:43', 'closed', '', '2026-05-10 09:23:43', '2026-05-10 09:23:43'),
(33, 5, '2026-04-03', 570.00, 570.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 8, 0.00, 0.00, 570.00, NULL, '18594', NULL, '2026-05-10 14:02:42', 'closed', 'expenses 55 short 15', '2026-05-10 14:02:42', '2026-05-10 14:02:42'),
(34, 5, '2026-04-04', 810.00, 810.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2, 8, 0.00, 0.00, 810.00, NULL, '18594', NULL, '2026-05-10 14:08:44', 'closed', '', '2026-05-10 14:08:44', '2026-05-10 14:08:44');

-- --------------------------------------------------------

--
-- Table structure for table `device_auth_settings`
--

DROP TABLE IF EXISTS `device_auth_settings`;
CREATE TABLE IF NOT EXISTS `device_auth_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `user_id` int DEFAULT NULL COMMENT 'NULL = Global setting',
  `enable_mac_auth` tinyint(1) DEFAULT '0' COMMENT 'Enable MAC authentication',
  `allow_multiple_devices` tinyint(1) DEFAULT '1' COMMENT 'Allow multiple devices',
  `require_first_device` tinyint(1) DEFAULT '0' COMMENT 'Must use first device',
  `block_new_devices` tinyint(1) DEFAULT '0' COMMENT 'Block unregistered MACs',
  `max_devices_per_user` int DEFAULT '3' COMMENT 'Maximum devices per user',
  `require_admin_approval` tinyint(1) DEFAULT '0' COMMENT 'Needs admin approval',
  `session_timeout_hours` int DEFAULT '24' COMMENT 'Session timeout',
  `allow_device_override` tinyint(1) DEFAULT '0' COMMENT 'User can add devices',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `error_logs`
--

DROP TABLE IF EXISTS `error_logs`;
CREATE TABLE IF NOT EXISTS `error_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `error_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., DATABASE, API, VALIDATION, PAYMENT, PRINTER, etc.',
  `error_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_stack` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Full stack trace',
  `module` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Module where error occurred',
  `route` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'GET, POST, etc.',
  `query_params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `request_body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'First 500 chars of body',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `status` enum('OPEN','ACKNOWLEDGED','RESOLVED','IGNORED') COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `resolved_at` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Admin notes',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_error_type` (`error_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shop_error_status` (`shop_id`,`status`,`created_at`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
CREATE TABLE IF NOT EXISTS `features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feature_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `feature_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `feature_category` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `feature_code` (`feature_code`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `features`
--

INSERT INTO `features` (`id`, `feature_code`, `feature_name`, `feature_category`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'customers', 'Customer Management', 'master', 'Manage customer information and history', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(2, 'suppliers', 'Supplier Management', 'master', 'Track supplier information and orders', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(3, 'tables', 'Table Management', 'master', 'Manage restaurant tables and seating', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(4, 'categories', 'Category Management', 'master', 'Organize menu items by categories', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(5, 'paymentOptions', 'Payment Options', 'master', 'Configure payment methods', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(6, 'items', 'Item Management', 'inventory', 'Manage menu items and inventory', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(7, 'stockManagement', 'Stock Management', 'inventory', 'Track inventory levels and stock', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(8, 'productManagement', 'Product Management', 'inventory', 'Manage product variants and combinations', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(9, 'stockReports', 'Stock Reports', 'inventory', 'Generate inventory and stock reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(10, 'pos', 'POS System', 'sales', 'Point of sale system for taking orders', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(11, 'advanceOrders', 'Advance Orders', 'sales', 'Take advance orders from customers', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(12, 'retailSales', 'Retail Sales', 'sales', 'Direct retail sales management', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(13, 'vouchers', 'Voucher System', 'financial', 'Issue and manage vouchers', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(14, 'expenses', 'Expense Tracking', 'financial', 'Track business expenses', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(15, 'salesReports', 'Sales Reports', 'reporting', 'Generate sales reports and analytics', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(16, 'itemWiseReports', 'Item-wise Reports', 'reporting', 'Detailed item sales reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(17, 'customerReports', 'Customer Reports', 'reporting', 'Customer analytics and reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(18, 'supplierReports', 'Supplier Reports', 'reporting', 'Supplier performance reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(19, 'advanceOrderReports', 'Advance Order Reports', 'reporting', 'Advance order tracking reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(20, 'lowStockReports', 'Low Stock Reports', 'reporting', 'Low stock alerts and reports', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(21, 'users', 'User Management', 'system', 'Manage system users and permissions', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(22, 'profileManagement', 'Profile Management', 'system', 'User profile management', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(23, 'coreSettings', 'Core Settings', 'system', 'System configuration settings', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(24, 'companyInfo', 'Company Information', 'system', 'Company profile and branding', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(25, 'taxManagement', 'Tax Management', 'system', 'Tax rates and tax management', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11'),
(26, 'unitsManagement', 'Units Management', 'system', 'Product units and measurements', 1, '2025-07-16 08:02:11', '2025-07-16 08:02:11');

-- --------------------------------------------------------

--
-- Table structure for table `feature_usage`
--

DROP TABLE IF EXISTS `feature_usage`;
CREATE TABLE IF NOT EXISTS `feature_usage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `feature_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `current_usage` int DEFAULT '0',
  `last_reset_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_feature` (`user_id`,`feature_code`),
  KEY `idx_user_feature` (`user_id`,`feature_code`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `final_bill`
--

DROP TABLE IF EXISTS `final_bill`;
CREATE TABLE IF NOT EXISTS `final_bill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `customer_id` int DEFAULT NULL,
  `inv_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `inv_date` date NOT NULL,
  `inv_time` time(6) NOT NULL,
  `table_number` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `discount_type` varchar(10) COLLATE utf8mb4_general_ci NOT NULL DEFAULT '0',
  `discount_value` float NOT NULL,
  `discount_amount` float NOT NULL,
  `subtotal_afterdiscount` float NOT NULL DEFAULT '0',
  `tax` decimal(15,2) NOT NULL,
  `roundoff` float NOT NULL DEFAULT '0',
  `grand_total` decimal(15,2) NOT NULL,
  `payment_mode` enum('Cash','Credit','Bank Transfer','QR Scan','Split','Card','Entertainment') COLLATE utf8mb4_general_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `setup_date` date NOT NULL,
  `remark` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_final_bill_inv_number` (`shop_id`,`inv_number`)
) ENGINE=InnoDB AUTO_INCREMENT=532 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `final_bill`
--

INSERT INTO `final_bill` (`id`, `shop_id`, `customer_id`, `inv_number`, `inv_date`, `inv_time`, `table_number`, `subtotal`, `discount_type`, `discount_value`, `discount_amount`, `subtotal_afterdiscount`, `tax`, `roundoff`, `grand_total`, `payment_mode`, `status`, `paid_amount`, `setup_date`, `remark`) VALUES
(399, 4, NULL, 'CLD001', '2026-03-27', '18:01:16.000000', 'VIP1', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-03-27', ''),
(422, 5, NULL, 'DM001', '2026-03-30', '11:17:56.000000', 'Table 1', 250.00, 'percentage', 0, 0, 250, 16.36, 0, 250.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(423, 5, NULL, 'DM002', '2026-03-30', '11:46:14.000000', 'Table 2', 245.00, 'percentage', 0, 0, 245, 16.03, 0, 245.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(424, 5, NULL, 'DM003', '2026-03-30', '15:43:53.000000', 'Table 1', 310.00, 'percentage', 0, 0, 310, 20.28, 0, 310.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(425, 5, NULL, 'DM004', '2026-03-30', '16:02:48.000000', 'Table 2', 1550.00, 'percentage', 0, 0, 1550, 101.40, 0, 1550.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(426, 5, NULL, 'DM005', '2026-03-30', '16:04:16.000000', 'Table 3', 100.00, 'percentage', 0, 0, 100, 6.54, 0, 100.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(427, 5, NULL, 'DM006', '2026-03-30', '16:04:50.000000', 'Table 1', 250.00, 'percentage', 0, 0, 250, 16.36, 0, 250.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(428, 5, NULL, 'DM007', '2026-03-30', '16:10:16.000000', 'Table 2', 340.00, 'percentage', 0, 0, 340, 22.24, 0, 340.00, 'Card', 0, 0.00, '2026-03-30', ''),
(429, 5, NULL, 'DM008', '2026-03-30', '16:16:25.000000', 'Table 2', 390.00, 'percentage', 0, 0, 390, 25.51, 0, 390.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(430, 5, NULL, 'DM009', '2026-03-30', '16:19:45.000000', 'VIP 1', 480.00, 'percentage', 0, 0, 480, 31.40, 0, 480.00, 'Entertainment', 0, 0.00, '2026-03-30', ''),
(431, 5, NULL, 'DM010', '2026-03-30', '16:24:29.000000', 'Table 1', 245.00, 'percentage', 10, 24.5, 220.5, 14.43, 0.5, 221.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(432, 5, NULL, 'DM011', '2026-03-30', '16:32:13.000000', 'Table 3', 340.00, 'percentage', 0, 0, 340, 22.24, 0, 340.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(433, 5, NULL, 'DM012', '2026-03-30', '16:36:35.000000', 'Table 2', 310.00, 'percentage', 0, 0, 310, 20.28, 0, 310.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(434, 5, NULL, 'DM013', '2026-03-30', '16:38:23.000000', 'VIP 3', 100.00, 'percentage', 0, 0, 100, 6.54, 0, 100.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(435, 5, NULL, 'DM014', '2026-03-30', '16:39:11.000000', 'VIP 2', 190.00, 'percentage', 0, 0, 190, 12.43, 0, 190.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(436, 5, NULL, 'DM015', '2026-03-30', '16:41:34.000000', 'VIP 3', 190.00, 'percentage', 0, 0, 190, 12.43, 0, 190.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(437, 5, NULL, 'DM016', '2026-03-30', '16:44:51.000000', 'Table 3', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(438, 5, NULL, 'DM017', '2026-03-30', '16:50:51.000000', 'VIP 2', 310.00, 'percentage', 0, 0, 310, 20.28, 0, 310.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(439, 5, NULL, 'DM018', '2026-03-30', '16:51:30.000000', 'Table 2', 190.00, 'percentage', 0, 0, 190, 12.43, 0, 190.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(440, 5, NULL, 'DM019', '2026-03-30', '16:54:55.000000', 'VIP 3', 245.00, 'percentage', 0, 0, 245, 16.03, 0, 245.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(441, 5, NULL, 'DM020', '2026-03-30', '17:32:42.000000', 'VIP 1', 2120.00, 'percentage', 0, 0, 2120, 138.69, 0, 2120.00, 'Cash', 0, 0.00, '2026-03-30', ''),
(442, 5, NULL, 'DM021', '2026-03-31', '14:53:21.000000', 'Table 2 - Split 1', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-03-31', ''),
(443, 5, NULL, 'DM022', '2026-03-31', '14:53:22.000000', 'Table 2 - Split 2', 260.00, 'percentage', 0, 0, 260, 17.01, 0, 260.00, 'Cash', 0, 0.00, '2026-03-31', ''),
(444, 5, NULL, 'DM023', '2026-03-31', '15:08:31.000000', 'Table 3', 1150.00, 'percentage', 0, 0, 1150, 75.23, 0, 1150.00, 'Cash', 0, 0.00, '2026-03-31', ''),
(445, 5, NULL, 'DM024', '2026-03-31', '15:14:29.000000', 'Table 2, VIP 1', 610.00, 'percentage', 0, 0, 610, 39.91, 0, 610.00, 'Card', 0, 0.00, '2026-03-31', ''),
(446, 5, 22, 'DM025', '2026-03-31', '16:07:34.000000', 'Table 1', 440.00, 'percentage', 0, 0, 440, 28.79, 0, 440.00, 'Credit', 0, 200.00, '2026-03-31', ''),
(447, 5, NULL, 'DM026', '2026-03-31', '16:10:44.000000', 'Table 2', 50.00, 'percentage', 0, 0, 50, 3.27, 0, 50.00, 'Cash', 0, 0.00, '2026-03-31', ''),
(448, 5, 22, 'DM027', '2026-03-31', '16:10:49.000000', 'Table 3', 295.00, 'percentage', 0, 0, 295, 19.30, 0, 295.00, 'Credit', 0, 295.00, '2026-03-31', ''),
(449, 5, 22, 'DM028', '2026-03-31', '16:14:37.000000', 'Table 3', 730.00, 'percentage', 0, 0, 730, 47.76, 0, 730.00, 'Credit', 0, 205.00, '2026-03-31', ''),
(450, 5, 22, 'DM029', '2026-03-31', '16:17:58.000000', 'Table 1', 295.00, 'percentage', 0, 0, 295, 19.30, 0, 295.00, 'Credit', 1, 0.00, '2026-03-31', ''),
(451, 5, 23, 'DM030', '2026-03-31', '17:04:24.000000', 'Table 1', 1610.00, 'percentage', 0, 0, 1610, 105.33, 0, 1610.00, 'Credit', 0, 1000.00, '2026-03-31', ''),
(452, 7, NULL, 'JSL001', '2026-04-03', '10:15:50.000000', 'Table 1', 200.00, 'fixed', 20, 20, 180, 11.78, 0, 180.00, 'Entertainment', 0, 0.00, '2026-04-03', ''),
(453, 7, NULL, 'JSL002', '2026-04-03', '10:29:33.000000', 'Table 1', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Entertainment', 0, 0.00, '2026-04-03', ''),
(454, 5, 22, 'DM031', '2026-04-04', '04:24:44.000000', 'Table 1', 1350.00, 'percentage', 10, 135, 1215, 79.49, 0, 1215.00, 'Credit', 1, 0.00, '2026-04-01', ''),
(455, 5, NULL, 'DM032', '2026-04-05', '04:44:25.000000', 'Table 2', 735.00, 'percentage', 0, 0, 735, 48.08, 0, 735.00, 'Cash', 0, 0.00, '2026-04-01', ''),
(456, 5, NULL, 'DM033', '2026-04-05', '04:45:28.000000', 'Table 3', 760.00, 'percentage', 0, 0, 760, 49.72, 0, 760.00, 'QR Scan', 0, 0.00, '2026-04-01', ''),
(457, 5, NULL, 'DM034', '2026-04-05', '04:47:10.000000', 'Table 2', 1130.00, 'percentage', 0, 0, 1130, 73.93, 0, 1130.00, 'QR Scan', 0, 0.00, '2026-04-01', ''),
(458, 5, NULL, 'DM035', '2026-04-05', '04:47:19.000000', 'VIP 1', 295.00, 'percentage', 0, 0, 295, 19.30, 0, 295.00, 'Cash', 0, 0.00, '2026-04-01', ''),
(459, 8, NULL, 'SNR001', '2026-04-05', '07:45:23.000000', 'Table 1', 300.00, 'fixed', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(460, 8, NULL, 'SNR002', '2026-04-05', '07:47:53.000000', 'Table 2, Table 3', 900.00, 'fixed', 0, 0, 900, 58.88, 0, 900.00, 'Card', 0, 0.00, '2026-04-05', ''),
(461, 5, NULL, 'DM036', '2026-04-06', '10:50:50.000000', 'Table 2', 1515.00, 'percentage', 0, 0, 1515, 99.11, 0, 1515.00, 'Cash', 0, 0.00, '2026-04-02', ''),
(462, 8, NULL, 'SNR003', '2026-04-08', '13:26:54.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(463, 8, NULL, 'SNR004', '2026-04-08', '13:26:54.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(464, 8, NULL, 'SNR005', '2026-04-08', '13:26:54.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(465, 8, NULL, 'SNR006', '2026-04-08', '13:26:54.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(466, 8, NULL, 'SNR007', '2026-04-08', '13:26:55.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(467, 8, NULL, 'SNR008', '2026-04-08', '13:26:55.000000', 'Table 1', 115.00, 'percentage', 0, 0, 115, 7.52, 0, 115.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(468, 5, NULL, 'DM037', '2026-04-12', '04:48:14.000000', 'Table 3', 3735.00, 'percentage', 0, 0, 3735, 244.35, 0, 3735.00, 'Cash', 0, 0.00, '2026-04-02', ''),
(469, 5, NULL, 'DM038', '2026-04-12', '04:48:29.000000', 'Table 1', 945.00, 'percentage', 0, 0, 945, 61.82, 0, 945.00, 'Cash', 0, 0.00, '2026-04-02', ''),
(470, 8, NULL, 'SNR009', '2026-04-12', '05:01:08.000000', 'Table 1', 1485.00, 'percentage', 0, 0, 1485, 97.15, 0, 1485.00, 'Entertainment', 0, 0.00, '2026-04-06', ''),
(471, 8, NULL, 'SNR010', '2026-04-12', '05:22:09.000000', 'Table 2', 239.00, 'percentage', 0, 0, 239, 15.64, 0, 239.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(472, 8, NULL, 'SNR011', '2026-04-12', '05:26:43.000000', 'Take Away', 550.00, 'percentage', 0, 0, 550, 35.98, 0, 550.00, 'Entertainment', 0, 0.00, '2026-04-06', ''),
(473, 5, NULL, 'DM039', '2026-04-13', '07:22:16.000000', 'Table 1', 3455.00, 'percentage', 0, 0, 3455, 226.03, 0, 3455.00, 'Cash', 0, 0.00, '2026-04-02', ''),
(474, 9, NULL, 'WS001', '2026-04-18', '06:58:00.000000', 'Room 201', 2400.00, 'percentage', 0, 0, 2400, 157.01, 0, 2400.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(475, 9, NULL, 'WS002', '2026-04-18', '06:58:56.000000', 'Room 302', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(476, 9, NULL, 'WS003', '2026-04-18', '07:03:43.000000', 'Room 304', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(477, 9, NULL, 'WS004', '2026-04-18', '07:03:47.000000', 'Room 303', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(478, 9, NULL, 'WS005', '2026-04-18', '07:03:50.000000', 'Room 305', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(479, 9, NULL, 'WS006', '2026-04-18', '07:04:33.000000', 'Room 403', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(480, 9, NULL, 'WS007', '2026-04-18', '07:36:47.000000', 'Room 304', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'Cash', 0, 0.00, '2026-04-18', ''),
(481, 9, NULL, 'WS008', '2026-04-19', '06:39:17.000000', 'Room 302', 1175.00, 'percentage', 0, 0, 1175, 76.87, 0, 1175.00, 'Cash', 0, 0.00, '2026-04-19', ''),
(482, 7, NULL, 'JSL003', '2026-04-23', '12:16:19.000000', 'Table 2', 1200.00, 'percentage', 0, 0, 1200, 78.50, 0, 1200.00, 'Entertainment', 0, 0.00, '2026-04-23', ''),
(483, 9, NULL, 'WS009', '2026-04-26', '09:39:51.000000', 'Room 302', 880.00, 'percentage', 0, 0, 880, 57.57, 0, 880.00, 'Cash', 0, 0.00, '2026-04-26', ''),
(484, 9, NULL, 'WS010', '2026-04-27', '11:58:23.000000', 'Table 3', 945.00, 'percentage', 10, 94.5, 850.5, 55.64, 0.5, 851.00, 'Cash', 0, 0.00, '2026-04-27', ''),
(485, 9, NULL, 'WS011', '2026-04-27', '12:17:31.000000', 'Table 4', 750.00, 'percentage', 0, 0, 750, 49.07, 0, 750.00, 'Cash', 0, 0.00, '2026-04-27', ''),
(486, 7, NULL, 'JSL004', '2026-04-28', '07:26:58.000000', 'Table 2', 570.00, 'percentage', 0, 0, 570, 37.29, 0, 570.00, 'Entertainment', 0, 0.00, '2026-04-28', ''),
(487, 9, NULL, 'WS012', '2026-05-02', '11:49:42.000000', 'Table 10', 15.00, 'percentage', 0, 0, 15, 0.98, 0, 15.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(488, 9, NULL, 'WS013', '2026-05-02', '11:49:48.000000', 'Room 402', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(489, 9, NULL, 'WS014', '2026-05-02', '11:49:57.000000', 'Grab 1', 30.00, 'percentage', 0, 0, 30, 1.96, 0, 30.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(490, 9, NULL, 'WS015', '2026-05-02', '12:07:49.000000', 'Room 401', 800.00, 'percentage', 25, 200, 600, 39.25, 0, 600.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(491, 9, NULL, 'WS016', '2026-05-02', '12:34:33.000000', 'Table 1', 270.00, 'percentage', 0, 0, 270, 17.66, 0, 270.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(492, 9, NULL, 'WS017', '2026-05-02', '12:49:55.000000', 'Table 2', 1900.00, 'percentage', 20, 380, 1520, 99.44, 0, 1520.00, 'Cash', 0, 0.00, '2026-05-02', ''),
(493, 9, NULL, 'WS018', '2026-05-05', '12:06:27.000000', 'Room 301', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-05-05', ''),
(494, 9, NULL, 'WS019', '2026-05-05', '12:06:32.000000', 'Room 303', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'Cash', 0, 0.00, '2026-05-05', ''),
(495, 9, NULL, 'WS020', '2026-05-05', '12:07:08.000000', 'Room 305', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-05-05', ''),
(496, 8, NULL, 'SNR012', '2026-05-08', '07:30:02.000000', 'Table 1', 85.00, 'percentage', 0, 0, 85, 5.56, 0, 85.00, 'Cash', 0, 0.00, '2026-04-06', ''),
(497, 8, NULL, 'SNR013', '2026-05-10', '09:06:01.000000', 'Table 1', 350.00, 'percentage', 0, 0, 350, 22.90, 0, 350.00, 'Cash', 2, 0.00, '2026-05-10', 'wormg post'),
(498, 8, NULL, 'SNR014', '2026-05-10', '09:11:43.000000', 'Table 1', 150.00, 'percentage', 0, 0, 150, 9.81, 0, 150.00, 'Cash', 0, 0.00, '2026-05-10', ''),
(499, 8, NULL, 'SNR015', '2026-05-10', '09:13:54.000000', 'Table 2', 150.00, 'percentage', 0, 0, 150, 9.81, 0, 150.00, 'Cash', 0, 0.00, '2026-05-10', ''),
(500, 8, NULL, 'SNR016', '2026-05-10', '09:13:57.000000', 'Table 2', 150.00, 'percentage', 0, 0, 150, 9.81, 0, 150.00, 'Cash', 0, 0.00, '2026-05-10', ''),
(501, 8, NULL, 'SNR017', '2026-05-10', '10:20:20.000000', 'Table 1', 85.00, 'percentage', 0, 0, 85, 5.56, 0, 85.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(502, 8, NULL, 'SNR018', '2026-05-10', '10:22:47.000000', 'Table 3', 75.00, 'percentage', 0, 0, 75, 4.91, 0, 75.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(503, 8, NULL, 'SNR019', '2026-05-10', '11:13:55.000000', 'Table 4', 244.00, 'percentage', 0, 0, 244, 15.96, 0, 244.00, 'Cash', 0, 0.00, '2026-05-10', ''),
(504, 5, NULL, 'DM040', '2026-05-10', '14:00:06.000000', 'Table 2', 570.00, 'percentage', 0, 0, 570, 37.29, 0, 570.00, 'Cash', 0, 0.00, '2026-04-03', ''),
(505, 5, NULL, 'DM041', '2026-05-10', '14:05:38.000000', 'Table 1', 500.00, 'percentage', 0, 0, 500, 32.71, 0, 500.00, 'Cash', 0, 0.00, '2026-04-04', ''),
(506, 5, NULL, 'DM042', '2026-05-10', '14:06:36.000000', 'Table 1', 310.00, 'percentage', 0, 0, 310, 20.28, 0, 310.00, 'Cash', 0, 0.00, '2026-04-04', ''),
(507, 8, NULL, 'SNR020', '2026-05-10', '16:21:45.000000', 'Table 7', 970.00, 'percentage', 0, 0, 970, 63.46, 0, 970.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(508, 8, NULL, 'SNR021', '2026-05-10', '16:23:58.000000', 'Table 8', 400.00, 'percentage', 0, 0, 400, 26.17, 0, 400.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(509, 8, NULL, 'SNR022', '2026-05-10', '17:03:44.000000', 'Table 8', 479.00, 'percentage', 0, 0, 479, 31.34, 0, 479.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(510, 8, NULL, 'SNR023', '2026-05-11', '02:38:37.000000', 'Table 2', 205.00, 'percentage', 0, 0, 205, 13.41, 0, 205.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(511, 8, NULL, 'SNR024', '2026-05-11', '04:35:51.000000', 'Table 3', 70.00, 'percentage', 0, 0, 70, 4.58, 0, 70.00, 'QR Scan', 0, 0.00, '2026-05-10', ''),
(512, 5, NULL, 'DM043', '2026-05-11', '15:09:44.000000', 'Table 2', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(513, 5, NULL, 'DM044', '2026-05-11', '15:23:01.000000', 'Table 2', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(514, 5, NULL, 'DM045', '2026-05-11', '15:31:58.000000', 'Table 2', 1400.00, 'percentage', 0, 0, 1400, 91.59, 0, 1400.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(515, 5, NULL, 'DM046', '2026-05-11', '15:43:11.000000', 'Table 2', 800.00, 'percentage', 0, 0, 800, 52.34, 0, 800.00, 'Card', 0, 0.00, '2026-04-05', ''),
(516, 5, NULL, 'DM047', '2026-05-11', '15:56:53.000000', 'Table 2', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(517, 5, NULL, 'DM048', '2026-05-11', '16:00:41.000000', 'Table 3', 300.00, 'percentage', 0, 0, 300, 19.63, 0, 300.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(518, 5, NULL, 'DM049', '2026-05-11', '16:15:16.000000', 'Table 2', 450.00, 'percentage', 0, 0, 450, 29.44, 0, 450.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(519, 5, NULL, 'DM050', '2026-05-11', '16:16:01.000000', 'Table 3', 600.00, 'percentage', 0, 0, 600, 39.25, 0, 600.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(520, 5, NULL, 'DM051', '2026-05-11', '18:19:53.000000', 'Table 2', 50.00, 'percentage', 0, 0, 50, 3.27, 0, 50.00, 'Card', 0, 0.00, '2026-04-05', ''),
(521, 5, NULL, 'DM052', '2026-05-12', '13:43:21.000000', '0', 650.00, 'fixed', 0, 0, 650, 42.52, 0, 650.00, 'Cash', 0, 0.00, '2026-05-12', ''),
(522, 5, NULL, 'DM053', '2026-05-12', '14:14:23.000000', 'Table 1', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(523, 5, NULL, 'DM054', '2026-05-12', '15:30:27.000000', 'Table 3', 1600.00, 'percentage', 0, 0, 1600, 104.67, 0, 1600.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(524, 5, NULL, 'DM055', '2026-05-12', '17:44:01.000000', 'VIP 1', 950.00, 'percentage', 0, 0, 950, 62.15, 0, 950.00, 'QR Scan', 0, 0.00, '2026-04-05', ''),
(525, 5, NULL, 'DM056', '2026-05-12', '17:46:42.000000', 'Table 3', 2620.00, 'percentage', 0, 0, 2620, 171.40, 0, 2620.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(526, 5, NULL, 'DM057', '2026-05-12', '17:47:30.000000', 'VIP 1', 765.00, 'percentage', 0, 0, 765, 50.05, 0, 765.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(527, 5, NULL, 'DM058', '2026-05-12', '17:54:00.000000', 'VIP 2', 795.00, 'fixed', 50, 50, 745, 48.74, 0, 745.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(528, 5, NULL, 'DM059', '2026-05-12', '17:58:16.000000', 'VIP 1', 1685.00, 'fixed', 50, 50, 1635, 106.96, 0, 1635.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(529, 5, NULL, 'DM060', '2026-05-12', '18:08:59.000000', 'VIP 1', 600.00, 'fixed', 50, 50, 550, 35.98, 0, 550.00, 'Card', 0, 0.00, '2026-04-05', ''),
(530, 5, NULL, 'DM061', '2026-05-12', '18:27:21.000000', 'VIP 3', 280.00, 'percentage', 0, 0, 280, 18.32, 0, 280.00, 'Cash', 0, 0.00, '2026-04-05', ''),
(531, 5, NULL, 'DM062', '2026-05-12', '18:31:17.000000', 'VIP 2', 1840.00, 'percentage', 0, 0, 1840, 120.37, 0, 1840.00, 'Card', 0, 0.00, '2026-04-05', '');

-- --------------------------------------------------------

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
CREATE TABLE IF NOT EXISTS `images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` varchar(233) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `mimetype` varchar(100) NOT NULL,
  `size` int NOT NULL,
  `dateUploaded` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
CREATE TABLE IF NOT EXISTS `inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int DEFAULT NULL,
  `item_id` int NOT NULL,
  `opening_stock` decimal(10,2) DEFAULT '0.00',
  `stock_in` decimal(10,2) DEFAULT '0.00',
  `stock_out` decimal(10,2) DEFAULT '0.00',
  `closing_stock` decimal(10,2) GENERATED ALWAYS AS (((`opening_stock` + `stock_in`) - `stock_out`)) STORED,
  `unit` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `refno` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `pdate` date DEFAULT NULL,
  `purchase_price` decimal(10,2) DEFAULT '0.00',
  `vat` decimal(5,2) DEFAULT '0.00',
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `vatAmount` decimal(10,2) DEFAULT '0.00',
  `netAmount` decimal(10,2) DEFAULT '0.00',
  `last_updated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `fk_inventory_supplier` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `catid` int UNSIGNED NOT NULL,
  `subcatid` int UNSIGNED DEFAULT NULL,
  `item_code` int NOT NULL,
  `item_type` varchar(20) NOT NULL DEFAULT 'Food',
  `iname` varchar(233) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit` varchar(23) NOT NULL,
  `weight` varchar(20) NOT NULL,
  `tax` int NOT NULL,
  `mrp` int NOT NULL,
  `offerprice` int NOT NULL,
  `description` text NOT NULL,
  `min_stock` int NOT NULL DEFAULT '0',
  `isstockable` varchar(50) NOT NULL DEFAULT 'false',
  `status` varchar(233) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`id`),
  KEY `fk_items_catid` (`catid`),
  KEY `fk_items_subcatid` (`subcatid`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1233 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `shop_id`, `catid`, `subcatid`, `item_code`, `item_type`, `iname`, `unit`, `weight`, `tax`, `mrp`, `offerprice`, `description`, `min_stock`, `isstockable`, `status`) VALUES
(502, 4, 46, 77, 4, 'Food', 'Allo mPoori', 'MG', 'unit', 7, 145, 145, '', 0, '0', 'Active'),
(503, 4, 46, 77, 5, 'Food', 'Allo mPoori', 'MG', 'unit', 7, 145, 145, '', 0, '0', 'Active'),
(504, 4, 46, 77, 6, 'Food', 'dasda', 'KG', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(505, 4, 46, 77, 7, 'Food', 'dasda', 'KG', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(509, 5, 47, 78, 101, 'Food', 'Coffee1', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(510, 5, 47, 78, 102, 'Food', 'Coffee2', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(511, 5, 47, 78, 103, 'Food', 'Coffee3', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(512, 5, 47, 78, 104, 'Food', 'Coffee4', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(513, 5, 47, 80, 105, 'Food', 'Lunch 1', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(514, 5, 47, 80, 106, 'Food', 'Lunch 2', '', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(515, 5, 47, 80, 107, 'Food', 'Lunch 3', '', 'unit', 7, 180, 280, '', 0, '0', 'Active'),
(516, 5, 47, 79, 108, 'Food', 'Snack 1', '', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(517, 5, 47, 79, 109, 'Food', 'Snack 2', '', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(518, 5, 47, 79, 110, 'Food', 'Snack 3', '', 'unit', 7, 195, 195, '', 0, '0', 'Active'),
(519, 7, 49, 115, 1, 'Food', 'Chilli Paneer', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(520, 7, 49, 115, 2, 'Food', 'Chilli Chicken', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(521, 7, 49, 115, 3, 'Food', 'Chicken Tikka', 'Plate', 'unit', 7, 330, 330, '', 0, '0', 'Active'),
(522, 7, 49, 115, 4, 'Food', 'Paneer Pakoda', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(523, 7, 49, 115, 5, 'Food', 'Veg Pakoda', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(524, 7, 49, 115, 6, 'Food', 'Honey Chilli Potato', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(525, 7, 49, 115, 7, 'Food', 'Crispy Veg', 'Bowl', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(526, 7, 49, 115, 8, 'Food', 'Veg Samosa 3pc.', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(527, 7, 49, 115, 9, 'Food', 'Chilli Prawn', 'Plate', 'unit', 7, 420, 420, '', 0, '0', 'Active'),
(528, 7, 49, 0, 10, 'Food', 'Veg Manchrian', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(529, 7, 49, 115, 11, 'Food', 'Gobhi Manchrian', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(530, 7, 49, 115, 12, 'Food', 'Onion Bhaji', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(531, 7, 49, 115, 13, 'Food', 'Tandoori chicken (Half)', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(532, 7, 49, 115, 14, 'Food', 'Tandoori chicken (Full)', 'Plate', 'unit', 7, 500, 500, '', 0, '0', 'Active'),
(533, 7, 49, 115, 15, 'Food', 'Mutton Samosa', 'Plate', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(534, 7, 49, 115, 16, 'Food', 'Papadum 2pc.', 'Plate', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(535, 7, 49, 115, 17, 'Food', 'Masala Papadum', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(536, 7, 49, 115, 18, 'Food', 'Chicken Samosa', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(537, 7, 49, 115, 19, 'Food', 'Chicken 65', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(538, 7, 49, 115, 20, 'Food', 'Mushroom Chilli', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(539, 7, 49, 115, 21, 'Food', 'Chicken Pakoda', 'Plate', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(540, 7, 49, 116, 22, 'Food', 'Shami Kabab', 'Plate', 'unit', 7, 480, 480, '', 0, '0', 'Active'),
(541, 7, 49, 116, 23, 'Food', 'chicken seekh kebab', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(542, 7, 49, 116, 24, 'Food', 'mutton seekh kebab', 'Plate', 'unit', 7, 480, 480, '', 0, '0', 'Active'),
(543, 7, 49, 116, 25, 'Food', 'reshmi kabab', 'Plate', 'unit', 7, 380, 380, '', 0, '0', 'Active'),
(544, 7, 49, 116, 26, 'Food', 'garlic kabab', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(545, 7, 49, 116, 27, 'Food', 'paneer cheese kebab', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(546, 7, 49, 116, 28, 'Food', 'Chicken malai tikka', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(547, 7, 49, 116, 29, 'Food', 'Prawn malai tikka', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(548, 7, 49, 117, 30, 'Food', 'chicken sizzling', 'Plate', 'unit', 7, 380, 380, '', 0, '0', 'Active'),
(551, 7, 49, 117, 31, 'Food', 'seafood sizzling', 'Plate', 'unit', 7, 490, 490, '', 0, '0', 'Active'),
(552, 7, 49, 117, 32, 'Food', 'mutton sizzling', 'Plate', 'unit', 7, 480, 480, '', 0, '0', 'Active'),
(553, 7, 49, 117, 33, 'Food', 'veg sizzling', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(554, 7, 49, 117, 34, 'Food', 'mutton tawa /lamb', 'Plate', 'unit', 7, 420, 420, '', 0, '0', 'Active'),
(555, 7, 49, 117, 35, 'Food', 'veg tawa', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(556, 7, 49, 117, 36, 'Food', 'seafood tawa', 'Plate', 'unit', 7, 490, 490, '', 0, '0', 'Active'),
(557, 7, 49, 117, 37, 'Food', 'paneer tawa', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(558, 7, 49, 118, 38, 'Food', 'garlic naan', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(559, 7, 49, 118, 39, 'Food', 'cheese naan', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(560, 7, 49, 118, 40, 'Food', 'keema chicken naan', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(561, 7, 49, 118, 41, 'Food', 'keema mutton naan', 'Plate', 'unit', 7, 240, 240, '', 0, '0', 'Active'),
(562, 7, 49, 118, 42, 'Food', 'plain naan', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(563, 7, 49, 118, 43, 'Food', 'onion naan', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(564, 7, 49, 118, 44, 'Food', 'butter naan', 'Plate', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(565, 7, 49, 118, 45, 'Food', 'aloo pyaz paratha', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(566, 7, 49, 118, 46, 'Food', 'aloo paratha', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(567, 7, 49, 118, 47, 'Food', 'onion paratha', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(568, 7, 49, 118, 48, 'Food', 'paneer paratha', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(569, 7, 49, 118, 49, 'Food', 'Gobi paratha', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(570, 7, 49, 118, 50, 'Food', 'egg paratha', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(571, 7, 49, 118, 51, 'Food', 'lachha paratha', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(572, 7, 49, 119, 52, 'Food', 'plain chapati', 'Pcs', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(573, 7, 49, 119, 53, 'Food', 'butter chapati', 'Pcs', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(574, 7, 49, 119, 54, 'Food', 'tandoori roti', 'Pcs', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(575, 7, 49, 119, 55, 'Food', 'tandoori roti butter', 'Pcs', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(576, 7, 49, 119, 56, 'Food', 'missi roti', 'Pcs', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(577, 7, 49, 119, 57, 'Food', 'jasmine rice', 'Plate', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(578, 7, 49, 119, 58, 'Food', 'basmati rice', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(579, 7, 49, 119, 59, 'Food', 'Jeera rice', 'Plate', 'unit', 7, 110, 110, '', 0, '0', 'Active'),
(580, 7, 49, 119, 60, 'Food', 'pulao rice', 'Plate', 'unit', 7, 110, 110, '', 0, '0', 'Active'),
(581, 7, 49, 119, 61, 'Food', 'veg pulao rice', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(582, 7, 49, 120, 62, 'Food', 'chef special biryani', 'Plate', 'unit', 7, 500, 500, '', 0, '0', 'Active'),
(583, 7, 49, 120, 63, 'Food', 'mix veg biryani', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(584, 7, 49, 120, 64, 'Food', 'chicken biryani', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(585, 7, 49, 120, 65, 'Food', 'prawn biryani', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(586, 7, 49, 120, 66, 'Food', 'mutton biryani', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(587, 7, 49, 120, 67, 'Food', 'fish biryani', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(588, 7, 49, 120, 68, 'Food', 'egg biryani', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(589, 7, 49, 120, 69, 'Food', 'Chicken fried rice', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(590, 7, 49, 120, 70, 'Food', 'seafood fried rice', 'Plate', 'unit', 7, 260, 260, '', 0, '0', 'Active'),
(591, 7, 49, 120, 71, 'Food', 'curd rice', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(592, 7, 49, 120, 72, 'Food', 'dal khichadi', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(593, 7, 49, 120, 73, 'Food', 'plain curd', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(594, 7, 49, 120, 74, 'Food', 'tomato raita', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(595, 7, 49, 120, 75, 'Food', 'bundi raita', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(596, 7, 49, 120, 76, 'Food', 'mix veg raita', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(597, 7, 0, 0, 77, 'Food', 'Veg soup', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(598, 7, 0, 0, 78, 'Food', 'mushroom soup', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(599, 7, 0, 0, 79, 'Food', 'chicken soup', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(600, 7, 0, 0, 80, 'Food', 'mutton soup', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(601, 7, 0, 0, 81, 'Food', 'dal soup', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(602, 7, 0, 0, 82, 'Food', 'tomato soup', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(603, 7, 0, 0, 83, 'Food', 'mancho soup', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(604, 7, 0, 0, 84, 'Food', 'prawn soup', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(606, 7, 49, 122, 85, 'Food', 'paneer lababdar', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(607, 7, 49, 122, 86, 'Food', 'Paneer bhurji', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(608, 7, 49, 122, 87, 'Food', 'Paneer butter masala', 'Plate', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(609, 7, 49, 122, 88, 'Food', 'Matar paneer', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(610, 7, 49, 122, 89, 'Food', 'Palak paneer', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(611, 7, 49, 122, 90, 'Food', 'Kadhai Paneer', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(612, 7, 49, 122, 91, 'Food', 'Paneer pasanda', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(613, 7, 49, 122, 92, 'Food', 'Paneer tikka masala', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(614, 7, 50, 89, 93, 'Food', 'Test Food', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(615, 7, 49, 122, 94, 'Food', 'paneer do pyaza', '', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(616, 7, 49, 122, 95, 'Food', 'mushroom do pyaza', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(617, 7, 49, 122, 96, 'Food', 'Chana masala', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(618, 7, 49, 122, 97, 'Food', 'malai kofta', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(619, 7, 49, 122, 98, 'Food', 'veg kofta', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(620, 7, 49, 122, 99, 'Food', 'navratan korma', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(621, 7, 49, 122, 100, 'Food', 'Dal tadka', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(622, 7, 49, 122, 101, 'Food', 'Dal makhani ', '', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(623, 7, 49, 122, 102, 'Food', 'Mix veg curry', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(624, 7, 49, 122, 103, 'Food', 'mushroom tikka masala ', '', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(625, 7, 49, 122, 104, 'Food', 'mushroom masala ', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(626, 7, 49, 122, 105, 'Food', 'aloo gobi', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(627, 7, 49, 122, 106, 'Food', 'aloo jeera', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(628, 7, 49, 122, 107, 'Food', 'bhindi masala', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(629, 7, 49, 122, 108, 'Food', 'Shahi paneer', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(630, 7, 49, 123, 109, 'Food', 'Chicken tikka masala', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(631, 7, 49, 123, 110, 'Food', 'lamb tikka masala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(632, 7, 49, 123, 111, 'Food', 'mutton tikka masala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(633, 7, 49, 123, 112, 'Food', 'chicken korma', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(634, 7, 49, 123, 113, 'Food', 'lamb korma', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(635, 7, 49, 123, 114, 'Food', 'mutton korma', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(636, 7, 49, 123, 115, 'Food', 'chicken dan shake', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(637, 7, 49, 123, 116, 'Food', 'lamb dan shake', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(638, 7, 49, 123, 117, 'Food', 'mutton dan shake', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(639, 7, 49, 0, 118, 'Food', 'chicken rogan josh', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(640, 7, 49, 0, 119, 'Food', 'lamb rogan josh', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(641, 7, 49, 0, 120, 'Food', 'mutton rogan josh', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(642, 7, 49, 123, 121, 'Food', 'chicken saagwala', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(643, 7, 49, 123, 122, 'Food', 'lamb saagwala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(644, 7, 49, 123, 123, 'Food', 'mutton saagwala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(645, 7, 49, 123, 124, 'Food', 'chicken curry', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(646, 7, 49, 123, 125, 'Food', 'lamb curry', 'Plate', 'unit', 7, 430, 430, '', 0, '0', 'Active'),
(647, 7, 49, 123, 126, 'Food', 'mutton curry', 'Plate', 'unit', 7, 430, 430, '', 0, '0', 'Active'),
(648, 7, 49, 123, 127, 'Food', 'chicken vindaloo', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(649, 7, 49, 123, 128, 'Food', 'lamb vindaloo', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(650, 7, 49, 123, 129, 'Food', 'mutton vindaloo', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(651, 7, 49, 123, 130, 'Food', 'chicken masala', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(652, 7, 49, 123, 131, 'Food', 'lamb masala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(653, 7, 49, 123, 132, 'Food', 'mutton masala', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(654, 7, 49, 123, 133, 'Food', 'butter chicken', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(655, 7, 49, 123, 134, 'Food', 'chicken do pyaza', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(656, 7, 49, 123, 135, 'Food', 'lamb do pyaza', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(657, 7, 49, 123, 136, 'Food', 'mutton do pyaza', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(658, 7, 49, 123, 137, 'Food', 'chicken mumtaz', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(659, 7, 49, 123, 138, 'Food', 'chicken madrasi', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(660, 7, 49, 123, 139, 'Food', 'lamb/mutton madrasi', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(661, 7, 49, 123, 140, 'Food', 'Egg curry 2pc', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(662, 7, 49, 123, 141, 'Food', 'Egg curry 3pc', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(663, 7, 49, 124, 142, 'Food', 'fish fry', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(664, 7, 49, 124, 143, 'Food', 'prawn fry 6pc', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(665, 7, 49, 124, 144, 'Food', 'prawn/fish madrasi', 'Plate', 'unit', 7, 390, 390, '', 0, '0', 'Active'),
(666, 7, 49, 124, 145, 'Food', 'prawn/fish jafresy', 'Plate', 'unit', 7, 420, 420, '', 0, '0', 'Active'),
(667, 7, 49, 124, 146, 'Food', 'seafood/prawn/fish curry', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(668, 7, 49, 124, 147, 'Food', 'Prawn butter masala', 'Plate', 'unit', 7, 390, 390, '', 0, '0', 'Active'),
(669, 7, 49, 124, 148, 'Food', 'Prawn tikka masala', 'Plate', 'unit', 7, 420, 420, '', 0, '0', 'Active'),
(670, 7, 49, 124, 149, 'Food', 'butter prawn', 'Plate', 'unit', 7, 420, 420, '', 0, '0', 'Active'),
(671, 7, 49, 125, 150, 'Food', 'rasgulla 1pc', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(672, 7, 49, 125, 151, 'Food', 'Gulab jamun 2pc', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(673, 7, 50, 96, 152, 'Food', 'fried banana with ice cream', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(674, 7, 50, 96, 153, 'Food', 'Fried banana with honey', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(675, 7, 50, 96, 154, 'Food', 'pancake and ice cream', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(676, 7, 50, 96, 155, 'Food', 'pancake with banana with honey', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(677, 7, 50, 96, 156, 'Food', 'fresh fruit', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(678, 7, 50, 96, 157, 'Food', 'ice cream', 'Plate', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(679, 7, 50, 96, 158, 'Food', 'sticky rice with mango', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(680, 7, 50, 89, 159, 'Food', 'pineapple fried rice', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(681, 7, 50, 89, 160, 'Food', 'Fried rice with chicken/pork/beef', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(682, 7, 50, 89, 161, 'Food', 'Fried rice with chicken/pork/beef+', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(683, 7, 50, 89, 162, 'Food', 'veg fried rice with egg', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(684, 7, 50, 89, 163, 'Food', 'fried rice with tuna', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(685, 7, 50, 89, 164, 'Food', 'garlic fried rice', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(686, 7, 50, 89, 165, 'Food', 'fried rice crab', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(687, 7, 51, 89, 166, 'Food', 'Water (small)', 'Plate', 'unit', 7, 20, 20, '', 0, '0', 'Active'),
(688, 7, 51, 89, 167, 'Food', 'Water (big)', 'Plate', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(689, 7, 51, 89, 168, 'Food', 'Coke/Sprite/Fanta(Bottle)', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(690, 7, 51, 89, 169, 'Food', 'Coke zero', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(691, 7, 51, 89, 170, 'Food', 'Soda', 'Plate', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(692, 7, 51, 89, 171, 'Food', 'Schweppers', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(693, 7, 51, 89, 172, 'Food', 'Soda with lime', 'Plate', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(694, 7, 51, 89, 173, 'Food', 'Tonic', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(695, 7, 51, 89, 174, 'Food', 'Fresh coconut water', 'Plate', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(697, 7, 51, 89, 175, 'Food', 'Fresh lime juice', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(698, 7, 51, 89, 176, 'Food', 'Black Tea', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(699, 7, 51, 89, 177, 'Food', 'Masala Tea', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(700, 7, 51, 89, 178, 'Food', 'Iced tea', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(701, 7, 51, 89, 179, 'Food', 'Iced coffee', 'Plate', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(702, 7, 51, 89, 180, 'Food', 'apple juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(703, 7, 51, 89, 181, 'Food', 'apple juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(704, 7, 51, 89, 182, 'Food', 'Mix fruit juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(705, 7, 51, 89, 183, 'Food', 'Mix fruit juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(706, 7, 51, 89, 184, 'Food', 'pineapple juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(707, 7, 51, 89, 185, 'Food', 'pineapple juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(708, 7, 51, 89, 186, 'Food', 'orange juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(709, 7, 51, 89, 187, 'Food', 'orange juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(710, 7, 51, 89, 188, 'Food', 'pomegranate juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(711, 7, 51, 89, 189, 'Food', 'pomegranate juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(712, 7, 51, 89, 190, 'Food', 'mango juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(713, 7, 51, 89, 191, 'Food', 'mango juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(714, 7, 51, 89, 192, 'Food', 'tomato juice (ice)', 'Plate', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(715, 7, 51, 89, 193, 'Food', 'tomato juice (without ice)', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(716, 7, 51, 0, 194, 'Food', 'Mango shake', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(717, 7, 51, 0, 195, 'Food', 'Banana shake', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(718, 7, 51, 0, 196, 'Food', 'Pineapple shake', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(719, 7, 51, 0, 197, 'Food', 'watermelon shake', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(720, 7, 51, 0, 198, 'Food', 'vanilla shake', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(721, 7, 51, 0, 199, 'Food', 'strawberry shake', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(722, 7, 51, 0, 200, 'Food', 'chocolate shake', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(723, 7, 51, 0, 201, 'Food', 'oreo shake', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(724, 7, 51, 0, 202, 'Food', 'imported red/white wine', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(725, 7, 51, 0, 203, 'Food', 'Rum', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(726, 7, 51, 0, 204, 'Food', 'Gin', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(727, 7, 51, 0, 205, 'Food', 'vodka', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(728, 7, 51, 0, 206, 'Food', 'tequila', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(729, 7, 51, 0, 207, 'Food', 'Red label ', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(730, 7, 51, 0, 208, 'Food', 'Black label ', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(731, 7, 51, 0, 209, 'Food', 'Chivas legal', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(732, 7, 51, 0, 210, 'Food', 'thai whisky', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(733, 7, 51, 0, 211, 'Food', 'Jack daniel', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(734, 7, 51, 0, 212, 'Food', 'Jim beam', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(735, 7, 51, 0, 213, 'Food', 'Sang som', 'Plate', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(736, 7, 51, 0, 214, 'Food', 'J&B rare', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(737, 7, 51, 0, 215, 'Food', 'Jameson lrish ', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(738, 7, 51, 0, 216, 'Food', 'Liqour', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(739, 7, 50, 126, 217, 'Food', 'Stir fried cashew nut 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(740, 7, 50, 126, 218, 'Food', 'Stir fried tamarind sauce 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(741, 7, 50, 126, 219, 'Food', 'Stir fried Broccoli 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(742, 7, 50, 126, 220, 'Food', 'Stir fried asparagus 210', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(743, 7, 50, 126, 221, 'Food', 'Stir fried curry paste 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(744, 7, 50, 126, 222, 'Food', 'thai red curry', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(745, 7, 50, 126, 223, 'Food', 'yellow curry', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(746, 7, 50, 84, 224, 'Food', 'Mix veg salad', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(747, 7, 50, 84, 225, 'Food', 'Tomato salad', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(748, 7, 50, 84, 226, 'Food', 'Egg salad', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(749, 7, 50, 84, 227, 'Food', 'seafood salad', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(750, 7, 50, 84, 228, 'Food', 'tuna salad', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(751, 7, 50, 85, 229, 'Food', 'Cream broccoli soup', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(752, 7, 50, 85, 230, 'Food', 'Cream chicken soup', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(753, 7, 50, 85, 231, 'Food', 'Cream mushroom soup', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(754, 7, 50, 85, 232, 'Food', 'Cream tomato soup', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(755, 7, 50, 95, 233, 'Food', 'fried squid with garlic', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(756, 7, 50, 95, 234, 'Food', 'stir fried sweet and sour squid', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(757, 7, 50, 95, 235, 'Food', 'grilled squid', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(758, 7, 50, 95, 236, 'Food', 'stir fried squid with curry powder', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(759, 7, 50, 95, 237, 'Food', 'steamed squid with sour sauce', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(760, 7, 50, 88, 238, 'Food', 'sea bass steak with white sauce', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(761, 7, 50, 88, 239, 'Food', 'Shrimp with white sauce', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(762, 7, 50, 88, 240, 'Food', 'Pork chop', 'Plate', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(763, 7, 50, 84, 241, 'Food', 'Pork salad', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(764, 7, 50, 88, 242, 'Food', 'Lamb shanks', 'Plate', 'unit', 7, 550, 550, '', 0, '0', 'Active'),
(765, 7, 50, 88, 243, 'Food', 'Pork rib steak', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(766, 7, 50, 88, 244, 'Food', 't bone steak', 'Plate', 'unit', 7, 480, 480, '', 0, '0', 'Active'),
(767, 7, 50, 88, 245, 'Food', 'Striplon streak', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(768, 7, 50, 88, 246, 'Food', 'Tenderloin streak', 'Plate', 'unit', 7, 450, 450, '', 0, '0', 'Active'),
(769, 7, 50, 89, 247, 'Food', 'spicy thai seafood salad', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(770, 7, 50, 89, 248, 'Food', 'thai glass noodle salad seafood', 'Plate', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(771, 7, 50, 89, 249, 'Food', 'spicy thai salad', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(772, 7, 50, 89, 250, 'Food', 'tom yum seafood ', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(773, 7, 50, 89, 251, 'Food', 'thai glass noodle soup with chicken ', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(774, 7, 50, 89, 252, 'Food', 'thai glass noodle soup with seafood ', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(775, 7, 50, 89, 253, 'Food', 'thai coconut chicken /seafood soup', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(776, 7, 50, 89, 254, 'Food', 'spicy minced chicken salad ', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(778, 7, 50, 89, 255, 'Food', 'spicy minced pork/beef salad ', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(779, 7, 50, 89, 256, 'Food', 'spicy papaya salad', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(780, 7, 50, 81, 257, 'Food', 'steamed shrimp', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(781, 7, 50, 81, 258, 'Food', 'satay chicken/beef 5pc', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(782, 7, 50, 81, 259, 'Food', 'satay shrimp 5pc', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(783, 7, 50, 81, 260, 'Food', 'Chicken nuggets and fries', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(784, 7, 50, 81, 261, 'Food', 'Fried shrimp cakes 4pc ', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(785, 7, 50, 81, 262, 'Food', 'crispy fried squid 6pc', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(786, 7, 50, 81, 263, 'Food', 'fried chicken', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(787, 7, 50, 81, 264, 'Food', 'chicken spring rolls ', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(788, 7, 50, 81, 265, 'Food', 'Fried fish and chips', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(789, 7, 50, 81, 266, 'Food', 'Shrimp tempura 6pc', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(790, 7, 50, 81, 267, 'Food', 'French fries', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(791, 7, 50, 81, 268, 'Food', 'Baked Potato', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(792, 7, 50, 81, 269, 'Food', 'garlic bread', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(793, 7, 50, 93, 270, 'Food', 'stir fried tiger prawn with sweet and sour sauce', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(794, 7, 50, 93, 271, 'Food', 'stir fried tiger prawn with tamarind sauce', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(795, 7, 50, 93, 272, 'Food', 'fried tiger prawn with garlic', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(796, 7, 50, 93, 273, 'Food', 'stir fried tiger prawn with green curry', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(797, 7, 50, 93, 274, 'Food', 'stir fried tiger prawn with curry powder', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(798, 7, 50, 93, 275, 'Food', 'Grilled tiger prawns ', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(799, 7, 50, 93, 276, 'Food', 'baked tiger prawns with garlic butter', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(800, 7, 50, 93, 277, 'Food', 'baked tiger prawns with glass noodles', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(801, 7, 50, 126, 278, 'Food', 'Stir fried cashew nut 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(802, 7, 50, 126, 279, 'Food', 'Stir fried cashew nut 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(803, 7, 50, 126, 280, 'Food', 'Stir fried curry paste 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(804, 7, 50, 126, 281, 'Food', 'Stir fried curry paste 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(805, 7, 50, 126, 282, 'Food', 'Stir fried tamarind sauce 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(806, 7, 50, 126, 283, 'Food', 'Stir fried tamarind sauce 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(807, 7, 50, 126, 284, 'Food', 'massaman curry 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(821, 7, 50, 126, 285, 'Food', 'massaman curry 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(822, 7, 50, 126, 286, 'Food', 'massaman curry 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(823, 7, 50, 126, 287, 'Food', 'Stir fried Broccoli 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(824, 7, 50, 126, 288, 'Food', 'Stir fried Broccoli 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(825, 7, 50, 126, 289, 'Food', 'Stir fried asparagus 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(826, 7, 50, 126, 290, 'Food', 'Stir fried asparagus 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(827, 7, 50, 126, 291, 'Food', 'thai curry with coconut milk 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(828, 7, 50, 126, 292, 'Food', 'thai curry with coconut milk 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(829, 7, 50, 126, 293, 'Food', 'thai curry with coconut milk 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(830, 7, 50, 126, 294, 'Food', 'thai sour curry soup 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(831, 7, 50, 126, 295, 'Food', 'thai sour curry soup 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(832, 7, 50, 126, 296, 'Food', 'thai sour curry soup 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(833, 7, 50, 86, 297, 'Food', 'seafood pizza', 'Plate', 'unit', 7, 390, 390, '', 0, '0', 'Active'),
(834, 7, 50, 86, 298, 'Food', 'veg pizza', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(835, 7, 50, 86, 299, 'Food', 'capricciosa pizza', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(836, 7, 50, 86, 300, 'Food', 'quattro stagioni pizza', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(837, 7, 50, 86, 301, 'Food', 'salami pizza', 'Plate', 'unit', 7, 380, 380, '', 0, '0', 'Active'),
(838, 7, 50, 86, 302, 'Food', 'margherita pizza', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(839, 7, 50, 82, 303, 'Food', 'ham and cheese sandwich and fries', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(840, 7, 50, 82, 304, 'Food', 'chicken cheese sandwich and fries', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(841, 7, 50, 82, 305, 'Food', 'tuna sandwich and fries', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(842, 7, 50, 82, 306, 'Food', 'pork/beef sandwich and fries', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(843, 7, 50, 82, 307, 'Food', 'club sandwich cheese and fries', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(844, 7, 50, 83, 308, 'Food', 'hamburger and fries', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(845, 7, 50, 83, 309, 'Food', 'beef burger and fries', 'Plate', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(846, 7, 50, 83, 310, 'Food', 'chicken burger and fries', 'Plate', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(847, 7, 50, 83, 311, 'Food', 'indian cottage cheese burger', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(848, 7, 50, 83, 312, 'Food', 'veg burger', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(849, 7, 50, 127, 313, 'Food', 'fried fish with fish sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(850, 7, 50, 127, 314, 'Food', 'steamed fish with lime sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(851, 7, 50, 127, 315, 'Food', 'Grilled fish', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(852, 7, 50, 127, 316, 'Food', 'fried fish with garlic', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(853, 7, 50, 127, 317, 'Food', 'steamed fish with ginger', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(854, 7, 50, 127, 318, 'Food', 'steamed fish with soy sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(855, 7, 50, 127, 319, 'Food', 'fish with three flavors sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(856, 7, 50, 127, 320, 'Food', 'fried fish with sweet and sour sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(858, 7, 50, 127, 321, 'Food', 'stir fried fish with black pepper sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(859, 7, 50, 127, 322, 'Food', 'fried fish with tamarind sauce', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(860, 7, 50, 127, 323, 'Food', 'fried fish with spicy mango salad', 'Plate', 'unit', 7, 410, 410, '', 0, '0', 'Active'),
(861, 7, 50, 88, 324, 'Food', 'salmon steak', 'Plate', 'unit', 7, 430, 430, '', 0, '0', 'Active'),
(862, 7, 50, 88, 325, 'Food', 'vienna schnitzel chicken', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(863, 7, 50, 88, 326, 'Food', 'vienna schnitzel pork/beef', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(864, 7, 50, 88, 327, 'Food', 'steak with garlice butter chicken', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(865, 7, 50, 88, 328, 'Food', 'steak with garlice butter pork/beef', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(866, 7, 50, 88, 329, 'Food', 'sea bass steak with mushroom sauce', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(867, 7, 50, 88, 330, 'Food', 'steak black pepper sauce pork', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(868, 7, 50, 88, 331, 'Food', 'steak black pepper sauce beef', 'Plate', 'unit', 7, 390, 390, '', 0, '0', 'Active'),
(869, 7, 50, 88, 332, 'Food', 'steak with mushroom sauce chicken', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(870, 7, 50, 88, 333, 'Food', 'steak with mushroom sauce pork/beef', 'Plate', 'unit', 7, 340, 340, '', 0, '0', 'Active'),
(871, 7, 50, 86, 334, 'Food', 'larb pizza', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(872, 7, 50, 86, 335, 'Food', 'tom yum pizza', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(873, 7, 50, 86, 336, 'Food', 'holy basil pizza', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(874, 7, 50, 86, 337, 'Food', 'chicken tikka pizza', 'Plate', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(875, 7, 50, 86, 338, 'Food', 'focaccia pizza', 'Plate', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(876, 7, 50, 86, 339, 'Food', 'pizza al tonno', 'Plate', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(877, 7, 50, 86, 340, 'Food', 'hawaiian pizza', 'Plate', 'unit', 7, 280, 280, '', 0, '0', 'Active'),
(878, 7, 50, 128, 341, 'Food', 'stir fried kale with oyster sauce', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(879, 7, 50, 128, 342, 'Food', 'stir fried morning glory', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(880, 7, 50, 128, 343, 'Food', 'thai red curry with veg', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(881, 7, 50, 128, 344, 'Food', 'stir fried bean sprouts', 'Plate', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(882, 7, 50, 128, 345, 'Food', 'stir fried mix veg', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(883, 7, 50, 128, 346, 'Food', 'green curry with veg', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(884, 7, 50, 128, 347, 'Food', 'stir fried asparagus with oyster sauce', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(885, 7, 50, 128, 348, 'Food', 'stir fried asparagus with oyster sauce', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(886, 7, 50, 90, 349, 'Food', 'Pad thai veg 160', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(887, 7, 50, 90, 350, 'Food', 'Pad thai non-veg 180', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(888, 7, 50, 90, 351, 'Food', 'stir fried noodles veg 160', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(889, 7, 50, 90, 352, 'Food', 'stir fried noodles non-veg 180', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(890, 7, 50, 90, 353, 'Food', 'stir fried yellow noodles veg 160', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(891, 7, 50, 90, 354, 'Food', 'stir fried yellow noodles non-veg 180', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(892, 7, 50, 90, 355, 'Food', 'fried noodles with gravy sauce veg 160', 'Plate', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(893, 7, 50, 90, 356, 'Food', 'fried noodles with gravy sauce non-veg 180', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(894, 7, 50, 87, 357, 'Food', 'macaroni chicken', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(895, 7, 50, 87, 358, 'Food', 'macaroni seafood', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(896, 7, 50, 87, 359, 'Food', 'spaghetti napolitan with tomato sauce', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(897, 7, 50, 87, 360, 'Food', 'thai green curry spaghetti', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(898, 7, 50, 87, 361, 'Food', 'spaghetti', 'Plate', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(899, 7, 50, 87, 362, 'Food', 'spaghetti tuna', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(900, 7, 50, 87, 363, 'Food', 'spaghetti seafood', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(901, 7, 50, 87, 364, 'Food', 'fettuccine alfredo', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(902, 7, 50, 87, 365, 'Food', 'spaghetti bolognese chicken 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(903, 7, 50, 87, 366, 'Food', 'spaghetti bolognese beef 210', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(904, 7, 50, 87, 367, 'Food', 'spaghetti carbonara', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(905, 7, 50, 91, 368, 'Food', 'new zealand mussels with cheese', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(906, 7, 50, 91, 369, 'Food', 'new zealand mussels with tomato sauce', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(907, 7, 50, 91, 370, 'Food', 'new zealand mussels with thai basil', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(908, 7, 50, 91, 371, 'Food', 'new zealand mussels with glass noodle', 'Plate', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(909, 7, 50, 91, 372, 'Food', 'oyster 70', 'Plate', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(910, 7, 50, 91, 373, 'Food', 'oyster 90', 'Plate', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(911, 7, 50, 92, 374, 'Food', 'stir fried crab with salt and chili', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(912, 7, 50, 92, 375, 'Food', 'stir fried crab with onion', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(913, 7, 50, 92, 376, 'Food', 'fried crab with garlic', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(914, 7, 50, 92, 377, 'Food', 'steamed crab', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(915, 7, 50, 92, 378, 'Food', 'baked crab with glass noodles', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(916, 5, 47, 78, 111, 'Food', 'เมนูแนะนำ', 'Bowl', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(917, 5, 47, 78, 112, 'Food', 'มีเมนูแนะนำไหม', 'Bowl', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(918, 7, 50, 94, 379, 'Food', 'grilled lobster', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(919, 7, 50, 94, 380, 'Food', 'baked lobster with cheese', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(920, 7, 50, 94, 381, 'Food', 'steamed lobster', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(921, 7, 50, 94, 382, 'Food', 'fried garlic lobster', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(922, 7, 50, 94, 383, 'Food', 'lobster with glass noodles', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(923, 7, 50, 94, 384, 'Food', 'lobster thermidor', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(924, 7, 50, 94, 385, 'Food', 'stir fried lobster with tamarind sauce', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(925, 7, 50, 94, 386, 'Food', 'stir fried lobster with curry powder', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(926, 7, 50, 94, 387, 'Food', 'stir fried lobster with green curry', 'Plate', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(927, 7, 50, 126, 388, 'Food', 'stir fried sweet and sour', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(928, 7, 50, 126, 389, 'Food', 'stir fried garlic and pepper', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(929, 7, 50, 126, 390, 'Food', 'stir fried ginger', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(930, 7, 50, 126, 391, 'Food', 'stir fried holy basil', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(931, 7, 50, 126, 392, 'Food', 'stir fried oyster sauce', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(932, 7, 50, 126, 393, 'Food', 'stir fried lemongrass', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(933, 7, 50, 126, 394, 'Food', 'stir fried bell peppers', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(934, 7, 50, 126, 395, 'Food', 'thai green curry', 'Plate', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(935, 7, 50, 126, 396, 'Food', 'stir fried sweet and sour 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(936, 7, 50, 126, 397, 'Food', 'stir fried sweet and sour 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(937, 7, 50, 126, 398, 'Food', 'stir fried garlic and pepper 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(938, 7, 50, 126, 399, 'Food', 'stir fried garlic and pepper 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(939, 7, 50, 126, 400, 'Food', 'stir fried ginger 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(940, 7, 50, 126, 401, 'Food', 'stir fried ginger 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(941, 7, 50, 126, 402, 'Food', 'stir fried holy basil 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(942, 7, 50, 126, 403, 'Food', 'stir fried holy basil 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(943, 7, 50, 126, 404, 'Food', 'stir fried oyster sauce 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(944, 7, 50, 126, 405, 'Food', 'stir fried oyster sauce 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(945, 7, 50, 126, 406, 'Food', 'stir fried lemongrass 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(946, 7, 50, 126, 407, 'Food', 'stir fried lemongrass 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(947, 7, 50, 126, 408, 'Food', 'stir fried bell peppers 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(948, 7, 50, 126, 409, 'Food', 'stir fried bell peppers 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(949, 7, 50, 126, 410, 'Food', 'thai green curry 170', 'Plate', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(950, 7, 50, 126, 411, 'Food', 'thai green curry 190', 'Plate', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(951, 8, 55, 114, 1, 'Food', 'Test item', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(952, 8, 54, 110, 2, 'Food', 'PRAWN CAESAR SALAD', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(953, 8, 54, 110, 3, 'Food', 'CHICKEN GREEK SALAD ', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(954, 8, 54, 110, 4, 'Food', 'FRENCH FRIES', '', 'unit', 7, 89, 89, '', 0, '0', 'Active'),
(955, 8, 54, 110, 5, 'Food', 'TOMATO SOUP', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(956, 8, 54, 110, 6, 'Food', 'HUMMUS', '', 'unit', 7, 165, 165, '', 0, '0', 'Active'),
(957, 8, 54, 110, 7, 'Food', 'HUMMUS WITH PRAWN', '', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(958, 8, 54, 110, 8, 'Food', 'TABOULEH', '', 'unit', 7, 165, 165, '', 0, '0', 'Active'),
(959, 8, 54, 110, 9, 'Food', 'MUTABLE', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(960, 8, 54, 110, 10, 'Food', 'TZATZIKI', '', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(961, 8, 54, 110, 11, 'Food', 'FALAFEL', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(962, 8, 54, 110, 12, 'Food', 'SUN RISE PLATTER', '', 'unit', 7, 399, 399, '', 0, '0', 'Active'),
(963, 8, 54, 110, 13, 'Food', 'PITTA BREAD', '', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(964, 8, 54, 110, 14, 'Food', 'BARBECUE LAMB WRAP', '', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(965, 8, 54, 110, 15, 'Food', 'BARBECUE CHICKEN WRAP', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(966, 8, 54, 110, 16, 'Food', 'SALMON KEBAB WITH SAFFRON RICE', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(967, 8, 54, 110, 17, 'Food', 'LAMB KEBAB WITH SAFFRON RICE', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(968, 8, 54, 110, 18, 'Food', 'CHICKEN KEBAB WITH SAFFRON RICE', '', 'unit', 7, 260, 260, '', 0, '0', 'Active'),
(969, 8, 54, 110, 19, 'Food', 'MIX GRILLED KEBAB CHICKEN&LAMB', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(970, 8, 54, 110, 20, 'Food', 'MIXED GRILLED KEBAB LAMB & SALMON', '', 'unit', 7, 360, 360, '', 0, '0', 'Active'),
(971, 8, 54, 110, 21, 'Food', 'MIXED GRILLED KEBAB SALMON & CHICKEN', '', 'unit', 7, 310, 310, '', 0, '0', 'Active'),
(972, 8, 54, 110, 22, 'Food', 'ALL MIX MEAT KEBAB PLATTER', '', 'unit', 7, 599, 599, '', 0, '0', 'Active'),
(973, 8, 54, 110, 23, 'Food', 'SUN RISE BURGER', '', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(974, 8, 54, 111, 24, 'Food', 'VEGETABLE SAMOSA', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(975, 8, 54, 111, 25, 'Food', 'TANDOORI LAMB CHOPS', '', 'unit', 7, 390, 390, '', 0, '0', 'Active'),
(976, 8, 54, 111, 26, 'Food', 'TANDOORI PRAWN', '', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(978, 8, 54, 111, 27, 'Food', 'TANDOORI CHICKEN', '', 'unit', 7, 260, 260, '', 0, '0', 'Active'),
(979, 8, 54, 111, 28, 'Food', 'CHICKEN TIKKA MASALA', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(980, 8, 54, 111, 29, 'Food', 'BUTTER CHICKEN', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(981, 8, 54, 111, 30, 'Food', 'PANEER BUTTER MASALA', '', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(982, 8, 54, 111, 31, 'Food', 'MUTTON ROGAN JOSH', '', 'unit', 7, 330, 330, '', 0, '0', 'Active'),
(984, 8, 54, 111, 32, 'Food', 'SAFFRON PULAO', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(985, 8, 54, 111, 33, 'Food', 'GARLIC NAAN BREAD', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(986, 8, 54, 111, 34, 'Food', 'CHEESE NAAN BREAD', '', 'unit', 7, 110, 110, '', 0, '0', 'Active'),
(987, 8, 54, 111, 35, 'Food', 'BUTTER NAAN BREAD', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(988, 8, 54, 111, 36, 'Food', 'ALOO KULCHA & TANDOORI ROTI [80]', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(989, 8, 54, 111, 37, 'Food', 'ALOO KULCHA & TANDOORI ROTI [60]', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(990, 8, 54, 111, 38, 'Food', 'YELLOW DAL TADKA', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(991, 8, 54, 112, 39, 'Food', 'POPPIA TOD', '', 'unit', 7, 99, 99, '', 0, '0', 'Active'),
(992, 8, 54, 112, 40, 'Food', 'LARB GAI', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(993, 8, 54, 112, 41, 'Food', 'LARB MOO', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(994, 8, 54, 112, 42, 'Food', 'SOM TAM THAI', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(995, 8, 54, 112, 43, 'Food', 'CHICKEN WING', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(996, 8, 54, 112, 44, 'Food', 'PAD THAI GOONG', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(997, 8, 54, 112, 45, 'Food', 'KAO PAD KAI', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(998, 8, 54, 112, 46, 'Food', 'KAO PAD MOO / GOONG', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(999, 8, 54, 112, 47, 'Food', 'PAD SIEW MOO', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(1000, 8, 54, 112, 48, 'Food', 'PAD SIEW GAI', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1001, 8, 54, 112, 49, 'Food', 'PAD KRAPRAO GAI / MOO', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(1002, 8, 54, 112, 50, 'Food', 'KHAI JIEW GOONG', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1003, 8, 54, 112, 51, 'Food', 'KHAI JIEW MOO SUB', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1004, 8, 54, 112, 52, 'Food', 'KAO', '', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(1005, 8, 54, 112, 53, 'Food', 'PLAA MUEG PAD PONG GAREE', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1006, 8, 54, 112, 54, 'Food', 'KOR MOO YANG', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1007, 8, 54, 112, 55, 'Food', 'PLAA KAPONG PREAW WAAN', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(1008, 8, 54, 112, 56, 'Food', 'FHANAENG GAI', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1009, 8, 54, 112, 57, 'Food', 'FHANAENG MOO', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(1010, 8, 54, 112, 58, 'Food', 'KAI PAD MED HIMMAPHAN', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1011, 8, 54, 112, 59, 'Food', 'TOM YAM GOONG', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(1012, 8, 54, 112, 60, 'Food', 'TOM YAM TALAY', '', 'unit', 7, 250, 250, '', 0, '0', 'Active');
INSERT INTO `items` (`id`, `shop_id`, `catid`, `subcatid`, `item_code`, `item_type`, `iname`, `unit`, `weight`, `tax`, `mrp`, `offerprice`, `description`, `min_stock`, `isstockable`, `status`) VALUES
(1013, 8, 54, 112, 61, 'Food', 'KAENG KIEW WAAN GAI', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1014, 8, 54, 112, 62, 'Food', 'KAENG KIEW WAAN GOONG', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(1015, 8, 54, 112, 63, 'Food', 'PAD PAK BOONG FAI DAENG', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1016, 8, 54, 112, 64, 'Food', 'NAAM TOK MOO', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(1017, 8, 54, 112, 65, 'Food', 'MANGO STICKY RICE', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1018, 8, 54, 113, 66, 'Food', 'MARGHERITA', '', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(1019, 8, 54, 113, 67, 'Food', 'HAWAIIAN PIZZA', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1020, 8, 54, 113, 68, 'Food', 'PEPPERONI PIZZA', '', 'unit', 7, 270, 270, '', 0, '0', 'Active'),
(1021, 8, 54, 113, 69, 'Food', 'SMOKED SALMON PIZZA', '', 'unit', 7, 360, 360, '', 0, '0', 'Active'),
(1022, 8, 54, 113, 70, 'Food', 'EASY SEAFOOD PIZZA', '', 'unit', 7, 370, 370, '', 0, '0', 'Active'),
(1026, 8, 55, 114, 74, 'Food', ' Mangoes And Cream Waffle', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1027, 8, 55, 114, 75, 'Food', 'Fresh Fruit', '', 'unit', 7, 99, 99, '', 0, '0', 'Active'),
(1028, 8, 55, 114, 76, 'Food', 'Granola & Yogurt', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1029, 8, 55, 114, 77, 'Food', 'Waffle', '', 'unit', 7, 99, 99, '', 0, '0', 'Active'),
(1030, 8, 55, 114, 78, 'Food', 'Banana And Nutella Waffle', '', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(1031, 8, 55, 114, 79, 'Food', 'Egg Salad On Toast', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1032, 8, 55, 114, 80, 'Food', 'Mushroom On Toast', '', 'unit', 7, 170, 170, '', 0, '0', 'Active'),
(1033, 8, 55, 114, 81, 'Food', 'Avocado On Toast', '', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(1034, 8, 55, 114, 82, 'Food', 'Salmon On Toast', '', 'unit', 7, 240, 240, '', 0, '0', 'Active'),
(1035, 8, 55, 114, 83, 'Food', 'French Toast', '', 'unit', 7, 190, 190, '', 0, '0', 'Active'),
(1036, 8, 55, 114, 84, 'Food', 'Tuna Melt', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(1037, 8, 55, 114, 85, 'Food', 'Breakfast BLT Sandwich', '', 'unit', 7, 199, 199, '', 0, '0', 'Active'),
(1038, 8, 55, 114, 86, 'Food', 'Eggs Benedict', '', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(1039, 8, 55, 114, 87, 'Food', 'Omelette', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(1040, 8, 55, 114, 88, 'Food', 'American Breakfast', '', 'unit', 7, 230, 230, '', 0, '0', 'Active'),
(1041, 8, 53, 106, 89, 'Food', 'Espresso', '', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(1042, 8, 53, 106, 90, 'Food', 'Americano', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1044, 8, 53, 106, 91, 'Food', 'Cappuccino', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1045, 8, 53, 106, 92, 'Food', 'Café Latte', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1046, 8, 53, 106, 93, 'Food', 'Spanish latte ', '', 'unit', 7, 75, 75, '', 0, '0', 'Active'),
(1047, 8, 53, 106, 94, 'Food', 'Salted Caramel Macchiato', '', 'unit', 7, 75, 75, '', 0, '0', 'Active'),
(1048, 8, 53, 106, 95, 'Food', 'Thai Tea', 'bowl', 'Per Piece', 7, 65, 65, '', 0, '0', 'Active'),
(1049, 8, 53, 106, 96, 'Food', 'Café Mocha  & Matcha latte', '', 'unit', 7, 75, 75, '', 0, '0', 'Active'),
(1051, 8, 53, 107, 97, 'Food', 'chamomile tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1052, 8, 53, 107, 98, 'Food', 'darjeeling tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1054, 8, 53, 107, 99, 'Food', 'english tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1055, 8, 53, 107, 100, 'Food', 'earl grey tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1056, 8, 53, 107, 101, 'Food', 'jasmine tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1057, 8, 53, 107, 102, 'Food', 'peppermint tea', '', 'unit', 7, 115, 115, '', 0, '0', 'Active'),
(1058, 8, 53, 108, 103, 'Food', 'Green extract', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1059, 8, 53, 108, 104, 'Food', 'Orange juice', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1060, 8, 53, 108, 105, 'Food', 'Vitality Boost', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1061, 8, 53, 108, 106, 'Food', 'Pink extract', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1062, 8, 53, 108, 107, 'Food', 'Pineapple juice', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1063, 8, 53, 108, 108, 'Food', 'Coconut Juice', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1064, 8, 53, 108, 109, 'Food', 'Blue Lemonade', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1065, 8, 53, 108, 110, 'Food', 'Lemon Iced Tea', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1066, 8, 53, 108, 111, 'Food', 'Lemonade  ', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1067, 8, 53, 108, 112, 'Food', 'Pink Lemonade', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1068, 8, 53, 109, 113, 'Food', 'Minted Watermelon', '', 'unit', 7, 75, 75, '', 0, '0', 'Active'),
(1069, 8, 53, 109, 114, 'Food', 'Mango Lassi ', '', 'unit', 7, 75, 75, '', 0, '0', 'Active'),
(1070, 8, 53, 109, 115, 'Food', 'Strawberry Daphne ', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1071, 8, 53, 109, 116, 'Food', 'Banana Nutella Milkshake', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1072, 8, 53, 109, 117, 'Food', 'Good morning, Sunshine', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1073, 8, 53, 109, 118, 'Food', 'Blue Dream', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1074, 8, 53, 109, 119, 'Food', 'Blue Dream', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1075, 8, 53, 109, 120, 'Food', 'Chocolate Milkshake', '', 'unit', 7, 85, 85, '', 0, '0', 'Active'),
(1076, 8, 52, 98, 121, 'Food', 'Singha (small)', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1077, 8, 52, 98, 122, 'Food', 'Singha (Big)', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1078, 8, 52, 98, 123, 'Food', 'Chang (small)', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1079, 8, 52, 98, 124, 'Food', 'Chang (Big)', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1080, 8, 52, 98, 125, 'Food', 'Leo (small)', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1081, 8, 52, 98, 126, 'Food', 'Leo (Big)', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1082, 8, 52, 98, 127, 'Food', 'Heineken (Small)', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1083, 8, 52, 98, 128, 'Food', 'Heineken (Big)', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1084, 8, 52, 129, 129, 'Food', 'WHISKEY SOUR ', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1085, 8, 52, 129, 130, 'Food', 'MOJITO', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1086, 8, 52, 129, 131, 'Food', 'MARGARITA STIR/ FROZEN', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1087, 8, 52, 129, 132, 'Food', 'GODFATHER ', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1088, 8, 52, 129, 133, 'Food', 'APEROL SPRITZ ', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1089, 8, 52, 129, 134, 'Food', 'FRANCE 75', '', 'unit', 7, 320, 320, '', 0, '0', 'Active'),
(1090, 8, 52, 105, 135, 'Food', 'RED WINE RESER VADO', '', 'unit', 7, 1600, 1600, '', 0, '0', 'Active'),
(1091, 8, 52, 105, 136, 'Food', 'CABERNET SAUVIGNON', '', 'unit', 7, 1600, 1600, '', 0, '0', 'Active'),
(1092, 8, 52, 105, 137, 'Food', 'WHITE WINE BRANCOTT', '', 'unit', 7, 1700, 1700, '', 0, '0', 'Active'),
(1093, 8, 52, 105, 138, 'Food', ' ESTATE', '', 'unit', 7, 1700, 1700, '', 0, '0', 'Active'),
(1094, 8, 52, 105, 139, 'Food', 'SAUVIGNON BLANC', '', 'unit', 7, 1700, 1700, '', 0, '0', 'Active'),
(1095, 8, 52, 105, 140, 'Food', 'SPARKLING WINE Glass', '', 'unit', 7, 290, 290, '', 0, '0', 'Active'),
(1096, 8, 52, 105, 141, 'Food', 'SPARKLING WINE Glass', '', 'unit', 7, 1850, 1850, '', 0, '0', 'Active'),
(1097, 8, 52, 97, 142, 'Food', 'ABSOLUTE', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1098, 8, 52, 97, 143, 'Food', 'BOMBAY SAPPHIRE', '', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(1099, 8, 52, 97, 144, 'Food', 'HENDRICKS', '', 'unit', 7, 350, 350, '', 0, '0', 'Active'),
(1100, 8, 52, 97, 145, 'Food', 'BACARDI RUM', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1101, 8, 52, 97, 146, 'Food', 'SIERRA', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1102, 8, 52, 97, 147, 'Food', 'JAMESON', '', 'unit', 7, 270, 270, '', 0, '0', 'Active'),
(1103, 8, 52, 97, 148, 'Food', 'JACK DANIELS', '', 'unit', 7, 300, 300, '', 0, '0', 'Active'),
(1104, 8, 52, 97, 149, 'Food', 'JACK DANIELS', '', 'unit', 7, 250, 250, '', 0, '0', 'Active'),
(1105, 8, 52, 99, 150, 'Food', 'ABSOLUTE', '', 'unit', 7, 2500, 2500, '', 0, '0', 'Active'),
(1107, 8, 52, 100, 152, 'Food', 'HENDRICKS', '', 'unit', 7, 2870, 2870, '', 0, '0', 'Active'),
(1108, 8, 52, 100, 153, 'Food', 'BOMBAY SAPPHIRE', '', 'unit', 7, 2650, 2650, '', 0, '0', 'Active'),
(1109, 8, 52, 101, 154, 'Food', 'BACARDI RUM', '', 'unit', 7, 2500, 2500, '', 0, '0', 'Active'),
(1110, 8, 52, 102, 155, 'Food', 'SIERRA', '', 'unit', 7, 2350, 2350, '', 0, '0', 'Active'),
(1112, 8, 52, 103, 157, 'Food', 'JACK DANIELS', '', 'unit', 7, 2550, 2550, '', 0, '0', 'Active'),
(1113, 8, 52, 103, 158, 'Food', 'JAMESON', '', 'unit', 7, 2510, 2510, '', 0, '0', 'Active'),
(1114, 8, 52, 104, 159, 'Food', 'BAILEY’S', '', 'unit', 7, 2500, 2500, '', 0, '0', 'Active'),
(1115, 7, 49, 121, 412, 'Food', 'Veg soup', 'Plate', 'unit', 7, 130, 130, '', 0, '0', 'Active'),
(1116, 7, 49, 121, 413, 'Food', 'Mushroom soup', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1117, 7, 49, 121, 414, 'Food', 'chicken soup', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1118, 7, 49, 121, 415, 'Food', 'mutton soup', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(1119, 7, 49, 121, 416, 'Food', 'dal soup', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1120, 7, 49, 121, 417, 'Food', 'tomato soup', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1121, 7, 49, 121, 418, 'Food', 'mancho soup', 'Plate', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1122, 7, 49, 121, 419, 'Food', 'prawn soup', 'Plate', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(1123, 9, 56, 130, 1, 'Food', 'Masala Tea', '', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(1124, 9, 56, 130, 2, 'Food', 'Coffee', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(1125, 9, 56, 130, 3, 'Food', 'Butter Milk', '', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(1126, 9, 56, 130, 4, 'Food', 'Sweet Lassi', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1127, 9, 56, 130, 5, 'Food', 'Mango Lassi', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1128, 9, 56, 130, 6, 'Food', 'French fries', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1129, 9, 56, 130, 7, 'Food', 'Chicken nugget', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(1130, 9, 56, 130, 8, 'Food', 'Chicken pakora', '', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(1131, 9, 56, 130, 9, 'Food', 'Paneer pakora', '', 'unit', 7, 220, 220, '', 0, '0', 'Active'),
(1132, 9, 56, 130, 10, 'Food', 'Mix veg pakora', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1133, 9, 56, 130, 11, 'Food', 'Paneer chilli', '', 'unit', 7, 180, 180, '', 0, '0', 'Active'),
(1134, 9, 56, 130, 12, 'Food', 'Chicken chilli', '', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(1135, 9, 56, 130, 13, 'Food', 'Aloo parantha with curd', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1136, 9, 56, 130, 14, 'Food', 'paneer paratha', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1137, 9, 56, 130, 15, 'Food', 'Gobi paratha', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1138, 9, 56, 130, 16, 'Food', 'Mix veg paratha', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1139, 9, 56, 130, 17, 'Food', 'Maggi', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(1140, 9, 56, 130, 18, 'Food', 'Poha', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1141, 9, 56, 130, 19, 'Food', 'Chana chat', '', 'unit', 7, 110, 110, '', 0, '0', 'Active'),
(1142, 9, 56, 130, 20, 'Food', 'Rosted papad', '', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(1143, 9, 56, 130, 21, 'Food', 'Fry papad', '', 'unit', 7, 40, 40, '', 0, '0', 'Active'),
(1144, 9, 56, 130, 22, 'Food', 'Masala papad', '', 'unit', 7, 50, 50, '', 0, '0', 'Active'),
(1145, 9, 56, 130, 23, 'Food', 'Pinet masala', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1146, 9, 57, 134, 24, 'Food', 'Heineken (Small)', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(1147, 9, 57, 134, 25, 'Food', 'Heineken (Big)', '', 'unit', 7, 110, 110, '', 0, '0', 'Active'),
(1148, 9, 57, 134, 26, 'Food', 'Budweiser', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1149, 9, 57, 134, 27, 'Food', 'Leo (small)', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1150, 9, 57, 134, 28, 'Food', 'Leo (Big)', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1152, 9, 57, 134, 29, 'Food', 'Singha (small)', '', 'unit', 7, 70, 70, '', 0, '0', 'Active'),
(1153, 9, 57, 134, 30, 'Food', 'Singha (Big)', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1154, 9, 57, 134, 31, 'Food', 'Chang (small)', '', 'unit', 7, 65, 65, '', 0, '0', 'Active'),
(1155, 9, 57, 134, 32, 'Food', 'Chang (Big)', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1156, 9, 57, 134, 33, 'Food', 'Smirnoff', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1157, 9, 57, 132, 34, 'Food', 'Jack daniel', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1158, 9, 57, 133, 35, 'Food', 'Jack daniel', '', 'unit', 7, 210, 210, '', 0, '0', 'Active'),
(1159, 9, 57, 131, 36, 'Food', 'Jack daniel', '', 'unit', 7, 2200, 2200, '', 0, '0', 'Active'),
(1161, 9, 57, 132, 37, 'Food', 'Chivas legal', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1162, 9, 57, 133, 38, 'Food', 'Chivas legal', '', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(1164, 9, 57, 132, 40, 'Food', 'Black label ', '', 'unit', 7, 120, 120, '', 0, '0', 'Active'),
(1165, 9, 57, 133, 41, 'Food', 'Black label ', '', 'unit', 7, 200, 200, '', 0, '0', 'Active'),
(1167, 9, 57, 131, 42, 'Food', 'Black label ', '', 'unit', 7, 1900, 1900, '', 0, '0', 'Active'),
(1168, 9, 57, 132, 43, 'Food', 'Red label ', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1169, 9, 57, 132, 44, 'Food', 'Red label ', '', 'unit', 7, 160, 160, '', 0, '0', 'Active'),
(1170, 9, 57, 131, 45, 'Food', 'Red label ', '', 'unit', 7, 1500, 1500, '', 0, '0', 'Active'),
(1171, 9, 57, 132, 46, 'Food', 'Blend 285', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(1172, 9, 57, 133, 47, 'Food', 'Blend 285', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1173, 9, 57, 131, 48, 'Food', 'Blend 285', '', 'unit', 7, 900, 900, '', 0, '0', 'Active'),
(1174, 9, 57, 131, 49, 'Food', 'Chivas legal', '', 'unit', 7, 1900, 1900, '', 0, '0', 'Active'),
(1175, 9, 57, 132, 50, 'Food', 'Sangsom', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(1176, 9, 57, 133, 51, 'Food', 'Sangsom', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1178, 9, 57, 131, 52, 'Food', 'Sangsom', '', 'unit', 7, 900, 900, '', 0, '0', 'Active'),
(1179, 9, 57, 132, 53, 'Food', 'Hongthong', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(1180, 9, 57, 133, 54, 'Food', 'Hongthong', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1181, 9, 57, 131, 55, 'Food', 'Hongthong', '', 'unit', 7, 900, 900, '', 0, '0', 'Active'),
(1182, 9, 57, 132, 56, 'Food', '100 Pipers', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1184, 9, 57, 133, 57, 'Food', '100 Pipers', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1185, 9, 57, 131, 58, 'Food', '100 Pipers', '', 'unit', 7, 900, 900, '', 0, '0', 'Active'),
(1186, 9, 57, 132, 59, 'Food', 'Ballantine', '', 'unit', 7, 90, 90, '', 0, '0', 'Active'),
(1187, 9, 57, 133, 60, 'Food', 'Ballantine', '', 'unit', 7, 150, 150, '', 0, '0', 'Active'),
(1188, 9, 57, 131, 61, 'Food', 'Ballantine', '', 'unit', 7, 1400, 1400, '', 0, '0', 'Active'),
(1189, 9, 57, 132, 62, 'Food', 'Absolut Vodka', '', 'unit', 7, 80, 80, '', 0, '0', 'Active'),
(1190, 9, 57, 133, 63, 'Food', 'Absolut Vodka', '', 'unit', 7, 140, 140, '', 0, '0', 'Active'),
(1191, 9, 57, 131, 64, 'Food', 'Absolut Vodka', '', 'unit', 7, 1300, 1300, '', 0, '0', 'Active'),
(1192, 9, 57, 132, 65, 'Food', 'Royal stag', '', 'unit', 7, 60, 60, '', 0, '0', 'Active'),
(1193, 9, 57, 133, 66, 'Food', 'Royal stag', '', 'unit', 7, 100, 100, '', 0, '0', 'Active'),
(1194, 9, 57, 131, 67, 'Food', 'Royal stag', '', 'unit', 7, 900, 900, '', 0, '0', 'Active'),
(1195, 9, 56, 130, 68, 'Food', 'coke', '', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(1196, 9, 56, 130, 69, 'Food', 'sprite', '', 'unit', 7, 30, 30, '', 0, '0', 'Active'),
(1197, 9, 56, 130, 70, 'Food', 'soda', '', 'unit', 7, 25, 25, '', 0, '0', 'Active'),
(1198, 9, 56, 130, 71, 'Food', 'water', '', 'unit', 7, 15, 15, '', 0, '0', 'Active'),
(1199, 9, 58, 135, 72, 'Food', 'Room303', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1200, 9, 58, 135, 73, 'Food', 'Room304', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1201, 9, 58, 135, 74, 'Food', 'Room403', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1202, 9, 58, 135, 75, 'Food', 'Room404', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1203, 9, 58, 135, 76, 'Food', 'Room503', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1204, 9, 58, 135, 77, 'Food', 'Room504', '', 'unit', 7, 950, 950, '', 0, '0', 'Active'),
(1205, 9, 58, 136, 78, 'Food', 'Room301', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1206, 9, 58, 136, 79, 'Food', 'Room302', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1207, 9, 58, 136, 80, 'Food', 'Room305', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1208, 9, 58, 136, 81, 'Food', 'Room401', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1209, 9, 58, 136, 82, 'Food', 'Room402', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1210, 9, 58, 136, 83, 'Food', 'Room405', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1211, 9, 58, 136, 84, 'Food', 'Room501', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1212, 9, 58, 136, 85, 'Food', 'Room502', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1213, 9, 58, 136, 86, 'Food', 'Room505', '', 'unit', 7, 800, 800, '', 0, '0', 'Active'),
(1214, 9, 58, 137, 87, 'Food', 'Room201', '', 'unit', 7, 2400, 2400, '', 0, '0', 'Active'),
(1215, 9, 58, 137, 88, 'Food', 'Room202', '', 'unit', 7, 2400, 2400, '', 0, '0', 'Active'),
(1216, 8, 53, 138, 160, 'Food', 'Crystal Water', 'btl', 'Per Piece', 7, 25, 25, '', 0, '1', 'Active'),
(1217, 8, 53, 138, 161, 'Food', 'Evian', 'btl', 'unit', 7, 85, 85, '', 0, '1', 'Active'),
(1218, 8, 53, 138, 162, 'Food', 'sparkling water', 'btl', 'Per Piece', 7, 99, 99, '', 0, '1', 'Active'),
(1219, 8, 53, 138, 163, 'Food', 'Coke', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1220, 8, 53, 138, 164, 'Food', 'Fanta', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1221, 8, 53, 138, 165, 'Food', 'Soda Water', 'cann', 'unit', 7, 25, 25, '', 0, '1', 'Active'),
(1222, 8, 53, 138, 166, 'Food', 'Sprite', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1223, 8, 53, 138, 167, 'Food', 'Ginger Ale', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1224, 8, 53, 138, 168, 'Food', 'Pepsi', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1225, 8, 53, 138, 169, 'Food', 'Coke Zero', 'cann', 'unit', 7, 30, 30, '', 0, '1', 'Active'),
(1226, 8, 53, 138, 170, 'Food', 'Fresh Coconut', 'cann', 'unit', 7, 65, 65, '', 0, '1', 'Active'),
(1227, 5, 47, 79, 113, 'Food', 'LAYS', 'Bowl', 'unit', 7, 25, 25, '', 0, '1', 'Active'),
(1228, 5, 48, 139, 0, 'Food', 'Black Label', 'btl', '', 7, 2200, 2200, '', 0, '1', 'Active'),
(1229, 5, 48, 139, 0, 'Food', 'Gold Label', 'btl', '', 7, 3500, 3500, '', 0, '1', 'Active'),
(1230, 5, 48, 139, 0, 'Food', 'Chivas 12Yr', 'btl', '', 7, 2500, 2500, '', 0, '1', 'Active'),
(1231, 5, 48, 139, 0, 'Food', 'Jack Daniel', 'btl', '', 7, 2400, 2400, '', 0, '1', 'Active'),
(1232, 5, 48, 140, 114, 'Bar', 'Chang 620ML', 'btl', 'unit', 7, 120, 120, '', 0, '1', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `item_images`
--

DROP TABLE IF EXISTS `item_images`;
CREATE TABLE IF NOT EXISTS `item_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `product_id` varchar(233) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `mimetype` varchar(100) NOT NULL,
  `size` int NOT NULL,
  `dateUploaded` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1171 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `item_images`
--

INSERT INTO `item_images` (`id`, `shop_id`, `product_id`, `filename`, `path`, `mimetype`, `size`, `dateUploaded`) VALUES
(1165, 5, '1227', 'images-1778428863703.jpeg', 'uploads/images-1778428863703.jpeg', 'image/jpeg', 203129, '2026-05-10 16:01:03'),
(1164, 8, '1226', 'images-1778421064329.jpg', 'uploads/images-1778421064329.jpg', 'image/jpeg', 67784, '2026-05-10 13:51:04'),
(1163, 8, '1225', 'images-1778421037457.webp', 'uploads/images-1778421037457.webp', 'image/webp', 29956, '2026-05-10 13:50:37'),
(1162, 8, '1224', 'images-1778420934233.jpg', 'uploads/images-1778420934233.jpg', 'image/jpeg', 5714, '2026-05-10 13:48:54'),
(1161, 8, '1223', 'images-1778420849299.webp', 'uploads/images-1778420849299.webp', 'image/webp', 195266, '2026-05-10 13:47:29'),
(1160, 8, '1222', 'images-1778420797494.jpg', 'uploads/images-1778420797494.jpg', 'image/jpeg', 25239, '2026-05-10 13:46:37'),
(1159, 8, '1221', 'images-1778420621095.webp', 'uploads/images-1778420621095.webp', 'image/webp', 107324, '2026-05-10 13:43:41'),
(1158, 8, '1220', 'images-1778420595411.jpg', 'uploads/images-1778420595411.jpg', 'image/jpeg', 8675, '2026-05-10 13:43:15'),
(1157, 8, '1219', 'images-1778420578386.webp', 'uploads/images-1778420578386.webp', 'image/webp', 29956, '2026-05-10 13:42:58'),
(1156, 8, '1218', 'images-1778403500594.webp', 'uploads/images-1778403500594.webp', 'image/webp', 4902, '2026-05-10 08:58:20'),
(1155, 8, '1217', 'images-1778403487255.webp', 'uploads/images-1778403487255.webp', 'image/webp', 12036, '2026-05-10 08:58:07'),
(463, 4, '505', 'images-1774609190880.png', 'uploads\\images-1774609190880.png', 'image/png', 779573, '2026-03-27 17:59:50'),
(1154, 8, '1216', 'images-1778403407276.jpg', 'uploads/images-1778403407276.jpg', 'image/jpeg', 3314243, '2026-05-10 08:56:47'),
(467, 5, '509', 'images-1774869253985.webp', 'uploads/images-1774869253985.webp', 'image/webp', 63948, '2026-03-30 11:14:14'),
(468, 5, '510', 'images-1774869266846.jpg', 'uploads/images-1774869266846.jpg', 'image/jpeg', 73153, '2026-03-30 11:14:26'),
(469, 5, '511', 'images-1774869278854.jpeg', 'uploads/images-1774869278854.jpeg', 'image/jpeg', 95927, '2026-03-30 11:14:38'),
(470, 5, '512', 'images-1774869294610.jpg', 'uploads/images-1774869294610.jpg', 'image/jpeg', 46967, '2026-03-30 11:14:54'),
(471, 5, '513', 'images-1774869312765.jpg', 'uploads/images-1774869312765.jpg', 'image/jpeg', 45261, '2026-03-30 11:15:12'),
(472, 5, '514', 'images-1774869326013.jpg', 'uploads/images-1774869326013.jpg', 'image/jpeg', 163990, '2026-03-30 11:15:26'),
(473, 5, '515', 'images-1774869338060.jpeg', 'uploads/images-1774869338060.jpeg', 'image/jpeg', 75615, '2026-03-30 11:15:38'),
(474, 5, '516', 'images-1774869408079.jpg', 'uploads/images-1774869408079.jpg', 'image/jpeg', 80345, '2026-03-30 11:16:48'),
(475, 5, '517', 'images-1774869419421.jpg', 'uploads/images-1774869419421.jpg', 'image/jpeg', 83389, '2026-03-30 11:16:59'),
(476, 5, '518', 'images-1774869430542.webp', 'uploads/images-1774869430542.webp', 'image/webp', 43396, '2026-03-30 11:17:10'),
(477, 7, '519', 'images-1775189506807.jpg', 'uploads/images-1775189506807.jpg', 'image/jpeg', 11720, '2026-04-03 04:11:46'),
(478, 7, '520', 'images-1775191491398.jpg', 'uploads/images-1775191491398.jpg', 'image/jpeg', 16278, '2026-04-03 04:44:51'),
(479, 7, '521', 'images-1775191554245.jpg', 'uploads/images-1775191554245.jpg', 'image/jpeg', 15509, '2026-04-03 04:45:54'),
(480, 7, '522', 'images-1775191601815.jpg', 'uploads/images-1775191601815.jpg', 'image/jpeg', 12387, '2026-04-03 04:46:41'),
(481, 7, '523', 'images-1775191734676.jpg', 'uploads/images-1775191734676.jpg', 'image/jpeg', 14554, '2026-04-03 04:48:54'),
(482, 7, '524', 'images-1775191773480.jpg', 'uploads/images-1775191773480.jpg', 'image/jpeg', 13676, '2026-04-03 04:49:33'),
(483, 7, '525', 'images-1775192463333.jpg', 'uploads/images-1775192463333.jpg', 'image/jpeg', 11160, '2026-04-03 05:01:03'),
(484, 7, '526', 'images-1775192629321.jpg', 'uploads/images-1775192629321.jpg', 'image/jpeg', 7164, '2026-04-03 05:03:49'),
(485, 7, '527', 'images-1775192699688.jpg', 'uploads/images-1775192699688.jpg', 'image/jpeg', 11274, '2026-04-03 05:04:59'),
(486, 7, '528', 'images-1775192946301.jpg', 'uploads/images-1775192946301.jpg', 'image/jpeg', 16104, '2026-04-03 05:09:06'),
(487, 7, '529', 'images-1775192961080.jpg', 'uploads/images-1775192961080.jpg', 'image/jpeg', 13119, '2026-04-03 05:09:21'),
(488, 7, '530', 'images-1775193091255.jpg', 'uploads/images-1775193091255.jpg', 'image/jpeg', 14558, '2026-04-03 05:11:31'),
(489, 7, '531', 'images-1775193176673.jpg', 'uploads/images-1775193176673.jpg', 'image/jpeg', 15346, '2026-04-03 05:12:56'),
(490, 7, '532', 'images-1775193192202.jpg', 'uploads/images-1775193192202.jpg', 'image/jpeg', 15346, '2026-04-03 05:13:12'),
(491, 7, '533', 'images-1775193244966.jpg', 'uploads/images-1775193244966.jpg', 'image/jpeg', 10763, '2026-04-03 05:14:05'),
(492, 7, '534', 'images-1775193300852.jpg', 'uploads/images-1775193300852.jpg', 'image/jpeg', 7888, '2026-04-03 05:15:00'),
(493, 7, '535', 'images-1775193344685.jpg', 'uploads/images-1775193344685.jpg', 'image/jpeg', 7753, '2026-04-03 05:15:44'),
(494, 7, '536', 'images-1775193419643.jpg', 'uploads/images-1775193419643.jpg', 'image/jpeg', 9622, '2026-04-03 05:16:59'),
(495, 7, '537', 'images-1775193483755.jpg', 'uploads/images-1775193483755.jpg', 'image/jpeg', 15811, '2026-04-03 05:18:03'),
(496, 7, '538', 'images-1775193920150.jpg', 'uploads/images-1775193920150.jpg', 'image/jpeg', 12159, '2026-04-03 05:25:20'),
(497, 7, '539', 'images-1775193960697.jpg', 'uploads/images-1775193960697.jpg', 'image/jpeg', 12387, '2026-04-03 05:26:00'),
(498, 7, '540', 'images-1775194024465.jpg', 'uploads/images-1775194024465.jpg', 'image/jpeg', 8865, '2026-04-03 05:27:04'),
(499, 7, '541', 'images-1775194176275.jpg', 'uploads/images-1775194176275.jpg', 'image/jpeg', 8269, '2026-04-03 05:29:36'),
(500, 7, '542', 'images-1775197245363.jpg', 'uploads/images-1775197245363.jpg', 'image/jpeg', 14740, '2026-04-03 06:20:45'),
(501, 7, '543', 'images-1775197291052.jpg', 'uploads/images-1775197291052.jpg', 'image/jpeg', 12230, '2026-04-03 06:21:31'),
(502, 7, '544', 'images-1775197393650.jpg', 'uploads/images-1775197393650.jpg', 'image/jpeg', 11028, '2026-04-03 06:23:13'),
(503, 7, '545', 'images-1775197469771.jpg', 'uploads/images-1775197469771.jpg', 'image/jpeg', 13781, '2026-04-03 06:24:29'),
(504, 7, '546', 'images-1775197595625.jpg', 'uploads/images-1775197595625.jpg', 'image/jpeg', 13067, '2026-04-03 06:26:35'),
(505, 7, '547', 'images-1775197653423.jpg', 'uploads/images-1775197653423.jpg', 'image/jpeg', 8729, '2026-04-03 06:27:33'),
(506, 7, '548', 'images-1775197725586.jpg', 'uploads/images-1775197725586.jpg', 'image/jpeg', 12901, '2026-04-03 06:28:45'),
(508, 7, '551', 'images-1775197880816.jpg', 'uploads/images-1775197880816.jpg', 'image/jpeg', 19177, '2026-04-03 06:31:20'),
(509, 7, '552', 'images-1775197899936.jpg', 'uploads/images-1775197899936.jpg', 'image/jpeg', 14709, '2026-04-03 06:31:39'),
(510, 7, '553', 'images-1775197957325.jpg', 'uploads/images-1775197957325.jpg', 'image/jpeg', 14206, '2026-04-03 06:32:37'),
(511, 7, '554', 'images-1775198696987.jpg', 'uploads/images-1775198696987.jpg', 'image/jpeg', 12661, '2026-04-03 06:44:56'),
(512, 7, '555', 'images-1775198722778.jpg', 'uploads/images-1775198722778.jpg', 'image/jpeg', 14745, '2026-04-03 06:45:22'),
(513, 7, '556', 'images-1775198745333.jpg', 'uploads/images-1775198745333.jpg', 'image/jpeg', 15115, '2026-04-03 06:45:45'),
(514, 7, '557', 'images-1775198771126.jpg', 'uploads/images-1775198771126.jpg', 'image/jpeg', 20937, '2026-04-03 06:46:11'),
(515, 7, '558', 'images-1775198882258.jpg', 'uploads/images-1775198882258.jpg', 'image/jpeg', 15494, '2026-04-03 06:48:02'),
(516, 7, '559', 'images-1775198962448.jpg', 'uploads/images-1775198962448.jpg', 'image/jpeg', 9683, '2026-04-03 06:49:22'),
(517, 7, '560', 'images-1775199003128.jpg', 'uploads/images-1775199003128.jpg', 'image/jpeg', 17901, '2026-04-03 06:50:03'),
(518, 7, '561', 'images-1775199116735.jpg', 'uploads/images-1775199116735.jpg', 'image/jpeg', 12228, '2026-04-03 06:51:56'),
(519, 7, '562', 'images-1775199320549.jpg', 'uploads/images-1775199320549.jpg', 'image/jpeg', 10212, '2026-04-03 06:55:20'),
(520, 7, '563', 'images-1775199376430.jpg', 'uploads/images-1775199376430.jpg', 'image/jpeg', 13033, '2026-04-03 06:56:16'),
(521, 7, '564', 'images-1775199430181.jpg', 'uploads/images-1775199430181.jpg', 'image/jpeg', 10770, '2026-04-03 06:57:10'),
(522, 7, '565', 'images-1775199473164.jpg', 'uploads/images-1775199473164.jpg', 'image/jpeg', 11773, '2026-04-03 06:57:53'),
(523, 7, '566', 'images-1775199541998.jpg', 'uploads/images-1775199541998.jpg', 'image/jpeg', 13263, '2026-04-03 06:59:02'),
(524, 7, '567', 'images-1775199935645.jpg', 'uploads/images-1775199935645.jpg', 'image/jpeg', 16220, '2026-04-03 07:05:35'),
(525, 7, '568', 'images-1775199957792.jpg', 'uploads/images-1775199957792.jpg', 'image/jpeg', 12892, '2026-04-03 07:05:57'),
(526, 7, '569', 'images-1775200048151.jpg', 'uploads/images-1775200048151.jpg', 'image/jpeg', 12278, '2026-04-03 07:07:28'),
(527, 7, '570', 'images-1775200136996.jpg', 'uploads/images-1775200136996.jpg', 'image/jpeg', 9218, '2026-04-03 07:08:57'),
(528, 7, '571', 'images-1775200150036.jpg', 'uploads/images-1775200150036.jpg', 'image/jpeg', 15083, '2026-04-03 07:09:10'),
(529, 7, '572', 'images-1775200249368.jpg', 'uploads/images-1775200249368.jpg', 'image/jpeg', 12823, '2026-04-03 07:10:49'),
(530, 7, '573', 'images-1775200289523.jpg', 'uploads/images-1775200289523.jpg', 'image/jpeg', 8872, '2026-04-03 07:11:29'),
(531, 7, '574', 'images-1775200667847.jpg', 'uploads/images-1775200667847.jpg', 'image/jpeg', 11252, '2026-04-03 07:17:47'),
(532, 7, '575', 'images-1775200706392.jpg', 'uploads/images-1775200706392.jpg', 'image/jpeg', 11099, '2026-04-03 07:18:26'),
(533, 7, '576', 'images-1775201190920.jpg', 'uploads/images-1775201190920.jpg', 'image/jpeg', 22208, '2026-04-03 07:26:30'),
(534, 7, '577', 'images-1775201256239.jpg', 'uploads/images-1775201256239.jpg', 'image/jpeg', 61795, '2026-04-03 07:27:36'),
(535, 7, '578', 'images-1775201339197.png', 'uploads/images-1775201339197.png', 'image/png', 57507, '2026-04-03 07:28:59'),
(536, 7, '579', 'images-1775201372795.jpg', 'uploads/images-1775201372795.jpg', 'image/jpeg', 235630, '2026-04-03 07:29:32'),
(537, 7, '580', 'images-1775201666275.jpg', 'uploads/images-1775201666275.jpg', 'image/jpeg', 13847, '2026-04-03 07:34:26'),
(538, 7, '581', 'images-1775201684684.jpg', 'uploads/images-1775201684684.jpg', 'image/jpeg', 12978, '2026-04-03 07:34:44'),
(539, 7, '582', 'images-1775202218647.jpg', 'uploads/images-1775202218647.jpg', 'image/jpeg', 13883, '2026-04-03 07:43:38'),
(540, 7, '583', 'images-1775202282813.jpg', 'uploads/images-1775202282813.jpg', 'image/jpeg', 47641, '2026-04-03 07:44:42'),
(541, 7, '584', 'images-1775202504370.jpg', 'uploads/images-1775202504370.jpg', 'image/jpeg', 48824, '2026-04-03 07:48:24'),
(542, 7, '585', 'images-1775202578596.jpg', 'uploads/images-1775202578596.jpg', 'image/jpeg', 43117, '2026-04-03 07:49:38'),
(543, 7, '586', 'images-1775202616043.jpg', 'uploads/images-1775202616043.jpg', 'image/jpeg', 792623, '2026-04-03 07:50:16'),
(544, 7, '587', 'images-1775202642610.jpg', 'uploads/images-1775202642610.jpg', 'image/jpeg', 59395, '2026-04-03 07:50:42'),
(545, 7, '588', 'images-1775202823987.jpg', 'uploads/images-1775202823987.jpg', 'image/jpeg', 14222, '2026-04-03 07:53:43'),
(546, 7, '589', 'images-1775202952907.jpg', 'uploads/images-1775202952907.jpg', 'image/jpeg', 565485, '2026-04-03 07:55:52'),
(547, 7, '590', 'images-1775202983951.jpg', 'uploads/images-1775202983951.jpg', 'image/jpeg', 65037, '2026-04-03 07:56:23'),
(548, 7, '591', 'images-1775203013250.jpg', 'uploads/images-1775203013250.jpg', 'image/jpeg', 51027, '2026-04-03 07:56:53'),
(549, 7, '592', 'images-1775203105089.jpg', 'uploads/images-1775203105089.jpg', 'image/jpeg', 8786, '2026-04-03 07:58:25'),
(550, 7, '593', 'images-1775203156447.jpg', 'uploads/images-1775203156447.jpg', 'image/jpeg', 4222, '2026-04-03 07:59:16'),
(551, 7, '594', 'images-1775203261379.jpg', 'uploads/images-1775203261379.jpg', 'image/jpeg', 43117, '2026-04-03 08:01:01'),
(552, 7, '595', 'images-1775203301507.jpg', 'uploads/images-1775203301507.jpg', 'image/jpeg', 17501, '2026-04-03 08:01:41'),
(553, 7, '596', 'images-1775203330726.jpg', 'uploads/images-1775203330726.jpg', 'image/jpeg', 9357, '2026-04-03 08:02:10'),
(554, 7, '597', 'images-1775203941108.jpg', 'uploads/images-1775203941108.jpg', 'image/jpeg', 10396, '2026-04-03 08:12:21'),
(555, 7, '598', 'images-1775203968332.jpg', 'uploads/images-1775203968332.jpg', 'image/jpeg', 12674, '2026-04-03 08:12:48'),
(556, 7, '599', 'images-1775204022754.jpg', 'uploads/images-1775204022754.jpg', 'image/jpeg', 11409, '2026-04-03 08:13:42'),
(557, 7, '600', 'images-1775204047960.jpg', 'uploads/images-1775204047960.jpg', 'image/jpeg', 12399, '2026-04-03 08:14:07'),
(558, 7, '601', 'images-1775204080228.jpg', 'uploads/images-1775204080228.jpg', 'image/jpeg', 8241, '2026-04-03 08:14:40'),
(559, 7, '602', 'images-1775204107052.jpg', 'uploads/images-1775204107052.jpg', 'image/jpeg', 17966, '2026-04-03 08:15:07'),
(560, 7, '603', 'images-1775204134507.jpg', 'uploads/images-1775204134507.jpg', 'image/jpeg', 9578, '2026-04-03 08:15:34'),
(561, 7, '604', 'images-1775204171016.jpg', 'uploads/images-1775204171016.jpg', 'image/jpeg', 15006, '2026-04-03 08:16:11'),
(563, 7, '606', 'images-1775209532435.jpg', 'uploads/images-1775209532435.jpg', 'image/jpeg', 15819, '2026-04-03 09:45:32'),
(564, 7, '607', 'images-1775209549491.jpg', 'uploads/images-1775209549491.jpg', 'image/jpeg', 21799, '2026-04-03 09:45:49'),
(565, 7, '608', 'images-1775209581479.jpg', 'uploads/images-1775209581479.jpg', 'image/jpeg', 14519, '2026-04-03 09:46:21'),
(566, 7, '609', 'images-1775209606193.jpg', 'uploads/images-1775209606193.jpg', 'image/jpeg', 62728, '2026-04-03 09:46:46'),
(567, 7, '610', 'images-1775209628533.jpg', 'uploads/images-1775209628533.jpg', 'image/jpeg', 176143, '2026-04-03 09:47:08'),
(568, 7, '611', 'images-1775209645178.jpg', 'uploads/images-1775209645178.jpg', 'image/jpeg', 53049, '2026-04-03 09:47:25'),
(569, 7, '612', 'images-1775209668097.jpg', 'uploads/images-1775209668097.jpg', 'image/jpeg', 14003, '2026-04-03 09:47:48'),
(570, 7, '613', 'images-1775209702987.jpg', 'uploads/images-1775209702987.jpg', 'image/jpeg', 44045, '2026-04-03 09:48:23'),
(571, 7, '614', 'images-1775211019866.jpg', 'uploads/images-1775211019866.jpg', 'image/jpeg', 1170197, '2026-04-03 10:10:19'),
(572, 7, '615', 'images-1775227134736.jpg', 'uploads/images-1775227134736.jpg', 'image/jpeg', 14871, '2026-04-03 14:38:54'),
(573, 7, '616', 'images-1775227170594.jpg', 'uploads/images-1775227170594.jpg', 'image/jpeg', 18322, '2026-04-03 14:39:30'),
(574, 7, '617', 'images-1775227238303.jpg', 'uploads/images-1775227238303.jpg', 'image/jpeg', 3576336, '2026-04-03 14:40:38'),
(575, 7, '618', 'images-1775227563783.jpg', 'uploads/images-1775227563783.jpg', 'image/jpeg', 19056, '2026-04-03 14:46:03'),
(576, 7, '619', 'images-1775227583492.jpg', 'uploads/images-1775227583492.jpg', 'image/jpeg', 11203, '2026-04-03 14:46:23'),
(577, 7, '620', 'images-1775227621467.jpg', 'uploads/images-1775227621467.jpg', 'image/jpeg', 22306, '2026-04-03 14:47:01'),
(578, 7, '621', 'images-1775227694975.jpg', 'uploads/images-1775227694975.jpg', 'image/jpeg', 8241, '2026-04-03 14:48:15'),
(579, 7, '622', 'images-1775227724116.jpg', 'uploads/images-1775227724116.jpg', 'image/jpeg', 72687, '2026-04-03 14:48:44'),
(580, 7, '623', 'images-1775227783192.jpg', 'uploads/images-1775227783192.jpg', 'image/jpeg', 21060, '2026-04-03 14:49:43'),
(581, 7, '624', 'images-1775227865855.jpg', 'uploads/images-1775227865855.jpg', 'image/jpeg', 7749, '2026-04-03 14:51:05'),
(582, 7, '625', 'images-1775227922644.jpg', 'uploads/images-1775227922644.jpg', 'image/jpeg', 98032, '2026-04-03 14:52:02'),
(583, 7, '626', 'images-1775287431433.jpg', 'uploads/images-1775287431433.jpg', 'image/jpeg', 12676, '2026-04-04 07:23:51'),
(584, 7, '627', 'images-1775287454134.jpg', 'uploads/images-1775287454134.jpg', 'image/jpeg', 12587, '2026-04-04 07:24:14'),
(585, 7, '628', 'images-1775287523805.jpg', 'uploads/images-1775287523805.jpg', 'image/jpeg', 10614, '2026-04-04 07:25:23'),
(586, 7, '629', 'images-1775287586314.jpg', 'uploads/images-1775287586314.jpg', 'image/jpeg', 46227, '2026-04-04 07:26:26'),
(587, 7, '630', 'images-1775287718379.jpg', 'uploads/images-1775287718379.jpg', 'image/jpeg', 20452, '2026-04-04 07:28:38'),
(588, 7, '631', 'images-1775287778218.jpg', 'uploads/images-1775287778218.jpg', 'image/jpeg', 12932, '2026-04-04 07:29:38'),
(589, 7, '632', 'images-1775287821169.jpg', 'uploads/images-1775287821169.jpg', 'image/jpeg', 15516, '2026-04-04 07:30:21'),
(590, 7, '633', 'images-1775287888391.jpg', 'uploads/images-1775287888391.jpg', 'image/jpeg', 53958, '2026-04-04 07:31:28'),
(591, 7, '634', 'images-1775287936289.jpg', 'uploads/images-1775287936289.jpg', 'image/jpeg', 13197, '2026-04-04 07:32:16'),
(592, 7, '635', 'images-1775287972924.jpg', 'uploads/images-1775287972924.jpg', 'image/jpeg', 8898, '2026-04-04 07:32:52'),
(593, 7, '636', 'images-1775288245308.jpg', 'uploads/images-1775288245308.jpg', 'image/jpeg', 10432, '2026-04-04 07:37:25'),
(594, 7, '637', 'images-1775288265964.jpg', 'uploads/images-1775288265964.jpg', 'image/jpeg', 8623, '2026-04-04 07:37:45'),
(595, 7, '638', 'images-1775288283884.jpg', 'uploads/images-1775288283884.jpg', 'image/jpeg', 8824, '2026-04-04 07:38:03'),
(596, 7, '639', 'images-1775291921532.jpg', 'uploads/images-1775291921532.jpg', 'image/jpeg', 14426, '2026-04-04 08:38:41'),
(597, 7, '640', 'images-1775291994312.jpg', 'uploads/images-1775291994312.jpg', 'image/jpeg', 12362, '2026-04-04 08:39:54'),
(598, 7, '641', 'images-1775292036118.jpg', 'uploads/images-1775292036118.jpg', 'image/jpeg', 13734, '2026-04-04 08:40:36'),
(599, 7, '642', 'images-1775296595691.jpg', 'uploads/images-1775296595691.jpg', 'image/jpeg', 11557, '2026-04-04 09:56:35'),
(600, 7, '643', 'images-1775297841569.jpg', 'uploads/images-1775297841569.jpg', 'image/jpeg', 11310, '2026-04-04 10:17:21'),
(601, 7, '644', 'images-1775297856680.jpg', 'uploads/images-1775297856680.jpg', 'image/jpeg', 11344, '2026-04-04 10:17:36'),
(602, 7, '645', 'images-1775297917358.jpg', 'uploads/images-1775297917358.jpg', 'image/jpeg', 8144, '2026-04-04 10:18:37'),
(603, 7, '646', 'images-1775297943399.jpg', 'uploads/images-1775297943399.jpg', 'image/jpeg', 12395, '2026-04-04 10:19:03'),
(604, 7, '647', 'images-1775297966679.jpg', 'uploads/images-1775297966679.jpg', 'image/jpeg', 12456, '2026-04-04 10:19:26'),
(605, 7, '648', 'images-1775298016922.jpg', 'uploads/images-1775298016922.jpg', 'image/jpeg', 13163, '2026-04-04 10:20:16'),
(606, 7, '649', 'images-1775298042893.jpg', 'uploads/images-1775298042893.jpg', 'image/jpeg', 14389, '2026-04-04 10:20:42'),
(607, 7, '650', 'images-1775298066429.jpg', 'uploads/images-1775298066429.jpg', 'image/jpeg', 13331, '2026-04-04 10:21:06'),
(608, 7, '651', 'images-1775298114370.jpg', 'uploads/images-1775298114370.jpg', 'image/jpeg', 16223, '2026-04-04 10:21:54'),
(609, 7, '652', 'images-1775298149773.jpg', 'uploads/images-1775298149773.jpg', 'image/jpeg', 9420, '2026-04-04 10:22:29'),
(610, 7, '653', 'images-1775298168939.jpg', 'uploads/images-1775298168939.jpg', 'image/jpeg', 12562, '2026-04-04 10:22:48'),
(611, 7, '654', 'images-1775298199109.jpg', 'uploads/images-1775298199109.jpg', 'image/jpeg', 12592, '2026-04-04 10:23:19'),
(612, 7, '655', 'images-1775298279838.jpg', 'uploads/images-1775298279838.jpg', 'image/jpeg', 12479, '2026-04-04 10:24:39'),
(613, 7, '656', 'images-1775303759532.jpg', 'uploads/images-1775303759532.jpg', 'image/jpeg', 12495, '2026-04-04 11:55:59'),
(614, 7, '657', 'images-1775303785077.jpg', 'uploads/images-1775303785077.jpg', 'image/jpeg', 10326, '2026-04-04 11:56:25'),
(615, 7, '658', 'images-1775303823095.jpg', 'uploads/images-1775303823095.jpg', 'image/jpeg', 12695, '2026-04-04 11:57:03'),
(616, 7, '659', 'images-1775303875865.jpg', 'uploads/images-1775303875865.jpg', 'image/jpeg', 13876, '2026-04-04 11:57:55'),
(617, 7, '660', 'images-1775303899798.jpg', 'uploads/images-1775303899798.jpg', 'image/jpeg', 15648, '2026-04-04 11:58:19'),
(618, 7, '661', 'images-1775304107633.jpg', 'uploads/images-1775304107633.jpg', 'image/jpeg', 12168, '2026-04-04 12:01:47'),
(619, 7, '662', 'images-1775304127326.jpg', 'uploads/images-1775304127326.jpg', 'image/jpeg', 12168, '2026-04-04 12:02:07'),
(620, 7, '663', 'images-1775304283959.jpg', 'uploads/images-1775304283959.jpg', 'image/jpeg', 10840, '2026-04-04 12:04:43'),
(621, 7, '664', 'images-1775304346029.jpg', 'uploads/images-1775304346029.jpg', 'image/jpeg', 14416, '2026-04-04 12:05:46'),
(622, 7, '665', 'images-1775304702018.jpg', 'uploads/images-1775304702018.jpg', 'image/jpeg', 15157, '2026-04-04 12:11:42'),
(623, 7, '666', 'images-1775304734135.jpg', 'uploads/images-1775304734135.jpg', 'image/jpeg', 11740, '2026-04-04 12:12:14'),
(624, 7, '667', 'images-1775304794638.jpg', 'uploads/images-1775304794638.jpg', 'image/jpeg', 13592, '2026-04-04 12:13:14'),
(625, 7, '668', 'images-1775304917547.jpg', 'uploads/images-1775304917547.jpg', 'image/jpeg', 12514, '2026-04-04 12:15:17'),
(626, 7, '669', 'images-1775304939763.jpg', 'uploads/images-1775304939763.jpg', 'image/jpeg', 19055, '2026-04-04 12:15:39'),
(627, 7, '670', 'images-1775304966943.jpg', 'uploads/images-1775304966943.jpg', 'image/jpeg', 10750, '2026-04-04 12:16:06'),
(628, 7, '671', 'images-1775305075671.jpg', 'uploads/images-1775305075671.jpg', 'image/jpeg', 8755, '2026-04-04 12:17:55'),
(629, 7, '672', 'images-1775305105673.jpg', 'uploads/images-1775305105673.jpg', 'image/jpeg', 8861, '2026-04-04 12:18:25'),
(630, 7, '673', 'images-1775306704672.jpg', 'uploads/images-1775306704672.jpg', 'image/jpeg', 37711, '2026-04-04 12:45:04'),
(631, 7, '674', 'images-1775306747959.jpg', 'uploads/images-1775306747959.jpg', 'image/jpeg', 14786, '2026-04-04 12:45:47'),
(632, 7, '675', 'images-1775306809158.jpg', 'uploads/images-1775306809158.jpg', 'image/jpeg', 10592, '2026-04-04 12:46:49'),
(633, 7, '676', 'images-1775306837640.jpg', 'uploads/images-1775306837640.jpg', 'image/jpeg', 8752, '2026-04-04 12:47:17'),
(634, 7, '677', 'images-1775306856242.jpg', 'uploads/images-1775306856242.jpg', 'image/jpeg', 9685, '2026-04-04 12:47:36'),
(635, 7, '678', 'images-1775306893483.jpg', 'uploads/images-1775306893483.jpg', 'image/jpeg', 6476, '2026-04-04 12:48:13'),
(636, 7, '679', 'images-1775306922520.jpg', 'uploads/images-1775306922520.jpg', 'image/jpeg', 7747, '2026-04-04 12:48:42'),
(637, 7, '680', 'images-1775307218371.jpg', 'uploads/images-1775307218371.jpg', 'image/jpeg', 10461, '2026-04-04 12:53:38'),
(638, 7, '681', 'images-1775307410665.png', 'uploads/images-1775307410665.png', 'image/png', 69041, '2026-04-04 12:56:50'),
(639, 7, '682', 'images-1775307428305.png', 'uploads/images-1775307428305.png', 'image/png', 69041, '2026-04-04 12:57:08'),
(640, 7, '683', 'images-1775307667913.png', 'uploads/images-1775307667913.png', 'image/png', 75148, '2026-04-04 13:01:07'),
(641, 7, '684', 'images-1775307827830.jpg', 'uploads/images-1775307827830.jpg', 'image/jpeg', 12983, '2026-04-04 13:03:47'),
(642, 7, '685', 'images-1775307871067.jpg', 'uploads/images-1775307871067.jpg', 'image/jpeg', 10894, '2026-04-04 13:04:31'),
(643, 7, '686', 'images-1775307910741.jpg', 'uploads/images-1775307910741.jpg', 'image/jpeg', 13543, '2026-04-04 13:05:10'),
(644, 7, '687', 'images-1775308108975.jpg', 'uploads/images-1775308108975.jpg', 'image/jpeg', 4276, '2026-04-04 13:08:28'),
(645, 7, '688', 'images-1775308146008.jpg', 'uploads/images-1775308146008.jpg', 'image/jpeg', 4276, '2026-04-04 13:09:06'),
(646, 7, '689', 'images-1775308253893.jpg', 'uploads/images-1775308253893.jpg', 'image/jpeg', 7081, '2026-04-04 13:10:53'),
(647, 7, '690', 'images-1775308630666.jpg', 'uploads/images-1775308630666.jpg', 'image/jpeg', 7147, '2026-04-04 13:17:10'),
(648, 7, '691', 'images-1775309021901.jpg', 'uploads/images-1775309021901.jpg', 'image/jpeg', 6296, '2026-04-04 13:23:41'),
(649, 7, '692', 'images-1775309051545.jpg', 'uploads/images-1775309051545.jpg', 'image/jpeg', 5891, '2026-04-04 13:24:11'),
(650, 7, '693', 'images-1775309077524.jpg', 'uploads/images-1775309077524.jpg', 'image/jpeg', 6692, '2026-04-04 13:24:37'),
(651, 7, '694', 'images-1775309114835.jpg', 'uploads/images-1775309114835.jpg', 'image/jpeg', 4695, '2026-04-04 13:25:14'),
(652, 7, '695', 'images-1775309160995.jpg', 'uploads/images-1775309160995.jpg', 'image/jpeg', 6499, '2026-04-04 13:26:01'),
(654, 7, '697', 'images-1775309232539.jpg', 'uploads/images-1775309232539.jpg', 'image/jpeg', 10244, '2026-04-04 13:27:12'),
(655, 7, '698', 'images-1775309249135.jpg', 'uploads/images-1775309249135.jpg', 'image/jpeg', 4665, '2026-04-04 13:27:29'),
(656, 7, '699', 'images-1775309300257.jpg', 'uploads/images-1775309300257.jpg', 'image/jpeg', 10561, '2026-04-04 13:28:20'),
(657, 7, '700', 'images-1775309322433.jpg', 'uploads/images-1775309322433.jpg', 'image/jpeg', 11213, '2026-04-04 13:28:42'),
(658, 7, '701', 'images-1775309456143.jpg', 'uploads/images-1775309456143.jpg', 'image/jpeg', 8287, '2026-04-04 13:30:56'),
(659, 7, '702', 'images-1775310037028.jpg', 'uploads/images-1775310037028.jpg', 'image/jpeg', 9274, '2026-04-04 13:40:37'),
(660, 7, '703', 'images-1775310061356.jpg', 'uploads/images-1775310061356.jpg', 'image/jpeg', 9274, '2026-04-04 13:41:01'),
(661, 7, '704', 'images-1775310141798.jpg', 'uploads/images-1775310141798.jpg', 'image/jpeg', 11690, '2026-04-04 13:42:21'),
(662, 7, '705', 'images-1775310172451.jpg', 'uploads/images-1775310172451.jpg', 'image/jpeg', 11690, '2026-04-04 13:42:52'),
(663, 7, '706', 'images-1775310231313.jpg', 'uploads/images-1775310231313.jpg', 'image/jpeg', 10591, '2026-04-04 13:43:51'),
(664, 7, '707', 'images-1775310259875.jpg', 'uploads/images-1775310259875.jpg', 'image/jpeg', 10591, '2026-04-04 13:44:19'),
(665, 7, '708', 'images-1775310317957.jpg', 'uploads/images-1775310317957.jpg', 'image/jpeg', 10873, '2026-04-04 13:45:17'),
(666, 7, '709', 'images-1775310335799.jpg', 'uploads/images-1775310335799.jpg', 'image/jpeg', 10873, '2026-04-04 13:45:35'),
(667, 7, '710', 'images-1775310411369.jpg', 'uploads/images-1775310411369.jpg', 'image/jpeg', 5549, '2026-04-04 13:46:51'),
(668, 7, '711', 'images-1775310464995.jpg', 'uploads/images-1775310464995.jpg', 'image/jpeg', 5549, '2026-04-04 13:47:45'),
(669, 7, '712', 'images-1775310500491.jpg', 'uploads/images-1775310500491.jpg', 'image/jpeg', 7529, '2026-04-04 13:48:20'),
(670, 7, '713', 'images-1775310568423.jpg', 'uploads/images-1775310568423.jpg', 'image/jpeg', 7529, '2026-04-04 13:49:28'),
(671, 7, '714', 'images-1775310616688.jpg', 'uploads/images-1775310616688.jpg', 'image/jpeg', 10368, '2026-04-04 13:50:16'),
(672, 7, '715', 'images-1775310685941.jpg', 'uploads/images-1775310685941.jpg', 'image/jpeg', 10368, '2026-04-04 13:51:25'),
(673, 7, '716', 'images-1775311660335.jpg', 'uploads/images-1775311660335.jpg', 'image/jpeg', 10076, '2026-04-04 14:07:40'),
(674, 7, '717', 'images-1775311680611.jpg', 'uploads/images-1775311680611.jpg', 'image/jpeg', 5531, '2026-04-04 14:08:00'),
(675, 7, '718', 'images-1775311735651.jpg', 'uploads/images-1775311735651.jpg', 'image/jpeg', 9110, '2026-04-04 14:08:55'),
(676, 7, '719', 'images-1775311775696.jpg', 'uploads/images-1775311775696.jpg', 'image/jpeg', 7121, '2026-04-04 14:09:35'),
(677, 7, '720', 'images-1775311814283.jpg', 'uploads/images-1775311814283.jpg', 'image/jpeg', 6118, '2026-04-04 14:10:14'),
(678, 7, '721', 'images-1775311862948.jpg', 'uploads/images-1775311862948.jpg', 'image/jpeg', 6551, '2026-04-04 14:11:02'),
(679, 7, '722', 'images-1775311887345.jpg', 'uploads/images-1775311887345.jpg', 'image/jpeg', 8551, '2026-04-04 14:11:27'),
(680, 7, '723', 'images-1775311925617.jpg', 'uploads/images-1775311925617.jpg', 'image/jpeg', 9106, '2026-04-04 14:12:05'),
(681, 7, '724', 'images-1775311998071.jpg', 'uploads/images-1775311998071.jpg', 'image/jpeg', 6849, '2026-04-04 14:13:18'),
(682, 7, '725', 'images-1775312166105.jpg', 'uploads/images-1775312166105.jpg', 'image/jpeg', 5081, '2026-04-04 14:16:06'),
(683, 7, '726', 'images-1775312571316.jpg', 'uploads/images-1775312571316.jpg', 'image/jpeg', 5033, '2026-04-04 14:22:51'),
(684, 7, '727', 'images-1775313206297.jpg', 'uploads/images-1775313206297.jpg', 'image/jpeg', 4473, '2026-04-04 14:33:26'),
(685, 7, '728', 'images-1775313260745.jpg', 'uploads/images-1775313260745.jpg', 'image/jpeg', 5241, '2026-04-04 14:34:20'),
(686, 7, '729', 'images-1775313287249.jpg', 'uploads/images-1775313287249.jpg', 'image/jpeg', 5437, '2026-04-04 14:34:47'),
(687, 7, '730', 'images-1775313313826.jpg', 'uploads/images-1775313313826.jpg', 'image/jpeg', 3350, '2026-04-04 14:35:13'),
(688, 7, '731', 'images-1775313339042.jpg', 'uploads/images-1775313339042.jpg', 'image/jpeg', 4168, '2026-04-04 14:35:39'),
(689, 7, '732', 'images-1775313429102.jpg', 'uploads/images-1775313429102.jpg', 'image/jpeg', 4427, '2026-04-04 14:37:09'),
(690, 7, '733', 'images-1775313460251.jpg', 'uploads/images-1775313460251.jpg', 'image/jpeg', 5593, '2026-04-04 14:37:40'),
(691, 7, '734', 'images-1775313515021.jpg', 'uploads/images-1775313515021.jpg', 'image/jpeg', 4162, '2026-04-04 14:38:35'),
(692, 7, '735', 'images-1775313546226.jpg', 'uploads/images-1775313546226.jpg', 'image/jpeg', 3574, '2026-04-04 14:39:06'),
(693, 7, '736', 'images-1775313616630.jpg', 'uploads/images-1775313616630.jpg', 'image/jpeg', 7228, '2026-04-04 14:40:16'),
(694, 7, '737', 'images-1775313774641.jpg', 'uploads/images-1775313774641.jpg', 'image/jpeg', 4141, '2026-04-04 14:42:54'),
(695, 7, '738', 'images-1775313826851.jpg', 'uploads/images-1775313826851.jpg', 'image/jpeg', 3230, '2026-04-04 14:43:46'),
(696, 7, '739', 'images-1775318116251.jpg', 'uploads/images-1775318116251.jpg', 'image/jpeg', 12972, '2026-04-04 15:55:16'),
(697, 7, '740', 'images-1775318239374.jpg', 'uploads/images-1775318239374.jpg', 'image/jpeg', 11593, '2026-04-04 15:57:19'),
(698, 7, '741', 'images-1775318329805.jpg', 'uploads/images-1775318329805.jpg', 'image/jpeg', 16361, '2026-04-04 15:58:49'),
(699, 7, '742', 'images-1775318359246.jpg', 'uploads/images-1775318359246.jpg', 'image/jpeg', 10843, '2026-04-04 15:59:19'),
(700, 7, '743', 'images-1775318417764.jpg', 'uploads/images-1775318417764.jpg', 'image/jpeg', 14628, '2026-04-04 16:00:17'),
(701, 7, '744', 'images-1775318450017.png', 'uploads/images-1775318450017.png', 'image/png', 51008, '2026-04-04 16:00:50'),
(702, 7, '745', 'images-1775318473672.jpg', 'uploads/images-1775318473672.jpg', 'image/jpeg', 9158, '2026-04-04 16:01:13'),
(703, 7, '746', 'images-1775318530993.jpg', 'uploads/images-1775318530993.jpg', 'image/jpeg', 10018, '2026-04-04 16:02:11'),
(704, 7, '747', 'images-1775318575684.jpg', 'uploads/images-1775318575684.jpg', 'image/jpeg', 12794, '2026-04-04 16:02:55'),
(705, 7, '748', 'images-1775318621708.jpg', 'uploads/images-1775318621708.jpg', 'image/jpeg', 12796, '2026-04-04 16:03:41'),
(706, 7, '749', 'images-1775318747643.jpg', 'uploads/images-1775318747643.jpg', 'image/jpeg', 12796, '2026-04-04 16:05:47'),
(707, 7, '750', 'images-1775318783585.jpg', 'uploads/images-1775318783585.jpg', 'image/jpeg', 13442, '2026-04-04 16:06:23'),
(708, 7, '751', 'images-1775319065725.jpg', 'uploads/images-1775319065725.jpg', 'image/jpeg', 7977, '2026-04-04 16:11:05'),
(709, 7, '752', 'images-1775319141880.jpg', 'uploads/images-1775319141880.jpg', 'image/jpeg', 7475, '2026-04-04 16:12:21'),
(710, 7, '753', 'images-1775319208687.jpg', 'uploads/images-1775319208687.jpg', 'image/jpeg', 10339, '2026-04-04 16:13:28'),
(711, 7, '754', 'images-1775319262750.jpg', 'uploads/images-1775319262750.jpg', 'image/jpeg', 17919, '2026-04-04 16:14:22'),
(712, 7, '755', 'images-1775320066664.jpg', 'uploads/images-1775320066664.jpg', 'image/jpeg', 13009, '2026-04-04 16:27:46'),
(713, 7, '756', 'images-1775320115388.jpg', 'uploads/images-1775320115388.jpg', 'image/jpeg', 14675, '2026-04-04 16:28:35'),
(714, 7, '757', 'images-1775320164286.jpg', 'uploads/images-1775320164286.jpg', 'image/jpeg', 11599, '2026-04-04 16:29:24'),
(715, 7, '758', 'images-1775320192297.jpg', 'uploads/images-1775320192297.jpg', 'image/jpeg', 12152, '2026-04-04 16:29:52'),
(716, 7, '759', 'images-1775320253712.jpg', 'uploads/images-1775320253712.jpg', 'image/jpeg', 12156, '2026-04-04 16:30:53'),
(717, 7, '760', 'images-1775320689420.jpg', 'uploads/images-1775320689420.jpg', 'image/jpeg', 7345, '2026-04-04 16:38:09'),
(718, 7, '761', 'images-1775320776268.jpg', 'uploads/images-1775320776268.jpg', 'image/jpeg', 13271, '2026-04-04 16:39:36'),
(719, 7, '762', 'images-1775320825433.jpg', 'uploads/images-1775320825433.jpg', 'image/jpeg', 11779, '2026-04-04 16:40:25'),
(720, 7, '763', 'images-1775320899725.jpg', 'uploads/images-1775320899725.jpg', 'image/jpeg', 76195, '2026-04-04 16:41:39'),
(721, 7, '764', 'images-1775320969342.jpg', 'uploads/images-1775320969342.jpg', 'image/jpeg', 11864, '2026-04-04 16:42:49'),
(722, 7, '765', 'images-1775321144722.jpg', 'uploads/images-1775321144722.jpg', 'image/jpeg', 10590, '2026-04-04 16:45:44'),
(723, 7, '766', 'images-1775321215887.jpg', 'uploads/images-1775321215887.jpg', 'image/jpeg', 10119, '2026-04-04 16:46:55'),
(724, 7, '767', 'images-1775321344164.jpg', 'uploads/images-1775321344164.jpg', 'image/jpeg', 9897, '2026-04-04 16:49:04'),
(725, 7, '768', 'images-1775321419627.jpg', 'uploads/images-1775321419627.jpg', 'image/jpeg', 13899, '2026-04-04 16:50:19'),
(726, 7, '769', 'images-1775322859170.jpg', 'uploads/images-1775322859170.jpg', 'image/jpeg', 14832, '2026-04-04 17:14:19'),
(727, 7, '770', 'images-1775322909599.jpg', 'uploads/images-1775322909599.jpg', 'image/jpeg', 12917, '2026-04-04 17:15:09'),
(728, 7, '771', 'images-1775322943917.jpg', 'uploads/images-1775322943917.jpg', 'image/jpeg', 9052, '2026-04-04 17:15:43'),
(729, 7, '772', 'images-1775322982716.jpg', 'uploads/images-1775322982716.jpg', 'image/jpeg', 8741, '2026-04-04 17:16:22'),
(730, 7, '773', 'images-1775323058456.jpg', 'uploads/images-1775323058456.jpg', 'image/jpeg', 12141, '2026-04-04 17:17:38'),
(731, 7, '774', 'images-1775323085228.jpg', 'uploads/images-1775323085228.jpg', 'image/jpeg', 10012, '2026-04-04 17:18:05'),
(732, 7, '775', 'images-1775323143531.jpg', 'uploads/images-1775323143531.jpg', 'image/jpeg', 9692, '2026-04-04 17:19:03'),
(733, 7, '776', 'images-1775323198807.jpg', 'uploads/images-1775323198807.jpg', 'image/jpeg', 13246, '2026-04-04 17:19:58'),
(734, 7, '778', 'images-1775323240539.jpg', 'uploads/images-1775323240539.jpg', 'image/jpeg', 10527, '2026-04-04 17:20:40'),
(735, 7, '779', 'images-1775323272414.png', 'uploads/images-1775323272414.png', 'image/png', 72345, '2026-04-04 17:21:12'),
(736, 7, '780', 'images-1775323648004.jpg', 'uploads/images-1775323648004.jpg', 'image/jpeg', 14653, '2026-04-04 17:27:28'),
(737, 7, '781', 'images-1775323731825.jpg', 'uploads/images-1775323731825.jpg', 'image/jpeg', 15565, '2026-04-04 17:28:51'),
(738, 7, '782', 'images-1775323798140.jpg', 'uploads/images-1775323798140.jpg', 'image/jpeg', 9748, '2026-04-04 17:29:58'),
(739, 7, '783', 'images-1775323873389.jpg', 'uploads/images-1775323873389.jpg', 'image/jpeg', 6573, '2026-04-04 17:31:13'),
(740, 7, '784', 'images-1775323934529.jpg', 'uploads/images-1775323934529.jpg', 'image/jpeg', 10105, '2026-04-04 17:32:14'),
(741, 7, '785', 'images-1775323980050.jpg', 'uploads/images-1775323980050.jpg', 'image/jpeg', 9008, '2026-04-04 17:33:00'),
(742, 7, '786', 'images-1775324008785.jpg', 'uploads/images-1775324008785.jpg', 'image/jpeg', 14010, '2026-04-04 17:33:28'),
(743, 7, '787', 'images-1775324057837.jpg', 'uploads/images-1775324057837.jpg', 'image/jpeg', 9019, '2026-04-04 17:34:17'),
(744, 7, '788', 'images-1775324104666.jpg', 'uploads/images-1775324104666.jpg', 'image/jpeg', 11785, '2026-04-04 17:35:04'),
(745, 7, '789', 'images-1775324149455.jpg', 'uploads/images-1775324149455.jpg', 'image/jpeg', 8745, '2026-04-04 17:35:49'),
(746, 7, '790', 'images-1775324204171.jpg', 'uploads/images-1775324204171.jpg', 'image/jpeg', 14144, '2026-04-04 17:36:44'),
(747, 7, '791', 'images-1775324232423.jpg', 'uploads/images-1775324232423.jpg', 'image/jpeg', 9717, '2026-04-04 17:37:12'),
(748, 7, '792', 'images-1775324257598.jpg', 'uploads/images-1775324257598.jpg', 'image/jpeg', 12916, '2026-04-04 17:37:37'),
(749, 7, '793', 'images-1775325349239.jpg', 'uploads/images-1775325349239.jpg', 'image/jpeg', 14341, '2026-04-04 17:55:49'),
(750, 7, '794', 'images-1775325393040.jpg', 'uploads/images-1775325393040.jpg', 'image/jpeg', 9388, '2026-04-04 17:56:33'),
(751, 7, '795', 'images-1775325453632.jpg', 'uploads/images-1775325453632.jpg', 'image/jpeg', 12776, '2026-04-04 17:57:33'),
(752, 7, '796', 'images-1775325493012.jpg', 'uploads/images-1775325493012.jpg', 'image/jpeg', 11638, '2026-04-04 17:58:13'),
(753, 7, '797', 'images-1775325527177.jpg', 'uploads/images-1775325527177.jpg', 'image/jpeg', 16167, '2026-04-04 17:58:47'),
(754, 7, '798', 'images-1775325566743.jpg', 'uploads/images-1775325566743.jpg', 'image/jpeg', 10567, '2026-04-04 17:59:26'),
(755, 7, '799', 'images-1775325625926.jpg', 'uploads/images-1775325625926.jpg', 'image/jpeg', 10581, '2026-04-04 18:00:25'),
(756, 7, '800', 'images-1775325672488.jpg', 'uploads/images-1775325672488.jpg', 'image/jpeg', 10853, '2026-04-04 18:01:12'),
(757, 7, '801', 'images-1775325894552.jpg', 'uploads/images-1775325894552.jpg', 'image/jpeg', 12972, '2026-04-04 18:04:54'),
(758, 7, '802', 'images-1775325934828.jpg', 'uploads/images-1775325934828.jpg', 'image/jpeg', 12972, '2026-04-04 18:05:34'),
(759, 7, '803', 'images-1775325984094.jpg', 'uploads/images-1775325984094.jpg', 'image/jpeg', 14628, '2026-04-04 18:06:24'),
(760, 7, '804', 'images-1775326023470.jpg', 'uploads/images-1775326023470.jpg', 'image/jpeg', 14628, '2026-04-04 18:07:03'),
(761, 7, '805', 'images-1775326056384.jpg', 'uploads/images-1775326056384.jpg', 'image/jpeg', 11593, '2026-04-04 18:07:36'),
(762, 7, '806', 'images-1775326103491.jpg', 'uploads/images-1775326103491.jpg', 'image/jpeg', 11593, '2026-04-04 18:08:23'),
(763, 7, '807', 'images-1775326253072.png', 'uploads/images-1775326253072.png', 'image/png', 90484, '2026-04-04 18:10:53'),
(764, 7, '821', 'images-1775326445415.png', 'uploads/images-1775326445415.png', 'image/png', 90484, '2026-04-04 18:14:05'),
(765, 7, '822', 'images-1775326462810.png', 'uploads/images-1775326462810.png', 'image/png', 90484, '2026-04-04 18:14:22'),
(766, 7, '823', 'images-1775326523552.jpg', 'uploads/images-1775326523552.jpg', 'image/jpeg', 16361, '2026-04-04 18:15:23'),
(767, 7, '824', 'images-1775326544619.jpg', 'uploads/images-1775326544619.jpg', 'image/jpeg', 16361, '2026-04-04 18:15:44'),
(768, 7, '825', 'images-1775326584030.jpg', 'uploads/images-1775326584030.jpg', 'image/jpeg', 10843, '2026-04-04 18:16:24'),
(769, 7, '826', 'images-1775326598937.jpg', 'uploads/images-1775326598937.jpg', 'image/jpeg', 10843, '2026-04-04 18:16:38'),
(770, 7, '827', 'images-1775328408053.jpg', 'uploads/images-1775328408053.jpg', 'image/jpeg', 11553, '2026-04-04 18:46:48'),
(771, 7, '828', 'images-1775328420993.jpg', 'uploads/images-1775328420993.jpg', 'image/jpeg', 11553, '2026-04-04 18:47:01'),
(772, 7, '829', 'images-1775328433894.jpg', 'uploads/images-1775328433894.jpg', 'image/jpeg', 11553, '2026-04-04 18:47:13'),
(773, 7, '830', 'images-1775328493967.jpg', 'uploads/images-1775328493967.jpg', 'image/jpeg', 15593, '2026-04-04 18:48:13'),
(774, 7, '831', 'images-1775328514601.jpg', 'uploads/images-1775328514601.jpg', 'image/jpeg', 15593, '2026-04-04 18:48:34'),
(775, 7, '832', 'images-1775328528641.jpg', 'uploads/images-1775328528641.jpg', 'image/jpeg', 15593, '2026-04-04 18:48:48'),
(776, 7, '833', 'images-1775328584453.jpg', 'uploads/images-1775328584453.jpg', 'image/jpeg', 13526, '2026-04-04 18:49:44'),
(777, 7, '834', 'images-1775328727265.jpg', 'uploads/images-1775328727265.jpg', 'image/jpeg', 16204, '2026-04-04 18:52:07'),
(778, 7, '835', 'images-1775328767183.jpg', 'uploads/images-1775328767183.jpg', 'image/jpeg', 15616, '2026-04-04 18:52:47'),
(779, 7, '836', 'images-1775328849605.jpg', 'uploads/images-1775328849605.jpg', 'image/jpeg', 10542, '2026-04-04 18:54:09'),
(780, 7, '837', 'images-1775328887150.jpg', 'uploads/images-1775328887150.jpg', 'image/jpeg', 16128, '2026-04-04 18:54:47'),
(781, 7, '838', 'images-1775328927052.jpg', 'uploads/images-1775328927052.jpg', 'image/jpeg', 11738, '2026-04-04 18:55:27'),
(782, 7, '839', 'images-1775329312433.jpg', 'uploads/images-1775329312433.jpg', 'image/jpeg', 7309, '2026-04-04 19:01:52'),
(783, 7, '840', 'images-1775329335175.jpg', 'uploads/images-1775329335175.jpg', 'image/jpeg', 9381, '2026-04-04 19:02:15'),
(784, 7, '841', 'images-1775329357378.jpg', 'uploads/images-1775329357378.jpg', 'image/jpeg', 8600, '2026-04-04 19:02:37'),
(785, 7, '842', 'images-1775329387333.jpg', 'uploads/images-1775329387333.jpg', 'image/jpeg', 12692, '2026-04-04 19:03:07'),
(786, 7, '843', 'images-1775329415001.jpg', 'uploads/images-1775329415001.jpg', 'image/jpeg', 12378, '2026-04-04 19:03:35'),
(787, 7, '844', 'images-1775329477341.jpg', 'uploads/images-1775329477341.jpg', 'image/jpeg', 8422, '2026-04-04 19:04:37'),
(788, 7, '845', 'images-1775329520802.jpg', 'uploads/images-1775329520802.jpg', 'image/jpeg', 8968, '2026-04-04 19:05:20'),
(789, 7, '846', 'images-1775329542792.jpg', 'uploads/images-1775329542792.jpg', 'image/jpeg', 9563, '2026-04-04 19:05:42'),
(790, 7, '847', 'images-1775329577064.jpg', 'uploads/images-1775329577064.jpg', 'image/jpeg', 8780, '2026-04-04 19:06:17'),
(791, 7, '848', 'images-1775329633831.jpg', 'uploads/images-1775329633831.jpg', 'image/jpeg', 8532, '2026-04-04 19:07:13'),
(792, 7, '849', 'images-1775330095355.jpg', 'uploads/images-1775330095355.jpg', 'image/jpeg', 11956, '2026-04-04 19:14:55'),
(793, 7, '850', 'images-1775330117754.jpg', 'uploads/images-1775330117754.jpg', 'image/jpeg', 9899, '2026-04-04 19:15:17'),
(794, 7, '851', 'images-1775330181065.jpg', 'uploads/images-1775330181065.jpg', 'image/jpeg', 15394, '2026-04-04 19:16:21'),
(795, 7, '852', 'images-1775330206714.jpg', 'uploads/images-1775330206714.jpg', 'image/jpeg', 11472, '2026-04-04 19:16:46'),
(796, 7, '853', 'images-1775330223751.jpg', 'uploads/images-1775330223751.jpg', 'image/jpeg', 11944, '2026-04-04 19:17:03'),
(797, 7, '854', 'images-1775330243445.jpg', 'uploads/images-1775330243445.jpg', 'image/jpeg', 11508, '2026-04-04 19:17:23'),
(798, 7, '855', 'images-1775330273586.jpg', 'uploads/images-1775330273586.jpg', 'image/jpeg', 15181, '2026-04-04 19:17:53'),
(799, 7, '856', 'images-1775330289253.jpg', 'uploads/images-1775330289253.jpg', 'image/jpeg', 11021, '2026-04-04 19:18:09'),
(800, 7, '858', 'images-1775330453258.jpg', 'uploads/images-1775330453258.jpg', 'image/jpeg', 12091, '2026-04-04 19:20:53'),
(801, 7, '859', 'images-1775330507407.jpg', 'uploads/images-1775330507407.jpg', 'image/jpeg', 12569, '2026-04-04 19:21:47'),
(802, 7, '860', 'images-1775330547117.jpg', 'uploads/images-1775330547117.jpg', 'image/jpeg', 12891, '2026-04-04 19:22:27'),
(803, 7, '861', 'images-1775331048425.jpg', 'uploads/images-1775331048425.jpg', 'image/jpeg', 10780, '2026-04-04 19:30:48'),
(804, 7, '862', 'images-1775331088774.jpg', 'uploads/images-1775331088774.jpg', 'image/jpeg', 11183, '2026-04-04 19:31:28'),
(805, 7, '863', 'images-1775331108574.jpg', 'uploads/images-1775331108574.jpg', 'image/jpeg', 11183, '2026-04-04 19:31:48'),
(806, 7, '864', 'images-1775331153215.jpg', 'uploads/images-1775331153215.jpg', 'image/jpeg', 24700, '2026-04-04 19:32:33'),
(807, 7, '865', 'images-1775331178215.jpg', 'uploads/images-1775331178215.jpg', 'image/jpeg', 14124, '2026-04-04 19:32:58'),
(808, 7, '866', 'images-1775331210191.jpg', 'uploads/images-1775331210191.jpg', 'image/jpeg', 10237, '2026-04-04 19:33:30'),
(809, 7, '867', 'images-1775331241600.jpg', 'uploads/images-1775331241600.jpg', 'image/jpeg', 11612, '2026-04-04 19:34:01'),
(810, 7, '868', 'images-1775331268379.jpg', 'uploads/images-1775331268379.jpg', 'image/jpeg', 9725, '2026-04-04 19:34:28'),
(811, 7, '869', 'images-1775331313238.jpg', 'uploads/images-1775331313238.jpg', 'image/jpeg', 7161, '2026-04-04 19:35:13'),
(812, 7, '870', 'images-1775331344609.jpg', 'uploads/images-1775331344609.jpg', 'image/jpeg', 10651, '2026-04-04 19:35:44'),
(813, 7, '871', 'images-1775331582527.jpg', 'uploads/images-1775331582527.jpg', 'image/jpeg', 9123, '2026-04-04 19:39:42'),
(814, 7, '872', 'images-1775331608391.jpg', 'uploads/images-1775331608391.jpg', 'image/jpeg', 11675, '2026-04-04 19:40:08'),
(815, 7, '873', 'images-1775331632396.jpg', 'uploads/images-1775331632396.jpg', 'image/jpeg', 15030, '2026-04-04 19:40:32'),
(816, 7, '874', 'images-1775331662405.jpg', 'uploads/images-1775331662405.jpg', 'image/jpeg', 25697, '2026-04-04 19:41:02'),
(817, 7, '875', 'images-1775331686315.jpg', 'uploads/images-1775331686315.jpg', 'image/jpeg', 14479, '2026-04-04 19:41:26'),
(818, 7, '876', 'images-1775331705605.jpg', 'uploads/images-1775331705605.jpg', 'image/jpeg', 21115, '2026-04-04 19:41:45'),
(819, 7, '877', 'images-1775331733247.jpg', 'uploads/images-1775331733247.jpg', 'image/jpeg', 23078, '2026-04-04 19:42:13'),
(820, 7, '878', 'images-1775332173099.jpg', 'uploads/images-1775332173099.jpg', 'image/jpeg', 7612, '2026-04-04 19:49:33'),
(821, 7, '879', 'images-1775332203358.jpg', 'uploads/images-1775332203358.jpg', 'image/jpeg', 12804, '2026-04-04 19:50:03'),
(822, 7, '880', 'images-1775332253552.jpg', 'uploads/images-1775332253552.jpg', 'image/jpeg', 15928, '2026-04-04 19:50:53'),
(823, 7, '881', 'images-1775332269282.jpg', 'uploads/images-1775332269282.jpg', 'image/jpeg', 14397, '2026-04-04 19:51:09'),
(824, 7, '882', 'images-1775332296498.jpg', 'uploads/images-1775332296498.jpg', 'image/jpeg', 12477, '2026-04-04 19:51:36'),
(825, 7, '883', 'images-1775332310922.jpg', 'uploads/images-1775332310922.jpg', 'image/jpeg', 12346, '2026-04-04 19:51:50'),
(826, 7, '884', 'images-1775332342294.jpg', 'uploads/images-1775332342294.jpg', 'image/jpeg', 7847, '2026-04-04 19:52:22'),
(827, 7, '885', 'images-1775332396877.jpg', 'uploads/images-1775332396877.jpg', 'image/jpeg', 16361, '2026-04-04 19:53:16'),
(828, 7, '886', 'images-1775332473480.png', 'uploads/images-1775332473480.png', 'image/png', 82203, '2026-04-04 19:54:33'),
(829, 7, '887', 'images-1775332498945.png', 'uploads/images-1775332498945.png', 'image/png', 82203, '2026-04-04 19:54:58'),
(830, 7, '888', 'images-1775332560987.jpg', 'uploads/images-1775332560987.jpg', 'image/jpeg', 16053, '2026-04-04 19:56:01'),
(831, 7, '889', 'images-1775332581911.jpg', 'uploads/images-1775332581911.jpg', 'image/jpeg', 16053, '2026-04-04 19:56:21'),
(832, 7, '890', 'images-1775332608186.jpg', 'uploads/images-1775332608186.jpg', 'image/jpeg', 9866, '2026-04-04 19:56:48'),
(833, 7, '891', 'images-1775332630766.jpg', 'uploads/images-1775332630766.jpg', 'image/jpeg', 9866, '2026-04-04 19:57:10'),
(834, 7, '892', 'images-1775332656023.jpg', 'uploads/images-1775332656023.jpg', 'image/jpeg', 11096, '2026-04-04 19:57:36'),
(835, 7, '893', 'images-1775332679229.jpg', 'uploads/images-1775332679229.jpg', 'image/jpeg', 11096, '2026-04-04 19:57:59'),
(836, 7, '894', 'images-1775332999118.jpg', 'uploads/images-1775332999118.jpg', 'image/jpeg', 11264, '2026-04-04 20:03:19'),
(837, 7, '895', 'images-1775333018858.jpg', 'uploads/images-1775333018858.jpg', 'image/jpeg', 10773, '2026-04-04 20:03:38'),
(838, 7, '896', 'images-1775333053897.jpg', 'uploads/images-1775333053897.jpg', 'image/jpeg', 17941, '2026-04-04 20:04:13'),
(839, 7, '897', 'images-1775333085963.jpg', 'uploads/images-1775333085963.jpg', 'image/jpeg', 6868, '2026-04-04 20:04:45'),
(840, 7, '898', 'images-1775333112863.jpg', 'uploads/images-1775333112863.jpg', 'image/jpeg', 10745, '2026-04-04 20:05:12'),
(841, 7, '899', 'images-1775333132938.jpg', 'uploads/images-1775333132938.jpg', 'image/jpeg', 13515, '2026-04-04 20:05:32'),
(842, 7, '900', 'images-1775333157366.jpg', 'uploads/images-1775333157366.jpg', 'image/jpeg', 12143, '2026-04-04 20:05:57'),
(843, 7, '901', 'images-1775333174499.jpg', 'uploads/images-1775333174499.jpg', 'image/jpeg', 13503, '2026-04-04 20:06:14'),
(844, 7, '902', 'images-1775333204639.jpg', 'uploads/images-1775333204639.jpg', 'image/jpeg', 12539, '2026-04-04 20:06:44'),
(845, 7, '903', 'images-1775333223318.jpg', 'uploads/images-1775333223318.jpg', 'image/jpeg', 12539, '2026-04-04 20:07:03'),
(846, 7, '904', 'images-1775333248713.jpg', 'uploads/images-1775333248713.jpg', 'image/jpeg', 8496, '2026-04-04 20:07:28'),
(847, 7, '905', 'images-1775371264229.jpg', 'uploads/images-1775371264229.jpg', 'image/jpeg', 9297, '2026-04-05 06:41:04'),
(848, 7, '906', 'images-1775371285613.jpg', 'uploads/images-1775371285613.jpg', 'image/jpeg', 11845, '2026-04-05 06:41:25'),
(849, 7, '907', 'images-1775371311215.jpg', 'uploads/images-1775371311215.jpg', 'image/jpeg', 13701, '2026-04-05 06:41:51'),
(850, 7, '908', 'images-1775371337058.jpg', 'uploads/images-1775371337058.jpg', 'image/jpeg', 13762, '2026-04-05 06:42:17'),
(851, 7, '909', 'images-1775371363871.jpg', 'uploads/images-1775371363871.jpg', 'image/jpeg', 9957, '2026-04-05 06:42:43'),
(852, 7, '910', 'images-1775371375455.jpg', 'uploads/images-1775371375455.jpg', 'image/jpeg', 9957, '2026-04-05 06:42:55'),
(853, 7, '911', 'images-1775371401415.jpg', 'uploads/images-1775371401415.jpg', 'image/jpeg', 17881, '2026-04-05 06:43:21'),
(854, 7, '912', 'images-1775371417103.jpg', 'uploads/images-1775371417103.jpg', 'image/jpeg', 11225, '2026-04-05 06:43:37'),
(855, 7, '913', 'images-1775371431407.jpg', 'uploads/images-1775371431407.jpg', 'image/jpeg', 11373, '2026-04-05 06:43:51'),
(856, 7, '914', 'images-1775371449543.jpg', 'uploads/images-1775371449543.jpg', 'image/jpeg', 10650, '2026-04-05 06:44:09'),
(857, 7, '915', 'images-1775371471228.jpg', 'uploads/images-1775371471228.jpg', 'image/jpeg', 9680, '2026-04-05 06:44:31'),
(858, 5, '916', 'images-1775371986151.jpg', 'uploads/images-1775371986151.jpg', 'image/jpeg', 585482, '2026-04-05 06:53:06'),
(859, 5, '917', 'images-1775372002564.png', 'uploads/images-1775372002564.png', 'image/png', 492076, '2026-04-05 06:53:22'),
(860, 7, '918', 'images-1775372116685.jpg', 'uploads/images-1775372116685.jpg', 'image/jpeg', 13596, '2026-04-05 06:55:16'),
(861, 7, '919', 'images-1775372143912.jpg', 'uploads/images-1775372143912.jpg', 'image/jpeg', 13082, '2026-04-05 06:55:43');
INSERT INTO `item_images` (`id`, `shop_id`, `product_id`, `filename`, `path`, `mimetype`, `size`, `dateUploaded`) VALUES
(862, 7, '920', 'images-1775372195554.jpg', 'uploads/images-1775372195554.jpg', 'image/jpeg', 11659, '2026-04-05 06:56:35'),
(863, 7, '921', 'images-1775372227426.jpg', 'uploads/images-1775372227426.jpg', 'image/jpeg', 8686, '2026-04-05 06:57:07'),
(864, 7, '922', 'images-1775372263963.jpg', 'uploads/images-1775372263963.jpg', 'image/jpeg', 12342, '2026-04-05 06:57:43'),
(865, 7, '923', 'images-1775372286335.jpg', 'uploads/images-1775372286335.jpg', 'image/jpeg', 19710, '2026-04-05 06:58:06'),
(866, 7, '924', 'images-1775372306996.jpg', 'uploads/images-1775372306996.jpg', 'image/jpeg', 17881, '2026-04-05 06:58:27'),
(867, 7, '925', 'images-1775372327626.jpg', 'uploads/images-1775372327626.jpg', 'image/jpeg', 14704, '2026-04-05 06:58:47'),
(868, 7, '926', 'images-1775372341748.jpg', 'uploads/images-1775372341748.jpg', 'image/jpeg', 11566, '2026-04-05 06:59:01'),
(869, 7, '927', 'images-1775372820320.jpg', 'uploads/images-1775372820320.jpg', 'image/jpeg', 13009, '2026-04-05 07:07:00'),
(870, 7, '928', 'images-1775372835927.jpg', 'uploads/images-1775372835927.jpg', 'image/jpeg', 14581, '2026-04-05 07:07:15'),
(871, 7, '929', 'images-1775372849182.jpg', 'uploads/images-1775372849182.jpg', 'image/jpeg', 13518, '2026-04-05 07:07:29'),
(872, 7, '930', 'images-1775372861578.jpg', 'uploads/images-1775372861578.jpg', 'image/jpeg', 8364, '2026-04-05 07:07:41'),
(873, 7, '931', 'images-1775372874227.jpg', 'uploads/images-1775372874227.jpg', 'image/jpeg', 10291, '2026-04-05 07:07:54'),
(874, 7, '932', 'images-1775372907440.jpg', 'uploads/images-1775372907440.jpg', 'image/jpeg', 10291, '2026-04-05 07:08:27'),
(875, 7, '933', 'images-1775372925530.jpg', 'uploads/images-1775372925530.jpg', 'image/jpeg', 14852, '2026-04-05 07:08:45'),
(876, 7, '934', 'images-1775372973765.png', 'uploads/images-1775372973765.png', 'image/png', 83700, '2026-04-05 07:09:33'),
(877, 7, '935', 'images-1775373078063.jpg', 'uploads/images-1775373078063.jpg', 'image/jpeg', 13009, '2026-04-05 07:11:18'),
(878, 7, '936', 'images-1775373093732.jpg', 'uploads/images-1775373093732.jpg', 'image/jpeg', 13009, '2026-04-05 07:11:33'),
(879, 7, '937', 'images-1775373129248.jpg', 'uploads/images-1775373129248.jpg', 'image/jpeg', 14581, '2026-04-05 07:12:09'),
(880, 7, '938', 'images-1775373138875.jpg', 'uploads/images-1775373138875.jpg', 'image/jpeg', 14581, '2026-04-05 07:12:18'),
(881, 7, '939', 'images-1775373157129.jpg', 'uploads/images-1775373157129.jpg', 'image/jpeg', 13518, '2026-04-05 07:12:37'),
(882, 7, '940', 'images-1775373167498.jpg', 'uploads/images-1775373167498.jpg', 'image/jpeg', 13518, '2026-04-05 07:12:47'),
(883, 7, '941', 'images-1775373198384.jpg', 'uploads/images-1775373198384.jpg', 'image/jpeg', 8364, '2026-04-05 07:13:18'),
(884, 7, '942', 'images-1775373225487.jpg', 'uploads/images-1775373225487.jpg', 'image/jpeg', 8364, '2026-04-05 07:13:45'),
(885, 7, '943', 'images-1775373311374.jpg', 'uploads/images-1775373311374.jpg', 'image/jpeg', 13883, '2026-04-05 07:15:11'),
(886, 7, '944', 'images-1775373323926.jpg', 'uploads/images-1775373323926.jpg', 'image/jpeg', 13883, '2026-04-05 07:15:23'),
(887, 7, '945', 'images-1775373354084.jpg', 'uploads/images-1775373354084.jpg', 'image/jpeg', 10291, '2026-04-05 07:15:54'),
(888, 7, '946', 'images-1775373366297.jpg', 'uploads/images-1775373366297.jpg', 'image/jpeg', 10291, '2026-04-05 07:16:06'),
(889, 7, '947', 'images-1775373388174.jpg', 'uploads/images-1775373388174.jpg', 'image/jpeg', 14852, '2026-04-05 07:16:28'),
(890, 7, '948', 'images-1775373399657.jpg', 'uploads/images-1775373399657.jpg', 'image/jpeg', 14852, '2026-04-05 07:16:39'),
(891, 7, '949', 'images-1775373423666.png', 'uploads/images-1775373423666.png', 'image/png', 83700, '2026-04-05 07:17:03'),
(892, 7, '950', 'images-1775373443997.png', 'uploads/images-1775373443997.png', 'image/png', 83700, '2026-04-05 07:17:24'),
(893, 8, '951', 'images-1775374799433.JPG', 'uploads/images-1775374799433.JPG', 'image/jpeg', 102235, '2026-04-05 07:39:59'),
(894, 8, '952', 'images-1775395077771.jpg', 'uploads/images-1775395077771.jpg', 'image/jpeg', 13007, '2026-04-05 13:17:57'),
(895, 8, '953', 'images-1775395109132.jpg', 'uploads/images-1775395109132.jpg', 'image/jpeg', 14828, '2026-04-05 13:18:29'),
(896, 8, '954', 'images-1775395165637.png', 'uploads/images-1775395165637.png', 'image/png', 65253, '2026-04-05 13:19:25'),
(897, 8, '955', 'images-1775395215220.jpg', 'uploads/images-1775395215220.jpg', 'image/jpeg', 17966, '2026-04-05 13:20:15'),
(898, 8, '956', 'images-1775395246908.jpg', 'uploads/images-1775395246908.jpg', 'image/jpeg', 12266, '2026-04-05 13:20:46'),
(899, 8, '957', 'images-1775395270793.jpg', 'uploads/images-1775395270793.jpg', 'image/jpeg', 10779, '2026-04-05 13:21:10'),
(900, 8, '958', 'images-1775395294615.jpg', 'uploads/images-1775395294615.jpg', 'image/jpeg', 16003, '2026-04-05 13:21:34'),
(901, 8, '959', 'images-1775395317543.jpg', 'uploads/images-1775395317543.jpg', 'image/jpeg', 20510, '2026-04-05 13:21:57'),
(902, 8, '960', 'images-1775395340155.jpg', 'uploads/images-1775395340155.jpg', 'image/jpeg', 10054, '2026-04-05 13:22:20'),
(903, 8, '961', 'images-1775395363935.jpg', 'uploads/images-1775395363935.jpg', 'image/jpeg', 13428, '2026-04-05 13:22:43'),
(904, 8, '962', 'images-1775395386434.jpg', 'uploads/images-1775395386434.jpg', 'image/jpeg', 13341, '2026-04-05 13:23:06'),
(905, 8, '963', 'images-1775395418090.jpg', 'uploads/images-1775395418090.jpg', 'image/jpeg', 8619, '2026-04-05 13:23:38'),
(906, 8, '964', 'images-1775395433005.jpg', 'uploads/images-1775395433005.jpg', 'image/jpeg', 12606, '2026-04-05 13:23:53'),
(907, 8, '965', 'images-1775395452298.jpg', 'uploads/images-1775395452298.jpg', 'image/jpeg', 10010, '2026-04-05 13:24:12'),
(908, 8, '966', 'images-1775395469574.jpg', 'uploads/images-1775395469574.jpg', 'image/jpeg', 10966, '2026-04-05 13:24:29'),
(909, 8, '967', 'images-1775395997365.jpg', 'uploads/images-1775395997365.jpg', 'image/jpeg', 11067, '2026-04-05 13:33:17'),
(910, 8, '968', 'images-1775396021447.jpg', 'uploads/images-1775396021447.jpg', 'image/jpeg', 10112, '2026-04-05 13:33:41'),
(911, 8, '969', 'images-1775396041582.jpg', 'uploads/images-1775396041582.jpg', 'image/jpeg', 11649, '2026-04-05 13:34:01'),
(912, 8, '970', 'images-1775396157376.jpg', 'uploads/images-1775396157376.jpg', 'image/jpeg', 10887, '2026-04-05 13:35:57'),
(913, 8, '971', 'images-1775396175359.jpg', 'uploads/images-1775396175359.jpg', 'image/jpeg', 13001, '2026-04-05 13:36:15'),
(914, 8, '972', 'images-1775396193417.jpg', 'uploads/images-1775396193417.jpg', 'image/jpeg', 13470, '2026-04-05 13:36:33'),
(915, 8, '973', 'images-1775396211048.jpg', 'uploads/images-1775396211048.jpg', 'image/jpeg', 10648, '2026-04-05 13:36:51'),
(916, 8, '974', 'images-1775396262206.jpg', 'uploads/images-1775396262206.jpg', 'image/jpeg', 8312, '2026-04-05 13:37:42'),
(917, 8, '975', 'images-1775396279941.jpg', 'uploads/images-1775396279941.jpg', 'image/jpeg', 13705, '2026-04-05 13:37:59'),
(918, 8, '976', 'images-1775396293830.jpg', 'uploads/images-1775396293830.jpg', 'image/jpeg', 15104, '2026-04-05 13:38:13'),
(919, 8, '978', 'images-1775396320726.jpg', 'uploads/images-1775396320726.jpg', 'image/jpeg', 15346, '2026-04-05 13:38:40'),
(920, 8, '979', 'images-1775396340622.jpg', 'uploads/images-1775396340622.jpg', 'image/jpeg', 20452, '2026-04-05 13:39:00'),
(921, 8, '980', 'images-1775397035812.jpg', 'uploads/images-1775397035812.jpg', 'image/jpeg', 12592, '2026-04-05 13:50:35'),
(922, 8, '981', 'images-1775397057451.jpg', 'uploads/images-1775397057451.jpg', 'image/jpeg', 14519, '2026-04-05 13:50:57'),
(923, 8, '982', 'images-1775397081748.jpg', 'uploads/images-1775397081748.jpg', 'image/jpeg', 13734, '2026-04-05 13:51:21'),
(924, 8, '984', 'images-1775397116561.jpg', 'uploads/images-1775397116561.jpg', 'image/jpeg', 13847, '2026-04-05 13:51:56'),
(925, 8, '985', 'images-1775397145241.jpg', 'uploads/images-1775397145241.jpg', 'image/jpeg', 15494, '2026-04-05 13:52:25'),
(926, 8, '986', 'images-1775397169990.jpg', 'uploads/images-1775397169990.jpg', 'image/jpeg', 9683, '2026-04-05 13:52:50'),
(927, 8, '987', 'images-1775397214301.jpg', 'uploads/images-1775397214301.jpg', 'image/jpeg', 11334, '2026-04-05 13:53:34'),
(928, 8, '988', 'images-1775397243773.jpg', 'uploads/images-1775397243773.jpg', 'image/jpeg', 12810, '2026-04-05 13:54:03'),
(929, 8, '989', 'images-1775397256171.jpg', 'uploads/images-1775397256171.jpg', 'image/jpeg', 12810, '2026-04-05 13:54:16'),
(930, 8, '990', 'images-1775397272370.jpg', 'uploads/images-1775397272370.jpg', 'image/jpeg', 8241, '2026-04-05 13:54:32'),
(931, 8, '991', 'images-1775397310867.jpg', 'uploads/images-1775397310867.jpg', 'image/jpeg', 9019, '2026-04-05 13:55:10'),
(932, 8, '992', 'images-1775397540182.jpg', 'uploads/images-1775397540182.jpg', 'image/jpeg', 13246, '2026-04-05 13:59:00'),
(933, 8, '993', 'images-1775397555703.jpg', 'uploads/images-1775397555703.jpg', 'image/jpeg', 10527, '2026-04-05 13:59:15'),
(934, 8, '994', 'images-1775397617907.png', 'uploads/images-1775397617907.png', 'image/png', 72345, '2026-04-05 14:00:17'),
(935, 8, '995', 'images-1775397661595.jpg', 'uploads/images-1775397661595.jpg', 'image/jpeg', 14212, '2026-04-05 14:01:01'),
(936, 8, '996', 'images-1775397703243.png', 'uploads/images-1775397703243.png', 'image/png', 82203, '2026-04-05 14:01:43'),
(937, 8, '997', 'images-1775397761686.jpg', 'uploads/images-1775397761686.jpg', 'image/jpeg', 13543, '2026-04-05 14:02:41'),
(938, 8, '998', 'images-1775397797265.png', 'uploads/images-1775397797265.png', 'image/png', 69041, '2026-04-05 14:03:17'),
(939, 8, '999', 'images-1775397881019.jpg', 'uploads/images-1775397881019.jpg', 'image/jpeg', 15494, '2026-04-05 14:04:41'),
(940, 8, '1000', 'images-1775397908294.jpg', 'uploads/images-1775397908294.jpg', 'image/jpeg', 14292, '2026-04-05 14:05:08'),
(941, 8, '1001', 'images-1775398096486.jpg', 'uploads/images-1775398096486.jpg', 'image/jpeg', 8364, '2026-04-05 14:08:16'),
(942, 8, '1002', 'images-1775398206792.jpg', 'uploads/images-1775398206792.jpg', 'image/jpeg', 7691, '2026-04-05 14:10:06'),
(943, 8, '1003', 'images-1775398306695.png', 'uploads/images-1775398306695.png', 'image/png', 70384, '2026-04-05 14:11:46'),
(944, 8, '1004', 'images-1775398333617.png', 'uploads/images-1775398333617.png', 'image/png', 57507, '2026-04-05 14:12:13'),
(945, 8, '1005', 'images-1775398488412.jpg', 'uploads/images-1775398488412.jpg', 'image/jpeg', 12152, '2026-04-05 14:14:48'),
(946, 8, '1006', 'images-1775398523932.jpg', 'uploads/images-1775398523932.jpg', 'image/jpeg', 10944, '2026-04-05 14:15:23'),
(947, 8, '1007', 'images-1775398562008.jpg', 'uploads/images-1775398562008.jpg', 'image/jpeg', 12877, '2026-04-05 14:16:02'),
(948, 8, '1008', 'images-1775398637075.jpg', 'uploads/images-1775398637075.jpg', 'image/jpeg', 15441, '2026-04-05 14:17:17'),
(949, 8, '1009', 'images-1775398669936.jpg', 'uploads/images-1775398669936.jpg', 'image/jpeg', 11570, '2026-04-05 14:17:49'),
(950, 8, '1010', 'images-1775398745027.jpg', 'uploads/images-1775398745027.jpg', 'image/jpeg', 12972, '2026-04-05 14:19:05'),
(951, 8, '1011', 'images-1775399104639.jpg', 'uploads/images-1775399104639.jpg', 'image/jpeg', 10434, '2026-04-05 14:25:04'),
(952, 8, '1012', 'images-1775399125023.jpg', 'uploads/images-1775399125023.jpg', 'image/jpeg', 13103, '2026-04-05 14:25:25'),
(953, 8, '1013', 'images-1775399186305.png', 'uploads/images-1775399186305.png', 'image/png', 83700, '2026-04-05 14:26:26'),
(954, 8, '1014', 'images-1775399216354.jpg', 'uploads/images-1775399216354.jpg', 'image/jpeg', 12346, '2026-04-05 14:26:56'),
(955, 8, '1015', 'images-1775399706183.jpg', 'uploads/images-1775399706183.jpg', 'image/jpeg', 12804, '2026-04-05 14:35:06'),
(956, 8, '1016', 'images-1775399886887.jpg', 'uploads/images-1775399886887.jpg', 'image/jpeg', 15016, '2026-04-05 14:38:06'),
(957, 8, '1017', 'images-1775399912967.jpg', 'uploads/images-1775399912967.jpg', 'image/jpeg', 7747, '2026-04-05 14:38:32'),
(958, 8, '1018', 'images-1775399957864.jpg', 'uploads/images-1775399957864.jpg', 'image/jpeg', 11738, '2026-04-05 14:39:17'),
(959, 8, '1019', 'images-1775399985829.jpg', 'uploads/images-1775399985829.jpg', 'image/jpeg', 23078, '2026-04-05 14:39:45'),
(960, 8, '1020', 'images-1775400016478.jpg', 'uploads/images-1775400016478.jpg', 'image/jpeg', 16128, '2026-04-05 14:40:16'),
(961, 8, '1021', 'images-1775400046136.jpg', 'uploads/images-1775400046136.jpg', 'image/jpeg', 12222, '2026-04-05 14:40:46'),
(962, 8, '1022', 'images-1775400086318.jpg', 'uploads/images-1775400086318.jpg', 'image/jpeg', 13526, '2026-04-05 14:41:26'),
(969, 8, '1029', 'images-1775400692844.jpg', 'uploads/images-1775400692844.jpg', 'image/jpeg', 7906, '2026-04-05 14:51:32'),
(968, 8, '1028', 'images-1775400668413.jpg', 'uploads/images-1775400668413.jpg', 'image/jpeg', 13277, '2026-04-05 14:51:08'),
(967, 8, '1027', 'images-1775400645463.jpg', 'uploads/images-1775400645463.jpg', 'image/jpeg', 9685, '2026-04-05 14:50:45'),
(966, 8, '1026', 'images-1775400546560.jpg', 'uploads/images-1775400546560.jpg', 'image/jpeg', 7442, '2026-04-05 14:49:06'),
(970, 8, '1030', 'images-1775400724937.jpg', 'uploads/images-1775400724937.jpg', 'image/jpeg', 9016, '2026-04-05 14:52:04'),
(971, 8, '1031', 'images-1775400756345.jpg', 'uploads/images-1775400756345.jpg', 'image/jpeg', 10858, '2026-04-05 14:52:36'),
(972, 8, '1032', 'images-1775400792252.jpg', 'uploads/images-1775400792252.jpg', 'image/jpeg', 13677, '2026-04-05 14:53:12'),
(973, 8, '1033', 'images-1775400821966.jpg', 'uploads/images-1775400821966.jpg', 'image/jpeg', 12896, '2026-04-05 14:53:41'),
(974, 8, '1034', 'images-1775400863661.jpg', 'uploads/images-1775400863661.jpg', 'image/jpeg', 12575, '2026-04-05 14:54:23'),
(975, 8, '1035', 'images-1775400891932.jpg', 'uploads/images-1775400891932.jpg', 'image/jpeg', 11388, '2026-04-05 14:54:51'),
(976, 8, '1036', 'images-1775400915947.jpg', 'uploads/images-1775400915947.jpg', 'image/jpeg', 9895, '2026-04-05 14:55:15'),
(977, 8, '1037', 'images-1775400943022.jpg', 'uploads/images-1775400943022.jpg', 'image/jpeg', 10018, '2026-04-05 14:55:43'),
(978, 8, '1038', 'images-1775400974204.jpg', 'uploads/images-1775400974204.jpg', 'image/jpeg', 10196, '2026-04-05 14:56:14'),
(979, 8, '1039', 'images-1775401001426.jpg', 'uploads/images-1775401001426.jpg', 'image/jpeg', 7194, '2026-04-05 14:56:41'),
(980, 8, '1040', 'images-1775401039975.jpg', 'uploads/images-1775401039975.jpg', 'image/jpeg', 10746, '2026-04-05 14:57:19'),
(981, 8, '1041', 'images-1775401240357.jpg', 'uploads/images-1775401240357.jpg', 'image/jpeg', 4174, '2026-04-05 15:00:40'),
(982, 8, '1042', 'images-1775401303246.jpg', 'uploads/images-1775401303246.jpg', 'image/jpeg', 7010, '2026-04-05 15:01:43'),
(984, 8, '1044', 'images-1775401375886.jpg', 'uploads/images-1775401375886.jpg', 'image/jpeg', 6047, '2026-04-05 15:02:55'),
(985, 8, '1045', 'images-1775401404682.jpg', 'uploads/images-1775401404682.jpg', 'image/jpeg', 8674, '2026-04-05 15:03:24'),
(986, 8, '1046', 'images-1775401613646.jpg', 'uploads/images-1775401613646.jpg', 'image/jpeg', 5320, '2026-04-05 15:06:53'),
(987, 8, '1047', 'images-1775401631730.jpg', 'uploads/images-1775401631730.jpg', 'image/jpeg', 6678, '2026-04-05 15:07:11'),
(988, 8, '1048', 'images-1775401645427.jpg', 'uploads/images-1775401645427.jpg', 'image/jpeg', 11433, '2026-04-05 15:07:25'),
(989, 8, '1049', 'images-1775401663490.jpg', 'uploads/images-1775401663490.jpg', 'image/jpeg', 5755, '2026-04-05 15:07:43'),
(991, 8, '1051', 'images-1775401789759.jpg', 'uploads/images-1775401789759.jpg', 'image/jpeg', 10563, '2026-04-05 15:09:49'),
(992, 8, '1052', 'images-1775401829166.jpg', 'uploads/images-1775401829166.jpg', 'image/jpeg', 10147, '2026-04-05 15:10:29'),
(993, 8, '1054', 'images-1775401910746.jpg', 'uploads/images-1775401910746.jpg', 'image/jpeg', 5112, '2026-04-05 15:11:50'),
(994, 8, '1055', 'images-1775401945459.jpg', 'uploads/images-1775401945459.jpg', 'image/jpeg', 10465, '2026-04-05 15:12:25'),
(995, 8, '1056', 'images-1775402041985.jpg', 'uploads/images-1775402041985.jpg', 'image/jpeg', 13841, '2026-04-05 15:14:01'),
(996, 8, '1057', 'images-1775402077727.jpg', 'uploads/images-1775402077727.jpg', 'image/jpeg', 8917, '2026-04-05 15:14:37'),
(997, 8, '1058', 'images-1775402886233.jpg', 'uploads/images-1775402886233.jpg', 'image/jpeg', 5807, '2026-04-05 15:28:06'),
(998, 8, '1059', 'images-1775402922726.png', 'uploads/images-1775402922726.png', 'image/png', 1067642, '2026-04-05 15:28:42'),
(999, 8, '1060', 'images-1775402958944.jpg', 'uploads/images-1775402958944.jpg', 'image/jpeg', 8844, '2026-04-05 15:29:18'),
(1000, 8, '1061', 'images-1775403001135.jpg', 'uploads/images-1775403001135.jpg', 'image/jpeg', 11184, '2026-04-05 15:30:01'),
(1001, 8, '1062', 'images-1775403037245.jpg', 'uploads/images-1775403037245.jpg', 'image/jpeg', 10591, '2026-04-05 15:30:37'),
(1002, 8, '1063', 'images-1775403052683.jpg', 'uploads/images-1775403052683.jpg', 'image/jpeg', 6342, '2026-04-05 15:30:52'),
(1003, 8, '1064', 'images-1775403075319.jpg', 'uploads/images-1775403075319.jpg', 'image/jpeg', 8791, '2026-04-05 15:31:15'),
(1004, 8, '1065', 'images-1775403294860.jpg', 'uploads/images-1775403294860.jpg', 'image/jpeg', 9359, '2026-04-05 15:34:54'),
(1005, 8, '1066', 'images-1775403331795.jpg', 'uploads/images-1775403331795.jpg', 'image/jpeg', 10244, '2026-04-05 15:35:31'),
(1006, 8, '1067', 'images-1775403344301.jpg', 'uploads/images-1775403344301.jpg', 'image/jpeg', 8447, '2026-04-05 15:35:44'),
(1007, 8, '1068', 'images-1775403400636.jpg', 'uploads/images-1775403400636.jpg', 'image/jpeg', 7483, '2026-04-05 15:36:40'),
(1008, 8, '1069', 'images-1775403462824.png', 'uploads/images-1775403462824.png', 'image/png', 1239516, '2026-04-05 15:37:42'),
(1009, 8, '1070', 'images-1775403572931.jpg', 'uploads/images-1775403572931.jpg', 'image/jpeg', 5702, '2026-04-05 15:39:32'),
(1010, 8, '1071', 'images-1775403624011.jpg', 'uploads/images-1775403624011.jpg', 'image/jpeg', 8943, '2026-04-05 15:40:24'),
(1011, 8, '1072', 'images-1775403649528.jpg', 'uploads/images-1775403649528.jpg', 'image/jpeg', 7554, '2026-04-05 15:40:49'),
(1012, 8, '1073', 'images-1775403664629.jpg', 'uploads/images-1775403664629.jpg', 'image/jpeg', 10944, '2026-04-05 15:41:04'),
(1013, 8, '1074', 'images-1775403677173.jpg', 'uploads/images-1775403677173.jpg', 'image/jpeg', 6118, '2026-04-05 15:41:17'),
(1014, 8, '1075', 'images-1775403700634.jpg', 'uploads/images-1775403700634.jpg', 'image/jpeg', 8551, '2026-04-05 15:41:40'),
(1015, 8, '1076', 'images-1775403832678.jpg', 'uploads/images-1775403832678.jpg', 'image/jpeg', 8369, '2026-04-05 15:43:52'),
(1016, 8, '1077', 'images-1775403854254.jpg', 'uploads/images-1775403854254.jpg', 'image/jpeg', 8369, '2026-04-05 15:44:14'),
(1017, 8, '1078', 'images-1775403884884.jpg', 'uploads/images-1775403884884.jpg', 'image/jpeg', 4978, '2026-04-05 15:44:44'),
(1018, 8, '1079', 'images-1775403905533.jpg', 'uploads/images-1775403905533.jpg', 'image/jpeg', 9769, '2026-04-05 15:45:05'),
(1019, 8, '1080', 'images-1775404053914.jpg', 'uploads/images-1775404053914.jpg', 'image/jpeg', 3977, '2026-04-05 15:47:33'),
(1020, 8, '1081', 'images-1775404076553.jpg', 'uploads/images-1775404076553.jpg', 'image/jpeg', 4311, '2026-04-05 15:47:56'),
(1021, 8, '1082', 'images-1775404104273.jpg', 'uploads/images-1775404104273.jpg', 'image/jpeg', 5367, '2026-04-05 15:48:24'),
(1022, 8, '1083', 'images-1775404131029.jpg', 'uploads/images-1775404131029.jpg', 'image/jpeg', 5367, '2026-04-05 15:48:51'),
(1023, 8, '1084', 'images-1775404247189.jpg', 'uploads/images-1775404247189.jpg', 'image/jpeg', 4538, '2026-04-05 15:50:47'),
(1024, 8, '1085', 'images-1775404270366.jpg', 'uploads/images-1775404270366.jpg', 'image/jpeg', 8698, '2026-04-05 15:51:10'),
(1025, 8, '1086', 'images-1775404316140.jpg', 'uploads/images-1775404316140.jpg', 'image/jpeg', 6073, '2026-04-05 15:51:56'),
(1026, 8, '1087', 'images-1775404362959.jpg', 'uploads/images-1775404362959.jpg', 'image/jpeg', 12097, '2026-04-05 15:52:42'),
(1027, 8, '1088', 'images-1775404437092.jpg', 'uploads/images-1775404437092.jpg', 'image/jpeg', 11388, '2026-04-05 15:53:57'),
(1028, 8, '1089', 'images-1775404451382.jpg', 'uploads/images-1775404451382.jpg', 'image/jpeg', 3645, '2026-04-05 15:54:11'),
(1029, 8, '1090', 'images-1775404496331.jpg', 'uploads/images-1775404496331.jpg', 'image/jpeg', 3000, '2026-04-05 15:54:56'),
(1030, 8, '1091', 'images-1775404530938.jpg', 'uploads/images-1775404530938.jpg', 'image/jpeg', 6940, '2026-04-05 15:55:30'),
(1031, 8, '1092', 'images-1775404577796.jpg', 'uploads/images-1775404577796.jpg', 'image/jpeg', 3436, '2026-04-05 15:56:17'),
(1032, 8, '1093', 'images-1775404618335.jpg', 'uploads/images-1775404618335.jpg', 'image/jpeg', 3149, '2026-04-05 15:56:58'),
(1033, 8, '1094', 'images-1775404651254.jpg', 'uploads/images-1775404651254.jpg', 'image/jpeg', 3722, '2026-04-05 15:57:31'),
(1034, 8, '1095', 'images-1775404709634.jpg', 'uploads/images-1775404709634.jpg', 'image/jpeg', 9455, '2026-04-05 15:58:29'),
(1035, 8, '1096', 'images-1775404725489.jpg', 'uploads/images-1775404725489.jpg', 'image/jpeg', 9455, '2026-04-05 15:58:45'),
(1036, 8, '1097', 'images-1775404769539.jpg', 'uploads/images-1775404769539.jpg', 'image/jpeg', 4473, '2026-04-05 15:59:29'),
(1037, 8, '1098', 'images-1775404953419.jpg', 'uploads/images-1775404953419.jpg', 'image/jpeg', 4064, '2026-04-05 16:02:33'),
(1038, 8, '1099', 'images-1775404968701.jpg', 'uploads/images-1775404968701.jpg', 'image/jpeg', 5011, '2026-04-05 16:02:48'),
(1039, 8, '1100', 'images-1775405018947.jpg', 'uploads/images-1775405018947.jpg', 'image/jpeg', 2962, '2026-04-05 16:03:38'),
(1040, 8, '1101', 'images-1775405049335.jpg', 'uploads/images-1775405049335.jpg', 'image/jpeg', 5241, '2026-04-05 16:04:09'),
(1041, 8, '1102', 'images-1775405102459.jpg', 'uploads/images-1775405102459.jpg', 'image/jpeg', 4141, '2026-04-05 16:05:02'),
(1042, 8, '1103', 'images-1775405130782.jpg', 'uploads/images-1775405130782.jpg', 'image/jpeg', 5593, '2026-04-05 16:05:30'),
(1043, 8, '1104', 'images-1775405171903.jpg', 'uploads/images-1775405171903.jpg', 'image/jpeg', 3998, '2026-04-05 16:06:11'),
(1044, 8, '1105', 'images-1775405218439.jpg', 'uploads/images-1775405218439.jpg', 'image/jpeg', 4473, '2026-04-05 16:06:58'),
(1047, 8, '1108', 'images-1775405358933.jpg', 'uploads/images-1775405358933.jpg', 'image/jpeg', 4064, '2026-04-05 16:09:18'),
(1046, 8, '1107', 'images-1775405326506.jpg', 'uploads/images-1775405326506.jpg', 'image/jpeg', 5011, '2026-04-05 16:08:46'),
(1048, 8, '1109', 'images-1775405395044.jpg', 'uploads/images-1775405395044.jpg', 'image/jpeg', 2962, '2026-04-05 16:09:55'),
(1049, 8, '1110', 'images-1775405452381.jpg', 'uploads/images-1775405452381.jpg', 'image/jpeg', 5241, '2026-04-05 16:10:52'),
(1052, 8, '1113', 'images-1775405572837.jpg', 'uploads/images-1775405572837.jpg', 'image/jpeg', 4141, '2026-04-05 16:12:52'),
(1051, 8, '1112', 'images-1775405535292.jpg', 'uploads/images-1775405535292.jpg', 'image/jpeg', 5593, '2026-04-05 16:12:15'),
(1053, 8, '1114', 'images-1775405603901.jpg', 'uploads/images-1775405603901.jpg', 'image/jpeg', 3998, '2026-04-05 16:13:23'),
(1054, 7, '1115', 'images-1775463874698.jpg', 'uploads/images-1775463874698.jpg', 'image/jpeg', 10396, '2026-04-06 08:24:34'),
(1055, 7, '1116', 'images-1775463894507.jpg', 'uploads/images-1775463894507.jpg', 'image/jpeg', 12674, '2026-04-06 08:24:54'),
(1056, 7, '1117', 'images-1775463910167.jpg', 'uploads/images-1775463910167.jpg', 'image/jpeg', 11409, '2026-04-06 08:25:10'),
(1057, 7, '1118', 'images-1775463938071.jpg', 'uploads/images-1775463938071.jpg', 'image/jpeg', 12399, '2026-04-06 08:25:38'),
(1058, 7, '1119', 'images-1775463958988.jpg', 'uploads/images-1775463958988.jpg', 'image/jpeg', 8241, '2026-04-06 08:25:58'),
(1059, 7, '1120', 'images-1775463974207.jpg', 'uploads/images-1775463974207.jpg', 'image/jpeg', 17966, '2026-04-06 08:26:14'),
(1060, 7, '1121', 'images-1775463993110.jpg', 'uploads/images-1775463993110.jpg', 'image/jpeg', 9578, '2026-04-06 08:26:33'),
(1061, 7, '1122', 'images-1775464013455.jpg', 'uploads/images-1775464013455.jpg', 'image/jpeg', 15006, '2026-04-06 08:26:53'),
(1062, 9, '1123', 'images-1776150537545.jpg', 'uploads/images-1776150537545.jpg', 'image/jpeg', 10561, '2026-04-14 07:08:57'),
(1063, 9, '1124', 'images-1776150556499.jpg', 'uploads/images-1776150556499.jpg', 'image/jpeg', 105349, '2026-04-14 07:09:16'),
(1064, 9, '1125', 'images-1776150583116.jpg', 'uploads/images-1776150583116.jpg', 'image/jpeg', 5464, '2026-04-14 07:09:43'),
(1065, 9, '1126', 'images-1776150615041.png', 'uploads/images-1776150615041.png', 'image/png', 64029, '2026-04-14 07:10:15'),
(1066, 9, '1127', 'images-1776150638539.png', 'uploads/images-1776150638539.png', 'image/png', 1239516, '2026-04-14 07:10:38'),
(1067, 9, '1128', 'images-1776150676832.jpg', 'uploads/images-1776150676832.jpg', 'image/jpeg', 14144, '2026-04-14 07:11:16'),
(1068, 9, '1129', 'images-1776150700911.jpg', 'uploads/images-1776150700911.jpg', 'image/jpeg', 12257, '2026-04-14 07:11:40'),
(1069, 9, '1130', 'images-1776150745512.jpg', 'uploads/images-1776150745512.jpg', 'image/jpeg', 12387, '2026-04-14 07:12:25'),
(1070, 9, '1131', 'images-1776150771901.jpg', 'uploads/images-1776150771901.jpg', 'image/jpeg', 8902, '2026-04-14 07:12:51'),
(1071, 9, '1132', 'images-1776150862948.jpg', 'uploads/images-1776150862948.jpg', 'image/jpeg', 12652, '2026-04-14 07:14:22'),
(1072, 9, '1133', 'images-1776150916782.jpg', 'uploads/images-1776150916782.jpg', 'image/jpeg', 12832, '2026-04-14 07:15:16'),
(1073, 9, '1134', 'images-1776150988469.jpg', 'uploads/images-1776150988469.jpg', 'image/jpeg', 16278, '2026-04-14 07:16:28'),
(1074, 9, '1135', 'images-1776151727712.jpg', 'uploads/images-1776151727712.jpg', 'image/jpeg', 239532, '2026-04-14 07:28:47'),
(1075, 9, '1136', 'images-1776151788851.jpg', 'uploads/images-1776151788851.jpg', 'image/jpeg', 60276, '2026-04-14 07:29:48'),
(1076, 9, '1137', 'images-1776151831056.jpg', 'uploads/images-1776151831056.jpg', 'image/jpeg', 12278, '2026-04-14 07:30:31'),
(1077, 9, '1138', 'images-1776152085046.jpg', 'uploads/images-1776152085046.jpg', 'image/jpeg', 12834, '2026-04-14 07:34:45'),
(1078, 9, '1139', 'images-1776152191384.png', 'uploads/images-1776152191384.png', 'image/png', 85728, '2026-04-14 07:36:31'),
(1079, 9, '1140', 'images-1776152308602.jpg', 'uploads/images-1776152308602.jpg', 'image/jpeg', 54485, '2026-04-14 07:38:28'),
(1080, 9, '1141', 'images-1776152345143.jpg', 'uploads/images-1776152345143.jpg', 'image/jpeg', 11040, '2026-04-14 07:39:05'),
(1081, 9, '1142', 'images-1776152405299.jpg', 'uploads/images-1776152405299.jpg', 'image/jpeg', 10608, '2026-04-14 07:40:05'),
(1082, 9, '1143', 'images-1776152436511.jpg', 'uploads/images-1776152436511.jpg', 'image/jpeg', 8837, '2026-04-14 07:40:36'),
(1083, 9, '1144', 'images-1776152472616.jpg', 'uploads/images-1776152472616.jpg', 'image/jpeg', 7753, '2026-04-14 07:41:12'),
(1084, 9, '1145', 'images-1776152501820.jpg', 'uploads/images-1776152501820.jpg', 'image/jpeg', 11740, '2026-04-14 07:41:41'),
(1085, 9, '1146', 'images-1776152537971.jpg', 'uploads/images-1776152537971.jpg', 'image/jpeg', 5367, '2026-04-14 07:42:18'),
(1086, 9, '1147', 'images-1776152565986.jpg', 'uploads/images-1776152565986.jpg', 'image/jpeg', 5367, '2026-04-14 07:42:46'),
(1087, 9, '1148', 'images-1776152593707.jpg', 'uploads/images-1776152593707.jpg', 'image/jpeg', 11854, '2026-04-14 07:43:13'),
(1088, 9, '1149', 'images-1776152620732.jpg', 'uploads/images-1776152620732.jpg', 'image/jpeg', 3977, '2026-04-14 07:43:40'),
(1089, 9, '1150', 'images-1776152640031.jpg', 'uploads/images-1776152640031.jpg', 'image/jpeg', 4311, '2026-04-14 07:44:00'),
(1090, 9, '1152', 'images-1776152676606.jpg', 'uploads/images-1776152676606.jpg', 'image/jpeg', 8369, '2026-04-14 07:44:36'),
(1091, 9, '1153', 'images-1776152694987.jpg', 'uploads/images-1776152694987.jpg', 'image/jpeg', 8369, '2026-04-14 07:44:54'),
(1092, 9, '1154', 'images-1776152725240.jpg', 'uploads/images-1776152725240.jpg', 'image/jpeg', 4978, '2026-04-14 07:45:25'),
(1093, 9, '1155', 'images-1776152747368.jpg', 'uploads/images-1776152747368.jpg', 'image/jpeg', 9769, '2026-04-14 07:45:47'),
(1094, 9, '1156', 'images-1776152766232.jpg', 'uploads/images-1776152766232.jpg', 'image/jpeg', 3304, '2026-04-14 07:46:06'),
(1095, 9, '1157', 'images-1776152817557.jpg', 'uploads/images-1776152817557.jpg', 'image/jpeg', 5593, '2026-04-14 07:46:57'),
(1096, 9, '1158', 'images-1776152838340.jpg', 'uploads/images-1776152838340.jpg', 'image/jpeg', 5593, '2026-04-14 07:47:18'),
(1097, 9, '1159', 'images-1776152865622.jpg', 'uploads/images-1776152865622.jpg', 'image/jpeg', 5593, '2026-04-14 07:47:45'),
(1099, 9, '1161', 'images-1776152951702.jpg', 'uploads/images-1776152951702.jpg', 'image/jpeg', 4168, '2026-04-14 07:49:11'),
(1100, 9, '1162', 'images-1776153001332.jpg', 'uploads/images-1776153001332.jpg', 'image/jpeg', 4168, '2026-04-14 07:50:01'),
(1112, 9, '1174', 'images-1776153452854.jpg', 'uploads/images-1776153452854.jpg', 'image/jpeg', 4168, '2026-04-14 07:57:32'),
(1102, 9, '1164', 'images-1776153052605.jpg', 'uploads/images-1776153052605.jpg', 'image/jpeg', 3350, '2026-04-14 07:50:52'),
(1103, 9, '1165', 'images-1776153145696.jpg', 'uploads/images-1776153145696.jpg', 'image/jpeg', 3350, '2026-04-14 07:52:25'),
(1105, 9, '1167', 'images-1776153174643.jpg', 'uploads/images-1776153174643.jpg', 'image/jpeg', 3350, '2026-04-14 07:52:54'),
(1106, 9, '1168', 'images-1776153233039.jpg', 'uploads/images-1776153233039.jpg', 'image/jpeg', 5437, '2026-04-14 07:53:53'),
(1107, 9, '1169', 'images-1776153255945.jpg', 'uploads/images-1776153255945.jpg', 'image/jpeg', 5437, '2026-04-14 07:54:15'),
(1108, 9, '1170', 'images-1776153292860.jpg', 'uploads/images-1776153292860.jpg', 'image/jpeg', 5437, '2026-04-14 07:54:52'),
(1109, 9, '1171', 'images-1776153331735.jpg', 'uploads/images-1776153331735.jpg', 'image/jpeg', 3230, '2026-04-14 07:55:31'),
(1110, 9, '1172', 'images-1776153354685.jpg', 'uploads/images-1776153354685.jpg', 'image/jpeg', 3230, '2026-04-14 07:55:54'),
(1111, 9, '1173', 'images-1776153406347.jpg', 'uploads/images-1776153406347.jpg', 'image/jpeg', 3230, '2026-04-14 07:56:46'),
(1113, 9, '1175', 'images-1776153483765.jpg', 'uploads/images-1776153483765.jpg', 'image/jpeg', 3574, '2026-04-14 07:58:03'),
(1114, 9, '1176', 'images-1776153534453.jpg', 'uploads/images-1776153534453.jpg', 'image/jpeg', 3574, '2026-04-14 07:58:54'),
(1116, 9, '1178', 'images-1776153627923.jpg', 'uploads/images-1776153627923.jpg', 'image/jpeg', 3574, '2026-04-14 08:00:27'),
(1117, 9, '1179', 'images-1776153682446.jpg', 'uploads/images-1776153682446.jpg', 'image/jpeg', 4427, '2026-04-14 08:01:22'),
(1118, 9, '1180', 'images-1776153702704.jpg', 'uploads/images-1776153702704.jpg', 'image/jpeg', 4427, '2026-04-14 08:01:42'),
(1119, 9, '1181', 'images-1776153724727.jpg', 'uploads/images-1776153724727.jpg', 'image/jpeg', 4427, '2026-04-14 08:02:04'),
(1120, 9, '1182', 'images-1776153756046.jpg', 'uploads/images-1776153756046.jpg', 'image/jpeg', 4647, '2026-04-14 08:02:36'),
(1122, 9, '1184', 'images-1776153803710.jpg', 'uploads/images-1776153803710.jpg', 'image/jpeg', 4647, '2026-04-14 08:03:23'),
(1123, 9, '1185', 'images-1776153835618.jpg', 'uploads/images-1776153835618.jpg', 'image/jpeg', 4647, '2026-04-14 08:03:55'),
(1124, 9, '1186', 'images-1776153903511.jpg', 'uploads/images-1776153903511.jpg', 'image/jpeg', 4912, '2026-04-14 08:05:03'),
(1125, 9, '1187', 'images-1776153940213.jpg', 'uploads/images-1776153940213.jpg', 'image/jpeg', 4912, '2026-04-14 08:05:40'),
(1126, 9, '1188', 'images-1776153965129.jpg', 'uploads/images-1776153965129.jpg', 'image/jpeg', 4912, '2026-04-14 08:06:05'),
(1127, 9, '1189', 'images-1776153994643.jpg', 'uploads/images-1776153994643.jpg', 'image/jpeg', 4473, '2026-04-14 08:06:34'),
(1128, 9, '1190', 'images-1776154009336.jpg', 'uploads/images-1776154009336.jpg', 'image/jpeg', 4473, '2026-04-14 08:06:49'),
(1129, 9, '1191', 'images-1776154028506.jpg', 'uploads/images-1776154028506.jpg', 'image/jpeg', 4473, '2026-04-14 08:07:08'),
(1130, 9, '1192', 'images-1776154056231.jpg', 'uploads/images-1776154056231.jpg', 'image/jpeg', 3573, '2026-04-14 08:07:36'),
(1131, 9, '1193', 'images-1776154071948.jpg', 'uploads/images-1776154071948.jpg', 'image/jpeg', 3573, '2026-04-14 08:07:51'),
(1132, 9, '1194', 'images-1776154091087.jpg', 'uploads/images-1776154091087.jpg', 'image/jpeg', 3573, '2026-04-14 08:08:11'),
(1133, 9, '1195', 'images-1776408109712.png', 'uploads/images-1776408109712.png', 'image/png', 8036, '2026-04-17 06:41:49'),
(1134, 9, '1196', 'images-1776408128591.jpg', 'uploads/images-1776408128591.jpg', 'image/jpeg', 5746, '2026-04-17 06:42:08'),
(1135, 9, '1197', 'images-1776408149147.jpg', 'uploads/images-1776408149147.jpg', 'image/jpeg', 6541, '2026-04-17 06:42:29'),
(1136, 9, '1198', 'images-1776408169112.jpg', 'uploads/images-1776408169112.jpg', 'image/jpeg', 6368, '2026-04-17 06:42:49'),
(1137, 9, '1199', 'images-1776408476064.png', 'uploads/images-1776408476064.png', 'image/png', 18789, '2026-04-17 06:47:56'),
(1138, 9, '1200', 'images-1776408504227.png', 'uploads/images-1776408504227.png', 'image/png', 18789, '2026-04-17 06:48:24'),
(1139, 9, '1201', 'images-1776408535974.png', 'uploads/images-1776408535974.png', 'image/png', 18789, '2026-04-17 06:48:55'),
(1140, 9, '1202', 'images-1776408578058.png', 'uploads/images-1776408578058.png', 'image/png', 18789, '2026-04-17 06:49:38'),
(1141, 9, '1203', 'images-1776408627726.png', 'uploads/images-1776408627726.png', 'image/png', 18789, '2026-04-17 06:50:27'),
(1142, 9, '1204', 'images-1776408644920.png', 'uploads/images-1776408644920.png', 'image/png', 18789, '2026-04-17 06:50:44'),
(1143, 9, '1205', 'images-1776408699096.png', 'uploads/images-1776408699096.png', 'image/png', 28898, '2026-04-17 06:51:39'),
(1144, 9, '1206', 'images-1776408711087.png', 'uploads/images-1776408711087.png', 'image/png', 28898, '2026-04-17 06:51:51'),
(1145, 9, '1207', 'images-1776408723462.png', 'uploads/images-1776408723462.png', 'image/png', 28898, '2026-04-17 06:52:03'),
(1146, 9, '1208', 'images-1776408736681.png', 'uploads/images-1776408736681.png', 'image/png', 28898, '2026-04-17 06:52:16'),
(1147, 9, '1209', 'images-1776408747010.png', 'uploads/images-1776408747010.png', 'image/png', 28898, '2026-04-17 06:52:27'),
(1148, 9, '1210', 'images-1776408756848.png', 'uploads/images-1776408756848.png', 'image/png', 28898, '2026-04-17 06:52:36'),
(1149, 9, '1211', 'images-1776408771802.png', 'uploads/images-1776408771802.png', 'image/png', 28898, '2026-04-17 06:52:51'),
(1150, 9, '1212', 'images-1776408782046.png', 'uploads/images-1776408782046.png', 'image/png', 28898, '2026-04-17 06:53:02'),
(1151, 9, '1213', 'images-1776408792275.png', 'uploads/images-1776408792275.png', 'image/png', 28898, '2026-04-17 06:53:12'),
(1152, 9, '1214', 'images-1776408855154.png', 'uploads/images-1776408855154.png', 'image/png', 22037, '2026-04-17 06:54:15'),
(1153, 9, '1215', 'images-1776408870389.png', 'uploads/images-1776408870389.png', 'image/png', 22037, '2026-04-17 06:54:30'),
(1166, 5, '1228', 'images-1778486474479.webp', 'uploads\\images-1778486474479.webp', 'image/webp', 14578, '2026-05-11 15:01:14'),
(1167, 5, '1229', 'images-1778486543437.webp', 'uploads\\images-1778486543437.webp', 'image/webp', 48096, '2026-05-11 15:02:23'),
(1168, 5, '1230', 'images-1778489651022.jpg', 'uploads\\images-1778489651022.jpg', 'image/jpeg', 27303, '2026-05-11 15:54:11'),
(1169, 5, '1231', 'images-1778498338896.webp', 'uploads\\images-1778498338896.webp', 'image/webp', 18516, '2026-05-11 18:18:58'),
(1170, 5, '1232', 'images-1778500312206.jpg', 'uploads\\images-1778500312206.jpg', 'image/jpeg', 13247, '2026-05-11 18:51:52');

-- --------------------------------------------------------

--
-- Table structure for table `kiosk_queue`
--

DROP TABLE IF EXISTS `kiosk_queue`;
CREATE TABLE IF NOT EXISTS `kiosk_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_id` int DEFAULT NULL,
  `queue_number` int NOT NULL,
  `queue_date` date NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'waiting',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_queue_per_day` (`queue_date`,`queue_number`),
  KEY `idx_bill_id` (`bill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_entries`
--

DROP TABLE IF EXISTS `ledger_entries`;
CREATE TABLE IF NOT EXISTS `ledger_entries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `transaction_id` varchar(50) NOT NULL,
  `date` datetime DEFAULT CURRENT_TIMESTAMP,
  `account_type` varchar(233) NOT NULL,
  `account_id` int NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `debit_amount` decimal(15,2) DEFAULT '0.00',
  `credit_amount` decimal(15,2) DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `reference_id` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transaction` (`transaction_id`),
  KEY `idx_account` (`account_id`,`account_type`(1)),
  KEY `idx_ledger_entries_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=171 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ledger_entries`
--

INSERT INTO `ledger_entries` (`id`, `shop_id`, `transaction_id`, `date`, `account_type`, `account_id`, `description`, `debit_amount`, `credit_amount`, `discount_amount`, `reference_id`, `created_at`, `updated_at`) VALUES
(7, 5, '450', '2026-03-31 16:17:58', 'Sales', 1, 'Bill #DM029 - Sale Revenue', 0.00, 295.00, 0.00, 0, '2026-03-31 16:17:58', '2026-03-31 16:17:58'),
(8, 5, '450', '2026-03-31 16:17:58', 'Account Recievable', 22, 'Bill #DM029 - Credit Sale', 295.00, 0.00, 0.00, 0, '2026-03-31 16:17:58', '2026-03-31 16:17:58'),
(9, 5, '', '2026-03-31 17:03:38', 'Cash', 0, 'Customer Payment Received', 200.00, 0.00, 0.00, 446, '2026-03-31 17:03:38', '2026-03-31 17:03:38'),
(10, 5, '', '2026-03-31 17:03:38', 'Account Recievable', 22, 'Credit Paid', 0.00, 200.00, 0.00, 446, '2026-03-31 17:03:38', '2026-03-31 17:03:38'),
(11, 5, '451', '2026-03-31 17:04:24', 'Sales', 1, 'Bill #DM030 - Sale Revenue', 0.00, 1610.00, 0.00, 0, '2026-03-31 17:04:24', '2026-03-31 17:04:24'),
(12, 5, '451', '2026-03-31 17:04:24', 'Account Recievable', 23, 'Bill #DM030 - Credit Sale', 1610.00, 0.00, 0.00, 0, '2026-03-31 17:04:24', '2026-03-31 17:04:24'),
(13, 5, '', '2026-03-31 17:04:57', 'Bank', 0, 'Customer Payment Received', 1000.00, 0.00, 0.00, 451, '2026-03-31 17:04:57', '2026-03-31 17:04:57'),
(14, 5, '', '2026-03-31 17:04:57', 'Account Recievable', 23, 'Credit Paid', 0.00, 1000.00, 0.00, 451, '2026-03-31 17:04:57', '2026-03-31 17:04:57'),
(15, 5, '', '2026-04-01 00:00:00', 'Purchase', 18, 'fdsfds', 52000.00, 0.00, 0.00, 0, '2026-03-31 17:40:16', '2026-03-31 17:40:16'),
(16, 5, '', '2026-04-01 00:00:00', 'Purchase', 18, 'dasdadasd', 15260.00, 0.00, 0.00, 0, '2026-03-31 17:40:29', '2026-03-31 17:40:29'),
(17, 5, '', '2026-04-01 00:00:00', 'Purchase', 18, '', 0.00, 5000.00, 0.00, 0, '2026-03-31 17:43:23', '2026-03-31 17:43:23'),
(18, 7, '452', '2026-04-03 10:15:50', 'Sales', 1, 'Bill #JSL001 - Sale Revenue', 0.00, 180.00, 0.00, 0, '2026-04-03 10:15:50', '2026-04-03 10:15:50'),
(19, 7, '453', '2026-04-03 10:29:33', 'Sales', 1, 'Bill #JSL002 - Sale Revenue', 0.00, 300.00, 0.00, 0, '2026-04-03 10:29:33', '2026-04-03 10:29:33'),
(20, 5, '454', '2026-04-04 04:24:44', 'Sales', 1, 'Bill #DM031 - Sale Revenue', 0.00, 1215.00, 0.00, 0, '2026-04-04 04:24:44', '2026-04-04 04:24:44'),
(21, 5, '454', '2026-04-04 04:24:44', 'Account Recievable', 22, 'Bill #DM031 - Credit Sale', 1215.00, 0.00, 0.00, 0, '2026-04-04 04:24:44', '2026-04-04 04:24:44'),
(22, 5, '', '2026-04-04 04:29:22', 'Cash', 0, 'Customer Payment Received', 295.00, 0.00, 0.00, 448, '2026-04-04 04:29:22', '2026-04-04 04:29:22'),
(23, 5, '', '2026-04-04 04:29:22', 'Account Recievable', 22, 'Credit Paid', 0.00, 295.00, 0.00, 448, '2026-04-04 04:29:22', '2026-04-04 04:29:22'),
(24, 5, '', '2026-04-04 04:29:22', 'Cash', 0, 'Customer Payment Received', 205.00, 0.00, 0.00, 449, '2026-04-04 04:29:22', '2026-04-04 04:29:22'),
(25, 5, '', '2026-04-04 04:29:22', 'Account Recievable', 22, 'Credit Paid', 0.00, 205.00, 0.00, 449, '2026-04-04 04:29:22', '2026-04-04 04:29:22'),
(26, 5, '455', '2026-04-05 04:44:25', 'Sales', 1, 'Bill #DM032 - Sale Revenue', 0.00, 735.00, 0.00, 0, '2026-04-05 04:44:25', '2026-04-05 04:44:25'),
(27, 5, '455', '2026-04-05 04:44:25', 'Cash', 0, 'Bill #DM032 - Cash Payment', 735.00, 0.00, 0.00, 0, '2026-04-05 04:44:25', '2026-04-05 04:44:25'),
(28, 5, '456', '2026-04-05 04:45:28', 'Sales', 1, 'Bill #DM033 - Sale Revenue', 0.00, 760.00, 0.00, 0, '2026-04-05 04:45:28', '2026-04-05 04:45:28'),
(29, 5, '456', '2026-04-05 04:45:28', 'QR Code', 0, 'Bill #DM033 - QR Payment', 760.00, 0.00, 0.00, 0, '2026-04-05 04:45:28', '2026-04-05 04:45:28'),
(30, 5, '457', '2026-04-05 04:47:10', 'Sales', 1, 'Bill #DM034 - Sale Revenue', 0.00, 1130.00, 0.00, 0, '2026-04-05 04:47:10', '2026-04-05 04:47:10'),
(31, 5, '457', '2026-04-05 04:47:10', 'QR Code', 0, 'Bill #DM034 - QR Payment', 1130.00, 0.00, 0.00, 0, '2026-04-05 04:47:10', '2026-04-05 04:47:10'),
(32, 5, '458', '2026-04-05 04:47:19', 'Sales', 1, 'Bill #DM035 - Sale Revenue', 0.00, 295.00, 0.00, 0, '2026-04-05 04:47:19', '2026-04-05 04:47:19'),
(33, 5, '458', '2026-04-05 04:47:19', 'Cash', 0, 'Bill #DM035 - Cash Payment', 295.00, 0.00, 0.00, 0, '2026-04-05 04:47:19', '2026-04-05 04:47:19'),
(34, 8, '459', '2026-04-05 07:45:23', 'Sales', 1, 'Bill #SNR001 - Sale Revenue', 0.00, 300.00, 0.00, 0, '2026-04-05 07:45:23', '2026-04-05 07:45:23'),
(35, 8, '459', '2026-04-05 07:45:23', 'Cash', 0, 'Bill #SNR001 - Cash Payment', 300.00, 0.00, 0.00, 0, '2026-04-05 07:45:23', '2026-04-05 07:45:23'),
(36, 8, '460', '2026-04-05 07:47:53', 'Sales', 1, 'Bill #SNR002 - Sale Revenue', 0.00, 900.00, 0.00, 0, '2026-04-05 07:47:53', '2026-04-05 07:47:53'),
(37, 5, '461', '2026-04-06 10:50:50', 'Sales', 1, 'Bill #DM036 - Sale Revenue', 0.00, 1515.00, 0.00, 0, '2026-04-06 10:50:50', '2026-04-06 10:50:50'),
(38, 5, '461', '2026-04-06 10:50:50', 'Cash', 0, 'Bill #DM036 - Cash Payment', 1515.00, 0.00, 0.00, 0, '2026-04-06 10:50:50', '2026-04-06 10:50:50'),
(39, 8, '462', '2026-04-08 13:26:54', 'Sales', 1, 'Bill #SNR003 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(40, 8, '462', '2026-04-08 13:26:54', 'Cash', 0, 'Bill #SNR003 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(41, 8, '463', '2026-04-08 13:26:55', 'Sales', 1, 'Bill #SNR004 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(42, 8, '463', '2026-04-08 13:26:55', 'Cash', 0, 'Bill #SNR004 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(43, 8, '464', '2026-04-08 13:26:55', 'Sales', 1, 'Bill #SNR005 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(44, 8, '464', '2026-04-08 13:26:55', 'Cash', 0, 'Bill #SNR005 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(45, 8, '465', '2026-04-08 13:26:55', 'Sales', 1, 'Bill #SNR006 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(46, 8, '465', '2026-04-08 13:26:55', 'Cash', 0, 'Bill #SNR006 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(47, 8, '466', '2026-04-08 13:26:55', 'Sales', 1, 'Bill #SNR007 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(48, 8, '466', '2026-04-08 13:26:55', 'Cash', 0, 'Bill #SNR007 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(49, 8, '467', '2026-04-08 13:26:55', 'Sales', 1, 'Bill #SNR008 - Sale Revenue', 0.00, 115.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(50, 8, '467', '2026-04-08 13:26:55', 'Cash', 0, 'Bill #SNR008 - Cash Payment', 115.00, 0.00, 0.00, 0, '2026-04-08 13:26:55', '2026-04-08 13:26:55'),
(51, 5, '468', '2026-04-12 04:48:14', 'Sales', 1, 'Bill #DM037 - Sale Revenue', 0.00, 3735.00, 0.00, 0, '2026-04-12 04:48:14', '2026-04-12 04:48:14'),
(52, 5, '468', '2026-04-12 04:48:14', 'Cash', 0, 'Bill #DM037 - Cash Payment', 3735.00, 0.00, 0.00, 0, '2026-04-12 04:48:14', '2026-04-12 04:48:14'),
(53, 5, '469', '2026-04-12 04:48:29', 'Sales', 1, 'Bill #DM038 - Sale Revenue', 0.00, 945.00, 0.00, 0, '2026-04-12 04:48:29', '2026-04-12 04:48:29'),
(54, 5, '469', '2026-04-12 04:48:29', 'Cash', 0, 'Bill #DM038 - Cash Payment', 945.00, 0.00, 0.00, 0, '2026-04-12 04:48:29', '2026-04-12 04:48:29'),
(55, 8, '470', '2026-04-12 05:01:08', 'Sales', 1, 'Bill #SNR009 - Sale Revenue', 0.00, 1485.00, 0.00, 0, '2026-04-12 05:01:08', '2026-04-12 05:01:08'),
(56, 8, '471', '2026-04-12 05:22:09', 'Sales', 1, 'Bill #SNR010 - Sale Revenue', 0.00, 239.00, 0.00, 0, '2026-04-12 05:22:09', '2026-04-12 05:22:09'),
(57, 8, '471', '2026-04-12 05:22:09', 'Cash', 0, 'Bill #SNR010 - Cash Payment', 239.00, 0.00, 0.00, 0, '2026-04-12 05:22:09', '2026-04-12 05:22:09'),
(58, 8, '472', '2026-04-12 05:26:43', 'Sales', 1, 'Bill #SNR011 - Sale Revenue', 0.00, 550.00, 0.00, 0, '2026-04-12 05:26:43', '2026-04-12 05:26:43'),
(59, 5, '473', '2026-04-13 07:22:16', 'Sales', 1, 'Bill #DM039 - Sale Revenue', 0.00, 3455.00, 0.00, 0, '2026-04-13 07:22:16', '2026-04-13 07:22:16'),
(60, 5, '473', '2026-04-13 07:22:16', 'Cash', 0, 'Bill #DM039 - Cash Payment', 3455.00, 0.00, 0.00, 0, '2026-04-13 07:22:16', '2026-04-13 07:22:16'),
(61, 9, '474', '2026-04-18 06:58:00', 'Sales', 1, 'Bill #WS001 - Sale Revenue', 0.00, 2400.00, 0.00, 0, '2026-04-18 06:58:00', '2026-04-18 06:58:00'),
(62, 9, '474', '2026-04-18 06:58:00', 'Cash', 0, 'Bill #WS001 - Cash Payment', 2400.00, 0.00, 0.00, 0, '2026-04-18 06:58:00', '2026-04-18 06:58:00'),
(63, 9, '475', '2026-04-18 06:58:56', 'Sales', 1, 'Bill #WS002 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-04-18 06:58:56', '2026-04-18 06:58:56'),
(64, 9, '475', '2026-04-18 06:58:56', 'Cash', 0, 'Bill #WS002 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-04-18 06:58:56', '2026-04-18 06:58:56'),
(65, 9, '476', '2026-04-18 07:03:44', 'Sales', 1, 'Bill #WS003 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-04-18 07:03:44', '2026-04-18 07:03:44'),
(66, 9, '476', '2026-04-18 07:03:44', 'Cash', 0, 'Bill #WS003 - Cash Payment', 950.00, 0.00, 0.00, 0, '2026-04-18 07:03:44', '2026-04-18 07:03:44'),
(67, 9, '477', '2026-04-18 07:03:47', 'Sales', 1, 'Bill #WS004 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-04-18 07:03:47', '2026-04-18 07:03:47'),
(68, 9, '477', '2026-04-18 07:03:47', 'Cash', 0, 'Bill #WS004 - Cash Payment', 950.00, 0.00, 0.00, 0, '2026-04-18 07:03:47', '2026-04-18 07:03:47'),
(69, 9, '478', '2026-04-18 07:03:50', 'Sales', 1, 'Bill #WS005 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-04-18 07:03:50', '2026-04-18 07:03:50'),
(70, 9, '478', '2026-04-18 07:03:50', 'Cash', 0, 'Bill #WS005 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-04-18 07:03:50', '2026-04-18 07:03:50'),
(71, 9, '479', '2026-04-18 07:04:33', 'Sales', 1, 'Bill #WS006 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-04-18 07:04:33', '2026-04-18 07:04:33'),
(72, 9, '479', '2026-04-18 07:04:33', 'Cash', 0, 'Bill #WS006 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-04-18 07:04:33', '2026-04-18 07:04:33'),
(73, 9, '480', '2026-04-18 07:36:47', 'Sales', 1, 'Bill #WS007 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-04-18 07:36:47', '2026-04-18 07:36:47'),
(74, 9, '480', '2026-04-18 07:36:47', 'Cash', 0, 'Bill #WS007 - Cash Payment', 950.00, 0.00, 0.00, 0, '2026-04-18 07:36:47', '2026-04-18 07:36:47'),
(75, 9, '481', '2026-04-19 06:39:17', 'Sales', 1, 'Bill #WS008 - Sale Revenue', 0.00, 1175.00, 0.00, 0, '2026-04-19 06:39:17', '2026-04-19 06:39:17'),
(76, 9, '481', '2026-04-19 06:39:17', 'Cash', 0, 'Bill #WS008 - Cash Payment', 1175.00, 0.00, 0.00, 0, '2026-04-19 06:39:17', '2026-04-19 06:39:17'),
(77, 7, '482', '2026-04-23 12:16:19', 'Sales', 1, 'Bill #JSL003 - Sale Revenue', 0.00, 1200.00, 0.00, 0, '2026-04-23 12:16:19', '2026-04-23 12:16:19'),
(78, 9, '483', '2026-04-26 09:39:51', 'Sales', 1, 'Bill #WS009 - Sale Revenue', 0.00, 880.00, 0.00, 0, '2026-04-26 09:39:51', '2026-04-26 09:39:51'),
(79, 9, '483', '2026-04-26 09:39:51', 'Cash', 0, 'Bill #WS009 - Cash Payment', 880.00, 0.00, 0.00, 0, '2026-04-26 09:39:51', '2026-04-26 09:39:51'),
(80, 9, '484', '2026-04-27 11:58:23', 'Sales', 1, 'Bill #WS010 - Sale Revenue', 0.00, 851.00, 0.00, 0, '2026-04-27 11:58:23', '2026-04-27 11:58:23'),
(81, 9, '484', '2026-04-27 11:58:23', 'Cash', 0, 'Bill #WS010 - Cash Payment', 851.00, 0.00, 0.00, 0, '2026-04-27 11:58:23', '2026-04-27 11:58:23'),
(82, 9, '485', '2026-04-27 12:17:31', 'Sales', 1, 'Bill #WS011 - Sale Revenue', 0.00, 750.00, 0.00, 0, '2026-04-27 12:17:31', '2026-04-27 12:17:31'),
(83, 9, '485', '2026-04-27 12:17:31', 'Cash', 0, 'Bill #WS011 - Cash Payment', 750.00, 0.00, 0.00, 0, '2026-04-27 12:17:31', '2026-04-27 12:17:31'),
(84, 7, '486', '2026-04-28 07:26:58', 'Sales', 1, 'Bill #JSL004 - Sale Revenue', 0.00, 570.00, 0.00, 0, '2026-04-28 07:26:58', '2026-04-28 07:26:58'),
(85, 9, '487', '2026-05-02 11:49:42', 'Sales', 1, 'Bill #WS012 - Sale Revenue', 0.00, 15.00, 0.00, 0, '2026-05-02 11:49:42', '2026-05-02 11:49:42'),
(86, 9, '487', '2026-05-02 11:49:42', 'Cash', 0, 'Bill #WS012 - Cash Payment', 15.00, 0.00, 0.00, 0, '2026-05-02 11:49:42', '2026-05-02 11:49:42'),
(87, 9, '488', '2026-05-02 11:49:48', 'Sales', 1, 'Bill #WS013 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-02 11:49:48', '2026-05-02 11:49:48'),
(88, 9, '488', '2026-05-02 11:49:48', 'Cash', 0, 'Bill #WS013 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-05-02 11:49:48', '2026-05-02 11:49:48'),
(89, 9, '489', '2026-05-02 11:49:57', 'Sales', 1, 'Bill #WS014 - Sale Revenue', 0.00, 30.00, 0.00, 0, '2026-05-02 11:49:57', '2026-05-02 11:49:57'),
(90, 9, '489', '2026-05-02 11:49:57', 'Cash', 0, 'Bill #WS014 - Cash Payment', 30.00, 0.00, 0.00, 0, '2026-05-02 11:49:57', '2026-05-02 11:49:57'),
(91, 9, '490', '2026-05-02 12:07:49', 'Sales', 1, 'Bill #WS015 - Sale Revenue', 0.00, 600.00, 0.00, 0, '2026-05-02 12:07:49', '2026-05-02 12:07:49'),
(92, 9, '490', '2026-05-02 12:07:49', 'Cash', 0, 'Bill #WS015 - Cash Payment', 600.00, 0.00, 0.00, 0, '2026-05-02 12:07:49', '2026-05-02 12:07:49'),
(93, 9, '491', '2026-05-02 12:34:33', 'Sales', 1, 'Bill #WS016 - Sale Revenue', 0.00, 270.00, 0.00, 0, '2026-05-02 12:34:33', '2026-05-02 12:34:33'),
(94, 9, '491', '2026-05-02 12:34:33', 'Cash', 0, 'Bill #WS016 - Cash Payment', 270.00, 0.00, 0.00, 0, '2026-05-02 12:34:33', '2026-05-02 12:34:33'),
(95, 9, '492', '2026-05-02 12:49:55', 'Sales', 1, 'Bill #WS017 - Sale Revenue', 0.00, 1520.00, 0.00, 0, '2026-05-02 12:49:55', '2026-05-02 12:49:55'),
(96, 9, '492', '2026-05-02 12:49:55', 'Cash', 0, 'Bill #WS017 - Cash Payment', 1520.00, 0.00, 0.00, 0, '2026-05-02 12:49:55', '2026-05-02 12:49:55'),
(97, 9, '493', '2026-05-05 12:06:27', 'Sales', 1, 'Bill #WS018 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-05 12:06:27', '2026-05-05 12:06:27'),
(98, 9, '493', '2026-05-05 12:06:27', 'Cash', 0, 'Bill #WS018 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-05-05 12:06:27', '2026-05-05 12:06:27'),
(99, 9, '494', '2026-05-05 12:06:32', 'Sales', 1, 'Bill #WS019 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-05-05 12:06:32', '2026-05-05 12:06:32'),
(100, 9, '494', '2026-05-05 12:06:32', 'Cash', 0, 'Bill #WS019 - Cash Payment', 950.00, 0.00, 0.00, 0, '2026-05-05 12:06:32', '2026-05-05 12:06:32'),
(101, 9, '495', '2026-05-05 12:07:08', 'Sales', 1, 'Bill #WS020 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-05 12:07:08', '2026-05-05 12:07:08'),
(102, 9, '495', '2026-05-05 12:07:08', 'Cash', 0, 'Bill #WS020 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-05-05 12:07:08', '2026-05-05 12:07:08'),
(103, 8, '496', '2026-05-08 07:30:02', 'Sales', 1, 'Bill #SNR012 - Sale Revenue', 0.00, 85.00, 0.00, 0, '2026-05-08 07:30:02', '2026-05-08 07:30:02'),
(104, 8, '496', '2026-05-08 07:30:02', 'Cash', 0, 'Bill #SNR012 - Cash Payment', 85.00, 0.00, 0.00, 0, '2026-05-08 07:30:02', '2026-05-08 07:30:02'),
(105, 8, '497', '2026-05-10 09:06:01', 'Sales', 1, 'Bill #SNR013 - Sale Revenue', 0.00, 350.00, 0.00, 0, '2026-05-10 09:06:01', '2026-05-10 09:06:01'),
(106, 8, '497', '2026-05-10 09:06:01', 'Cash', 0, 'Bill #SNR013 - Cash Payment', 350.00, 0.00, 0.00, 0, '2026-05-10 09:06:01', '2026-05-10 09:06:01'),
(107, 8, '498', '2026-05-10 09:11:43', 'Sales', 1, 'Bill #SNR014 - Sale Revenue', 0.00, 150.00, 0.00, 0, '2026-05-10 09:11:43', '2026-05-10 09:11:43'),
(108, 8, '498', '2026-05-10 09:11:43', 'Cash', 0, 'Bill #SNR014 - Cash Payment', 150.00, 0.00, 0.00, 0, '2026-05-10 09:11:43', '2026-05-10 09:11:43'),
(109, 8, '499', '2026-05-10 09:13:54', 'Sales', 1, 'Bill #SNR015 - Sale Revenue', 0.00, 150.00, 0.00, 0, '2026-05-10 09:13:54', '2026-05-10 09:13:54'),
(110, 8, '499', '2026-05-10 09:13:54', 'Cash', 0, 'Bill #SNR015 - Cash Payment', 150.00, 0.00, 0.00, 0, '2026-05-10 09:13:54', '2026-05-10 09:13:54'),
(111, 8, '500', '2026-05-10 09:13:57', 'Sales', 1, 'Bill #SNR016 - Sale Revenue', 0.00, 150.00, 0.00, 0, '2026-05-10 09:13:57', '2026-05-10 09:13:57'),
(112, 8, '500', '2026-05-10 09:13:57', 'Cash', 0, 'Bill #SNR016 - Cash Payment', 150.00, 0.00, 0.00, 0, '2026-05-10 09:13:57', '2026-05-10 09:13:57'),
(113, 8, '501', '2026-05-10 10:20:20', 'Sales', 1, 'Bill #SNR017 - Sale Revenue', 0.00, 85.00, 0.00, 0, '2026-05-10 10:20:20', '2026-05-10 10:20:20'),
(114, 8, '501', '2026-05-10 10:20:20', 'QR Code', 0, 'Bill #SNR017 - QR Payment', 85.00, 0.00, 0.00, 0, '2026-05-10 10:20:20', '2026-05-10 10:20:20'),
(115, 8, '502', '2026-05-10 10:22:47', 'Sales', 1, 'Bill #SNR018 - Sale Revenue', 0.00, 75.00, 0.00, 0, '2026-05-10 10:22:47', '2026-05-10 10:22:47'),
(116, 8, '502', '2026-05-10 10:22:47', 'QR Code', 0, 'Bill #SNR018 - QR Payment', 75.00, 0.00, 0.00, 0, '2026-05-10 10:22:47', '2026-05-10 10:22:47'),
(117, 8, '503', '2026-05-10 11:13:55', 'Sales', 1, 'Bill #SNR019 - Sale Revenue', 0.00, 244.00, 0.00, 0, '2026-05-10 11:13:55', '2026-05-10 11:13:55'),
(118, 8, '503', '2026-05-10 11:13:55', 'Cash', 0, 'Bill #SNR019 - Cash Payment', 244.00, 0.00, 0.00, 0, '2026-05-10 11:13:55', '2026-05-10 11:13:55'),
(119, 5, '504', '2026-05-10 14:00:06', 'Sales', 1, 'Bill #DM040 - Sale Revenue', 0.00, 570.00, 0.00, 0, '2026-05-10 14:00:06', '2026-05-10 14:00:06'),
(120, 5, '504', '2026-05-10 14:00:06', 'Cash', 0, 'Bill #DM040 - Cash Payment', 570.00, 0.00, 0.00, 0, '2026-05-10 14:00:06', '2026-05-10 14:00:06'),
(121, 5, '505', '2026-05-10 14:05:38', 'Sales', 1, 'Bill #DM041 - Sale Revenue', 0.00, 500.00, 0.00, 0, '2026-05-10 14:05:38', '2026-05-10 14:05:38'),
(122, 5, '505', '2026-05-10 14:05:38', 'Cash', 0, 'Bill #DM041 - Cash Payment', 500.00, 0.00, 0.00, 0, '2026-05-10 14:05:38', '2026-05-10 14:05:38'),
(123, 5, '506', '2026-05-10 14:06:36', 'Sales', 1, 'Bill #DM042 - Sale Revenue', 0.00, 310.00, 0.00, 0, '2026-05-10 14:06:36', '2026-05-10 14:06:36'),
(124, 5, '506', '2026-05-10 14:06:36', 'Cash', 0, 'Bill #DM042 - Cash Payment', 310.00, 0.00, 0.00, 0, '2026-05-10 14:06:36', '2026-05-10 14:06:36'),
(125, 8, '507', '2026-05-10 16:21:45', 'Sales', 1, 'Bill #SNR020 - Sale Revenue', 0.00, 970.00, 0.00, 0, '2026-05-10 16:21:45', '2026-05-10 16:21:45'),
(126, 8, '507', '2026-05-10 16:21:45', 'QR Code', 0, 'Bill #SNR020 - QR Payment', 970.00, 0.00, 0.00, 0, '2026-05-10 16:21:45', '2026-05-10 16:21:45'),
(127, 8, '508', '2026-05-10 16:23:58', 'Sales', 1, 'Bill #SNR021 - Sale Revenue', 0.00, 400.00, 0.00, 0, '2026-05-10 16:23:58', '2026-05-10 16:23:58'),
(128, 8, '508', '2026-05-10 16:23:58', 'QR Code', 0, 'Bill #SNR021 - QR Payment', 400.00, 0.00, 0.00, 0, '2026-05-10 16:23:58', '2026-05-10 16:23:58'),
(129, 8, '509', '2026-05-10 17:03:44', 'Sales', 1, 'Bill #SNR022 - Sale Revenue', 0.00, 479.00, 0.00, 0, '2026-05-10 17:03:44', '2026-05-10 17:03:44'),
(130, 8, '509', '2026-05-10 17:03:44', 'QR Code', 0, 'Bill #SNR022 - QR Payment', 479.00, 0.00, 0.00, 0, '2026-05-10 17:03:44', '2026-05-10 17:03:44'),
(131, 8, '510', '2026-05-11 02:38:37', 'Sales', 1, 'Bill #SNR023 - Sale Revenue', 0.00, 205.00, 0.00, 0, '2026-05-11 02:38:37', '2026-05-11 02:38:37'),
(132, 8, '510', '2026-05-11 02:38:37', 'QR Code', 0, 'Bill #SNR023 - QR Payment', 205.00, 0.00, 0.00, 0, '2026-05-11 02:38:37', '2026-05-11 02:38:37'),
(133, 8, '511', '2026-05-11 04:35:51', 'Sales', 1, 'Bill #SNR024 - Sale Revenue', 0.00, 70.00, 0.00, 0, '2026-05-11 04:35:51', '2026-05-11 04:35:51'),
(134, 8, '511', '2026-05-11 04:35:51', 'QR Code', 0, 'Bill #SNR024 - QR Payment', 70.00, 0.00, 0.00, 0, '2026-05-11 04:35:51', '2026-05-11 04:35:51'),
(135, 5, '512', '2026-05-11 15:09:44', 'Sales', 1, 'Bill #DM043 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-11 15:09:44', '2026-05-11 15:09:44'),
(136, 5, '512', '2026-05-11 15:09:44', 'Cash', 0, 'Bill #DM043 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-05-11 15:09:44', '2026-05-11 15:09:44'),
(137, 5, '513', '2026-05-11 15:23:01', 'Sales', 1, 'Bill #DM044 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-11 15:23:01', '2026-05-11 15:23:01'),
(138, 5, '513', '2026-05-11 15:23:01', 'Cash', 0, 'Bill #DM044 - Cash Payment', 800.00, 0.00, 0.00, 0, '2026-05-11 15:23:01', '2026-05-11 15:23:01'),
(139, 5, '514', '2026-05-11 15:31:58', 'Sales', 1, 'Bill #DM045 - Sale Revenue', 0.00, 1400.00, 0.00, 0, '2026-05-11 15:31:58', '2026-05-11 15:31:58'),
(140, 5, '514', '2026-05-11 15:31:58', 'Cash', 0, 'Bill #DM045 - Cash Payment', 1400.00, 0.00, 0.00, 0, '2026-05-11 15:31:58', '2026-05-11 15:31:58'),
(141, 5, '515', '2026-05-11 15:43:12', 'Sales', 1, 'Bill #DM046 - Sale Revenue', 0.00, 800.00, 0.00, 0, '2026-05-11 15:43:11', '2026-05-11 15:43:11'),
(142, 5, '516', '2026-05-11 15:56:54', 'Sales', 1, 'Bill #DM047 - Sale Revenue', 0.00, 300.00, 0.00, 0, '2026-05-11 15:56:53', '2026-05-11 15:56:53'),
(143, 5, '516', '2026-05-11 15:56:54', 'Cash', 0, 'Bill #DM047 - Cash Payment', 300.00, 0.00, 0.00, 0, '2026-05-11 15:56:53', '2026-05-11 15:56:53'),
(144, 5, '517', '2026-05-11 16:00:42', 'Sales', 1, 'Bill #DM048 - Sale Revenue', 0.00, 300.00, 0.00, 0, '2026-05-11 16:00:41', '2026-05-11 16:00:41'),
(145, 5, '517', '2026-05-11 16:00:42', 'Cash', 0, 'Bill #DM048 - Cash Payment', 300.00, 0.00, 0.00, 0, '2026-05-11 16:00:41', '2026-05-11 16:00:41'),
(146, 5, '518', '2026-05-11 16:15:17', 'Sales', 1, 'Bill #DM049 - Sale Revenue', 0.00, 450.00, 0.00, 0, '2026-05-11 16:15:16', '2026-05-11 16:15:16'),
(147, 5, '518', '2026-05-11 16:15:17', 'Cash', 0, 'Bill #DM049 - Cash Payment', 450.00, 0.00, 0.00, 0, '2026-05-11 16:15:16', '2026-05-11 16:15:16'),
(148, 5, '519', '2026-05-11 16:16:02', 'Sales', 1, 'Bill #DM050 - Sale Revenue', 0.00, 600.00, 0.00, 0, '2026-05-11 16:16:01', '2026-05-11 16:16:01'),
(149, 5, '519', '2026-05-11 16:16:02', 'Cash', 0, 'Bill #DM050 - Cash Payment', 600.00, 0.00, 0.00, 0, '2026-05-11 16:16:01', '2026-05-11 16:16:01'),
(150, 5, '520', '2026-05-11 18:19:53', 'Sales', 1, 'Bill #DM051 - Sale Revenue', 0.00, 50.00, 0.00, 0, '2026-05-11 18:19:53', '2026-05-11 18:19:53'),
(151, 5, '521', '2026-05-12 13:43:22', 'Sales', 1, 'Bill #DM052 - Sale Revenue', 0.00, 650.00, 0.00, 0, '2026-05-12 13:43:21', '2026-05-12 13:43:21'),
(152, 5, '521', '2026-05-12 13:43:22', 'Cash', 0, 'Bill #DM052 - Cash Payment', 650.00, 0.00, 0.00, 0, '2026-05-12 13:43:21', '2026-05-12 13:43:21'),
(153, 5, '522', '2026-05-12 14:14:24', 'Sales', 1, 'Bill #DM053 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-05-12 14:14:23', '2026-05-12 14:14:23'),
(154, 5, '522', '2026-05-12 14:14:24', 'Cash', 0, 'Bill #DM053 - Cash Payment', 950.00, 0.00, 0.00, 0, '2026-05-12 14:14:23', '2026-05-12 14:14:23'),
(155, 5, '523', '2026-05-12 15:30:28', 'Sales', 1, 'Bill #DM054 - Sale Revenue', 0.00, 1600.00, 0.00, 0, '2026-05-12 15:30:27', '2026-05-12 15:30:27'),
(156, 5, '523', '2026-05-12 15:30:28', 'Cash', 0, 'Bill #DM054 - Cash Payment', 1600.00, 0.00, 0.00, 0, '2026-05-12 15:30:27', '2026-05-12 15:30:27'),
(157, 5, '524', '2026-05-12 17:44:02', 'Sales', 1, 'Bill #DM055 - Sale Revenue', 0.00, 950.00, 0.00, 0, '2026-05-12 17:44:01', '2026-05-12 17:44:01'),
(158, 5, '524', '2026-05-12 17:44:02', 'QR Code', 0, 'Bill #DM055 - QR Payment', 950.00, 0.00, 0.00, 0, '2026-05-12 17:44:01', '2026-05-12 17:44:01'),
(159, 5, '525', '2026-05-12 17:46:42', 'Sales', 1, 'Bill #DM056 - Sale Revenue', 0.00, 2620.00, 0.00, 0, '2026-05-12 17:46:42', '2026-05-12 17:46:42'),
(160, 5, '525', '2026-05-12 17:46:42', 'Cash', 0, 'Bill #DM056 - Cash Payment', 2620.00, 0.00, 0.00, 0, '2026-05-12 17:46:42', '2026-05-12 17:46:42'),
(161, 5, '526', '2026-05-12 17:47:31', 'Sales', 1, 'Bill #DM057 - Sale Revenue', 0.00, 765.00, 0.00, 0, '2026-05-12 17:47:30', '2026-05-12 17:47:30'),
(162, 5, '526', '2026-05-12 17:47:31', 'Cash', 0, 'Bill #DM057 - Cash Payment', 765.00, 0.00, 0.00, 0, '2026-05-12 17:47:30', '2026-05-12 17:47:30'),
(163, 5, '527', '2026-05-12 17:54:00', 'Sales', 1, 'Bill #DM058 - Sale Revenue', 0.00, 745.00, 0.00, 0, '2026-05-12 17:54:00', '2026-05-12 17:54:00'),
(164, 5, '527', '2026-05-12 17:54:00', 'Cash', 0, 'Bill #DM058 - Cash Payment', 745.00, 0.00, 0.00, 0, '2026-05-12 17:54:00', '2026-05-12 17:54:00'),
(165, 5, '528', '2026-05-12 17:58:16', 'Sales', 1, 'Bill #DM059 - Sale Revenue', 0.00, 1635.00, 0.00, 0, '2026-05-12 17:58:16', '2026-05-12 17:58:16'),
(166, 5, '528', '2026-05-12 17:58:16', 'Cash', 0, 'Bill #DM059 - Cash Payment', 1635.00, 0.00, 0.00, 0, '2026-05-12 17:58:16', '2026-05-12 17:58:16'),
(167, 5, '529', '2026-05-12 18:08:59', 'Sales', 1, 'Bill #DM060 - Sale Revenue', 0.00, 550.00, 0.00, 0, '2026-05-12 18:08:59', '2026-05-12 18:08:59'),
(168, 5, '530', '2026-05-12 18:27:22', 'Sales', 1, 'Bill #DM061 - Sale Revenue', 0.00, 280.00, 0.00, 0, '2026-05-12 18:27:21', '2026-05-12 18:27:21'),
(169, 5, '530', '2026-05-12 18:27:22', 'Cash', 0, 'Bill #DM061 - Cash Payment', 280.00, 0.00, 0.00, 0, '2026-05-12 18:27:21', '2026-05-12 18:27:21'),
(170, 5, '531', '2026-05-12 18:31:17', 'Sales', 1, 'Bill #DM062 - Sale Revenue', 0.00, 1840.00, 0.00, 0, '2026-05-12 18:31:17', '2026-05-12 18:31:17');

-- --------------------------------------------------------

--
-- Table structure for table `line_discount_customers`
--

DROP TABLE IF EXISTS `line_discount_customers`;
CREATE TABLE IF NOT EXISTS `line_discount_customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `added_on` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL COMMENT 'User attempting login',
  `username` varchar(233) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Username used',
  `mac_address` varchar(17) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'MAC address',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP address',
  `device_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Device/hostname',
  `status` enum('success','failed_invalid_mac','failed_no_mac','failed_blocked_mac','failed_credentials','failed_other') COLLATE utf8mb4_unicode_ci DEFAULT 'failed_credentials',
  `error_message` text COLLATE utf8mb4_unicode_ci COMMENT 'Failure reason',
  `user_agent` text COLLATE utf8mb4_unicode_ci COMMENT 'Browser/client info',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_mac_address` (`mac_address`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_members`
--

DROP TABLE IF EXISTS `loyalty_members`;
CREATE TABLE IF NOT EXISTS `loyalty_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `loyalty_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tier_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Basic',
  `points_balance` int NOT NULL DEFAULT '0',
  `lifetime_points` int NOT NULL DEFAULT '0',
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `enrolled_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_loyalty_member` (`shop_id`,`customer_id`),
  UNIQUE KEY `uniq_loyalty_code` (`shop_id`,`loyalty_code`),
  KEY `idx_loyalty_members_shop` (`shop_id`),
  KEY `idx_loyalty_members_customer` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_members`
--

INSERT INTO `loyalty_members` (`id`, `shop_id`, `customer_id`, `loyalty_code`, `tier_name`, `points_balance`, `lifetime_points`, `status`, `enrolled_on`, `updated_at`) VALUES
(1, 5, 23, 'LOY-5-23', 'Basic', 80, 80, 'active', '2026-05-12 07:01:05', '2026-05-12 08:30:27'),
(2, 5, 24, 'LOY-5-24', 'Basic', 176, 476, 'active', '2026-05-12 07:10:58', '2026-05-12 11:31:17');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_member_programs`
--

DROP TABLE IF EXISTS `loyalty_member_programs`;
CREATE TABLE IF NOT EXISTS `loyalty_member_programs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `program_id` int NOT NULL,
  `member_id` int NOT NULL,
  `points_balance` int NOT NULL DEFAULT '0',
  `lifetime_points` int NOT NULL DEFAULT '0',
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `enrolled_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_activity_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_loyalty_member_program` (`shop_id`,`program_id`,`member_id`),
  KEY `idx_loyalty_member_program_shop` (`shop_id`),
  KEY `idx_loyalty_member_program_program` (`program_id`),
  KEY `idx_loyalty_member_program_member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_member_programs`
--

INSERT INTO `loyalty_member_programs` (`id`, `shop_id`, `program_id`, `member_id`, `points_balance`, `lifetime_points`, `status`, `enrolled_on`, `last_activity_at`, `expires_at`, `updated_at`) VALUES
(1, 5, 1, 2, 167, 467, 'active', '2026-05-12 08:27:27', '2026-05-12 11:31:17', '2026-11-12 18:31:17', '2026-05-12 11:31:17'),
(2, 5, 2, 2, 0, 0, 'active', '2026-05-12 08:27:27', NULL, '2026-11-12 15:27:27', '2026-05-12 08:27:27'),
(3, 5, 2, 1, 0, 0, 'active', '2026-05-12 08:27:37', NULL, '2026-11-12 15:27:37', '2026-05-12 08:27:37'),
(4, 5, 1, 1, 80, 80, 'active', '2026-05-12 08:30:27', '2026-05-12 08:30:27', '2026-11-12 15:30:27', '2026-05-12 08:30:27');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_notification_queue`
--

DROP TABLE IF EXISTS `loyalty_notification_queue`;
CREATE TABLE IF NOT EXISTS `loyalty_notification_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `member_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `channel` enum('LINE','SMS') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LINE',
  `template_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','SENT','FAILED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `payload_json` json DEFAULT NULL,
  `error_message` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_notification_shop` (`shop_id`),
  KEY `idx_loyalty_notification_status` (`status`),
  KEY `idx_loyalty_notification_customer` (`customer_id`),
  KEY `fk_loyalty_notification_member` (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_notification_queue`
--

INSERT INTO `loyalty_notification_queue` (`id`, `shop_id`, `member_id`, `customer_id`, `channel`, `template_key`, `message`, `status`, `payload_json`, `error_message`, `sent_at`, `created_at`) VALUES
(1, 5, 2, 24, 'LINE', 'LOYALTY_NEAR_REWARD', 'You are close to your next reward. Keep ordering to unlock your offer.', 'PENDING', '{\"channel\": \"LINE\", \"scheduled_for\": null}', NULL, NULL, '2026-05-12 08:26:42'),
(2, 5, 1, 23, 'LINE', 'LOYALTY_EARNED', 'You earned 80 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 523, \"program_id\": 1, \"points_delta\": 80}', NULL, NULL, '2026-05-12 08:30:27'),
(3, 5, 2, 24, 'LINE', 'LOYALTY_NEAR_REWARD', 'You are close to your next reward. Keep ordering to unlock your offer.', 'PENDING', '{\"channel\": \"LINE\", \"scheduled_for\": \"2026-05-12T10:44:00.000Z\"}', NULL, NULL, '2026-05-12 10:41:59'),
(4, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 47 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 524, \"program_id\": 1, \"points_delta\": 47}', NULL, NULL, '2026-05-12 10:44:01'),
(5, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 131 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 525, \"program_id\": 1, \"points_delta\": 131}', NULL, NULL, '2026-05-12 10:46:42'),
(6, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 38 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 526, \"program_id\": 1, \"points_delta\": 38}', NULL, NULL, '2026-05-12 10:47:30'),
(7, 5, 2, 24, 'LINE', 'LOYALTY_REDEEMED_OFFER', 'You redeemed Songkaran_Festival using 100 points.', 'PENDING', '{\"offer_id\": 1, \"redemption_id\": 1, \"discount_value\": 50, \"transaction_id\": 6}', NULL, NULL, '2026-05-12 10:53:50'),
(8, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 37 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 527, \"program_id\": 1, \"points_delta\": 37}', NULL, NULL, '2026-05-12 10:54:00'),
(9, 5, 2, 24, 'LINE', 'LOYALTY_REDEEMED_OFFER', 'You redeemed Songkaran_Festival using 100 points.', 'PENDING', '{\"offer_id\": 1, \"redemption_id\": 2, \"discount_value\": 50, \"transaction_id\": 8}', NULL, NULL, '2026-05-12 10:58:13'),
(10, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 81 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 528, \"program_id\": 1, \"points_delta\": 81}', NULL, NULL, '2026-05-12 10:58:16'),
(11, 5, 2, 24, 'LINE', 'LOYALTY_REDEEMED_OFFER', 'You redeemed Songkaran_Festival using 100 points.', 'PENDING', '{\"offer_id\": 1, \"redemption_id\": 3, \"discount_value\": 50, \"transaction_id\": 10}', NULL, NULL, '2026-05-12 11:08:53'),
(12, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 27 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 529, \"program_id\": 1, \"points_delta\": 27}', NULL, NULL, '2026-05-12 11:08:59'),
(13, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 14 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 530, \"program_id\": 1, \"points_delta\": 14}', NULL, NULL, '2026-05-12 11:27:21'),
(14, 5, 2, 24, 'LINE', 'LOYALTY_EARNED', 'You earned 92 loyalty points in Discount_Offer.', 'PENDING', '{\"bill_id\": 531, \"program_id\": 1, \"points_delta\": 92}', NULL, NULL, '2026-05-12 11:31:17');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_offers`
--

DROP TABLE IF EXISTS `loyalty_offers`;
CREATE TABLE IF NOT EXISTS `loyalty_offers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `program_id` int NOT NULL,
  `offer_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `offer_type` enum('DISCOUNT_AMOUNT','DISCOUNT_PERCENT','FREE_ITEM') COLLATE utf8mb4_unicode_ci NOT NULL,
  `points_required` int NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `discount_percent` decimal(8,2) DEFAULT NULL,
  `free_item_id` int DEFAULT NULL,
  `free_item_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `min_bill_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `max_discount_amount` decimal(10,2) DEFAULT NULL,
  `offer_description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `created_by` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_offers_shop` (`shop_id`),
  KEY `idx_loyalty_offers_program` (`program_id`),
  KEY `idx_loyalty_offers_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_offers`
--

INSERT INTO `loyalty_offers` (`id`, `shop_id`, `program_id`, `offer_name`, `offer_type`, `points_required`, `discount_amount`, `discount_percent`, `free_item_id`, `free_item_name`, `min_bill_amount`, `max_discount_amount`, `offer_description`, `is_active`, `start_at`, `end_at`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 5, 1, 'Songkaran_Festival', 'DISCOUNT_AMOUNT', 100, 50.00, 10.00, NULL, 'Burger', 0.00, 0.00, 'Discount Offer for Songkaran Festival', 1, NULL, NULL, 'system', '2026-05-12 08:22:38', '2026-05-12 08:22:38'),
(2, 5, 2, '100 Points = 50 THB', 'DISCOUNT_AMOUNT', 100, 50.00, 0.00, NULL, 'Burger', 0.00, 0.00, 'Starter redeem offer', 1, NULL, NULL, 'system', '2026-05-12 08:26:14', '2026-05-12 10:45:14');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_programs`
--

DROP TABLE IF EXISTS `loyalty_programs`;
CREATE TABLE IF NOT EXISTS `loyalty_programs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `program_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `earn_spend_amount` decimal(10,2) NOT NULL DEFAULT '20.00',
  `earn_points` int NOT NULL DEFAULT '1',
  `redeem_points_required` int NOT NULL DEFAULT '100',
  `redeem_value` decimal(10,2) NOT NULL DEFAULT '50.00',
  `minimum_redeem_points` int NOT NULL DEFAULT '100',
  `expiry_months` int NOT NULL DEFAULT '6',
  `birthday_reward_type` enum('NONE','FREE_DESSERT','COUPON','CUSTOM') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FREE_DESSERT',
  `birthday_reward_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_programs_shop` (`shop_id`),
  KEY `idx_loyalty_programs_active` (`shop_id`,`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_programs`
--

INSERT INTO `loyalty_programs` (`id`, `shop_id`, `program_name`, `description`, `is_active`, `earn_spend_amount`, `earn_points`, `redeem_points_required`, `redeem_value`, `minimum_redeem_points`, `expiry_months`, `birthday_reward_type`, `birthday_reward_value`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 5, 'Discount_Offer', 'Doscount Loyality Program', 1, 20.00, 1, 100, 50.00, 100, 6, 'COUPON', 'Disc_Coupon', 'system', '2026-05-12 08:21:24', '2026-05-12 08:21:24'),
(2, 5, 'Starter Program', 'Recommended starter setup for small restaurants', 1, 20.00, 1, 100, 50.00, 100, 6, 'FREE_DESSERT', 'Free dessert', 'system', '2026-05-12 08:26:14', '2026-05-12 08:26:14');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_redemptions`
--

DROP TABLE IF EXISTS `loyalty_redemptions`;
CREATE TABLE IF NOT EXISTS `loyalty_redemptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `program_id` int NOT NULL,
  `member_program_id` int NOT NULL,
  `member_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `bill_id` int DEFAULT NULL,
  `offer_id` int DEFAULT NULL,
  `offer_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `offer_type` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `points_used` int NOT NULL,
  `discount_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `free_item_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_redemptions_shop` (`shop_id`),
  KEY `idx_loyalty_redemptions_member` (`member_id`),
  KEY `idx_loyalty_redemptions_customer` (`customer_id`),
  KEY `idx_loyalty_redemptions_bill` (`bill_id`),
  KEY `fk_loyalty_redemptions_program` (`program_id`),
  KEY `fk_loyalty_redemptions_member_program` (`member_program_id`),
  KEY `fk_loyalty_redemptions_offer` (`offer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_redemptions`
--

INSERT INTO `loyalty_redemptions` (`id`, `shop_id`, `program_id`, `member_program_id`, `member_id`, `customer_id`, `bill_id`, `offer_id`, `offer_name`, `offer_type`, `points_used`, `discount_value`, `free_item_name`, `note`, `created_by`, `created_at`) VALUES
(1, 5, 1, 1, 2, 24, NULL, 1, 'Songkaran_Festival', 'DISCOUNT_AMOUNT', 100, 50.00, NULL, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 10:53:50'),
(2, 5, 1, 1, 2, 24, NULL, 1, 'Songkaran_Festival', 'DISCOUNT_AMOUNT', 100, 50.00, NULL, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 10:58:13'),
(3, 5, 1, 1, 2, 24, NULL, 1, 'Songkaran_Festival', 'DISCOUNT_AMOUNT', 100, 50.00, NULL, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 11:08:53');

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_transactions`
--

DROP TABLE IF EXISTS `loyalty_transactions`;
CREATE TABLE IF NOT EXISTS `loyalty_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `member_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `program_id` int DEFAULT NULL,
  `member_program_id` int DEFAULT NULL,
  `bill_id` int DEFAULT NULL,
  `offer_id` int DEFAULT NULL,
  `offer_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_type` enum('EARN','REDEEM','ADJUST') COLLATE utf8mb4_unicode_ci NOT NULL,
  `points_delta` int NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_tx_shop` (`shop_id`),
  KEY `idx_loyalty_tx_member` (`member_id`),
  KEY `idx_loyalty_tx_customer` (`customer_id`),
  KEY `idx_loyalty_tx_bill` (`bill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `loyalty_transactions`
--

INSERT INTO `loyalty_transactions` (`id`, `shop_id`, `member_id`, `customer_id`, `program_id`, `member_program_id`, `bill_id`, `offer_id`, `offer_name`, `transaction_type`, `points_delta`, `note`, `created_by`, `created_at`) VALUES
(1, 5, 2, 24, NULL, NULL, 522, NULL, NULL, 'EARN', 9, 'Bill #DM053', 'system', '2026-05-12 07:14:23'),
(2, 5, 1, 23, 1, 4, 523, NULL, NULL, 'EARN', 80, 'Bill #DM054', 'system', '2026-05-12 08:30:27'),
(3, 5, 2, 24, 1, 1, 524, NULL, NULL, 'EARN', 47, 'Bill #DM055', 'system', '2026-05-12 10:44:01'),
(4, 5, 2, 24, 1, 1, 525, NULL, NULL, 'EARN', 131, 'Bill #DM056', 'system', '2026-05-12 10:46:42'),
(5, 5, 2, 24, 1, 1, 526, NULL, NULL, 'EARN', 38, 'Bill #DM057', 'system', '2026-05-12 10:47:30'),
(6, 5, 2, 24, 1, 1, NULL, 1, 'Songkaran_Festival', 'REDEEM', -100, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 10:53:50'),
(7, 5, 2, 24, 1, 1, 527, NULL, NULL, 'EARN', 37, 'Bill #DM058', 'system', '2026-05-12 10:54:00'),
(8, 5, 2, 24, 1, 1, NULL, 1, 'Songkaran_Festival', 'REDEEM', -100, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 10:58:13'),
(9, 5, 2, 24, 1, 1, 528, NULL, NULL, 'EARN', 81, 'Bill #DM059', 'system', '2026-05-12 10:58:16'),
(10, 5, 2, 24, 1, 1, NULL, 1, 'Songkaran_Festival', 'REDEEM', -100, 'Redeemed from POS CheckBill modal', 'system', '2026-05-12 11:08:53'),
(11, 5, 2, 24, 1, 1, 529, NULL, NULL, 'EARN', 27, 'Bill #DM060', 'system', '2026-05-12 11:08:59'),
(12, 5, 2, 24, 1, 1, 530, NULL, NULL, 'EARN', 14, 'Bill #DM061', 'system', '2026-05-12 11:27:21'),
(13, 5, 2, 24, 1, 1, 531, NULL, NULL, 'EARN', 92, 'Bill #DM062', 'system', '2026-05-12 11:31:17');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `message` text COLLATE utf8mb4_general_ci NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `image_path` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `notification_type` enum('general','announcement','promotion','alert','maintenance') COLLATE utf8mb4_general_ci DEFAULT 'general',
  `target_type` enum('all','specific_shops','specific_users') COLLATE utf8mb4_general_ci DEFAULT 'all',
  `shop_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Array of shop_ids for specific shops',
  `user_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Array of user_ids for specific users',
  `created_by` int NOT NULL COMMENT 'Super admin user ID who created this',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint DEFAULT '1',
  `scheduled_for` datetime DEFAULT NULL COMMENT 'Schedule notification for future time',
  `expires_at` datetime DEFAULT NULL COMMENT 'When notification expires/becomes inactive',
  `views_count` int DEFAULT '0',
  `priority` enum('low','normal','high','urgent') COLLATE utf8mb4_general_ci DEFAULT 'normal',
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target_type`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_scheduled_for` (`scheduled_for`)
) ;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `title`, `message`, `image_url`, `image_path`, `notification_type`, `target_type`, `shop_ids`, `user_ids`, `created_by`, `created_at`, `updated_at`, `is_active`, `scheduled_for`, `expires_at`, `views_count`, `priority`) VALUES
(4, 'Regulare Maintainance ', 'We are going to under maintainenance on 25 march 2026 for 2-3 hours start from 10:00 am', NULL, NULL, 'alert', 'all', NULL, NULL, 1, '2026-03-27 07:04:23', '2026-03-27 07:04:23', 1, NULL, NULL, 0, 'high'),
(11, 'Enhancement of Supplier Module – UI Design & Backend Database Upgrade', 'We are pleased to inform you that significant improvements have been successfully implemented in the Supplier Management Module at both the design (frontend) and database/backend levels.\n\nThese updates are aimed at improving system performance, usability, and scalability for better supplier handling and data management.\n\n🔹 Key Updates\n✅ 1. UI/UX Design Improvements\nEnhanced user interface for better navigation and usability\nImproved layout structure for supplier-related operations\nFaster and more intuitive supplier data entry and management\n✅ 2. Database Structure Optimization\nRefined supplier-related tables for improved data organization\nOptimized relationships between supplier and transaction records\nImproved query performance for faster data retrieval\n✅ 3. Backend Logic Enhancements\nUpdated APIs for supplier creation, update, and management\nImproved validation and error handling mechanisms\nBetter data consistency and integrity checks\n🔹 Benefits\n⚡ Faster system performance\n📊 More reliable supplier data management\n🔒 Improved data integrity and security\n📈 Scalable structure for future enhancements\n🔹 Important Note\n\nThese updates have been applied at the system level and do not require any action from your side. However, we recommend clearing your browser cache to experience the latest updates smoothly.\n\n🔹 Support\n\nIf you face any issues or have questions regarding this update, feel free to contact our support team.\n\nThank you for your continued trust in our services.\n– Cloudnet Softwares Team', NULL, NULL, 'general', 'all', NULL, NULL, 1, '2026-03-31 18:29:08', '2026-03-31 18:29:08', 1, NULL, NULL, 0, 'normal'),
(12, 'Buf Fixed', '- Topbar Business Date now uses setup date from `getNextSetupDate()`\n- Business Date refresh logic runs every 60 seconds to keep display in sync\n- Build workflow continues to sync `CHANGELOG.md` into `public/CHANGELOG.md`', NULL, NULL, 'announcement', 'all', NULL, NULL, 1, '2026-04-02 08:38:58', '2026-04-02 08:38:58', 1, '2026-04-03 00:00:00', NULL, 0, 'normal'),
(13, 'Subscription Plan Upgraded', 'Your subscription package has been upgraded to Enterprise. Enjoy your new features!', NULL, NULL, '', 'specific_shops', '[5]', NULL, 1, '2026-05-13 08:28:56', '2026-05-13 08:28:56', 1, NULL, NULL, 0, 'high'),
(14, 'Subscription Plan Upgraded', 'Your subscription package has been upgraded to Professional. Enjoy your new features!', NULL, NULL, '', 'specific_shops', '[5]', NULL, 1, '2026-05-13 08:33:55', '2026-05-13 08:33:55', 1, NULL, NULL, 0, 'high'),
(15, 'Subscription Plan Upgraded', 'Your subscription package has been upgraded to Starter. Enjoy your new features!', NULL, NULL, '', 'specific_shops', '[9]', NULL, 1, '2026-05-13 08:38:02', '2026-05-13 08:38:02', 1, NULL, NULL, 0, 'high');

-- --------------------------------------------------------

--
-- Table structure for table `notification_read_status`
--

DROP TABLE IF EXISTS `notification_read_status`;
CREATE TABLE IF NOT EXISTS `notification_read_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `notification_id` int NOT NULL,
  `shop_id` int NOT NULL,
  `user_id` int NOT NULL,
  `is_read` tinyint DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_notification_user` (`notification_id`,`shop_id`,`user_id`),
  KEY `idx_notification_id` (`notification_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification_read_status`
--

INSERT INTO `notification_read_status` (`id`, `notification_id`, `shop_id`, `user_id`, `is_read`, `read_at`, `created_at`) VALUES
(24, 4, 5, 180, 1, '2026-03-30 11:51:37', '2026-03-30 11:51:37'),
(26, 4, 7, 182, 1, '2026-04-01 05:54:22', '2026-04-01 05:54:22'),
(27, 11, 7, 182, 1, '2026-04-01 05:56:00', '2026-04-01 05:56:00'),
(33, 11, 5, 180, 1, '2026-04-02 07:56:16', '2026-04-02 07:56:16'),
(34, 4, 8, 185, 1, '2026-04-02 08:40:51', '2026-04-02 08:40:51'),
(35, 12, 5, 180, 1, '2026-04-04 08:05:13', '2026-04-04 08:05:13'),
(36, 11, 8, 185, 1, '2026-04-09 07:16:00', '2026-04-09 07:16:00'),
(37, 12, 5, 181, 1, '2026-04-13 07:12:10', '2026-04-13 07:12:10'),
(38, 13, 5, 190, 1, '2026-05-13 15:32:57', '2026-05-13 08:29:05'),
(40, 14, 5, 190, 1, '2026-05-13 15:34:07', '2026-05-13 08:34:07');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `userid` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  `order_number` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_orders_shop_id` (`shop_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1587 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `shop_id`, `userid`, `order_number`, `table_number`, `total_amount`, `created_at`, `invoice_number`, `status`) VALUES
(1560, 8, '58271', 28, 'Table 3', 70.00, '2026-05-11 04:35:25', NULL, 1),
(1559, 8, '58271', 27, 'Table 2', 205.00, '2026-05-11 02:32:10', NULL, 1),
(1558, 8, '58271', 26, 'Table 8', 479.00, '2026-05-10 16:55:06', NULL, 1),
(1557, 8, '58271', 25, 'Table 8', 400.00, '2026-05-10 16:19:53', NULL, 1),
(1556, 8, '58271', 24, 'Table 7', 100.00, '2026-05-10 15:41:03', NULL, 1),
(1555, 8, '58271', 23, 'Table 7', 100.00, '2026-05-10 14:51:49', NULL, 1),
(1554, 8, '58271', 22, 'Table 7', 770.00, '2026-05-10 14:42:11', NULL, 1),
(1553, 5, '18594', 55, 'Table 1', 310.00, '2026-05-10 14:06:31', NULL, 1),
(1552, 5, '18594', 54, 'Table 1', 190.00, '2026-05-10 14:05:34', NULL, 1),
(1551, 5, '18594', 53, 'Table 1', 310.00, '2026-05-10 13:59:57', NULL, 1),
(1550, 8, '58271', 21, 'Table 4', 244.00, '2026-05-10 11:02:59', NULL, 1),
(1549, 8, '58271', 20, 'Table 3', 75.00, '2026-05-10 10:21:58', NULL, 1),
(1548, 8, '58271', 19, 'Table 1', 85.00, '2026-05-10 10:19:07', NULL, 1),
(1547, 8, '58271', 18, 'Table 2', 150.00, '2026-05-10 09:08:51', NULL, 1),
(1546, 8, '58271', 17, 'Table 1', 150.00, '2026-05-10 09:08:22', NULL, 1),
(1545, 8, '58271', 16, 'Table 1', 150.00, '2026-05-10 09:01:43', NULL, 1),
(1544, 8, '58271', 15, 'Table 1', 150.00, '2026-05-10 08:52:57', NULL, 1),
(1543, 8, '58271', 14, 'Table 1', 50.00, '2026-05-09 13:54:43', NULL, 1),
(1542, 8, '58271', 13, 'Table 1', 85.00, '2026-05-08 07:28:47', NULL, 1),
(1541, 9, '32741', 23, 'Room 305', 800.00, '2026-05-05 12:06:58', NULL, 1),
(1395, 4, '63651', 2, 'VIP1', 300.00, '2026-03-27 11:00:03', NULL, 1),
(1540, 9, '32741', 22, 'Table 2', 1900.00, '2026-05-02 12:49:17', NULL, 1),
(1539, 9, '32741', 21, 'Table 1', 270.00, '2026-05-02 12:32:35', NULL, 1),
(1538, 9, '32741', 20, 'Room 401', 800.00, '2026-05-02 12:07:19', NULL, 1),
(1537, 9, '32741', 19, 'Room 303', 950.00, '2026-05-02 11:51:18', NULL, 1),
(1536, 9, '32741', 18, 'Room 301', 800.00, '2026-05-02 11:45:57', NULL, 1),
(1535, 7, '51634', 4, 'Table 2', 570.00, '2026-04-28 07:24:36', NULL, 1),
(1534, 9, '32741', 17, 'Table 4', 750.00, '2026-04-27 12:17:15', NULL, 1),
(1533, 9, '32741', 16, 'Table 3', 945.00, '2026-04-27 11:57:26', NULL, 1),
(1532, 9, '32741', 15, 'Table 10', 15.00, '2026-04-26 09:40:10', NULL, 1),
(1531, 9, '32741', 14, 'Room 302', 880.00, '2026-04-26 09:36:41', NULL, 1),
(1530, 7, '51634', 3, 'Table 2', 1200.00, '2026-04-23 12:13:43', NULL, 1),
(1430, 5, '18594', 2, 'Table 1', 250.00, '2026-03-30 11:17:44', NULL, 1),
(1431, 5, '13718', 2, 'Table 2', 245.00, '2026-03-30 11:45:07', NULL, 1),
(1432, 5, '18594', 3, 'Table 1', 310.00, '2026-03-30 15:37:46', NULL, 1),
(1433, 5, '18594', 4, 'Table 1', 250.00, '2026-03-30 15:57:52', NULL, 1),
(1434, 5, '18594', 5, 'Table 2', 250.00, '2026-03-30 16:00:14', NULL, 1),
(1435, 5, '18594', 6, 'Table 2', 245.00, '2026-03-30 16:02:15', NULL, 1),
(1436, 5, '18594', 7, 'Table 2', 1055.00, '2026-03-30 16:02:26', NULL, 1),
(1437, 5, '18594', 8, 'Table 3', 100.00, '2026-03-30 16:04:10', NULL, 1),
(1438, 5, '18594', 9, 'Table 2', 340.00, '2026-03-30 16:06:40', NULL, 1),
(1439, 5, '18594', 10, 'Table 1', 245.00, '2026-03-30 16:13:19', NULL, 1),
(1440, 5, '18594', 11, 'VIP 1', 480.00, '2026-03-30 16:13:30', NULL, 1),
(1441, 5, '18594', 12, 'Table 2', 390.00, '2026-03-30 16:14:04', NULL, 1),
(1442, 5, '18594', 13, 'Table 3', 340.00, '2026-03-30 16:18:32', NULL, 1),
(1443, 5, '18594', 14, 'Table 2', 310.00, '2026-03-30 16:24:04', NULL, 1),
(1444, 5, '18594', 15, 'VIP 2', 190.00, '2026-03-30 16:37:41', NULL, 1),
(1445, 5, '18594', 16, 'VIP 3', 100.00, '2026-03-30 16:37:52', NULL, 1),
(1446, 5, '18594', 17, 'Table 2', 190.00, '2026-03-30 16:39:03', NULL, 1),
(1447, 5, '18594', 18, 'VIP 3', 190.00, '2026-03-30 16:41:25', NULL, 1),
(1448, 5, '18594', 19, 'Table 3', 300.00, '2026-03-30 16:43:24', NULL, 1),
(1449, 5, '18594', 20, 'VIP 3', 245.00, '2026-03-30 16:43:57', NULL, 1),
(1450, 5, '18594', 21, 'VIP 2', 310.00, '2026-03-30 16:46:23', NULL, 1),
(1451, 5, '18594', 22, 'Table 1', 250.00, '2026-03-30 17:27:16', NULL, 1),
(1452, 5, '18594', 23, 'Table 1', 190.00, '2026-03-30 17:28:37', NULL, 1),
(1453, 5, '18594', 24, 'VIP 1', 795.00, '2026-03-30 17:29:48', NULL, 1),
(1454, 5, '18594', 25, 'VIP 1', 1325.00, '2026-03-30 17:30:07', NULL, 1),
(1455, 5, '13718', 3, 'Table 2', 350.00, '2026-03-31 14:39:35', NULL, 1),
(1456, 5, '13718', 4, 'Table 3', 700.00, '2026-03-31 14:44:51', NULL, 1),
(1457, 5, '13718', 5, 'Table 3', 100.00, '2026-03-31 14:45:02', NULL, 1),
(1458, 5, '18594', 26, 'Table 3', 250.00, '2026-03-31 14:46:08', NULL, 1),
(1459, 5, '13718', 6, 'Table 2', 210.00, '2026-03-31 14:50:28', NULL, 1),
(1460, 5, '13718', 7, 'Table 3', 100.00, '2026-03-31 14:52:52', NULL, 1),
(1461, 5, '13718', 8, 'Table 2', 100.00, '2026-03-31 15:13:48', NULL, 1),
(1462, 5, '13718', 9, 'VIP 1', 510.00, '2026-03-31 15:13:57', NULL, 1),
(1463, 5, '13718', 10, 'Table 2', 50.00, '2026-03-31 16:06:10', NULL, 1),
(1464, 5, '13718', 11, 'Table 3', 295.00, '2026-03-31 16:06:51', NULL, 1),
(1465, 5, '18594', 27, 'Table 3', 730.00, '2026-03-31 16:14:26', NULL, 1),
(1466, 5, '18594', 28, 'Table 1', 295.00, '2026-03-31 16:17:48', NULL, 1),
(1467, 5, '18594', 29, 'Table 1', 1610.00, '2026-03-31 17:04:15', NULL, 1),
(1468, 7, '51634', 2, 'Table 1', 200.00, '2026-04-03 10:12:42', NULL, 1),
(1469, 7, '27412', 2, 'Table 1', 200.00, '2026-04-03 10:27:46', NULL, 1),
(1470, 7, '27412', 3, 'Table 1', 100.00, '2026-04-03 10:28:40', NULL, 1),
(1471, 7, '27412', 4, 'Table 1', 200.00, '2026-04-03 10:30:20', NULL, 1),
(1472, 7, '27412', 5, 'Table 1', 200.00, '2026-04-03 10:31:11', NULL, 1),
(1473, 7, '27412', 6, 'Table 1', 200.00, '2026-04-03 10:32:00', NULL, 1),
(1474, 7, '27412', 7, 'Table 1', 200.00, '2026-04-03 10:32:41', NULL, 1),
(1475, 7, '27412', 8, 'Table 1', 200.00, '2026-04-03 10:33:35', NULL, 1),
(1476, 5, '18594', 30, 'Table 1', 190.00, '2026-04-04 04:24:14', NULL, 1),
(1477, 5, '18594', 31, 'Table 1', 1160.00, '2026-04-04 04:24:24', NULL, 1),
(1478, 5, '18594', 32, 'Table 1', 350.00, '2026-04-05 04:27:08', NULL, 1),
(1479, 5, '18594', 33, 'Table 1', 295.00, '2026-04-05 04:28:03', NULL, 1),
(1480, 5, '18594', 34, 'Table 2', 490.00, '2026-04-05 04:40:39', NULL, 1),
(1481, 5, '18594', 35, 'Table 2', 245.00, '2026-04-05 04:41:57', NULL, 1),
(1482, 5, '18594', 36, 'Table 3', 760.00, '2026-04-05 04:43:56', NULL, 1),
(1483, 5, '13718', 12, 'Table 2', 370.00, '2026-04-05 04:46:36', NULL, 1),
(1484, 5, '13718', 13, 'Table 2', 760.00, '2026-04-05 04:46:43', NULL, 1),
(1485, 5, '13718', 14, 'VIP 1', 295.00, '2026-04-05 04:46:56', NULL, 1),
(1486, 5, '18594', 37, 'Table 2', 280.00, '2026-04-05 06:57:01', NULL, 1),
(1487, 8, '58271', 2, 'Table 1', 300.00, '2026-04-05 07:41:26', NULL, 1),
(1488, 8, '58271', 3, 'Table 2', 300.00, '2026-04-05 07:46:07', NULL, 1),
(1489, 8, '58271', 4, 'Table 3', 600.00, '2026-04-05 07:46:22', NULL, 1),
(1490, 5, '18594', 38, 'Table 3', 530.00, '2026-04-06 07:44:31', NULL, 1),
(1491, 5, '18594', 39, 'Table 3', 190.00, '2026-04-06 07:56:57', NULL, 1),
(1492, 5, '18594', 40, 'Table 3', 310.00, '2026-04-06 08:02:04', NULL, 1),
(1493, 5, '18594', 41, 'Table 3', 410.00, '2026-04-06 08:02:38', NULL, 1),
(1494, 5, '18594', 42, 'Table 2', 245.00, '2026-04-06 10:12:56', NULL, 1),
(1495, 5, '18594', 43, 'Table 2', 245.00, '2026-04-06 10:17:42', NULL, 1),
(1496, 5, '18594', 44, 'Table 2', 245.00, '2026-04-06 10:20:28', NULL, 1),
(1497, 5, '18594', 45, 'Table 3', 100.00, '2026-04-06 10:29:03', NULL, 1),
(1498, 5, '18594', 46, 'Table 2', 190.00, '2026-04-06 10:36:34', NULL, 1),
(1499, 5, '18594', 47, 'Table 3', 370.00, '2026-04-06 10:40:49', NULL, 1),
(1500, 5, '18594', 48, 'Table 3', 60.00, '2026-04-06 10:41:26', NULL, 1),
(1501, 5, '18594', 49, 'Table 2', 310.00, '2026-04-06 10:44:41', NULL, 1),
(1502, 5, '18594', 50, 'Table 3', 250.00, '2026-04-06 10:46:15', NULL, 1),
(1503, 5, '18594', 51, 'Table 3', 1205.00, '2026-04-06 10:50:26', NULL, 1),
(1504, 8, '58271', 5, 'Table 1', 115.00, '2026-04-08 13:24:43', NULL, 1),
(1505, 5, '13718', 15, 'Table 1', 300.00, '2026-04-09 08:00:20', NULL, 1),
(1506, 8, '58271', 6, 'Table 2', 140.00, '2026-04-10 06:31:54', NULL, 1),
(1507, 8, '58271', 7, 'Table 2', 99.00, '2026-04-10 06:37:18', NULL, 1),
(1508, 8, '58271', 8, 'Table 1', 120.00, '2026-04-12 04:27:07', NULL, 1),
(1509, 8, '58271', 9, 'Take Away', 550.00, '2026-04-12 04:30:10', NULL, 1),
(1510, 8, '58271', 9, 'Table 1', 50.00, '2026-04-12 04:34:48', NULL, 1),
(1511, 8, '58271', 10, 'Table 1', 115.00, '2026-04-12 04:36:08', NULL, 1),
(1512, 5, '18594', 52, 'Table 3', 310.00, '2026-04-12 04:48:02', NULL, 1),
(1513, 8, '58271', 11, 'Table 1', 850.00, '2026-04-12 04:52:32', NULL, 1),
(1514, 8, '58271', 12, 'Table 1', 350.00, '2026-04-12 04:52:41', NULL, 1),
(1515, 5, '13718', 16, 'Table 1', 2265.00, '2026-04-12 06:57:42', NULL, 1),
(1516, 5, '13718', 17, 'Table 1', 1190.00, '2026-04-12 07:04:32', NULL, 1),
(1517, 5, '13718', 18, 'Table 2', 570.00, '2026-04-13 07:21:52', NULL, 1),
(1518, 9, '32741', 2, 'Room 201', 2400.00, '2026-04-18 06:57:32', NULL, 1),
(1519, 9, '32741', 3, 'Room 302', 800.00, '2026-04-18 06:58:35', NULL, 1),
(1520, 9, '32741', 4, 'Room 303', 950.00, '2026-04-18 06:59:26', NULL, 1),
(1521, 9, '32741', 5, 'Room 304', 950.00, '2026-04-18 06:59:45', NULL, 1),
(1522, 9, '32741', 6, 'Room 305', 800.00, '2026-04-18 07:00:25', NULL, 1),
(1523, 9, '32741', 7, 'Room 403', 800.00, '2026-04-18 07:04:26', NULL, 1),
(1524, 9, '32741', 8, 'Room 304', 950.00, '2026-04-18 07:36:38', NULL, 1),
(1525, 9, '32741', 9, 'Room 402', 800.00, '2026-04-18 08:05:14', NULL, 1),
(1526, 9, '32741', 10, 'Room 302', 800.00, '2026-04-19 06:37:31', NULL, 1),
(1527, 9, '32741', 11, 'Room 302', 375.00, '2026-04-19 06:38:33', NULL, 1),
(1528, 9, '32741', 12, 'Grab 1', 15.00, '2026-04-19 07:13:09', NULL, 1),
(1529, 9, '32741', 13, 'Grab 1', 15.00, '2026-04-19 07:13:35', NULL, 1),
(1561, 5, '18594', 56, 'Table 1', 500.00, '2026-05-11 07:45:03', NULL, 1),
(1562, 5, '18594', 57, 'Table 2', 800.00, '2026-05-11 08:09:16', NULL, 1),
(1563, 5, '18594', 58, 'Table 2', 800.00, '2026-05-11 08:22:15', NULL, 1),
(1564, 5, '18594', 59, 'Table 2', 400.00, '2026-05-11 08:26:14', NULL, 1),
(1565, 5, '18594', 60, 'Table 2', 400.00, '2026-05-11 08:27:13', NULL, 1),
(1566, 5, '18594', 61, 'Table 2', 600.00, '2026-05-11 08:31:47', NULL, 1),
(1567, 5, '18594', 62, 'Table 2', 800.00, '2026-05-11 08:43:04', NULL, 1),
(1568, 5, '18594', 63, 'Table 2', 300.00, '2026-05-11 08:56:41', NULL, 1),
(1569, 5, '18594', 64, 'Table 3', 300.00, '2026-05-11 09:00:34', NULL, 1),
(1570, 5, '18594', 65, 'Table 2', 450.00, '2026-05-11 09:15:10', NULL, 1),
(1571, 5, '18594', 66, 'Table 3', 600.00, '2026-05-11 09:15:56', NULL, 1),
(1572, 5, '18594', 67, 'Table 2', 50.00, '2026-05-11 11:19:43', NULL, 1),
(1573, 5, '18594', 68, 'Table 1', 450.00, '2026-05-12 06:46:35', NULL, 1),
(1574, 5, '18594', 69, 'Table 3', 1110.00, '2026-05-12 08:27:20', NULL, 1),
(1575, 5, '18594', 70, 'Table 3', 490.00, '2026-05-12 08:29:52', NULL, 1),
(1576, 5, '18594', 71, 'Table 3', 220.00, '2026-05-12 10:42:32', NULL, 1),
(1577, 5, '18594', 72, 'VIP 1', 950.00, '2026-05-12 10:42:56', NULL, 1),
(1578, 5, '18594', 73, 'VIP 1', 765.00, '2026-05-12 10:45:31', NULL, 1),
(1579, 5, '18594', 74, 'Table 3', 2400.00, '2026-05-12 10:46:22', NULL, 1),
(1580, 5, '18594', 75, 'VIP 2', 795.00, '2026-05-12 10:47:54', NULL, 1),
(1581, 5, '18594', 76, 'VIP 1', 1685.00, '2026-05-12 10:53:22', NULL, 1),
(1582, 5, '18594', 77, 'VIP 3', 280.00, '2026-05-12 11:01:12', NULL, 1),
(1583, 5, '18594', 78, 'VIP 1', 600.00, '2026-05-12 11:04:46', NULL, 1),
(1584, 5, '18594', 79, 'Table 2', 775.00, '2026-05-12 11:07:10', NULL, 1),
(1585, 5, '18594', 80, 'Table 3', 510.00, '2026-05-12 11:27:03', NULL, 1),
(1586, 5, '18594', 81, 'VIP 2', 1840.00, '2026-05-12 11:31:00', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `order_id` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_group` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `quantity` float NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `setup_date` date NOT NULL,
  `table_cat_id` int DEFAULT NULL COMMENT 'Foreign key reference to table_category.id',
  `catid` int DEFAULT NULL,
  `subcatid` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `idx_table_cat_id` (`table_cat_id`),
  KEY `idx_order_items_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2813 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `shop_id`, `order_id`, `table_number`, `item_name`, `item_group`, `quantity`, `total_price`, `created_at`, `invoice_number`, `status`, `setup_date`, `table_cat_id`, `catid`, `subcatid`) VALUES
(2396, 4, 2, 'VIP1', 'dasda', 'Food', 2, 300.00, '2026-03-27 11:00:03', 'CLD001', 0, '2026-03-27', 9, 46, 77),
(2444, 5, 2, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 11:17:44', 'DM001', 0, '2026-03-30', 10, 47, 78),
(2445, 5, 2, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 11:17:44', 'DM001', 0, '2026-03-30', 10, 47, 78),
(2446, 5, 2, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 11:45:07', 'DM002', 0, '2026-03-30', 10, 47, 79),
(2447, 5, 2, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 11:45:07', 'DM002', 0, '2026-03-30', 10, 47, 79),
(2448, 5, 3, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 15:37:46', 'DM003', 0, '2026-03-30', 10, 47, 78),
(2449, 5, 3, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 15:37:46', 'DM003', 0, '2026-03-30', 10, 47, 78),
(2450, 5, 3, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 15:37:46', 'DM003', 0, '2026-03-30', 10, 47, 78),
(2451, 5, 4, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 15:57:52', 'DM006', 0, '2026-03-30', 10, 47, 78),
(2452, 5, 4, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 15:57:52', 'DM006', 0, '2026-03-30', 10, 47, 78),
(2453, 5, 5, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 16:00:14', 'DM004', 0, '2026-03-30', 10, 47, 78),
(2454, 5, 5, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:00:14', 'DM004', 0, '2026-03-30', 10, 47, 78),
(2455, 5, 6, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:02:15', 'DM004', 0, '2026-03-30', 10, 47, 79),
(2456, 5, 6, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 16:02:15', 'DM004', 0, '2026-03-30', 10, 47, 79),
(2457, 5, 7, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 79),
(2458, 5, 7, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 79),
(2459, 5, 7, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 79),
(2460, 5, 7, 'Table 2', 'Lunch 1', 'Food', 1, 250.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 80),
(2461, 5, 7, 'Table 2', 'Lunch 2', 'Food', 1, 230.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 80),
(2462, 5, 7, 'Table 2', 'Lunch 3', 'Food', 1, 280.00, '2026-03-30 16:02:26', 'DM004', 0, '2026-03-30', 10, 47, 80),
(2463, 5, 8, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:04:10', 'DM005', 0, '2026-03-30', 10, 47, 79),
(2464, 5, 8, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 16:04:10', 'DM005', 0, '2026-03-30', 10, 47, 79),
(2465, 5, 9, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:06:40', 'DM007', 0, '2026-03-30', 10, 47, 78),
(2466, 5, 9, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:06:40', 'DM007', 0, '2026-03-30', 10, 47, 78),
(2467, 5, 9, 'Table 2', 'Coffee4', 'Food', 1, 150.00, '2026-03-30 16:06:40', 'DM007', 0, '2026-03-30', 10, 47, 78),
(2468, 5, 10, 'Table 1', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:13:19', 'DM010', 0, '2026-03-30', 10, 47, 79),
(2469, 5, 10, 'Table 1', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 16:13:19', 'DM010', 0, '2026-03-30', 10, 47, 79),
(2470, 5, 11, 'VIP 1', 'Lunch 1', 'Food', 1, 250.00, '2026-03-30 16:13:30', 'DM009', 0, '2026-03-30', 10, 47, 80),
(2471, 5, 11, 'VIP 1', 'Lunch 2', 'Food', 1, 230.00, '2026-03-30 16:13:30', 'DM009', 0, '2026-03-30', 10, 47, 80),
(2472, 5, 12, 'Table 2', 'Snack 3', 'Food', 2, 390.00, '2026-03-30 16:14:04', 'DM008', 0, '2026-03-30', 10, 47, 79),
(2473, 5, 13, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:18:32', 'DM011', 0, '2026-03-30', 10, 47, 78),
(2474, 5, 13, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:18:32', 'DM011', 0, '2026-03-30', 10, 47, 78),
(2475, 5, 13, 'Table 3', 'Coffee4', 'Food', 1, 150.00, '2026-03-30 16:18:32', 'DM011', 0, '2026-03-30', 10, 47, 78),
(2476, 5, 14, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 16:24:04', 'DM012', 0, '2026-03-30', 10, 47, 78),
(2477, 5, 14, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:24:04', 'DM012', 0, '2026-03-30', 10, 47, 78),
(2478, 5, 14, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:24:04', 'DM012', 0, '2026-03-30', 10, 47, 78),
(2479, 5, 15, 'VIP 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:37:41', 'DM014', 0, '2026-03-30', 10, 47, 78),
(2480, 5, 15, 'VIP 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:37:41', 'DM014', 0, '2026-03-30', 10, 47, 78),
(2481, 5, 16, 'VIP 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:37:52', 'DM013', 0, '2026-03-30', 10, 47, 79),
(2482, 5, 16, 'VIP 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 16:37:52', 'DM013', 0, '2026-03-30', 10, 47, 79),
(2483, 5, 17, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:39:03', 'DM018', 0, '2026-03-30', 10, 47, 78),
(2484, 5, 17, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:39:03', 'DM018', 0, '2026-03-30', 10, 47, 78),
(2485, 5, 18, 'VIP 3', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:41:25', 'DM015', 0, '2026-03-30', 10, 47, 78),
(2486, 5, 18, 'VIP 3', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:41:25', 'DM015', 0, '2026-03-30', 10, 47, 78),
(2487, 5, 19, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 16:43:24', 'DM016', 0, '2026-03-30', 10, 47, 79),
(2488, 5, 19, 'Table 3', 'Lunch 1', 'Food', 1, 250.00, '2026-03-30 16:43:24', 'DM016', 0, '2026-03-30', 10, 47, 80),
(2489, 5, 20, 'VIP 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 16:43:57', 'DM019', 0, '2026-03-30', 10, 47, 79),
(2490, 5, 20, 'VIP 3', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 16:43:57', 'DM019', 0, '2026-03-30', 10, 47, 79),
(2491, 5, 21, 'VIP 2', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 16:46:23', 'DM017', 0, '2026-03-30', 10, 47, 78),
(2492, 5, 21, 'VIP 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 16:46:23', 'DM017', 0, '2026-03-30', 10, 47, 78),
(2493, 5, 21, 'VIP 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 16:46:23', 'DM017', 0, '2026-03-30', 10, 47, 78),
(2494, 5, 22, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 17:27:16', 'DM025', 0, '2026-03-31', 10, 47, 78),
(2495, 5, 22, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 17:27:16', 'DM025', 0, '2026-03-31', 10, 47, 78),
(2496, 5, 23, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-03-30 17:28:37', 'DM025', 0, '2026-03-31', 10, 47, 78),
(2497, 5, 23, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-30 17:28:37', 'DM025', 0, '2026-03-31', 10, 47, 78),
(2498, 5, 24, 'VIP 1', 'Coffee2', 'Food', 2, 260.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 78),
(2499, 5, 24, 'VIP 1', 'Coffee3', 'Food', 2, 120.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 78),
(2500, 5, 24, 'VIP 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 78),
(2501, 5, 24, 'VIP 1', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2502, 5, 24, 'VIP 1', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2503, 5, 24, 'VIP 1', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 17:29:48', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2504, 5, 25, 'VIP 1', 'Snack 1', 'Food', 1, 50.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2505, 5, 25, 'VIP 1', 'Snack 2', 'Food', 1, 50.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2506, 5, 25, 'VIP 1', 'Snack 3', 'Food', 1, 195.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 79),
(2507, 5, 25, 'VIP 1', 'Lunch 1', 'Food', 1, 250.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 80),
(2508, 5, 25, 'VIP 1', 'Lunch 2', 'Food', 1, 230.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 80),
(2509, 5, 25, 'VIP 1', 'Lunch 3', 'Food', 1, 280.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 80),
(2510, 5, 25, 'VIP 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 78),
(2511, 5, 25, 'VIP 1', 'Coffee4', 'Food', 1, 150.00, '2026-03-30 17:30:07', 'DM020', 0, '2026-03-30', 10, 47, 78),
(2512, 5, 3, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-03-31 14:39:35', 'DM021', 0, '2026-03-31', 10, 47, 78),
(2513, 5, 3, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-03-31 14:39:35', 'DM021', 0, '2026-03-31', 10, 47, 78),
(2514, 5, 3, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 14:39:35', 'DM021', 0, '2026-03-31', 10, 47, 79),
(2515, 5, 3, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 14:39:35', 'DM022', 0, '2026-03-31', 10, 47, 79),
(2516, 5, 4, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-03-31 14:44:51', 'DM023', 0, '2026-03-31', 10, 47, 78),
(2517, 5, 4, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-03-31 14:44:51', 'DM023', 0, '2026-03-31', 10, 47, 78),
(2518, 5, 4, 'Table 3', 'Lunch 2', 'Food', 1, 230.00, '2026-03-31 14:44:51', 'DM023', 0, '2026-03-31', 10, 47, 80),
(2519, 5, 4, 'Table 3', 'Lunch 3', 'Food', 1, 280.00, '2026-03-31 14:44:51', 'DM023', 0, '2026-03-31', 10, 47, 80),
(2520, 5, 5, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 14:45:02', 'DM023', 0, '2026-03-31', 10, 47, 79),
(2521, 5, 5, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 14:45:02', 'DM023', 0, '2026-03-31', 10, 47, 79),
(2522, 5, 26, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-03-31 14:46:08', 'DM023', 0, '2026-03-31', 10, 47, 78),
(2523, 5, 26, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-03-31 14:46:08', 'DM023', 0, '2026-03-31', 10, 47, 78),
(2524, 5, 6, 'Table 2', 'Coffee4', 'Food', 1, 150.00, '2026-03-31 14:50:28', 'DM022', 0, '2026-03-31', 10, 47, 78),
(2525, 5, 6, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-03-31 14:50:28', 'DM022', 0, '2026-03-31', 10, 47, 78),
(2526, 5, 7, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 14:52:52', 'DM023', 0, '2026-03-31', 10, 47, 79),
(2527, 5, 7, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 14:52:52', 'DM023', 0, '2026-03-31', 10, 47, 79),
(2528, 5, 8, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 15:13:48', 'DM024', 0, '2026-03-31', 10, 47, 79),
(2529, 5, 8, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 15:13:48', 'DM024', 0, '2026-03-31', 10, 47, 79),
(2530, 5, 9, 'VIP 1', 'Lunch 3', 'Food', 1, 280.00, '2026-03-31 15:13:57', 'DM024', 0, '2026-03-31', 10, 47, 80),
(2531, 5, 9, 'VIP 1', 'Lunch 2', 'Food', 1, 230.00, '2026-03-31 15:13:57', 'DM024', 0, '2026-03-31', 10, 47, 80),
(2532, 5, 10, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 16:06:10', 'DM026', 0, '2026-03-31', 10, 47, 79),
(2533, 5, 11, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 16:06:51', 'DM027', 0, '2026-03-31', 10, 47, 79),
(2534, 5, 11, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 16:06:51', 'DM027', 0, '2026-03-31', 10, 47, 79),
(2535, 5, 11, 'Table 3', 'Snack 3', 'Food', 1, 195.00, '2026-03-31 16:06:51', 'DM027', 0, '2026-03-31', 10, 47, 79),
(2536, 5, 27, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-03-31 16:14:26', 'DM028', 0, '2026-03-31', 10, 47, 78),
(2537, 5, 27, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-03-31 16:14:26', 'DM028', 0, '2026-03-31', 10, 47, 78),
(2538, 5, 27, 'Table 3', 'Lunch 1', 'Food', 1, 250.00, '2026-03-31 16:14:26', 'DM028', 0, '2026-03-31', 10, 47, 80),
(2539, 5, 27, 'Table 3', 'Lunch 2', 'Food', 1, 230.00, '2026-03-31 16:14:26', 'DM028', 0, '2026-03-31', 10, 47, 80),
(2540, 5, 28, 'Table 1', 'Snack 1', 'Food', 1, 50.00, '2026-03-31 16:17:48', 'DM029', 0, '2026-03-31', 10, 47, 79),
(2541, 5, 28, 'Table 1', 'Snack 2', 'Food', 1, 50.00, '2026-03-31 16:17:48', 'DM029', 0, '2026-03-31', 10, 47, 79),
(2542, 5, 28, 'Table 1', 'Snack 3', 'Food', 1, 195.00, '2026-03-31 16:17:48', 'DM029', 0, '2026-03-31', 10, 47, 79),
(2543, 5, 29, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 78),
(2544, 5, 29, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 78),
(2545, 5, 29, 'Table 1', 'Coffee3', 'Food', 2, 120.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 78),
(2546, 5, 29, 'Table 1', 'Coffee4', 'Food', 2, 300.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 78),
(2547, 5, 29, 'Table 1', 'Lunch 1', 'Food', 1, 250.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 80),
(2548, 5, 29, 'Table 1', 'Lunch 2', 'Food', 3, 690.00, '2026-03-31 17:04:15', 'DM030', 0, '2026-03-31', 10, 47, 80),
(2549, 7, 2, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:12:42', 'JSL001', 0, '2026-04-03', 12, 50, 89),
(2550, 7, 2, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:27:46', 'JSL002', 0, '2026-04-03', 12, 50, 89),
(2551, 7, 3, 'Table 1', 'Test Food', 'Food', 1, 100.00, '2026-04-03 10:28:40', 'JSL002', 0, '2026-04-03', 12, 50, 89),
(2552, 7, 4, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:30:20', NULL, 1, '2026-04-03', 12, 50, 89),
(2553, 7, 5, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:31:11', NULL, 1, '2026-04-03', 12, 50, 89),
(2554, 7, 6, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:32:00', NULL, 1, '2026-04-03', 12, 50, 89),
(2555, 7, 7, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:32:41', NULL, 1, '2026-04-03', 12, 50, 89),
(2556, 7, 8, 'Table 1', 'Test Food', 'Food', 2, 200.00, '2026-04-03 10:33:35', NULL, 1, '2026-04-03', 12, 50, 89),
(2557, 5, 30, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-04-04 04:24:14', 'DM031', 0, '2026-04-01', 10, 47, 78),
(2558, 5, 30, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-04-04 04:24:14', 'DM031', 0, '2026-04-01', 10, 47, 78),
(2559, 5, 31, 'Table 1', 'Coffee4', 'Food', 1, 150.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 78),
(2560, 5, 31, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 78),
(2561, 5, 31, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 78),
(2562, 5, 31, 'Table 1', 'Lunch 1', 'Food', 1, 250.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 80),
(2563, 5, 31, 'Table 1', 'Lunch 2', 'Food', 1, 230.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 80),
(2564, 5, 31, 'Table 1', 'Lunch 3', 'Food', 1, 280.00, '2026-04-04 04:24:24', 'DM031', 0, '2026-04-01', 10, 47, 80),
(2565, 5, 32, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-04-05 04:27:08', 'DM038', 0, '2026-04-02', 10, 47, 78),
(2566, 5, 32, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-04-05 04:27:08', 'DM038', 0, '2026-04-02', 10, 47, 78),
(2567, 5, 32, 'Table 1', 'Snack 1', 'Food', 1, 50.00, '2026-04-05 04:27:08', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2568, 5, 32, 'Table 1', 'Snack 2', 'Food', 1, 50.00, '2026-04-05 04:27:08', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2569, 5, 33, 'Table 1', 'Snack 3', 'Food', 1, 195.00, '2026-04-05 04:28:03', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2570, 5, 33, 'Table 1', 'Snack 2', 'Food', 1, 50.00, '2026-04-05 04:28:03', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2571, 5, 33, 'Table 1', 'Snack 1', 'Food', 1, 50.00, '2026-04-05 04:28:03', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2572, 5, 34, 'Table 2', 'Snack 3', 'Food', 2, 390.00, '2026-04-05 04:40:39', 'DM032', 0, '2026-04-01', 10, 47, 79),
(2573, 5, 34, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-04-05 04:40:39', 'DM032', 0, '2026-04-01', 10, 47, 79),
(2574, 5, 34, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-04-05 04:40:39', 'DM032', 0, '2026-04-01', 10, 47, 79),
(2575, 5, 35, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-04-05 04:41:57', 'DM032', 0, '2026-04-01', 10, 47, 79),
(2576, 5, 35, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-04-05 04:41:57', 'DM032', 0, '2026-04-01', 10, 47, 79),
(2577, 5, 36, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-04-05 04:43:56', 'DM033', 0, '2026-04-01', 10, 47, 78),
(2578, 5, 36, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-05 04:43:56', 'DM033', 0, '2026-04-01', 10, 47, 78),
(2579, 5, 36, 'Table 3', 'Lunch 3', 'Food', 1, 280.00, '2026-04-05 04:43:56', 'DM033', 0, '2026-04-01', 10, 47, 80),
(2580, 5, 36, 'Table 3', 'Lunch 2', 'Food', 1, 230.00, '2026-04-05 04:43:56', 'DM033', 0, '2026-04-01', 10, 47, 80),
(2581, 5, 12, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-04-05 04:46:36', 'DM034', 0, '2026-04-01', 10, 47, 78),
(2582, 5, 12, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-04-05 04:46:36', 'DM034', 0, '2026-04-01', 10, 47, 78),
(2583, 5, 12, 'Table 2', 'Coffee3', 'Food', 2, 120.00, '2026-04-05 04:46:36', 'DM034', 0, '2026-04-01', 10, 47, 78),
(2584, 5, 13, 'Table 2', 'Coffee4', 'Food', 1, 150.00, '2026-04-05 04:46:43', 'DM034', 0, '2026-04-01', 10, 47, 78),
(2585, 5, 13, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-04-05 04:46:43', 'DM034', 0, '2026-04-01', 10, 47, 78),
(2586, 5, 13, 'Table 2', 'Lunch 1', 'Food', 1, 250.00, '2026-04-05 04:46:43', 'DM034', 0, '2026-04-01', 10, 47, 80),
(2587, 5, 13, 'Table 2', 'Lunch 2', 'Food', 1, 230.00, '2026-04-05 04:46:43', 'DM034', 0, '2026-04-01', 10, 47, 80),
(2588, 5, 14, 'VIP 1', 'Snack 1', 'Food', 1, 50.00, '2026-04-05 04:46:56', 'DM035', 0, '2026-04-01', 10, 47, 79),
(2589, 5, 14, 'VIP 1', 'Snack 2', 'Food', 1, 50.00, '2026-04-05 04:46:56', 'DM035', 0, '2026-04-01', 10, 47, 79),
(2590, 5, 14, 'VIP 1', 'Snack 3', 'Food', 1, 195.00, '2026-04-05 04:46:56', 'DM035', 0, '2026-04-01', 10, 47, 79),
(2591, 5, 37, 'Table 2', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-05 06:57:01', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2592, 5, 37, 'Table 2', 'มีเมนูแนะนำไหม', 'Food', 1, 120.00, '2026-04-05 06:57:01', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2593, 8, 2, 'Table 1', 'Test item', 'Food', 3, 300.00, '2026-04-05 07:41:26', 'SNR001', 0, '2026-04-05', 11, 55, 114),
(2594, 8, 3, 'Table 2', 'Test item', 'Food', 3, 300.00, '2026-04-05 07:46:07', 'SNR002', 0, '2026-04-05', 11, 55, 114),
(2595, 8, 4, 'Table 3', 'Test item', 'Food', 6, 600.00, '2026-04-05 07:46:22', 'SNR002', 0, '2026-04-05', 11, 55, 114),
(2596, 5, 38, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-04-06 07:44:31', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2597, 5, 38, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 07:44:31', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2598, 5, 38, 'Table 3', 'Coffee3', 'Food', 2, 120.00, '2026-04-06 07:44:31', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2599, 5, 38, 'Table 3', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-06 07:44:31', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2600, 5, 39, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 07:56:57', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2601, 5, 39, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-04-06 07:56:57', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2602, 5, 40, 'Table 3', 'Coffee4', 'Food', 1, 150.00, '2026-04-06 08:02:04', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2603, 5, 40, 'Table 3', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-06 08:02:04', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2604, 5, 41, 'Table 3', 'มีเมนูแนะนำไหม', 'Food', 1, 120.00, '2026-04-06 08:02:38', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2605, 5, 41, 'Table 3', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-06 08:02:38', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2606, 5, 41, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 08:02:38', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2607, 5, 42, 'Table 2', 'Snack 1', 'Food', 1, 50.00, '2026-04-06 10:12:56', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2608, 5, 42, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-04-06 10:12:56', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2609, 5, 43, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-04-06 10:17:42', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2610, 5, 43, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-04-06 10:17:42', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2611, 5, 44, 'Table 2', 'Snack 3', 'Food', 1, 195.00, '2026-04-06 10:20:28', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2612, 5, 44, 'Table 2', 'Snack 2', 'Food', 1, 50.00, '2026-04-06 10:20:28', 'DM036', 0, '2026-04-02', 10, 47, 79),
(2613, 5, 45, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-04-06 10:29:03', 'DM037', 0, '2026-04-02', 10, 47, 79),
(2614, 5, 45, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-04-06 10:29:03', 'DM037', 0, '2026-04-02', 10, 47, 79),
(2615, 5, 46, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 10:36:34', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2616, 5, 46, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-04-06 10:36:34', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2617, 5, 47, 'Table 3', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-06 10:40:49', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2618, 5, 47, 'Table 3', 'Coffee4', 'Food', 1, 150.00, '2026-04-06 10:40:49', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2619, 5, 47, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-04-06 10:40:49', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2620, 5, 48, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-04-06 10:41:26', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2621, 5, 49, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-04-06 10:44:41', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2622, 5, 49, 'Table 2', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 10:44:41', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2623, 5, 49, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-04-06 10:44:41', 'DM036', 0, '2026-04-02', 10, 47, 78),
(2624, 5, 50, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-04-06 10:46:15', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2625, 5, 50, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-06 10:46:15', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2626, 5, 51, 'Table 3', 'Lunch 3', 'Food', 1, 280.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 80),
(2627, 5, 51, 'Table 3', 'Lunch 1', 'Food', 1, 250.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 80),
(2628, 5, 51, 'Table 3', 'Lunch 2', 'Food', 1, 230.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 80),
(2629, 5, 51, 'Table 3', 'Snack 1', 'Food', 1, 50.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 79),
(2630, 5, 51, 'Table 3', 'Snack 2', 'Food', 1, 50.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 79),
(2631, 5, 51, 'Table 3', 'Snack 3', 'Food', 1, 195.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 79),
(2632, 5, 51, 'Table 3', 'Coffee4', 'Food', 1, 150.00, '2026-04-06 10:50:26', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2633, 8, 5, 'Table 1', 'chamomile tea', 'Food', 1, 115.00, '2026-04-08 13:24:43', 'SNR005', 0, '2026-04-06', 11, 53, 107),
(2634, 5, 15, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-04-09 08:00:20', 'DM038', 0, '2026-04-02', 10, 47, 78),
(2635, 5, 15, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-04-09 08:00:20', 'DM038', 0, '2026-04-02', 10, 47, 78),
(2636, 5, 15, 'Table 1', 'Snack 1', 'Food', 1, 50.00, '2026-04-09 08:00:20', 'DM038', 0, '2026-04-02', 10, 47, 79),
(2637, 8, 6, 'Table 2', 'Singha (small)', 'Food', 2, 140.00, '2026-04-10 06:31:54', 'SNR010', 0, '2026-04-06', 11, 52, 98),
(2638, 8, 7, 'Table 2', 'Fresh Fruit', 'Food', 1, 99.00, '2026-04-10 06:37:18', 'SNR010', 0, '2026-04-06', 11, 55, 114),
(2639, 8, 8, 'Table 1', 'Espresso', 'Food', 1, 50.00, '2026-04-12 04:27:07', 'SNR009', 0, '2026-04-06', 11, 53, 106),
(2640, 8, 8, 'Table 1', 'Café Latte', 'Food', 1, 70.00, '2026-04-12 04:27:07', 'SNR009', 0, '2026-04-06', 11, 53, 106),
(2641, 8, 9, 'Take Away', 'ABSOLUTE', 'Food', 1, 250.00, '2026-04-12 04:30:10', 'SNR011', 0, '2026-04-06', 11, 52, 97),
(2642, 8, 9, 'Take Away', 'BOMBAY SAPPHIRE', 'Food', 1, 300.00, '2026-04-12 04:30:10', 'SNR011', 0, '2026-04-06', 11, 52, 97),
(2643, 8, 9, 'Table 1', 'Espresso', 'Food', 1, 50.00, '2026-04-12 04:34:48', 'SNR009', 0, '2026-04-06', 11, 53, 106),
(2644, 8, 10, 'Table 1', 'chamomile tea', 'Food', 1, 115.00, '2026-04-12 04:36:08', 'SNR009', 0, '2026-04-06', 11, 53, 107),
(2645, 5, 52, 'Table 3', 'Coffee1', 'Food', 1, 120.00, '2026-04-12 04:48:02', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2646, 5, 52, 'Table 3', 'Coffee2', 'Food', 1, 130.00, '2026-04-12 04:48:02', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2647, 5, 52, 'Table 3', 'Coffee3', 'Food', 1, 60.00, '2026-04-12 04:48:02', 'DM037', 0, '2026-04-02', 10, 47, 78),
(2648, 8, 11, 'Table 1', 'ABSOLUTE', 'Food', 1, 250.00, '2026-04-12 04:52:32', 'SNR009', 0, '2026-04-06', 11, 52, 97),
(2649, 8, 11, 'Table 1', 'SIERRA', 'Food', 1, 250.00, '2026-04-12 04:52:32', 'SNR009', 0, '2026-04-06', 11, 52, 97),
(2650, 8, 11, 'Table 1', 'HENDRICKS', 'Food', 1, 350.00, '2026-04-12 04:52:32', 'SNR009', 0, '2026-04-06', 11, 52, 97),
(2651, 8, 12, 'Table 1', 'HENDRICKS', 'Food', 1, 350.00, '2026-04-12 04:52:41', 'SNR009', 0, '2026-04-06', 11, 52, 97),
(2652, 5, 16, 'Table 1', 'เมนูแนะนำ', 'Food', 1, 160.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2653, 5, 16, 'Table 1', 'มีเมนูแนะนำไหม', 'Food', 1, 120.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2654, 5, 16, 'Table 1', 'Coffee2', 'Food', 6, 780.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2655, 5, 16, 'Table 1', 'Coffee1', 'Food', 2, 240.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2656, 5, 16, 'Table 1', 'Coffee4', 'Food', 4, 600.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2657, 5, 16, 'Table 1', 'Coffee3', 'Food', 2, 120.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 78),
(2658, 5, 16, 'Table 1', 'Snack 2', 'Food', 1, 50.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 79),
(2659, 5, 16, 'Table 1', 'Snack 3', 'Food', 1, 195.00, '2026-04-12 06:57:42', 'DM039', 0, '2026-04-02', 10, 47, 79),
(2660, 5, 17, 'Table 1', 'Lunch 1', 'Food', 2, 500.00, '2026-04-12 07:04:32', 'DM039', 0, '2026-04-02', 10, 47, 80),
(2661, 5, 17, 'Table 1', 'Lunch 2', 'Food', 3, 690.00, '2026-04-12 07:04:32', 'DM039', 0, '2026-04-02', 10, 47, 80),
(2662, 5, 18, 'Table 2', 'Coffee1', 'Food', 1, 120.00, '2026-04-13 07:21:52', 'DM040', 0, '2026-04-03', 10, 47, 78),
(2663, 5, 18, 'Table 2', 'Coffee2', 'Food', 3, 390.00, '2026-04-13 07:21:52', 'DM040', 0, '2026-04-03', 10, 47, 78),
(2664, 5, 18, 'Table 2', 'Coffee3', 'Food', 1, 60.00, '2026-04-13 07:21:52', 'DM040', 0, '2026-04-03', 10, 47, 78),
(2665, 9, 2, 'Room 201', 'Room201', 'Food', 1, 2400.00, '2026-04-18 06:57:32', 'WS001', 0, '2026-04-18', 14, 58, 137),
(2666, 9, 3, 'Room 302', 'Room302', 'Food', 1, 800.00, '2026-04-18 06:58:35', 'WS002', 0, '2026-04-18', 14, 58, 136),
(2667, 9, 4, 'Room 303', 'Room303', 'Food', 1, 950.00, '2026-04-18 06:59:26', 'WS004', 0, '2026-04-18', 14, 58, 135),
(2668, 9, 5, 'Room 304', 'Room304', 'Food', 1, 950.00, '2026-04-18 06:59:45', 'WS003', 0, '2026-04-18', 14, 58, 135),
(2669, 9, 6, 'Room 305', 'Room305', 'Food', 1, 800.00, '2026-04-18 07:00:25', 'WS005', 0, '2026-04-18', 14, 58, 136),
(2670, 9, 7, 'Room 403', 'Room402', 'Food', 1, 800.00, '2026-04-18 07:04:26', 'WS006', 0, '2026-04-18', 14, 58, 136),
(2671, 9, 8, 'Room 304', 'Room304', 'Food', 1, 950.00, '2026-04-18 07:36:38', 'WS007', 0, '2026-04-18', 14, 58, 135),
(2672, 9, 9, 'Room 402', 'Room402', 'Food', 1, 800.00, '2026-04-18 08:05:14', 'WS013', 0, '2026-05-02', 14, 58, 136),
(2673, 9, 10, 'Room 302', 'Room302', 'Food', 1, 800.00, '2026-04-19 06:37:31', 'WS008', 0, '2026-04-19', 14, 58, 136),
(2674, 9, 11, 'Room 302', 'Chang (small)', 'Food', 3, 195.00, '2026-04-19 06:38:33', 'WS008', 0, '2026-04-19', 14, 57, 134),
(2675, 9, 11, 'Room 302', 'Heineken (Small)', 'Food', 1, 80.00, '2026-04-19 06:38:33', 'WS008', 0, '2026-04-19', 14, 57, 134),
(2676, 9, 11, 'Room 302', 'Masala papad', 'Food', 2, 100.00, '2026-04-19 06:38:33', 'WS008', 0, '2026-04-19', 14, 56, 130),
(2677, 9, 12, 'Grab 1', 'water', 'Food', 1, 15.00, '2026-04-19 07:13:09', 'WS014', 0, '2026-05-02', 13, 56, 130),
(2678, 9, 13, 'Grab 1', 'water', 'Food', 1, 15.00, '2026-04-19 07:13:35', 'WS014', 0, '2026-05-02', 13, 56, 130),
(2679, 7, 3, 'Table 2', 'Chicken tikka masala', 'Food', 1, 300.00, '2026-04-23 12:13:43', 'JSL003', 0, '2026-04-23', 12, 49, 123),
(2680, 7, 3, 'Table 2', 'lamb tikka masala', 'Food', 1, 450.00, '2026-04-23 12:13:43', 'JSL003', 0, '2026-04-23', 12, 49, 123),
(2681, 7, 3, 'Table 2', 'mutton tikka masala', 'Food', 1, 450.00, '2026-04-23 12:13:43', 'JSL003', 0, '2026-04-23', 12, 49, 123),
(2682, 9, 14, 'Room 302', 'Room302', 'Food', 1, 800.00, '2026-04-26 09:36:41', 'WS009', 0, '2026-04-26', 14, 58, 136),
(2683, 9, 14, 'Room 302', 'Maggi', 'Food', 1, 80.00, '2026-04-26 09:36:41', 'WS009', 0, '2026-04-26', 14, 56, 130),
(2684, 9, 15, 'Table 10', 'water', 'Food', 1, 15.00, '2026-04-26 09:40:10', 'WS012', 0, '2026-05-02', 13, 56, 130),
(2685, 9, 16, 'Table 3', 'Chang (Big)', 'Food', 6, 540.00, '2026-04-27 11:57:26', 'WS010', 0, '2026-04-27', 13, 57, 134),
(2686, 9, 16, 'Table 3', 'Singha (Big)', 'Food', 2, 200.00, '2026-04-27 11:57:26', 'WS010', 0, '2026-04-27', 13, 57, 134),
(2687, 9, 16, 'Table 3', 'Singha (small)', 'Food', 2, 140.00, '2026-04-27 11:57:26', 'WS010', 0, '2026-04-27', 13, 57, 134),
(2688, 9, 16, 'Table 3', 'Chang (small)', 'Food', 1, 65.00, '2026-04-27 11:57:26', 'WS010', 0, '2026-04-27', 13, 57, 134),
(2689, 9, 17, 'Table 4', 'Chang (Big)', 'Food', 8, 720.00, '2026-04-27 12:17:15', 'WS011', 0, '2026-04-27', 13, 57, 134),
(2690, 9, 17, 'Table 4', 'Rosted papad', 'Food', 1, 30.00, '2026-04-27 12:17:15', 'WS011', 0, '2026-04-27', 13, 56, 130),
(2691, 7, 4, 'Table 2', 'Chilli Chicken', 'Food', 1, 350.00, '2026-04-28 07:24:36', 'JSL004', 0, '2026-04-28', 12, 49, 115),
(2692, 7, 4, 'Table 2', 'Honey Chilli Potato', 'Food', 1, 220.00, '2026-04-28 07:24:36', 'JSL004', 0, '2026-04-28', 12, 49, 115),
(2693, 9, 18, 'Room 301', 'Room301', 'Food', 1, 800.00, '2026-05-02 11:45:57', 'WS018', 0, '2026-05-05', 14, 58, 136),
(2694, 9, 19, 'Room 303', 'Room303', 'Food', 1, 950.00, '2026-05-02 11:51:18', 'WS019', 0, '2026-05-05', 14, 58, 135),
(2695, 9, 20, 'Room 401', 'Room401', 'Food', 1, 800.00, '2026-05-02 12:07:19', 'WS015', 0, '2026-05-02', 14, 58, 136),
(2696, 9, 21, 'Table 1', 'Chang (Big)', 'Food', 3, 270.00, '2026-05-02 12:32:35', 'WS016', 0, '2026-05-02', 13, 57, 134),
(2697, 9, 22, 'Table 2', 'Chang (Big)', 'Food', 20, 1800.00, '2026-05-02 12:49:17', 'WS017', 0, '2026-05-02', 13, 57, 134),
(2698, 9, 22, 'Table 2', 'Singha (Big)', 'Food', 1, 100.00, '2026-05-02 12:49:17', 'WS017', 0, '2026-05-02', 13, 57, 134),
(2699, 9, 23, 'Room 305', 'Room305', 'Food', 1, 800.00, '2026-05-05 12:06:58', 'WS020', 0, '2026-05-05', 14, 58, 136),
(2700, 8, 13, 'Table 1', 'Banana Nutella Milkshake', 'Food', 1, 85.00, '2026-05-08 07:28:47', 'SNR012', 0, '2026-04-06', 11, 53, 109),
(2701, 8, 14, 'Table 1', 'Espresso', 'Food', 1, 50.00, '2026-05-09 13:54:43', 'SNR013', 0, '2026-05-10', 11, 53, 106),
(2702, 8, 15, 'Table 1', 'Minted Watermelon', 'Food', 2, 150.00, '2026-05-10 08:52:57', 'SNR013', 0, '2026-05-10', 11, 53, 109),
(2703, 8, 16, 'Table 1', 'Minted Watermelon', 'Food', 2, 150.00, '2026-05-10 09:01:43', 'SNR013', 0, '2026-05-10', 11, 53, 109),
(2704, 8, 17, 'Table 1', 'Minted Watermelon', 'Food', 2, 150.00, '2026-05-10 09:08:22', 'SNR014', 0, '2026-05-10', 11, 53, 109),
(2705, 8, 18, 'Table 2', 'Minted Watermelon', 'Food', 2, 150.00, '2026-05-10 09:08:51', 'SNR015', 0, '2026-05-10', 11, 53, 109),
(2706, 8, 19, 'Table 1', 'Strawberry Daphne ', 'Food', 1, 85.00, '2026-05-10 10:19:07', 'SNR017', 0, '2026-05-10', 11, 53, 109),
(2707, 8, 20, 'Table 3', 'Café Mocha  & Matcha latte', 'Food', 1, 75.00, '2026-05-10 10:21:58', 'SNR018', 0, '2026-05-10', 11, 53, 106),
(2708, 8, 21, 'Table 4', 'POPPIA TOD', 'Food', 1, 99.00, '2026-05-10 11:02:59', 'SNR019', 0, '2026-05-10', 11, 54, 112),
(2709, 8, 21, 'Table 4', 'Cappuccino', 'Food', 1, 70.00, '2026-05-10 11:02:59', 'SNR019', 0, '2026-05-10', 11, 53, 106),
(2710, 8, 21, 'Table 4', 'Minted Watermelon', 'Food', 1, 75.00, '2026-05-10 11:02:59', 'SNR019', 0, '2026-05-10', 11, 53, 109),
(2711, 5, 53, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-05-10 13:59:57', 'DM041', 0, '2026-04-04', 10, 47, 78),
(2712, 5, 53, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-05-10 13:59:57', 'DM041', 0, '2026-04-04', 10, 47, 78),
(2713, 5, 53, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-05-10 13:59:57', 'DM041', 0, '2026-04-04', 10, 47, 78),
(2714, 5, 54, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-05-10 14:05:34', 'DM041', 0, '2026-04-04', 10, 47, 78),
(2715, 5, 54, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-05-10 14:05:34', 'DM041', 0, '2026-04-04', 10, 47, 78),
(2716, 5, 55, 'Table 1', 'Coffee1', 'Food', 1, 120.00, '2026-05-10 14:06:31', 'DM042', 0, '2026-04-04', 10, 47, 78),
(2717, 5, 55, 'Table 1', 'Coffee2', 'Food', 1, 130.00, '2026-05-10 14:06:31', 'DM042', 0, '2026-04-04', 10, 47, 78),
(2718, 5, 55, 'Table 1', 'Coffee3', 'Food', 1, 60.00, '2026-05-10 14:06:31', 'DM042', 0, '2026-04-04', 10, 47, 78),
(2719, 8, 22, 'Table 7', 'Crystal Water', 'Food', 2, 50.00, '2026-05-10 14:42:11', 'SNR020', 0, '2026-05-10', 11, 53, 138),
(2720, 8, 22, 'Table 7', 'Singha (Big)', 'Food', 4, 400.00, '2026-05-10 14:42:11', 'SNR020', 0, '2026-05-10', 11, 52, 98),
(2721, 8, 22, 'Table 7', 'KAO PAD MOO / GOONG', 'Food', 2, 320.00, '2026-05-10 14:42:11', 'SNR020', 0, '2026-05-10', 11, 54, 112),
(2722, 8, 23, 'Table 7', 'Singha (Big)', 'Food', 1, 100.00, '2026-05-10 14:51:49', 'SNR020', 0, '2026-05-10', 11, 52, 98),
(2723, 8, 24, 'Table 7', 'Singha (Big)', 'Food', 1, 100.00, '2026-05-10 15:41:03', 'SNR020', 0, '2026-05-10', 11, 52, 98),
(2724, 8, 25, 'Table 8', 'Singha (Big)', 'Food', 3, 300.00, '2026-05-10 16:19:53', 'SNR021', 0, '2026-05-10', 11, 52, 98),
(2725, 8, 25, 'Table 8', 'CHICKEN WING', 'Food', 1, 100.00, '2026-05-10 16:19:53', 'SNR021', 0, '2026-05-10', 11, 54, 112),
(2726, 8, 26, 'Table 8', 'CHICKEN WING', 'Food', 1, 100.00, '2026-05-10 16:55:06', 'SNR022', 0, '2026-05-10', 11, 54, 112),
(2727, 8, 26, 'Table 8', 'FRENCH FRIES', 'Food', 1, 89.00, '2026-05-10 16:55:06', 'SNR022', 0, '2026-05-10', 11, 54, 110),
(2728, 8, 26, 'Table 8', 'LAMB KEBAB WITH SAFFRON RICE', 'Food', 1, 290.00, '2026-05-10 16:55:06', 'SNR022', 0, '2026-05-10', 11, 54, 110),
(2729, 8, 27, 'Table 2', 'KHAI JIEW MOO SUB', 'Food', 1, 100.00, '2026-05-11 02:32:10', 'SNR023', 0, '2026-05-10', 11, 54, 112),
(2730, 8, 27, 'Table 2', 'KAO', 'Food', 1, 30.00, '2026-05-11 02:32:10', 'SNR023', 0, '2026-05-10', 11, 54, 112),
(2731, 8, 27, 'Table 2', 'Mango Lassi ', 'Food', 1, 75.00, '2026-05-11 02:32:10', 'SNR023', 0, '2026-05-10', 11, 53, 109),
(2732, 8, 28, 'Table 3', 'Café Latte', 'Food', 1, 70.00, '2026-05-11 04:35:25', 'SNR024', 0, '2026-05-10', 11, 53, 106),
(2733, 5, 56, 'Table 1', 'Coffee1', NULL, 1, 120.00, '2026-05-11 07:45:03', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2734, 5, 56, 'Table 1', 'Coffee2', NULL, 1, 130.00, '2026-05-11 07:45:03', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2735, 5, 56, 'Table 1', 'Coffee2', NULL, 1, 130.00, '2026-05-11 07:45:03', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2736, 5, 56, 'Table 1', 'Coffee3', NULL, 1, 60.00, '2026-05-11 07:45:03', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2737, 5, 56, 'Table 1', 'Coffee3', NULL, 1, 60.00, '2026-05-11 07:45:03', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2738, 5, 57, 'Table 2', 'Black Label', NULL, 2, 400.00, '2026-05-11 08:09:16', 'DM043', 0, '2026-04-05', 10, NULL, NULL),
(2739, 5, 57, 'Table 2', 'Black Label', NULL, 1, 400.00, '2026-05-11 08:09:16', 'DM043', 0, '2026-04-05', 10, NULL, NULL),
(2740, 5, 58, 'Table 2', 'Black Label', NULL, 1, 400.00, '2026-05-11 08:22:15', 'DM044', 0, '2026-04-05', 10, NULL, NULL),
(2741, 5, 58, 'Table 2', 'Black Label', NULL, 2, 400.00, '2026-05-11 08:22:15', 'DM044', 0, '2026-04-05', 10, NULL, NULL),
(2742, 5, 59, 'Table 2', 'Black Label', NULL, 1, 400.00, '2026-05-11 08:26:14', 'DM045', 0, '2026-04-05', 10, NULL, NULL),
(2743, 5, 60, 'Table 2', 'Black Label', NULL, 1, 400.00, '2026-05-11 08:27:13', 'DM045', 0, '2026-04-05', 10, NULL, NULL),
(2744, 5, 61, 'Table 2', 'Black Label', NULL, 1, 400.00, '2026-05-11 08:31:47', 'DM045', 0, '2026-04-05', 10, NULL, NULL),
(2745, 5, 61, 'Table 2', 'Black Label', NULL, 1, 200.00, '2026-05-11 08:31:47', 'DM045', 0, '2026-04-05', 10, NULL, NULL),
(2746, 5, 62, 'Table 2', 'Black Label', NULL, 2, 800.00, '2026-05-11 08:43:04', 'DM046', 0, '2026-04-05', 10, NULL, NULL),
(2747, 5, 63, 'Table 2', 'Chivas 12Yr', NULL, 2, 300.00, '2026-05-11 08:56:41', 'DM047', 0, '2026-04-05', 10, NULL, NULL),
(2748, 5, 64, 'Table 3', 'Chivas 12Yr', NULL, 1, 300.00, '2026-05-11 09:00:34', 'DM048', 0, '2026-04-05', 10, NULL, NULL),
(2749, 5, 65, 'Table 2', 'Chivas 12Yr', NULL, 3, 450.00, '2026-05-11 09:15:10', 'DM049', 0, '2026-04-05', 10, NULL, NULL),
(2750, 5, 66, 'Table 3', 'Chivas 12Yr', NULL, 2, 600.00, '2026-05-11 09:15:56', 'DM050', 0, '2026-04-05', 10, NULL, NULL),
(2751, 5, 67, 'Table 2', 'Jack Daniel', NULL, 1, 50.00, '2026-05-11 11:19:43', 'DM051', 0, '2026-04-05', 10, NULL, NULL),
(2752, 5, 68, 'Table 1', 'Coffee2', NULL, 1, 130.00, '2026-05-12 06:46:35', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2753, 5, 68, 'Table 1', 'Snack 2', NULL, 1, 50.00, '2026-05-12 06:46:35', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2754, 5, 68, 'Table 1', 'Coffee3', NULL, 2, 120.00, '2026-05-12 06:46:35', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2755, 5, 68, 'Table 1', 'Coffee4', NULL, 1, 150.00, '2026-05-12 06:46:35', 'DM053', 0, '2026-04-05', 10, NULL, NULL),
(2756, 5, 69, 'Table 3', 'Gold Label', NULL, 1, 600.00, '2026-05-12 08:27:20', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2757, 5, 69, 'Table 3', 'Coffee3', NULL, 1, 60.00, '2026-05-12 08:27:20', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2758, 5, 69, 'Table 3', 'Snack 2', NULL, 3, 150.00, '2026-05-12 08:27:20', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2759, 5, 69, 'Table 3', 'Coffee4', NULL, 2, 300.00, '2026-05-12 08:27:20', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2760, 5, 70, 'Table 3', 'Coffee2', NULL, 1, 130.00, '2026-05-12 08:29:52', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2761, 5, 70, 'Table 3', 'Coffee3', NULL, 1, 60.00, '2026-05-12 08:29:52', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2762, 5, 70, 'Table 3', 'Snack 2', NULL, 1, 50.00, '2026-05-12 08:29:52', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2763, 5, 70, 'Table 3', 'Lunch 1', NULL, 1, 250.00, '2026-05-12 08:29:52', 'DM054', 0, '2026-04-05', 10, NULL, NULL),
(2764, 5, 71, 'Table 3', 'Coffee1', NULL, 1, 120.00, '2026-05-12 10:42:32', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2765, 5, 71, 'Table 3', 'Snack 1', NULL, 1, 50.00, '2026-05-12 10:42:32', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2766, 5, 71, 'Table 3', 'Snack 2', NULL, 1, 50.00, '2026-05-12 10:42:32', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2767, 5, 72, 'VIP 1', 'Chivas 12Yr', NULL, 1, 150.00, '2026-05-12 10:42:56', 'DM055', 0, '2026-04-05', 10, NULL, NULL),
(2768, 5, 72, 'VIP 1', 'Gold Label', NULL, 1, 600.00, '2026-05-12 10:42:56', 'DM055', 0, '2026-04-05', 10, NULL, NULL),
(2769, 5, 72, 'VIP 1', 'Jack Daniel', NULL, 2, 200.00, '2026-05-12 10:42:56', 'DM055', 0, '2026-04-05', 10, NULL, NULL),
(2770, 5, 73, 'VIP 1', 'Coffee1', NULL, 1, 120.00, '2026-05-12 10:45:31', 'DM057', 0, '2026-04-05', 10, NULL, NULL),
(2771, 5, 73, 'VIP 1', 'Snack 1', NULL, 1, 50.00, '2026-05-12 10:45:31', 'DM057', 0, '2026-04-05', 10, NULL, NULL),
(2772, 5, 73, 'VIP 1', 'Snack 3', NULL, 1, 195.00, '2026-05-12 10:45:31', 'DM057', 0, '2026-04-05', 10, NULL, NULL),
(2773, 5, 73, 'VIP 1', 'เมนูแนะนำ', NULL, 1, 160.00, '2026-05-12 10:45:31', 'DM057', 0, '2026-04-05', 10, NULL, NULL),
(2774, 5, 73, 'VIP 1', 'มีเมนูแนะนำไหม', NULL, 2, 240.00, '2026-05-12 10:45:31', 'DM057', 0, '2026-04-05', 10, NULL, NULL),
(2775, 5, 74, 'Table 3', 'Gold Label', NULL, 1, 0.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2776, 5, 74, 'Table 3', 'Chang 620ML', NULL, 1, 120.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2777, 5, 74, 'Table 3', 'Jack Daniel', NULL, 2, 200.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2778, 5, 74, 'Table 3', 'Gold Label', NULL, 1, 600.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2779, 5, 74, 'Table 3', 'มีเมนูแนะนำไหม', NULL, 3, 360.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2780, 5, 74, 'Table 3', 'Lunch 3', NULL, 4, 1120.00, '2026-05-12 10:46:22', 'DM056', 0, '2026-04-05', 10, NULL, NULL),
(2781, 5, 75, 'VIP 2', 'Coffee4', NULL, 4, 600.00, '2026-05-12 10:47:54', 'DM058', 0, '2026-04-05', 10, NULL, NULL),
(2782, 5, 75, 'VIP 2', 'Snack 3', NULL, 1, 195.00, '2026-05-12 10:47:54', 'DM058', 0, '2026-04-05', 10, NULL, NULL),
(2783, 5, 76, 'VIP 1', 'Chivas 12Yr', NULL, 1, 500.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2784, 5, 76, 'VIP 1', 'Chang 620ML', NULL, 1, 120.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2785, 5, 76, 'VIP 1', 'Gold Label', NULL, 1, 600.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2786, 5, 76, 'VIP 1', 'Coffee3', NULL, 1, 60.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2787, 5, 76, 'VIP 1', 'Snack 2', NULL, 1, 50.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2788, 5, 76, 'VIP 1', 'Snack 3', NULL, 1, 195.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2789, 5, 76, 'VIP 1', 'เมนูแนะนำ', NULL, 1, 160.00, '2026-05-12 10:53:22', 'DM059', 0, '2026-04-05', 10, NULL, NULL),
(2790, 5, 77, 'VIP 3', 'Coffee1', NULL, 1, 120.00, '2026-05-12 11:01:12', 'DM061', 0, '2026-04-05', 10, NULL, NULL),
(2791, 5, 77, 'VIP 3', 'Snack 1', NULL, 1, 50.00, '2026-05-12 11:01:12', 'DM061', 0, '2026-04-05', 10, NULL, NULL),
(2792, 5, 77, 'VIP 3', 'Snack 2', NULL, 1, 50.00, '2026-05-12 11:01:12', 'DM061', 0, '2026-04-05', 10, NULL, NULL),
(2793, 5, 77, 'VIP 3', 'Coffee3', NULL, 1, 60.00, '2026-05-12 11:01:12', 'DM061', 0, '2026-04-05', 10, NULL, NULL),
(2794, 5, 78, 'VIP 1', 'Lunch 2', NULL, 1, 230.00, '2026-05-12 11:04:46', 'DM060', 0, '2026-04-05', 10, NULL, NULL),
(2795, 5, 78, 'VIP 1', 'Lunch 1', NULL, 1, 250.00, '2026-05-12 11:04:46', 'DM060', 0, '2026-04-05', 10, NULL, NULL),
(2796, 5, 78, 'VIP 1', 'มีเมนูแนะนำไหม', NULL, 1, 120.00, '2026-05-12 11:04:46', 'DM060', 0, '2026-04-05', 10, NULL, NULL),
(2797, 5, 79, 'Table 2', 'Coffee2', NULL, 1, 130.00, '2026-05-12 11:07:10', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2798, 5, 79, 'Table 2', 'Snack 2', NULL, 1, 50.00, '2026-05-12 11:07:10', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2799, 5, 79, 'Table 2', 'Snack 3', NULL, 1, 195.00, '2026-05-12 11:07:10', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2800, 5, 79, 'Table 2', 'Coffee4', NULL, 1, 150.00, '2026-05-12 11:07:10', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2801, 5, 79, 'Table 2', 'Lunch 1', NULL, 1, 250.00, '2026-05-12 11:07:10', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2802, 5, 80, 'Table 3', 'Coffee3', NULL, 1, 60.00, '2026-05-12 11:27:03', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2803, 5, 80, 'Table 3', 'Coffee4', NULL, 3, 450.00, '2026-05-12 11:27:03', NULL, 1, '2026-04-05', 10, NULL, NULL),
(2804, 5, 81, 'VIP 2', 'Coffee3', NULL, 2, 120.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2805, 5, 81, 'VIP 2', 'Coffee4', NULL, 2, 300.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2806, 5, 81, 'VIP 2', 'Lunch 1', NULL, 1, 250.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2807, 5, 81, 'VIP 2', 'Lunch 2', NULL, 1, 230.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2808, 5, 81, 'VIP 2', 'มีเมนูแนะนำไหม', NULL, 1, 120.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2809, 5, 81, 'VIP 2', 'เมนูแนะนำ', NULL, 1, 160.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2810, 5, 81, 'VIP 2', 'Snack 1', NULL, 1, 50.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2811, 5, 81, 'VIP 2', 'Lunch 3', NULL, 2, 560.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL),
(2812, 5, 81, 'VIP 2', 'LAYS', NULL, 2, 50.00, '2026-05-12 11:31:00', 'DM062', 0, '2026-04-05', 10, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items_gst`
--

DROP TABLE IF EXISTS `order_items_gst`;
CREATE TABLE IF NOT EXISTS `order_items_gst` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` decimal(10,0) NOT NULL,
  `uom` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `rate` decimal(10,2) NOT NULL,
  `cgst` decimal(10,2) NOT NULL,
  `sgst` decimal(10,2) NOT NULL,
  `igst` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `paymentoptions`
--

DROP TABLE IF EXISTS `paymentoptions`;
CREATE TABLE IF NOT EXISTS `paymentoptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `name` varchar(233) COLLATE utf8mb4_general_ci NOT NULL,
  `isactive` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_payment_methods_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_records`
--

DROP TABLE IF EXISTS `payment_records`;
CREATE TABLE IF NOT EXISTS `payment_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `subscription_id` int DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
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
  KEY `idx_shop_status_due` (`shop_id`,`payment_status`,`due_date`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payment records for subscriptions';

--
-- Dumping data for table `payment_records`
--

INSERT INTO `payment_records` (`id`, `shop_id`, `subscription_id`, `amount`, `currency`, `payment_method`, `payment_status`, `transaction_id`, `due_date`, `paid_date`, `invoice_url`, `notes`, `payment_type`, `reference_number`, `created_by`, `created_at`, `updated_at`) VALUES
(12, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2027-03-31', '2026-03-28', NULL, 'Auto-created while assigning subscription plan', 'YEARLY', NULL, NULL, '2026-03-28 19:33:20', '2026-03-28 19:46:22'),
(13, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2028-03-31', '2026-03-28', NULL, 'Auto-generated next cycle after payment #12 completion', 'YEARLY', NULL, NULL, '2026-03-28 19:46:23', '2026-03-28 19:46:28'),
(14, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2029-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #13 completion', 'YEARLY', NULL, NULL, '2026-03-28 19:46:28', '2026-05-10 09:14:46'),
(15, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2026-03-31', '2026-03-31', NULL, 'Auto-created while assigning subscription plan', 'MONTHLY', NULL, NULL, '2026-03-28 19:47:13', '2026-03-31 06:48:07'),
(16, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2026-05-01', '2026-05-10', NULL, 'Auto-generated next cycle after payment #15 completion', 'MONTHLY', NULL, NULL, '2026-03-31 06:48:07', '2026-05-10 09:19:37'),
(17, 7, 4, 500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2026-04-04', '2026-04-04', NULL, 'Auto-created while assigning subscription plan', 'MONTHLY', NULL, NULL, '2026-04-04 06:36:23', '2026-04-04 06:37:21'),
(18, 7, 4, 500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2026-05-04', NULL, NULL, 'Auto-generated next cycle after payment #17 completion', 'MONTHLY', NULL, NULL, '2026-04-04 06:37:21', '2026-04-04 06:37:21'),
(19, 9, NULL, 500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2026-04-20', NULL, NULL, 'Starting From 20 April 2026', 'MONTHLY', NULL, NULL, '2026-04-17 05:42:31', '2026-04-17 05:42:31'),
(20, 9, 5, 500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2026-04-20', '2026-04-23', NULL, 'Auto-created while assigning subscription plan', 'MONTHLY', NULL, NULL, '2026-04-17 05:48:44', '2026-04-23 15:35:15'),
(21, 8, 6, 500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2026-04-20', '2026-05-08', NULL, 'Auto-created while assigning subscription plan', 'MONTHLY', NULL, NULL, '2026-04-17 05:50:16', '2026-05-08 07:22:46'),
(22, 9, 5, 500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2026-05-20', NULL, NULL, 'Auto-generated next cycle after payment #20 completion', 'MONTHLY', NULL, NULL, '2026-04-23 15:35:15', '2026-04-23 15:35:15'),
(23, 8, 6, 500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2026-05-20', NULL, NULL, 'Auto-generated next cycle after payment #21 completion', 'MONTHLY', NULL, NULL, '2026-05-08 07:22:46', '2026-05-08 07:22:46'),
(24, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2030-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #14 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:14:46', '2026-05-10 09:14:52'),
(25, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2031-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #24 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:14:52', '2026-05-10 09:15:00'),
(26, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2032-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #25 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:15:00', '2026-05-10 09:15:07'),
(27, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2033-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #26 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:15:07', '2026-05-10 09:15:21'),
(28, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2034-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #27 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:15:21', '2026-05-10 09:16:01'),
(29, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2035-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #28 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:16:01', '2026-05-10 09:17:00'),
(30, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2034-06-30', '2026-05-10', NULL, 'Auto-created while assigning subscription plan', 'MONTHLY', NULL, NULL, '2026-05-10 09:16:25', '2026-05-10 09:17:09'),
(31, 5, 3, 100.00, 'USD', 'CASH', 'PENDING', NULL, '2034-06-30', NULL, NULL, NULL, 'MONTHLY', NULL, NULL, '2026-05-10 09:16:46', '2026-05-10 09:16:46'),
(32, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2036-03-31', '2026-05-10', NULL, 'Auto-generated next cycle after payment #29 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:17:00', '2026-05-10 09:17:06'),
(33, 5, 3, 4800.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2037-03-31', NULL, NULL, 'Auto-generated next cycle after payment #32 completion', 'YEARLY', NULL, NULL, '2026-05-10 09:17:06', '2026-05-10 09:17:06'),
(34, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'COMPLETED', NULL, '2034-07-30', '2026-05-10', NULL, 'Auto-generated next cycle after payment #30 completion', 'MONTHLY', NULL, NULL, '2026-05-10 09:17:09', '2026-05-10 09:17:11'),
(35, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2034-08-30', NULL, NULL, 'Auto-generated next cycle after payment #34 completion', 'MONTHLY', NULL, NULL, '2026-05-10 09:17:11', '2026-05-10 09:17:11'),
(36, 5, 3, 1500.00, 'USD', 'BANK_TRANSFER', 'PENDING', NULL, '2026-06-01', NULL, NULL, 'Auto-generated next cycle after payment #16 completion', 'MONTHLY', NULL, NULL, '2026-05-10 09:19:37', '2026-05-10 09:19:37');

-- --------------------------------------------------------

--
-- Table structure for table `payment_reminders`
--

DROP TABLE IF EXISTS `payment_reminders`;
CREATE TABLE IF NOT EXISTS `payment_reminders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `payment_record_id` int DEFAULT NULL,
  `reminder_type` enum('DUE_REMINDER','OVERDUE_WARNING','SUSPENSION_NOTICE') COLLATE utf8mb4_unicode_ci DEFAULT 'DUE_REMINDER',
  `days_before_due` int DEFAULT '0' COMMENT '0=on due date, negative=days after due date',
  `sent_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `acknowledged` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_payment_record_id` (`payment_record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payment reminder notifications';

-- --------------------------------------------------------

--
-- Table structure for table `payment_transactions`
--

DROP TABLE IF EXISTS `payment_transactions`;
CREATE TABLE IF NOT EXISTS `payment_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_id` int NOT NULL,
  `transaction_type` enum('payment','refund','adjustment') COLLATE utf8mb4_unicode_ci DEFAULT 'payment',
  `payment_method` enum('cash','upi','card','qr','bank_transfer','online','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `reference_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_by` int DEFAULT NULL,
  `processed_by_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('success','failed','pending') COLLATE utf8mb4_unicode_ci DEFAULT 'success',
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_bill_id` (`bill_id`),
  KEY `idx_payment_method` (`payment_method`),
  KEY `idx_transaction_date` (`transaction_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_vouchers`
--

DROP TABLE IF EXISTS `payment_vouchers`;
CREATE TABLE IF NOT EXISTS `payment_vouchers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `supplier_id` bigint NOT NULL,
  `payment_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `payment_mode` enum('Cash','Bank','Cheque','Online') COLLATE utf8mb4_general_ci NOT NULL,
  `amount_paid` decimal(15,2) NOT NULL,
  `reference_id` bigint DEFAULT NULL,
  `remarks` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer` (`supplier_id`),
  KEY `idx_payment_vouchers_shop_id` (`shop_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_vouchers`
--

INSERT INTO `payment_vouchers` (`id`, `shop_id`, `supplier_id`, `payment_date`, `payment_mode`, `amount_paid`, `reference_id`, `remarks`, `created_at`, `updated_at`) VALUES
(2, 5, 18, '2026-03-31 18:08:06', 'Cash', 45000.00, 0, '', '2026-03-31 18:08:06', '2026-03-31 18:08:06'),
(3, 5, 20, '2026-03-31 18:18:21', 'Online', 10000.00, 0, '', '2026-03-31 18:18:21', '2026-03-31 18:18:21'),
(4, 5, 20, '2026-03-31 18:20:08', 'Cash', 2000.00, 0, '2000', '2026-03-31 18:20:08', '2026-03-31 18:20:08');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usertype_id` int DEFAULT NULL,
  `permission` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usertype_id` (`usertype_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `usertype_id`, `permission`) VALUES
(1, 1, 'view'),
(2, 1, 'edit'),
(3, 1, 'delete'),
(4, 1, 'create'),
(5, 1, 'manage_users'),
(6, 2, 'view'),
(7, 2, 'edit'),
(8, 2, 'create'),
(9, 3, 'view'),
(10, 4, 'view'),
(11, 4, 'create'),
(12, 4, 'edit_own'),
(13, 5, 'view_public');

-- --------------------------------------------------------

--
-- Table structure for table `plan_features`
--

DROP TABLE IF EXISTS `plan_features`;
CREATE TABLE IF NOT EXISTS `plan_features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plan_id` int NOT NULL,
  `feature_id` int NOT NULL,
  `is_enabled` tinyint(1) DEFAULT '1',
  `feature_level` enum('basic','advanced','enterprise') COLLATE utf8mb4_general_ci DEFAULT 'basic',
  `usage_limit` int DEFAULT NULL,
  `additional_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_plan_feature` (`plan_id`,`feature_id`),
  KEY `feature_id` (`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `printer_config`
--

DROP TABLE IF EXISTS `printer_config`;
CREATE TABLE IF NOT EXISTS `printer_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `terminal_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Machine/Terminal ID',
  `machine_uuid` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Machine UUID from users.user_uuid for device identification',
  `location` enum('kitchen','cashier') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Printer location type',
  `printer_ip` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Printer IP address',
  `printer_port` int DEFAULT '9100' COMMENT 'Printer port for ESC/POS (default: 9100)',
  `printer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Friendly name for the printer',
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'active' COMMENT 'Printer configuration status',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `terminal_id` (`terminal_id`),
  KEY `idx_location` (`location`),
  KEY `idx_terminal_id` (`terminal_id`),
  KEY `idx_status` (`status`),
  KEY `idx_machine_uuid` (`machine_uuid`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `printer_config`
--

INSERT INTO `printer_config` (`id`, `shop_id`, `terminal_id`, `machine_uuid`, `location`, `printer_ip`, `printer_port`, `printer_name`, `status`, `created_at`, `updated_at`) VALUES
(16, 5, 'DEMO_CASHIER01', 'd790f3bf-4987-4000-b395-95258824063e', 'cashier', '192.168.1.216', 9100, 'Cashier_Printer1', 'active', '2026-03-30 15:40:42', '2026-03-31 14:41:11'),
(18, 7, 'JASLEEN_CASHIER001', '39ac2eca-17fb-400e-96da-1903281eb4ba', 'cashier', '192.168.1.216', 9100, 'Cashier_Printer1', 'active', '2026-03-30 15:57:12', '2026-03-30 15:57:12'),
(19, 5, 'JASLEEN_CASHIER02', 'd790f3bf-4987-4000-b395-95258824063e', 'kitchen', '192.168.1.217', 9100, 'Kitchen_Printer1', 'active', '2026-03-30 15:58:48', '2026-03-30 15:58:48'),
(20, 5, 'KITCHEN_2', '06f56e45-e5a8-42b2-82f6-6cb512eb52a5', 'kitchen', '192.168.1.217', 9100, 'Kitchen2', 'active', '2026-03-31 14:44:00', '2026-03-31 14:44:00'),
(21, 5, 'CASHIERID', 'd790f3bf-4987-4000-b395-95258824063e', 'cashier', '192.168.1.216', 9100, 'Cashier Printer', 'active', '2026-03-31 14:49:01', '2026-03-31 14:49:01'),
(22, 5, 'CASHIER', '06f56e45-e5a8-42b2-82f6-6cb512eb52a5', 'cashier', '192.168.1.216', 9100, 'Cashier Printer1', 'active', '2026-03-31 14:52:34', '2026-03-31 14:52:34');

-- --------------------------------------------------------

--
-- Table structure for table `printer_settings`
--

DROP TABLE IF EXISTS `printer_settings`;
CREATE TABLE IF NOT EXISTS `printer_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `cashier_printer_ip` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Cashier thermal printer IP address (e.g., 192.168.1.100)',
  `kitchen_printer_ip` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Kitchen thermal printer IP address (e.g., 192.168.1.101)',
  `kiosk_printer_ip` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Kiosk terminal printer IP address (e.g., 192.168.1.102)',
  `printer_port` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT '9100' COMMENT 'Network port for ESCpos communication (default: 9100)',
  `print_width` int DEFAULT '80' COMMENT 'Print width in mm (typically 58 or 80)',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'active' COMMENT 'Settings status (active/inactive)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
  `created_by` int DEFAULT NULL COMMENT 'User ID who created the record',
  `updated_by` int DEFAULT NULL COMMENT 'User ID who last updated the record',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_printer_settings` (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_printer_settings_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ESCpos Thermal Printer Settings for Multiple Locations';

-- --------------------------------------------------------

--
-- Table structure for table `product_units`
--

DROP TABLE IF EXISTS `product_units`;
CREATE TABLE IF NOT EXISTS `product_units` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `unit_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'e.g., Bottle, Can, Piece, Liter, ML',
  `unit_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'BASE, DERIVED',
  `conversion_factor` decimal(10,2) DEFAULT '1.00' COMMENT 'Conversion factor to base unit',
  `is_base_unit` tinyint(1) DEFAULT '0',
  `ml_capacity` int DEFAULT NULL COMMENT 'For liquor bottles - ML capacity',
  `purchase_price` decimal(10,2) DEFAULT '0.00',
  `selling_price` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_units`
--

INSERT INTO `product_units` (`id`, `product_id`, `unit_name`, `unit_type`, `conversion_factor`, `is_base_unit`, `ml_capacity`, `purchase_price`, `selling_price`, `is_active`, `created_at`, `updated_at`) VALUES
(103, 1216, 'btl', 'BASE', 1.00, 1, NULL, 25.00, 25.00, 1, '2026-05-10 08:56:46', '2026-05-10 08:56:46'),
(104, 1217, 'btl', 'BASE', 1.00, 1, NULL, 85.00, 85.00, 1, '2026-05-10 08:58:07', '2026-05-10 08:58:07'),
(105, 1218, 'btl', 'BASE', 1.00, 1, NULL, 99.00, 99.00, 1, '2026-05-10 08:58:20', '2026-05-10 08:58:20'),
(106, 1219, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:42:58', '2026-05-10 13:42:58'),
(107, 1220, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:43:15', '2026-05-10 13:43:15'),
(108, 1221, 'cann', 'BASE', 1.00, 1, NULL, 25.00, 25.00, 1, '2026-05-10 13:43:40', '2026-05-10 13:43:40'),
(109, 1222, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:46:37', '2026-05-10 13:46:37'),
(110, 1223, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:47:29', '2026-05-10 13:47:29'),
(111, 1224, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:48:54', '2026-05-10 13:48:54'),
(112, 1225, 'cann', 'BASE', 1.00, 1, NULL, 30.00, 30.00, 1, '2026-05-10 13:50:37', '2026-05-10 13:50:37'),
(113, 1226, 'cann', 'BASE', 1.00, 1, NULL, 65.00, 65.00, 1, '2026-05-10 13:51:04', '2026-05-10 13:51:04'),
(114, 1227, 'Bowl', 'BASE', 1.00, 1, NULL, 25.00, 25.00, 1, '2026-05-10 16:01:03', '2026-05-10 16:01:03'),
(115, 1228, 'Bottle', 'BASE', 1.00, 1, 750, 0.00, 0.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(116, 1228, '30ML Peg', 'DERIVED', 0.04, 0, 30, 0.00, 200.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(117, 1228, '60ML Peg', 'DERIVED', 0.08, 0, 60, 0.00, 400.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(118, 1228, '90ML Large Peg', 'DERIVED', 0.12, 0, 90, 0.00, 600.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(119, 1228, 'Bottle', 'BASE', 1.00, 0, 750, 0.00, 2200.00, 1, '2026-05-11 15:01:14', '2026-05-11 16:14:18'),
(120, 1229, 'Bottle', 'BASE', 1.00, 1, 750, 0.00, 0.00, 1, '2026-05-11 15:02:23', '2026-05-11 15:02:23'),
(121, 1229, '30ML Peg', 'DERIVED', 0.04, 0, 30, 0.00, 300.00, 1, '2026-05-11 15:02:23', '2026-05-11 15:02:23'),
(122, 1229, '60ML Peg', 'DERIVED', 0.08, 0, 60, 0.00, 600.00, 1, '2026-05-11 15:02:23', '2026-05-11 15:02:23'),
(123, 1230, 'Bottle', 'BASE', 1.00, 1, 750, 0.00, 2500.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:55:24'),
(124, 1230, '30ML Peg', 'DERIVED', 0.04, 0, 30, 0.00, 150.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(125, 1230, '60ML Peg', 'DERIVED', 0.08, 0, 60, 0.00, 300.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(126, 1230, '90ML Large Peg', 'DERIVED', 0.12, 0, 90, 0.00, 500.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(128, 1231, 'Bottle', 'BASE', 1.00, 1, 750, 0.00, 0.00, 1, '2026-05-11 18:18:58', '2026-05-11 18:18:58'),
(129, 1231, '30ML Peg', 'DERIVED', 0.04, 0, 30, 0.00, 50.00, 1, '2026-05-11 18:18:58', '2026-05-11 18:18:58'),
(130, 1231, '60ML Peg', 'DERIVED', 0.08, 0, 60, 0.00, 100.00, 1, '2026-05-11 18:18:58', '2026-05-11 18:18:58'),
(131, 1232, 'btl', 'BASE', 1.00, 1, NULL, 120.00, 120.00, 1, '2026-05-11 18:51:52', '2026-05-11 18:51:52');

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE IF NOT EXISTS `product_variants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `variant_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'e.g., Whiskey 30ML Peg, Whiskey 60ML, Full Bottle',
  `base_unit_id` int NOT NULL COMMENT 'Unit it is based on (e.g., Bottle)',
  `quantity_in_base_unit` decimal(10,4) NOT NULL COMMENT 'e.g., 0.25 bottles = 1 peg of 30ML',
  `ml_quantity` int DEFAULT NULL COMMENT 'e.g., 30 for 30ML peg',
  `selling_price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_variant` (`product_id`),
  KEY `idx_base_unit` (`base_unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`id`, `product_id`, `variant_name`, `base_unit_id`, `quantity_in_base_unit`, `ml_quantity`, `selling_price`, `cost_price`, `is_active`, `created_at`, `updated_at`) VALUES
(13, 1228, '30ML Peg', 115, 0.0400, 30, 200.00, 0.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(14, 1228, '60ML Peg', 115, 0.0800, 60, 400.00, 0.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(15, 1228, '90ML Large Peg', 115, 0.1200, 90, 600.00, 0.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(16, 1228, 'Bottle', 115, 1.0000, 750, 2200.00, 0.00, 1, '2026-05-11 15:01:14', '2026-05-11 15:01:14'),
(17, 1229, '30ML Peg', 120, 0.0400, 30, 300.00, 0.00, 1, '2026-05-11 15:02:23', '2026-05-11 15:02:23'),
(18, 1229, '60ML Peg', 120, 0.0800, 60, 600.00, 0.00, 1, '2026-05-11 15:02:23', '2026-05-11 15:02:23'),
(19, 1230, '30ML Peg', 123, 0.0400, 30, 150.00, 0.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(20, 1230, '60ML Peg', 123, 0.0800, 60, 300.00, 0.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(21, 1230, '90ML Large Peg', 123, 0.1200, 90, 500.00, 0.00, 1, '2026-05-11 15:54:10', '2026-05-11 15:54:10'),
(22, 1230, 'Bottle', 123, 1.0000, 750, 2500.00, 0.00, 1, '2026-05-11 15:54:11', '2026-05-11 15:54:11'),
(23, 1231, '30ML Peg', 128, 0.0400, 30, 50.00, 0.00, 1, '2026-05-11 18:18:58', '2026-05-11 18:18:58'),
(24, 1231, '60ML Peg', 128, 0.0800, 60, 100.00, 0.00, 1, '2026-05-11 18:18:58', '2026-05-11 18:18:58');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_items`
--

DROP TABLE IF EXISTS `purchase_items`;
CREATE TABLE IF NOT EXISTS `purchase_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `purchase_id` int NOT NULL,
  `product_id` int NOT NULL,
  `unit_id` int NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `tax_rate` decimal(5,2) DEFAULT '0.00',
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL,
  `batch_number` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `unit_id` (`unit_id`),
  KEY `idx_purchase` (`purchase_id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchase_items`
--

INSERT INTO `purchase_items` (`id`, `purchase_id`, `product_id`, `unit_id`, `quantity`, `unit_price`, `tax_rate`, `tax_amount`, `total_amount`, `batch_number`, `expiry_date`, `notes`, `created_at`) VALUES
(7, 13, 1228, 115, 10.00, 1200.00, 7.00, 840.00, 12840.00, NULL, NULL, '', '2026-05-11 15:21:19'),
(8, 13, 1229, 120, 10.00, 2000.00, 7.00, 1400.00, 21400.00, NULL, NULL, '', '2026-05-11 15:21:19'),
(9, 14, 1228, 119, 10.00, 2200.00, 7.00, 1540.00, 23540.00, NULL, NULL, '', '2026-05-11 15:41:05'),
(10, 15, 1230, 123, 12.00, 1200.00, 7.00, 1008.00, 15408.00, NULL, NULL, '', '2026-05-11 15:56:07'),
(11, 16, 1231, 128, 12.00, 1200.00, 7.00, 1008.00, 15408.00, NULL, NULL, '', '2026-05-11 18:19:30');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
CREATE TABLE IF NOT EXISTS `purchase_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `purchase_number` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'PO-2026-001',
  `supplier_id` int NOT NULL,
  `purchase_date` date NOT NULL,
  `invoice_number` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `discount_amount` decimal(10,2) DEFAULT '0.00',
  `net_amount` decimal(10,2) DEFAULT '0.00',
  `payment_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'PENDING' COMMENT 'PENDING, PARTIAL, PAID',
  `payment_method` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'CASH, CARD, UPI, BANK_TRANSFER',
  `notes` text COLLATE utf8mb4_general_ci,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_number` (`purchase_number`),
  KEY `idx_purchase_date` (`purchase_date`),
  KEY `idx_supplier` (`supplier_id`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchase_orders`
--

INSERT INTO `purchase_orders` (`id`, `shop_id`, `purchase_number`, `supplier_id`, `purchase_date`, `invoice_number`, `invoice_date`, `total_amount`, `tax_amount`, `discount_amount`, `net_amount`, `payment_status`, `payment_method`, `notes`, `created_by`, `created_at`, `updated_at`) VALUES
(13, 5, 'PO-2026-0001', 18, '2026-05-10', 'INV-12356', '2026-05-10', 34240.00, 2240.00, 0.00, 34240.00, 'PENDING', NULL, '', 180, '2026-05-11 15:21:19', '2026-05-11 15:21:19'),
(14, 5, 'PO-2026-0002', 20, '2026-05-11', 'inv25636', NULL, 23540.00, 1540.00, 0.00, 23540.00, 'PENDING', NULL, '', 180, '2026-05-11 15:41:05', '2026-05-11 15:41:05'),
(15, 5, 'PO-2026-0003', 20, '2026-05-11', 'inv256369', NULL, 15408.00, 1008.00, 0.00, 15408.00, 'PENDING', NULL, '', 180, '2026-05-11 15:56:07', '2026-05-11 15:56:07'),
(16, 5, 'PO-2026-0004', 20, '2026-05-11', 'INV2569', '2026-05-11', 15408.00, 1008.00, 0.00, 15408.00, 'PENDING', NULL, '', 180, '2026-05-11 18:19:30', '2026-05-11 18:19:30');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_payments`
--

DROP TABLE IF EXISTS `purchase_payments`;
CREATE TABLE IF NOT EXISTS `purchase_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `purchase_id` int NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `reference_number` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_general_ci,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_purchase` (`purchase_id`),
  KEY `idx_payment_date` (`payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `quotations`
--

DROP TABLE IF EXISTS `quotations`;
CREATE TABLE IF NOT EXISTS `quotations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `quotation_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `customer_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_address` text COLLATE utf8mb4_unicode_ci,
  `customer_gst` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_place` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `discount_type` enum('percentage','amount') COLLATE utf8mb4_unicode_ci DEFAULT 'percentage',
  `discount_value` decimal(10,2) DEFAULT '0.00',
  `subtotal_afterdiscount` decimal(10,2) DEFAULT '0.00',
  `tax` decimal(10,2) DEFAULT '0.00',
  `round_off` decimal(10,2) DEFAULT '0.00',
  `grand_total` decimal(10,2) DEFAULT '0.00',
  `status` enum('pending','approved','rejected','converted','expired') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `valid_until` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `setup_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_quotation_number` (`quotation_number`),
  KEY `idx_status` (`status`),
  KEY `idx_setup_date` (`setup_date`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_valid_until` (`valid_until`),
  KEY `idx_quotations_customer_status` (`customer_id`,`status`),
  KEY `idx_quotations_date_status` (`setup_date`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for storing quotation information';

--
-- Triggers `quotations`
--
DROP TRIGGER IF EXISTS `quotation_number_generator`;
DELIMITER $$
CREATE TRIGGER `quotation_number_generator` BEFORE INSERT ON `quotations` FOR EACH ROW BEGIN
  DECLARE next_number INT;
  DECLARE quotation_number VARCHAR(50);
  
  -- Get the next quotation number
  SELECT COALESCE(MAX(CAST(SUBSTRING(quotation_number, 10) AS UNSIGNED)), 0) + 1 
  INTO next_number 
  FROM quotations 
  WHERE quotation_number LIKE CONCAT('QUO-', YEAR(CURDATE()), '-%');
  
  -- Generate quotation number in format QUO-YYYY-NNNN
  SET quotation_number = CONCAT('QUO-', YEAR(CURDATE()), '-', LPAD(next_number, 4, '0'));
  
  -- Set the quotation number if not provided
  IF NEW.quotation_number IS NULL OR NEW.quotation_number = '' THEN
    SET NEW.quotation_number = quotation_number;
  END IF;
  
  -- Set setup_date if not provided
  IF NEW.setup_date IS NULL THEN
    SET NEW.setup_date = CURDATE();
  END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `quotation_status_history`;
DELIMITER $$
CREATE TRIGGER `quotation_status_history` AFTER UPDATE ON `quotations` FOR EACH ROW BEGIN
  IF OLD.status != NEW.status THEN
    INSERT INTO quotation_history (quotation_id, action, old_status, new_status, comments)
    VALUES (NEW.id, 'status_change', OLD.status, NEW.status, CONCAT('Status changed from ', OLD.status, ' to ', NEW.status));
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `quotation_history`
--

DROP TABLE IF EXISTS `quotation_history`;
CREATE TABLE IF NOT EXISTS `quotation_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `quotation_id` int NOT NULL,
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comments` text COLLATE utf8mb4_unicode_ci,
  `action_by` int DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_quotation_id` (`quotation_id`),
  KEY `idx_action_date` (`action_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='History table for tracking quotation status changes';

-- --------------------------------------------------------

--
-- Table structure for table `quotation_items`
--

DROP TABLE IF EXISTS `quotation_items`;
CREATE TABLE IF NOT EXISTS `quotation_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `table_number` varchar(25) COLLATE utf8mb4_general_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` float NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `invoice_number` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `setup_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_quotation_items_quotation` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `receipt_vouchers`
--

DROP TABLE IF EXISTS `receipt_vouchers`;
CREATE TABLE IF NOT EXISTS `receipt_vouchers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `customer_id` bigint NOT NULL,
  `payment_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `payment_mode` enum('Cash','Bank','Cheque','Online') COLLATE utf8mb4_general_ci NOT NULL,
  `amount_paid` decimal(15,2) NOT NULL,
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `reference_id` bigint DEFAULT NULL,
  `remarks` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transaction` (`transaction_id`),
  KEY `idx_customer` (`customer_id`)
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `receipt_vouchers`
--

INSERT INTO `receipt_vouchers` (`id`, `transaction_id`, `customer_id`, `payment_date`, `payment_mode`, `amount_paid`, `discount_amount`, `reference_id`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 'RECPT_1770187413433', 15, '2026-02-04 13:43:33', 'Cash', 1.00, 200.00, NULL, NULL, '2026-02-04 13:43:33', '2026-02-14 14:13:25'),
(2, 'RECPT_1771051215985', 15, '2026-02-14 13:40:15', 'Cash', 100.00, 0.00, 0, NULL, '2026-02-14 13:40:15', '2026-02-14 13:40:15'),
(3, 'RECPT_1771051509572', 15, '2026-02-14 13:45:09', 'Cash', 25.00, 25.00, 0, NULL, '2026-02-14 13:45:09', '2026-02-14 13:45:09'),
(4, 'RECPT_1771051962230', 15, '2026-02-14 13:52:42', 'Cash', 35.00, 35.00, NULL, NULL, '2026-02-14 13:52:42', '2026-02-14 14:21:10'),
(5, 'RECPT_1771053868198', 15, '2026-02-14 14:24:30', 'Cash', 200.00, 150.00, NULL, NULL, '2026-02-14 14:24:30', '2026-02-14 14:24:44'),
(6, 'RECPT_1771054920379', 15, '2026-02-14 14:42:02', 'Cash', 500.00, 55.00, NULL, NULL, '2026-02-14 14:42:02', '2026-02-14 14:42:02'),
(8, 'RECPT_1771112849665', 16, '2026-02-15 06:47:29', 'Cash', 26870.00, 2462.00, NULL, NULL, '2026-02-15 06:47:29', '2026-02-15 06:47:29'),
(9, 'RECPT_1771112922370', 17, '2026-02-15 06:48:42', 'Cash', 1205.00, 0.00, NULL, NULL, '2026-02-15 06:48:42', '2026-02-15 06:48:42'),
(10, 'RECPT_1771287532449', 17, '2026-02-17 07:18:52', 'Cash', 2543.00, 0.00, NULL, NULL, '2026-02-17 07:18:52', '2026-02-17 07:18:52'),
(11, 'RECPT_1771546775746', 16, '2026-02-20 07:19:35', 'Cash', 18400.00, 0.00, NULL, NULL, '2026-02-20 07:19:35', '2026-02-20 07:19:35'),
(12, 'RECPT_1771547376013', 17, '2026-02-20 07:29:36', 'Cash', 7840.00, 0.00, NULL, NULL, '2026-02-20 07:29:36', '2026-02-20 07:29:36'),
(13, 'RECPT_1771547391601', 17, '2026-02-20 07:29:51', 'Cash', 6200.00, 0.00, NULL, NULL, '2026-02-20 07:29:51', '2026-02-20 07:29:51'),
(14, 'RECPT_1771547414024', 17, '2026-02-20 07:30:14', 'Cash', 400.00, 0.00, NULL, NULL, '2026-02-20 07:30:14', '2026-02-20 07:30:14'),
(15, 'RECPT_1771547530855', 19, '2026-02-20 07:32:10', 'Cash', 12500.00, 0.00, NULL, NULL, '2026-02-20 07:32:10', '2026-02-20 07:32:10'),
(16, 'RECPT_1771547600819', 20, '2026-02-20 07:33:20', 'Bank', 548.00, 0.00, 0, NULL, '2026-02-20 07:33:20', '2026-02-20 07:33:20'),
(17, 'RECPT_1771548882592', 17, '2026-02-20 07:54:42', 'Cash', 6980.00, 0.00, NULL, NULL, '2026-02-20 07:54:42', '2026-02-20 07:54:42'),
(18, 'RECPT_1771639111437', 16, '2026-02-21 08:58:31', 'Cash', 26744.00, 0.00, NULL, NULL, '2026-02-21 08:58:31', '2026-02-21 08:58:31'),
(19, 'RECPT_1771639134647', 19, '2026-02-21 08:58:54', 'Cash', 10520.00, 0.00, NULL, NULL, '2026-02-21 08:58:54', '2026-02-21 08:58:54'),
(20, 'RECPT_1771812078856', 17, '2026-02-23 09:01:18', 'Bank', 4680.00, 0.00, NULL, NULL, '2026-02-23 09:01:18', '2026-02-23 09:01:18'),
(21, 'RECPT_1774976618500', 22, '2026-03-31 17:03:38', 'Cash', 200.00, 0.00, NULL, NULL, '2026-03-31 17:03:38', '2026-03-31 17:03:38'),
(22, 'RECPT_1774976697761', 23, '2026-03-31 17:04:57', 'Bank', 1000.00, 0.00, NULL, NULL, '2026-03-31 17:04:57', '2026-03-31 17:04:57'),
(23, 'RECPT_1775276962337', 22, '2026-04-04 04:29:22', 'Cash', 500.00, 0.00, NULL, NULL, '2026-04-04 04:29:22', '2026-04-04 04:29:22');

-- --------------------------------------------------------

--
-- Table structure for table `rs485_logs`
--

DROP TABLE IF EXISTS `rs485_logs`;
CREATE TABLE IF NOT EXISTS `rs485_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `command_sent` text COLLATE utf8mb4_general_ci,
  `response_received` text COLLATE utf8mb4_general_ci,
  `status` enum('sent','received','error','timeout') COLLATE utf8mb4_general_ci DEFAULT 'sent',
  `error_message` text COLLATE utf8mb4_general_ci,
  `response_time_ms` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_rs485_logs_machine_created` (`machine_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scb_payments`
--

DROP TABLE IF EXISTS `scb_payments`;
CREATE TABLE IF NOT EXISTS `scb_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_id` int DEFAULT NULL COMMENT 'Reference to bills table if linked to a specific bill',
  `ref1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary reference ID (usually order/bill number)',
  `ref2` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Secondary reference ID (customer ID, etc)',
  `ref3` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Tertiary reference ID (transaction reference, etc)',
  `amount` decimal(10,2) NOT NULL COMMENT 'Payment amount in THB',
  `qr_raw_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Raw QR code data string for payment',
  `qr_image` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Base64 encoded QR code image',
  `transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SCB transaction ID',
  `status` enum('PENDING','SUCCESS','FAILED','EXPIRED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT 'Payment status',
  `paid_at` datetime DEFAULT NULL COMMENT 'Timestamp when payment was completed',
  `expires_at` datetime DEFAULT NULL COMMENT 'QR code expiration time',
  `callback_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Raw callback data from SCB webhook',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Error message if payment failed',
  `pp_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Partner ID used for QR generation',
  `merchant_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Merchant ID used for the transaction',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_ref1` (`ref1`),
  KEY `idx_bill_id` (`bill_id`),
  KEY `idx_status` (`status`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_paid_at` (`paid_at`),
  KEY `idx_status_created_date` (`status`,`created_at`),
  KEY `idx_amount` (`amount`),
  KEY `idx_ref2` (`ref2`),
  KEY `idx_ref3` (`ref3`),
  KEY `idx_status_amount_created` (`status`,`amount`,`created_at`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scb_payments`
--

INSERT INTO `scb_payments` (`id`, `bill_id`, `ref1`, `ref2`, `ref3`, `amount`, `qr_raw_data`, `qr_image`, `transaction_id`, `status`, `paid_at`, `expires_at`, `callback_data`, `error_message`, `pp_id`, `merchant_id`, `created_at`, `updated_at`) VALUES
(1, NULL, 'BILL1774756166289', 'CUST1774756167113', 'TXN1774756167113', 180.00, '000201010212306101152696314020436540217BILL17747561662890317CUST17747561671135204701153037645406180.005802TH5922TestMerchant17563798076007BANGKOK62470523202603291049272610000000716TXN17747561671136304CC93', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-29 03:49:28', '2026-03-29 03:49:28'),
(2, NULL, 'BILL1774891956961', 'CUST1774891958830', 'TXN1774891958830', 2120.00, '000201010212306101152696314020436540217BILL17748919569610317CUST177489195883052047011530376454072120.005802TH5922TestMerchant17563798076007BANGKOK62470523202603311232389310000000716TXN1774891958830630439ED', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-30 17:32:39', '2026-03-30 17:32:39'),
(3, NULL, 'BILL1775364358167', 'CUST1775364324038', 'TXN1775364324038', 760.00, '000201010212306101152696314020436540217BILL17753643581670317CUST17753643240385204701153037645406760.005802TH5922TestMerchant17563798076007BANGKOK62470523202604051145241850000000716TXN177536432403863045398', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-05 04:45:24', '2026-04-05 04:45:24');
INSERT INTO `scb_payments` (`id`, `bill_id`, `ref1`, `ref2`, `ref3`, `amount`, `qr_raw_data`, `qr_image`, `transaction_id`, `status`, `paid_at`, `expires_at`, `callback_data`, `error_message`, `pp_id`, `merchant_id`, `created_at`, `updated_at`) VALUES
(4, NULL, 'BILL1775364424285', 'CUST1775364423975', 'TXN1775364423975', 1130.00, '000201010212306101152696314020436540217BILL17753644242850317CUST177536442397552047011530376454071130.005802TH5922TestMerchant17563798076007BANGKOK62470523202604051147040800000000716TXN177536442397563047459', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-05 04:47:04', '2026-04-05 04:47:04'),
(5, NULL, 'BILL1777722477674', 'CUST1777722478054', 'TXN1777722478054', 600.00, '000201010212306101152696314020436540217BILL17777224776740317CUST17777224780545204701153037645406600.005802TH5922TestMerchant17563798076007BANGKOK62470523202605020647581600000000716TXN1777722478054630366C', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-02 11:47:58', '2026-05-02 11:47:58'),
(6, NULL, 'BILL1778408411154', 'CUST1778408412716', 'TXN1778408412716', 85.00, '000201010212306101152696314020436540217BILL17784084111540317CUST1778408412716520470115303764540585.005802TH5922TestMerchant17563798076007BANGKOK62470523202605100520128150000000716TXN1778408412716630450B5', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-10 10:20:14', '2026-05-10 10:20:14');
INSERT INTO `scb_payments` (`id`, `bill_id`, `ref1`, `ref2`, `ref3`, `amount`, `qr_raw_data`, `qr_image`, `transaction_id`, `status`, `paid_at`, `expires_at`, `callback_data`, `error_message`, `pp_id`, `merchant_id`, `created_at`, `updated_at`) VALUES
(7, NULL, 'BILL1778408561062', 'CUST1778408562436', 'TXN1778408562436', 75.00, '000201010212306101152696314020436540217BILL17784085610620317CUST1778408562436520470115303764540575.005802TH5922TestMerchant17563798076007BANGKOK62470523202605100522425420000000716TXN17784085624366304DCD4', 'R0lGODdh9AH0AYAAAAAAAP///ywAAAAA9AH0AQAC/4yPqcvtD6OctNqLs968+w+G4kiW5omm6sq27gvH8kzX9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNarfcrvcLDovH5LL5jE6r1+y2+w2Py+f0uv2Oz+v3/L7/DxgoOEhYaHiImKi4yNjo+AgZKTlJWWl5SQmgucnZ6fkJGioKwDBqespJgSqq+lnqugDKIju0ShoLK2FLq7vr+3vrAjy8+kps20qc3GnMjOs5mxuE/OzcqzxxrB0Ks+1tnfB9ugxMvtmcWp2uwjtdrH6efWwuji1c742ODw6hTR8cThqCdigI/qCmwKADf/L2zXvhkGHCiNAaDvunT1NGgP8FBR58N7HitYsWKfrqZrIcPIr/EEZQGAAmTBIzd7gc6HHhw5Epb67o+Wujw5YgX+aMebSmCKU5fBpgitOeUaBOU1DdJXQfUVQYV3I8APVDWBtVxyKV2u9q0WgirSalurFryHEjZB7Nihbs27ZR+T2wy/fvXa9s/bIbvHRvz7gl4801RVPxuqn1GD92HDCwTs1nDTcwa5ZDaLGIQwBeTLixRq+jeWLuOzktPsuZPYOW/FowZ9odd59oneF0St66ba8lzfn27NSXVzf/utm47+dy3U4vARyDcJPEo8fWy7UubueUxXXv/P1padi51V9nT16258jvxdf3sJ0l8/Lt0Y//oi/dfKztVFt6/sUHnoDU7SefgecB6OBv6yEX4HAMFmdgVaKNB91nWl3oXoX9naecggWOaJ+JEKKYWHJwgeihi+G1KCKC3n1DIofVwdfhgzCuaKN1NWL144AznhjkVipekF+H2WHYn0T8JblBkyVmSCCPKMlI0oKunVTkl9ykiCWXEWpg5XE3Uokmh1dGmWWCZ2LnppoH9mgkXV4GZ+eGZsJ5XwVpHtkgi3z+yYpqTsYZ4pxALppXo4byWNaEa45JY5lDPoqXnlPi2SaimH7aKWRh0ilqpYFKqWWVfboqqo+hDqnhqdrVuSqunrZ6T6p2vgnmnrcSSqGmxk7KpK6m/4rJaZ6Oyglol0iCiiqtv1p6p6pLXvrkpTkGuiO0wZJKZrTLkvucts9mam5QtopLpLDJEoufju9aMOiuULJ5qLW5+krvnVv6q6+kQQ6lqKyfNvntth0AOyqv6JqGbb7nSlzYseNiDC+r+0LqcKntHmzvYf8WLHDC5fLLscHxTjuwxi+3nC2jMW4KK8oM3/twxdeevK6gPgOsM7YgWPwfjAgzy7PIJMfadM5Bq4usy80yne7PIRc78szwOu21t1FnDbW8Vv80dNFAVy302k9LS3NvBF/8tbPuYg2z1EmbnTLfVy9c8sRHpy0z1SyvDLJKfC8teN2z0n324kbrfbjLO//jPbjbid+dd69z7935tB6L7beil4ceN+JKyhxuvZqDfXrGXRtOLaU2I115zZHebGHpvotus8KpS757t/0WrvXUHxKPMuyvkl0ZzxCPzjvbEDtfdgu4R+w44MUra/3y3kf/+/DA7y5894W+rTjqaBMNed/jt09zrdDT/zHj5u/fcfDSEz675LEtc59LVPn69z34hW85YtKf+j62Os6tr3YPJN351LY11xWQe5GbnwQrqDuHOZBb4uNfBydIvfSdEIJ2M6D7TLbB2OXvduDL3Qirp58DrpCE6Pvf61rIQfnJjn0f3CEOt9Gw+GGveUCk3vVM5z8dCpGF9wOdCSkGLsr/UdCCtsteFzf4t2GJEIBEVMvmXCjGoPkpgz3L4uMGqDQBljGI9jseHKX4xCrm8IJqHJsdc0fAPr4RkHEM2PbAFsZ5jfGHeowIIrU4xC1ikY1pvOMLQ8g6ID6SXYTEIxnPqJZN/lGSaxRkGympSFPWT46gPKTqIKkyzCEQNY0spSUr2clTqjKVtwQh7UT5xV1ykZc2/OQSzaNJWMJQmKOMpC3nKEPL1ZCUsWxmNSd4TBwlc5DU5GbMeomvyTEvfq6s5Su9eU0q8pE727TmMsE5SjN60ZeBW+U8jRjNKeKznvS8pz7/mU95MtEEAiUnP/fpz4AeFKALVWhCGwpRBZrx/5sFxdk4u5ZEjBbSopd0KEft+dF+hlSaFaVoRTV60TlmVKUbzWRKQblSmLYUpR2d5lVMelKZvjSmPJ0pS3fqU53W9KFEjeGLPJdTlw51pAwtqlJB+lSRRhWhTPUo8koKkaQ6laZQ5apUvUrVqTa1qhEl61a1itOT9hSobF2qWK0K1rG+taxzlWgo37A948EVmtN8ZhD9CswZuhETMcirON0aV9rp9XnuXGcxA0ZYm9j0sF39qWNbSdlZMjOm08tsZJ3ZRM/KNbGsXCxklXnZCObys9qb7GArK9RgBvC1moUnZz9pPNbK7aoDbVxYZwtGLeY2qJ2lrW6FxFslpvO3fP+1q1+H+9LiovK4uwWucmXJXMw6V7iiva3moNuHcl52r7ElZtj+qdq7SjG9N1ThEVuHSduaN7AkxWBdpxtfNIKQvUe95HP7i03UBticSLWugfWbXfdm07K4TKqCoQgU+EqYuN2dbztli+DRMti8v+QuVtcLYVr6tm2LDG6Bm2vUs5Y3nAnEr1b9+d8IL5fEytvuibWbYrMylb8wDrFAH9xAAKuzwfCtYyLrm1wrfnXDLIbbfn0sTyB7cI8DbmyVMdxNXR4YxwZVcYztC88X79jDIr6yhbGb3yxH0si1zXB7L9xmLi+wxF3WcZInCucm964HKQytXdmM5C3T971QZrL/huWMZwLHs4SS7WEjDXtaRWN50O7tcFuxfNM805idPujzo13b20lrGtDoHTVdt5xpSXOY0Trw9HhBfd3UmjrS/p21nVEt5ECvNs6upkGveQ1rJfPQxLJG86DJu2BHaprHTm51FF/9Z8aKWtW6lqR074vtF1O60Ej8iKOhneNYT7vY5DbzsLNtaDHfWc3A/vaaadhjahPa2GSuMZ1xbUhpL7nb8gbvFaubj6Cmd8IgDjIjR3xDUkMazG6ucMGrhcxLC/bej8Xvtj0Z7XzTGrZOZOWRC8vqQw98xlJGoTFnnHB9Z7fjGre4Hx/F8jHLu9IOL/eQb15txZ780y2v82Zf/464mIv14rV+uMkPbu406xzp7WY4HWv+bwkxELEVF/eTjT5xe2sd307PI7h9LuxSo5MsIc8n0a/o7zgTnOr8tvkwc17ahQI2q0xfeV8p3HNBk9zWYN9Y1vXO81vv2ogmLfLd+x3sdKtc7G5Pc7JHjvgWD33vNza8jRu/cHT/1YddT7y1455xwbOb8HSn+Iodz3eua97rRyc2pnF7+K+T1riMBy2axTtujnt82Zzv+9PdrfbU+z3BAp4B6/eNe+Tvfua9D/vSQx38yDdb5MWXwfHtfnnd5x3FW6+680EP/WofG94yH3HhUR773Ct/+4j+/HfT3/Tu/77z7C/51avwfP+rk5750o+47DM8d+/UcMD3doeWds7GfgoHe+8Xer73a3omXwYXbmF2agD4BPkXdjS3cdH3f/Pnf4EUgVPWfqYlegfYFOCnf7XHga23bhg4fFo2eJs2gNNnea43BS64eRgXfqgXeA74bET2PvS3g2vVeFCAg9d3RNemet83dSAYg5DXgQHIdiaIA0e4cyIIha+XgD94ZsjFhDSIftl3gyiYgc1ngf2nTT1YhmPnhTOIPxCoeBvISe33cUSIdstXdGyXhX8XcBIHh+4Hhlg3h2fXhUlndsJ3enbIh4C4Z7AlhSy4hnloe0VYffOmh9ymiAWohN5HZfv2iIuIhOfHf1b/hnPUJ4GaV4Pyt4lt54iV+HiU11piqEHyl4lJWIGMGFeECHeSl4uwqIWmV4XwN4tzhoqYKHBhaHqrKHS9SG9qyImjN0nrVofHqIO+p4Hlp37nloaXyIaQeIaSGITSeE4IJ3eIeI2TN4q/+IamSIra+I1RR1BcWIDJZoVyKIPQmHziR40d+GbclGo18ICW6I2sGH+RCITduIIJSXzOqGxz+I++Jo8CCYrk94FcE4P5yIPcyI8h92WNaHwReY6ctpG0Z3/YZ4MLOZLkE41RdgMBGZKduItD6IuliIO1qG4hqI7bCJEEKJHuSJAxmYJrZ4hkGIcTCJMwqF4ACZJm2JAp//lzgmiAwsiOOXmUHSmSOxmI5udn09eP7XiP41d/eFdQMJdrIOdlxoiQKDmQn/iHr9iMiyZj6UiTSzmMRamKooVsaOmVqVhEPYmUD6mQX7mVTymYfmiLtJeXp0iBiOl5QrlqcUmJt0eXSFmLuuiXhyiX84iM61iSh1lmgcmXLwhwp7eKbDmVi2iaoXlenUmPFGmQc8mTTkiaC+hit7iHbVmJAWmCOWWZ3iWTdTmbDFibZ6mYF4mXjTmTfwiY+piWSgd1m8mMkUmO8SadSaeaCkiSg6mToAmdoll6hNmKzZmY1VmQz+iY+weOzJmel3mc2Vl54wiPGhme5AmUxGif5v+ZnBkZn/N5kEWwm+UomcRJn85Zd375krjohouJjaUIBP9JnUMpoNnomSkYikx5myqoie3pcu85iECnlp7Iewx5nhhKoqXpoaeJm0bgoAuaoRHKnSKanxVajV/ITJiplZ32nB+aovK5fsm4eDK6niYKlTZqnd62oTy6o/zZo3dpj0B6h8KJjtM5nEdKllvYgNEpoWC5g1RojogopEF6hf35blZqlIkYopj3ozk6obMnhEzKoiWqoeDJbRi5jM/4pVl6ohdKp2kalm+5n/dXpW26hIZmmTWZn1ZplzT6mur5pMDoilLHlUTpgfeZg2japGqqpeKYmfoJqJ2KnkUaj7z/mKAveKeoeaZ/qpy3iJGZSqkjypqPKajcp6h2SpuaeqMrOap0eKqB6aSeaqCQuo71+KbYGasICo16KpXEao0xGqc42Z2Vqn2fmaqy+KuGiYQpR603SagtKZW+6ZHTepLViqRweqW5yqpolafACnhS+mP1tq6gOq7XWnbJqq2vGqrh6q1XCau2Cq9K+qlL2pd7epP2CnHvCptj6a6yip8BOqyeR16Zp6//an3dKpbfeo+raqH7CKEqGa0tWJZcCpyF6rCTKaHK2qoae7AVaZIeC5mo2oa6yrDt6o8UO6OJurBOyaY++GHrKYoiWKr1qbDG2pso26KOypBEapFN2a/w/zmRUDqoMMuui8qeBSqvTeiriPqT4jqNMFqcI0izU9is22qY+UqqmKqd3gmVYtq0PlquULuxQUm0U2u0OCu2uKq0DKqutHqpZKqzc4unMXuyNeu1ffqyXemyauuTP0ug+FqxChql/iq3KkuiWKubZquZXIuFZ+u2KSu1lRm3ZHteIEu30Hq1SctsbsqyjBtdYWumY9u4ZeuePhuRotuZ2Op0rvq6oTu7YWqqR8u6JtuHSsmYVsuovkqCqdu3FMq7Ptmaw5uVVEm6AoiP80q4S1u0klu5BXquWXu6lOqSeTu9xMupEju5uSustMisfNuX3au3zxuOjrudxUu+x/u0EP97s9Y7vosLt5g7kKQ2mpQrqQdqmrbLmRnbtc07pQXsu7GbmnMawAbslQS8vhC8lppLv2g7usHovNiLh/gLuucbuLdashzpwE6LwZMIvQ+LnAesuQJ8qEuAtJdrqe7boQtcgiucufxrvMuLfwAqwrxKsrlJveGavcUaw+RKpUb6uHiLhifMtEA7qUHrljkchRTMxFFwxAdqv8daiOUZxZsLxcgqqkL7wkqQxUy5xT2bwqqKwxWsw/PLw1RwxoKbxt9Zv2zctmIcqdqbrkIwx2Cqvu/4xPo7q2BMyO2LvFi6wwysxIoswyMcm0lbtb+ZwV7Kulh7nbb5rFv7w+Qrm5P/vL+V3MTRq7W9G7XmasWeXMaAnMQsDLiCnLgPvKm1y6dE7MOQ28B+WrrACcqda8H0ao+0vLe2/KAgWsN72ccXy8P++8vZunjCvKXA3LDFnKRd/MhBt8zP3MzETMkuC7yGfMR/7MGpXLjZHMzbzK8v2slrer9ATM0oSpmPmrb7GsJ/K7uBbMi4u6kCO81vqs+sLKe6fK/pLL/KrGLjibjsrLuMrMrHLJtqbMdSvKvMm7ueK9CH/MWc/L+DvNET68znPMrbC82oG7BqSrtXnNAdbZbcHMqQzNKOXMpQLM4oDb4azdHvK9Gz3KUhfaLK2MGm+5EMXb4hG9QvDcsKDboW/73OEvyEyZzS8lywTS2esgyXN+yi1RzL1QvUHt3KQx3PXE3Q+avHYT3TcCy+KxrQhWm3SLCcMY3RzDzVY5zUFZ2+Rp3RX9DWWkzCDu3FNvnTBe3Co1zWSZDXaLzXa93CcWtpA9rLuTrYbF2Wei2+H1enwXm7E43EZP3XWVDYdHzYD53Y1rrZ35zJH93VDRrZhj3Zg1zZc726fPzadg0GnQ3QERvVgyt6Io3Zjf3Fj30EtN2oFkvZrmmzd73P5lysBDumqlvbdevSiYzKrsyzm0zd8yy4yp2w+UzOirvF4bzZA4zcS4zVkeusM0utgd3cxi3K6e3brivaQs3bGpzcdf8t3vnb3bfszl3t3Vf91afMxbz8tcEN04u9xu9M4Fud3kr91O4di/N90ft92TZc3wdO1Nf9uVCNyxHd23F84Twt4QP+3UJMtfg93gqO0xsO2+Oq2x/u3Pmd1hBejHx9veVd1dDNvT1N4gZtxEM84Wr1rG190tJd4DTs1Rlu3jt+1jnOmz/+sZar4zZexDWa4+yL2xxs4D7+ykl5uJI8sjx5wa1b44UM5EqO5f495kLdYPft5Zfs1H2NziV95Tv7tixp3X/Z5UT+5dgdxm8Ou/0ss2be5GhOz0FruLus4tmt5nvs53QO6C1r6IEK5bu7wTBN5QgcrGQu55ybaNNNdu//LLIDa75TzueWjb5di7FZHuSIPaS1LGYfLOosTur1vLZhXdqnXdM4PsytHuqePuombtaK3tIAK9UNXt+frm6uzuuw7uuZDefdLOz/TeyUvtv1uuv+3Osdzt5UndBwLbzWftygHtvLeuSXHuds6+ARrM2d7u2MTe3hXsgArNW/TtKOzeY6re7FPu3gDrbx/uTN3uMmjOIJbLBgDb/FDdyaXuWyrqPM3s7jjdDGfOgDXfCxvunb3sYIv+y9OuPF7dfJ3t8W37bf+954rskWftEdn9uK7eQjnbOMDvJlqpoZz+FZjvIxzukfb81R6egOf/EbT/FkfPIqz98PL73gHfJB/7zwUd7yLS7vE1/zS//zEM3zRx/JI6/A8YrpfpvzRA/P7a3WLx/pVY/1az70M3/zkMv1XK/SbozMb8zwpEzaGI7wGk/eTO/WqY6/3C7gfT7vxkr3LJ/T6/z0xpniKGzKC17Fng3w/+zNAf7oEN/4hX/iFzqira2XbD/Oq37euJ7yzannbT+gkh3hVIz5NH3NPv/3Qi/wDb/SfZ/LiZ/ti7/Kkc/ctG/ziL/lFU76OT/Few/3rO70Ih7Nk87xct/Qt0359O3v3lurCv/1Ww/8hN/5oJ/7t62td6v7YH/Hqw3rFP721//5n3z9n8371T26Sl/xkD/rLv/40jv+5F/i5v8/5JJr6ctv9+/v8cuN/zfu+fLvxYUu08QN5vNv23g/6PtP5Iyv/jIN/29N3GA+/7aN94O+/0TO+Oov0/D/1sQN5vNv23g/6PtP5Iyv/jIN/29N3GA+/7aN94O+/0TO+Oov0/D/1sQN5vNv23g/6ODc/Abf/E4c/+7O+p+P1sEf9BJP7+Uu7uzO/dT/7JVv0iZd74IPvvzs+nRt6um+1I7f9MNe/bbv/Gll2q5P16ae7kvt+E0/7NVv+86fVqbt+nRt6um+1I7f9MNe/bbv/Gll2q5P16ae7kvt+E0/7NVv+86fVqbt+nRt6um+1I7f9MNe/bbv/Gll2q5P16ae7kv/7fhNP+zVb/vOP5pMHb6j7/syL9c37e7Dbs/aH93RfpRfrvaq3/de7/tDK+QI/tw03r/EHb6j7/syL9c37e7Dbs/aH93RfpRfrvaq3/de7/tDK+QI/tw03r/EHb6j7/syL9c37e7Dbs/aH93RfpRfrvaq3/de7/tDK+QI/tw03r/EHb6j7/syL9c37e7Dbs/aH93RfpRfrvaq3/de7/tDK+QI/tw0nuY87vzwPvxEjt6Zr+rrPedHbYSBrvUATvZEjt6Zr+rrPedHbYSBrvUATvZEjt6Zr+rrPedHbYSBrvUATvZEjt6Zr+rrPedHbYSBrvUATvZEjt6Zr+rrPedH/22Ega71AE72RI7ema/q6z3nR22Ega71AE72RI7ema/q6z3nR22Ega71AE72RI7ema/q6z3nRw3ZZS/2pc+h54/HJA/f7X72pv+yg7+a2Y2VYT/68+/88C6tRW76Lzv4q5ndWBn2oz//zg/v0lrkpv+yg7+a2Y2VYT/68+/88C6tRW76Lzv4q5ndWBn2oz//zg/v0lrkpv+yg7+a2Y2VYT/68+/88C6tRW76Lzv4q5ndWBn2oz//zg/v0lrkpv+yg7+a2Y2VYT/68+/88C6tRW765Sz5x5/3WZ+82z/60Mv4Xhz3Jt/tyiv58c/gzy3mPP60jO/FcW/y3a68kh//DP/+3GLO40/L+F4c9ybf7cor+fHP4M8t5jz+tIzvxXFv8t2uvJIf/wz+3GLO40/L+F4c9ybf7cor+fHP4M8t5jz+tIzvxXFv8t2uvJIf/wz+3GLO40/L+F4c9ybf7cor+fHP4M8t5jz+tIzvxXFv8t0e7AXN1GA+5wZf70s92umu6rvvx+k+w1a+7mjv+Kf//Xhs6w+e7t0e7AXN1GA+5wZf70s92umu6rvvx+k+w1a+7mjv+Kf//Xhs6w+e7t0e7AXN1GA+5wZf70s92umu6rvvx+k+w1a+7mjv+Kf//Xhs6w+e7t0e7AXN1GA+5wZf70s92umu6rvvx+k+w1a+7mj/7/in//14bOsPnu49LPlNT+iOv7LML/YdC/U+TfxgzgR0z9uGiurN78Soj8fmHuwLb4Rm7/u9r84dy/xi37FQ79PED+ZMQPe8baio3vxOjPp4bO7BvvBGaPa+3/vq3LHML/YdC/U+TfxgzgR0z9uGiurN78Soj8fmHuwLb4Rm7/u9r84dy/xi37FQ79PED+ZMQPe8baio3vxOjPp4bO7BvvConetSm+ianeQ7//zZ7+YPHuJBf+9SG/fKbsljXOin//x7/uAhHvT3LrVxr+yWPMaFfvrPv+cPHuJBf+9SG/fKbsljXOin//x7/uAhHvT3LrVxr+yWPMaFfvrPv+cP/x7iQX/vUhv3ym7JY1zop//8e/7gIR709y61ca/sljzGhX76z7/nDx7iQX/vUhv3ym7JY1zop//8e/7gIR70TsDb6E/KlT776mzk+w7sth3+vx3e8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78chze8YvU2JzrEx/fTD7GhX78hl/QS+72rr3v0orU5AzpIC7XbY7qd07uJG/aYU/y/B7+O33P02/4Bb3kbu/a+y6tSP9NzpAO4nLd5qh+5+RO8qYd9iTP7+G/0/c8/YZf0Evu9q6979KK1OQM6SAu122O6ndO7iRv2mFP8vwe/jt9z9Nv+AW95G7v2vsurUhNzpAO4nLd5qh+5+RO8qYd9iTP7+G/0/c8/fo/8Eid3YCv3nnf/MHr+1Se6nmu4ace+jsd5vdv9vP/7sofvGtf/hJP77I/7tLu4Uvd/MHr+1Se6nmu4ace+jsd5vdv9vP/7sofvGtf/hJP77I/7tLu4Uvd/MHr+1Se6nmu4ace+jsd5vdv9vP/7sofvGtf/hJP77I/7tLu4Uvd/MHr+1Se6nmu4ace+jsd5vdv9vP/7sofvGv/X/4Sj8gDL9bCb7EiL/iqzbHqf/xzPuw2XdCGKuNvLaloHfymTtxRz9orb/z2re0IPv9inu6Cr9ocq/7HP+fDbtMFbagy/taSitbBb+rEHfWsvfLGb9/ajuDzL+bpLviqzbHqf/xzPuw2XdCGKuNvLaloHfymTtxRz9orb/z2re0IPv9inu6Cr9ocq/7HP+fDbtMFbagy/taSitbBb+rEHfWsvfLYLOhuj/5Zq/eLXPteHPffPv1MoPeDHvDKm+QgneD5Lq11//v8DdkgHeb0nuvxK9bKH/j9K+m1r/7HzwN6P+gBr7xJDtIJnu/SWve/z9+QDdJhTu+5Hr9irfyB/9+/kl776n/8PKD3gx7wypvkIJ3g+S6tdf/7/A3ZIB3m9J7r8SvWyh/4/Svpta/+x88Dej/oAa+8SQ7SCZ7v0lr3v8/fkD3i+X/ris+xgw7taS7NaT34pCzfpR7xrQ/iO9/vw57m0pzWg0/K8l3qEd/6IL7z/T7saS7NaT34pCzfpR7xrQ/iO9/vw57m0pzWg0/K8l3qEd/6IL7z/T7saS7NaT34pCzfpR7xrQ/iO9/vw57m0pzWg0/K8l3qEd/6IL7z/T7saS7NaT34pCzfpR7xrQ/iO9/vw57m0pzWg0/K8p28UE/lMG7/0L727W/fjt/0hJ7u1i/N/86xiwzsNP8+3MSv3vbs+/U/7Ji807EP7MzP7zww2N4f96iO9HbLz//OsYsM7DQ+3MSv3vbs+/U/7Ji807EP7MzP7zww2N4f96iO9HbLz//OsYsM7DQ+3MSv3vbs+/U/7Ji807EP7MzP7zww2N4f96iO9HbLz//OsYsM7DQ+3MSv3vbs+/U/7DFfwqNf+tnv5so+6qmP6jwe/HUe8yU8+qWf/W6u7KOe+qjO48Ff5zFfwqNf+tnv5so+6qmP6jwe/HUe8yU8+qWf/W6u7KOe+qjO48Ff5zFfwqNf+tnv5so+6qmP6jwe/HUe8yU8+qWf/W6u7KOe+qjO48Ff5zFfwqNf+tnv5sr/Puqpj+o8Hvx1HvMlPPqln/1uruyjnvqozuPBX+dUrvfqXPqATdceHuZHCeMDX/fQjpXCffmDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+bYSpLeSDrt3uHvi2z/4L79r+DQh6z+U7j9SjHvdC3v7Rnv5yoPdcvvNIPepxL+TtH+3pLwd6z+U7j9SjHvdC3v7Rnv5yoPdcvvNIPepxL+TtH+3pLwd6z+U7j9SjHvdC3v7R/57+cqD3XL7zSD3qcS/k7R/t6S8Hes/lO4/Uox73Qt7+0Z7+cqD3XL7zSD3qcS/k7R/t6S8IeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tu4EeV7Uws35tG78Or/64Tv8tp7V0orRrw/ago3HWr/wvb/I088E4B/a1I/gz/3u+T79/Zv1tw/D7Q77uI/gz/3u+T79/Zv1tw/D7Q77uP+P4M/97vk+/f2b9bcPw+0O+7iP4M/97vk+/f2b9bcPw+0O+7iP4M/97vk+/f2b9bcPw+0O+7iP4M/97vk+/f2b9bcPw+0O+7iP4M/97vk+/f2b9bcPwyv/7IWe1bLN+VY+/Xlv9nN+1Gt/692f7rD/3NKu7Kpf6ktd76F/60U/6nrv5h5+9l6c9mbv+0bv7DKO/KOu927u4WfvxWlv9r5v9M4u48g/6nrv5h5+9l6c9mbv+0bv7DKO/KOu927u4WfvxWlv9r5v9M4u48g/6nrv5h5+9l6c9mbv+0bv7DKO/KOu927u4WfvxWlv9r5v9M4u4xj9+ZVt+e5f5nPO9wP/r9BMDe3DLdfYjM/eD+nsj/qjHf1a3v4v2/vtr9CJju/jzv6oP9rRr+Xt/7K93/4Knej4Pu7sj/qjHf1a3v4v2/vtr9CJju/jzv6oP9rRr+Xt/7K93/4Knej4Pu7sj/qjHf1a3v4v2/vtr9CJju/jzv6oP9rRr+Xt/7K93/4Knej4Pu7sj/qjHf1a3v4v2/vqD67BDtgnDuPbv+7PPcGKb+tTD+zS7vbJ7/5ZH/br/twTrPi2PvXALu1un/zun/Vhv+7PPcGKb+tTD+zS7vbJ7/5ZH/br/twTrPi2PvXALu1un/zun/Vhv+7PPcGKb+tTD+zS7vbJ7/5ZH/br/twT/6z4tj71wC7tbp/87p/1Yb/uzz3Bim/rUw/s0u72ye/+WR/26/7cE6z4tj71wC7tD07c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/g0LvslU/c2O/Ww032sk3O4Y/ga6/hMe//4Cru/l3/xW/yS73ybX76yO//Pg/vi27wxB31ys/6a3/rBM/68Y3oWb96xB31ys/6a3/rBM/68Y3oWb96xP8d9crP+mt/6wTP+vGN6Fm/esQd9crP+mt/6wTP+vGN6Fm/esQd9crP+mt/6wTP+vGN6Fm/esQd9crP+mt/6wTP+vGN6Fm/esQd9crP+qO55HXesRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tKit79XfsRN/8DJt9s/t/Gj9tNRFXdRFXdRFXdRFXdRFXdRFXdRFXdRFXdRFXdRFXdRFXdRMRV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3URV3UVQIFAAA7', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-10 10:22:43', '2026-05-10 10:22:43'),
(8, NULL, 'BILL1778430067753', 'CUST1778430069161', 'TXN1778430069161', 970.00, '000201010212306101152696314020436540217BILL17784300677530317CUST17784300691615204701153037645406970.005802TH5922TestMerchant17563798076007BANGKOK62470523202605101121092580000000716TXN17784300691616304B255', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-10 16:21:09', '2026-05-10 16:21:09'),
(9, NULL, 'BILL1778430233443', 'CUST1778430234617', 'TXN1778430234617', 400.00, '000201010212306101152696314020436540217BILL17784302334430317CUST17784302346175204701153037645406400.005802TH5922TestMerchant17563798076007BANGKOK62470523202605101123547030000000716TXN177843023461763048597', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-10 16:23:55', '2026-05-10 16:23:55');
INSERT INTO `scb_payments` (`id`, `bill_id`, `ref1`, `ref2`, `ref3`, `amount`, `qr_raw_data`, `qr_image`, `transaction_id`, `status`, `paid_at`, `expires_at`, `callback_data`, `error_message`, `pp_id`, `merchant_id`, `created_at`, `updated_at`) VALUES
(10, NULL, 'BILL1778432619804', 'CUST1778432620931', 'TXN1778432620931', 479.00, '000201010212306101152696314020436540217BILL17784326198040317CUST17784326209315204701153037645406479.005802TH5922TestMerchant17563798076007BANGKOK62470523202605111203410310000000716TXN177843262093163047875', 'R0lGODdh9AH0AYAAAAAAAP///ywAAAAA9AH0AQAC/4yPqcvtD6OctNqLs968+w+G4kiW5omm6sq27gvH8kzX9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNarfcrvcLDovH5LL5jE6r1+y2+w2Py+f0uv2Oz+v3/L7/DxgoOEhYaHiImKi4yNjo+AgZKTlJWWl5SQmgucnZ6fkJGioKwDBqespZ+kmBqqnq+doZm7oCyrpa2zq7ydFKOuEbLCz7MmwcvHt8mvwr4csMvWCbCwuMq/IsfZ2R7az8LQoDPr6NQI4a7Y2uXa0w7V5+8h4xj9KdUH9xD3He39zi7xyzgK7YEVO3zCAteO3wxTORz0HEEvsOTLy1DiHBY//iNn4bSDAdPV0KeZUsyPBgiosn/9kjmXIhN5gjPXIsZvNmzJwi+dE09zDARJYiiDps+DLjUZUYKkrMaawjVGEgA/Z84FRo0KFBSRgFilTeT4tdrSn1ORUZzrRZ2bokG/bpWbhM6coEWxdi2Z0oV4418BXr3wZusybNS3Hrxw3geLTdu7SwSb5vAUPGe9fu5JqIr+qN6xe0V8XKei3W8Vh0S7eetaqm3Dp2SxaBi17+wLU049M5UndezbZ1bdeIhxu/7WE4COW7QTdurrP34OOSM1t2jpy4de2b0f6GTe174tchckdvyhuH7+1VpwrPbp79bLPil2e3Tx5/8fT6+Nv/WN+dYNUFeN1++WnWF2YEEgbffdDJ91l9uJF2Xn+6oTZdgwMmiGBl3HEol4ESFghhZAuOdqBtKXYQ3zCmXSjdXCSeCFxa763YIogM4uigBswlR2FU82lEo4ojfughgDo+Z+R2THLmZIbYybijiEKC50KOamEJZZHlaWjlKDdWCOSUZFYZJZVaUhcmVUMCFKSLb3pXon51dthemm1u+aWZV3a5pJR7sqnnnwrqeFihcnJJp5d2OopnjXvmKeYIaw42pimZVkpkoDAe6mGiCz4JKkZHvnjkpX6O6h+LcbrZaZKCKhoOfbTyWepag84K6YyIWgrmrVpSWmuTrH4q4K6r/3qaUKzEhiJbhMLy+iujYvG4LLRzdmjYg8eeuWmxJjKrqa3fGhpplq/imi6goQKLrbKTSlquseQu6u6z4WrrLL2cjvuutOfimytlhP7baLXuDuutwgUvvC7DGMY7rZo9upqtkrJSqa+5DidbL8Co3ulrwACrOu/EqUZMrckoyhvyw6AeLG7CLoOMcLvoUdwrkijf6liwA8Mqsq4VN1u0wULXjPPHIcass4Ur88x0yRLHODXMOZcsldZVI9lxrDTf/PTWYDdM9tlis5xt0FRvfOaPGHvNb9InL123zSObLbfMTaet8dXq4f2s4OEdDTXX/jrtM+FoG27B2KYm3njbO/9IvnjeUWPDNtJ+W4035j62vDfjY/88dNq0Oa60xSs+ei/Rn1fQt9Gpd9u6P9HarbfHgLOeb+aQh0b38JP3TAPqXxfequjB9wv989LPTLrtsbOr+Oivz6C85mXbtPvs4W+OZs/OU+/6qRNmXL326svQ/ekhbfv9728fbzrw6HtOvqjXa1w61XGvc5RjHrKyN72/4c9+WSOZ2u6WPgfCDm7oQuDO3heD+IVuftaq3wI/6DsQRm9/lKud+xDHt4uJ73IENJsB46Y/BYZwhiOUYe5KqEK0vRBoOhyCBt+2kfFZ0IYJ9CANi1g5/g2Rc9s7IfLgRbcdpi6AASQVEUnIk8z/UfFwTywTBi8oQSii8H/tm0kTIQgu+iURKmEz4xelFkYvxtGNc5xgG7H4NRM+EIwCOSIePXJHOHaRjoPcIhPfKMfbtTCPOVwi7TiIxA0p8owrtJcAE8k4Q2ZwkRQkWP/8KEhyiBCNbNRiDw9Zx1MSL5WY7CQjD7jHUF6SlJ404g2zeMtMqvFlrCSkLp34yz5FUXjr0iQfRQlK0NnIlMCc5TGdqUr/QbOVgVSmEmMZuUausZblI+MyczlNbI4Hkb6U5BTVOLx0FhOd6+ygONVpOXfCs3jBsZ45r7evfLIznrwj3zx5KM929tOR/7xnIR9nTn0GlJ+zKyg+95mygb5T/6ANpag/DUpJhEpSoRJ1qCs/ytGKMvSiIyWoRU3Kvo3a854hJWlERfpSlwK0oyedaEltGlOUYvSgzWQpRGcKU6DK9JwLzSlOhapTpB6VqLSUTNd2CtKfMjWoUx3qQ4uqVI+2NKlVteaAnrrTrS71qjS9qValSlaqptWqUcVqWN9w1rXdD60f1SMAk7lN8GHChzWV31zd6k1y3rWGXsXlXoEQV4j9tazD7GlN98WawwYhsTY7H1ur+cgImo+TQZQsYvu6wcWqta7aHGwkE+rZH1D2b5blamB7adregbOzqe3BauvX2rGSNqOFXastmwrI2toWtECMoWt3K9gyyha4tP+tRPekmL+bYtaKjoRucOHHWUwRU7p01eMzp9sqsYIXln7dUPKyy7HtGhWy2vwuM5lrXHGOF4bFVSl2U5rG2T62u+2V5Xwr2M22Kpae3NXvNzeJXwBbV4i69a5/3/vH3JZ3jN6Tr3pLeV8CX3PBu+Qvb8v5X26KF8LcUi5rUZthCuMOvgVmbAGv1VgWN7CrAf7hei9sWLC+VsQ49m2AMSvNEMvuip8EJ4fdad3m6hi5Cu6xgJf7x8/C8shIFHKFF5hbK4vVxk1GsofzWwPq1li7XjYyibOZ3jIDd8vEdQ9e2TvlG4iZylA+cYJ5mlcGOjC2l/1yP0ZZ595iD2tdlvH/nkMb42dm+cy6ZfOBA/1jJztYYEPGLZklamW7XrqSa6aro91M2EgbeMNyDq+TAW3nRMty0WYG7JPZqmQi/zbCmx5gnEd96PqqGs2kVnOUPQ1sXPPY17A29X+MbejN6prCVYyvloPt4hzLWtTJXh6Me5lkFINYo/TtdbXHAWQ/95HYlA6ney0J1ReHGsvNq7WgYy1oVL+73R82JheDWdl0W3vdvhPzimltFUbDWXcdRiWezy1Mfae5yv2mt7cBTvBWn/bRRV7lwR+MboVr+sPwzjO7KR5vvEaW3OPENsYTrnEXvrnh5HV3njv+72IHnOS8vDivTS5sjNr75uPutFxB/+3ziQOd00G2Z81TfuWV/xzAMZ/3zIMO6ZFj+t7mPnnUORlug+N7fRouNMRx2HLRTnvj5LSjyLEucKqf987IXDo3/e1saCN87TP2ceD620y6qxjZX09h2OuuZxrLG8GAHzizbV32aJb46fn+O9Pj7uqdEz7XRr17vRWvLraDm+XdfrzYZ11xSC958M9Nu9arnndJuxzmDqe86wWvdDh9vsFoT7HNt53zQWdb88YreLS3Xl2jn13zWbc48Oe291t/m8uwJ3nv+X1ss66+tNqe++I7P2zcTz3ymM9s5V1edFezesAY1n7fXwlm6wef+6lv/++TnvnvL5zoqS6/+l/esv+me1+pI4a+0A8fffL3cKFXf9LGcztWafh3eez3f3hGdlkFftdGY/r3gNUheaynfPcnYdTHcW2mbrIngB9If5YGcvs3SdiXgBcYXxV4fB41acg3gdPXgfZlftfneelndQR4XJJHerUXZh6ocjSnehk4dpB0fqj3fj04g8klffMnRjGoWQhYYSwYeC1oYtT0hAn4fAyXe1u4Ok14TcznY4PHYM9mSUc3aF44bbt3Y/EHgVHIZH7HhIXHbfzXfc0Gh2Xoe0eohqdneFCIguE0fo3XhjXYSny2fly4fPvlhoAIdl3XfIo4gmPWYveHh2HIiJJog2+HdzBod1eogIUoenv/WIBjeId1KId26H98mIlfGIKpeIKPCFuQR36RaImoiH6qqIlOh4kL6ImvFnLiB4pkSIokKIo5eIigSIUfF4iDs2yOCIvRNYDB2IBa2Io6+ItzVowm6FSl9oyfmIec93r79n6IaGFC6FhEmIiKVk8BOI5T6IOTSIEyCIngSIenp43oWIt65Y7K1ou7do5QV4pVGIe5aIvYeIleh5DiaICT54+yGIsHSY2E+I501meryHV/FnvsWIKjx5D2CJHSKIKbKJIRaZCmqI8ciYPruGrt+IPfCIwet43z6ITHZY6DmJE9N4rpOHSI944ueI0TOZBK2Iwz2YkUmX2TyIz2twUT/+aAQIiS1QiPvLeCiBaSUzmN1KaUV+CUVgiGunh14Zh7RPmT+RePyBiQXNCVggiVMUmW0ViQ8JeEH4mVV7mM24gFa6mCX/mUxCdu5DhaSwmXped+W2kFetl9t8WNcfmHgHmR+1iXg8mBx6gFiFmYj2mY5diWNEmZoQiAAnmAbvkFlmmIjYaXfxmT+TiXbneSkemYoMeSlWmVffmKURmW/5h897h935ZpkwmWfAWTjYmEv2Z7tpmTJWmcxvibsJmWQ3kEpDlaL0icDpmcv/iWXombtLmclJh4jYicrsmYWSiX4bebZhdqVNiHWrmQEkcE0Clz3QmaILidPCh3LVmJRf+4hCOpMmXJl6+5mNKJlgDKnP0HmXrIgCqJc/L5kHBZfAh6exp4lGtYn6GZngSKlMfnkayZmhGooXonkdY5fHN4lXspokE4XMGJmmgooItpoKVpoc6Zkphpn/CZkJIJk3cpjL64kyjXmnBXkyCKkbGpnvholjfqm9Don/SZcVQJhyvKYDg5oBJojT+qmrf5meQpTWIInk5qlLNHjOVmeYCnf5+mn0BqfFvaeiZqnrvYnFEKpkUqphy6mvGJhq5ol2mapKfofEeKoTN6p0aan0g6nsc5nDC6iH7phxu5nuUpnmHKn1lJpmpKqHZqo4HIpXvqpYq6pNnpn1WKnwBZp1T/p6WEeaZfyqhu+pK1GZ4dKp6CWZ0VGqIaiamdiYE06pOC2qAkWahCao4vGppsuJ3pWasJ6qEgaZIEuaLuyatByaJDSKvMOqwPeqvGKoWuuqttKpOzOp+xqpPYKKxGuKhuo6q5KpRYyKra+qHXuXno+qrgKqRSNq6mR6d6Gp8bqKPveYMV2aURd6qT1Zbkmq08iqzQyqzq6qO6KY/uiq3w+oagKq+3yJ7eWrDc2nb9+q2MF66iOpvYSay62qIQO6c7CqEYu4O4uK5sOkHK2qybuq2XyZxQurKHGq88KasoS6gqa6oOWp1KGrIS6rKeyaCn2YX02LHnWqD0qrOieYYU/0uQoTq0/cmWHSm02bixUWur5bqwSCujqDqy/BqYJuup73qzVcuzSfuxaOmrWXueCgurT5uVl8qdjzqL94q1cJuw9ym2a0uypkmz3cq1jUq2WkuhE/uzaZus6MWpSguZYau2VNukRFupVxqgeFoYlNqjlGuRypmUGvu4VAqnkvurp+asCpmMTJq4mRu3m0uknfu2n3usJJqvFsi59QieqAus0tq3l+u5rAu6MXuEt5uCgGu6Iyq6GjqmUpqGfOexjHa8OZq4UpeliEu8Y0mXzVtynKiOATud2zu5jie7q0u7QLm7XjutyZu9jvq6iUm50Iu8o7qZkFuxxWq+K6m9y/8bsaFLvW5Luo4bvu87vjUrv4x7tpr7nejbmrCLu/VLwIq7phcal3Y7utqZwJwZu1NaojtLl9Y6wL5rqL+7Usr7t4MLqLS7wW17tEabmSDLvbxYtIsrpyncwQOppSVMuCdswzCMvzesqxCsvxLcp/eburp7uupLtwocxAw8qRlcvAoav2hrstY6w1P7tSy7oAesdkqcv0x8sirsp1U8vxVstS2rwwu8wTlrv7z5wdlbxg+7w9KbrhPKv3L7xoXLvCAssGsZrZ1KsEVsuauKxlScp0E6pIMcvSMMwGdspV7MBKTqwYA8qDnMxXkbx17MvlhruBHqnX7cyHf8wj7Lpjz/PK89bMFlerFXq8W9+aNQjMmNe7em7MCqvLcU/KGg7LT1asewbMo4arOlG6clKMvtysdXDMQCXL2rrMsiK7y93JOWDMdrXJya3MZFTMyC/KSr/MrFHMvwi8SS7IwAOc0uLM182rSqpbAa3KpS7MlTLLDAu83/2ckhfMQM67fuHM54y8Eva8xubMWOfLiBGsha/M0rbKY4TMjNTMTky80ynM/+/MjUucVd/MM9a65SWcusaM+43MLoac1jq8ZsDMkZC88mnMhNnNAL3M8X3NBLFtCInMQxGtI1PNIPXdJHfNJzC6lpTL8Aq64V/akZrc+1m8xlasZkTM57a85L69IF/32gLS2zYuzANe3DKV3UJIzO+Jypzju9Lpqimsq3Y9zVVBDFSX3Js3ewNq2vQFzN9nyTG92PUijSPa3ITNurXM3I6by18WzQThDW/brTdP3TNEzW2tzXKHzXULDXBD3WCBvNnZnWDsuu7bzWwdzWDwzTcP2dBjuMfo2on7zHQyzWU52bTm3Z46y3RUnHWB3XpS3H1Hqt3Rzac0zRmk3VSW2vrRvYKLrUzyycqGu9rdywq72h9ayqigmzb43Umjm86XvaEo2tkZ3L/juzFluVkn3PtJfc1Sq4Xy2xYsnXTGuGzN3Yon3c0fnXHq3UzK2yxj3IdV2yjz3YqfrbkSvfHP+b2uBdxxft3fcd3cjc3vAtqIfN0h9t1c/K3YgNx84drNPtyt3rzesrzu/t20H72bltxIoZ3rDN0zZZ3mgt2/FdwP96zqjN2hd+2VVdqhE8yhNsx0hn1HmN3JbK4uJ94qL8xSp+vjE+z4n92kIc4858vW7NtgtNvzie4y5O3t5L5DKOpYt9yDNtuyiechA+2mWd5EqOvOw817nb0FXOuKW842hK5D6e4UBL0qys0IbM5SXu3lCO5S5p4OXW5gXO0bad5qqr3QPe5GRuUGIe4k2Nvc9943Vu515+rAYc5SbewE6s2vX91NrccRgt4dLNu5I60+zt0GU72kOt53h8y2z/buQBrueavtveiNIIrObgTOdMKcKmLenPK9gHLdRXnt06Tskr7uYQXePA7Or/G9U6LevLHdOa/uhQrtFIDtmuq8cM7etwPuufvqwtTuPFzuoRzuOUbuYaTt2ibuKE/uGBvsz0PO3bveup3uvmveQCXt3FXc7ELs5Urut/Su70jd2TncfHftsIfefrDd37e8z4Gunq/ObgnufcTtp+PuL5LeK6t+37/u93TctM/ucJfu8D39keTtm8Lu/BHe79HfCQnuLvzugQv8+tbvHsrO0U7u4ab+WrTvFqreAtT+D7LfJb/uCoSdyVreUpT+IFb9Eyj+f/bevKbvMgTuGFjO8E/4/Zxr7zkVrmgD3cykj0AB3kLj/x84z0B77utM3wIw/wID3j3c3h4z3lQY/StU3K76zvQk/NpC7jva3oL87v7f7y1u72P5/xJ+/fGBz26yzXZG/WdH+WRC32lU6L4tr2aC/sPw2zAGvpyx7bwO71GQr2ocz3i970C4/x0Cz4lT/51N7av975oD7mwvnLYQz4m33Ng3/tzc3WP97Ojh/J1j3kcl/1yX7Tlm/6p96eOG/Eoz/0mV+jui/65o7wWj3hkwzk0F5O6p7NNJi0lbz6Vc7nWh7nt+/VO5/y0O/x1xX6LPy93c/J1y3TyM/zZz7uqi7w30/Q0o/oc/7lK735/P+96Yrf6dGOuWBbfZHv/oWe9ctf+DPvvh1t/0qP/86v/7z8/vV//fsK81+F/75M++k2/f4v/vCP14Jc79qPzd8u7VA1/f4v/vCP14Jc79qPzd8u7VA1/aXZ5X5v9cgu1Vov5yaN7Cof8ug+/VJZ+qWf/Rtu/F7N6ZN+8Gu/5pn85Fnc6JOe/KX+xPsK81nt+Zju5Awe994O8/Ae61ov5yaN7Cof8ug+/VJZ+qWf/Rtu/F7N6ZN+8Gu/5pn85Fnc6JOe/KX+xPsK81nt+Zju5Awe994O8/Ae61ov5yaN7Cof8ug+/VJZ+qWf/Rtu/F7N6ZN+8Gu/5kbQ+Nh8/rjK1Uv/n92N/8R9LtAPP9ECvf2WfvWQT/i1L9WEPdEC/fATLdDbb+lXD/mEX/tSTdgTLdAPP9ECvf2WfvWQT/i1L9WEPdEC/fATLdDbb+lXD/mEX/tSTdgTLdAPP9ECvf2WfvWQT/i1L9WEPdEC/fATLdDbb+lXD/mEX/tSTdgTLdAPP9ECvf2WfvWQT/i1L9WEPdEC/fAcz9Rdj+0xn9UCDf1Xn/Db3/hsj+GZjvVyHv/+nvwbz/pQy+mTHtFjDtUHn/DYv/UXv/GsD7WcPukRPeZQffAJj/1bf/Ebz/pQy+mTHtFjDtUHn/DYv/UXv/GsD7WcPukRPeZQffAJj/1bf/Eb/8/6UMvpkx7RYw7VB5/w2L/1F7/xrA+1nD7pET3mUH3wCY/9W3/xG8/6UMvpkx7RAYzsYH7+Ic/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5bzrp1V7tws/x5i/x+O708A7Gwf/5E230Xy7l6L79Ou/px9/zZ835hp/AqBzvr4/55vX7nh3+sy/cLZzob/8q/lKO7tuv855+/D1/1pxv+AmMyvH++phvXr/v2eE/+8Ldwon+puIv5ei+/Trv6cff82fN+YafwKgc76+P+eb1+54d/rMv3C2c6G8q/lKO7tuv855+/D1/1pxv+AmMyvH++phvXr/v2eE/+8Ldwl3798L/7EeP7Lmv+ek+97Yf69T/nLxv9rVu7I3f92pP8sp9/UGdwOce/XPf7TCO+gwe60W/1YT9ptne5+s/990O46jP4LFe9FtN2G+a7X2+/nPf7TCO+gwe60W/1YT9ptne5+s/990O46jP4LFe9FtN2G+a7X2+/nPf7TCO+gwe60W/1YT9ptne5+s/990O46j/z+CxXvRbTdhvmu3CvMsOrd6YHv843bvqneX2Pdl4r9K8j+nxj9O9q95Zbt+TjfcqzfuYHv843bvqneX2Pdl4r9K8j+nxj9O9q95Zbt+TjfcqzfuYHv843bvqneX2Pdl4r9K8j+nxj9O9q95Zbt+TjfcqzfuYHv843bvqneX2Pdl4r9K8j+nxj9O9q95Zbt+ZXO9PTtjoLuXojvcxXfpHDf4Pb9L3n8Vm2+xFz9XTL/tnj9vg//Amff9ZbLbNXvRcPf2yf/a4Df4Pb9L3n8Vm2+xFz9XTL/tnj9vg//Amff9ZbLbNXvRcPf2yf/a4Df4Pb9L3n8Vm2+xFz9XTL/tn/4/b4P/wJn3/WWy2zV70XD39sn/2uA3+D2/S95/FZtvsRc/V0y/7Z4/b4P/wL53KsyvxC47yyF7+E93z7+/orZ/4qTy7Er/gKI/s5T/RPf/+jt76iZ/KsyvxC47yyF7+E93z7+/orZ/4qTy7Er/gKI/s5T/RPf/+jt76iZ/KsyvxC47yyF7+E93z7+/orZ/4qTy7Er/gKI/s5T/RPf/+jt76iZ/KsyvxC47yyF7+E93z7+/orZ/4qTy7Er/gKI/s5T/RPf/+jt76wa/yCYzKnh3+3770XG3qNK/07c/LJT+7Xz798+/tZ73LpVn6CJ7AZuvs5M/bQv5VHR7yzL73m//c9c9s4UHN//htvP3v+XjftWev9O3PyyU/u18+/fPv7We9y6VZ+giewGbr7OTP20L+VR0e8sy+95vc9c9s4UHN//htvP3v+XjftWev9O3PyyU/u18+/fPv7We9y6VZ+giewClb/2da+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9pkM/65f+sP+2O4r54Qv/r6/9m+qb2Nu9kAv3MAN/f3/nsnTf6YaN+ZmD/TCDdzQ3++ZPP1nqnFjbvZAL9zADf39nsnTf6YaN+ZmD/TCDdzQ3++ZPP1nqnFjbvZAL9zADf39nsnTf6YaN+ZmD/TCDdzQ3++ZPP1nqnFjbvZAL9zADf39nsnTf6YaN+ZmD/TCDdzQ3++ZPP2c3/GZ3vcdrQR1T9NTr9h2r/LWnuhOXvwxDf9FUPc0PfWKbfcqb+2J7uTFH9PwXwR1T9NTr9h2r/LWnuhOXvwxDf9FUPc0PfWKbfcqb+2J7uTFH9PwXwR1T9NTr9h2r/LWnuhOXvwxDf9FUPc0PfWKbfcqb+2J7uTFH9PwXwR1T9NTr9h2r/LW/57oTl78MQ3/RVD3ND31im33Km/tSFD6Ny/+Jg/rCfzd8m/2yl0GpX/z4m/ysJ7A3y3/Zq/cZVD6Ny/+Jg/rCfzd8m/2yl0GpX/z4m/ysJ7A3y3/Zq/cZVD6Ny/+Jg/rCfzd8m/2yl0GpX/z4m/ysJ7A3y3/Zq/cZVD6Ny/+Jg/rCfzd8m/2yl0GpX/z4m/ysJ7A3y3/Zq/cRdDvb4rb/i/nvHzW4I/gUZ399e/6mM7LwB38QO3IUs7yuIr/kx68mYzpvAzcwQ/UjizlLI+r+D/pwZvJmM7LwB38QO3IUs7yuIr/kx68mYzpvAzcwQ/UjizlLI+r+D/pwZvJmM7LwP8d/EDtyFLO8riK/5MevJmM6bwM3MEP1I4s5SyPq/g/6cGbyZjOy8Ad/EDtyFLO8riK/5MevMz+2Jb+8IJs6Kg8+1Qf81ndtS0c7Fhsy9n+9gJt6CZf/MGOxeCv3l0L3N/t2rWO+qA+7EXv7BVe88cv5fEP6g8vyIaOyrNP9TGf1V3bwsGOxbac7W8v0IZu8sUf7FgM/urdtcD93a5d66gP6sNe9M5e4TV//FIe/6D+8IJs6Kg8+1Qf81ndtS0c7Fhsy9n+9gJt6CZf/MGOxeCv3s9f/7aM5mXe5bzvvlT/9LX/+Zk87IT97Oa1xMEO61Y/9/P++E2g/VhM8uo/81L/ju71LuXMXPTPeessP8v57/3CT/jif/UJL+VKoP1YTPLqP/NSju71LuXMXPTPeessP8v57/3CT/jif/UJL+VKoP1YTPLqP/NSju71LuXMXPTPeessP8v57/3CT/jif/UJL+V6AMpZ7v9Qq/37mtUdj+vD7gagnOX+D7Xav69Z3fG4PuxuAMpZ7v9Qq/37mtUdj+vD7gagnOX+D7Xav69Z3fG4PuxuAMpZ7v9Qq/37mtUdj+vD7gagnOX+D7Xav69Z3fG4PuxuAMpZ7v9Qq/37mtUdj+vD7gagnOX+D7Xav69Z3fG4Pux+IO3ALb6Ovctnqt6YHv92LQbSDtzi69i7/3ym6o3p8W/XYiDtwC2+jr3LZ6remB7/di0G0g7c4uvYu3ym6o3p8W/XYiDtwC2+jr3LZ6remB7/di0G0g7c4uvYu3ym6o3p8W/XYiDtwC2+jr3LZ6remB7/di0G0g7c4uvYu3ym6o3p8W/X/Hzr2D77DJ39US//7jvp827fRqBxpP/qOY/sKh/yds/9Ao3gCazS+Y/ts8/Q2R/18u++kz7v9m0EGkf6r57zyK7yIW/33C/QCJ7AKp3/2D77DJ39US//7jvp827fRqBxpP/qOY/sKh/yds/9Ao3gCazS+Y/ts8/Q2R/18u++kz7v9m0EGkf6r57zyK7yIW/33C/QCP+ewJJ/7qyv9n/M+es/9crcuyYP69Z+7q6/9LBu51LO8hFf66hv/rGe8K6dwLR+90uc6ITf/MrcuyYP69Z+7q6/9LBu51LO8hFf66hv/rGe8K6dwLR+90uc6ITf/MrcuyYP69Z+7q6/9LBu51LO8hFf66hv/rGe8K6dwLR+90uc6ITf/MrcuyYP69Z+7q6/9LBu51LO8hFf66hv/rGe8K7N/1Tv2cZv8GCebokv58xs/3K+n/xP9Z5t/AYP5umW+HLOzPYv5/vJ/1Tv2cZv8GCebokv58xs/3K+n/xP9Z5t/AYP5umW+HLOzPYv5/vJ/1Tv2cZv8GCebokv58xs/3L/vp/8T/WebfwGD+bplvhyzsz2L+f7yf9U79nGb/Bgnm6JL+fMbP9yvp/8T/WebfwGD+bplvhyzsz2L+f7yf9QK+3vn/91K+RZ3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zDLOjKDf7f3fG4zvzWP+Y6T/zGu+Gcv/6FP/zH3/V2L9WZzNuBT/4APtHrX/jDf/xdb/dSncm8HfjkD+ATvf6F/z/8x9/1di/VmczbgU/+AD7R61/4w3/8XW/3Up3JvB345A/gE73+hT/8x9/1di/VmczbgU/+AD7R61/4w3/8XW/3Up3JvB345A/gE73+hT/8x9/1di/VmczbgU/+AD7R61/4w3/8XW/3Up3JfXzUf/zH6E3/+G28U//0VK/YiZqohO39ye/zsg/GKnrrHA/qzL/g8Izpdevgcs7xM6/e1Z/VRx7zZ33KwuzV2Q/1UKvzQd2Q4hvzZ33KwuzV2Q/1UKvzQd2Q4hvzZ33KwuzV2Q/1UKvzQd2Q4hvzZ33KwuzV2Q/1UKvzQd2Q4hvzZ33KwuzV2Q/1UKvzQd2Q4hvzZ/8t9c4/8/3O8eZ/9srv2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2Ofyjj9VZ7+swTf5f3v2iEf/2OfysIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMIlXMJFAQUBAAA7', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-10 17:03:41', '2026-05-10 17:03:41'),
(11, NULL, 'BILL1778467107781', 'CUST1778467109347', 'TXN1778467109347', 205.00, '000201010212306101152696314020436540217BILL17784671077810317CUST17784671093475204701153037645406205.005802TH5922TestMerchant17563798076007BANGKOK62470523202605110938294710000000716TXN1778467109347630496C5', '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9mmd1nu/tzYu5omfyomt3jfb77fe31E90vg+68mN74vu/OgP5EAv+dfP7PY+92Of1nvv/edv0P5f801+/mOf1mm993tr42Ke+Kmc2Op9s/1+6/0d1SON77Oe3Pi+6M6P/kAO9JJ//cxu73O/1N0/8tCL602O5jY+2Kvt/4lv9LWs6+Lcyr1N76g/78s768BP50Zfy7ouzq3c2/SO+vO+vLMO/HRu9LWs6+Lcyr1N76g/78s768BP50Zfy7ouzq3c2/SO+vO+vLMO/HRu9LWs6+Lcyr1N76g/78s768BP50Zfy7ouzq3c2/SO+vO+vLMO/HRu9LWs6+Lcyr1N76j/P+/LO+vAT+dGX5sNa/2p3O5KT+/zXtlNfvbj3/chHfDir/RXbciiDvyV3eRnP/59H9IBL/5Kf9WGLOrAX9lNfvbj3/chHfDir/RXbciiDvyV3eRnP/59H9IBL/5Kf9WGLOrAX9lNfvbj3/chHfDir/RXbciiDvyV3eRnP/59H9IBL/5Kf9WGLOrAX9lNfvbj3/chHfDir/RXbciiDvyV3eRnP/59f/cjP/I57/IULfhafNVAn/N179vyPPI57/IULfhafNVAn/N179vyPPI57/IULfhafNVAn/N179vyPPI57/IULfhafNVAn/N179vyPPI57/IULfhafNVAn/N1/+/b8jzyOe/yFC34WnzVQJ/zde/b8jzyOe/yFC34WnzVQJ/zde/b8jzyOe/yFC34WnzVQJ/zdb/8vX3e18zxAY/ZtSzpl4/4yt3Zhpzo5ZzmGg/20Fvg737e53/WoC/Om237aa7xYA+9Bf7u533+Zw364rzZtp/mGg/20Fvg737e53/WoC/Om237aa7xYA+9Bf7u533+Zw364rzZtp/mGg/20Fvg737e53/WoC/Om237aa7xYA+9Bf7u533+Zw364rzZtp/mGg/20Fvg737e51/6+XreNS/sYD/ykr/3am3neJ/m823MFLnuKJ/4+O7vDH/3e4/3aT7fxkyR647yif+P7/7O8He/93if5vNtzBS57iif+Pju7wx/93uP92k+38ZMkeuO8omP7/7O8He/93if5vNtzBS57iif+Pju7wx/93uP92k+38ZMkeuO8omP7/7O8He/93if5vNtzBS57iif+Pju7wx/93uP92k+38Zc2Dl/syNt+/SP+8Vd3L3u9nGP+KB+5jbe/IX/573d/XtPwb3d9CMPvrle4EyP2OaP653c6e9t55qf+O5f7+7M8Yht/rjeyZ3+3nau+Ynv/vXuzhyP2OaP653c6e9t55qf+O5f7+7M8Yht/rjeyZ3+3nau+Ynv/vXuzhyP2OaP653c6e9t55qf+O5f7+7M8Yj/bf643smd/t52rvmJ7/6LXtmnPv593+RkDbWm6vOfT9aC3bADPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9lO8G0DPOv53/kUvNaIbfvnj9l+oOxqvuvZD+RT3fEff7NyoOxqvuvZD+RT3fEff7NyoOxqvuvZD+RT3fEff7NyoOxqvuvZD+RT3fEff7NyoOxqvuvZD+RT3fEff7NyoOxqvuvZD+RT3fEff7NyoOxqvuvZ/w/kU93xH3+zcqDsar7r2Q/kU93xH3+zgpDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuYJDlPW/y6o3y1G3Q4m704PzuHiy7qX/4Hn/9nZyqjJ7l6v3pUND7lo76RT/r5U/c889sSh/xfW/w8GXpqF/0s17+xD3/zKb0Ed/3Bg9flo76RT/r5U/c889sSh/xfW/w8GXpqF/0s17+xP89/8ym9BHf9wYPX5aO+kU/6+VP3PPPbEof8X1v8PBl6ahf9LNe/sQ9/8ym9BHf9wYPX5aO+kU/6+VP3PPPbEof8X1v8NRt8uau5tcvzldO3EKNy6mP99Td+b//bUAPve2+6MtL/F8f9bNP4rO+/Ngf5lT/+7yP2JSP+vWd7eff2Qaf5niu5tcvzldO3EKNy6mP99Td+b//bUAPve2+6MtL/F8f9bNP4rO+/Ngf5lT/+7yP2JSP+vWd7eff2Qaf5niu5tcvzldO3EKNy6mP99Td+b//bUAPve2+6MtL/F8f9bNP4rOe3FN93mfv4f5vkTXO8T/u/pXP+Zz+9VHv783/3/583/PwP/19z6dXref3n9jrn/w73PPwP/19z6dXref3n9jrn/w73PPwP/19z6dXref3n9jrn/w73PPwP/19z6dXref3n9jrn/w73PPwP/19z6dXref3n9jrn/w73PPwP/19z6dXref3n9jrn/w73PPwP/19z6cRn/0/7/nqHfceLu7affkib/BpHvi3b+X9Ds69fd7fHuy+vtkwPuvJDbUvTud339vn/e3B7uubDeOzntxQ++J0fve9fd7fHuy+vtkwPuvJDbUvTud339vn/e3B7uubDeOzntxQ++J0fve9fd7fHuy+vtkwPuvJDbUvTud339vn/e3B7uubDeOz/57cUPvidH73vX3e3x7svr7ZMD7ryQ21Qm3/+kz4Wl7z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73fBrxu5/+PU3ntl/z4lzvzt73Rt//0NvuVy7v72zn/k/PhL/tQA/fe77ajq7svPze+o/Yd5/rir/80IvL9U7mRC3uPi/fuw/+L6zmyw+9uFzvZE7U4u7z8r374P/Car780IvL9U7mRC3uPi/fu/8P/i+s5ssPvbhc72RO1OLu8/K9++D/wmq+/NCLy/VO5kQt7j4v37sP/i+s5ssPvbhc72RO1OLu8/K9++D/wmpOpLJ79GSr/ff9/Tq/w9m+9Wgs2FAu7ncv+diP+8s79u8O9GmN+fAl/v6+6eNe6Ii9tZsN9GmN+fAl/v6+6eNe6Ii9tZsN9GmN+fAl/v6+6eNe6Ii9tZsN9GmN+fAl/v6+6eNe6Ii9tZsN9GmN+fAl/v6+6eNe6Ii9tZsN9GmN+fAl/v6+6eNe6Ii9tZsN9GmdWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZmVWZk+lVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVmZlVkiUAAAOw==', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-11 02:38:29', '2026-05-11 02:38:29'),
(12, NULL, 'BILL1778474148250', 'CUST1778474148601', 'TXN1778474148601', 70.00, '000201010212306101152696314020436540217BILL17784741482500317CUST1778474148601520470115303764540570.005802TH5922TestMerchant17563798076007BANGKOK62470523202605111135487130000000716TXN17784741486016304EFCA', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-11 04:35:49', '2026-05-11 04:35:49');
INSERT INTO `scb_payments` (`id`, `bill_id`, `ref1`, `ref2`, `ref3`, `amount`, `qr_raw_data`, `qr_image`, `transaction_id`, `status`, `paid_at`, `expires_at`, `callback_data`, `error_message`, `pp_id`, `merchant_id`, `created_at`, `updated_at`) VALUES
(13, NULL, 'BILL1778582639272', 'CUST1778582639627', 'TXN1778582639627', 950.00, '000201010212306101152696314020436540217BILL17785826392720317CUST17785826396275204701153037645406950.005802TH5922TestMerchant17563798076007BANGKOK62470523202605120544001100000000716TXN17785826396276304B915', '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', NULL, 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-12 10:44:00', '2026-05-12 10:44:00');

-- --------------------------------------------------------

--
-- Table structure for table `scb_payment_logs`
--

DROP TABLE IF EXISTS `scb_payment_logs`;
CREATE TABLE IF NOT EXISTS `scb_payment_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payment_id` int DEFAULT NULL COMMENT 'Reference to scb_payments table',
  `ref1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Reference ID for correlation',
  `action` enum('CREATE_QR','CHECK_STATUS','SIMULATE_PAYMENT','CALLBACK_RECEIVED','TOKEN_REQUEST','ERROR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of action performed',
  `request_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Request payload sent to SCB API',
  `response_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Response received from SCB API',
  `status_code` int DEFAULT NULL COMMENT 'HTTP status code from API response',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Error message if action failed',
  `api_endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SCB API endpoint called',
  `request_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Unique request ID sent to SCB',
  `duration_ms` int DEFAULT NULL COMMENT 'API call duration in milliseconds',
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent string from request',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Client IP address',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Log entry timestamp',
  PRIMARY KEY (`id`),
  KEY `idx_payment_id` (`payment_id`),
  KEY `idx_ref1` (`ref1`),
  KEY `idx_action` (`action`),
  KEY `idx_status_code` (`status_code`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_request_id` (`request_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

DROP TABLE IF EXISTS `shops`;
CREATE TABLE IF NOT EXISTS `shops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Shop/Restaurant name',
  `shop_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique shop identifier',
  `bill_prefix` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tax_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tax identification number',
  `phone_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primary phone',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Shop email',
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Full address',
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` longblob COMMENT 'Shop logo',
  `logo_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_person` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_person_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subscription_status` enum('active','inactive','trial','suspended') COLLATE utf8mb4_unicode_ci DEFAULT 'trial',
  `subscription_plan_id` int DEFAULT NULL,
  `subscription_start_date` datetime DEFAULT NULL,
  `subscription_end_date` datetime DEFAULT NULL,
  `no_of_terminals` int DEFAULT '1',
  `max_users` int DEFAULT '10',
  `storage_quota_gb` int DEFAULT '50',
  `database_prefix` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Optional: for database sharding',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1=active, 0=inactive',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shop_code` (`shop_code`),
  UNIQUE KEY `unique_shop_code` (`shop_code`),
  UNIQUE KEY `unique_tax_id` (`tax_id`),
  UNIQUE KEY `uk_shops_bill_prefix` (`bill_prefix`),
  KEY `idx_shop_name` (`name`),
  KEY `idx_subscription_status` (`subscription_status`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shops_subscription_status` (`subscription_status`,`is_active`),
  KEY `idx_shops_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Multi-tenant shop/restaurant information';

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`id`, `name`, `shop_code`, `bill_prefix`, `tax_id`, `phone_number`, `email`, `address`, `city`, `state`, `zip_code`, `country`, `website`, `logo`, `logo_type`, `logo_name`, `contact_person`, `contact_person_phone`, `subscription_status`, `subscription_plan_id`, `subscription_start_date`, `subscription_end_date`, `no_of_terminals`, `max_users`, `storage_quota_gb`, `database_prefix`, `is_active`, `created_at`, `updated_at`, `created_by`, `updated_by`) VALUES
(4, 'Cloud7', 'CLD0001', 'CLD', '4525545465', '+6698653256', 'cloud7@gmail.com', 'Sout Pataya Chonburi', 'Pattaya', 'chonburi', '20150', 'Thailand', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 2, '2026-03-27 16:55:23', '2027-03-27 16:55:23', 1, 10, 50, NULL, 1, '2026-03-27 09:55:23', '2026-03-27 09:55:37', 1, 1),
(5, 'Demo Restaurant', 'Demo0001', 'DM', '12345678930', '+661234567898', 'demo@gmail.com', '125/56,Near Demo,Demo City China ', 'Demo', 'Demo', '20150', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 2, '2026-03-28 19:32:43', '2027-03-28 19:32:43', 1, 10, 50, NULL, 1, '2026-03-28 19:32:43', '2026-05-13 08:33:55', 1, 1),
(7, 'JASLEEN RESTAURANT', 'JSL0001', 'JSL', 'xxxxxxxxxxxxx', '+66 84 848 6868', 'info@jasleenindianfood.com', '100 21 Soi Kamala 12, Kamala Kathu District, Phuket 83150, Thailand', NULL, NULL, '83150', 'Thailand', NULL, NULL, NULL, NULL, NULL, NULL, 'trial', 1, '2026-03-29 05:14:44', '2027-03-29 05:14:44', 1, 10, 50, NULL, 1, '2026-03-29 05:14:44', '2026-03-29 05:14:44', 1, NULL),
(8, 'SUNRISE CAFE & RESTAURANT', 'SNR001', 'SNR', 'XXXXXXXX', '+66-805401625', 'rajkirthwal@outlook.com', '31/3 Sukhumvit Soi 48 Phra Khanong Khlong Toei Bangkok', 'Bangkok', 'Bangkok', '10110', 'Thailand', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-04-02 08:21:56', '2027-04-02 08:21:56', 1, 10, 50, NULL, 1, '2026-04-02 08:21:56', '2026-05-08 07:23:14', 1, 1),
(9, 'WELCOME SUIT', 'WS0001', 'WS', '0205565021365', '+66-800062602', 'welcomesuit@gmail.com', '249/29-30 Moo 10, Muang Pattaya, Bang Lamung District, Chon Buri 20150', 'Pattaya', 'Chonburi', '20150', 'Thailand', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-04-13 06:32:41', '2027-04-13 06:32:41', 1, 10, 50, NULL, 1, '2026-04-13 06:32:41', '2026-05-13 08:38:02', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `shop_admins`
--

DROP TABLE IF EXISTS `shop_admins`;
CREATE TABLE IF NOT EXISTS `shop_admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role` enum('owner','manager','admin','staff') COLLATE utf8mb4_unicode_ci DEFAULT 'admin',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Shop-specific permissions',
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `assigned_by` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_shop_user` (`shop_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role` (`role`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `shop_audit_logs`
--

DROP TABLE IF EXISTS `shop_audit_logs`;
CREATE TABLE IF NOT EXISTS `shop_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Table name being modified',
  `entity_id` int DEFAULT NULL COMMENT 'ID of modified record',
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Previous values',
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'New values',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shop_audit_logs_shop_action` (`shop_id`,`action`,`created_at`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `shop_billing`
--

DROP TABLE IF EXISTS `shop_billing`;
CREATE TABLE IF NOT EXISTS `shop_billing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `billing_period_start` date NOT NULL,
  `billing_period_end` date NOT NULL,
  `plan_id` int DEFAULT NULL,
  `amount_due` decimal(10,2) NOT NULL,
  `amount_paid` decimal(10,2) DEFAULT '0.00',
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `billing_status` enum('pending','sent','paid','cancelled','overdue') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `payment_method` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `plan_id` (`plan_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_billing_status` (`billing_status`),
  KEY `idx_billing_period` (`billing_period_start`,`billing_period_end`),
  KEY `idx_shop_billing_by_shop` (`shop_id`,`billing_period_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Subscription billing records for each shop';

-- --------------------------------------------------------

--
-- Table structure for table `shop_subscriptions`
--

DROP TABLE IF EXISTS `shop_subscriptions`;
CREATE TABLE IF NOT EXISTS `shop_subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `plan_id` int NOT NULL,
  `subscription_type` enum('MONTHLY','QUARTERLY','YEARLY') COLLATE utf8mb4_unicode_ci DEFAULT 'MONTHLY',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `renewal_date` date NOT NULL COMMENT 'When next payment is due',
  `status` enum('ACTIVE','SUSPENDED','CANCELLED','EXPIRED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `auto_renew` tinyint(1) DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_plan_id` (`plan_id`),
  KEY `idx_renewal_date` (`renewal_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Shop subscription records';

--
-- Dumping data for table `shop_subscriptions`
--

INSERT INTO `shop_subscriptions` (`id`, `shop_id`, `plan_id`, `subscription_type`, `start_date`, `end_date`, `renewal_date`, `status`, `auto_renew`, `notes`, `created_at`, `updated_at`) VALUES
(3, 5, 2, 'MONTHLY', '2026-03-29', '2026-04-28', '2026-06-01', 'ACTIVE', 1, NULL, '2026-03-28 19:33:20', '2026-05-10 09:19:37'),
(4, 7, 1, 'MONTHLY', '2026-04-04', '2027-04-03', '2026-05-04', 'ACTIVE', 1, NULL, '2026-04-04 06:36:23', '2026-04-04 06:37:21'),
(5, 9, 1, 'MONTHLY', '2026-04-17', '2026-05-17', '2026-05-20', 'ACTIVE', 1, NULL, '2026-04-17 05:48:44', '2026-04-23 15:35:15'),
(6, 8, 1, 'MONTHLY', '2026-04-17', '2026-05-17', '2026-05-20', 'ACTIVE', 1, NULL, '2026-04-17 05:50:16', '2026-05-08 07:22:46');

-- --------------------------------------------------------

--
-- Table structure for table `stock_balance`
--

DROP TABLE IF EXISTS `stock_balance`;
CREATE TABLE IF NOT EXISTS `stock_balance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `product_id` int NOT NULL,
  `unit_id` int NOT NULL,
  `current_quantity` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `reserved_quantity` decimal(10,4) NOT NULL DEFAULT '0.0000' COMMENT 'Quantity reserved for pending orders',
  `available_quantity` decimal(10,4) GENERATED ALWAYS AS ((`current_quantity` - `reserved_quantity`)) STORED,
  `last_updated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_product_unit` (`product_id`,`unit_id`),
  KEY `idx_product_stock` (`product_id`),
  KEY `fk_stock_balance_unit` (`unit_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock_balance`
--

INSERT INTO `stock_balance` (`id`, `shop_id`, `product_id`, `unit_id`, `current_quantity`, `reserved_quantity`, `last_updated`) VALUES
(17, 5, 1228, 115, 6.0000, 0.0000, '2026-05-11 15:43:04'),
(18, 5, 1229, 120, 8.6800, 0.0000, '2026-05-12 17:53:22'),
(19, 5, 1228, 119, 10.0000, 0.0000, '2026-05-11 15:41:05'),
(20, 5, 1230, 123, 8.5600, 0.0000, '2026-05-12 17:53:22'),
(21, 5, 1231, 128, 11.6400, 0.0000, '2026-05-12 17:46:22');

-- --------------------------------------------------------

--
-- Table structure for table `stock_conversions`
--

DROP TABLE IF EXISTS `stock_conversions`;
CREATE TABLE IF NOT EXISTS `stock_conversions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `product_id` int NOT NULL,
  `from_unit_id` int NOT NULL,
  `to_unit_id` int NOT NULL,
  `conversion_factor` decimal(10,4) NOT NULL COMMENT 'Multiply from_unit by this to get to_unit',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_conversion` (`product_id`,`from_unit_id`,`to_unit_id`),
  KEY `idx_product_conversion` (`product_id`),
  KEY `idx_from_unit` (`from_unit_id`),
  KEY `idx_to_unit` (`to_unit_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stock_transactions`
--

DROP TABLE IF EXISTS `stock_transactions`;
CREATE TABLE IF NOT EXISTS `stock_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `product_id` int NOT NULL,
  `transaction_type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ADD, REMOVE, ADJUST, SALE',
  `unit_id` int NOT NULL,
  `quantity` decimal(10,4) NOT NULL,
  `quantity_in_ml` decimal(15,2) DEFAULT NULL COMMENT 'For liquor - quantity in ML',
  `reference_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'PURCHASE, SALE, WASTE, DAMAGE, INVENTORY_ADJUSTMENT',
  `reference_id` int DEFAULT NULL COMMENT 'ID from related table',
  `user_id` int DEFAULT NULL,
  `notes` text COLLATE utf8mb4_general_ci,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_transaction_date` (`transaction_date`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  KEY `fk_stock_trans_unit` (`unit_id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock_transactions`
--

INSERT INTO `stock_transactions` (`id`, `shop_id`, `product_id`, `transaction_type`, `unit_id`, `quantity`, `quantity_in_ml`, `reference_type`, `reference_id`, `user_id`, `notes`, `transaction_date`, `created_at`) VALUES
(12, 5, 1228, 'ADD', 115, 10.0000, 7500.00, 'PURCHASE', 13, 180, 'Purchase PO-2026-0001', '2026-05-11 15:21:19', '2026-05-11 15:21:19'),
(13, 5, 1229, 'ADD', 120, 10.0000, 7500.00, 'PURCHASE', 13, 180, 'Purchase PO-2026-0001', '2026-05-11 15:21:19', '2026-05-11 15:21:19'),
(18, 5, 1228, 'REMOVE', 115, 1.0000, 750.00, 'SALE', 61, 180, 'Sale - Order #61 - Table: Table 2', '2026-05-11 15:31:47', '2026-05-11 15:31:47'),
(19, 5, 1228, 'REMOVE', 115, 1.0000, 750.00, 'SALE', 61, 180, 'Sale - Order #61 - Table: Table 2', '2026-05-11 15:31:47', '2026-05-11 15:31:47'),
(20, 5, 1228, 'ADD', 119, 10.0000, 7500.00, 'PURCHASE', 14, 180, 'Purchase PO-2026-0002', '2026-05-11 15:41:05', '2026-05-11 15:41:05'),
(21, 5, 1228, 'REMOVE', 115, 2.0000, 1500.00, 'SALE', 62, 180, 'Sale - Order #62 - Table: Table 2', '2026-05-11 15:43:04', '2026-05-11 15:43:04'),
(22, 5, 1230, 'ADD', 123, 12.0000, 9000.00, 'PURCHASE', 15, 180, 'Purchase PO-2026-0003', '2026-05-11 15:56:07', '2026-05-11 15:56:07'),
(23, 5, 1230, 'REMOVE', 123, 2.0000, 1500.00, 'SALE', 63, 180, 'Sale - Order #63 - Table: Table 2', '2026-05-11 15:56:41', '2026-05-11 15:56:41'),
(24, 5, 1230, 'REMOVE', 123, 1.0000, 750.00, 'SALE', 64, 180, 'Sale - Order #64 - Table: Table 3', '2026-05-11 16:00:34', '2026-05-11 16:00:34'),
(25, 5, 1230, 'REMOVE', 124, 3.0000, 90.00, 'SALE', 65, 180, 'Sale - Order #65 - Table: Table 2', '2026-05-11 16:15:10', '2026-05-11 16:15:10'),
(26, 5, 1230, 'REMOVE', 125, 2.0000, 120.00, 'SALE', 66, 180, 'Sale - Order #66 - Table: Table 3', '2026-05-11 16:15:56', '2026-05-11 16:15:56'),
(27, 5, 1231, 'ADD', 128, 12.0000, 9000.00, 'PURCHASE', 16, 180, 'Purchase PO-2026-0004', '2026-05-11 18:19:30', '2026-05-11 18:19:30'),
(28, 5, 1231, 'REMOVE', 129, 1.0000, 30.00, 'SALE', 67, 180, 'Sale - Order #67 - Table: Table 2', '2026-05-11 18:19:43', '2026-05-11 18:19:43'),
(29, 5, 1229, 'REMOVE', 122, 1.0000, 60.00, 'SALE', 69, 180, 'Sale - Order #69 - Table: Table 3', '2026-05-12 15:27:20', '2026-05-12 15:27:20'),
(30, 5, 1230, 'REMOVE', 124, 1.0000, 30.00, 'SALE', 72, 180, 'Sale - Order #72 - Table: VIP 1', '2026-05-12 17:42:56', '2026-05-12 17:42:56'),
(31, 5, 1231, 'REMOVE', 130, 2.0000, 120.00, 'SALE', 72, 180, 'Sale - Order #72 - Table: VIP 1', '2026-05-12 17:42:56', '2026-05-12 17:42:56'),
(32, 5, 1229, 'REMOVE', 122, 1.0000, 60.00, 'SALE', 72, 180, 'Sale - Order #72 - Table: VIP 1', '2026-05-12 17:42:56', '2026-05-12 17:42:56'),
(33, 5, 1231, 'REMOVE', 130, 2.0000, 120.00, 'SALE', 74, 180, 'Sale - Order #74 - Table: Table 3', '2026-05-12 17:46:22', '2026-05-12 17:46:22'),
(34, 5, 1229, 'REMOVE', 120, 1.0000, 750.00, 'SALE', 74, 180, 'Sale - Order #74 - Table: Table 3', '2026-05-12 17:46:22', '2026-05-12 17:46:22'),
(35, 5, 1229, 'REMOVE', 122, 1.0000, 60.00, 'SALE', 74, 180, 'Sale - Order #74 - Table: Table 3', '2026-05-12 17:46:22', '2026-05-12 17:46:22'),
(36, 5, 1230, 'REMOVE', 126, 1.0000, 90.00, 'SALE', 76, 180, 'Sale - Order #76 - Table: VIP 1', '2026-05-12 17:53:22', '2026-05-12 17:53:22'),
(37, 5, 1229, 'REMOVE', 122, 1.0000, 60.00, 'SALE', 76, 180, 'Sale - Order #76 - Table: VIP 1', '2026-05-12 17:53:22', '2026-05-12 17:53:22');

-- --------------------------------------------------------

--
-- Table structure for table `subcategory`
--

DROP TABLE IF EXISTS `subcategory`;
CREATE TABLE IF NOT EXISTS `subcategory` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `cat_id` int DEFAULT NULL,
  `subcat` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_subcategory_category` (`cat_id`),
  KEY `idx_final_bill_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `subcategory`
--

INSERT INTO `subcategory` (`id`, `shop_id`, `cat_id`, `subcat`) VALUES
(77, 4, 46, 'Breakfast'),
(78, 5, 47, 'Breakfast'),
(79, 5, 47, 'Snacks'),
(80, 5, 47, 'Main Course'),
(81, 7, 50, 'Appetizer'),
(82, 7, 50, 'Sandwich'),
(83, 7, 50, 'Burger'),
(84, 7, 50, 'Salad'),
(85, 7, 50, 'Soup'),
(86, 7, 50, 'Pizza'),
(87, 7, 50, 'Spaghetti'),
(88, 7, 50, 'Steaks'),
(89, 7, 50, 'Thai'),
(90, 7, 50, 'Noodles'),
(91, 7, 50, 'New Zealamd Mussel'),
(92, 7, 50, 'Crab'),
(93, 7, 50, 'Black Tiger Shrimp'),
(94, 7, 50, 'Lobster'),
(95, 7, 50, 'Squid'),
(96, 7, 50, 'Dessert'),
(97, 8, 52, 'PEG'),
(98, 8, 52, 'BEERS'),
(99, 8, 52, 'VODKA BTL'),
(100, 8, 52, 'GIN BTL'),
(101, 8, 52, 'RUM BTL'),
(102, 8, 52, 'TEQUILA BTL'),
(103, 8, 52, 'WHISKEY BTL'),
(104, 8, 52, 'LIQUER BTL'),
(105, 8, 52, 'WINE'),
(106, 8, 53, 'COFFEE'),
(107, 8, 53, 'TEA'),
(108, 8, 53, 'SEASONAL FRESH'),
(109, 8, 53, 'SMOTTHIES'),
(110, 8, 54, 'A LA CARTE'),
(111, 8, 54, 'INDIAN CUISINE'),
(112, 8, 54, 'THAI CUISINE'),
(113, 8, 54, 'PIZZA'),
(114, 8, 55, 'BREAKFAST'),
(115, 7, 49, 'Appetizer'),
(116, 7, 49, 'Kebab'),
(117, 7, 49, 'Sizzling/Tawa'),
(118, 7, 49, 'Naan & Parantha'),
(119, 7, 49, 'Rice/Bread'),
(120, 7, 49, 'Briyani'),
(121, 7, 49, 'Soup'),
(122, 7, 49, 'Vegetable'),
(123, 7, 49, 'Non-Veg'),
(124, 7, 49, 'Fisg Prawn'),
(125, 7, 49, 'Sweet dish'),
(126, 7, 50, 'Side Dish'),
(127, 7, 50, 'Fish'),
(128, 7, 50, 'veg dish'),
(129, 8, 52, 'Cocktails'),
(130, 9, 56, 'Snacks'),
(131, 9, 57, 'Bottle'),
(132, 9, 57, '30ML Peg'),
(133, 9, 57, '60ML Peg'),
(134, 9, 57, 'Beer'),
(135, 9, 58, 'DLX'),
(136, 9, 58, 'STD'),
(137, 9, 58, 'SWT'),
(138, 8, 53, 'SOFT DRINKS'),
(139, 5, 48, 'Whiskey'),
(140, 5, 48, 'Beers');

-- --------------------------------------------------------

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
CREATE TABLE IF NOT EXISTS `subscription_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Plan name (Basic, Pro, Premium)',
  `description` text COLLATE utf8mb4_unicode_ci,
  `price_per_month` decimal(10,2) NOT NULL,
  `quarterly_price` decimal(10,2) DEFAULT NULL,
  `yearly_price` decimal(10,2) DEFAULT NULL,
  `max_terminals` int DEFAULT '1',
  `max_users` int DEFAULT '5',
  `storage_quota_gb` int DEFAULT '10',
  `setup_fee` decimal(10,2) DEFAULT '0.00' COMMENT 'One-time setup fee',
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'JSON array of included features',
  `payment_methods_allowed` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'JSON array of allowed payment methods',
  `support_level` enum('BASIC','STANDARD','PREMIUM','24_7') COLLATE utf8mb4_unicode_ci DEFAULT 'BASIC' COMMENT 'Level of support included',
  `trial_days` int DEFAULT '0' COMMENT 'Free trial period in days',
  `cancellation_policy` text COLLATE utf8mb4_unicode_ci COMMENT 'Cancellation terms and conditions',
  `billing_cycle` enum('DAILY','WEEKLY','MONTHLY','QUARTERLY','YEARLY') COLLATE utf8mb4_unicode_ci DEFAULT 'MONTHLY',
  `is_active` tinyint(1) DEFAULT '1',
  `visible_to_customers` tinyint(1) DEFAULT '1' COMMENT 'Whether this plan is visible to customers',
  `tier_level` int DEFAULT '0' COMMENT 'Tier level for sorting (0=basic, 1=pro, 2=enterprise)',
  `discount_percentage` decimal(5,2) DEFAULT '0.00' COMMENT 'Bulk or promotional discount percentage',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT 'Maximum discount that can be applied',
  `refund_policy_days` int DEFAULT '30' COMMENT 'Number of days for refund eligibility',
  `min_contract_months` int DEFAULT '1' COMMENT 'Minimum contract period requirement',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_tier_level` (`tier_level`),
  KEY `idx_visible` (`visible_to_customers`,`is_active`)
) ;

--
-- Dumping data for table `subscription_plans`
--

INSERT INTO `subscription_plans` (`id`, `name`, `description`, `price_per_month`, `quarterly_price`, `yearly_price`, `max_terminals`, `max_users`, `storage_quota_gb`, `setup_fee`, `features`, `payment_methods_allowed`, `support_level`, `trial_days`, `cancellation_policy`, `billing_cycle`, `is_active`, `visible_to_customers`, `tier_level`, `discount_percentage`, `max_discount_amount`, `refund_policy_days`, `min_contract_months`, `created_at`, `updated_at`) VALUES
(1, 'Starter', 'Perfect for small restaurants', 500.00, 1350.00, 4800.00, 1, 5, 10, 0.00, '[\"POS\", \"Basic Reports\", \"Customer Management\"]', '[\"CREDIT_CARD\", \"BANK_TRANSFER\", \"UPI\"]', 'BASIC', 14, 'Plans can be cancelled anytime. Refund policy applies as per the plan terms.', 'MONTHLY', 1, 1, 0, 0.00, NULL, 30, 1, '2026-03-26 09:01:56', '2026-03-26 18:12:33'),
(2, 'Professional', 'For growing restaurants', 1500.00, 4050.00, 14400.00, 3, 15, 50, 0.00, '[\"POS\", \"Advanced Reports\", \"Customer Management\", \"Inventory\", \"Staff Management\"]', '[\"CREDIT_CARD\", \"BANK_TRANSFER\", \"UPI\"]', 'STANDARD', 14, 'Plans can be cancelled anytime. Refund policy applies as per the plan terms.', 'MONTHLY', 1, 1, 1, 0.00, NULL, 30, 1, '2026-03-26 09:01:56', '2026-03-26 18:12:33'),
(3, 'Enterprise', 'For large restaurant chains', 2500.00, 6750.00, 24000.00, 10, 50, 200, 0.00, '[\"POS\", \"Advanced Reports\", \"Customer Management\", \"Inventory\", \"Staff Management\", \"Multi-location\", \"API Access\", \"Custom Integration\"]', '[\"CREDIT_CARD\", \"BANK_TRANSFER\", \"UPI\"]', 'PREMIUM', 14, 'Plans can be cancelled anytime. Refund policy applies as per the plan terms.', 'MONTHLY', 1, 1, 2, 0.00, NULL, 30, 1, '2026-03-26 09:01:56', '2026-03-26 18:12:33');

-- --------------------------------------------------------

--
-- Table structure for table `super_admin_users`
--

DROP TABLE IF EXISTS `super_admin_users`;
CREATE TABLE IF NOT EXISTS `super_admin_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('super_admin','admin','support','billing') COLLATE utf8mb4_unicode_ci DEFAULT 'super_admin',
  `shop_id` int DEFAULT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'JSON array of permissions',
  `profile_image` longblob,
  `profile_image_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` datetime DEFAULT NULL,
  `login_attempts` int DEFAULT '0',
  `account_locked_until` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_username` (`username`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sau_shop_id` (`shop_id`)
) ;

--
-- Dumping data for table `super_admin_users`
--

INSERT INTO `super_admin_users` (`id`, `username`, `email`, `password_hash`, `first_name`, `last_name`, `phone_number`, `role`, `shop_id`, `permissions`, `profile_image`, `profile_image_type`, `is_active`, `last_login`, `login_attempts`, `account_locked_until`, `created_at`, `updated_at`) VALUES
(1, 'superadmin', 'admin@chefmate.com', '$2a$10$5YtvKgzmni/oqLJwG59yZe6DeyRgYZd5z8jmpLdnNZygy7r.q7gp2', 'Super', 'Admin', '+66-839194134', 'super_admin', NULL, NULL, NULL, NULL, 1, '2026-05-13 16:07:05', 0, NULL, '2026-03-26 09:21:01', '2026-05-13 09:07:05'),
(2, 'view1', 'view1@gmail.com', '$2a$10$yH9lmkLcTdM46EwcKc9tx.epn.3J81.sNNbKTRVZRJgJbWjmZvahm', 'bjbk', 'nbjj', NULL, 'admin', NULL, NULL, NULL, NULL, 1, NULL, 0, NULL, '2026-03-26 11:15:40', '2026-03-26 11:15:40');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `company_name` varchar(233) DEFAULT NULL,
  `contact` bigint NOT NULL,
  `email` varchar(233) NOT NULL,
  `taxid` varchar(233) DEFAULT NULL,
  `address` varchar(233) DEFAULT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  `createdon` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_suppliers_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `shop_id`, `name`, `company_name`, `contact`, `email`, `taxid`, `address`, `is_active`, `createdon`) VALUES
(1, NULL, 'Vinod Kumar Kumar', 'Axial IT Solutions', 255666, 'axialtour@gmail.com', '1516165', 'vill tikkar rajputan po bumbloo', 1, '2025-06-02 06:14:27'),
(2, NULL, 'Sopit', 'Sopu co. Ltd', 992799977, 'AXIALITSOLUTIONS0001@GMAIL.COM', '0236256926', 'vill tikkar rajputan po bumbloo', 1, '2025-06-12 09:41:44'),
(4, NULL, 'Makro', 'Makro Pattaya', 0, '', NULL, 'Pattaya', 1, '2026-02-04 16:09:32'),
(5, NULL, 'Friendship', 'Friendship', 0, '', NULL, 'Pattaya', 1, '2026-02-04 16:09:46'),
(6, NULL, 'Vegetables', 'Vegetables', 0, '', NULL, 'Pattaya', 1, '2026-02-04 16:10:08'),
(7, NULL, 'Local Vendor', 'Local Vendor', 0, '', NULL, 'Pattaya', 1, '2026-02-04 16:10:21'),
(8, NULL, 'Staff Expenses', 'Staff Expenses', 0, '', NULL, 'Pattaya', 1, '2026-02-04 16:10:54'),
(9, NULL, 'Gas', 'Gas', 0, '', NULL, NULL, 1, '2026-02-04 16:11:05'),
(10, NULL, 'Chokchai', 'Chokchai', 0, '', NULL, NULL, 1, '2026-02-04 16:11:21'),
(11, NULL, 'Supamitr', 'Supamitr', 0, '', NULL, NULL, 1, '2026-02-04 16:11:45'),
(12, NULL, 'Chang House', 'Chang House', 0, '', NULL, NULL, 1, '2026-02-04 16:12:00'),
(13, NULL, 'Banlue', 'Banlue', 0, '', NULL, NULL, 1, '2026-02-04 16:12:12'),
(14, NULL, 'Boonchai', 'Boonchai', 125, '', '', 'Pattaya', 1, '2026-02-18 12:46:57'),
(15, NULL, 'dsfdsfsf', 'fsdfsf', 1563156316, 'cloud7@gmail.com', '', 'Sout Pataya Chonburi', 1, '2026-03-31 17:28:53'),
(16, NULL, 'sdffdsfsdf', 'fsdfsf', 0, '', '', '', 1, '2026-03-31 17:33:56'),
(17, NULL, 'dsaddadsa', '', 0, '', '', '', 1, '2026-03-31 17:36:20'),
(18, 5, 'jghjghjgh', '', 0, '', '', '', 1, '2026-03-31 17:37:22'),
(20, 5, 'sdfsgdfg gdfgdfg', '', 0, '', '', '', 1, '2026-03-31 17:37:37');

-- --------------------------------------------------------

--
-- Table structure for table `supplier_ledger_entries`
--

DROP TABLE IF EXISTS `supplier_ledger_entries`;
CREATE TABLE IF NOT EXISTS `supplier_ledger_entries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `transaction_id` varchar(50) NOT NULL,
  `date` datetime DEFAULT CURRENT_TIMESTAMP,
  `account_type` varchar(233) NOT NULL,
  `account_id` int NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `debit_amount` decimal(15,2) DEFAULT '0.00',
  `credit_amount` decimal(15,2) DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `reference_id` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_supplier_ledger_transaction` (`transaction_id`),
  KEY `idx_supplier_ledger_account` (`account_id`,`account_type`(1)),
  KEY `idx_supplier_ledger_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `supplier_ledger_entries`
--

INSERT INTO `supplier_ledger_entries` (`id`, `shop_id`, `transaction_id`, `date`, `account_type`, `account_id`, `description`, `debit_amount`, `credit_amount`, `discount_amount`, `reference_id`, `created_at`, `updated_at`) VALUES
(1, 5, 'dsd', '2026-04-01 00:00:00', 'Purchase', 18, 'dfds', 62350.00, 0.00, 0.00, 0, '2026-03-31 17:50:54', '2026-03-31 17:54:15'),
(2, 5, 'dsd', '2026-04-01 00:00:00', 'Purchase', 18, '', 10000.00, 0.00, 0.00, 0, '2026-03-31 17:52:25', '2026-03-31 17:54:17'),
(3, 5, 'dsad', '2026-04-01 00:00:00', 'Purchase', 18, 'sadsads', 13500.00, 0.00, 0.00, 0, '2026-03-31 17:54:37', '2026-03-31 17:54:37'),
(4, 5, '', '2026-04-01 00:00:00', 'Purchase', 20, '', 15000.00, 0.00, 0.00, 0, '2026-03-31 17:54:44', '2026-03-31 17:54:44'),
(5, 5, '', '2026-04-01 00:00:00', 'Purchase', 18, '', 0.00, 2500.00, 0.00, 0, '2026-03-31 18:04:10', '2026-03-31 18:04:10'),
(6, 5, '', '2026-03-31 18:08:06', 'Cash Account', 0, 'Supplier Payment - Credit', 0.00, 45000.00, 0.00, NULL, '2026-03-31 18:08:06', '2026-03-31 18:08:06'),
(7, 5, '', '2026-03-31 18:08:06', 'Accounts Payable', 18, 'Supplier Payment - Debit', 45000.00, 0.00, 0.00, NULL, '2026-03-31 18:08:06', '2026-03-31 18:08:06'),
(8, 5, '', '2026-03-31 18:18:21', 'Other Account', 0, 'Supplier Payment - Credit', 0.00, 10000.00, 0.00, NULL, '2026-03-31 18:18:21', '2026-03-31 18:18:21'),
(9, 5, '', '2026-03-31 18:18:21', 'Accounts Payable', 20, 'Supplier Payment - Debit', 10000.00, 0.00, 0.00, NULL, '2026-03-31 18:18:21', '2026-03-31 18:18:21'),
(10, 5, '', '2026-03-31 18:20:08', 'Cash Account', 0, 'Supplier Payment - Credit', 0.00, 2000.00, 0.00, NULL, '2026-03-31 18:20:08', '2026-03-31 18:20:08'),
(11, 5, '', '2026-03-31 18:20:08', 'Accounts Payable', 20, 'Supplier Payment - Debit', 2000.00, 0.00, 0.00, NULL, '2026-03-31 18:20:08', '2026-03-31 18:20:08');

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `ticket_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'AUTO-GENERATED: TICKET-SHOPID-YYYYMMDD-XXXX',
  `user_id` int DEFAULT NULL COMMENT 'User who created ticket',
  `assigned_to` int DEFAULT NULL COMMENT 'Admin user assigned',
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., BILLING, TECHNICAL, FEATURE_REQUEST, PAYMENT, PRINTER, INVENTORY, OTHER',
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `status` enum('OPEN','IN_PROGRESS','PENDING_CUSTOMER','ON_HOLD','RESOLVED','CLOSED') COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `error_log_id` int DEFAULT NULL COMMENT 'Link to related error log',
  `notes` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Internal support notes',
  `resolution` text COLLATE utf8mb4_unicode_ci COMMENT 'How issue was resolved',
  `created_by` int DEFAULT NULL COMMENT 'Super admin user creating this ticket',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_number` (`ticket_number`),
  UNIQUE KEY `idx_ticket_number` (`ticket_number`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shop_status` (`shop_id`,`status`,`created_at`),
  KEY `error_log_id` (`error_log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Support tickets for shop issues';

--
-- Dumping data for table `support_tickets`
--

INSERT INTO `support_tickets` (`id`, `shop_id`, `ticket_number`, `user_id`, `assigned_to`, `category`, `subject`, `description`, `priority`, `status`, `error_log_id`, `notes`, `resolution`, `created_by`, `created_at`, `updated_at`, `resolved_at`) VALUES
(4, 5, 'TICKET-5-20260411-4235', 180, NULL, 'BILLING', 'fdf', 'dsfdsfds', 'MEDIUM', 'CLOSED', NULL, 'ddsadsad', 'We will closed the ticket as issue resolved already', NULL, '2026-04-11 06:35:54', '2026-04-11 07:18:04', '2026-04-11 07:18:04'),
(5, 8, 'TICKET-8-20260412-1082', NULL, NULL, 'TECHNICAL', 'Blank Screen', 'After cashier login show blank screen using app and browser', 'MEDIUM', 'OPEN', NULL, NULL, NULL, 1, '2026-04-12 04:25:51', '2026-04-12 04:25:51', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `support_ticket_comments`
--

DROP TABLE IF EXISTS `support_ticket_comments`;
CREATE TABLE IF NOT EXISTS `support_ticket_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'Super admin or shop user',
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_internal` tinyint(1) DEFAULT '0' COMMENT '1 = visible only to admins, 0 = visible to shop',
  `attachment_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Comments and discussion on support tickets';

--
-- Dumping data for table `support_ticket_comments`
--

INSERT INTO `support_ticket_comments` (`id`, `ticket_id`, `user_id`, `comment`, `is_internal`, `attachment_url`, `created_at`, `updated_at`) VALUES
(6, 4, 180, 'gfdgfdgfd', 0, NULL, '2026-04-11 06:36:17', '2026-04-11 06:36:17'),
(7, 4, 1, 'fdsfdsfsdffsd', 0, NULL, '2026-04-11 06:36:44', '2026-04-11 06:36:44'),
(8, 4, 180, 'ok thanks', 0, NULL, '2026-04-11 07:18:22', '2026-04-11 07:18:22');

-- --------------------------------------------------------

--
-- Table structure for table `tablelist`
--

DROP TABLE IF EXISTS `tablelist`;
CREATE TABLE IF NOT EXISTS `tablelist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `category` varchar(22) NOT NULL,
  `name` varchar(233) NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_tables_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tablelist`
--

INSERT INTO `tablelist` (`id`, `shop_id`, `category`, `name`, `status`) VALUES
(54, 4, '9', 'VIP1', 0),
(55, 5, '10', 'Table 1', 0),
(56, 5, '10', 'Table 2', 1),
(57, 5, '10', 'Table 3', 1),
(58, 5, '10', 'VIP 1', 0),
(59, 5, '10', 'VIP 2', 0),
(60, 5, '10', 'VIP 3', 0),
(61, 8, '11', 'Table 1', 0),
(62, 8, '11', 'Table 2', 0),
(63, 8, '11', 'Table 3', 0),
(64, 8, '11', 'Table 4', 0),
(65, 8, '11', 'Table 5', 0),
(66, 8, '11', 'Table 6', 0),
(67, 8, '11', 'Table 7', 0),
(68, 8, '11', 'Table 8', 0),
(69, 8, '11', 'Table 9', 0),
(70, 8, '11', 'Table 10', 0),
(71, 8, '11', 'Grab', 0),
(72, 8, '11', 'Take Away', 0),
(73, 7, '12', 'Table 1', 1),
(74, 7, '12', 'Table 2', 0),
(75, 7, '12', 'Table 3', 0),
(76, 7, '12', 'Table 4', 0),
(77, 7, '12', 'Table 5', 0),
(78, 7, '12', 'Table 6', 0),
(79, 7, '12', 'Table 7', 0),
(80, 7, '12', 'Table 8', 0),
(81, 7, '12', 'Table 9', 0),
(82, 7, '12', 'Table 10', 0),
(83, 7, '12', 'Table 11', 0),
(84, 7, '12', 'Table 11', 0),
(85, 7, '12', 'Table 12', 0),
(86, 7, '12', 'Table 13', 0),
(87, 7, '12', 'Table 14', 0),
(88, 7, '12', 'Table 15', 0),
(89, 7, '12', 'Table 16', 0),
(90, 7, '12', 'Table 17', 0),
(91, 7, '12', 'Table 18', 0),
(92, 7, '12', 'Table 19', 0),
(93, 7, '12', 'Table 20', 0),
(94, 7, '12', 'Take Away 1', 0),
(95, 7, '12', 'Take Away 2', 0),
(96, 7, '12', 'Take Away 3', 0),
(98, 7, '12', 'Take Away 4', 0),
(99, 7, '12', 'Take Away 5', 0),
(100, 7, '12', 'Take Away 6', 0),
(101, 9, '13', 'Table 1', 0),
(102, 9, '13', 'Table 2', 0),
(103, 9, '13', 'Table 3', 0),
(104, 9, '13', 'Table 4', 0),
(105, 9, '13', 'Table 5', 0),
(106, 9, '13', 'Table 6', 0),
(107, 9, '13', 'Table 7', 0),
(108, 9, '13', 'Table 8', 0),
(109, 9, '13', 'Table 9', 0),
(110, 9, '13', 'Table 10', 0),
(111, 9, '13', 'Grab 1', 0),
(112, 9, '13', 'Grab 2', 0),
(113, 9, '14', 'Room 201', 0),
(114, 9, '14', 'Room 202', 0),
(115, 9, '14', 'Room 301', 0),
(116, 9, '14', 'Room 302', 0),
(117, 9, '14', 'Room 303', 0),
(118, 9, '14', 'Room 304', 0),
(119, 9, '14', 'Room 305', 0),
(120, 9, '14', 'Room 401', 0),
(121, 9, '14', 'Room 402', 0),
(122, 9, '14', 'Room 403', 0),
(123, 9, '14', 'Room 404', 0),
(124, 9, '14', 'Room 405', 0),
(125, 9, '14', 'Room 501', 0),
(126, 9, '14', 'Room 502', 0),
(127, 9, '14', 'Room 503', 0),
(128, 9, '14', 'Room 504', 0),
(129, 9, '14', 'Room 505', 0);

-- --------------------------------------------------------

--
-- Table structure for table `table_category`
--

DROP TABLE IF EXISTS `table_category`;
CREATE TABLE IF NOT EXISTS `table_category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `cat_name` varchar(222) COLLATE utf8mb4_general_ci NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_table_categories_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `table_category`
--

INSERT INTO `table_category` (`id`, `shop_id`, `cat_name`, `status`) VALUES
(9, 4, 'FGood', 0),
(10, 5, 'Food', 0),
(11, 8, 'Retstaurant', 0),
(12, 7, 'Restaurant', 0),
(13, 9, 'Restaurant', 0),
(14, 9, 'Hotel Room', 0);

-- --------------------------------------------------------

--
-- Table structure for table `taxes`
--

DROP TABLE IF EXISTS `taxes`;
CREATE TABLE IF NOT EXISTS `taxes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taxname` varchar(122) NOT NULL,
  `taxvalue` int NOT NULL,
  `included` varchar(10) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'InActive',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `taxes`
--

INSERT INTO `taxes` (`id`, `taxname`, `taxvalue`, `included`, `status`) VALUES
(5, 'Vat', 7, 'true', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
CREATE TABLE IF NOT EXISTS `units` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `name` varchar(233) NOT NULL,
  `description` varchar(233) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `shop_id`, `name`, `description`) VALUES
(16, 4, 'Pcs', 'dsd'),
(17, 4, 'cup', ''),
(18, 5, 'Plate', ''),
(19, 5, 'Pcs.', ''),
(20, 5, 'Bowl', ''),
(21, 7, 'Pcs', ''),
(22, 7, 'Bowl', ''),
(23, 7, 'Plate', ''),
(24, 8, 'btl', ''),
(25, 8, 'cann', ''),
(26, 8, 'plate', ''),
(27, 8, 'bowl', ''),
(28, 8, 'cup', ''),
(29, 5, 'peg', ''),
(30, 5, 'btl', '');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `user_uuid` varchar(36) DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `uname` varchar(233) NOT NULL,
  `pass` text NOT NULL,
  `contact` varchar(233) NOT NULL DEFAULT '0',
  `email` varchar(233) NOT NULL,
  `type` varchar(112) NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `last_loggedin` varchar(233) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_uuid` (`user_uuid`),
  KEY `idx_user_uuid` (`user_uuid`),
  KEY `idx_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=191 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `shop_id`, `user_uuid`, `name`, `uname`, `pass`, `contact`, `email`, `type`, `status`, `last_loggedin`) VALUES
(179, 4, 'fb6bbf18-d68a-4e5a-8c9a-6efd128abfa3', 'Cloud Admin', '63651', '$2a$10$M0I2MPEEuS0A7dDXWzKuo.3zzwqmvXSnl/gONXHjYBjsJTdGVml1S', '', '', 'admin', 1, ''),
(180, 5, 'd790f3bf-4987-4000-b395-95258824063e', 'Demo', '18594', '$2a$10$loTxQna6AQrTjfTGVvDmteBkpgEQ/hAVCFAGb.rkzN/T12tLB3ftq', '+661234567995', 'demo@chefmatepro.com', 'admin', 1, ''),
(181, 5, '06f56e45-e5a8-42b2-82f6-6cb512eb52a5', 'Cashier Demo', '13718', '$2a$10$eU0CrcIWx34p/wiZ7PPvHOnQBePuAsqQsHSXNBCCl0zO/o1R40NPm', '46151615', 'cashier434@gmail.com', 'Cashier', 1, '2026-03-29'),
(182, 7, 'be2492b4-0fec-4482-8dae-4760cea6e86e', 'Jasleen Admin', '51634', '$2a$10$72Ky8Uqqtu2jhOzjQ6wtDep./zjg8EUJDQYmjuCC2enXjU0iXR.hW', '', '', 'admin', 1, ''),
(183, 7, '39ac2eca-17fb-400e-96da-1903281eb4ba', 'Cashier Jasleen', '27412', '$2a$10$6XhWcn4IjHD7QXwuhGMzMubBRVr3kfByCSSTQgcQ8ZE3freztTziG', '123456', 'cashier01@gmail.com', 'Cashier', 1, '2026-03-29'),
(184, 7, '072f0461-1209-44c5-be01-a11c40e2a6f3', 'Manager', '1465', '$2a$10$H14L8b/K9JFako.UdF81/uF8T3pAKHbAKv1XHvjaREbS1y4R9Flyu', '123', 'manager@gmail.com', 'Account', 1, '2026-04-02'),
(185, 8, '54384f29-75ef-4c59-a1b9-61ae08278cf5', 'Sunrise Admin', '79969', '$2a$10$OfjFWmQstpb7fWzvj.UskezaSSXriIPIQ9.6A2k5Qc5Yv4K5InJJW', '+66-805401625', 'rajkirthwal@outlook.com', 'admin', 1, ''),
(186, 8, '67893942-6939-4ec0-8c14-ef95585857e2', 'Sunrise Cashier', '58271', '$2a$10$CctYZGfgOi73LBianDPmnOjVvOKhS15XccU..9cqWUOLTHm3WDJfW', '123456', 'sunrisecashier@gmail.com', 'Cashier', 1, '2026-04-02'),
(187, 9, '3a6ff780-ac7e-44dd-b803-aa12d92e69dd', 'Narender Admin', '69408', '$2a$10$cdfSR1kTex6l7cug0CQVtu95DSzgkKYPbKcuF9z1aL8/DS0V4lr6q', '+66-800062602', 'welcomesuit@gmail.com', 'admin', 1, ''),
(188, 9, '15389e35-087c-4443-882e-2eb8ca801b78', 'Cashier Welcome Suit', '32741', '$2a$10$xn6vMcxwzGiUlv2Bw5SKku9h6Xr9MbQDI2jwTPUpz.w2TDuc7ZJ9a', '+66-800062602', 'welcomecashier@gmail.com', 'Cashier', 1, ''),
(189, 7, 'd291fd7c-47c8-4831-9523-3c298f67a904', 'test', '20070', '$2a$10$C6IadyzZTiKvzYmr7BFEieZFH9KWx6TA/HB3TAQO91nQHL4eE2Axi', '21325', 'khajonpong55@gmail.com', 'Cashier', 1, '2026-04-23'),
(190, 5, 'dd022cc7-1e7a-4b8d-ac2a-8eba598fe5f1', 'Manager', '49678', '$2a$10$5X61iaz5Thx25GYqiXKnqumFACxYAQgz2i3SFpQXxJz3LeOtZNE5q', '2542354546', 'axialtour55@gmail.com', 'Account', 1, '2026-05-13');

-- --------------------------------------------------------

--
-- Table structure for table `users_subs`
--

DROP TABLE IF EXISTS `users_subs`;
CREATE TABLE IF NOT EXISTS `users_subs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('admin','manager','cashier','accountant') COLLATE utf8mb4_general_ci DEFAULT 'cashier',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users_subs`
--

INSERT INTO `users_subs` (`id`, `username`, `email`, `password_hash`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
(1, '3130', 'adminchef@gmail.com', '$2a$10$OktzxujrxGpv2H6a5OQ3JuSxpULhZPJ92uDr5Lwko0k1AI1rHf5D2', 'admin', 1, '2025-07-17 10:55:50', '2025-07-17 10:55:50');

-- --------------------------------------------------------

--
-- Table structure for table `usertypes`
--

DROP TABLE IF EXISTS `usertypes`;
CREATE TABLE IF NOT EXISTS `usertypes` (
  `id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `usertypes`
--

INSERT INTO `usertypes` (`id`, `name`, `description`) VALUES
(1, 'Admin', 'Administrator with full access to all features.'),
(2, 'Editor', 'Editor with access to content creation and editing.'),
(3, 'Viewer', 'Viewer with read-only access to content.'),
(4, 'Contributor', 'Contributor with limited access to create and edit their own content.'),
(5, 'Guest', 'Guest with limited access to view public content.');

-- --------------------------------------------------------

--
-- Table structure for table `user_devices`
--

DROP TABLE IF EXISTS `user_devices`;
CREATE TABLE IF NOT EXISTS `user_devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `user_id` int NOT NULL COMMENT 'References users.id',
  `mac_address` varchar(17) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Device MAC address',
  `device_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Friendly device name',
  `device_type` enum('desktop','laptop','tablet','mobile','other') COLLATE utf8mb4_unicode_ci DEFAULT 'desktop',
  `status` enum('active','inactive','blocked') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `last_login_at` timestamp NULL DEFAULT NULL COMMENT 'Last successful login',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_mac_address` (`mac_address`),
  KEY `idx_status` (`status`),
  KEY `unique_user_mac` (`user_id`,`mac_address`),
  KEY `idx_user_devices_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vending_inventory`
--

DROP TABLE IF EXISTS `vending_inventory`;
CREATE TABLE IF NOT EXISTS `vending_inventory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `product_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `max_quantity` int DEFAULT '10',
  `min_threshold` int DEFAULT '2',
  `last_updated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_machine_product` (`machine_id`,`product_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_vending_inventory_machine_quantity` (`machine_id`,`quantity`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vending_inventory`
--

INSERT INTO `vending_inventory` (`id`, `machine_id`, `product_id`, `product_name`, `price`, `quantity`, `max_quantity`, `min_threshold`, `last_updated`, `created_at`) VALUES
(1, 'VM001', 'DRINK001', 'Coca Cola 330ml', 2.50, 10, 15, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(2, 'VM001', 'DRINK002', 'Pepsi 330ml', 2.50, 8, 15, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(3, 'VM001', 'SNACK001', 'Chips - Classic', 3.00, 5, 12, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(4, 'VM001', 'SNACK002', 'Chocolate Bar', 2.75, 7, 10, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(5, 'VM002', 'DRINK001', 'Coca Cola 330ml', 2.50, 12, 20, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(6, 'VM002', 'DRINK003', 'Orange Juice 500ml', 3.50, 6, 10, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(7, 'VM002', 'SNACK003', 'Cookies Pack', 2.25, 8, 12, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(8, 'VM003', 'DRINK004', 'Water 500ml', 1.50, 15, 25, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(9, 'VM003', 'DRINK005', 'Coffee 250ml', 3.00, 4, 8, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44'),
(10, 'VM003', 'SNACK004', 'Nuts Mix', 4.00, 3, 8, 2, '2025-09-18 16:36:44', '2025-09-18 16:36:44');

-- --------------------------------------------------------

--
-- Table structure for table `vending_machines`
--

DROP TABLE IF EXISTS `vending_machines`;
CREATE TABLE IF NOT EXISTS `vending_machines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `status` enum('online','offline','maintenance','error') COLLATE utf8mb4_general_ci DEFAULT 'offline',
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `last_heartbeat` datetime DEFAULT NULL,
  `setup_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `machine_id` (`machine_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`location`(250))
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vending_machines`
--

INSERT INTO `vending_machines` (`id`, `machine_id`, `name`, `location`, `status`, `configuration`, `last_heartbeat`, `setup_date`, `created_at`, `updated_at`) VALUES
(1, 'VM001', 'Main Hall Vending Machine', 'Building A - Main Hall', 'offline', '{\"temperature_control\": true, \"payment_methods\": [\"cash\", \"card\"], \"max_items\": 50}', NULL, '2025-09-18 16:36:43', '2025-09-18 16:36:43', '2025-09-18 16:36:43'),
(2, 'VM002', 'Cafeteria Vending Machine', 'Building B - Cafeteria', 'offline', '{\"temperature_control\": false, \"payment_methods\": [\"cash\", \"card\", \"mobile\"], \"max_items\": 40}', NULL, '2025-09-18 16:36:43', '2025-09-18 16:36:43', '2025-09-18 16:36:43'),
(3, 'VM003', 'Office Vending Machine', 'Building C - Office Floor 3', 'offline', '{\"temperature_control\": true, \"payment_methods\": [\"card\", \"mobile\"], \"max_items\": 30}', NULL, '2025-09-18 16:36:43', '2025-09-18 16:36:43', '2025-09-18 16:36:43');

-- --------------------------------------------------------

--
-- Table structure for table `vending_transactions`
--

DROP TABLE IF EXISTS `vending_transactions`;
CREATE TABLE IF NOT EXISTS `vending_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `machine_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `product_id` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','completed','failed','cancelled') COLLATE utf8mb4_general_ci DEFAULT 'pending',
  `payment_method` enum('cash','card','mobile','wallet') COLLATE utf8mb4_general_ci DEFAULT 'cash',
  `user_id` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_vending_transactions_machine_status` (`machine_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `advance_final_bill`
--
ALTER TABLE `advance_final_bill`
  ADD CONSTRAINT `advance_final_bill_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `advance_order_items`
--
ALTER TABLE `advance_order_items`
  ADD CONSTRAINT `advance_order_items_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `bill_edit_logs`
--
ALTER TABLE `bill_edit_logs`
  ADD CONSTRAINT `bill_edit_logs_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cash_drawer`
--
ALTER TABLE `cash_drawer`
  ADD CONSTRAINT `cash_drawer_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `company_profile`
--
ALTER TABLE `company_profile`
  ADD CONSTRAINT `company_profile_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `device_auth_settings`
--
ALTER TABLE `device_auth_settings`
  ADD CONSTRAINT `device_auth_settings_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_device_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `error_logs`
--
ALTER TABLE `error_logs`
  ADD CONSTRAINT `error_logs_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `feature_usage`
--
ALTER TABLE `feature_usage`
  ADD CONSTRAINT `feature_usage_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `final_bill`
--
ALTER TABLE `final_bill`
  ADD CONSTRAINT `final_bill_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `final_bill_ibfk_2` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `fk_inventory_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kiosk_queue`
--
ALTER TABLE `kiosk_queue`
  ADD CONSTRAINT `fk_kiosk_queue_bill` FOREIGN KEY (`bill_id`) REFERENCES `final_bill` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `loyalty_members`
--
ALTER TABLE `loyalty_members`
  ADD CONSTRAINT `fk_loyalty_members_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_member_programs`
--
ALTER TABLE `loyalty_member_programs`
  ADD CONSTRAINT `fk_loyalty_member_program_member` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_member_program_program` FOREIGN KEY (`program_id`) REFERENCES `loyalty_programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_notification_queue`
--
ALTER TABLE `loyalty_notification_queue`
  ADD CONSTRAINT `fk_loyalty_notification_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_notification_member` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_offers`
--
ALTER TABLE `loyalty_offers`
  ADD CONSTRAINT `fk_loyalty_offers_program` FOREIGN KEY (`program_id`) REFERENCES `loyalty_programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_redemptions`
--
ALTER TABLE `loyalty_redemptions`
  ADD CONSTRAINT `fk_loyalty_redemptions_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_redemptions_member` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_redemptions_member_program` FOREIGN KEY (`member_program_id`) REFERENCES `loyalty_member_programs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_redemptions_offer` FOREIGN KEY (`offer_id`) REFERENCES `loyalty_offers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_loyalty_redemptions_program` FOREIGN KEY (`program_id`) REFERENCES `loyalty_programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  ADD CONSTRAINT `fk_loyalty_tx_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_loyalty_tx_member` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notification_read_status`
--
ALTER TABLE `notification_read_status`
  ADD CONSTRAINT `notification_read_status_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_records`
--
ALTER TABLE `payment_records`
  ADD CONSTRAINT `payment_records_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payment_records_ibfk_2` FOREIGN KEY (`subscription_id`) REFERENCES `shop_subscriptions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `payment_reminders`
--
ALTER TABLE `payment_reminders`
  ADD CONSTRAINT `payment_reminders_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payment_reminders_ibfk_2` FOREIGN KEY (`payment_record_id`) REFERENCES `payment_records` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD CONSTRAINT `payment_transactions_ibfk_1` FOREIGN KEY (`bill_id`) REFERENCES `final_bill` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `printer_config`
--
ALTER TABLE `printer_config`
  ADD CONSTRAINT `printer_config_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_units`
--
ALTER TABLE `product_units`
  ADD CONSTRAINT `fk_product_units_item` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `fk_variant_base_unit` FOREIGN KEY (`base_unit_id`) REFERENCES `product_units` (`id`),
  ADD CONSTRAINT `fk_variant_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `purchase_items`
--
ALTER TABLE `purchase_items`
  ADD CONSTRAINT `purchase_items_ibfk_1` FOREIGN KEY (`purchase_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `purchase_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`),
  ADD CONSTRAINT `purchase_items_ibfk_3` FOREIGN KEY (`unit_id`) REFERENCES `product_units` (`id`);

--
-- Constraints for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  ADD CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `purchase_payments`
--
ALTER TABLE `purchase_payments`
  ADD CONSTRAINT `purchase_payments_ibfk_1` FOREIGN KEY (`purchase_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `quotation_history`
--
ALTER TABLE `quotation_history`
  ADD CONSTRAINT `fk_quotation_history_quotation` FOREIGN KEY (`quotation_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `quotation_items`
--
ALTER TABLE `quotation_items`
  ADD CONSTRAINT `fk_quotation_items_quotation` FOREIGN KEY (`order_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `shop_admins`
--
ALTER TABLE `shop_admins`
  ADD CONSTRAINT `shop_admins_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shop_audit_logs`
--
ALTER TABLE `shop_audit_logs`
  ADD CONSTRAINT `shop_audit_logs_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `shop_billing`
--
ALTER TABLE `shop_billing`
  ADD CONSTRAINT `shop_billing_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shop_billing_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`);

--
-- Constraints for table `shop_subscriptions`
--
ALTER TABLE `shop_subscriptions`
  ADD CONSTRAINT `shop_subscriptions_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shop_subscriptions_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`);

--
-- Constraints for table `stock_balance`
--
ALTER TABLE `stock_balance`
  ADD CONSTRAINT `fk_stock_balance_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_stock_balance_unit` FOREIGN KEY (`unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stock_balance_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stock_conversions`
--
ALTER TABLE `stock_conversions`
  ADD CONSTRAINT `fk_conversion_from_unit` FOREIGN KEY (`from_unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_conversion_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_conversion_to_unit` FOREIGN KEY (`to_unit_id`) REFERENCES `product_units` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stock_conversions_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stock_transactions`
--
ALTER TABLE `stock_transactions`
  ADD CONSTRAINT `fk_stock_trans_product` FOREIGN KEY (`product_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_stock_trans_unit` FOREIGN KEY (`unit_id`) REFERENCES `product_units` (`id`),
  ADD CONSTRAINT `stock_transactions_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `super_admin_users`
--
ALTER TABLE `super_admin_users`
  ADD CONSTRAINT `fk_sau_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_tickets_ibfk_2` FOREIGN KEY (`error_log_id`) REFERENCES `error_logs` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `support_ticket_comments`
--
ALTER TABLE `support_ticket_comments`
  ADD CONSTRAINT `support_ticket_comments_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `units`
--
ALTER TABLE `units`
  ADD CONSTRAINT `units_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_devices`
--
ALTER TABLE `user_devices`
  ADD CONSTRAINT `fk_user_devices_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
