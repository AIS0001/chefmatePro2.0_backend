-- MariaDB dump 10.19  Distrib 10.11.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: chefmate_pindbulluchi_db
-- ------------------------------------------------------
-- Server version	10.11.6-MariaDB-0+deb12u1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `advance_final_bill`
--

DROP TABLE IF EXISTS `advance_final_bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advance_final_bill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `inv_date` date NOT NULL,
  `inv_time` time(6) NOT NULL,
  `table_number` varchar(50) DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `discount_type` varchar(10) NOT NULL DEFAULT '0',
  `discount_value` float NOT NULL,
  `discount_amount` float NOT NULL,
  `subtotal_afterdiscount` float NOT NULL DEFAULT 0,
  `tax` decimal(15,2) NOT NULL,
  `roundoff` float NOT NULL DEFAULT 0,
  `grand_total` decimal(15,2) NOT NULL,
  `payment_mode` enum('Cash','Credit','Card','UPI','Split') NOT NULL,
  `setup_dte` timestamp NULL DEFAULT current_timestamp(),
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `final_billed` tinyint(1) NOT NULL,
  `bill_generated_by` varchar(15) NOT NULL,
  `pickup_date` date NOT NULL,
  `pickup_time` time(6) DEFAULT NULL,
  `special_note` varchar(200) NOT NULL,
  `order_type` varchar(50) NOT NULL,
  `created_by` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advance_final_bill`
--

LOCK TABLES `advance_final_bill` WRITE;
/*!40000 ALTER TABLE `advance_final_bill` DISABLE KEYS */;
INSERT INTO `advance_final_bill` VALUES
(1,0,'2025-06-13','14:51:19.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 07:51:19',0,0.00,0,'Jyoti0001','2025-06-28','14:31:00.000000','jyjtutyutu','Delivery','2025-06-13 14:51:19'),
(2,0,'2025-06-13','15:20:01.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 08:20:01',0,0.00,0,'Jyoti0001','2025-06-14','00:00:00.000000','','','2025-06-13 15:20:01'),
(3,0,'2025-06-13','15:22:14.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 08:22:14',0,0.00,0,'Jyoti0001','2025-06-14','00:00:00.000000','','','2025-06-13 15:22:14'),
(4,0,'2025-06-13','15:31:02.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 08:31:02',0,0.00,0,'Jyoti0001','2025-06-14','00:00:00.000000','','','2025-06-13 15:31:02'),
(5,0,'2025-06-13','15:31:17.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 08:31:17',0,0.00,0,'Jyoti0001','2025-06-14','15:32:00.000000','gyrgyt','ytrfyfty','2025-06-13 15:31:17'),
(6,0,'2025-06-13','15:31:51.000000','',180.00,'',0,0,180,0.00,0,0.00,'','2025-06-13 08:31:51',0,0.00,0,'Jyoti0001','2025-06-14','15:32:00.000000','gyrgyt','ytrfyfty','2025-06-13 15:31:51'),
(7,0,'2025-06-13','15:38:31.000000','',655.00,'',0,0,655,0.00,0,0.00,'','2025-06-13 08:38:31',0,0.00,0,'Jyoti0001','2025-06-14','15:32:00.000000','Call before delivery','Delivery','2025-06-13 15:38:31'),
(8,0,'2025-06-13','15:43:00.000000','',575.00,'',0,0,575,0.00,0,0.00,'','2025-06-13 08:43:00',0,0.00,0,'Jyoti0001','0000-00-00','00:00:00.000000','','','2025-06-13 15:43:00'),
(9,0,'2025-06-13','15:47:45.000000','',340.00,'amount',0,0,340,0.00,0,340.00,'','2025-06-13 08:47:45',0,0.00,0,'Jyoti0001','2025-06-26','15:48:00.000000','Deliver before call','Deloivery','2025-06-13 15:47:45'),
(10,0,'2025-06-13','16:13:17.000000','',100.00,'amount',0,0,100,0.00,0,100.00,'Credit','2025-06-13 09:13:17',0,0.00,0,'Jyoti0001','2025-06-25','19:15:00.000000','Delivery by car.call before reach','Pickup shop','2025-06-13 16:13:17'),
(11,0,'2025-06-13','16:15:23.000000','',260.00,'amount',0,0,260,0.00,0,260.00,'Credit','2025-06-13 09:15:23',0,0.00,0,'Jyoti0001','2025-06-24','22:19:00.000000','Delivery by car.call before reach','Pickup shop','2025-06-13 16:15:23'),
(12,0,'2025-06-13','18:14:25.000000','',140.00,'percentage',0,0,140,0.00,0,140.00,'Credit','2025-06-13 11:14:25',0,0.00,0,'Jyoti0001','2025-06-26','22:18:00.000000','jhgjhgjh','jghj','2025-06-13 18:14:25'),
(13,0,'2025-06-13','18:14:51.000000','',130.00,'percentage',0,0,130,0.00,0,130.00,'Credit','2025-06-13 11:14:51',0,0.00,0,'Jyoti0001','2025-06-26','22:18:00.000000','jhgjhgjh','jghj','2025-06-13 18:14:51'),
(14,0,'2025-06-17','11:55:33.000000','',390.00,'amount',0,0,390,0.00,0,390.00,'Credit','2025-06-17 04:55:33',2,0.00,0,'Jyoti0001','2025-06-26','03:54:00.000000','COme to shop','Delivery','2025-06-17 11:55:33'),
(15,0,'2025-06-21','17:15:54.000000','',1725.00,'amount',0,0,1725,0.00,0,1725.00,'Credit','2025-06-21 10:15:54',0,0.00,0,'Jyoti0001','2025-06-30','10:20:00.000000','Collect from shop','Delivery','2025-06-21 17:15:54'),
(16,0,'2025-06-21','17:22:31.000000','',240.00,'amount',0,0,240,0.00,0,240.00,'Credit','2025-06-21 10:22:31',0,0.00,0,'Jyoti0001','2025-06-26','20:25:00.000000','','Delivery','2025-06-21 17:22:31'),
(17,0,'2025-06-21','17:26:30.000000','',180.00,'amount',0,0,180,0.00,0,180.00,'Credit','2025-06-21 10:26:30',0,0.00,0,'Jyoti0001','2025-06-24','20:29:00.000000','yhfgyhfh','hfghfgh','2025-06-21 17:26:30'),
(18,0,'2025-07-15','18:40:49.000000','',150.00,'percentage',10,0,855,0.00,0.15,915.00,'Cash','2025-07-15 11:40:49',0,0.00,0,'3130','0000-00-00','00:00:00.000000','','','2025-07-15 18:40:49'),
(19,0,'2025-07-15','18:41:47.000000','',300.00,'percentage',10,0,585,0.00,0.05,626.00,'Cash','2025-07-15 11:41:47',0,0.00,0,'3130','0000-00-00','00:00:00.000000','','','2025-07-15 18:41:47');
/*!40000 ALTER TABLE `advance_final_bill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advance_order_items`
--

DROP TABLE IF EXISTS `advance_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advance_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advance_order_items`
--

LOCK TABLES `advance_order_items` WRITE;
/*!40000 ALTER TABLE `advance_order_items` DISABLE KEYS */;
INSERT INTO `advance_order_items` VALUES
(1,14,'Table 1','Mineral Water',1,40.00,'2025-06-13 10:39:34','13',0),
(2,14,'Table 1','Pepsit 500ML',1,50.00,'2025-06-13 10:39:34','13',0),
(3,14,'Table 1','Coke 320ML',1,40.00,'2025-06-13 10:39:34','13',0),
(4,15,'Table 5','Salt Lassi',1,50.00,'2025-06-13 10:59:54','12',0),
(5,15,'Table 5','Mineral Water',1,40.00,'2025-06-13 10:59:54','12',0),
(6,15,'Table 5','Pepsit 500ML',1,50.00,'2025-06-13 10:59:54','12',0),
(7,2,'Take Away','VAT ITEM 3',1,150.00,'2025-07-15 11:25:41','18',0),
(8,2,'Take Away','VAT ITEM 4',2,200.00,'2025-07-15 11:25:41','18',0),
(9,2,'Take Away','vatitem',2,600.00,'2025-07-15 11:25:41','18',0),
(10,3,'Table 9','vatitem',1,300.00,'2025-07-15 11:41:31','19',0),
(11,3,'Table 9','VAT ITEM 3',1,150.00,'2025-07-15 11:41:31','19',0),
(12,3,'Table 9','VAT ITEM 4',2,200.00,'2025-07-15 11:41:31','19',0);
/*!40000 ALTER TABLE `advance_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advance_order_items_gst`
--

DROP TABLE IF EXISTS `advance_order_items_gst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advance_order_items_gst` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `uom` varchar(50) NOT NULL,
  `rate` decimal(10,2) NOT NULL,
  `cgst` decimal(10,2) NOT NULL,
  `sgst` decimal(10,2) NOT NULL,
  `igst` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advance_order_items_gst`
--

LOCK TABLES `advance_order_items_gst` WRITE;
/*!40000 ALTER TABLE `advance_order_items_gst` DISABLE KEYS */;
INSERT INTO `advance_order_items_gst` VALUES
(1,6,'Table 7','test',2,'',100.00,3.50,3.50,0.00,7.00,200.00,'2025-06-13 07:03:19','16',0),
(2,6,'Table 7','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-13 07:03:19','16',0),
(3,7,'Table 5','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-06-13 07:03:41','6',0),
(4,7,'Table 5','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-13 07:03:41','6',0),
(5,8,'Table 9','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-06-13 08:37:44','7',0),
(6,8,'Table 9','Chicken Curry',1,'',250.00,0.00,0.00,0.00,0.00,250.00,'2025-06-13 08:37:44','7',0),
(7,8,'Table 9','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-13 08:37:44','7',0),
(8,9,'Table 3','Tawa Roti',3,'',25.00,0.00,0.00,0.00,0.00,75.00,'2025-06-13 08:40:54','8',0),
(9,9,'Table 3','Chicken Curry',2,'',250.00,0.00,0.00,0.00,0.00,500.00,'2025-06-13 08:40:54','8',0),
(10,10,'Table 6','Salt Lassi',2,'',50.00,0.00,0.00,0.00,0.00,100.00,'2025-06-13 08:47:08','9',0),
(11,10,'Table 6','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-13 08:47:08','9',0),
(12,10,'Table 6','Aloo Pyaj  Parantha',2,'',100.00,0.00,0.00,0.00,0.00,200.00,'2025-06-13 08:47:08','9',0),
(13,11,'Table 3','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-06-13 09:12:33','10',0),
(14,11,'Table 3','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-13 09:12:33','10',0),
(15,12,'Table 3','Aloo Parantha',2,'',80.00,0.00,0.00,0.00,0.00,160.00,'2025-06-13 09:14:37','11',0),
(16,12,'Table 3','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-13 09:14:37','11',0),
(17,16,'Table 1','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-06-17 04:54:38','14',0),
(18,16,'Table 1','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-17 04:54:38','14',0),
(19,16,'Table 1','Aloo Parantha',2,'',80.00,0.00,0.00,0.00,0.00,160.00,'2025-06-17 04:54:38','14',0),
(20,16,'Table 1','Namkeen Parantha',2,'',65.00,0.00,0.00,0.00,0.00,130.00,'2025-06-17 04:54:38','14',0),
(21,17,'Table 3','Tandoori Roti',6,'',25.00,0.00,0.00,0.00,0.00,150.00,'2025-06-21 10:15:02','15',0),
(22,17,'Table 3','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 10:15:02','15',0),
(23,17,'Table 3','Mutton Briyani',2,'',350.00,2.50,2.50,0.00,17.50,700.00,'2025-06-21 10:15:02','15',0),
(24,17,'Table 3','Chicken Curry',3,'',250.00,0.00,0.00,0.00,0.00,750.00,'2025-06-21 10:15:02','15',0),
(25,18,'Table 2','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 10:26:12','17',0),
(26,18,'Table 2',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 10:26:12','17',0),
(27,18,'Table 2','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-06-21 10:26:12','17',0);
/*!40000 ALTER TABLE `advance_order_items_gst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advance_orders`
--

DROP TABLE IF EXISTS `advance_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advance_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(233) NOT NULL,
  `order_number` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advance_orders`
--

LOCK TABLES `advance_orders` WRITE;
/*!40000 ALTER TABLE `advance_orders` DISABLE KEYS */;
INSERT INTO `advance_orders` VALUES
(25,'Jyoti0001',16,'Table 1',390.00,'2025-06-17 04:54:38',NULL,1),
(24,'Jyoti0001',15,'Table 5',140.00,'2025-06-13 10:59:54',NULL,1),
(23,'Jyoti0001',14,'Table 1',130.00,'2025-06-13 10:39:34',NULL,1),
(22,'Jyoti0001',14,'Table 1',130.00,'2025-06-13 10:39:20',NULL,1),
(21,'Jyoti0001',13,'Table 1',130.00,'2025-06-13 10:36:44',NULL,1),
(26,'Jyoti0001',17,'Table 3',1725.00,'2025-06-21 10:15:01',NULL,1),
(27,'Jyoti0001',18,'Table 2',180.00,'2025-06-21 10:26:12',NULL,1),
(28,'3130',2,'Take Away',950.00,'2025-07-15 11:25:40',NULL,1),
(29,'3130',3,'Table 9',650.00,'2025-07-15 11:41:31',NULL,1);
/*!40000 ALTER TABLE `advance_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cash_drawer`
--

DROP TABLE IF EXISTS `cash_drawer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_drawer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `open_date` date NOT NULL,
  `opening_cash` decimal(10,2) NOT NULL DEFAULT 0.00,
  `closing_cash` decimal(10,2) NOT NULL DEFAULT 0.00,
  `expected_cash` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cash_difference` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cash_in` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cash_out` decimal(10,2) NOT NULL DEFAULT 0.00,
  `opened_by` varchar(100) DEFAULT NULL,
  `closed_by` varchar(100) DEFAULT NULL,
  `opening_time` timestamp NULL DEFAULT NULL,
  `closing_time` timestamp NULL DEFAULT NULL,
  `status` enum('open','closed') DEFAULT 'open',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_open_date` (`open_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_drawer`
--

LOCK TABLES `cash_drawer` WRITE;
/*!40000 ALTER TABLE `cash_drawer` DISABLE KEYS */;
/*!40000 ALTER TABLE `cash_drawer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(233) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(10,'Dishes'),
(11,'Drinks');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_profile`
--

DROP TABLE IF EXISTS `company_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'Company name (required)',
  `tax_id` varchar(100) NOT NULL COMMENT 'Tax identification number (required)',
  `phone_number` varchar(50) NOT NULL COMMENT 'Primary phone number (required)',
  `email` varchar(255) NOT NULL COMMENT 'Primary email address (required)',
  `address` text NOT NULL COMMENT 'Complete address (required)',
  `website` varchar(255) DEFAULT NULL COMMENT 'Company website URL',
  `city` varchar(100) DEFAULT NULL COMMENT 'City',
  `state` varchar(100) DEFAULT NULL COMMENT 'State/Province',
  `zip_code` varchar(20) DEFAULT NULL COMMENT 'ZIP/Postal code',
  `country` varchar(100) DEFAULT NULL COMMENT 'Country',
  `logo` longblob DEFAULT NULL COMMENT 'Company logo image (BLOB)',
  `logo_type` varchar(50) DEFAULT NULL COMMENT 'Logo MIME type (e.g., image/png)',
  `logo_name` varchar(255) DEFAULT NULL COMMENT 'Original logo filename',
  `qr_code` longblob DEFAULT NULL COMMENT 'QR code image (BLOB)',
  `qr_code_type` varchar(50) DEFAULT NULL COMMENT 'QR code MIME type',
  `qr_code_name` varchar(255) DEFAULT NULL COMMENT 'Original QR code filename',
  `bank_name` varchar(255) DEFAULT NULL COMMENT 'Bank name',
  `account_number` varchar(100) DEFAULT NULL COMMENT 'Bank account number',
  `account_name` varchar(255) DEFAULT NULL COMMENT 'Account holder name',
  `routing_number` varchar(50) DEFAULT NULL COMMENT 'Bank routing number',
  `swift_code` varchar(20) DEFAULT NULL COMMENT 'SWIFT/BIC code',
  `payment_methods` text DEFAULT NULL COMMENT 'Accepted payment methods',
  `terms_and_conditions` text DEFAULT NULL COMMENT 'Terms and conditions text',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Record creation timestamp',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Record last update timestamp',
  `created_by` int(11) DEFAULT NULL COMMENT 'User ID who created the record',
  `updated_by` int(11) DEFAULT NULL COMMENT 'User ID who last updated the record',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Active status (1=active, 0=inactive)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tax_id` (`tax_id`),
  UNIQUE KEY `unique_email` (`email`),
  KEY `idx_company_name` (`name`),
  KEY `idx_city` (`city`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_company_profile_search` (`name`,`email`,`city`),
  KEY `idx_company_profile_status` (`is_active`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company information and settings';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_profile`
--

LOCK TABLES `company_profile` WRITE;
/*!40000 ALTER TABLE `company_profile` DISABLE KEYS */;
INSERT INTO `company_profile` VALUES
(1,'ChefMate Restaurant Solutions','TAX123456789','+1-555-123-4567','info@chefmate.com','123 Restaurant Street, Food District','https://www.chefmate.com','Bangkok','Bangkok Metropolitan','10110','Thailand',NULL,NULL,NULL,NULL,NULL,NULL,'Bangkok Bank',NULL,'ChefMate Restaurant Solutions Co., Ltd.',NULL,NULL,'Cash, Credit Card, Debit Card, Bank Transfer, Mobile Payment','Terms and Conditions:\r\n\r\n1. Payment Terms:\r\n   - Payment is due upon receipt of invoice\r\n   - Late payments may incur additional charges\r\n   - All prices are subject to applicable taxes\r\n\r\n2. Return Policy:\r\n   - Items must be returned within 30 days\r\n   - Original receipt required for all returns\r\n   - Perishable items cannot be returned\r\n\r\n3. Warranty:\r\n   - Equipment warranty as per manufacturer terms\r\n   - Software support included for first year\r\n   - Extended warranty available upon request\r\n\r\n4. Liability:\r\n   - Company liability limited to product value\r\n   - Customer responsible for proper usage\r\n   - Installation and training provided\r\n\r\nFor questions or support, contact us at support@chefmate.com','2025-09-06 07:35:14','2025-09-06 07:35:14',1,1,1);
/*!40000 ALTER TABLE `company_profile` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`pindbulluchi_db`@`localhost`*/ /*!50003 TRIGGER `company_profile_before_update`
BEFORE UPDATE ON `company_profile`
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `company_profile_basic`
--

DROP TABLE IF EXISTS `company_profile_basic`;
/*!50001 DROP VIEW IF EXISTS `company_profile_basic`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `company_profile_basic` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `tax_id`,
  1 AS `phone_number`,
  1 AS `email`,
  1 AS `address`,
  1 AS `website`,
  1 AS `city`,
  1 AS `state`,
  1 AS `zip_code`,
  1 AS `country`,
  1 AS `bank_name`,
  1 AS `account_number`,
  1 AS `account_name`,
  1 AS `payment_methods`,
  1 AS `is_active`,
  1 AS `created_at`,
  1 AS `updated_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `company_profile_display`
--

DROP TABLE IF EXISTS `company_profile_display`;
/*!50001 DROP VIEW IF EXISTS `company_profile_display`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `company_profile_display` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `tax_id`,
  1 AS `phone_number`,
  1 AS `email`,
  1 AS `address`,
  1 AS `city`,
  1 AS `state`,
  1 AS `zip_code`,
  1 AS `country`,
  1 AS `has_logo`,
  1 AS `has_qr_code`,
  1 AS `terms_and_conditions`,
  1 AS `payment_methods` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `companyinfo`
--

DROP TABLE IF EXISTS `companyinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `companyinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `tax_id` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(233) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companyinfo`
--

LOCK TABLES `companyinfo` WRITE;
/*!40000 ALTER TABLE `companyinfo` DISABLE KEYS */;
INSERT INTO `companyinfo` VALUES
(6,'Restaurant Name','02CMRPK1281N1ZP','+66-986643299','restaurantname@gmail.com','554/28, Chaiyavidhi 1/1 ,Pattaya-20150','2025-01-29 10:02:36');
/*!40000 ALTER TABLE `companyinfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coresetting`
--

DROP TABLE IF EXISTS `coresetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coresetting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(233) NOT NULL,
  `tax_type` varchar(50) NOT NULL,
  `region` varchar(33) NOT NULL,
  `currency` varchar(50) NOT NULL,
  `type` varchar(33) NOT NULL,
  `valid_till` date NOT NULL,
  `status` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coresetting`
--

LOCK TABLES `coresetting` WRITE;
/*!40000 ALTER TABLE `coresetting` DISABLE KEYS */;
INSERT INTO `coresetting` VALUES
(11,'Vix','VAT','TH','THB','Basic','2026-06-14','active');
/*!40000 ALTER TABLE `coresetting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `contact` bigint(20) NOT NULL,
  `email` varchar(233) NOT NULL,
  `taxid` varchar(233) DEFAULT NULL,
  `address` varchar(233) DEFAULT NULL,
  `createdon` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
(1,'Vicky Thakur',986643299,'cloud@gmail.com',NULL,NULL,'0000-00-00 00:00:00'),
(2,'Jakjaan',7832807218,'vix@gmail.com',NULL,NULL,'0000-00-00 00:00:00'),
(3,'Vinod Kumar',992799977,'Gigi@gmail.com',NULL,NULL,'0000-00-00 00:00:00'),
(4,'Gigu',0,'',NULL,NULL,'2025-05-01 09:32:03'),
(5,'Sopit',0,'',NULL,NULL,'2025-05-26 07:25:24'),
(6,'Jack',0,'',NULL,NULL,'2025-05-26 07:25:29'),
(7,'Hollywood',0,'',NULL,NULL,'2025-05-26 07:25:34'),
(8,'Jannaat',0,'',NULL,NULL,'2025-05-26 07:25:40'),
(9,'Gigu',992799977,'Gigu@gmail.com','','Pattaya','2025-06-02 06:04:51'),
(10,'Sopit',0,'','020525gffff5','NCP','2025-06-02 06:05:14'),
(11,'Jannaat',2569369,'ahsk@gmail.com','0258669931599','Pattaya','2025-06-02 06:06:23'),
(12,'Hollywood',9866435268,'hollywood@gmail.com','0239523685','Pattaya','2025-06-02 06:07:59'),
(13,'gfdg',656546,'axialtour@gmail.com','gfdgfdgdf','vill tikkar rajputan po bumbloo','2025-06-21 06:02:45'),
(14,'Veena',987832807218,'kumar@gmail.com','02cmrplkvjvj','vill tikkar rajputan po bumbloo','2025-07-09 06:03:31');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `day_close_summary`
--

DROP TABLE IF EXISTS `day_close_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `day_close_summary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `close_date` date NOT NULL,
  `total_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cash_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `upi_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `card_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `qr_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `bank_transfer_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `online_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `other_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_items_sold` int(11) NOT NULL DEFAULT 0,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_sales` decimal(12,2) NOT NULL DEFAULT 0.00,
  `opened_by` varchar(100) DEFAULT NULL,
  `closed_by` varchar(100) DEFAULT NULL,
  `opening_time` timestamp NULL DEFAULT NULL,
  `closing_time` timestamp NULL DEFAULT current_timestamp(),
  `status` enum('open','closed') DEFAULT 'open',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `close_date` (`close_date`),
  KEY `idx_close_date` (`close_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `day_close_summary`
--

LOCK TABLES `day_close_summary` WRITE;
/*!40000 ALTER TABLE `day_close_summary` DISABLE KEYS */;
INSERT INTO `day_close_summary` VALUES
(1,'2025-08-28',19081.30,19081.30,0.00,0.00,0.00,0.00,0.00,0.00,229,704,0.00,0.00,19081.30,NULL,'3130',NULL,'2025-08-28 03:59:07','closed','','2025-08-28 10:59:08','2025-08-28 10:59:08'),
(4,'2025-08-29',1838.00,1330.00,0.00,115.00,0.00,393.00,0.00,0.00,6,11,0.00,0.00,1838.00,NULL,'3130',NULL,'2025-08-29 03:15:09','closed','','2025-08-29 10:15:10','2025-08-29 10:15:10'),
(5,'2025-08-30',5701.00,5701.00,0.00,0.00,0.00,0.00,0.00,0.00,9,24,0.00,0.00,5701.00,NULL,'3130',NULL,'2025-09-06 00:38:36','closed','','2025-09-06 07:38:39','2025-09-06 07:38:39'),
(6,'2025-08-31',920.00,920.00,0.00,0.00,0.00,0.00,0.00,0.00,1,3,0.00,0.00,920.00,NULL,'3130',NULL,'2025-09-06 00:41:39','closed','','2025-09-06 07:41:41','2025-09-06 07:41:41'),
(7,'2025-09-01',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,0,0.00,0.00,0.00,NULL,'3130',NULL,'2025-09-06 00:41:50','closed','','2025-09-06 07:41:53','2025-09-06 07:41:53'),
(8,'2025-09-02',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,0,0.00,0.00,0.00,NULL,'3130',NULL,'2025-09-06 00:42:00','closed','','2025-09-06 07:42:02','2025-09-06 07:42:02'),
(9,'2025-09-03',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,0,0.00,0.00,0.00,NULL,'3130',NULL,'2025-09-06 00:42:08','closed','','2025-09-06 07:42:10','2025-09-06 07:42:10'),
(10,'2025-09-04',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,0,0.00,0.00,0.00,NULL,'3130',NULL,'2025-09-06 00:42:17','closed','','2025-09-06 07:42:19','2025-09-06 07:42:19'),
(11,'2025-09-05',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,0,0.00,0.00,0.00,NULL,'3130',NULL,'2025-09-06 00:42:25','closed','','2025-09-06 07:42:27','2025-09-06 07:42:27'),
(12,'2025-09-06',4895.00,4895.00,0.00,0.00,0.00,0.00,0.00,0.00,6,16,0.00,0.00,4895.00,NULL,'3130',NULL,'2025-09-06 01:58:26','closed','','2025-09-06 08:58:28','2025-09-06 08:58:28');
/*!40000 ALTER TABLE `day_close_summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feature_usage`
--

DROP TABLE IF EXISTS `feature_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_usage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `feature_code` varchar(50) NOT NULL,
  `current_usage` int(11) DEFAULT 0,
  `last_reset_at` timestamp NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_feature` (`user_id`,`feature_code`),
  KEY `idx_user_feature` (`user_id`,`feature_code`),
  CONSTRAINT `feature_usage_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feature_usage`
--

LOCK TABLES `feature_usage` WRITE;
/*!40000 ALTER TABLE `feature_usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `feature_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_code` varchar(50) NOT NULL,
  `feature_name` varchar(100) NOT NULL,
  `feature_category` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `feature_code` (`feature_code`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features`
--

LOCK TABLES `features` WRITE;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` VALUES
(1,'customers','Customer Management','master','Manage customer information and history',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(2,'suppliers','Supplier Management','master','Track supplier information and orders',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(3,'tables','Table Management','master','Manage restaurant tables and seating',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(4,'categories','Category Management','master','Organize menu items by categories',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(5,'paymentOptions','Payment Options','master','Configure payment methods',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(6,'items','Item Management','inventory','Manage menu items and inventory',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(7,'stockManagement','Stock Management','inventory','Track inventory levels and stock',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(8,'productManagement','Product Management','inventory','Manage product variants and combinations',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(9,'stockReports','Stock Reports','inventory','Generate inventory and stock reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(10,'pos','POS System','sales','Point of sale system for taking orders',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(11,'advanceOrders','Advance Orders','sales','Take advance orders from customers',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(12,'retailSales','Retail Sales','sales','Direct retail sales management',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(13,'vouchers','Voucher System','financial','Issue and manage vouchers',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(14,'expenses','Expense Tracking','financial','Track business expenses',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(15,'salesReports','Sales Reports','reporting','Generate sales reports and analytics',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(16,'itemWiseReports','Item-wise Reports','reporting','Detailed item sales reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(17,'customerReports','Customer Reports','reporting','Customer analytics and reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(18,'supplierReports','Supplier Reports','reporting','Supplier performance reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(19,'advanceOrderReports','Advance Order Reports','reporting','Advance order tracking reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(20,'lowStockReports','Low Stock Reports','reporting','Low stock alerts and reports',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(21,'users','User Management','system','Manage system users and permissions',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(22,'profileManagement','Profile Management','system','User profile management',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(23,'coreSettings','Core Settings','system','System configuration settings',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(24,'companyInfo','Company Information','system','Company profile and branding',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(25,'taxManagement','Tax Management','system','Tax rates and tax management',1,'2025-07-16 08:02:11','2025-07-16 08:02:11'),
(26,'unitsManagement','Units Management','system','Product units and measurements',1,'2025-07-16 08:02:11','2025-07-16 08:02:11');
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `final_bill`
--

DROP TABLE IF EXISTS `final_bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `final_bill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `inv_date` date NOT NULL,
  `inv_time` time(6) NOT NULL,
  `table_number` varchar(50) DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL,
  `discount_type` varchar(10) NOT NULL DEFAULT '0',
  `discount_value` float NOT NULL,
  `discount_amount` float NOT NULL,
  `subtotal_afterdiscount` float NOT NULL DEFAULT 0,
  `tax` decimal(15,2) NOT NULL,
  `roundoff` float NOT NULL DEFAULT 0,
  `grand_total` decimal(15,2) NOT NULL,
  `payment_mode` enum('Cash','Credit','Bank Transfer','QR Scan','Split','Card') NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `setup_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `final_bill_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `final_bill`
--

LOCK TABLES `final_bill` WRITE;
/*!40000 ALTER TABLE `final_bill` DISABLE KEYS */;
INSERT INTO `final_bill` VALUES
(1,2,'2025-02-11','17:57:08.000000','Table 6',840.00,'percentage',0,0,840,58.80,0.2,898.80,'Credit',0,898.80,'0000-00-00'),
(2,NULL,'2025-02-12','15:05:57.000000','Table 2',660.00,'percentage',396,0,600,42.00,0,642.00,'Cash',2,0.00,'0000-00-00'),
(3,1,'2025-02-12','15:06:27.000000','Table 4',780.00,'percentage',624,0,700,49.00,0,749.00,'Credit',0,749.00,'0000-00-00'),
(4,2,'2025-02-12','15:45:48.000000','Table 3',790.00,'amount',0,0,790,55.30,-0.3,845.30,'Credit',0,701.20,'0000-00-00'),
(5,NULL,'2025-02-20','14:11:30.000000','Table 7',660.00,'amount',6,0,654,45.78,0.22,699.78,'Cash',0,0.00,'0000-00-00'),
(6,NULL,'2025-02-20','14:22:29.000000','Table 6',400.00,'percentage',40,0,390,27.30,-0.3,417.30,'Cash',2,0.00,'0000-00-00'),
(7,NULL,'2025-02-20','15:57:38.000000','Table 4',540.00,'percentage',0,0,486,34.02,-0.02,520.02,'Cash',2,0.00,'0000-00-00'),
(8,NULL,'2025-02-20','15:59:32.000000','Table 3',650.00,'percentage',0,0,585,40.95,0.05,625.95,'Cash',0,0.00,'0000-00-00'),
(9,NULL,'2025-02-20','15:59:50.000000','Table 3',650.00,'percentage',0,0,585,40.95,0.05,625.95,'Cash',2,0.00,'0000-00-00'),
(10,NULL,'2025-02-20','16:00:01.000000','Table 6',660.00,'percentage',0,0,594,41.58,0.42,635.58,'Cash',0,0.00,'0000-00-00'),
(11,NULL,'2025-02-20','16:05:12.000000','Table 1',360.00,'percentage',0,0,324,22.68,0.32,346.68,'Cash',2,0.00,'0000-00-00'),
(12,NULL,'2025-02-20','16:54:45.000000','Table 6',720.00,'percentage',10,0,648,45.36,-0.36,693.36,'Cash',0,0.00,'0000-00-00'),
(13,NULL,'2025-02-20','17:16:46.000000','Table 4',1080.00,'percentage',10,0,972,68.04,-0.04,1040.04,'Cash',0,0.00,'0000-00-00'),
(14,NULL,'2025-02-20','17:19:24.000000','Table 3',360.00,'percentage',10,0,324,22.68,0.32,346.68,'Cash',0,0.00,'0000-00-00'),
(15,NULL,'2025-02-20','17:23:16.000000','Table 1',500.00,'percentage',10,0,450,31.50,0.5,481.50,'Cash',0,0.00,'0000-00-00'),
(16,NULL,'2025-02-20','17:26:08.000000','Table 6',470.00,'percentage',15,0,399.5,27.97,-0.47,427.47,'Cash',0,0.00,'0000-00-00'),
(17,NULL,'2025-02-20','17:52:14.000000','Table 3',430.00,'percentage',10,0,387,27.09,-0.09,414.09,'Cash',0,0.00,'0000-00-00'),
(18,NULL,'2025-02-24','14:15:17.000000','Table 2',720.00,'amount',20,0,700,49.00,0,749.00,'Cash',0,0.00,'0000-00-00'),
(19,NULL,'2025-02-24','14:17:53.000000','Table 4',480.00,'amount',20,20,460,32.20,-0.2,492.20,'Cash',0,0.00,'0000-00-00'),
(20,NULL,'2025-02-24','14:18:28.000000','Table 1',800.00,'percentage',10,80,720,50.40,-0.4,770.40,'Cash',0,0.00,'0000-00-00'),
(21,NULL,'2025-02-24','14:27:32.000000','Table 4',660.00,'amount',60,60,600,42.00,0,642.00,'Cash',0,0.00,'0000-00-00'),
(22,NULL,'2025-02-24','14:34:04.000000','Table 3',1080.00,'amount',80,80,1000,70.00,0,1070.00,'Cash',2,0.00,'0000-00-00'),
(23,NULL,'2025-02-24','14:34:43.000000','Table 6',220.00,'amount',20,20,200,14.00,0,214.00,'Cash',0,0.00,'0000-00-00'),
(24,NULL,'2025-02-24','14:37:32.000000','Table 2',480.00,'amount',180,180,300,21.00,0,321.00,'Cash',0,0.00,'0000-00-00'),
(25,NULL,'2025-02-24','14:40:28.000000','Table 9',840.00,'amount',40,40,800,56.00,0,856.00,'Cash',0,0.00,'0000-00-00'),
(26,NULL,'2025-02-24','15:06:21.000000','Table 4',690.00,'amount',90,90,600,42.00,0,642.00,'Cash',0,0.00,'0000-00-00'),
(27,NULL,'2025-02-24','15:08:47.000000','Table 7',430.00,'amount',60,60,370,25.90,0.1,395.90,'Cash',0,0.00,'0000-00-00'),
(28,NULL,'2025-02-24','15:10:04.000000','Table 1',610.00,'amount',50,50,560,39.20,-0.2,599.20,'Cash',0,0.00,'0000-00-00'),
(29,NULL,'2025-02-24','15:35:51.000000','Table 9',1310.00,'amount',50,50,1260,88.20,-0.2,1348.20,'Cash',0,0.00,'0000-00-00'),
(30,NULL,'2025-02-24','16:29:50.000000','Table 6',650.00,'percentage',10,65,585,40.95,0.05,625.95,'Cash',0,0.00,'0000-00-00'),
(31,NULL,'2025-02-24','16:30:06.000000','Table 4',540.00,'percentage',10,54,486,34.02,-0.02,520.02,'Cash',0,0.00,'0000-00-00'),
(32,NULL,'2025-02-24','16:31:53.000000','Table 2',650.00,'percentage',5,32.5,617.5,45.50,0.27,6630.27,'Cash',0,0.00,'0000-00-00'),
(33,NULL,'2025-02-24','16:36:50.000000','Table 3',660.00,'percentage',50,330,330,23.10,-0.1,353.10,'Cash',0,0.00,'0000-00-00'),
(34,NULL,'2025-02-24','16:51:30.000000','Table 2',220.00,'percentage',20,44,176,12.32,-0.32,188.32,'Cash',0,0.00,'0000-00-00'),
(35,NULL,'2025-02-24','16:56:03.000000','Table 6',830.00,'percentage',0,0,830,58.10,-0.1,888.10,'Cash',0,0.00,'0000-00-00'),
(36,NULL,'2025-02-24','16:57:14.000000','Table 2',760.00,'percentage',10,76,684,47.88,0.12,731.88,'Cash',0,0.00,'0000-00-00'),
(37,NULL,'2025-02-24','17:02:47.000000','Table 4',540.00,'percentage',0,0,540,37.80,0.2,577.80,'Cash',0,0.00,'0000-00-00'),
(38,NULL,'2025-02-24','17:04:11.000000','Table 3',720.00,'percentage',0,0,720,50.40,-0.4,770.40,'Cash',0,0.00,'0000-00-00'),
(39,NULL,'2025-02-24','17:05:29.000000','Table 2',750.00,'percentage',0,0,750,52.50,0.5,802.50,'Cash',0,0.00,'0000-00-00'),
(40,NULL,'2025-02-24','17:20:01.000000','Table 3',610.00,'percentage',0,0,610,42.70,0.3,652.70,'Cash',0,0.00,'0000-00-00'),
(41,NULL,'2025-02-24','17:20:42.000000','Table 7',660.00,'percentage',20,132,528,36.96,0.04,564.96,'Cash',0,0.00,'0000-00-00'),
(42,NULL,'2025-02-24','18:48:35.000000','Table 5',2135.00,'percentage',0,0,2135,149.45,-0.45,2284.45,'Cash',0,0.00,'0000-00-00'),
(43,NULL,'2025-02-24','18:52:53.000000','Table 6',2200.00,'percentage',10,220,1980,138.60,0.4,2119.00,'Cash',0,0.00,'0000-00-00'),
(44,1,'2025-02-25','15:48:44.000000','Table 5',295.00,'percentage',10,29.5,265.5,18.59,-0.08,284.00,'Credit',0,284.00,'0000-00-00'),
(45,1,'2025-03-13','19:08:27.000000','Table 5',1640.00,'amount',50,50,1590,111.30,-0.3,1701.00,'Credit',0,967.00,'0000-00-00'),
(46,1,'2025-03-13','19:08:31.000000','Table 5',1640.00,'amount',50,50,1590,111.30,-0.3,1701.00,'Credit',0,1701.00,'0000-00-00'),
(47,NULL,'2025-03-13','19:12:40.000000','Table 9',1060.00,'amount',60,60,1000,70.00,0,1070.00,'Cash',0,0.00,'0000-00-00'),
(48,2,'2025-03-15','17:07:53.000000','Table 7',1080.00,'amount',0,0,1080,75.60,0.4,1156.00,'Credit',0,1156.00,'0000-00-00'),
(49,2,'2025-03-15','17:07:59.000000','Table 7',1080.00,'amount',0,0,1080,75.60,0.4,1156.00,'Credit',0,1144.30,'0000-00-00'),
(50,NULL,'2025-03-15','17:29:49.000000','Table 5',345.00,'percentage',0,0,345,24.15,-0.15,369.00,'Cash',0,0.00,'0000-00-00'),
(51,1,'2025-03-15','18:05:07.000000','Table 6',485.00,'amount',0,0,485,33.95,0.05,519.00,'Credit',0,519.00,'0000-00-00'),
(52,NULL,'2025-03-15','18:05:29.000000','Table 7',1130.00,'amount',0,0,1130,79.10,-0.1,1209.00,'',0,0.00,'0000-00-00'),
(53,NULL,'2025-03-15','18:09:36.000000','Table 2',395.00,'amount',50,50,345,24.15,-0.15,369.00,'Cash',0,0.00,'0000-00-00'),
(54,NULL,'2025-03-15','18:09:53.000000','Table 10',1990.00,'amount',100,100,1890,132.30,-0.3,2022.00,'Cash',2,0.00,'0000-00-00'),
(55,1,'2025-05-01','16:33:37.000000','Table 10',880.00,'percentage',0,0,880,61.60,0.4,942.00,'Credit',0,942.00,'0000-00-00'),
(56,1,'2025-05-01','16:33:40.000000','Table 10',880.00,'percentage',0,0,880,61.60,0.4,942.00,'Credit',0,942.00,'0000-00-00'),
(57,NULL,'2025-05-01','16:34:01.000000','Table 4',345.00,'percentage',0,0,345,24.15,-0.15,369.00,'',0,0.00,'0000-00-00'),
(58,1,'2025-05-26','14:31:13.000000','Table 5',630.00,'amount',0,0,630,44.10,-0.1,674.00,'Credit',0,674.00,'0000-00-00'),
(59,1,'2025-05-26','14:31:36.000000','Table 6',670.00,'amount',0,0,670,46.90,0.1,717.00,'Credit',0,717.00,'0000-00-00'),
(60,1,'2025-05-26','14:32:32.000000','Table 6',555.00,'percentage',0,0,555,38.85,0.15,594.00,'Credit',0,594.00,'0000-00-00'),
(61,1,'2025-05-26','14:42:03.000000','Table 9',330.00,'percentage',0,0,330,23.10,-0.1,353.00,'Credit',0,15.00,'0000-00-00'),
(62,1,'2025-05-26','14:43:29.000000','Table 3',145.00,'percentage',0,0,145,10.15,-0.15,155.00,'Credit',0,155.00,'0000-00-00'),
(63,NULL,'2025-05-26','14:46:16.000000','Table 9',200.00,'percentage',0,0,200,14.00,0,214.00,'Cash',0,0.00,'0000-00-00'),
(64,NULL,'2025-05-26','14:57:43.000000','Table 10',310.00,'percentage',0,0,310,21.70,0.3,332.00,'Cash',0,0.00,'0000-00-00'),
(65,NULL,'2025-05-26','14:59:14.000000','Table 9',530.00,'percentage',0,0,530,37.10,-0.1,567.00,'Cash',0,0.00,'0000-00-00'),
(66,NULL,'2025-05-26','15:01:43.000000','Table 5',50.00,'percentage',0,0,50,3.50,0.5,54.00,'Cash',0,0.00,'0000-00-00'),
(67,NULL,'2025-05-26','15:08:03.000000','Table 6',580.00,'percentage',0,0,580,40.60,0.4,621.00,'Cash',0,0.00,'0000-00-00'),
(68,NULL,'2025-05-26','15:10:10.000000','Table 10',50.00,'percentage',0,0,50,3.50,0.5,54.00,'Cash',0,0.00,'0000-00-00'),
(69,NULL,'2025-05-26','15:10:57.000000','Table 5',500.00,'percentage',0,0,500,35.00,0,535.00,'Cash',0,0.00,'0000-00-00'),
(70,NULL,'2025-05-26','18:11:40.000000','Table 6',145.00,'percentage',0,0,145,10.15,-0.15,155.00,'Cash',0,0.00,'0000-00-00'),
(71,NULL,'2025-05-26','18:14:23.000000','Table 5',230.00,'percentage',0,0,230,16.10,-0.1,246.00,'Cash',0,0.00,'0000-00-00'),
(72,NULL,'2025-05-26','18:24:26.000000','Table 1',500.00,'percentage',0,0,500,35.00,0,535.00,'Cash',0,0.00,'0000-00-00'),
(73,NULL,'2025-05-26','18:27:02.000000','Table 7',240.00,'percentage',0,0,240,16.80,0.2,257.00,'Cash',0,0.00,'0000-00-00'),
(74,NULL,'2025-05-26','18:27:56.000000','Table 4',230.00,'percentage',0,0,230,16.10,-0.1,246.00,'Cash',0,0.00,'0000-00-00'),
(75,NULL,'2025-05-26','18:33:49.000000','Table 3',240.00,'percentage',0,0,240,16.80,0.2,257.00,'Cash',0,0.00,'0000-00-00'),
(76,1,'2025-05-27','15:42:49.000000','Table 1',230.00,'percentage',0,0,230,16.10,-0.1,246.00,'Credit',0,246.00,'0000-00-00'),
(77,1,'2025-05-27','16:21:58.000000','Table 3',340.00,'percentage',0,0,340,23.80,0.2,364.00,'Credit',0,364.00,'0000-00-00'),
(78,NULL,'2025-05-27','16:22:33.000000','Table 5',570.00,'amount',10,10,560,39.20,-0.2,599.00,'',0,0.00,'0000-00-00'),
(79,NULL,'2025-05-28','15:37:25.000000','Table 3',360.00,'percentage',0,0,360,25.20,-0.2,385.00,'Cash',0,0.00,'0000-00-00'),
(80,NULL,'2025-06-03','14:45:06.000000','Table 5',405.00,'percentage',0,0,405,28.35,-0.35,433.00,'Cash',0,0.00,'0000-00-00'),
(81,NULL,'2025-06-03','14:45:47.000000','Table 10',325.00,'percentage',0,0,325,22.75,0.25,348.00,'Cash',0,0.00,'0000-00-00'),
(82,NULL,'2025-06-03','14:46:12.000000','Table 1',345.00,'percentage',0,0,345,24.15,-0.15,369.00,'Cash',0,0.00,'0000-00-00'),
(83,NULL,'2025-06-03','17:13:01.000000','Table 4',340.00,'amount',64,64,276,19.32,-0.32,295.00,'Cash',0,0.00,'0000-00-00'),
(84,NULL,'2025-06-03','17:13:40.000000','Table 9',275.00,'amount',0,0,275,19.25,-0.25,294.00,'Cash',0,0.00,'0000-00-00'),
(85,1,'2025-06-03','17:32:43.000000','Table 3',460.00,'percentage',0,0,460,32.20,-0.2,492.00,'Credit',0,492.00,'0000-00-00'),
(86,NULL,'2025-06-03','17:41:54.000000','Table 5',110.00,'percentage',0,0,110,7.70,0.3,118.00,'Cash',0,0.00,'0000-00-00'),
(87,NULL,'2025-06-03','17:50:01.000000','Table 1',635.00,'percentage',0,0,635,44.45,-0.45,679.00,'Cash',0,0.00,'0000-00-00'),
(88,NULL,'2025-06-03','17:50:12.000000','Table 1',635.00,'percentage',0,0,635,44.45,-0.45,679.00,'Cash',0,0.00,'0000-00-00'),
(89,NULL,'2025-06-03','17:53:41.000000','Table 3',665.00,'percentage',0,0,665,46.55,0.45,712.00,'Cash',0,0.00,'0000-00-00'),
(90,NULL,'2025-06-03','17:54:54.000000','Table 5',530.00,'percentage',0,0,530,37.10,-0.1,567.00,'Cash',0,0.00,'0000-00-00'),
(91,NULL,'2025-06-03','17:56:35.000000','Table 4',365.00,'percentage',0,0,365,25.55,0.45,391.00,'Cash',0,0.00,'0000-00-00'),
(92,NULL,'2025-06-03','17:57:50.000000','Table 4',320.00,'percentage',0,0,320,22.40,-0.4,342.00,'Cash',0,0.00,'0000-00-00'),
(93,NULL,'2025-06-03','18:01:21.000000','Table 4',320.00,'percentage',0,0,320,22.40,-0.4,342.00,'Cash',0,0.00,'0000-00-00'),
(94,NULL,'2025-06-03','18:01:44.000000','Table 4',320.00,'percentage',0,0,320,22.40,-0.4,342.00,'Cash',0,0.00,'0000-00-00'),
(95,NULL,'2025-06-03','18:02:12.000000','Table 4',320.00,'percentage',0,0,320,22.40,-0.4,342.00,'Cash',0,0.00,'0000-00-00'),
(96,NULL,'2025-06-03','18:06:16.000000','Table 10',1100.00,'percentage',0,0,1100,77.00,0,1177.00,'Cash',0,0.00,'0000-00-00'),
(97,NULL,'2025-06-04','16:11:18.000000','Table 4',1100.00,'percentage',0,0,1100,77.00,0,1177.00,'Cash',0,0.00,'0000-00-00'),
(98,NULL,'2025-06-05','14:57:37.000000','Table 5',1100.00,'percentage',0,0,1100,77.00,0,1177.00,'Cash',0,0.00,'0000-00-00'),
(99,1,'2025-06-05','15:29:12.000000','Table 9',340.00,'percentage',0,0,340,23.80,0.2,364.00,'Credit',0,200.00,'0000-00-00'),
(100,1,'2025-06-07','17:22:56.000000','Take Away',345.00,'percentage',0,0,345,24.15,-0.15,369.00,'Credit',0,300.00,'0000-00-00'),
(101,1,'2025-06-10','14:00:14.000000','Table 7',365.00,'percentage',0,0,365,25.55,0.45,391.00,'Credit',0,391.00,'0000-00-00'),
(102,1,'2025-06-10','14:05:25.000000','Table 9',1525.00,'percentage',0,0,1525,106.75,0.25,1632.00,'Credit',0,609.00,'0000-00-00'),
(103,NULL,'2025-06-11','13:44:08.000000','Table 7',90.00,'percentage',0,0,90,6.30,-0.3,96.00,'Cash',0,0.00,'0000-00-00'),
(104,NULL,'2025-06-11','16:42:15.000000','Table 3',250.00,'percentage',50,125,125,11.36,0,125.00,'Cash',0,0.00,'0000-00-00'),
(105,NULL,'2025-06-12','13:59:44.000000','Table 10',90.00,'amount',20,20,70,0.00,0,70.00,'Cash',0,0.00,'0000-00-00'),
(106,NULL,'2025-06-12','15:36:03.000000','Table 3',90.00,'percentage',0,0,90,0.00,0,90.00,'Cash',0,0.00,'0000-00-00'),
(107,NULL,'2025-06-12','15:36:07.000000','Table 1',705.00,'percentage',0,0,705,0.00,0,705.00,'Cash',0,0.00,'0000-00-00'),
(108,NULL,'2025-06-12','17:49:10.000000','Table 10',1380.00,'percentage',0,0,1380,0.00,0,1380.00,'Cash',0,0.00,'0000-00-00'),
(109,NULL,'2025-06-13','17:52:22.000000','Table 4',915.00,'percentage',0,0,915,98.04,0,915.00,'Cash',0,0.00,'0000-00-00'),
(110,NULL,'2025-06-13','17:56:59.000000','Table 2',580.00,'percentage',0,0,580,62.14,0,580.00,'Cash',0,0.00,'0000-00-00'),
(111,1,'2025-06-17','13:46:37.000000','Table 1',530.00,'percentage',0,0,530,0.00,0,530.00,'Credit',0,530.00,'0000-00-00'),
(112,1,'2025-06-17','13:46:41.000000','Table 9',1100.00,'percentage',0,0,1100,0.00,0,1100.00,'Credit',0,70.00,'0000-00-00'),
(113,1,'2025-06-17','14:19:27.000000','Table 10',755.00,'percentage',0,0,755,80.89,0,755.00,'Credit',0,755.00,'0000-00-00'),
(114,NULL,'2025-06-18','12:42:37.000000','Table 2',1225.00,'percentage',0,0,1225,0.00,0,1225.00,'Cash',0,0.00,'0000-00-00'),
(115,NULL,'2025-06-21','15:00:33.000000','Table 3',50.00,'percentage',0,0,180,0.00,0,180.00,'Cash',0,0.00,'0000-00-00'),
(116,NULL,'2025-06-21','15:01:39.000000','Table 2',250.00,'percentage',10,0,2214,0.00,0,2214.00,'Cash',0,0.00,'0000-00-00'),
(117,NULL,'2025-06-21','16:00:32.000000','Table 3',320.00,'amount',15,15,700,0.00,0,700.00,'Cash',0,0.00,'0000-00-00'),
(118,NULL,'2025-06-21','16:01:20.000000','Table 9',25.00,'amount',500,500,2395,0.00,0,2395.00,'Cash',0,0.00,'0000-00-00'),
(119,NULL,'2025-06-21','17:14:27.000000','Table 6',40.00,'percentage',0,0,525,0.00,0,525.00,'Cash',0,0.00,'0000-00-00'),
(120,1,'2025-06-23','13:05:17.000000','Table 5',300.01,'percentage',0,0,6160,0.00,0,6160.00,'Credit',0,2000.00,'0000-00-00'),
(121,1,'2025-06-23','22:40:35.000000','Table 7',80.00,'percentage',0,0,665,0.00,0,665.00,'Credit',0,665.00,'0000-00-00'),
(122,NULL,'2025-06-24','18:47:04.000000','Table 9',25.00,'percentage',0,0,325,0.00,0,325.00,'Cash',0,0.00,'0000-00-00'),
(123,1,'2025-06-26','13:14:47.000000','Table 5',40.00,'amount',20,20,550,0.00,0,550.00,'Credit',1,0.00,'0000-00-00'),
(124,5,'2025-07-08','15:18:16.000000','hgfh',590.00,'percentage',0,0,590,0.00,0,590.00,'Cash',0,0.00,'0000-00-00'),
(125,7,'2025-07-08','15:20:16.000000','',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(126,7,'2025-07-08','15:25:37.000000','',80.00,'percentage',0,0,80,0.00,0,80.00,'Cash',0,0.00,'0000-00-00'),
(127,7,'2025-07-08','15:28:07.000000','',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(128,7,'2025-07-08','15:29:06.000000','',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(129,7,'2025-07-08','15:31:00.000000','',50.00,'percentage',0,0,50,0.00,0,50.00,'Cash',0,0.00,'0000-00-00'),
(130,5,'2025-07-08','15:38:20.000000','',150.00,'percentage',0,0,150,0.00,0,150.00,'Cash',0,0.00,'0000-00-00'),
(131,4,'2025-07-08','15:40:42.000000','',280.00,'percentage',0,0,280,0.00,0,280.00,'Cash',0,0.00,'0000-00-00'),
(132,4,'2025-07-08','15:43:19.000000','',570.00,'percentage',0,0,570,0.00,0,570.00,'Cash',0,0.00,'0000-00-00'),
(133,4,'2025-07-08','16:23:27.000000','',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(134,4,'2025-07-08','16:25:25.000000','',80.00,'percentage',0,0,80,0.00,0,80.00,'Cash',0,0.00,'0000-00-00'),
(135,6,'2025-07-08','17:04:22.000000','',170.00,'percentage',0,0,170,0.00,0,170.00,'Cash',0,0.00,'0000-00-00'),
(136,2,'2025-07-08','22:25:10.000000','',250.00,'percentage',0,0,250,0.00,0,250.00,'Cash',0,0.00,'0000-00-00'),
(137,3,'2025-07-08','22:44:03.000000','fdsfsdf',380.00,'percentage',0,0,380,0.00,0,380.00,'Cash',0,0.00,'0000-00-00'),
(138,3,'2025-07-08','22:45:29.000000','fdsfsdf',380.00,'percentage',0,0,380,0.00,0,380.00,'Cash',0,0.00,'0000-00-00'),
(139,5,'2025-07-08','22:50:05.000000','dasd',250.00,'percentage',0,0,250,0.00,0,250.00,'Cash',0,0.00,'0000-00-00'),
(140,4,'2025-07-08','22:58:40.000000','yrtfyrtyrt',410.00,'percentage',0,0,410,0.00,0,410.00,'Cash',0,0.00,'0000-00-00'),
(141,3,'2025-07-08','23:01:56.000000','',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(142,3,'2025-07-08','23:03:24.000000','dasd',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(143,3,'2025-07-08','23:03:37.000000','dasd',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(144,3,'2025-07-08','23:04:40.000000','dasd',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(145,3,'2025-07-08','23:05:30.000000','dasd',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(146,3,'2025-07-08','23:06:37.000000','dasd',120.00,'percentage',0,0,120,0.00,0,120.00,'Cash',0,0.00,'0000-00-00'),
(147,3,'2025-07-08','23:08:50.000000','dasd',200.00,'percentage',0,0,200,5.60,0.4,206.00,'Cash',0,0.00,'0000-00-00'),
(148,3,'2025-07-08','23:12:23.000000','',520.00,'percentage',0,0,520,0.00,0,520.00,'Cash',0,0.00,'0000-00-00'),
(149,5,'2025-07-08','23:17:40.000000','',65.00,'percentage',0,0,65,0.00,0,65.00,'Cash',0,0.00,'0000-00-00'),
(150,4,'2025-07-08','23:20:54.000000','',25.00,'percentage',0,0,25,0.00,0,25.00,'Cash',0,0.00,'0000-00-00'),
(151,4,'2025-07-08','23:21:17.000000','ffsd',305.00,'percentage',0,0,305,0.00,0,305.00,'Cash',0,0.00,'0000-00-00'),
(152,6,'2025-07-08','23:54:54.000000','',800.00,'percentage',0,0,800,56.00,0,856.00,'Cash',0,0.00,'0000-00-00'),
(153,3,'2025-07-09','10:23:14.000000','',1580.00,'percentage',0,0,1580,36.40,-0.4,1616.00,'Cash',0,0.00,'0000-00-00'),
(154,2,'2025-07-09','10:26:30.000000','',1280.00,'percentage',0,0,1280,0.00,0,1280.00,'Cash',0,0.00,'0000-00-00'),
(155,14,'2025-07-09','13:06:46.000000','ggdfgdfg',2000.00,'percentage',0,0,2000,0.00,0,2000.00,'Credit',0,0.00,'0000-00-00'),
(156,14,'2025-07-09','13:10:21.000000','',1800.00,'percentage',0,0,1800,0.00,0,1800.00,'Cash',0,0.00,'0000-00-00'),
(157,14,'2025-07-09','13:10:35.000000','',520.00,'percentage',0,0,520,0.00,0,520.00,'Credit',0,0.00,'0000-00-00'),
(158,14,'2025-07-09','13:15:18.000000','',580.00,'percentage',0,0,580,0.00,0,580.00,'Credit',0,300.00,'0000-00-00'),
(159,3,'2025-07-09','13:22:40.000000','',1680.00,'percentage',0,0,1680,0.00,0,1680.00,'Cash',2,0.00,'0000-00-00'),
(160,14,'2025-07-09','13:38:43.000000','',1020.00,'percentage',0,0,1020,71.40,-0.4,1091.00,'Cash',0,0.00,'0000-00-00'),
(161,1,'2025-07-09','13:44:35.000000','',1320.00,'percentage',0,0,1320,92.40,-0.4,1412.00,'Cash',0,0.00,'0000-00-00'),
(162,3,'2025-07-09','13:48:46.000000','',520.00,'percentage',0,0,520,36.40,-0.4,556.00,'Cash',0,0.00,'0000-00-00'),
(163,3,'2025-07-09','13:48:55.000000','',520.00,'percentage',0,0,520,36.40,-0.4,556.00,'Cash',0,0.00,'0000-00-00'),
(164,14,'2025-07-09','13:49:05.000000','',520.00,'percentage',0,0,520,36.40,-0.4,556.00,'Cash',2,0.00,'0000-00-00'),
(165,14,'2025-07-09','13:49:18.000000','',1040.00,'percentage',0,0,1040,72.80,0.2,1113.00,'Cash',0,0.00,'0000-00-00'),
(166,1,'2025-07-09','13:51:19.000000','',520.00,'percentage',0,0,520,0.00,0,520.00,'Cash',0,0.00,'0000-00-00'),
(167,14,'2025-07-11','13:44:04.000000','',1440.00,'percentage',0,0,1440,0.00,0,1440.00,'Cash',0,0.00,'0000-00-00'),
(168,14,'2025-07-11','14:28:05.000000','',2500.00,'percentage',0,0,2344,98.28,-0.28,2442.00,'Cash',0,0.00,'0000-00-00'),
(169,14,'2025-07-11','14:38:04.000000','',2340.00,'percentage',0,0,2340,72.80,0.2,2413.00,'Cash',0,0.00,'0000-00-00'),
(170,14,'2025-07-11','14:48:04.000000','',500.00,'percentage',0,0,500,35.00,0,535.00,'Cash',0,0.00,'0000-00-00'),
(171,14,'2025-07-11','14:55:10.000000','',900.00,'percentage',0,0,900,63.00,0,963.00,'Cash',0,0.00,'0000-00-00'),
(172,14,'2025-07-11','15:09:12.000000','',1340.00,'percentage',0,0,1340,93.80,0.2,1434.00,'Cash',0,0.00,'0000-00-00'),
(173,7,'2025-07-11','15:14:38.000000','',1040.00,'percentage',0,0,1040,72.80,0.2,1113.00,'Cash',0,0.00,'0000-00-00'),
(174,3,'2025-07-11','16:49:26.000000','fhdfhfdh',1520.00,'percentage',0,0,1520,106.40,-0.4,1626.00,'Cash',0,0.00,'0000-00-00'),
(175,14,'2025-07-11','16:52:23.000000','',1020.00,'percentage',0,0,1020,71.40,-0.4,1091.00,'Cash',0,0.00,'0000-00-00'),
(176,14,'2025-07-11','17:46:03.000000','',3370.00,'percentage',0,0,3370,235.90,0.1,3606.00,'Cash',0,0.00,'0000-00-00'),
(177,14,'2025-07-11','17:48:48.000000','',2380.00,'percentage',0,0,2380,166.60,0.4,2547.00,'Cash',0,0.00,'0000-00-00'),
(178,14,'2025-07-11','17:51:22.000000','',940.00,'percentage',0,0,940,65.80,0.2,1006.00,'Cash',0,0.00,'0000-00-00'),
(179,14,'2025-07-11','19:03:13.000000','',1040.00,'percentage',0,0,1040,72.80,0.2,1113.00,'Cash',0,0.00,'0000-00-00'),
(180,14,'2025-07-11','19:08:08.000000','',1840.00,'percentage',0,0,1840,128.80,0.2,1969.00,'Cash',0,0.00,'0000-00-00'),
(181,14,'2025-07-11','19:16:40.000000','',1560.00,'percentage',0,0,1560,109.20,-0.2,1669.00,'Cash',0,0.00,'0000-00-00'),
(182,14,'2025-07-11','19:17:59.000000','',900.00,'percentage',0,0,900,63.00,0,963.00,'Cash',0,0.00,'0000-00-00'),
(183,14,'2025-07-11','19:38:27.000000','',500.00,'percentage',0,0,500,35.00,0,535.00,'Cash',0,0.00,'0000-00-00'),
(184,14,'2025-07-11','19:54:06.000000','',3000.00,'percentage',0,0,3000,210.00,0,3210.00,'Cash',0,0.00,'0000-00-00'),
(185,3,'2025-07-12','10:55:31.000000','',1760.00,'percentage',0,0,1760,0.00,0,1760.00,'',0,0.00,'0000-00-00'),
(186,7,'2025-07-12','11:01:46.000000','',4100.00,'percentage',0,0,4100,287.00,0,4387.00,'',2,0.00,'0000-00-00'),
(187,4,'2025-07-12','13:14:04.000000','',2080.00,'percentage',0,0,2080,145.60,0.4,2226.00,'',0,0.00,'0000-00-00'),
(188,NULL,'2025-07-12','13:22:20.000000','Table 9',675.00,'percentage',0,0,675,0.00,0,675.00,'Cash',0,0.00,'0000-00-00'),
(189,14,'2025-07-14','12:53:32.000000','',1360.00,'percentage',0,0,1360,95.20,-0.2,1455.00,'',2,0.00,'0000-00-00'),
(190,NULL,'2025-07-14','17:03:58.000000','Table 1',100.00,'percentage',10,0,292.5,31.34,0.5,293.00,'Cash',0,0.00,'0000-00-00'),
(191,NULL,'2025-07-15','12:23:06.000000','Table 2',75.00,'percentage',0,0,325,34.82,0,325.00,'Cash',0,0.00,'0000-00-00'),
(192,NULL,'2025-07-15','12:26:20.000000','Take Away',280.00,'percentage',10,28,252,27.00,0,252.00,'Cash',0,0.00,'0000-00-00'),
(193,NULL,'2025-07-15','17:58:28.000000','Table 2',450.00,'percentage',10,45,405,28.35,-0.35,433.00,'Cash',0,0.00,'0000-00-00'),
(194,NULL,'2025-07-15','17:58:42.000000','Table 2',450.00,'percentage',10,45,405,28.35,-0.35,433.00,'Cash',0,0.00,'0000-00-00'),
(195,NULL,'2025-07-15','18:01:08.000000','Table 10',1425.00,'percentage',20,285,1140,79.80,0.2,1220.00,'Cash',0,0.00,'0000-00-00'),
(196,1,'2025-07-16','13:55:52.000000','Table 2',175.00,'percentage',15,26.25,148.75,10.41,-0.16,159.00,'Credit',1,0.00,'0000-00-00'),
(197,NULL,'2025-07-17','15:44:31.000000','Table 1',400.00,'percentage',0,0,400,28.00,0,428.00,'Cash',0,0.00,'0000-00-00'),
(198,14,'2025-07-18','16:45:39.000000','',1040.00,'percentage',0,0,1040,72.80,0.2,1113.00,'Cash',0,0.00,'0000-00-00'),
(199,NULL,'2025-07-22','17:34:12.000000','Table 2',175.00,'percentage',0,0,175,12.25,-0.25,187.00,'Cash',0,0.00,'0000-00-00'),
(200,NULL,'2025-07-24','18:00:34.000000','Take Away',285.00,'percentage',0,0,285,19.95,0.05,305.00,'Cash',0,0.00,'0000-00-00'),
(201,NULL,'2025-07-24','18:02:14.000000','Take Away',500.00,'percentage',0,0,500,32.71,0,500.00,'Cash',0,0.00,'0000-00-00'),
(202,3,'2025-07-24','19:31:55.000000','',1120.00,'percentage',0,0,1120,78.40,-0.4,1198.00,'Cash',0,0.00,'0000-00-00'),
(203,NULL,'2025-07-25','11:21:32.000000','Table 2',275.00,'percentage',0,0,275,17.99,0,275.00,'Cash',0,0.00,'0000-00-00'),
(204,NULL,'2025-07-25','11:24:15.000000','Table 4',300.00,'percentage',0,0,300,19.63,0,300.00,'Cash',0,0.00,'0000-00-00'),
(205,NULL,'2025-07-31','14:13:40.000000','Table 2',835.00,'percentage',0,0,835,54.63,0,835.00,'Cash',0,0.00,'0000-00-00'),
(206,NULL,'2025-08-15','16:52:15.000000','Table 5',325.00,'percentage',0,0,325,21.26,0,325.00,'Cash',0,0.00,'0000-00-00'),
(207,NULL,'2025-08-25','23:09:55.000000','Table 3',100.00,'percentage',0,0,100,6.54,0,100.00,'',0,0.00,'0000-00-00'),
(208,1,'2025-08-25','23:15:43.000000','',1340.00,'percentage',0,0,1340,93.80,0.2,1434.00,'',0,0.00,'0000-00-00'),
(209,NULL,'2025-08-26','15:33:27.000000','Table 7',225.00,'percentage',0,0,225,14.72,0,225.00,'Cash',0,0.00,'0000-00-00'),
(210,NULL,'2025-08-26','15:37:40.000000','Table 6',2000.00,'percentage',0,0,2000,130.84,0,2000.00,'',0,0.00,'0000-00-00'),
(211,NULL,'2025-08-26','15:40:35.000000','Table 2',225.00,'percentage',0,0,225,14.72,0,225.00,'',0,0.00,'0000-00-00'),
(212,NULL,'2025-08-26','15:45:54.000000','Table 4',200.00,'percentage',10,20,180,11.78,0,180.00,'',0,0.00,'0000-00-00'),
(213,NULL,'2025-08-26','15:50:20.000000','Table 7',345.00,'percentage',0,0,345,22.57,0,345.00,'',0,0.00,'0000-00-00'),
(214,NULL,'2025-08-26','15:54:02.000000','Table 1',250.00,'percentage',0,0,250,16.36,0,250.00,'Cash',0,0.00,'0000-00-00'),
(215,NULL,'2025-08-26','16:01:15.000000','Take Away, Table 5, Table 6',1125.00,'percentage',10,112.5,1012.5,66.24,0.5,1013.00,'Cash',0,0.00,'0000-00-00'),
(216,NULL,'2025-08-26','16:02:52.000000','Table 3',75.00,'percentage',0,0,75,4.91,0,75.00,'',0,0.00,'0000-00-00'),
(217,NULL,'2025-08-26','16:03:34.000000','Table 7',400.00,'percentage',5,20,380,24.86,0,380.00,'Cash',0,0.00,'0000-00-00'),
(218,NULL,'2025-08-26','16:03:54.000000','Take Away',350.00,'percentage',0,0,350,22.90,0,350.00,'',0,0.00,'0000-00-00'),
(219,NULL,'2025-08-26','16:12:01.000000','Table 5',310.00,'percentage',0,0,310,20.28,0,310.00,'',0,0.00,'0000-00-00'),
(220,NULL,'2025-08-26','16:59:53.000000','Table 3',425.00,'percentage',0,0,425,27.80,0,425.00,'Cash',0,0.00,'0000-00-00'),
(221,NULL,'2025-08-26','17:11:28.000000','Table 4, Table 6',1170.00,'percentage',0,0,1170,76.54,0,1170.00,'Cash',0,0.00,'0000-00-00'),
(222,NULL,'2025-08-26','17:12:09.000000','Table 5, Table 7',975.00,'percentage',0,0,975,63.79,0,975.00,'Cash',0,0.00,'0000-00-00'),
(223,NULL,'2025-08-27','15:47:48.000000','Table 3, Table 10',475.00,'percentage',10,47.5,427.5,27.97,0.5,428.00,'',0,0.00,'0000-00-00'),
(224,NULL,'2025-08-27','15:55:53.000000','Table 5',225.00,'percentage',0,0,225,14.72,0,225.00,'Cash',0,0.00,'0000-00-00'),
(225,NULL,'2025-08-27','18:01:57.000000','Table 9, Table 7, Table 4',1310.00,'percentage',10,131,1179,77.13,0,1179.00,'Cash',0,0.00,'0000-00-00'),
(226,NULL,'2025-08-27','18:02:08.000000','Table 9, Table 7, Table 4, Table 2',2340.00,'percentage',10,234,2106,137.78,0,2106.00,'Cash',0,0.00,'0000-00-00'),
(227,NULL,'2025-08-27','18:02:19.000000','Table 2',2340.00,'percentage',0,0,2340,153.08,0,2340.00,'Cash',0,0.00,'0000-00-00'),
(228,NULL,'2025-08-27','23:33:54.000000','Table 3',1755.00,'percentage',0,0,1755,114.81,0,1755.00,'Cash',0,0.00,'0000-00-00'),
(229,NULL,'2025-08-28','10:51:20.000000','Table 7',790.00,'percentage',0,0,790,51.68,0,790.00,'',0,0.00,'0000-00-00'),
(230,NULL,'2025-08-28','17:22:01.000000','Table 10',567.50,'percentage',0,0,567.5,37.13,0.5,568.00,'',0,0.00,'2025-08-28'),
(231,NULL,'2025-08-28','17:27:10.000000','Table 7',225.18,'percentage',0,0,225.18,14.73,-0.18,225.00,'',0,0.00,'2025-08-28'),
(232,NULL,'2025-08-29','13:08:30.000000','Table 2',225.00,'percentage',0,0,225,14.72,0,225.00,'Cash',0,0.00,'2025-08-29'),
(233,NULL,'2025-08-29','13:08:35.000000','Table 4',235.00,'percentage',0,0,235,15.37,0,235.00,'Cash',0,0.00,'2025-08-29'),
(234,NULL,'2025-08-29','13:32:56.000000','Table 3',750.00,'percentage',0,0,750,49.07,0,750.00,'Cash',0,0.00,'2025-08-29'),
(235,NULL,'2025-08-29','16:53:37.000000','Table 5',320.00,'percentage',0,0,320,20.93,0,320.00,'Cash',0,0.00,'2025-08-30'),
(236,NULL,'2025-08-29','16:53:47.000000','Table 9',317.50,'percentage',0,0,317.5,20.77,0.5,318.00,'',0,0.00,'2025-08-30'),
(237,NULL,'2025-08-29','17:10:21.000000','Table 4',120.00,'percentage',0,0,120,7.85,0,120.00,'Cash',0,0.00,'2025-08-29'),
(238,NULL,'2025-08-29','17:10:29.000000','Table 2',115.00,'percentage',0,0,115,7.52,0,115.00,'Card',0,0.00,'2025-08-29'),
(239,NULL,'2025-08-29','17:11:19.000000','Table 9',392.50,'percentage',0,0,392.5,25.68,0.5,393.00,'Bank Transfer',0,0.00,'2025-08-29'),
(240,3,'2025-09-02','18:13:42.000000','',934.58,'percentage',0,0,934.579,65.42,0,1000.00,'Cash',0,0.00,'2025-08-30'),
(241,NULL,'2025-09-03','19:50:13.000000','Table 1',1080.00,'percentage',0,0,1080,70.65,0,1080.00,'Cash',0,0.00,'2025-08-30'),
(242,NULL,'2025-09-03','19:56:13.000000','Table 2',290.00,'percentage',0,0,290,18.97,0,290.00,'Cash',0,0.00,'2025-08-30'),
(243,NULL,'2025-09-06','13:47:59.000000','Table 1',220.00,'percentage',0,0,220,14.39,0,220.00,'Cash',0,0.00,'2025-08-30'),
(244,NULL,'2025-09-06','14:36:45.000000','Take Away',260.00,'percentage',0,0,260,17.01,0,260.00,'Cash',0,0.00,'2025-08-30'),
(245,NULL,'2025-09-06','14:36:52.000000','Table 5',1882.50,'percentage',0,0,1882.5,123.15,0.5,1883.00,'Cash',0,0.00,'2025-08-30'),
(246,NULL,'2025-09-06','14:36:56.000000','Table 2',330.00,'percentage',0,0,330,21.59,0,330.00,'Cash',0,0.00,'2025-08-30'),
(247,NULL,'2025-09-06','14:40:14.000000','Room2',920.00,'percentage',0,0,920,60.19,0,920.00,'Cash',0,0.00,'2025-08-31'),
(248,NULL,'2025-09-06','14:43:39.000000','Room2',390.00,'percentage',0,0,390,25.51,0,390.00,'Cash',0,0.00,'2025-09-06'),
(249,NULL,'2025-09-06','14:43:46.000000','Table 9',120.00,'percentage',0,0,120,7.85,0,120.00,'Cash',0,0.00,'2025-09-06'),
(250,NULL,'2025-09-06','14:43:51.000000','Table 3',745.00,'percentage',0,0,745,48.74,0,745.00,'Cash',0,0.00,'2025-09-06'),
(251,NULL,'2025-09-06','14:43:57.000000','Room1',450.00,'percentage',0,0,450,29.44,0,450.00,'Cash',0,0.00,'2025-09-06'),
(252,NULL,'2025-09-06','15:25:55.000000','Table11',235.00,'percentage',0,0,235,15.37,0,235.00,'Cash',0,0.00,'2025-09-06'),
(253,NULL,'2025-09-06','15:50:39.000000','Table12, Table11, Room5, Room4, Room2, Take Away, ',2955.00,'percentage',0,0,2955,193.32,0,2955.00,'Cash',0,0.00,'2025-09-06'),
(254,NULL,'2025-09-08','13:34:29.000000','Table 7',150.00,'percentage',0,0,150,9.81,0,150.00,'Cash',0,0.00,'2025-09-07'),
(255,NULL,'2025-09-13','09:45:37.000000','Take Away',522.50,'percentage',0,0,522.5,34.18,0.5,523.00,'Cash',0,0.00,'2025-09-07'),
(256,NULL,'2025-09-13','09:49:12.000000','Table 4',390.00,'percentage',0,0,390,25.51,0,390.00,'Cash',0,0.00,'2025-09-07'),
(257,NULL,'2025-09-13','16:34:35.000000','Table 7',362.50,'percentage',0,0,362.5,23.71,0.5,363.00,'Cash',0,0.00,'2025-09-07'),
(258,NULL,'2025-09-13','16:36:12.000000','Room2',300.00,'percentage',0,0,300,19.63,0,300.00,'Cash',0,0.00,'2025-09-07');
/*!40000 ALTER TABLE `final_bill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` varchar(233) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `mimetype` varchar(100) NOT NULL,
  `size` int(11) NOT NULL,
  `dateUploaded` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) DEFAULT NULL,
  `item_id` int(11) NOT NULL,
  `opening_stock` decimal(10,2) DEFAULT 0.00,
  `stock_in` decimal(10,2) DEFAULT 0.00,
  `stock_out` decimal(10,2) DEFAULT 0.00,
  `closing_stock` decimal(10,2) GENERATED ALWAYS AS (`opening_stock` + `stock_in` - `stock_out`) STORED,
  `unit` varchar(50) DEFAULT NULL,
  `refno` varchar(100) DEFAULT NULL,
  `pdate` date DEFAULT NULL,
  `purchase_price` decimal(10,2) DEFAULT 0.00,
  `vat` decimal(5,2) DEFAULT 0.00,
  `subtotal` decimal(10,2) DEFAULT 0.00,
  `vatAmount` decimal(10,2) DEFAULT 0.00,
  `netAmount` decimal(10,2) DEFAULT 0.00,
  `last_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `fk_inventory_supplier` (`supplier_id`),
  CONSTRAINT `fk_inventory_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES
(1,1,89,0.00,20.00,0.00,20.00,'KG','301','2025-08-29',200.00,5.00,3809.52,190.48,4000.00,'2025-08-29 19:03:29','2025-08-29 19:03:29'),
(2,1,126,0.00,12.00,0.00,12.00,'btl.','301','2025-08-29',200.00,7.00,2242.99,157.01,2400.00,'2025-08-29 19:04:21','2025-08-29 19:04:21'),
(3,1,125,0.00,500.00,0.00,500.00,'Ltr','302','2025-08-29',150.00,5.00,71428.57,3571.43,75000.00,'2025-08-29 19:12:03','2025-08-29 19:12:03'),
(4,1,125,0.00,300.00,0.00,300.00,'Ltr','302','2025-08-29',50.00,5.00,14285.71,714.29,15000.00,'2025-08-29 19:14:21','2025-08-29 19:14:21'),
(5,1,89,0.00,30.00,0.00,30.00,'KG','6306','2025-08-29',20.00,5.00,571.43,28.57,600.00,'2025-08-29 19:36:50','2025-08-29 19:36:50'),
(6,1,127,0.00,300.00,0.00,300.00,'cann','701','2025-08-31',20.00,7.00,5607.48,392.52,6000.00,'2025-08-30 14:02:08','2025-08-30 14:02:08'),
(7,1,126,0.00,30.00,0.00,30.00,'btl.','701','2025-08-31',30.00,7.00,841.12,58.88,900.00,'2025-08-30 14:11:03','2025-08-30 14:11:03'),
(8,1,90,0.00,500.00,0.00,500.00,'KG','701','2025-08-31',50.00,5.00,23809.52,1190.48,25000.00,'2025-08-30 14:14:30','2025-08-30 14:14:30'),
(9,1,125,0.00,100.00,0.00,100.00,'Ltr','703','0000-00-00',50.00,5.00,4761.90,238.10,5000.00,'2025-08-30 15:28:44','2025-08-30 15:28:44'),
(10,2,127,300.00,200.00,0.00,500.00,'cann','705','2025-08-30',50.00,0.00,10000.00,0.00,10000.00,'2025-08-30 15:48:14','2025-08-30 15:48:14'),
(11,2,125,100.00,200.00,0.00,300.00,'Ltr','705','2025-08-30',30.00,5.00,5714.29,285.71,6000.00,'2025-08-30 15:48:27','2025-08-30 15:48:27'),
(12,1,88,0.00,200.00,0.00,200.00,'KG','201','2025-09-13',60.00,7.00,11214.95,785.05,12000.00,'2025-09-13 16:40:43','2025-09-13 16:40:43'),
(13,1,91,0.00,300.00,0.00,300.00,'KG','201','2025-09-13',100.00,5.00,28571.43,1428.57,30000.00,'2025-09-13 16:40:58','2025-09-13 16:40:58'),
(14,1,126,30.00,150.00,0.00,180.00,'btl.','2012','2025-09-13',120.00,7.00,16822.43,1177.57,18000.00,'2025-09-13 16:41:25','2025-09-13 16:41:25'),
(15,1,132,0.00,200.00,0.00,200.00,'cann','2545','2025-09-30',150.00,7.00,28037.38,1962.62,30000.00,'2025-09-30 10:15:26','2025-09-30 10:15:26');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_images`
--

DROP TABLE IF EXISTS `item_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` varchar(233) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `mimetype` varchar(100) NOT NULL,
  `size` int(11) NOT NULL,
  `dateUploaded` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_images`
--

LOCK TABLES `item_images` WRITE;
/*!40000 ALTER TABLE `item_images` DISABLE KEYS */;
INSERT INTO `item_images` VALUES
(1,'83','images-1751094384988.webp','uploads/images-1751094384988.webp','image/webp',39222,'2025-06-28 14:06:25'),
(2,'84','images-1751095290808.jpg','uploads/images-1751095290808.jpg','image/jpeg',97471,'2025-06-28 14:21:30'),
(3,'85','images-1751099284783.jpg','uploads/images-1751099284783.jpg','image/jpeg',60125,'2025-06-28 15:28:04'),
(4,'87','images-1751099315146.jpg','uploads/images-1751099315146.jpg','image/jpeg',177079,'2025-06-28 15:28:35'),
(5,'88','images-1751099590525.webp','uploads/images-1751099590525.webp','image/webp',39222,'2025-06-28 15:33:10'),
(6,'89','images-1751099623987.webp','uploads/images-1751099623987.webp','image/webp',22894,'2025-06-28 15:33:44'),
(7,'91','images-1751099706262.webp','uploads/images-1751099706262.webp','image/webp',129768,'2025-06-28 15:35:06'),
(8,'92','images-1751099738932.webp','uploads/images-1751099738932.webp','image/webp',22268,'2025-06-28 15:35:38'),
(9,'93','images-1751099766979.jpg','uploads/images-1751099766979.jpg','image/jpeg',782007,'2025-06-28 15:36:07'),
(10,'94','images-1751104389681.jpg','uploads/images-1751104389681.jpg','image/jpeg',97471,'2025-06-28 16:53:09'),
(11,'95','images-1751104652045.jpg','uploads/images-1751104652045.jpg','image/jpeg',83562,'2025-06-28 16:57:32'),
(12,'96','images-1751104672657.jpg','uploads/images-1751104672657.jpg','image/jpeg',207433,'2025-06-28 16:57:52'),
(13,'97','images-1751104755365.webp','uploads/images-1751104755365.webp','image/webp',45632,'2025-06-28 16:59:15'),
(14,'98','images-1751104777876.jpg','uploads/images-1751104777876.jpg','image/jpeg',136739,'2025-06-28 16:59:37'),
(15,'99','images-1751436640782.jpg','uploads/images-1751436640782.jpg','image/jpeg',72931,'2025-07-02 13:10:40'),
(16,'100','images-1751436665073.jpeg','uploads/images-1751436665073.jpeg','image/jpeg',12565,'2025-07-02 13:11:05'),
(17,'101','images-1751436687368.jpg','uploads/images-1751436687368.jpg','image/jpeg',176048,'2025-07-02 13:11:27'),
(18,'102','images-1751436704337.jpeg','uploads/images-1751436704337.jpeg','image/jpeg',257580,'2025-07-02 13:11:44'),
(19,'103','images-1751436720742.webp','uploads/images-1751436720742.webp','image/webp',49258,'2025-07-02 13:12:00'),
(20,'104','images-1751436740489.jpg','uploads/images-1751436740489.jpg','image/jpeg',211339,'2025-07-02 13:12:20'),
(21,'105','images-1751436761314.jpg','uploads/images-1751436761314.jpg','image/jpeg',526425,'2025-07-02 13:12:41'),
(22,'106','images-1751436819211.webp','uploads/images-1751436819211.webp','image/webp',32916,'2025-07-02 13:13:39'),
(23,'107','images-1751436858770.jpg','uploads/images-1751436858770.jpg','image/jpeg',110464,'2025-07-02 13:14:18'),
(24,'108','images-1751441807028.webp','uploads/images-1751441807028.webp','image/webp',118350,'2025-07-02 14:36:47'),
(25,'109','images-1751441825338.webp','uploads/images-1751441825338.webp','image/webp',32992,'2025-07-02 14:37:05'),
(26,'110','images-1751441852250.webp','uploads/images-1751441852250.webp','image/webp',24056,'2025-07-02 14:37:32'),
(27,'111','images-1751441882322.webp','uploads/images-1751441882322.webp','image/webp',24056,'2025-07-02 14:38:02'),
(28,'112','images-1751441907882.jpeg','uploads/images-1751441907882.jpeg','image/jpeg',9222,'2025-07-02 14:38:27'),
(29,'113','images-1751441966653.jpg','uploads/images-1751441966653.jpg','image/jpeg',268470,'2025-07-02 14:39:26'),
(30,'114','images-1751442023453.jpeg','uploads/images-1751442023453.jpeg','image/jpeg',160401,'2025-07-02 14:40:23'),
(31,'115','images-1751442082018.jpg','uploads/images-1751442082018.jpg','image/jpeg',92857,'2025-07-02 14:41:22'),
(32,'116','images-1751442137033.jpg','uploads/images-1751442137033.jpg','image/jpeg',79482,'2025-07-02 14:42:17'),
(33,'117','images-1751442270663.jpg','uploads/images-1751442270663.jpg','image/jpeg',69949,'2025-07-02 14:44:30'),
(34,'118','images-1751443161452.jpg','uploads/images-1751443161452.jpg','image/jpeg',113014,'2025-07-02 14:59:21'),
(35,'119','images-1751443247051.jpg','uploads/images-1751443247051.jpg','image/jpeg',150783,'2025-07-02 15:00:47'),
(36,'120','images-1751443290410.jpg','uploads/images-1751443290410.jpg','image/jpeg',141486,'2025-07-02 15:01:30');
/*!40000 ALTER TABLE `item_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `catid` int(10) unsigned NOT NULL,
  `subcatid` int(10) unsigned DEFAULT NULL,
  `iname` varchar(233) NOT NULL,
  `unit` varchar(23) NOT NULL,
  `weight` varchar(20) NOT NULL,
  `tax` int(11) NOT NULL,
  `mrp` int(11) NOT NULL,
  `offerprice` int(11) NOT NULL,
  `description` text NOT NULL,
  `min_stock` int(11) NOT NULL DEFAULT 0,
  `isstockable` varchar(50) NOT NULL DEFAULT 'false',
  `status` varchar(233) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`id`),
  KEY `fk_items_catid` (`catid`),
  KEY `fk_items_subcatid` (`subcatid`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES
(85,10,23,'Khoya Barfi','KG','weight',5,600,600,'',10,'0','Active'),
(86,10,23,'Malai Barfi','KG','weight',5,520,520,'',20,'0','Active'),
(88,10,23,'Kalakand five','KG','weight',5,550,550,'',20,'1','Active'),
(89,10,23,'KalakandPakeeza','KG','weight',5,520,520,'',20,'1','Active'),
(90,10,23,'Pakeeza','KG','weight',5,520,520,'',20,'1','Active'),
(91,10,23,'Milk Cake','KG','weight',5,480,480,'',20,'1','Active'),
(92,10,23,'Bhare Chumchum','KG','weight',5,450,450,'',20,'0','Active'),
(93,10,23,'Chocolate Barfi','KG','weight',5,520,520,'',20,'0','Active'),
(94,10,23,'Rasgulle','KG','weight',5,300,300,'',20,'0','Active'),
(95,10,23,'ChumChum','KG','weight',5,300,300,'',20,'0','Active'),
(96,10,23,'Gulabjamun','KG','weight',5,320,320,'',20,'0','Active'),
(97,10,23,'Kaju Katli','KG','weight',5,1000,1000,'',20,'0','Active'),
(98,10,23,'Gajar Barfi','KG','weight',5,460,460,'',20,'0','Active'),
(99,10,23,'Petha','KG','weight',5,300,300,'',10,'0','Active'),
(100,10,23,'Coconut Barfi','KG','weight',5,520,520,'',10,'0','Active'),
(101,10,23,'Meetha Bdana','KG','weight',5,260,260,'',10,'0','Active'),
(102,10,23,'Amrati','KG','weight',5,420,420,'',10,'0','Active'),
(103,10,23,'jalebi','KG','weight',5,220,220,'',10,'0','Active'),
(104,10,23,'Gujia','KG','weight',5,360,360,'',10,'0','Active'),
(105,10,23,'Balushahi','KG','weight',5,260,260,'',10,'0','Active'),
(106,10,23,'Besan Laddu','KG','weight',5,260,260,'',10,'0','Active'),
(107,10,23,'Besan Barfi','KG','weight',5,260,260,'',10,'0','Active'),
(108,10,23,'Doda Barfi','KG','weight',5,400,400,'',10,'0','Active'),
(109,10,23,'Patisa','KG','weight',5,340,340,'',10,'0','Active'),
(110,10,23,'Mix Mithai','KG','weight',5,350,350,'',10,'0','Active'),
(111,10,23,'Koya Mix','KG','weight',5,520,520,'',10,'0','Active'),
(112,10,23,'Khoya Paneer Mix','KG','weight',5,500,500,'',10,'0','Active'),
(113,10,23,'moong dal pinni','KG','weight',5,400,400,'',10,'0','Active'),
(114,10,24,'Mattar namkeen','KG','weight',5,260,260,'',10,'0','Active'),
(115,10,24,'Sewiyan Namkeen','KG','weight',5,300,300,'',10,'0','Active'),
(116,10,24,'Mix Namkeen','KG','weight',5,320,320,'',10,'0','Active'),
(117,10,24,'Moong Dal Namkeen','KG','weight',5,320,320,'',10,'0','Active'),
(118,11,25,'Chai','cup','unit',5,15,15,'',10,'0','Active'),
(120,10,24,'pakode','KG','weight',5,280,280,'',10,'0','Active'),
(129,11,25,'fbdjbk','cann','unit',7,636,6565,'fhghgf',0,'1','Active'),
(131,11,26,'hgfh','cann','weight',7,100,100,'',10,'1','Active'),
(132,11,26,'hgfhkjk','cann','weight',7,200,200,'',10,'1','Active');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ledger_entries`
--

DROP TABLE IF EXISTS `ledger_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ledger_entries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(50) NOT NULL,
  `date` datetime DEFAULT current_timestamp(),
  `account_type` varchar(233) NOT NULL,
  `account_id` int(11) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `debit_amount` decimal(15,2) DEFAULT 0.00,
  `credit_amount` decimal(15,2) DEFAULT 0.00,
  `reference_id` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_transaction` (`transaction_id`),
  KEY `idx_account` (`account_id`,`account_type`(1))
) ENGINE=InnoDB AUTO_INCREMENT=634 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ledger_entries`
--

LOCK TABLES `ledger_entries` WRITE;
/*!40000 ALTER TABLE `ledger_entries` DISABLE KEYS */;
INSERT INTO `ledger_entries` VALUES
(1,'1','2025-02-11 17:57:08','Sales',1,'Bill #1 - Sale Revenue',0.00,898.80,0,'2025-02-11 17:57:08','2025-02-11 17:57:08'),
(2,'1','2025-02-11 17:57:08','Account Recievable',2,'Bill #1 - Credit Sale',840.00,0.00,0,'2025-02-11 17:57:08','2025-02-11 17:57:08'),
(3,'1','2025-02-11 17:57:08','Round-Off',5,'Bill #1 - Round-Off Adjustment',0.20,0.00,1,'2025-02-11 17:57:08','2025-02-11 17:57:08'),
(4,'1','2025-02-11 17:57:08','Tax',2,'Bill #1 - Tax',58.80,0.00,1,'2025-02-11 17:57:08','2025-02-11 17:57:08'),
(5,'2','2025-02-12 15:05:58','Sales',1,'Bill #2 - Sale Revenue',0.00,642.00,0,'2025-02-12 15:05:57','2025-02-12 15:05:57'),
(6,'2','2025-02-12 15:05:58','Cash',0,'Bill #2 - Cash Payment',600.00,0.00,0,'2025-02-12 15:05:57','2025-02-12 15:05:57'),
(7,'2','2025-02-12 15:05:58','Discount',0,'Bill #2 - Discount Given',2613.60,0.00,2,'2025-02-12 15:05:57','2025-02-12 15:05:57'),
(8,'2','2025-02-12 15:05:58','Round-Off',5,'Bill #2 - Round-Off Adjustment',0.00,0.00,2,'2025-02-12 15:05:57','2025-02-12 15:05:57'),
(9,'2','2025-02-12 15:05:58','Tax',0,'Bill #2 - Tax',42.00,0.00,2,'2025-02-12 15:05:57','2025-02-12 15:05:57'),
(10,'3','2025-02-12 15:06:27','Sales',1,'Bill #3 - Sale Revenue',0.00,749.00,0,'2025-02-12 15:06:27','2025-02-12 15:06:27'),
(11,'3','2025-02-12 15:06:27','Account Recievable',1,'Bill #3 - Credit Sale',700.00,0.00,0,'2025-02-12 15:06:27','2025-02-12 15:06:27'),
(12,'3','2025-02-12 15:06:27','Discount',1,'Bill #3 - Discount Given',4867.20,0.00,3,'2025-02-12 15:06:27','2025-02-12 15:06:27'),
(13,'3','2025-02-12 15:06:27','Round-Off',5,'Bill #3 - Round-Off Adjustment',0.00,0.00,3,'2025-02-12 15:06:27','2025-02-12 15:06:27'),
(14,'3','2025-02-12 15:06:27','Tax',1,'Bill #3 - Tax',49.00,0.00,3,'2025-02-12 15:06:27','2025-02-12 15:06:27'),
(15,'4','2025-02-12 15:45:48','Sales',1,'Bill #4 - Sale Revenue',0.00,845.30,0,'2025-02-12 15:45:48','2025-02-12 15:45:48'),
(16,'4','2025-02-12 15:45:48','Account Recievable',2,'Bill #4 - Credit Sale',845.30,0.00,0,'2025-02-12 15:45:48','2025-02-12 15:45:48'),
(17,'5','2025-02-20 14:11:31','Sales',1,'Bill #5 - Sale Revenue',0.00,699.78,0,'2025-02-20 14:11:30','2025-02-20 14:11:30'),
(18,'5','2025-02-20 14:11:31','Cash',0,'Bill #5 - Cash Payment',699.78,0.00,0,'2025-02-20 14:11:30','2025-02-20 14:11:30'),
(19,'6','2025-02-20 14:22:29','Sales',1,'Bill #6 - Sale Revenue',0.00,417.30,0,'2025-02-20 14:22:29','2025-02-20 14:22:29'),
(20,'6','2025-02-20 14:22:29','Cash',0,'Bill #6 - Cash Payment',417.30,0.00,0,'2025-02-20 14:22:29','2025-02-20 14:22:29'),
(21,'7','2025-02-20 15:57:39','Sales',1,'Bill #7 - Sale Revenue',0.00,520.02,0,'2025-02-20 15:57:38','2025-02-20 15:57:38'),
(22,'7','2025-02-20 15:57:39','Cash',0,'Bill #7 - Cash Payment',520.02,0.00,0,'2025-02-20 15:57:38','2025-02-20 15:57:38'),
(23,'8','2025-02-20 15:59:33','Sales',1,'Bill #8 - Sale Revenue',0.00,625.95,0,'2025-02-20 15:59:32','2025-02-20 15:59:32'),
(24,'8','2025-02-20 15:59:33','Cash',0,'Bill #8 - Cash Payment',625.95,0.00,0,'2025-02-20 15:59:32','2025-02-20 15:59:32'),
(25,'9','2025-02-20 15:59:51','Sales',1,'Bill #9 - Sale Revenue',0.00,625.95,0,'2025-02-20 15:59:50','2025-02-20 15:59:50'),
(26,'9','2025-02-20 15:59:51','Cash',0,'Bill #9 - Cash Payment',625.95,0.00,0,'2025-02-20 15:59:50','2025-02-20 15:59:50'),
(27,'10','2025-02-20 16:00:02','Sales',1,'Bill #10 - Sale Revenue',0.00,635.58,0,'2025-02-20 16:00:01','2025-02-20 16:00:01'),
(28,'10','2025-02-20 16:00:02','Cash',0,'Bill #10 - Cash Payment',635.58,0.00,0,'2025-02-20 16:00:01','2025-02-20 16:00:01'),
(29,'11','2025-02-20 16:05:13','Sales',1,'Bill #11 - Sale Revenue',0.00,346.68,0,'2025-02-20 16:05:12','2025-02-20 16:05:12'),
(30,'11','2025-02-20 16:05:13','Cash',0,'Bill #11 - Cash Payment',346.68,0.00,0,'2025-02-20 16:05:12','2025-02-20 16:05:12'),
(31,'12','2025-02-20 16:54:46','Sales',1,'Bill #12 - Sale Revenue',0.00,693.36,0,'2025-02-20 16:54:45','2025-02-20 16:54:45'),
(32,'12','2025-02-20 16:54:46','Cash',0,'Bill #12 - Cash Payment',693.36,0.00,0,'2025-02-20 16:54:45','2025-02-20 16:54:45'),
(33,'13','2025-02-20 17:16:47','Sales',1,'Bill #13 - Sale Revenue',0.00,1040.04,0,'2025-02-20 17:16:46','2025-02-20 17:16:46'),
(34,'13','2025-02-20 17:16:47','Cash',0,'Bill #13 - Cash Payment',1040.04,0.00,0,'2025-02-20 17:16:46','2025-02-20 17:16:46'),
(35,'14','2025-02-20 17:19:25','Sales',1,'Bill #14 - Sale Revenue',0.00,346.68,0,'2025-02-20 17:19:24','2025-02-20 17:19:24'),
(36,'14','2025-02-20 17:19:25','Cash',0,'Bill #14 - Cash Payment',346.68,0.00,0,'2025-02-20 17:19:24','2025-02-20 17:19:24'),
(37,'15','2025-02-20 17:23:17','Sales',1,'Bill #15 - Sale Revenue',0.00,481.50,0,'2025-02-20 17:23:16','2025-02-20 17:23:16'),
(38,'15','2025-02-20 17:23:17','Cash',0,'Bill #15 - Cash Payment',481.50,0.00,0,'2025-02-20 17:23:16','2025-02-20 17:23:16'),
(39,'16','2025-02-20 17:26:08','Sales',1,'Bill #16 - Sale Revenue',0.00,427.47,0,'2025-02-20 17:26:08','2025-02-20 17:26:08'),
(40,'16','2025-02-20 17:26:08','Cash',0,'Bill #16 - Cash Payment',427.47,0.00,0,'2025-02-20 17:26:08','2025-02-20 17:26:08'),
(41,'17','2025-02-20 17:52:14','Sales',1,'Bill #17 - Sale Revenue',0.00,414.09,0,'2025-02-20 17:52:14','2025-02-20 17:52:14'),
(42,'17','2025-02-20 17:52:14','Cash',0,'Bill #17 - Cash Payment',414.09,0.00,0,'2025-02-20 17:52:14','2025-02-20 17:52:14'),
(43,'18','2025-02-24 14:15:18','Sales',1,'Bill #18 - Sale Revenue',0.00,749.00,0,'2025-02-24 14:15:17','2025-02-24 14:15:17'),
(44,'18','2025-02-24 14:15:18','Cash',0,'Bill #18 - Cash Payment',749.00,0.00,0,'2025-02-24 14:15:17','2025-02-24 14:15:17'),
(45,'19','2025-02-24 14:17:53','Sales',1,'Bill #19 - Sale Revenue',0.00,492.20,0,'2025-02-24 14:17:53','2025-02-24 14:17:53'),
(46,'19','2025-02-24 14:17:53','Cash',0,'Bill #19 - Cash Payment',492.20,0.00,0,'2025-02-24 14:17:53','2025-02-24 14:17:53'),
(47,'20','2025-02-24 14:18:29','Sales',1,'Bill #20 - Sale Revenue',0.00,770.40,0,'2025-02-24 14:18:28','2025-02-24 14:18:28'),
(48,'20','2025-02-24 14:18:29','Cash',0,'Bill #20 - Cash Payment',770.40,0.00,0,'2025-02-24 14:18:28','2025-02-24 14:18:28'),
(49,'21','2025-02-24 14:27:32','Sales',1,'Bill #21 - Sale Revenue',0.00,642.00,0,'2025-02-24 14:27:32','2025-02-24 14:27:32'),
(50,'21','2025-02-24 14:27:32','Cash',0,'Bill #21 - Cash Payment',642.00,0.00,0,'2025-02-24 14:27:32','2025-02-24 14:27:32'),
(51,'22','2025-02-24 14:34:05','Sales',1,'Bill #22 - Sale Revenue',0.00,1070.00,0,'2025-02-24 14:34:04','2025-02-24 14:34:04'),
(52,'22','2025-02-24 14:34:05','Cash',0,'Bill #22 - Cash Payment',1070.00,0.00,0,'2025-02-24 14:34:04','2025-02-24 14:34:04'),
(53,'23','2025-02-24 14:34:44','Sales',1,'Bill #23 - Sale Revenue',0.00,214.00,0,'2025-02-24 14:34:43','2025-02-24 14:34:43'),
(54,'23','2025-02-24 14:34:44','Cash',0,'Bill #23 - Cash Payment',214.00,0.00,0,'2025-02-24 14:34:43','2025-02-24 14:34:43'),
(55,'24','2025-02-24 14:37:32','Sales',1,'Bill #24 - Sale Revenue',0.00,321.00,0,'2025-02-24 14:37:32','2025-02-24 14:37:32'),
(56,'24','2025-02-24 14:37:32','Cash',0,'Bill #24 - Cash Payment',321.00,0.00,0,'2025-02-24 14:37:32','2025-02-24 14:37:32'),
(57,'25','2025-02-24 14:40:28','Sales',1,'Bill #25 - Sale Revenue',0.00,856.00,0,'2025-02-24 14:40:28','2025-02-24 14:40:28'),
(58,'25','2025-02-24 14:40:28','Cash',0,'Bill #25 - Cash Payment',856.00,0.00,0,'2025-02-24 14:40:28','2025-02-24 14:40:28'),
(59,'26','2025-02-24 15:06:22','Sales',1,'Bill #26 - Sale Revenue',0.00,642.00,0,'2025-02-24 15:06:21','2025-02-24 15:06:21'),
(60,'26','2025-02-24 15:06:22','Cash',0,'Bill #26 - Cash Payment',642.00,0.00,0,'2025-02-24 15:06:21','2025-02-24 15:06:21'),
(61,'27','2025-02-24 15:08:47','Sales',1,'Bill #27 - Sale Revenue',0.00,395.90,0,'2025-02-24 15:08:47','2025-02-24 15:08:47'),
(62,'27','2025-02-24 15:08:47','Cash',0,'Bill #27 - Cash Payment',395.90,0.00,0,'2025-02-24 15:08:47','2025-02-24 15:08:47'),
(63,'28','2025-02-24 15:10:05','Sales',1,'Bill #28 - Sale Revenue',0.00,599.20,0,'2025-02-24 15:10:04','2025-02-24 15:10:04'),
(64,'28','2025-02-24 15:10:05','Cash',0,'Bill #28 - Cash Payment',599.20,0.00,0,'2025-02-24 15:10:04','2025-02-24 15:10:04'),
(65,'29','2025-02-24 15:35:52','Sales',1,'Bill #29 - Sale Revenue',0.00,1348.20,0,'2025-02-24 15:35:51','2025-02-24 15:35:51'),
(66,'29','2025-02-24 15:35:52','Cash',0,'Bill #29 - Cash Payment',1348.20,0.00,0,'2025-02-24 15:35:51','2025-02-24 15:35:51'),
(67,'30','2025-02-24 16:29:50','Sales',1,'Bill #30 - Sale Revenue',0.00,625.95,0,'2025-02-24 16:29:50','2025-02-24 16:29:50'),
(68,'30','2025-02-24 16:29:50','Cash',0,'Bill #30 - Cash Payment',625.95,0.00,0,'2025-02-24 16:29:50','2025-02-24 16:29:50'),
(69,'31','2025-02-24 16:30:07','Sales',1,'Bill #31 - Sale Revenue',0.00,520.02,0,'2025-02-24 16:30:06','2025-02-24 16:30:06'),
(70,'31','2025-02-24 16:30:07','Cash',0,'Bill #31 - Cash Payment',520.02,0.00,0,'2025-02-24 16:30:06','2025-02-24 16:30:06'),
(71,'32','2025-02-24 16:31:54','Sales',1,'Bill #32 - Sale Revenue',0.00,6630.27,0,'2025-02-24 16:31:53','2025-02-24 16:31:53'),
(72,'32','2025-02-24 16:31:54','Cash',0,'Bill #32 - Cash Payment',6630.27,0.00,0,'2025-02-24 16:31:53','2025-02-24 16:31:53'),
(73,'33','2025-02-24 16:36:50','Sales',1,'Bill #33 - Sale Revenue',0.00,353.10,0,'2025-02-24 16:36:50','2025-02-24 16:36:50'),
(74,'33','2025-02-24 16:36:50','Cash',0,'Bill #33 - Cash Payment',353.10,0.00,0,'2025-02-24 16:36:50','2025-02-24 16:36:50'),
(75,'34','2025-02-24 16:51:30','Sales',1,'Bill #34 - Sale Revenue',0.00,188.32,0,'2025-02-24 16:51:30','2025-02-24 16:51:30'),
(76,'34','2025-02-24 16:51:30','Cash',0,'Bill #34 - Cash Payment',188.32,0.00,0,'2025-02-24 16:51:30','2025-02-24 16:51:30'),
(77,'35','2025-02-24 16:56:04','Sales',1,'Bill #35 - Sale Revenue',0.00,888.10,0,'2025-02-24 16:56:03','2025-02-24 16:56:03'),
(78,'35','2025-02-24 16:56:04','Cash',0,'Bill #35 - Cash Payment',888.10,0.00,0,'2025-02-24 16:56:03','2025-02-24 16:56:03'),
(79,'36','2025-02-24 16:57:15','Sales',1,'Bill #36 - Sale Revenue',0.00,731.88,0,'2025-02-24 16:57:14','2025-02-24 16:57:14'),
(80,'36','2025-02-24 16:57:15','Cash',0,'Bill #36 - Cash Payment',731.88,0.00,0,'2025-02-24 16:57:14','2025-02-24 16:57:14'),
(81,'37','2025-02-24 17:02:47','Sales',1,'Bill #37 - Sale Revenue',0.00,577.80,0,'2025-02-24 17:02:47','2025-02-24 17:02:47'),
(82,'37','2025-02-24 17:02:47','Cash',0,'Bill #37 - Cash Payment',577.80,0.00,0,'2025-02-24 17:02:47','2025-02-24 17:02:47'),
(83,'38','2025-02-24 17:04:11','Sales',1,'Bill #38 - Sale Revenue',0.00,770.40,0,'2025-02-24 17:04:11','2025-02-24 17:04:11'),
(84,'38','2025-02-24 17:04:11','Cash',0,'Bill #38 - Cash Payment',770.40,0.00,0,'2025-02-24 17:04:11','2025-02-24 17:04:11'),
(85,'39','2025-02-24 17:05:30','Sales',1,'Bill #39 - Sale Revenue',0.00,802.50,0,'2025-02-24 17:05:29','2025-02-24 17:05:29'),
(86,'39','2025-02-24 17:05:30','Cash',0,'Bill #39 - Cash Payment',802.50,0.00,0,'2025-02-24 17:05:29','2025-02-24 17:05:29'),
(87,'40','2025-02-24 17:20:01','Sales',1,'Bill #40 - Sale Revenue',0.00,652.70,0,'2025-02-24 17:20:01','2025-02-24 17:20:01'),
(88,'40','2025-02-24 17:20:01','Cash',0,'Bill #40 - Cash Payment',652.70,0.00,0,'2025-02-24 17:20:01','2025-02-24 17:20:01'),
(89,'41','2025-02-24 17:20:43','Sales',1,'Bill #41 - Sale Revenue',0.00,564.96,0,'2025-02-24 17:20:42','2025-02-24 17:20:42'),
(90,'41','2025-02-24 17:20:43','Cash',0,'Bill #41 - Cash Payment',564.96,0.00,0,'2025-02-24 17:20:42','2025-02-24 17:20:42'),
(91,'42','2025-02-24 18:48:36','Sales',1,'Bill #42 - Sale Revenue',0.00,2284.45,0,'2025-02-24 18:48:35','2025-02-24 18:48:35'),
(92,'42','2025-02-24 18:48:36','Cash',0,'Bill #42 - Cash Payment',2284.45,0.00,0,'2025-02-24 18:48:35','2025-02-24 18:48:35'),
(93,'43','2025-02-24 18:52:53','Sales',1,'Bill #43 - Sale Revenue',0.00,2119.00,0,'2025-02-24 18:52:53','2025-02-24 18:52:53'),
(94,'43','2025-02-24 18:52:53','Cash',0,'Bill #43 - Cash Payment',2119.00,0.00,0,'2025-02-24 18:52:53','2025-02-24 18:52:53'),
(95,'44','2025-02-25 15:48:44','Sales',1,'Bill #44 - Sale Revenue',0.00,284.00,0,'2025-02-25 15:48:44','2025-02-25 15:48:44'),
(96,'44','2025-02-25 15:48:44','Account Recievable',1,'Bill #44 - Credit Sale',284.00,0.00,0,'2025-02-25 15:48:44','2025-02-25 15:48:44'),
(97,'45','2025-03-13 19:08:28','Sales',1,'Bill #45 - Sale Revenue',0.00,1701.00,0,'2025-03-13 19:08:27','2025-03-13 19:08:27'),
(98,'45','2025-03-13 19:08:28','Account Recievable',1,'Bill #45 - Credit Sale',1701.00,0.00,0,'2025-03-13 19:08:27','2025-03-13 19:08:27'),
(99,'46','2025-03-13 19:08:31','Sales',1,'Bill #46 - Sale Revenue',0.00,1701.00,0,'2025-03-13 19:08:31','2025-03-13 19:08:31'),
(100,'46','2025-03-13 19:08:31','Account Recievable',1,'Bill #46 - Credit Sale',1701.00,0.00,0,'2025-03-13 19:08:31','2025-03-13 19:08:31'),
(101,'47','2025-03-13 19:12:40','Sales',1,'Bill #47 - Sale Revenue',0.00,1070.00,0,'2025-03-13 19:12:40','2025-03-13 19:12:40'),
(102,'47','2025-03-13 19:12:40','Cash',0,'Bill #47 - Cash Payment',1070.00,0.00,0,'2025-03-13 19:12:40','2025-03-13 19:12:40'),
(103,'','2025-03-15 16:18:13','Cash',0,'Customer Payment Received',749.00,0.00,3,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(104,'','2025-03-15 16:18:13','Accounts Receivable',1,'Payment Received',0.00,749.00,3,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(105,'','2025-03-15 16:18:13','Cash',0,'Customer Payment Received',284.00,0.00,44,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(106,'','2025-03-15 16:18:13','Accounts Receivable',1,'Payment Received',0.00,284.00,44,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(107,'','2025-03-15 16:18:13','Cash',0,'Customer Payment Received',967.00,0.00,45,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(108,'','2025-03-15 16:18:13','Account Recievable',1,'Payment Received',0.00,967.00,45,'2025-03-15 16:18:13','2025-03-15 17:47:08'),
(109,'','2025-03-15 16:25:00','Cash',1,'Customer Payment Received',1701.00,0.00,46,'2025-03-15 16:25:00','2025-03-15 16:25:00'),
(110,'48','2025-03-15 17:07:54','Sales',1,'Bill #48 - Sale Revenue',0.00,1156.00,0,'2025-03-15 17:07:53','2025-03-15 17:07:53'),
(111,'48','2025-03-15 17:07:54','Account Recievable',2,'Bill #48 - Credit Sale',1156.00,0.00,0,'2025-03-15 17:07:53','2025-03-15 17:07:53'),
(112,'49','2025-03-15 17:08:00','Sales',1,'Bill #49 - Sale Revenue',0.00,1156.00,0,'2025-03-15 17:07:59','2025-03-15 17:07:59'),
(113,'49','2025-03-15 17:08:00','Account Recievable',2,'Bill #49 - Credit Sale',1156.00,0.00,0,'2025-03-15 17:07:59','2025-03-15 17:07:59'),
(114,'50','2025-03-15 17:29:49','Sales',1,'Bill #50 - Sale Revenue',0.00,369.00,0,'2025-03-15 17:29:49','2025-03-15 17:29:49'),
(115,'50','2025-03-15 17:29:49','Cash',0,'Bill #50 - Cash Payment',369.00,0.00,0,'2025-03-15 17:29:49','2025-03-15 17:29:49'),
(116,'','2025-03-15 17:42:14','Cash',0,'Customer Payment Received',898.80,0.00,1,'2025-03-15 17:42:13','2025-03-15 17:42:13'),
(117,'','2025-03-15 17:42:14','Account Recievable',2,'Credit Paid',0.00,898.80,1,'2025-03-15 17:42:13','2025-03-15 17:47:14'),
(118,'','2025-03-15 17:42:14','Cash',0,'Customer Payment Received',601.20,0.00,4,'2025-03-15 17:42:13','2025-03-15 17:42:13'),
(119,'','2025-03-15 17:42:14','Account Recievable',2,'Credit Paid',0.00,601.20,4,'2025-03-15 17:42:13','2025-03-15 17:43:40'),
(120,'','2025-03-15 17:49:32','Cash',0,'Customer Payment Received',1156.00,0.00,48,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(121,'','2025-03-15 17:49:32','Account Recievable',2,'Credit Paid',0.00,1156.00,48,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(122,'','2025-03-15 17:49:32','Cash',0,'Customer Payment Received',1144.30,0.00,49,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(123,'','2025-03-15 17:49:32','Account Recievable',2,'Credit Paid',0.00,1144.30,49,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(124,'51','2025-03-15 18:05:08','Sales',1,'Bill #51 - Sale Revenue',0.00,519.00,0,'2025-03-15 18:05:07','2025-03-15 18:05:07'),
(125,'51','2025-03-15 18:05:08','Account Recievable',1,'Bill #51 - Credit Sale',519.00,0.00,0,'2025-03-15 18:05:07','2025-03-15 18:05:07'),
(126,'52','2025-03-15 18:05:30','Sales',1,'Bill #52 - Sale Revenue',0.00,1209.00,0,'2025-03-15 18:05:29','2025-03-15 18:05:29'),
(127,'52','2025-03-15 18:05:30','Bank Transfer',0,'Bill #52 - Bank Transfer Payment',1209.00,0.00,0,'2025-03-15 18:05:29','2025-03-15 18:05:29'),
(128,'53','2025-03-15 18:09:36','Sales',1,'Bill #53 - Sale Revenue',0.00,369.00,0,'2025-03-15 18:09:36','2025-03-15 18:09:36'),
(129,'53','2025-03-15 18:09:36','Cash',0,'Bill #53 - Cash Payment',369.00,0.00,0,'2025-03-15 18:09:36','2025-03-15 18:09:36'),
(130,'54','2025-03-15 18:09:54','Sales',1,'Bill #54 - Sale Revenue',0.00,2022.00,0,'2025-03-15 18:09:53','2025-03-15 18:09:53'),
(131,'54','2025-03-15 18:09:54','Cash',0,'Bill #54 - Cash Payment',2022.00,0.00,0,'2025-03-15 18:09:53','2025-03-15 18:09:53'),
(132,'','2025-03-15 18:10:42','Cash',0,'Customer Payment Received',519.00,0.00,51,'2025-03-15 18:10:41','2025-03-15 18:10:41'),
(133,'','2025-03-15 18:10:42','Account Recievable',1,'Credit Paid',0.00,519.00,51,'2025-03-15 18:10:41','2025-03-15 18:10:41'),
(134,'55','2025-05-01 16:33:38','Sales',1,'Bill #55 - Sale Revenue',0.00,942.00,0,'2025-05-01 16:33:37','2025-05-01 16:33:37'),
(135,'55','2025-05-01 16:33:38','Account Recievable',1,'Bill #55 - Credit Sale',942.00,0.00,0,'2025-05-01 16:33:37','2025-05-01 16:33:37'),
(136,'56','2025-05-01 16:33:40','Sales',1,'Bill #56 - Sale Revenue',0.00,942.00,0,'2025-05-01 16:33:40','2025-05-01 16:33:40'),
(137,'56','2025-05-01 16:33:40','Account Recievable',1,'Bill #56 - Credit Sale',942.00,0.00,0,'2025-05-01 16:33:40','2025-05-01 16:33:40'),
(138,'57','2025-05-01 16:34:01','Sales',1,'Bill #57 - Sale Revenue',0.00,369.00,0,'2025-05-01 16:34:01','2025-05-01 16:34:01'),
(139,'57','2025-05-01 16:34:01','Bank Transfer',0,'Bill #57 - Bank Transfer Payment',369.00,0.00,0,'2025-05-01 16:34:01','2025-05-01 16:34:01'),
(140,'','2025-05-26 14:24:00','Cash',0,'Customer Payment Received',942.00,0.00,55,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(141,'','2025-05-26 14:24:00','Account Recievable',1,'Credit Paid',0.00,942.00,55,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(142,'','2025-05-26 14:24:00','Cash',0,'Customer Payment Received',942.00,0.00,56,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(143,'','2025-05-26 14:24:00','Account Recievable',1,'Credit Paid',0.00,942.00,56,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(144,'58','2025-05-26 14:31:14','Sales',1,'Bill #58 - Sale Revenue',0.00,674.00,0,'2025-05-26 14:31:13','2025-05-26 14:31:13'),
(145,'58','2025-05-26 14:31:14','Account Recievable',1,'Bill #58 - Credit Sale',674.00,0.00,0,'2025-05-26 14:31:13','2025-05-26 14:31:13'),
(146,'59','2025-05-26 14:31:37','Sales',1,'Bill #59 - Sale Revenue',0.00,717.00,0,'2025-05-26 14:31:36','2025-05-26 14:31:36'),
(147,'59','2025-05-26 14:31:37','Account Recievable',1,'Bill #59 - Credit Sale',717.00,0.00,0,'2025-05-26 14:31:36','2025-05-26 14:31:36'),
(148,'60','2025-05-26 14:32:32','Sales',1,'Bill #60 - Sale Revenue',0.00,594.00,0,'2025-05-26 14:32:32','2025-05-26 14:32:32'),
(149,'60','2025-05-26 14:32:32','Account Recievable',1,'Bill #60 - Credit Sale',594.00,0.00,0,'2025-05-26 14:32:32','2025-05-26 14:32:32'),
(150,'61','2025-05-26 14:42:03','Sales',1,'Bill #61 - Sale Revenue',0.00,353.00,0,'2025-05-26 14:42:03','2025-05-26 14:42:03'),
(151,'61','2025-05-26 14:42:03','Account Recievable',1,'Bill #61 - Credit Sale',353.00,0.00,0,'2025-05-26 14:42:03','2025-05-26 14:42:03'),
(152,'62','2025-05-26 14:43:29','Sales',1,'Bill #62 - Sale Revenue',0.00,155.00,0,'2025-05-26 14:43:29','2025-05-26 14:43:29'),
(153,'62','2025-05-26 14:43:29','Account Recievable',1,'Bill #62 - Credit Sale',155.00,0.00,0,'2025-05-26 14:43:29','2025-05-26 14:43:29'),
(154,'63','2025-05-26 14:46:16','Sales',1,'Bill #63 - Sale Revenue',0.00,214.00,0,'2025-05-26 14:46:16','2025-05-26 14:46:16'),
(155,'63','2025-05-26 14:46:16','Cash',0,'Bill #63 - Cash Payment',214.00,0.00,0,'2025-05-26 14:46:16','2025-05-26 14:46:16'),
(156,'64','2025-05-26 14:57:43','Sales',1,'Bill #64 - Sale Revenue',0.00,332.00,0,'2025-05-26 14:57:43','2025-05-26 14:57:43'),
(157,'64','2025-05-26 14:57:43','Cash',0,'Bill #64 - Cash Payment',332.00,0.00,0,'2025-05-26 14:57:43','2025-05-26 14:57:43'),
(158,'65','2025-05-26 14:59:15','Sales',1,'Bill #65 - Sale Revenue',0.00,567.00,0,'2025-05-26 14:59:14','2025-05-26 14:59:14'),
(159,'65','2025-05-26 14:59:15','Cash',0,'Bill #65 - Cash Payment',567.00,0.00,0,'2025-05-26 14:59:14','2025-05-26 14:59:14'),
(160,'66','2025-05-26 15:01:43','Sales',1,'Bill #66 - Sale Revenue',0.00,54.00,0,'2025-05-26 15:01:43','2025-05-26 15:01:43'),
(161,'66','2025-05-26 15:01:43','Cash',0,'Bill #66 - Cash Payment',54.00,0.00,0,'2025-05-26 15:01:43','2025-05-26 15:01:43'),
(162,'67','2025-05-26 15:08:03','Sales',1,'Bill #67 - Sale Revenue',0.00,621.00,0,'2025-05-26 15:08:03','2025-05-26 15:08:03'),
(163,'67','2025-05-26 15:08:03','Cash',0,'Bill #67 - Cash Payment',621.00,0.00,0,'2025-05-26 15:08:03','2025-05-26 15:08:03'),
(164,'68','2025-05-26 15:10:10','Sales',1,'Bill #68 - Sale Revenue',0.00,54.00,0,'2025-05-26 15:10:10','2025-05-26 15:10:10'),
(165,'68','2025-05-26 15:10:10','Cash',0,'Bill #68 - Cash Payment',54.00,0.00,0,'2025-05-26 15:10:10','2025-05-26 15:10:10'),
(166,'69','2025-05-26 15:10:57','Sales',1,'Bill #69 - Sale Revenue',0.00,535.00,0,'2025-05-26 15:10:57','2025-05-26 15:10:57'),
(167,'69','2025-05-26 15:10:57','Cash',0,'Bill #69 - Cash Payment',535.00,0.00,0,'2025-05-26 15:10:57','2025-05-26 15:10:57'),
(168,'70','2025-05-26 18:11:40','Sales',1,'Bill #70 - Sale Revenue',0.00,155.00,0,'2025-05-26 18:11:40','2025-05-26 18:11:40'),
(169,'70','2025-05-26 18:11:40','Cash',0,'Bill #70 - Cash Payment',155.00,0.00,0,'2025-05-26 18:11:40','2025-05-26 18:11:40'),
(170,'71','2025-05-26 18:14:23','Sales',1,'Bill #71 - Sale Revenue',0.00,246.00,0,'2025-05-26 18:14:23','2025-05-26 18:14:23'),
(171,'71','2025-05-26 18:14:23','Cash',0,'Bill #71 - Cash Payment',246.00,0.00,0,'2025-05-26 18:14:23','2025-05-26 18:14:23'),
(172,'72','2025-05-26 18:24:26','Sales',1,'Bill #72 - Sale Revenue',0.00,535.00,0,'2025-05-26 18:24:26','2025-05-26 18:24:26'),
(173,'72','2025-05-26 18:24:26','Cash',0,'Bill #72 - Cash Payment',535.00,0.00,0,'2025-05-26 18:24:26','2025-05-26 18:24:26'),
(174,'73','2025-05-26 18:27:03','Sales',1,'Bill #73 - Sale Revenue',0.00,257.00,0,'2025-05-26 18:27:02','2025-05-26 18:27:02'),
(175,'73','2025-05-26 18:27:03','Cash',0,'Bill #73 - Cash Payment',257.00,0.00,0,'2025-05-26 18:27:02','2025-05-26 18:27:02'),
(176,'74','2025-05-26 18:27:56','Sales',1,'Bill #74 - Sale Revenue',0.00,246.00,0,'2025-05-26 18:27:56','2025-05-26 18:27:56'),
(177,'74','2025-05-26 18:27:56','Cash',0,'Bill #74 - Cash Payment',246.00,0.00,0,'2025-05-26 18:27:56','2025-05-26 18:27:56'),
(178,'75','2025-05-26 18:33:49','Sales',1,'Bill #75 - Sale Revenue',0.00,257.00,0,'2025-05-26 18:33:49','2025-05-26 18:33:49'),
(179,'75','2025-05-26 18:33:49','Cash',0,'Bill #75 - Cash Payment',257.00,0.00,0,'2025-05-26 18:33:49','2025-05-26 18:33:49'),
(180,'76','2025-05-27 15:42:49','Sales',1,'Bill #76 - Sale Revenue',0.00,246.00,0,'2025-05-27 15:42:49','2025-05-27 15:42:49'),
(181,'76','2025-05-27 15:42:49','Account Recievable',1,'Bill #76 - Credit Sale',246.00,0.00,0,'2025-05-27 15:42:49','2025-05-27 15:42:49'),
(182,'','2025-05-27 15:44:12','Cash',0,'Customer Payment Received',674.00,0.00,58,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(183,'','2025-05-27 15:44:12','Account Recievable',1,'Credit Paid',0.00,674.00,58,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(184,'','2025-05-27 15:44:12','Cash',0,'Customer Payment Received',717.00,0.00,59,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(185,'','2025-05-27 15:44:12','Account Recievable',1,'Credit Paid',0.00,717.00,59,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(186,'','2025-05-27 15:44:12','Cash',0,'Customer Payment Received',594.00,0.00,60,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(187,'','2025-05-27 15:44:12','Account Recievable',1,'Credit Paid',0.00,594.00,60,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(188,'','2025-05-27 15:44:12','Cash',0,'Customer Payment Received',15.00,0.00,61,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(189,'','2025-05-27 15:44:12','Account Recievable',1,'Credit Paid',0.00,15.00,61,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(190,'77','2025-05-27 16:21:59','Sales',1,'Bill #77 - Sale Revenue',0.00,364.00,0,'2025-05-27 16:21:58','2025-05-27 16:21:58'),
(191,'77','2025-05-27 16:21:59','Account Recievable',1,'Bill #77 - Credit Sale',364.00,0.00,0,'2025-05-27 16:21:58','2025-05-27 16:21:58'),
(192,'78','2025-05-27 16:22:34','Sales',1,'Bill #78 - Sale Revenue',0.00,599.00,0,'2025-05-27 16:22:33','2025-05-27 16:22:33'),
(193,'78','2025-05-27 16:22:34','Bank Transfer',0,'Bill #78 - Bank Transfer Payment',599.00,0.00,0,'2025-05-27 16:22:33','2025-05-27 16:22:33'),
(194,'','2025-05-27 16:24:03','Cash',0,'Customer Payment Received',155.00,0.00,62,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(195,'','2025-05-27 16:24:03','Account Recievable',1,'Credit Paid',0.00,155.00,62,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(196,'','2025-05-27 16:24:03','Cash',0,'Customer Payment Received',246.00,0.00,76,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(197,'','2025-05-27 16:24:03','Account Recievable',1,'Credit Paid',0.00,246.00,76,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(198,'','2025-05-27 16:24:03','Cash',0,'Customer Payment Received',364.00,0.00,77,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(199,'','2025-05-27 16:24:03','Account Recievable',1,'Credit Paid',0.00,364.00,77,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(200,'79','2025-05-28 15:37:25','Sales',1,'Bill #79 - Sale Revenue',0.00,385.00,0,'2025-05-28 15:37:25','2025-05-28 15:37:25'),
(201,'79','2025-05-28 15:37:25','Cash',0,'Bill #79 - Cash Payment',385.00,0.00,0,'2025-05-28 15:37:25','2025-05-28 15:37:25'),
(202,'501','2025-06-02 00:00:00','Purchase',1,'Auto ledger from stock entry',25820.00,0.00,NULL,'2025-06-02 15:52:27','2025-06-02 15:52:27'),
(203,'502','2025-06-02 00:00:00','Purchase',1,'Auto ledger from stock entry',1000.00,0.00,NULL,'2025-06-02 15:53:00','2025-06-02 15:53:00'),
(204,'503','2025-06-03 00:00:00','Purchase',1,'Final ledger entry from stock items',1100.00,0.00,NULL,'2025-06-02 15:54:17','2025-06-02 15:54:17'),
(205,'80','2025-06-03 14:45:06','Sales',1,'Bill #80 - Sale Revenue',0.00,433.00,0,'2025-06-03 14:45:06','2025-06-03 14:45:06'),
(206,'80','2025-06-03 14:45:06','Cash',0,'Bill #80 - Cash Payment',433.00,0.00,0,'2025-06-03 14:45:06','2025-06-03 14:45:06'),
(207,'81','2025-06-03 14:45:47','Sales',1,'Bill #81 - Sale Revenue',0.00,348.00,0,'2025-06-03 14:45:47','2025-06-03 14:45:47'),
(208,'81','2025-06-03 14:45:47','Cash',0,'Bill #81 - Cash Payment',348.00,0.00,0,'2025-06-03 14:45:47','2025-06-03 14:45:47'),
(209,'82','2025-06-03 14:46:13','Sales',1,'Bill #82 - Sale Revenue',0.00,369.00,0,'2025-06-03 14:46:12','2025-06-03 14:46:12'),
(210,'82','2025-06-03 14:46:13','Cash',0,'Bill #82 - Cash Payment',369.00,0.00,0,'2025-06-03 14:46:12','2025-06-03 14:46:12'),
(211,'504','2025-06-03 00:00:00','Purchase',1,'Final ledger entry from stock items',2250.00,0.00,NULL,'2025-06-03 14:50:03','2025-06-03 14:50:03'),
(212,'83','2025-06-03 17:13:02','Sales',1,'Bill #83 - Sale Revenue',0.00,295.00,0,'2025-06-03 17:13:01','2025-06-03 17:13:01'),
(213,'83','2025-06-03 17:13:02','Cash',0,'Bill #83 - Cash Payment',295.00,0.00,0,'2025-06-03 17:13:01','2025-06-03 17:13:01'),
(214,'84','2025-06-03 17:13:40','Sales',1,'Bill #84 - Sale Revenue',0.00,294.00,0,'2025-06-03 17:13:40','2025-06-03 17:13:40'),
(215,'84','2025-06-03 17:13:40','Cash',0,'Bill #84 - Cash Payment',294.00,0.00,0,'2025-06-03 17:13:40','2025-06-03 17:13:40'),
(216,'85','2025-06-03 17:32:44','Sales',1,'Bill #85 - Sale Revenue',0.00,492.00,0,'2025-06-03 17:32:43','2025-06-03 17:32:43'),
(217,'85','2025-06-03 17:32:44','Account Recievable',1,'Bill #85 - Credit Sale',492.00,0.00,0,'2025-06-03 17:32:43','2025-06-03 17:32:43'),
(218,'86','2025-06-03 17:41:55','Sales',1,'Bill #86 - Sale Revenue',0.00,118.00,0,'2025-06-03 17:41:54','2025-06-03 17:41:54'),
(219,'86','2025-06-03 17:41:55','Cash',0,'Bill #86 - Cash Payment',118.00,0.00,0,'2025-06-03 17:41:54','2025-06-03 17:41:54'),
(220,'87','2025-06-03 17:50:01','Sales',1,'Bill #87 - Sale Revenue',0.00,679.00,0,'2025-06-03 17:50:01','2025-06-03 17:50:01'),
(221,'87','2025-06-03 17:50:01','Cash',0,'Bill #87 - Cash Payment',679.00,0.00,0,'2025-06-03 17:50:01','2025-06-03 17:50:01'),
(222,'88','2025-06-03 17:50:12','Sales',1,'Bill #88 - Sale Revenue',0.00,679.00,0,'2025-06-03 17:50:12','2025-06-03 17:50:12'),
(223,'88','2025-06-03 17:50:12','Cash',0,'Bill #88 - Cash Payment',679.00,0.00,0,'2025-06-03 17:50:12','2025-06-03 17:50:12'),
(224,'89','2025-06-03 17:53:41','Sales',1,'Bill #89 - Sale Revenue',0.00,712.00,0,'2025-06-03 17:53:41','2025-06-03 17:53:41'),
(225,'89','2025-06-03 17:53:41','Cash',0,'Bill #89 - Cash Payment',712.00,0.00,0,'2025-06-03 17:53:41','2025-06-03 17:53:41'),
(226,'90','2025-06-03 17:54:54','Sales',1,'Bill #90 - Sale Revenue',0.00,567.00,0,'2025-06-03 17:54:54','2025-06-03 17:54:54'),
(227,'90','2025-06-03 17:54:54','Cash',0,'Bill #90 - Cash Payment',567.00,0.00,0,'2025-06-03 17:54:54','2025-06-03 17:54:54'),
(228,'91','2025-06-03 17:56:35','Sales',1,'Bill #91 - Sale Revenue',0.00,391.00,0,'2025-06-03 17:56:35','2025-06-03 17:56:35'),
(229,'91','2025-06-03 17:56:35','Cash',0,'Bill #91 - Cash Payment',391.00,0.00,0,'2025-06-03 17:56:35','2025-06-03 17:56:35'),
(230,'92','2025-06-03 17:57:51','Sales',1,'Bill #92 - Sale Revenue',0.00,342.00,0,'2025-06-03 17:57:50','2025-06-03 17:57:50'),
(231,'92','2025-06-03 17:57:51','Cash',0,'Bill #92 - Cash Payment',342.00,0.00,0,'2025-06-03 17:57:50','2025-06-03 17:57:50'),
(232,'93','2025-06-03 18:01:21','Sales',1,'Bill #93 - Sale Revenue',0.00,342.00,0,'2025-06-03 18:01:21','2025-06-03 18:01:21'),
(233,'93','2025-06-03 18:01:21','Cash',0,'Bill #93 - Cash Payment',342.00,0.00,0,'2025-06-03 18:01:21','2025-06-03 18:01:21'),
(234,'94','2025-06-03 18:01:45','Sales',1,'Bill #94 - Sale Revenue',0.00,342.00,0,'2025-06-03 18:01:44','2025-06-03 18:01:44'),
(235,'94','2025-06-03 18:01:45','Cash',0,'Bill #94 - Cash Payment',342.00,0.00,0,'2025-06-03 18:01:44','2025-06-03 18:01:44'),
(236,'95','2025-06-03 18:02:12','Sales',1,'Bill #95 - Sale Revenue',0.00,342.00,0,'2025-06-03 18:02:12','2025-06-03 18:02:12'),
(237,'95','2025-06-03 18:02:12','Cash',0,'Bill #95 - Cash Payment',342.00,0.00,0,'2025-06-03 18:02:12','2025-06-03 18:02:12'),
(238,'96','2025-06-03 18:06:16','Sales',1,'Bill #96 - Sale Revenue',0.00,1177.00,0,'2025-06-03 18:06:16','2025-06-03 18:06:16'),
(239,'96','2025-06-03 18:06:16','Cash',0,'Bill #96 - Cash Payment',1177.00,0.00,0,'2025-06-03 18:06:16','2025-06-03 18:06:16'),
(240,'','2025-06-03 18:28:44','Cash',0,'Customer Payment Received',492.00,0.00,85,'2025-06-03 18:28:44','2025-06-03 18:28:44'),
(241,'','2025-06-03 18:28:44','Account Recievable',1,'Credit Paid',0.00,492.00,85,'2025-06-03 18:28:44','2025-06-03 18:28:44'),
(242,'97','2025-06-04 16:11:19','Sales',1,'Bill #97 - Sale Revenue',0.00,1177.00,0,'2025-06-04 16:11:18','2025-06-04 16:11:18'),
(243,'97','2025-06-04 16:11:19','Cash',0,'Bill #97 - Cash Payment',1177.00,0.00,0,'2025-06-04 16:11:18','2025-06-04 16:11:18'),
(244,'98','2025-06-05 14:57:37','Sales',1,'Bill #98 - Sale Revenue',0.00,1177.00,0,'2025-06-05 14:57:37','2025-06-05 14:57:37'),
(245,'98','2025-06-05 14:57:37','Cash',0,'Bill #98 - Cash Payment',1177.00,0.00,0,'2025-06-05 14:57:37','2025-06-05 14:57:37'),
(246,'99','2025-06-05 15:29:13','Sales',1,'Bill #99 - Sale Revenue',0.00,364.00,0,'2025-06-05 15:29:12','2025-06-05 15:29:12'),
(247,'99','2025-06-05 15:29:13','Account Recievable',1,'Bill #99 - Credit Sale',364.00,0.00,0,'2025-06-05 15:29:12','2025-06-05 15:29:12'),
(248,'','2025-06-05 15:32:11','Cash',0,'Customer Payment Received',200.00,0.00,99,'2025-06-05 15:32:10','2025-06-05 15:32:10'),
(249,'','2025-06-05 15:32:11','Account Recievable',1,'Credit Paid',0.00,200.00,99,'2025-06-05 15:32:10','2025-06-05 15:32:10'),
(250,'505','2025-06-05 00:00:00','Purchase',1,'Final ledger entry from stock items',150.00,0.00,NULL,'2025-06-05 15:33:00','2025-06-05 15:33:00'),
(269,'','2025-06-07 15:44:53','Bank Account',0,'Supplier Payment - Debit',2000.00,0.00,55,'2025-06-07 15:44:53','2025-06-07 15:44:53'),
(270,'','2025-06-07 15:44:53','Accounts Payable',1,'Supplier Payment - Credit',0.00,2000.00,55,'2025-06-07 15:44:53','2025-06-07 15:44:53'),
(271,'','2025-06-07 15:45:22','Bank Account',0,'Supplier Payment - Debit',3000.00,0.00,0,'2025-06-07 15:45:21','2025-06-07 15:45:21'),
(272,'','2025-06-07 15:45:22','Accounts Payable',1,'Supplier Payment - Credit',0.00,3000.00,0,'2025-06-07 15:45:21','2025-06-07 15:45:21'),
(273,'','2025-06-07 15:47:08','Cash Account',0,'Supplier Payment - Debit',10000.00,0.00,0,'2025-06-07 15:47:07','2025-06-07 15:47:07'),
(274,'','2025-06-07 15:47:08','Accounts Payable',1,'Supplier Payment - Credit',0.00,10000.00,0,'2025-06-07 15:47:07','2025-06-07 15:47:07'),
(275,'','2025-06-07 15:48:52','Cash Account',0,'Supplier Payment - Debit',5000.00,0.00,0,'2025-06-07 15:48:52','2025-06-07 15:48:52'),
(276,'','2025-06-07 15:48:52','Accounts Payable',1,'Supplier Payment - Credit',0.00,5000.00,0,'2025-06-07 15:48:52','2025-06-07 15:48:52'),
(277,'100','2025-06-07 17:22:57','Sales',1,'Bill #100 - Sale Revenue',0.00,369.00,0,'2025-06-07 17:22:56','2025-06-07 17:22:56'),
(278,'100','2025-06-07 17:22:57','Account Recievable',1,'Bill #100 - Credit Sale',369.00,0.00,0,'2025-06-07 17:22:56','2025-06-07 17:22:56'),
(279,'','2025-06-07 17:24:17','Cash',0,'Customer Payment Received',300.00,0.00,100,'2025-06-07 17:24:17','2025-06-07 17:24:17'),
(280,'','2025-06-07 17:24:17','Account Recievable',1,'Credit Paid',0.00,300.00,100,'2025-06-07 17:24:17','2025-06-07 17:24:17'),
(281,'510','2025-06-07 00:00:00','Purchase',1,'Final ledger entry from stock items',1200.00,0.00,NULL,'2025-06-07 17:33:12','2025-06-07 17:33:12'),
(282,'101','2025-06-10 14:00:15','Sales',1,'Bill #101 - Sale Revenue',0.00,391.00,0,'2025-06-10 14:00:14','2025-06-10 14:00:14'),
(283,'101','2025-06-10 14:00:15','Account Recievable',1,'Bill #101 - Credit Sale',391.00,0.00,0,'2025-06-10 14:00:14','2025-06-10 14:00:14'),
(284,'102','2025-06-10 14:05:25','Sales',1,'Bill #102 - Sale Revenue',0.00,1632.00,0,'2025-06-10 14:05:25','2025-06-10 14:05:25'),
(285,'102','2025-06-10 14:05:25','Account Recievable',1,'Bill #102 - Credit Sale',1632.00,0.00,0,'2025-06-10 14:05:25','2025-06-10 14:05:25'),
(286,'103','2025-06-11 13:44:09','Sales',1,'Bill #103 - Sale Revenue',0.00,96.00,0,'2025-06-11 13:44:08','2025-06-11 13:44:08'),
(287,'103','2025-06-11 13:44:09','Cash',0,'Bill #103 - Cash Payment',96.00,0.00,0,'2025-06-11 13:44:08','2025-06-11 13:44:08'),
(288,'104','2025-06-11 16:42:15','Sales',1,'Bill #104 - Sale Revenue',0.00,125.00,0,'2025-06-11 16:42:15','2025-06-11 16:42:15'),
(289,'104','2025-06-11 16:42:15','Cash',0,'Bill #104 - Cash Payment',125.00,0.00,0,'2025-06-11 16:42:15','2025-06-11 16:42:15'),
(290,'105','2025-06-12 13:59:44','Sales',1,'Bill #105 - Sale Revenue',0.00,70.00,0,'2025-06-12 13:59:44','2025-06-12 13:59:44'),
(291,'105','2025-06-12 13:59:44','Cash',0,'Bill #105 - Cash Payment',70.00,0.00,0,'2025-06-12 13:59:44','2025-06-12 13:59:44'),
(292,'106','2025-06-12 15:36:04','Sales',1,'Bill #106 - Sale Revenue',0.00,90.00,0,'2025-06-12 15:36:03','2025-06-12 15:36:03'),
(293,'106','2025-06-12 15:36:04','Cash',0,'Bill #106 - Cash Payment',90.00,0.00,0,'2025-06-12 15:36:03','2025-06-12 15:36:03'),
(294,'107','2025-06-12 15:36:07','Sales',1,'Bill #107 - Sale Revenue',0.00,705.00,0,'2025-06-12 15:36:07','2025-06-12 15:36:07'),
(295,'107','2025-06-12 15:36:07','Cash',0,'Bill #107 - Cash Payment',705.00,0.00,0,'2025-06-12 15:36:07','2025-06-12 15:36:07'),
(296,'515','2025-06-11 00:00:00','Purchase',1,'Final ledger entry from stock items',3900.00,0.00,NULL,'2025-06-12 16:39:44','2025-06-12 16:39:44'),
(297,'516','2025-06-12 00:00:00','Purchase',2,'Final ledger entry from stock items',5000.00,0.00,NULL,'2025-06-12 16:42:38','2025-06-12 16:42:38'),
(298,'','2025-06-12 16:54:43','Cash Account',0,'Supplier Payment - Debit',6000.00,0.00,0,'2025-06-12 16:54:42','2025-06-12 16:54:42'),
(299,'','2025-06-12 16:54:43','Accounts Payable',2,'Supplier Payment - Credit',0.00,6000.00,0,'2025-06-12 16:54:42','2025-06-12 16:54:42'),
(300,'108','2025-06-12 17:49:10','Sales',1,'Bill #108 - Sale Revenue',0.00,1380.00,0,'2025-06-12 17:49:10','2025-06-12 17:49:10'),
(301,'108','2025-06-12 17:49:10','Cash',0,'Bill #108 - Cash Payment',1380.00,0.00,0,'2025-06-12 17:49:10','2025-06-12 17:49:10'),
(302,'1','2025-06-13 14:51:20','Sales',1,'Bill #1 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 14:51:19','2025-06-13 14:51:19'),
(303,'2','2025-06-13 15:20:01','Sales',1,'Bill #2 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:20:01','2025-06-13 15:20:01'),
(304,'3','2025-06-13 15:22:15','Sales',1,'Bill #3 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:22:14','2025-06-13 15:22:14'),
(305,'4','2025-06-13 15:31:02','Sales',1,'Bill #4 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:31:02','2025-06-13 15:31:02'),
(306,'5','2025-06-13 15:31:17','Sales',1,'Bill #5 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:31:17','2025-06-13 15:31:17'),
(307,'6','2025-06-13 15:31:52','Sales',1,'Bill #6 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:31:51','2025-06-13 15:31:51'),
(308,'7','2025-06-13 15:38:32','Sales',1,'Bill #7 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:38:31','2025-06-13 15:38:31'),
(309,'8','2025-06-13 15:43:00','Sales',1,'Bill #8 - Sale Revenue',0.00,0.00,NULL,'2025-06-13 15:43:00','2025-06-13 15:43:00'),
(310,'9','2025-06-13 15:47:45','Sales',1,'Bill #9 - Sale Revenue',0.00,340.00,NULL,'2025-06-13 15:47:45','2025-06-13 15:47:45'),
(311,'10','2025-06-13 16:13:17','Sales',1,'Bill #10 - Sale Revenue',0.00,100.00,NULL,'2025-06-13 16:13:17','2025-06-13 16:13:17'),
(312,'10','2025-06-13 16:13:17','Account Receivable',0,'Bill #10 - Credit Sale',100.00,0.00,NULL,'2025-06-13 16:13:17','2025-06-13 16:13:17'),
(313,'11','2025-06-13 16:15:23','Sales',1,'Bill #11 - Sale Revenue',0.00,260.00,NULL,'2025-06-13 16:15:23','2025-06-13 16:15:23'),
(314,'11','2025-06-13 16:15:23','Account Receivable',0,'Bill #11 - Credit Sale',260.00,0.00,NULL,'2025-06-13 16:15:23','2025-06-13 16:15:23'),
(315,'109','2025-06-13 17:52:23','Sales',1,'Bill #109 - Sale Revenue',0.00,915.00,0,'2025-06-13 17:52:22','2025-06-13 17:52:22'),
(316,'109','2025-06-13 17:52:23','Cash',0,'Bill #109 - Cash Payment',915.00,0.00,0,'2025-06-13 17:52:22','2025-06-13 17:52:22'),
(317,'110','2025-06-13 17:56:59','Sales',1,'Bill #110 - Sale Revenue',0.00,580.00,0,'2025-06-13 17:56:59','2025-06-13 17:56:59'),
(318,'110','2025-06-13 17:56:59','Cash',0,'Bill #110 - Cash Payment',580.00,0.00,0,'2025-06-13 17:56:59','2025-06-13 17:56:59'),
(319,'12','2025-06-13 18:14:26','Sales',1,'Bill #12 - Sale Revenue',0.00,140.00,NULL,'2025-06-13 18:14:25','2025-06-13 18:14:25'),
(320,'12','2025-06-13 18:14:26','Account Receivable',0,'Bill #12 - Credit Sale',140.00,0.00,NULL,'2025-06-13 18:14:25','2025-06-13 18:14:25'),
(321,'13','2025-06-13 18:14:51','Sales',1,'Bill #13 - Sale Revenue',0.00,130.00,NULL,'2025-06-13 18:14:51','2025-06-13 18:14:51'),
(322,'13','2025-06-13 18:14:51','Account Receivable',0,'Bill #13 - Credit Sale',130.00,0.00,NULL,'2025-06-13 18:14:51','2025-06-13 18:14:51'),
(323,'14','2025-06-17 11:55:33','Sales',1,'Bill #14 - Sale Revenue',0.00,390.00,NULL,'2025-06-17 11:55:33','2025-06-17 11:55:33'),
(324,'14','2025-06-17 11:55:33','Account Receivable',0,'Bill #14 - Credit Sale',390.00,0.00,NULL,'2025-06-17 11:55:33','2025-06-17 11:55:33'),
(325,'','2025-06-17 13:38:37','Cash',0,'Customer Payment Received',0.00,0.00,56,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(326,'','2025-06-17 13:38:37','Account Recievable',1,'Credit Paid',0.00,0.00,56,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(327,'','2025-06-17 13:38:37','Cash',0,'Customer Payment Received',391.00,0.00,101,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(328,'','2025-06-17 13:38:37','Account Recievable',1,'Credit Paid',0.00,391.00,101,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(329,'','2025-06-17 13:38:37','Cash',0,'Customer Payment Received',609.00,0.00,102,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(330,'','2025-06-17 13:38:37','Account Recievable',1,'Credit Paid',0.00,609.00,102,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(331,'111','2025-06-17 13:46:37','Sales',1,'Bill #111 - Sale Revenue',0.00,530.00,0,'2025-06-17 13:46:37','2025-06-17 13:46:37'),
(332,'111','2025-06-17 13:46:37','Account Recievable',1,'Bill #111 - Credit Sale',530.00,0.00,0,'2025-06-17 13:46:37','2025-06-17 13:46:37'),
(333,'112','2025-06-17 13:46:42','Sales',1,'Bill #112 - Sale Revenue',0.00,1100.00,0,'2025-06-17 13:46:41','2025-06-17 13:46:41'),
(334,'112','2025-06-17 13:46:42','Account Recievable',1,'Bill #112 - Credit Sale',1100.00,0.00,0,'2025-06-17 13:46:41','2025-06-17 13:46:41'),
(335,'','2025-06-17 13:47:04','Bank',0,'Customer Payment Received',530.00,0.00,111,'2025-06-17 13:47:03','2025-06-17 13:47:03'),
(336,'','2025-06-17 13:47:04','Account Recievable',1,'Credit Paid',0.00,530.00,111,'2025-06-17 13:47:03','2025-06-17 13:47:03'),
(337,'','2025-06-17 13:47:04','Bank',0,'Customer Payment Received',70.00,0.00,112,'2025-06-17 13:47:03','2025-06-17 13:47:03'),
(338,'','2025-06-17 13:47:04','Account Recievable',1,'Credit Paid',0.00,70.00,112,'2025-06-17 13:47:03','2025-06-17 13:47:03'),
(339,'113','2025-06-17 14:19:27','Sales',1,'Bill #113 - Sale Revenue',0.00,755.00,0,'2025-06-17 14:19:27','2025-06-17 14:19:27'),
(340,'113','2025-06-17 14:19:27','Account Recievable',1,'Bill #113 - Credit Sale',755.00,0.00,0,'2025-06-17 14:19:27','2025-06-17 14:19:27'),
(341,'','2025-06-17 14:56:38','Bank',0,'Customer Payment Received',755.00,0.00,113,'2025-06-17 14:56:38','2025-06-17 14:56:38'),
(342,'','2025-06-17 14:56:38','Account Recievable',1,'Credit Paid',0.00,755.00,113,'2025-06-17 14:56:38','2025-06-17 14:56:38'),
(343,'','2025-06-17 14:58:22','Bank',0,'Customer Payment Received',0.00,0.00,1,'2025-06-17 14:58:22','2025-06-17 14:58:22'),
(344,'','2025-06-17 14:58:22','Account Recievable',2,'Credit Paid',0.00,0.00,1,'2025-06-17 14:58:22','2025-06-17 14:58:22'),
(345,'','2025-06-17 14:58:22','Bank',0,'Customer Payment Received',100.00,0.00,4,'2025-06-17 14:58:22','2025-06-17 14:58:22'),
(346,'','2025-06-17 14:58:22','Account Recievable',2,'Credit Paid',0.00,100.00,4,'2025-06-17 14:58:22','2025-06-17 14:58:22'),
(347,'114','2025-06-18 12:42:37','Sales',1,'Bill #114 - Sale Revenue',0.00,1225.00,0,'2025-06-18 12:42:37','2025-06-18 12:42:37'),
(348,'114','2025-06-18 12:42:37','Cash',0,'Bill #114 - Cash Payment',1225.00,0.00,0,'2025-06-18 12:42:37','2025-06-18 12:42:37'),
(349,'115','2025-06-21 08:00:33','Sales',1,'Bill #115 - Sale Revenue',0.00,180.00,0,'2025-06-21 15:00:33','2025-06-21 15:00:33'),
(350,'115','2025-06-21 08:00:33','Cash',0,'Bill #115 - Cash Payment',180.00,0.00,0,'2025-06-21 15:00:33','2025-06-21 15:00:33'),
(351,'116','2025-06-21 08:01:39','Sales',1,'Bill #116 - Sale Revenue',0.00,2214.00,0,'2025-06-21 15:01:39','2025-06-21 15:01:39'),
(352,'116','2025-06-21 08:01:39','Cash',0,'Bill #116 - Cash Payment',2214.00,0.00,0,'2025-06-21 15:01:39','2025-06-21 15:01:39'),
(353,'117','2025-06-21 09:00:32','Sales',1,'Bill #117 - Sale Revenue',0.00,700.00,0,'2025-06-21 16:00:32','2025-06-21 16:00:32'),
(354,'117','2025-06-21 09:00:32','Cash',0,'Bill #117 - Cash Payment',700.00,0.00,0,'2025-06-21 16:00:32','2025-06-21 16:00:32'),
(355,'118','2025-06-21 09:01:20','Sales',1,'Bill #118 - Sale Revenue',0.00,2395.00,0,'2025-06-21 16:01:20','2025-06-21 16:01:20'),
(356,'118','2025-06-21 09:01:20','Cash',0,'Bill #118 - Cash Payment',2395.00,0.00,0,'2025-06-21 16:01:20','2025-06-21 16:01:20'),
(357,'119','2025-06-21 10:14:27','Sales',1,'Bill #119 - Sale Revenue',0.00,525.00,0,'2025-06-21 17:14:27','2025-06-21 17:14:27'),
(358,'119','2025-06-21 10:14:27','Cash',0,'Bill #119 - Cash Payment',525.00,0.00,0,'2025-06-21 17:14:27','2025-06-21 17:14:27'),
(359,'15','2025-06-21 10:15:54','Sales',1,'Bill #15 - Sale Revenue',0.00,1725.00,NULL,'2025-06-21 17:15:54','2025-06-21 17:15:54'),
(360,'15','2025-06-21 10:15:54','Account Receivable',0,'Bill #15 - Credit Sale',1725.00,0.00,NULL,'2025-06-21 17:15:54','2025-06-21 17:15:54'),
(361,'16','2025-06-21 10:22:31','Sales',1,'Bill #16 - Sale Revenue',0.00,240.00,NULL,'2025-06-21 17:22:31','2025-06-21 17:22:31'),
(362,'16','2025-06-21 10:22:31','Account Receivable',0,'Bill #16 - Credit Sale',240.00,0.00,NULL,'2025-06-21 17:22:31','2025-06-21 17:22:31'),
(363,'17','2025-06-21 10:26:30','Sales',1,'Bill #17 - Sale Revenue',0.00,180.00,NULL,'2025-06-21 17:26:30','2025-06-21 17:26:30'),
(364,'17','2025-06-21 10:26:30','Account Receivable',0,'Bill #17 - Credit Sale',180.00,0.00,NULL,'2025-06-21 17:26:30','2025-06-21 17:26:30'),
(365,'120','2025-06-23 06:05:17','Sales',1,'Bill #120 - Sale Revenue',0.00,6160.00,0,'2025-06-23 13:05:17','2025-06-23 13:05:17'),
(366,'120','2025-06-23 06:05:17','Account Recievable',1,'Bill #120 - Credit Sale',6160.00,0.00,0,'2025-06-23 13:05:17','2025-06-23 13:05:17'),
(367,'','2025-06-23 06:05:52','Cash',0,'Customer Payment Received',2000.00,0.00,120,'2025-06-23 13:05:52','2025-06-23 13:05:52'),
(368,'','2025-06-23 06:05:52','Account Recievable',1,'Credit Paid',0.00,2000.00,120,'2025-06-23 13:05:52','2025-06-23 13:05:52'),
(369,'555','2025-06-23 00:00:00','Purchase',2,'Final ledger entry from stock items',350.00,0.00,NULL,'2025-06-23 16:13:24','2025-06-23 16:13:24'),
(370,'','2025-06-23 09:13:41','Cash Account',0,'Supplier Payment - Debit',5000.00,0.00,0,'2025-06-23 16:13:41','2025-06-23 16:13:41'),
(371,'','2025-06-23 09:13:41','Accounts Payable',2,'Supplier Payment - Credit',0.00,5000.00,0,'2025-06-23 16:13:41','2025-06-23 16:13:41'),
(372,'','2025-06-23 09:14:22','Bank Account',0,'Supplier Payment - Debit',4500.00,0.00,0,'2025-06-23 16:14:22','2025-06-23 16:14:22'),
(373,'','2025-06-23 09:14:22','Accounts Payable',2,'Supplier Payment - Credit',0.00,4500.00,0,'2025-06-23 16:14:22','2025-06-23 16:14:22'),
(374,'121','2025-06-23 15:40:35','Sales',1,'Bill #121 - Sale Revenue',0.00,665.00,0,'2025-06-23 22:40:35','2025-06-23 22:40:35'),
(375,'121','2025-06-23 15:40:35','Account Recievable',1,'Bill #121 - Credit Sale',665.00,0.00,0,'2025-06-23 22:40:35','2025-06-23 22:40:35'),
(376,'','2025-06-23 15:41:02','Cash',0,'Customer Payment Received',665.00,0.00,121,'2025-06-23 22:41:02','2025-06-23 22:41:02'),
(377,'','2025-06-23 15:41:02','Account Recievable',1,'Credit Paid',0.00,665.00,121,'2025-06-23 22:41:02','2025-06-23 22:41:02'),
(378,'1561516','2025-06-25 00:00:00','Purchase',1,'Final ledger entry from stock items',4000.00,0.00,NULL,'2025-06-24 18:46:28','2025-06-24 18:46:28'),
(379,'122','2025-06-24 11:47:04','Sales',1,'Bill #122 - Sale Revenue',0.00,325.00,0,'2025-06-24 18:47:04','2025-06-24 18:47:04'),
(380,'122','2025-06-24 11:47:04','Cash',0,'Bill #122 - Cash Payment',325.00,0.00,0,'2025-06-24 18:47:04','2025-06-24 18:47:04'),
(381,'123','2025-06-26 06:14:47','Sales',1,'Bill #123 - Sale Revenue',0.00,550.00,0,'2025-06-26 13:14:47','2025-06-26 13:14:47'),
(382,'123','2025-06-26 06:14:47','Account Recievable',1,'Bill #123 - Credit Sale',550.00,0.00,0,'2025-06-26 13:14:47','2025-06-26 13:14:47'),
(383,'124','2025-07-08 08:18:16','Sales',1,'Bill #124 - Sale Revenue',0.00,590.00,0,'2025-07-08 15:18:16','2025-07-08 15:18:16'),
(384,'124','2025-07-08 08:18:16','Cash',0,'Bill #124 - Cash Payment',590.00,0.00,0,'2025-07-08 15:18:16','2025-07-08 15:18:16'),
(385,'125','2025-07-08 08:20:16','Sales',1,'Bill #125 - Sale Revenue',0.00,120.00,0,'2025-07-08 15:20:16','2025-07-08 15:20:16'),
(386,'126','2025-07-08 08:25:37','Sales',1,'Bill #126 - Sale Revenue',0.00,80.00,0,'2025-07-08 15:25:37','2025-07-08 15:25:37'),
(387,'127','2025-07-08 08:28:07','Sales',1,'Bill #127 - Sale Revenue',0.00,120.00,0,'2025-07-08 15:28:07','2025-07-08 15:28:07'),
(388,'128','2025-07-08 08:29:06','Sales',1,'Bill #128 - Sale Revenue',0.00,120.00,0,'2025-07-08 15:29:06','2025-07-08 15:29:06'),
(389,'129','2025-07-08 08:31:00','Sales',1,'Bill #129 - Sale Revenue',0.00,50.00,0,'2025-07-08 15:31:00','2025-07-08 15:31:00'),
(390,'130','2025-07-08 08:38:20','Sales',1,'Bill #130 - Sale Revenue',0.00,150.00,0,'2025-07-08 15:38:20','2025-07-08 15:38:20'),
(391,'131','2025-07-08 08:40:42','Sales',1,'Bill #131 - Sale Revenue',0.00,280.00,0,'2025-07-08 15:40:42','2025-07-08 15:40:42'),
(392,'132','2025-07-08 08:43:19','Sales',1,'Bill #132 - Sale Revenue',0.00,570.00,0,'2025-07-08 15:43:19','2025-07-08 15:43:19'),
(393,'133','2025-07-08 09:23:27','Sales',1,'Bill #133 - Sale Revenue',0.00,120.00,0,'2025-07-08 16:23:27','2025-07-08 16:23:27'),
(394,'134','2025-07-08 09:25:25','Sales',1,'Bill #134 - Sale Revenue',0.00,80.00,0,'2025-07-08 16:25:25','2025-07-08 16:25:25'),
(395,'135','2025-07-08 10:04:22','Sales',1,'Bill #135 - Sale Revenue',0.00,170.00,0,'2025-07-08 17:04:22','2025-07-08 17:04:22'),
(396,'136','2025-07-08 15:25:10','Sales',1,'Bill #136 - Sale Revenue',0.00,250.00,0,'2025-07-08 22:25:10','2025-07-08 22:25:10'),
(397,'136','2025-07-08 15:25:10','Cash',0,'Bill #136 - Cash Payment',250.00,0.00,0,'2025-07-08 22:25:10','2025-07-08 22:25:10'),
(398,'137','2025-07-08 15:44:03','Sales',1,'Bill #137 - Sale Revenue',0.00,380.00,0,'2025-07-08 22:44:03','2025-07-08 22:44:03'),
(399,'137','2025-07-08 15:44:03','Cash',0,'Bill #137 - Cash Payment',380.00,0.00,0,'2025-07-08 22:44:03','2025-07-08 22:44:03'),
(400,'138','2025-07-08 15:45:29','Sales',1,'Bill #138 - Sale Revenue',0.00,380.00,0,'2025-07-08 22:45:29','2025-07-08 22:45:29'),
(401,'138','2025-07-08 15:45:29','Cash',0,'Bill #138 - Cash Payment',380.00,0.00,0,'2025-07-08 22:45:29','2025-07-08 22:45:29'),
(402,'139','2025-07-08 15:50:05','Sales',1,'Bill #139 - Sale Revenue',0.00,250.00,0,'2025-07-08 22:50:05','2025-07-08 22:50:05'),
(403,'140','2025-07-08 15:58:40','Sales',1,'Bill #140 - Sale Revenue',0.00,410.00,0,'2025-07-08 22:58:40','2025-07-08 22:58:40'),
(404,'141','2025-07-08 16:01:56','Sales',1,'Bill #141 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:01:56','2025-07-08 23:01:56'),
(405,'141','2025-07-08 16:01:56','Cash',0,'Bill #141 - Cash Payment',120.00,0.00,0,'2025-07-08 23:01:56','2025-07-08 23:01:56'),
(406,'142','2025-07-08 16:03:24','Sales',1,'Bill #142 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:03:24','2025-07-08 23:03:24'),
(407,'142','2025-07-08 16:03:24','Cash',0,'Bill #142 - Cash Payment',120.00,0.00,0,'2025-07-08 23:03:24','2025-07-08 23:03:24'),
(408,'143','2025-07-08 16:03:37','Sales',1,'Bill #143 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:03:37','2025-07-08 23:03:37'),
(409,'143','2025-07-08 16:03:37','Cash',0,'Bill #143 - Cash Payment',120.00,0.00,0,'2025-07-08 23:03:37','2025-07-08 23:03:37'),
(410,'144','2025-07-08 16:04:40','Sales',1,'Bill #144 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:04:40','2025-07-08 23:04:40'),
(411,'144','2025-07-08 16:04:40','Cash',0,'Bill #144 - Cash Payment',120.00,0.00,0,'2025-07-08 23:04:40','2025-07-08 23:04:40'),
(412,'145','2025-07-08 16:05:30','Sales',1,'Bill #145 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:05:30','2025-07-08 23:05:30'),
(413,'145','2025-07-08 16:05:30','Cash',0,'Bill #145 - Cash Payment',120.00,0.00,0,'2025-07-08 23:05:30','2025-07-08 23:05:30'),
(414,'146','2025-07-08 16:06:37','Sales',1,'Bill #146 - Sale Revenue',0.00,120.00,0,'2025-07-08 23:06:37','2025-07-08 23:06:37'),
(415,'146','2025-07-08 16:06:37','Cash',0,'Bill #146 - Cash Payment',120.00,0.00,0,'2025-07-08 23:06:37','2025-07-08 23:06:37'),
(416,'147','2025-07-08 16:08:50','Sales',1,'Bill #147 - Sale Revenue',0.00,206.00,0,'2025-07-08 23:08:50','2025-07-08 23:08:50'),
(417,'147','2025-07-08 16:08:50','Cash',0,'Bill #147 - Cash Payment',206.00,0.00,0,'2025-07-08 23:08:50','2025-07-08 23:08:50'),
(418,'148','2025-07-08 16:12:23','Sales',1,'Bill #148 - Sale Revenue',0.00,520.00,0,'2025-07-08 23:12:23','2025-07-08 23:12:23'),
(419,'148','2025-07-08 16:12:23','Cash',0,'Bill #148 - Cash Payment',520.00,0.00,0,'2025-07-08 23:12:23','2025-07-08 23:12:23'),
(420,'149','2025-07-08 16:17:40','Sales',1,'Bill #149 - Sale Revenue',0.00,65.00,0,'2025-07-08 23:17:40','2025-07-08 23:17:40'),
(421,'149','2025-07-08 16:17:40','Cash',0,'Bill #149 - Cash Payment',65.00,0.00,0,'2025-07-08 23:17:40','2025-07-08 23:17:40'),
(422,'150','2025-07-08 16:20:54','Sales',1,'Bill #150 - Sale Revenue',0.00,25.00,0,'2025-07-08 23:20:54','2025-07-08 23:20:54'),
(423,'150','2025-07-08 16:20:54','Cash',0,'Bill #150 - Cash Payment',25.00,0.00,0,'2025-07-08 23:20:54','2025-07-08 23:20:54'),
(424,'151','2025-07-08 16:21:17','Sales',1,'Bill #151 - Sale Revenue',0.00,305.00,0,'2025-07-08 23:21:17','2025-07-08 23:21:17'),
(425,'151','2025-07-08 16:21:17','Cash',0,'Bill #151 - Cash Payment',305.00,0.00,0,'2025-07-08 23:21:17','2025-07-08 23:21:17'),
(426,'152','2025-07-08 16:54:54','Sales',1,'Bill #152 - Sale Revenue',0.00,856.00,0,'2025-07-08 23:54:54','2025-07-08 23:54:54'),
(427,'152','2025-07-08 16:54:54','Cash',0,'Bill #152 - Cash Payment',856.00,0.00,0,'2025-07-08 23:54:54','2025-07-08 23:54:54'),
(428,'153','2025-07-09 03:23:14','Sales',1,'Bill #153 - Sale Revenue',0.00,1616.00,0,'2025-07-09 10:23:14','2025-07-09 10:23:14'),
(429,'153','2025-07-09 03:23:14','Cash',0,'Bill #153 - Cash Payment',1616.00,0.00,0,'2025-07-09 10:23:14','2025-07-09 10:23:14'),
(430,'154','2025-07-09 03:26:30','Sales',1,'Bill #154 - Sale Revenue',0.00,1280.00,0,'2025-07-09 10:26:30','2025-07-09 10:26:30'),
(431,'154','2025-07-09 03:26:30','Cash',0,'Bill #154 - Cash Payment',1280.00,0.00,0,'2025-07-09 10:26:30','2025-07-09 10:26:30'),
(432,'155','2025-07-09 06:06:46','Sales',1,'Bill #155 - Sale Revenue',0.00,2000.00,0,'2025-07-09 13:06:46','2025-07-09 13:06:46'),
(433,'156','2025-07-09 06:10:21','Sales',1,'Bill #156 - Sale Revenue',0.00,1800.00,0,'2025-07-09 13:10:21','2025-07-09 13:10:21'),
(434,'156','2025-07-09 06:10:21','Cash',0,'Bill #156 - Cash Payment',1800.00,0.00,0,'2025-07-09 13:10:21','2025-07-09 13:10:21'),
(435,'157','2025-07-09 06:10:35','Sales',1,'Bill #157 - Sale Revenue',0.00,520.00,0,'2025-07-09 13:10:35','2025-07-09 13:10:35'),
(436,'158','2025-07-09 06:15:18','Sales',1,'Bill #158 - Sale Revenue',0.00,580.00,0,'2025-07-09 13:15:18','2025-07-09 13:15:18'),
(437,'158','2025-07-09 06:15:18','Account Recievable',14,'Bill #158 - Credit Sale',580.00,0.00,0,'2025-07-09 13:15:18','2025-07-09 13:15:18'),
(438,'','2025-07-09 06:19:19','Cash',0,'Customer Payment Received',300.00,0.00,158,'2025-07-09 13:19:19','2025-07-09 13:19:19'),
(439,'','2025-07-09 06:19:19','Account Recievable',14,'Credit Paid',0.00,300.00,158,'2025-07-09 13:19:19','2025-07-09 13:19:19'),
(440,'159','2025-07-09 06:22:40','Sales',1,'Bill #159 - Sale Revenue',0.00,1680.00,0,'2025-07-09 13:22:40','2025-07-09 13:22:40'),
(441,'159','2025-07-09 06:22:40','Cash',0,'Bill #159 - Cash Payment',1680.00,0.00,0,'2025-07-09 13:22:40','2025-07-09 13:22:40'),
(442,'160','2025-07-09 06:38:43','Sales',1,'Bill #160 - Sale Revenue',0.00,1091.00,0,'2025-07-09 13:38:43','2025-07-09 13:38:43'),
(443,'160','2025-07-09 06:38:43','Cash',0,'Bill #160 - Cash Payment',1091.00,0.00,0,'2025-07-09 13:38:43','2025-07-09 13:38:43'),
(444,'161','2025-07-09 06:44:35','Sales',1,'Bill #161 - Sale Revenue',0.00,1412.00,0,'2025-07-09 13:44:35','2025-07-09 13:44:35'),
(445,'161','2025-07-09 06:44:35','Cash',0,'Bill #161 - Cash Payment',1412.00,0.00,0,'2025-07-09 13:44:35','2025-07-09 13:44:35'),
(446,'162','2025-07-09 06:48:46','Sales',1,'Bill #162 - Sale Revenue',0.00,556.00,0,'2025-07-09 13:48:46','2025-07-09 13:48:46'),
(447,'162','2025-07-09 06:48:46','Cash',0,'Bill #162 - Cash Payment',556.00,0.00,0,'2025-07-09 13:48:46','2025-07-09 13:48:46'),
(448,'163','2025-07-09 06:48:55','Sales',1,'Bill #163 - Sale Revenue',0.00,556.00,0,'2025-07-09 13:48:55','2025-07-09 13:48:55'),
(449,'163','2025-07-09 06:48:55','Cash',0,'Bill #163 - Cash Payment',556.00,0.00,0,'2025-07-09 13:48:55','2025-07-09 13:48:55'),
(450,'164','2025-07-09 06:49:05','Sales',1,'Bill #164 - Sale Revenue',0.00,556.00,0,'2025-07-09 13:49:05','2025-07-09 13:49:05'),
(451,'164','2025-07-09 06:49:05','Cash',0,'Bill #164 - Cash Payment',556.00,0.00,0,'2025-07-09 13:49:05','2025-07-09 13:49:05'),
(452,'165','2025-07-09 06:49:18','Sales',1,'Bill #165 - Sale Revenue',0.00,1113.00,0,'2025-07-09 13:49:18','2025-07-09 13:49:18'),
(453,'165','2025-07-09 06:49:18','Cash',0,'Bill #165 - Cash Payment',1113.00,0.00,0,'2025-07-09 13:49:18','2025-07-09 13:49:18'),
(454,'166','2025-07-09 06:51:19','Sales',1,'Bill #166 - Sale Revenue',0.00,520.00,0,'2025-07-09 13:51:19','2025-07-09 13:51:19'),
(455,'166','2025-07-09 06:51:19','Cash',0,'Bill #166 - Cash Payment',520.00,0.00,0,'2025-07-09 13:51:19','2025-07-09 13:51:19'),
(456,'167','2025-07-11 06:44:04','Sales',1,'Bill #167 - Sale Revenue',0.00,1440.00,0,'2025-07-11 13:44:04','2025-07-11 13:44:04'),
(457,'167','2025-07-11 06:44:04','Cash',0,'Bill #167 - Cash Payment',1440.00,0.00,0,'2025-07-11 13:44:04','2025-07-11 13:44:04'),
(458,'168','2025-07-11 07:28:05','Sales',1,'Bill #168 - Sale Revenue',0.00,2442.00,0,'2025-07-11 14:28:05','2025-07-11 14:28:05'),
(459,'168','2025-07-11 07:28:05','Cash',0,'Bill #168 - Cash Payment',2442.00,0.00,0,'2025-07-11 14:28:05','2025-07-11 14:28:05'),
(460,'169','2025-07-11 07:38:04','Sales',1,'Bill #169 - Sale Revenue',0.00,2413.00,0,'2025-07-11 14:38:04','2025-07-11 14:38:04'),
(461,'169','2025-07-11 07:38:04','Cash',0,'Bill #169 - Cash Payment',2413.00,0.00,0,'2025-07-11 14:38:04','2025-07-11 14:38:04'),
(462,'170','2025-07-11 07:48:04','Sales',1,'Bill #170 - Sale Revenue',0.00,535.00,0,'2025-07-11 14:48:04','2025-07-11 14:48:04'),
(463,'170','2025-07-11 07:48:04','Cash',0,'Bill #170 - Cash Payment',535.00,0.00,0,'2025-07-11 14:48:04','2025-07-11 14:48:04'),
(464,'171','2025-07-11 07:55:10','Sales',1,'Bill #171 - Sale Revenue',0.00,963.00,0,'2025-07-11 14:55:10','2025-07-11 14:55:10'),
(465,'171','2025-07-11 07:55:10','Cash',0,'Bill #171 - Cash Payment',963.00,0.00,0,'2025-07-11 14:55:10','2025-07-11 14:55:10'),
(466,'172','2025-07-11 08:09:12','Sales',1,'Bill #172 - Sale Revenue',0.00,1434.00,0,'2025-07-11 15:09:12','2025-07-11 15:09:12'),
(467,'172','2025-07-11 08:09:12','Cash',0,'Bill #172 - Cash Payment',1434.00,0.00,0,'2025-07-11 15:09:12','2025-07-11 15:09:12'),
(468,'173','2025-07-11 08:14:38','Sales',1,'Bill #173 - Sale Revenue',0.00,1113.00,0,'2025-07-11 15:14:38','2025-07-11 15:14:38'),
(469,'173','2025-07-11 08:14:38','Cash',0,'Bill #173 - Cash Payment',1113.00,0.00,0,'2025-07-11 15:14:38','2025-07-11 15:14:38'),
(470,'174','2025-07-11 09:49:26','Sales',1,'Bill #174 - Sale Revenue',0.00,1626.00,0,'2025-07-11 16:49:26','2025-07-11 16:49:26'),
(471,'174','2025-07-11 09:49:26','Cash',0,'Bill #174 - Cash Payment',1626.00,0.00,0,'2025-07-11 16:49:26','2025-07-11 16:49:26'),
(472,'175','2025-07-11 09:52:23','Sales',1,'Bill #175 - Sale Revenue',0.00,1091.00,0,'2025-07-11 16:52:23','2025-07-11 16:52:23'),
(473,'175','2025-07-11 09:52:23','Cash',0,'Bill #175 - Cash Payment',1091.00,0.00,0,'2025-07-11 16:52:23','2025-07-11 16:52:23'),
(474,'176','2025-07-11 10:46:03','Sales',1,'Bill #176 - Sale Revenue',0.00,3606.00,0,'2025-07-11 17:46:03','2025-07-11 17:46:03'),
(475,'176','2025-07-11 10:46:03','Cash',0,'Bill #176 - Cash Payment',3606.00,0.00,0,'2025-07-11 17:46:03','2025-07-11 17:46:03'),
(476,'177','2025-07-11 10:48:48','Sales',1,'Bill #177 - Sale Revenue',0.00,2547.00,0,'2025-07-11 17:48:48','2025-07-11 17:48:48'),
(477,'177','2025-07-11 10:48:48','Cash',0,'Bill #177 - Cash Payment',2547.00,0.00,0,'2025-07-11 17:48:48','2025-07-11 17:48:48'),
(478,'178','2025-07-11 10:51:22','Sales',1,'Bill #178 - Sale Revenue',0.00,1006.00,0,'2025-07-11 17:51:22','2025-07-11 17:51:22'),
(479,'178','2025-07-11 10:51:22','Cash',0,'Bill #178 - Cash Payment',1006.00,0.00,0,'2025-07-11 17:51:22','2025-07-11 17:51:22'),
(480,'179','2025-07-11 12:03:13','Sales',1,'Bill #179 - Sale Revenue',0.00,1113.00,0,'2025-07-11 19:03:13','2025-07-11 19:03:13'),
(481,'179','2025-07-11 12:03:13','Cash',0,'Bill #179 - Cash Payment',1113.00,0.00,0,'2025-07-11 19:03:13','2025-07-11 19:03:13'),
(482,'180','2025-07-11 12:08:08','Sales',1,'Bill #180 - Sale Revenue',0.00,1969.00,0,'2025-07-11 19:08:08','2025-07-11 19:08:08'),
(483,'180','2025-07-11 12:08:08','Cash',0,'Bill #180 - Cash Payment',1969.00,0.00,0,'2025-07-11 19:08:08','2025-07-11 19:08:08'),
(484,'181','2025-07-11 12:16:40','Sales',1,'Bill #181 - Sale Revenue',0.00,1669.00,0,'2025-07-11 19:16:40','2025-07-11 19:16:40'),
(485,'181','2025-07-11 12:16:40','Cash',0,'Bill #181 - Cash Payment',1669.00,0.00,0,'2025-07-11 19:16:40','2025-07-11 19:16:40'),
(486,'182','2025-07-11 12:17:59','Sales',1,'Bill #182 - Sale Revenue',0.00,963.00,0,'2025-07-11 19:17:59','2025-07-11 19:17:59'),
(487,'182','2025-07-11 12:17:59','Cash',0,'Bill #182 - Cash Payment',963.00,0.00,0,'2025-07-11 19:17:59','2025-07-11 19:17:59'),
(488,'183','2025-07-11 12:38:27','Sales',1,'Bill #183 - Sale Revenue',0.00,535.00,0,'2025-07-11 19:38:27','2025-07-11 19:38:27'),
(489,'183','2025-07-11 12:38:27','Cash',0,'Bill #183 - Cash Payment',535.00,0.00,0,'2025-07-11 19:38:27','2025-07-11 19:38:27'),
(490,'184','2025-07-11 12:54:06','Sales',1,'Bill #184 - Sale Revenue',0.00,3210.00,0,'2025-07-11 19:54:06','2025-07-11 19:54:06'),
(491,'184','2025-07-11 12:54:06','Cash',0,'Bill #184 - Cash Payment',3210.00,0.00,0,'2025-07-11 19:54:06','2025-07-11 19:54:06'),
(492,'185','2025-07-12 03:55:31','Sales',1,'Bill #185 - Sale Revenue',0.00,1760.00,0,'2025-07-12 10:55:31','2025-07-12 10:55:31'),
(493,'186','2025-07-12 04:01:46','Sales',1,'Bill #186 - Sale Revenue',0.00,4387.00,0,'2025-07-12 11:01:46','2025-07-12 11:01:46'),
(494,'186','2025-07-12 04:01:46','UPI',0,'Bill #186 - UPI Payment',4387.00,0.00,0,'2025-07-12 11:01:46','2025-07-12 11:01:46'),
(495,'187','2025-07-12 06:14:04','Sales',1,'Bill #187 - Sale Revenue',0.00,2226.00,0,'2025-07-12 13:14:04','2025-07-12 13:14:04'),
(496,'187','2025-07-12 06:14:04','UPI',0,'Bill #187 - UPI Payment',2226.00,0.00,0,'2025-07-12 13:14:04','2025-07-12 13:14:04'),
(497,'188','2025-07-12 06:22:20','Sales',1,'Bill #188 - Sale Revenue',0.00,675.00,0,'2025-07-12 13:22:20','2025-07-12 13:22:20'),
(498,'188','2025-07-12 06:22:20','Cash',0,'Bill #188 - Cash Payment',675.00,0.00,0,'2025-07-12 13:22:20','2025-07-12 13:22:20'),
(499,'189','2025-07-14 05:53:32','Sales',1,'Bill #189 - Sale Revenue',0.00,1455.00,0,'2025-07-14 12:53:32','2025-07-14 12:53:32'),
(500,'189','2025-07-14 05:53:32','UPI',0,'Bill #189 - UPI Payment',1455.00,0.00,0,'2025-07-14 12:53:32','2025-07-14 12:53:32'),
(501,'190','2025-07-14 10:03:58','Sales',1,'Bill #190 - Sale Revenue',0.00,293.00,0,'2025-07-14 17:03:58','2025-07-14 17:03:58'),
(502,'190','2025-07-14 10:03:58','Cash',0,'Bill #190 - Cash Payment',293.00,0.00,0,'2025-07-14 17:03:58','2025-07-14 17:03:58'),
(503,'191','2025-07-15 05:23:07','Sales',1,'Bill #191 - Sale Revenue',0.00,325.00,0,'2025-07-15 12:23:07','2025-07-15 12:23:07'),
(504,'191','2025-07-15 05:23:07','Cash',0,'Bill #191 - Cash Payment',325.00,0.00,0,'2025-07-15 12:23:07','2025-07-15 12:23:07'),
(505,'192','2025-07-15 05:26:20','Sales',1,'Bill #192 - Sale Revenue',0.00,252.00,0,'2025-07-15 12:26:20','2025-07-15 12:26:20'),
(506,'192','2025-07-15 05:26:20','Cash',0,'Bill #192 - Cash Payment',252.00,0.00,0,'2025-07-15 12:26:20','2025-07-15 12:26:20'),
(507,'193','2025-07-15 10:58:28','Sales',1,'Bill #193 - Sale Revenue',0.00,433.00,0,'2025-07-15 17:58:28','2025-07-15 17:58:28'),
(508,'193','2025-07-15 10:58:28','Cash',0,'Bill #193 - Cash Payment',433.00,0.00,0,'2025-07-15 17:58:28','2025-07-15 17:58:28'),
(509,'194','2025-07-15 10:58:42','Sales',1,'Bill #194 - Sale Revenue',0.00,433.00,0,'2025-07-15 17:58:42','2025-07-15 17:58:42'),
(510,'194','2025-07-15 10:58:42','Cash',0,'Bill #194 - Cash Payment',433.00,0.00,0,'2025-07-15 17:58:42','2025-07-15 17:58:42'),
(511,'195','2025-07-15 11:01:08','Sales',1,'Bill #195 - Sale Revenue',0.00,1220.00,0,'2025-07-15 18:01:08','2025-07-15 18:01:08'),
(512,'195','2025-07-15 11:01:08','Cash',0,'Bill #195 - Cash Payment',1220.00,0.00,0,'2025-07-15 18:01:08','2025-07-15 18:01:08'),
(513,'18','2025-07-15 11:40:49','Sales',1,'Bill #18 - Sale Revenue',0.00,915.00,NULL,'2025-07-15 18:40:49','2025-07-15 18:40:49'),
(514,'18','2025-07-15 11:40:49','Cash',0,'Bill #18 - Cash Payment',915.00,0.00,NULL,'2025-07-15 18:40:49','2025-07-15 18:40:49'),
(515,'19','2025-07-15 11:41:47','Sales',1,'Bill #19 - Sale Revenue',0.00,626.00,NULL,'2025-07-15 18:41:47','2025-07-15 18:41:47'),
(516,'19','2025-07-15 11:41:47','Cash',0,'Bill #19 - Cash Payment',626.00,0.00,NULL,'2025-07-15 18:41:47','2025-07-15 18:41:47'),
(517,'196','2025-07-16 06:55:52','Sales',1,'Bill #196 - Sale Revenue',0.00,159.00,0,'2025-07-16 13:55:52','2025-07-16 13:55:52'),
(518,'196','2025-07-16 06:55:52','Account Recievable',1,'Bill #196 - Credit Sale',159.00,0.00,0,'2025-07-16 13:55:52','2025-07-16 13:55:52'),
(519,'197','2025-07-17 08:44:31','Sales',1,'Bill #197 - Sale Revenue',0.00,428.00,0,'2025-07-17 15:44:31','2025-07-17 15:44:31'),
(520,'197','2025-07-17 08:44:31','Cash',0,'Bill #197 - Cash Payment',428.00,0.00,0,'2025-07-17 15:44:31','2025-07-17 15:44:31'),
(521,'198','2025-07-18 09:45:39','Sales',1,'Bill #198 - Sale Revenue',0.00,1113.00,0,'2025-07-18 16:45:39','2025-07-18 16:45:39'),
(522,'198','2025-07-18 09:45:39','Cash',0,'Bill #198 - Cash Payment',1113.00,0.00,0,'2025-07-18 16:45:39','2025-07-18 16:45:39'),
(523,'199','2025-07-22 10:34:12','Sales',1,'Bill #199 - Sale Revenue',0.00,187.00,0,'2025-07-22 17:34:12','2025-07-22 17:34:12'),
(524,'199','2025-07-22 10:34:12','Cash',0,'Bill #199 - Cash Payment',187.00,0.00,0,'2025-07-22 17:34:12','2025-07-22 17:34:12'),
(525,'200','2025-07-24 11:00:34','Sales',1,'Bill #200 - Sale Revenue',0.00,305.00,0,'2025-07-24 18:00:34','2025-07-24 18:00:34'),
(526,'200','2025-07-24 11:00:34','Cash',0,'Bill #200 - Cash Payment',305.00,0.00,0,'2025-07-24 18:00:34','2025-07-24 18:00:34'),
(527,'201','2025-07-24 11:02:14','Sales',1,'Bill #201 - Sale Revenue',0.00,500.00,0,'2025-07-24 18:02:14','2025-07-24 18:02:14'),
(528,'201','2025-07-24 11:02:14','Cash',0,'Bill #201 - Cash Payment',500.00,0.00,0,'2025-07-24 18:02:14','2025-07-24 18:02:14'),
(529,'202','2025-07-24 12:31:55','Sales',1,'Bill #202 - Sale Revenue',0.00,1198.00,0,'2025-07-24 19:31:55','2025-07-24 19:31:55'),
(530,'202','2025-07-24 12:31:55','Cash',0,'Bill #202 - Cash Payment',1198.00,0.00,0,'2025-07-24 19:31:55','2025-07-24 19:31:55'),
(531,'203','2025-07-25 04:21:32','Sales',1,'Bill #203 - Sale Revenue',0.00,275.00,0,'2025-07-25 11:21:32','2025-07-25 11:21:32'),
(532,'203','2025-07-25 04:21:32','Cash',0,'Bill #203 - Cash Payment',275.00,0.00,0,'2025-07-25 11:21:32','2025-07-25 11:21:32'),
(533,'204','2025-07-25 04:24:15','Sales',1,'Bill #204 - Sale Revenue',0.00,300.00,0,'2025-07-25 11:24:15','2025-07-25 11:24:15'),
(534,'204','2025-07-25 04:24:15','Cash',0,'Bill #204 - Cash Payment',300.00,0.00,0,'2025-07-25 11:24:15','2025-07-25 11:24:15'),
(535,'205','2025-07-31 07:13:40','Sales',1,'Bill #205 - Sale Revenue',0.00,835.00,0,'2025-07-31 14:13:40','2025-07-31 14:13:40'),
(536,'205','2025-07-31 07:13:40','Cash',0,'Bill #205 - Cash Payment',835.00,0.00,0,'2025-07-31 14:13:40','2025-07-31 14:13:40'),
(537,'206','2025-08-15 09:52:15','Sales',1,'Bill #206 - Sale Revenue',0.00,325.00,0,'2025-08-15 16:52:15','2025-08-15 16:52:15'),
(538,'206','2025-08-15 09:52:15','Cash',0,'Bill #206 - Cash Payment',325.00,0.00,0,'2025-08-15 16:52:15','2025-08-15 16:52:15'),
(539,'207','2025-08-25 16:09:55','Sales',1,'Bill #207 - Sale Revenue',0.00,100.00,0,'2025-08-25 23:09:55','2025-08-25 23:09:55'),
(540,'208','2025-08-25 16:15:43','Sales',1,'Bill #208 - Sale Revenue',0.00,1434.00,0,'2025-08-25 23:15:43','2025-08-25 23:15:43'),
(541,'208','2025-08-25 16:15:43','QR Code',0,'Bill #208 - QR Payment',1434.00,0.00,0,'2025-08-25 23:15:43','2025-08-25 23:15:43'),
(542,'209','2025-08-26 08:33:27','Sales',1,'Bill #209 - Sale Revenue',0.00,225.00,0,'2025-08-26 15:33:27','2025-08-26 15:33:27'),
(543,'209','2025-08-26 08:33:27','Cash',0,'Bill #209 - Cash Payment',225.00,0.00,0,'2025-08-26 15:33:27','2025-08-26 15:33:27'),
(544,'210','2025-08-26 08:37:40','Sales',1,'Bill #210 - Sale Revenue',0.00,2000.00,0,'2025-08-26 15:37:40','2025-08-26 15:37:40'),
(545,'211','2025-08-26 08:40:35','Sales',1,'Bill #211 - Sale Revenue',0.00,225.00,0,'2025-08-26 15:40:35','2025-08-26 15:40:35'),
(546,'212','2025-08-26 08:45:54','Sales',1,'Bill #212 - Sale Revenue',0.00,180.00,0,'2025-08-26 15:45:54','2025-08-26 15:45:54'),
(547,'213','2025-08-26 08:50:20','Sales',1,'Bill #213 - Sale Revenue',0.00,345.00,0,'2025-08-26 15:50:20','2025-08-26 15:50:20'),
(548,'214','2025-08-26 08:54:02','Sales',1,'Bill #214 - Sale Revenue',0.00,250.00,0,'2025-08-26 15:54:02','2025-08-26 15:54:02'),
(549,'214','2025-08-26 08:54:02','Cash',0,'Bill #214 - Cash Payment',250.00,0.00,0,'2025-08-26 15:54:02','2025-08-26 15:54:02'),
(550,'215','2025-08-26 09:01:15','Sales',1,'Bill #215 - Sale Revenue',0.00,1013.00,0,'2025-08-26 16:01:15','2025-08-26 16:01:15'),
(551,'215','2025-08-26 09:01:15','Cash',0,'Bill #215 - Cash Payment',1013.00,0.00,0,'2025-08-26 16:01:15','2025-08-26 16:01:15'),
(552,'216','2025-08-26 09:02:52','Sales',1,'Bill #216 - Sale Revenue',0.00,75.00,0,'2025-08-26 16:02:52','2025-08-26 16:02:52'),
(553,'217','2025-08-26 09:03:34','Sales',1,'Bill #217 - Sale Revenue',0.00,380.00,0,'2025-08-26 16:03:34','2025-08-26 16:03:34'),
(554,'217','2025-08-26 09:03:34','Cash',0,'Bill #217 - Cash Payment',380.00,0.00,0,'2025-08-26 16:03:34','2025-08-26 16:03:34'),
(555,'218','2025-08-26 09:03:54','Sales',1,'Bill #218 - Sale Revenue',0.00,350.00,0,'2025-08-26 16:03:54','2025-08-26 16:03:54'),
(556,'219','2025-08-26 09:12:01','Sales',1,'Bill #219 - Sale Revenue',0.00,310.00,0,'2025-08-26 16:12:01','2025-08-26 16:12:01'),
(557,'220','2025-08-26 09:59:53','Sales',1,'Bill #220 - Sale Revenue',0.00,425.00,0,'2025-08-26 16:59:53','2025-08-26 16:59:53'),
(558,'220','2025-08-26 09:59:53','Cash',0,'Bill #220 - Cash Payment',425.00,0.00,0,'2025-08-26 16:59:53','2025-08-26 16:59:53'),
(559,'221','2025-08-26 10:11:28','Sales',1,'Bill #221 - Sale Revenue',0.00,1170.00,0,'2025-08-26 17:11:28','2025-08-26 17:11:28'),
(560,'221','2025-08-26 10:11:28','Cash',0,'Bill #221 - Cash Payment',1170.00,0.00,0,'2025-08-26 17:11:28','2025-08-26 17:11:28'),
(561,'222','2025-08-26 10:12:09','Sales',1,'Bill #222 - Sale Revenue',0.00,975.00,0,'2025-08-26 17:12:09','2025-08-26 17:12:09'),
(562,'222','2025-08-26 10:12:09','Cash',0,'Bill #222 - Cash Payment',975.00,0.00,0,'2025-08-26 17:12:09','2025-08-26 17:12:09'),
(563,'223','2025-08-27 08:47:48','Sales',1,'Bill #223 - Sale Revenue',0.00,428.00,0,'2025-08-27 15:47:48','2025-08-27 15:47:48'),
(564,'223','2025-08-27 08:47:48','Bank Transfer',0,'Bill #223 - Bank Transfer Payment',428.00,0.00,0,'2025-08-27 15:47:48','2025-08-27 15:47:48'),
(565,'224','2025-08-27 08:55:53','Sales',1,'Bill #224 - Sale Revenue',0.00,225.00,0,'2025-08-27 15:55:53','2025-08-27 15:55:53'),
(566,'224','2025-08-27 08:55:53','Cash',0,'Bill #224 - Cash Payment',225.00,0.00,0,'2025-08-27 15:55:53','2025-08-27 15:55:53'),
(567,'225','2025-08-27 11:01:57','Sales',1,'Bill #225 - Sale Revenue',0.00,1179.00,0,'2025-08-27 18:01:57','2025-08-27 18:01:57'),
(568,'225','2025-08-27 11:01:57','Cash',0,'Bill #225 - Cash Payment',1179.00,0.00,0,'2025-08-27 18:01:57','2025-08-27 18:01:57'),
(569,'226','2025-08-27 11:02:08','Sales',1,'Bill #226 - Sale Revenue',0.00,2106.00,0,'2025-08-27 18:02:08','2025-08-27 18:02:08'),
(570,'226','2025-08-27 11:02:08','Cash',0,'Bill #226 - Cash Payment',2106.00,0.00,0,'2025-08-27 18:02:08','2025-08-27 18:02:08'),
(571,'227','2025-08-27 11:02:19','Sales',1,'Bill #227 - Sale Revenue',0.00,2340.00,0,'2025-08-27 18:02:19','2025-08-27 18:02:19'),
(572,'227','2025-08-27 11:02:19','Cash',0,'Bill #227 - Cash Payment',2340.00,0.00,0,'2025-08-27 18:02:19','2025-08-27 18:02:19'),
(573,'228','2025-08-27 16:33:54','Sales',1,'Bill #228 - Sale Revenue',0.00,1755.00,0,'2025-08-27 23:33:54','2025-08-27 23:33:54'),
(574,'228','2025-08-27 16:33:54','Cash',0,'Bill #228 - Cash Payment',1755.00,0.00,0,'2025-08-27 23:33:54','2025-08-27 23:33:54'),
(575,'229','2025-08-28 03:51:20','Sales',1,'Bill #229 - Sale Revenue',0.00,790.00,0,'2025-08-28 10:51:20','2025-08-28 10:51:20'),
(576,'230','2025-08-28 10:22:01','Sales',1,'Bill #230 - Sale Revenue',0.00,568.00,0,'2025-08-28 17:22:01','2025-08-28 17:22:01'),
(577,'231','2025-08-28 10:27:10','Sales',1,'Bill #231 - Sale Revenue',0.00,225.00,0,'2025-08-28 17:27:10','2025-08-28 17:27:10'),
(578,'232','2025-08-29 06:08:30','Sales',1,'Bill #232 - Sale Revenue',0.00,225.00,0,'2025-08-29 13:08:30','2025-08-29 13:08:30'),
(579,'232','2025-08-29 06:08:30','Cash',0,'Bill #232 - Cash Payment',225.00,0.00,0,'2025-08-29 13:08:30','2025-08-29 13:08:30'),
(580,'233','2025-08-29 06:08:35','Sales',1,'Bill #233 - Sale Revenue',0.00,235.00,0,'2025-08-29 13:08:35','2025-08-29 13:08:35'),
(581,'233','2025-08-29 06:08:35','Cash',0,'Bill #233 - Cash Payment',235.00,0.00,0,'2025-08-29 13:08:35','2025-08-29 13:08:35'),
(582,'234','2025-08-29 06:32:56','Sales',1,'Bill #234 - Sale Revenue',0.00,750.00,0,'2025-08-29 13:32:56','2025-08-29 13:32:56'),
(583,'234','2025-08-29 06:32:56','Cash',0,'Bill #234 - Cash Payment',750.00,0.00,0,'2025-08-29 13:32:56','2025-08-29 13:32:56'),
(584,'235','2025-08-29 09:53:37','Sales',1,'Bill #235 - Sale Revenue',0.00,320.00,0,'2025-08-29 16:53:37','2025-08-29 16:53:37'),
(585,'235','2025-08-29 09:53:37','Cash',0,'Bill #235 - Cash Payment',320.00,0.00,0,'2025-08-29 16:53:37','2025-08-29 16:53:37'),
(586,'236','2025-08-29 09:53:47','Sales',1,'Bill #236 - Sale Revenue',0.00,318.00,0,'2025-08-29 16:53:47','2025-08-29 16:53:47'),
(587,'237','2025-08-29 10:10:21','Sales',1,'Bill #237 - Sale Revenue',0.00,120.00,0,'2025-08-29 17:10:21','2025-08-29 17:10:21'),
(588,'237','2025-08-29 10:10:21','Cash',0,'Bill #237 - Cash Payment',120.00,0.00,0,'2025-08-29 17:10:21','2025-08-29 17:10:21'),
(589,'238','2025-08-29 10:10:29','Sales',1,'Bill #238 - Sale Revenue',0.00,115.00,0,'2025-08-29 17:10:29','2025-08-29 17:10:29'),
(590,'239','2025-08-29 10:11:19','Sales',1,'Bill #239 - Sale Revenue',0.00,393.00,0,'2025-08-29 17:11:19','2025-08-29 17:11:19'),
(591,'239','2025-08-29 10:11:19','Bank Transfer',0,'Bill #239 - Bank Transfer Payment',393.00,0.00,0,'2025-08-29 17:11:19','2025-08-29 17:11:19'),
(592,'301','2025-08-29 00:00:00','Purchase',1,'Final ledger entry from stock items',6400.00,0.00,NULL,'2025-08-29 19:04:27','2025-08-29 19:04:27'),
(593,'705','2025-08-30 00:00:00','Purchase',2,'Final ledger entry from stock items',16000.00,0.00,NULL,'2025-08-30 15:48:30','2025-08-30 15:48:30'),
(594,'240','2025-09-02 11:13:42','Sales',1,'Bill #240 - Sale Revenue',0.00,1000.00,0,'2025-09-02 18:13:42','2025-09-02 18:13:42'),
(595,'240','2025-09-02 11:13:42','Cash',0,'Bill #240 - Cash Payment',1000.00,0.00,0,'2025-09-02 18:13:42','2025-09-02 18:13:42'),
(596,'241','2025-09-03 12:50:13','Sales',1,'Bill #241 - Sale Revenue',0.00,1080.00,0,'2025-09-03 19:50:13','2025-09-03 19:50:13'),
(597,'241','2025-09-03 12:50:13','Cash',0,'Bill #241 - Cash Payment',1080.00,0.00,0,'2025-09-03 19:50:13','2025-09-03 19:50:13'),
(598,'242','2025-09-03 12:56:13','Sales',1,'Bill #242 - Sale Revenue',0.00,290.00,0,'2025-09-03 19:56:13','2025-09-03 19:56:13'),
(599,'242','2025-09-03 12:56:13','Cash',0,'Bill #242 - Cash Payment',290.00,0.00,0,'2025-09-03 19:56:13','2025-09-03 19:56:13'),
(600,'243','2025-09-06 06:47:59','Sales',1,'Bill #243 - Sale Revenue',0.00,220.00,0,'2025-09-06 13:47:59','2025-09-06 13:47:59'),
(601,'243','2025-09-06 06:47:59','Cash',0,'Bill #243 - Cash Payment',220.00,0.00,0,'2025-09-06 13:47:59','2025-09-06 13:47:59'),
(602,'244','2025-09-06 07:36:45','Sales',1,'Bill #244 - Sale Revenue',0.00,260.00,0,'2025-09-06 14:36:45','2025-09-06 14:36:45'),
(603,'244','2025-09-06 07:36:45','Cash',0,'Bill #244 - Cash Payment',260.00,0.00,0,'2025-09-06 14:36:45','2025-09-06 14:36:45'),
(604,'245','2025-09-06 07:36:52','Sales',1,'Bill #245 - Sale Revenue',0.00,1883.00,0,'2025-09-06 14:36:52','2025-09-06 14:36:52'),
(605,'245','2025-09-06 07:36:52','Cash',0,'Bill #245 - Cash Payment',1883.00,0.00,0,'2025-09-06 14:36:52','2025-09-06 14:36:52'),
(606,'246','2025-09-06 07:36:56','Sales',1,'Bill #246 - Sale Revenue',0.00,330.00,0,'2025-09-06 14:36:56','2025-09-06 14:36:56'),
(607,'246','2025-09-06 07:36:56','Cash',0,'Bill #246 - Cash Payment',330.00,0.00,0,'2025-09-06 14:36:56','2025-09-06 14:36:56'),
(608,'247','2025-09-06 07:40:14','Sales',1,'Bill #247 - Sale Revenue',0.00,920.00,0,'2025-09-06 14:40:14','2025-09-06 14:40:14'),
(609,'247','2025-09-06 07:40:14','Cash',0,'Bill #247 - Cash Payment',920.00,0.00,0,'2025-09-06 14:40:14','2025-09-06 14:40:14'),
(610,'248','2025-09-06 07:43:39','Sales',1,'Bill #248 - Sale Revenue',0.00,390.00,0,'2025-09-06 14:43:39','2025-09-06 14:43:39'),
(611,'248','2025-09-06 07:43:39','Cash',0,'Bill #248 - Cash Payment',390.00,0.00,0,'2025-09-06 14:43:39','2025-09-06 14:43:39'),
(612,'249','2025-09-06 07:43:46','Sales',1,'Bill #249 - Sale Revenue',0.00,120.00,0,'2025-09-06 14:43:46','2025-09-06 14:43:46'),
(613,'249','2025-09-06 07:43:46','Cash',0,'Bill #249 - Cash Payment',120.00,0.00,0,'2025-09-06 14:43:46','2025-09-06 14:43:46'),
(614,'250','2025-09-06 07:43:51','Sales',1,'Bill #250 - Sale Revenue',0.00,745.00,0,'2025-09-06 14:43:51','2025-09-06 14:43:51'),
(615,'250','2025-09-06 07:43:51','Cash',0,'Bill #250 - Cash Payment',745.00,0.00,0,'2025-09-06 14:43:51','2025-09-06 14:43:51'),
(616,'251','2025-09-06 07:43:57','Sales',1,'Bill #251 - Sale Revenue',0.00,450.00,0,'2025-09-06 14:43:57','2025-09-06 14:43:57'),
(617,'251','2025-09-06 07:43:57','Cash',0,'Bill #251 - Cash Payment',450.00,0.00,0,'2025-09-06 14:43:57','2025-09-06 14:43:57'),
(618,'252','2025-09-06 08:25:55','Sales',1,'Bill #252 - Sale Revenue',0.00,235.00,0,'2025-09-06 15:25:55','2025-09-06 15:25:55'),
(619,'252','2025-09-06 08:25:55','Cash',0,'Bill #252 - Cash Payment',235.00,0.00,0,'2025-09-06 15:25:55','2025-09-06 15:25:55'),
(620,'253','2025-09-06 08:50:39','Sales',1,'Bill #253 - Sale Revenue',0.00,2955.00,0,'2025-09-06 15:50:39','2025-09-06 15:50:39'),
(621,'253','2025-09-06 08:50:39','Cash',0,'Bill #253 - Cash Payment',2955.00,0.00,0,'2025-09-06 15:50:39','2025-09-06 15:50:39'),
(622,'254','2025-09-08 06:34:29','Sales',1,'Bill #254 - Sale Revenue',0.00,150.00,0,'2025-09-08 13:34:29','2025-09-08 13:34:29'),
(623,'254','2025-09-08 06:34:29','Cash',0,'Bill #254 - Cash Payment',150.00,0.00,0,'2025-09-08 13:34:29','2025-09-08 13:34:29'),
(624,'255','2025-09-13 02:45:37','Sales',1,'Bill #255 - Sale Revenue',0.00,523.00,0,'2025-09-13 09:45:37','2025-09-13 09:45:37'),
(625,'255','2025-09-13 02:45:37','Cash',0,'Bill #255 - Cash Payment',523.00,0.00,0,'2025-09-13 09:45:37','2025-09-13 09:45:37'),
(626,'256','2025-09-13 02:49:12','Sales',1,'Bill #256 - Sale Revenue',0.00,390.00,0,'2025-09-13 09:49:12','2025-09-13 09:49:12'),
(627,'256','2025-09-13 02:49:12','Cash',0,'Bill #256 - Cash Payment',390.00,0.00,0,'2025-09-13 09:49:12','2025-09-13 09:49:12'),
(628,'257','2025-09-13 09:34:35','Sales',1,'Bill #257 - Sale Revenue',0.00,363.00,0,'2025-09-13 16:34:35','2025-09-13 16:34:35'),
(629,'257','2025-09-13 09:34:35','Cash',0,'Bill #257 - Cash Payment',363.00,0.00,0,'2025-09-13 16:34:35','2025-09-13 16:34:35'),
(630,'258','2025-09-13 09:36:12','Sales',1,'Bill #258 - Sale Revenue',0.00,300.00,0,'2025-09-13 16:36:12','2025-09-13 16:36:12'),
(631,'258','2025-09-13 09:36:12','Cash',0,'Bill #258 - Cash Payment',300.00,0.00,0,'2025-09-13 16:36:12','2025-09-13 16:36:12'),
(632,'2012','2025-09-13 00:00:00','Purchase',1,'Final ledger entry from stock items',18000.00,0.00,NULL,'2025-09-13 16:41:28','2025-09-13 16:41:28'),
(633,'2545','2025-09-30 00:00:00','Purchase',1,'Final ledger entry from stock items',30000.00,0.00,NULL,'2025-09-30 10:15:29','2025-09-30 10:15:29');
/*!40000 ALTER TABLE `ledger_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `line_discount_customers`
--

DROP TABLE IF EXISTS `line_discount_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_discount_customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) DEFAULT NULL,
  `added_on` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `line_discount_customers`
--

LOCK TABLES `line_discount_customers` WRITE;
/*!40000 ALTER TABLE `line_discount_customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `line_discount_customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` float NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `setup_date` date NOT NULL,
  `table_cat_id` int(11) DEFAULT NULL COMMENT 'Foreign key reference to table_category.id',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `idx_table_cat_id` (`table_cat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=692 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES
(1,2,'Table 2','Jalebi',2,360.00,'2025-02-11 10:55:59','2',0,'0000-00-00',NULL),
(2,2,'Table 2','Paneer Masala',1,180.00,'2025-02-11 10:55:59','2',0,'0000-00-00',NULL),
(3,2,'Table 2','Dosa',1,120.00,'2025-02-11 10:55:59','2',0,'0000-00-00',NULL),
(4,3,'Table 3','Rahra Chicken',3,540.00,'2025-02-11 10:56:11','4',0,'0000-00-00',NULL),
(5,3,'Table 3','Chicken Curry',1,250.00,'2025-02-11 10:56:11','4',0,'0000-00-00',NULL),
(6,4,'Table 6','Jalebi',2,360.00,'2025-02-11 10:56:18','1',0,'0000-00-00',NULL),
(7,4,'Table 6','Paneer Masala',2,360.00,'2025-02-11 10:56:18','1',0,'0000-00-00',NULL),
(8,4,'Table 6','Dosa',1,120.00,'2025-02-11 10:56:18','1',0,'0000-00-00',NULL),
(9,5,'Table 4','Paneer Masala',2,360.00,'2025-02-12 08:05:43','3',0,'0000-00-00',NULL),
(10,5,'Table 4','Dosa',2,240.00,'2025-02-12 08:05:43','3',0,'0000-00-00',NULL),
(11,5,'Table 4','Jalebi',1,180.00,'2025-02-12 08:05:43','3',0,'0000-00-00',NULL),
(12,6,'Table 7','Paneer Masala',1,180.00,'2025-02-20 07:10:54','5',0,'0000-00-00',NULL),
(13,6,'Table 7','Jalebi',2,360.00,'2025-02-20 07:10:54','5',0,'0000-00-00',NULL),
(14,6,'Table 7','Dosa',1,120.00,'2025-02-20 07:10:54','5',0,'0000-00-00',NULL),
(15,7,'Table 4','Paneer Masala',1,180.00,'2025-02-20 07:21:27','7',0,'0000-00-00',NULL),
(16,7,'Table 4','Dosa',3,360.00,'2025-02-20 07:21:27','7',0,'0000-00-00',NULL),
(17,8,'Table 6','Rahra Chicken',1,180.00,'2025-02-20 07:21:35','6',0,'0000-00-00',NULL),
(18,8,'Table 6','Tandoori Chicken',1,220.00,'2025-02-20 07:21:35','6',0,'0000-00-00',NULL),
(19,9,'Table 3','Chicken Curry',1,250.00,'2025-02-20 08:58:53','8',0,'0000-00-00',NULL),
(20,9,'Table 3','Rahra Chicken',1,180.00,'2025-02-20 08:58:53','8',0,'0000-00-00',NULL),
(21,9,'Table 3','Tandoori Chicken',1,220.00,'2025-02-20 08:58:53','8',0,'0000-00-00',NULL),
(22,10,'Table 6','Jalebi',1,180.00,'2025-02-20 08:59:02','10',0,'0000-00-00',NULL),
(23,10,'Table 6','Dosa',1,120.00,'2025-02-20 08:59:02','10',0,'0000-00-00',NULL),
(24,10,'Table 6','Paneer Masala',2,360.00,'2025-02-20 08:59:02','10',0,'0000-00-00',NULL),
(25,11,'Table 1','Dosa',3,360.00,'2025-02-20 09:04:51','11',0,'0000-00-00',NULL),
(26,12,'Table 6','Jalebi',2,360.00,'2025-02-20 09:04:56','12',0,'0000-00-00',NULL),
(27,12,'Table 6','Paneer Masala',2,360.00,'2025-02-20 09:04:56','12',0,'0000-00-00',NULL),
(28,13,'Table 3','Jalebi',1,180.00,'2025-02-20 09:51:15','14',0,'0000-00-00',NULL),
(29,13,'Table 3','Paneer Masala',1,180.00,'2025-02-20 09:51:15','14',0,'0000-00-00',NULL),
(30,14,'Table 4','Tandoori Chicken',1,220.00,'2025-02-20 10:16:33','13',0,'0000-00-00',NULL),
(31,14,'Table 4','Chicken Curry',2,500.00,'2025-02-20 10:16:33','13',0,'0000-00-00',NULL),
(32,14,'Table 4','Rahra Chicken',2,360.00,'2025-02-20 10:16:33','13',0,'0000-00-00',NULL),
(33,15,'Table 1','Chicken Curry',2,500.00,'2025-02-20 10:22:32','15',0,'0000-00-00',NULL),
(34,16,'Table 3','Chicken Curry',1,250.00,'2025-02-20 10:25:46','17',0,'0000-00-00',NULL),
(35,16,'Table 3','Rahra Chicken',1,180.00,'2025-02-20 10:25:46','17',0,'0000-00-00',NULL),
(36,17,'Table 6','Tandoori Chicken',1,220.00,'2025-02-20 10:25:52','16',0,'0000-00-00',NULL),
(37,17,'Table 6','Chicken Curry',1,250.00,'2025-02-20 10:25:52','16',0,'0000-00-00',NULL),
(38,18,'Table 2','Jalebi',2,360.00,'2025-02-24 07:13:41','18',0,'0000-00-00',NULL),
(39,18,'Table 2','Paneer Masala',2,360.00,'2025-02-24 07:13:41','18',0,'0000-00-00',NULL),
(40,19,'Table 4','Dosa',1,120.00,'2025-02-24 07:17:41','19',0,'0000-00-00',NULL),
(41,19,'Table 4','Paneer Masala',2,360.00,'2025-02-24 07:17:41','19',0,'0000-00-00',NULL),
(42,20,'Table 1','Dosa',3,360.00,'2025-02-24 07:18:11','20',0,'0000-00-00',NULL),
(43,20,'Table 1','Tandoori Chicken',2,440.00,'2025-02-24 07:18:11','20',0,'0000-00-00',NULL),
(44,21,'Table 3','Chicken Curry',2,500.00,'2025-02-24 07:27:05','22',0,'0000-00-00',NULL),
(45,21,'Table 3','Rahra Chicken',2,360.00,'2025-02-24 07:27:05','22',0,'0000-00-00',NULL),
(46,21,'Table 3','Tandoori Chicken',1,220.00,'2025-02-24 07:27:05','22',0,'0000-00-00',NULL),
(47,22,'Table 4','Jalebi',1,180.00,'2025-02-24 07:27:12','21',0,'0000-00-00',NULL),
(48,22,'Table 4','Paneer Masala',2,360.00,'2025-02-24 07:27:12','21',0,'0000-00-00',NULL),
(49,22,'Table 4','Dosa',1,120.00,'2025-02-24 07:27:12','21',0,'0000-00-00',NULL),
(50,23,'Table 2','Dosa',1,120.00,'2025-02-24 07:34:24','24',0,'0000-00-00',NULL),
(51,23,'Table 2','Paneer Masala',1,180.00,'2025-02-24 07:34:24','24',0,'0000-00-00',NULL),
(52,23,'Table 2','Jalebi',1,180.00,'2025-02-24 07:34:24','24',0,'0000-00-00',NULL),
(53,24,'Table 6','Tandoori Chicken',1,220.00,'2025-02-24 07:34:29','23',0,'0000-00-00',NULL),
(54,25,'Table 9','Jalebi',1,180.00,'2025-02-24 07:39:46','25',0,'0000-00-00',NULL),
(55,25,'Table 9','Paneer Masala',3,540.00,'2025-02-24 07:39:46','25',0,'0000-00-00',NULL),
(56,25,'Table 9','Dosa',1,120.00,'2025-02-24 07:39:46','25',0,'0000-00-00',NULL),
(57,26,'Table 4','Tandoori Chicken',2,440.00,'2025-02-24 07:39:53','26',0,'0000-00-00',NULL),
(58,26,'Table 4','Chicken Curry',1,250.00,'2025-02-24 07:39:53','26',0,'0000-00-00',NULL),
(59,27,'Table 1','Rahra Chicken',2,360.00,'2025-02-24 08:08:23','28',0,'0000-00-00',NULL),
(60,27,'Table 1','Chicken Curry',1,250.00,'2025-02-24 08:08:23','28',0,'0000-00-00',NULL),
(61,28,'Table 7','Chicken Curry',1,250.00,'2025-02-24 08:08:33','27',0,'0000-00-00',NULL),
(62,28,'Table 7','Paneer Masala',1,180.00,'2025-02-24 08:08:33','27',0,'0000-00-00',NULL),
(63,29,'Table 9','Dosa',1,120.00,'2025-02-24 08:25:01','29',0,'0000-00-00',NULL),
(64,29,'Table 9','Paneer Masala',1,180.00,'2025-02-24 08:25:01','29',0,'0000-00-00',NULL),
(65,29,'Table 9','Jalebi',1,180.00,'2025-02-24 08:25:01','29',0,'0000-00-00',NULL),
(66,30,'Table 9','Rahra Chicken',1,180.00,'2025-02-24 08:25:08','29',0,'0000-00-00',NULL),
(67,30,'Table 9','Chicken Curry',1,250.00,'2025-02-24 08:25:08','29',0,'0000-00-00',NULL),
(68,30,'Table 9','Tandoori Chicken',1,220.00,'2025-02-24 08:25:08','29',0,'0000-00-00',NULL),
(69,31,'Table 4','Rahra Chicken',3,540.00,'2025-02-24 08:34:53','31',0,'0000-00-00',NULL),
(70,32,'Table 6','Chicken Curry',1,250.00,'2025-02-24 08:35:00','30',0,'0000-00-00',NULL),
(71,32,'Table 6','Tandoori Chicken',1,220.00,'2025-02-24 08:35:00','30',0,'0000-00-00',NULL),
(72,32,'Table 6','Rahra Chicken',1,180.00,'2025-02-24 08:35:00','30',0,'0000-00-00',NULL),
(73,33,'Table 9','Rahra Chicken',1,180.00,'2025-02-24 08:35:15','29',0,'0000-00-00',NULL),
(74,34,'Table 2','Rahra Chicken',1,180.00,'2025-02-24 09:31:32','32',0,'0000-00-00',NULL),
(75,34,'Table 2','Chicken Curry',1,250.00,'2025-02-24 09:31:32','32',0,'0000-00-00',NULL),
(76,34,'Table 2','Tandoori Chicken',1,220.00,'2025-02-24 09:31:32','32',0,'0000-00-00',NULL),
(77,35,'Table 3','Jalebi',1,180.00,'2025-02-24 09:34:11','33',0,'0000-00-00',NULL),
(78,35,'Table 3','Paneer Masala',2,360.00,'2025-02-24 09:34:11','33',0,'0000-00-00',NULL),
(79,35,'Table 3','Dosa',1,120.00,'2025-02-24 09:34:11','33',0,'0000-00-00',NULL),
(80,36,'Table 2','Tandoori Chicken',1,220.00,'2025-02-24 09:34:20','34',0,'0000-00-00',NULL),
(81,37,'Table 4','Jalebi',2,360.00,'2025-02-24 09:55:32','37',0,'0000-00-00',NULL),
(82,37,'Table 4','Paneer Masala',1,180.00,'2025-02-24 09:55:32','37',0,'0000-00-00',NULL),
(83,38,'Table 2','Jalebi',3,540.00,'2025-02-24 09:55:42','36',0,'0000-00-00',NULL),
(84,38,'Table 2','Tandoori Chicken',1,220.00,'2025-02-24 09:55:42','36',0,'0000-00-00',NULL),
(85,39,'Table 6','Tandoori Chicken',1,220.00,'2025-02-24 09:55:50','35',0,'0000-00-00',NULL),
(86,39,'Table 6','Chicken Curry',1,250.00,'2025-02-24 09:55:50','35',0,'0000-00-00',NULL),
(87,39,'Table 6','Rahra Chicken',2,360.00,'2025-02-24 09:55:50','35',0,'0000-00-00',NULL),
(88,40,'Table 3','Tandoori Chicken',1,220.00,'2025-02-24 10:03:53','38',0,'0000-00-00',NULL),
(89,40,'Table 3','Chicken Curry',2,500.00,'2025-02-24 10:03:53','38',0,'0000-00-00',NULL),
(90,41,'Table 2','Chicken Curry',3,750.00,'2025-02-24 10:04:01','39',0,'0000-00-00',NULL),
(91,42,'Table 3','Chicken Curry',1,250.00,'2025-02-24 10:05:54','40',0,'0000-00-00',NULL),
(92,42,'Table 3','Rahra Chicken',2,360.00,'2025-02-24 10:05:54','40',0,'0000-00-00',NULL),
(93,43,'Table 7','Tandoori Chicken',3,660.00,'2025-02-24 10:19:26','41',0,'0000-00-00',NULL),
(94,44,'Table 5','Jalebi',1,180.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(95,44,'Table 5','Paneer Masala',1,180.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(96,44,'Table 5','Dosa',1,120.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(97,44,'Table 5','Tandoori Chicken',1,220.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(98,44,'Table 5','Chicken Curry',1,250.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(99,44,'Table 5','Rahra Chicken',1,180.00,'2025-02-24 10:19:34','42',0,'0000-00-00',NULL),
(100,45,'Table 2','Aloo Parantha',1,80.00,'2025-02-24 11:44:04','53',0,'0000-00-00',NULL),
(101,45,'Table 2','Aloo Pyaj  Parantha',1,100.00,'2025-02-24 11:44:04','53',0,'0000-00-00',NULL),
(102,45,'Table 2','Namkeen Parantha',1,65.00,'2025-02-24 11:44:04','53',0,'0000-00-00',NULL),
(103,45,'Table 2','Salt Lassi',1,50.00,'2025-02-24 11:44:04','53',0,'0000-00-00',NULL),
(104,46,'Table 4','Chanaa Daal',1,120.00,'2025-02-24 11:46:37','57',0,'0000-00-00',NULL),
(105,46,'Table 4','Daal Tarka',1,120.00,'2025-02-24 11:46:37','57',0,'0000-00-00',NULL),
(106,46,'Table 4',' Missi Roti',3,105.00,'2025-02-24 11:46:37','57',0,'0000-00-00',NULL),
(107,47,'Table 6','Chicken Curry',1,250.00,'2025-02-24 11:46:56','43',0,'0000-00-00',NULL),
(108,47,'Table 6','Chanaa Daal',1,120.00,'2025-02-24 11:46:56','43',0,'0000-00-00',NULL),
(109,47,'Table 6','Tawa Roti',5,125.00,'2025-02-24 11:46:56','43',0,'0000-00-00',NULL),
(110,47,'Table 6','tANDOORI Roti',3,75.00,'2025-02-24 11:46:56','43',0,'0000-00-00',NULL),
(111,48,'Table 5','Mutton Rogan Josh',1,570.00,'2025-02-24 11:47:29','42',0,'0000-00-00',NULL),
(112,48,'Table 5','Tawa Roti',4,100.00,'2025-02-24 11:47:29','42',0,'0000-00-00',NULL),
(113,48,'Table 5',' Missi Roti',1,35.00,'2025-02-24 11:47:29','42',0,'0000-00-00',NULL),
(114,48,'Table 5','tANDOORI Roti',5,125.00,'2025-02-24 11:47:29','42',0,'0000-00-00',NULL),
(115,49,'Table 2','Tawa Roti',4,100.00,'2025-02-24 11:47:50','53',0,'0000-00-00',NULL),
(116,50,'Table 5','tANDOORI Roti',4,100.00,'2025-02-24 11:47:59','42',0,'0000-00-00',NULL),
(117,51,'Table 6','Mutton Rogan',2,1060.00,'2025-02-24 11:48:12','43',0,'0000-00-00',NULL),
(118,51,'Table 6','Mutton Rogan Josh',1,570.00,'2025-02-24 11:48:12','43',0,'0000-00-00',NULL),
(119,52,'Table 5','tANDOORI Roti',3,75.00,'2025-02-24 11:48:21','42',0,'0000-00-00',NULL),
(120,53,'Table 5','Salt Lassi',1,50.00,'2025-02-25 08:48:14','44',0,'0000-00-00',NULL),
(121,53,'Table 5','Aloo Pyaj  Parantha',1,100.00,'2025-02-25 08:48:14','44',0,'0000-00-00',NULL),
(122,53,'Table 5','Namkeen Parantha',1,65.00,'2025-02-25 08:48:14','44',0,'0000-00-00',NULL),
(123,53,'Table 5','Aloo Parantha',1,80.00,'2025-02-25 08:48:14','44',0,'0000-00-00',NULL),
(124,54,'Table 5','Mutton Curry',1,0.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(125,54,'Table 5','Mutton Rogan Josh',1,570.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(126,54,'Table 5','Mutton Rogan',1,530.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(127,54,'Table 5','Chicken Curry',1,250.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(128,54,'Table 5','Chanaa Daal',1,120.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(129,54,'Table 5','Daal Tarka',1,120.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(130,54,'Table 5','Tandoori Roti',1,25.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(131,54,'Table 5','Tawa Roti',1,25.00,'2025-03-13 12:07:34','45',0,'0000-00-00',NULL),
(132,55,'Table 9','Tawa Roti',6,150.00,'2025-03-13 12:12:17','47',0,'0000-00-00',NULL),
(133,55,'Table 9','Tandoori Roti',2,50.00,'2025-03-13 12:12:17','47',0,'0000-00-00',NULL),
(134,55,'Table 9','Chicken Curry',2,500.00,'2025-03-13 12:12:17','47',0,'0000-00-00',NULL),
(135,55,'Table 9','Chanaa Daal',3,360.00,'2025-03-13 12:12:17','47',0,'0000-00-00',NULL),
(136,56,'Table 7','Tawa Roti',3,75.00,'2025-03-15 10:07:18','48',0,'0000-00-00',NULL),
(137,56,'Table 7','Tandoori Roti',3,75.00,'2025-03-15 10:07:18','48',0,'0000-00-00',NULL),
(138,56,'Table 7','Chicken Mughlai',2,560.00,'2025-03-15 10:07:18','48',0,'0000-00-00',NULL),
(139,56,'Table 7','Chicken Curry',1,250.00,'2025-03-15 10:07:18','48',0,'0000-00-00',NULL),
(140,56,'Table 7','Chanaa Daal',1,120.00,'2025-03-15 10:07:18','48',0,'0000-00-00',NULL),
(141,57,'Table 5','Salt Lassi',2,100.00,'2025-03-15 10:29:35','50',0,'0000-00-00',NULL),
(142,57,'Table 5','Aloo Parantha',1,80.00,'2025-03-15 10:29:35','50',0,'0000-00-00',NULL),
(143,57,'Table 5','Aloo Pyaj  Parantha',1,100.00,'2025-03-15 10:29:35','50',0,'0000-00-00',NULL),
(144,57,'Table 5','Namkeen Parantha',1,65.00,'2025-03-15 10:29:35','50',0,'0000-00-00',NULL),
(145,58,'Table 6','Salt Lassi',2,100.00,'2025-03-15 11:04:22','51',0,'0000-00-00',NULL),
(146,58,'Table 6','Aloo Parantha',1,80.00,'2025-03-15 11:04:22','51',0,'0000-00-00',NULL),
(147,58,'Table 6','Namkeen Parantha',1,65.00,'2025-03-15 11:04:22','51',0,'0000-00-00',NULL),
(148,58,'Table 6','Daal Tarka',1,120.00,'2025-03-15 11:04:22','51',0,'0000-00-00',NULL),
(149,58,'Table 6','Chanaa Daal',1,120.00,'2025-03-15 11:04:22','51',0,'0000-00-00',NULL),
(150,59,'Table 7','Daal Tarka',5,600.00,'2025-03-15 11:04:41','52',0,'0000-00-00',NULL),
(151,59,'Table 7','Chanaa Daal',4,480.00,'2025-03-15 11:04:41','52',0,'0000-00-00',NULL),
(152,59,'Table 7','Tawa Roti',1,25.00,'2025-03-15 11:04:41','52',0,'0000-00-00',NULL),
(153,59,'Table 7','Tandoori Roti',1,25.00,'2025-03-15 11:04:41','52',0,'0000-00-00',NULL),
(154,60,'Table 10','Mutton Curry',2,0.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(155,60,'Table 10','Mutton Rogan Josh',1,570.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(156,60,'Table 10','Mutton Rogan',2,1060.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(157,60,'Table 10','Salt Lassi',1,50.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(158,60,'Table 10','Aloo Parantha',1,80.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(159,60,'Table 10','Namkeen Parantha',2,130.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(160,60,'Table 10','Aloo Pyaj  Parantha',1,100.00,'2025-03-15 11:09:05','54',0,'0000-00-00',NULL),
(161,61,'Table 1','Salt Lassi',1,50.00,'2025-05-01 09:32:20','72',0,'0000-00-00',NULL),
(162,61,'Table 1','Aloo Parantha',1,80.00,'2025-05-01 09:32:20','72',0,'0000-00-00',NULL),
(163,61,'Table 1','Daal Tarka',1,120.00,'2025-05-01 09:32:20','72',0,'0000-00-00',NULL),
(164,61,'Table 1','Chicken Curry',1,250.00,'2025-05-01 09:32:20','72',0,'0000-00-00',NULL),
(165,62,'Table 10','Mutton Curry',1,0.00,'2025-05-01 09:32:55','55',0,'0000-00-00',NULL),
(166,62,'Table 10','Mutton Rogan Josh',1,570.00,'2025-05-01 09:32:55','55',0,'0000-00-00',NULL),
(167,62,'Table 10','Tawa Roti',8,200.00,'2025-05-01 09:32:55','55',0,'0000-00-00',NULL),
(168,62,'Table 10','Tandoori Roti',3,75.00,'2025-05-01 09:32:55','55',0,'0000-00-00',NULL),
(169,62,'Table 10',' Missi Roti',1,35.00,'2025-05-01 09:32:55','55',0,'0000-00-00',NULL),
(170,63,'Table 5','Chicken Mughlai',1,280.00,'2025-05-26 07:25:54','58',0,'0000-00-00',NULL),
(171,63,'Table 5','Chicken Curry',1,250.00,'2025-05-26 07:25:54','58',0,'0000-00-00',NULL),
(172,63,'Table 5','Tawa Roti',4,100.00,'2025-05-26 07:25:54','58',0,'0000-00-00',NULL),
(173,64,'Table 6','Mutton Curry',2,0.00,'2025-05-26 07:26:51','59',0,'0000-00-00',NULL),
(174,64,'Table 6','Mutton Rogan Josh',1,570.00,'2025-05-26 07:26:51','59',0,'0000-00-00',NULL),
(175,64,'Table 6','Salt Lassi',2,100.00,'2025-05-26 07:26:51','59',0,'0000-00-00',NULL),
(176,65,'Table 3','Tawa Roti',3,75.00,'2025-05-26 07:32:04','62',0,'0000-00-00',NULL),
(177,65,'Table 3',' Missi Roti',2,70.00,'2025-05-26 07:32:04','62',0,'0000-00-00',NULL),
(178,66,'Table 6','Chicken Mughlai',1,280.00,'2025-05-26 07:32:12','60',0,'0000-00-00',NULL),
(179,66,'Table 6','Chicken Curry',1,250.00,'2025-05-26 07:32:12','60',0,'0000-00-00',NULL),
(180,66,'Table 6','Tawa Roti',1,25.00,'2025-05-26 07:32:12','60',0,'0000-00-00',NULL),
(181,67,'Table 9','Salt Lassi',1,50.00,'2025-05-26 07:41:28','61',0,'0000-00-00',NULL),
(182,67,'Table 9','Aloo Parantha',1,80.00,'2025-05-26 07:41:28','61',0,'0000-00-00',NULL),
(183,67,'Table 9','Aloo Pyaj  Parantha',2,200.00,'2025-05-26 07:41:28','61',0,'0000-00-00',NULL),
(184,68,'Table 10','Salt Lassi',2,100.00,'2025-05-26 07:41:39','64',0,'0000-00-00',NULL),
(185,68,'Table 10','Namkeen Parantha',2,130.00,'2025-05-26 07:41:39','64',0,'0000-00-00',NULL),
(186,68,'Table 10','Aloo Parantha',1,80.00,'2025-05-26 07:41:39','64',0,'0000-00-00',NULL),
(187,68,'Table 10','Mutton Curry',1,0.00,'2025-05-26 07:41:39','64',0,'0000-00-00',NULL),
(188,69,'Table 9','Aloo Pyaj  Parantha',2,200.00,'2025-05-26 07:46:01','63',0,'0000-00-00',NULL),
(189,70,'Table 5','Tawa Roti',1,25.00,'2025-05-26 07:57:20','66',0,'0000-00-00',NULL),
(190,70,'Table 5','Tandoori Roti',1,25.00,'2025-05-26 07:57:20','66',0,'0000-00-00',NULL),
(191,71,'Table 9','Chicken Mughlai',1,280.00,'2025-05-26 07:57:28','65',0,'0000-00-00',NULL),
(192,71,'Table 9','Chicken Curry',1,250.00,'2025-05-26 07:57:28','65',0,'0000-00-00',NULL),
(193,72,'Table 10','Tawa Roti',1,25.00,'2025-05-26 08:07:00','68',0,'0000-00-00',NULL),
(194,72,'Table 10','Tandoori Roti',1,25.00,'2025-05-26 08:07:00','68',0,'0000-00-00',NULL),
(195,73,'Table 6','Tawa Roti',1,25.00,'2025-05-26 08:07:11','67',0,'0000-00-00',NULL),
(196,73,'Table 6','Tandoori Roti',1,25.00,'2025-05-26 08:07:11','67',0,'0000-00-00',NULL),
(197,73,'Table 6','Chicken Mughlai',1,280.00,'2025-05-26 08:07:11','67',0,'0000-00-00',NULL),
(198,73,'Table 6','Chicken Curry',1,250.00,'2025-05-26 08:07:11','67',0,'0000-00-00',NULL),
(199,74,'Table 5','Chicken Curry',2,500.00,'2025-05-26 08:07:18','69',0,'0000-00-00',NULL),
(200,75,'Table 5','Salt Lassi',1,50.00,'2025-05-26 11:11:15','71',0,'0000-00-00',NULL),
(201,75,'Table 5','Aloo Parantha',1,80.00,'2025-05-26 11:11:15','71',0,'0000-00-00',NULL),
(202,75,'Table 5','Aloo Pyaj  Parantha',1,100.00,'2025-05-26 11:11:15','71',0,'0000-00-00',NULL),
(203,76,'Table 6','Aloo Parantha',1,80.00,'2025-05-26 11:11:23','70',0,'0000-00-00',NULL),
(204,76,'Table 6','Namkeen Parantha',1,65.00,'2025-05-26 11:11:23','70',0,'0000-00-00',NULL),
(205,77,'Table 4','Salt Lassi',1,50.00,'2025-05-26 11:26:22','74',0,'0000-00-00',NULL),
(206,78,'Table 4','Aloo Parantha',1,80.00,'2025-05-26 11:26:27','74',0,'0000-00-00',NULL),
(207,78,'Table 4','Aloo Pyaj  Parantha',1,100.00,'2025-05-26 11:26:27','74',0,'0000-00-00',NULL),
(208,79,'Table 7','Aloo Parantha',1,80.00,'2025-05-26 11:26:43','73',0,'0000-00-00',NULL),
(209,79,'Table 7','Aloo Pyaj  Parantha',1,100.00,'2025-05-26 11:26:43','73',0,'0000-00-00',NULL),
(210,79,'Table 7','Tandoori Roti',1,25.00,'2025-05-26 11:26:43','73',0,'0000-00-00',NULL),
(211,79,'Table 7',' Missi Roti',1,35.00,'2025-05-26 11:26:43','73',0,'0000-00-00',NULL),
(212,80,'Table 3','Chanaa Daal',1,120.00,'2025-05-26 11:26:51','75',0,'0000-00-00',NULL),
(213,80,'Table 3','Daal Tarka',1,120.00,'2025-05-26 11:26:51','75',0,'0000-00-00',NULL),
(214,81,'Table 1','Salt Lassi',1,50.00,'2025-05-27 08:42:28','76',0,'0000-00-00',NULL),
(215,81,'Table 1','Aloo Parantha',1,80.00,'2025-05-27 08:42:28','76',0,'0000-00-00',NULL),
(216,81,'Table 1','Aloo Pyaj  Parantha',1,100.00,'2025-05-27 08:42:28','76',0,'0000-00-00',NULL),
(217,82,'Table 1','Salt Lassi',1,50.00,'2025-05-27 09:20:44','82',0,'0000-00-00',NULL),
(218,82,'Table 1','Aloo Parantha',1,80.00,'2025-05-27 09:20:44','82',0,'0000-00-00',NULL),
(219,82,'Table 1','Aloo Pyaj  Parantha',1,100.00,'2025-05-27 09:20:44','82',0,'0000-00-00',NULL),
(220,82,'Table 1','Namkeen Parantha',1,65.00,'2025-05-27 09:20:44','82',0,'0000-00-00',NULL),
(221,83,'Table 5','Mutton Curry',1,0.00,'2025-05-27 09:21:05','78',0,'0000-00-00',NULL),
(222,83,'Table 5','Mutton Rogan Josh',1,570.00,'2025-05-27 09:21:05','78',0,'0000-00-00',NULL),
(223,84,'Table 3','Tawa Roti',1,25.00,'2025-05-27 09:21:19','77',0,'0000-00-00',NULL),
(224,84,'Table 3',' Missi Roti',1,35.00,'2025-05-27 09:21:19','77',0,'0000-00-00',NULL),
(225,84,'Table 3','Chicken Mughlai',1,280.00,'2025-05-27 09:21:19','77',0,'0000-00-00',NULL),
(226,85,'Table 3','Salt Lassi',2,100.00,'2025-05-28 08:37:08','79',0,'0000-00-00',NULL),
(227,85,'Table 3','Aloo Parantha',1,80.00,'2025-05-28 08:37:08','79',0,'0000-00-00',NULL),
(228,85,'Table 3','Plain Prantha',1,80.00,'2025-05-28 08:37:08','79',0,'0000-00-00',NULL),
(229,85,'Table 3','Omlette',1,100.00,'2025-05-28 08:37:08','79',0,'0000-00-00',NULL),
(230,86,'Table 5','Tawa Roti',2,50.00,'2025-06-03 07:44:36','80',0,'0000-00-00',NULL),
(231,86,'Table 5','Chicken Mughlai',1,280.00,'2025-06-03 07:44:36','80',0,'0000-00-00',NULL),
(232,87,'Table 10','Chanaa Daal',1,120.00,'2025-06-03 07:44:47','81',0,'0000-00-00',NULL),
(233,87,'Table 10','Daal Tarka',1,120.00,'2025-06-03 07:44:47','81',0,'0000-00-00',NULL),
(234,87,'Table 10','Tandoori Roti',2,50.00,'2025-06-03 07:44:47','81',0,'0000-00-00',NULL),
(235,87,'Table 10',' Missi Roti',1,35.00,'2025-06-03 07:44:47','81',0,'0000-00-00',NULL),
(236,88,'Table 5','Tandoori Roti',3,75.00,'2025-06-03 07:44:54','80',0,'0000-00-00',NULL),
(237,89,'Table 1','Tawa Roti',1,25.00,'2025-06-03 07:46:01','82',0,'0000-00-00',NULL),
(238,89,'Table 1','Tandoori Roti',1,25.00,'2025-06-03 07:46:01','82',0,'0000-00-00',NULL),
(239,90,'Table 4','Coke 320ML',2,80.00,'2025-06-03 10:12:22','83',0,'0000-00-00',NULL),
(240,90,'Table 4','Namkeen Parantha',4,260.00,'2025-06-03 10:12:22','83',0,'0000-00-00',NULL),
(241,91,'Table 9','Mineral Water',2,80.00,'2025-06-03 10:13:28','84',0,'0000-00-00',NULL),
(242,91,'Table 9','Namkeen Parantha',3,195.00,'2025-06-03 10:13:28','84',0,'0000-00-00',NULL),
(243,92,'Table 3','Salt Lassi',2,100.00,'2025-06-03 10:31:12','85',0,'0000-00-00',NULL),
(244,92,'Table 3','Aloo Parantha',2,160.00,'2025-06-03 10:31:12','85',0,'0000-00-00',NULL),
(245,92,'Table 3','Aloo Pyaj  Parantha',2,200.00,'2025-06-03 10:31:12','85',0,'0000-00-00',NULL),
(246,93,'Table 5','Tandoori Roti',3,75.00,'2025-06-03 10:38:50','86',0,'0000-00-00',NULL),
(247,93,'Table 5',' Missi Roti',1,35.00,'2025-06-03 10:38:50','86',0,'0000-00-00',NULL),
(248,94,'Table 3','Salt Lassi',2,100.00,'2025-06-03 10:39:14','89',0,'0000-00-00',NULL),
(249,94,'Table 3','Pepsit 500ML',2,100.00,'2025-06-03 10:39:14','89',0,'0000-00-00',NULL),
(250,94,'Table 3','Paneer Kulcha',2,400.00,'2025-06-03 10:39:14','89',0,'0000-00-00',NULL),
(251,94,'Table 3','Namkeen Parantha',1,65.00,'2025-06-03 10:39:14','89',0,'0000-00-00',NULL),
(252,95,'Table 1','Chicken Mughlai',2,560.00,'2025-06-03 10:49:45','87',0,'0000-00-00',NULL),
(253,95,'Table 1','Tawa Roti',3,75.00,'2025-06-03 10:49:45','87',0,'0000-00-00',NULL),
(254,96,'Table 4','Tandoori Roti',1,25.00,'2025-06-03 10:54:27','91',0,'0000-00-00',NULL),
(255,96,'Table 4','Tawa Roti',1,25.00,'2025-06-03 10:54:27','91',0,'0000-00-00',NULL),
(256,96,'Table 4',' Missi Roti',1,35.00,'2025-06-03 10:54:27','91',0,'0000-00-00',NULL),
(257,96,'Table 4','Chicken Mughlai',1,280.00,'2025-06-03 10:54:27','91',0,'0000-00-00',NULL),
(258,97,'Table 5','Chicken Mughlai',1,280.00,'2025-06-03 10:54:33','90',0,'0000-00-00',NULL),
(259,97,'Table 5','Chicken Curry',1,250.00,'2025-06-03 10:54:33','90',0,'0000-00-00',NULL),
(260,98,'Table 2','Chicken Mughlai',1,280.00,'2025-06-03 10:54:43','110',0,'0000-00-00',NULL),
(261,98,'Table 2','Chicken Curry',1,250.00,'2025-06-03 10:54:43','110',0,'0000-00-00',NULL),
(262,98,'Table 2','Salt Lassi',1,50.00,'2025-06-03 10:54:43','110',0,'0000-00-00',NULL),
(263,99,'Table 4','Pepsit 500ML',1,50.00,'2025-06-03 10:57:41','92',0,'0000-00-00',NULL),
(264,99,'Table 4','Coke 320ML',1,40.00,'2025-06-03 10:57:41','92',0,'0000-00-00',NULL),
(265,99,'Table 4','Salt Lassi',1,50.00,'2025-06-03 10:57:41','92',0,'0000-00-00',NULL),
(266,99,'Table 4','Aloo Parantha',1,80.00,'2025-06-03 10:57:41','92',0,'0000-00-00',NULL),
(267,99,'Table 4','Aloo Pyaj  Parantha',1,100.00,'2025-06-03 10:57:41','92',0,'0000-00-00',NULL),
(268,100,'Table 7','Aloo Pyaj  Parantha',1,100.00,'2025-06-03 11:01:03','101',0,'0000-00-00',NULL),
(269,100,'Table 7','Namkeen Parantha',1,65.00,'2025-06-03 11:01:03','101',0,'0000-00-00',NULL),
(270,100,'Table 7','Paneer Kulcha',1,200.00,'2025-06-03 11:01:03','101',0,'0000-00-00',NULL),
(271,101,'Table 10','Mutton Curry',1,0.00,'2025-06-03 11:01:14','96',0,'0000-00-00',NULL),
(272,101,'Table 10','Mutton Rogan Josh',1,570.00,'2025-06-03 11:01:14','96',0,'0000-00-00',NULL),
(273,101,'Table 10','Mutton Rogan',1,530.00,'2025-06-03 11:01:14','96',0,'0000-00-00',NULL),
(274,102,'Table 4','Mutton Curry',1,0.00,'2025-06-04 09:11:07','97',0,'0000-00-00',NULL),
(275,102,'Table 4','Mutton Rogan Josh',1,570.00,'2025-06-04 09:11:07','97',0,'0000-00-00',NULL),
(276,102,'Table 4','Mutton Rogan',1,530.00,'2025-06-04 09:11:07','97',0,'0000-00-00',NULL),
(277,103,'Table 5','Mutton Curry',1,0.00,'2025-06-05 07:56:51','98',0,'0000-00-00',NULL),
(278,103,'Table 5','Mutton Rogan Josh',1,570.00,'2025-06-05 07:56:51','98',0,'0000-00-00',NULL),
(279,103,'Table 5','Mutton Rogan',1,530.00,'2025-06-05 07:56:51','98',0,'0000-00-00',NULL),
(280,104,'Table 3','Salt Lassi',1,50.00,'2025-06-05 07:57:05','104',0,'0000-00-00',NULL),
(281,104,'Table 3','Aloo Pyaj  Parantha',2,200.00,'2025-06-05 07:57:05','104',0,'0000-00-00',NULL),
(282,105,'Table 9','Salt Lassi',2,100.00,'2025-06-05 08:28:56','99',0,'0000-00-00',NULL),
(283,105,'Table 9','Aloo Parantha',3,240.00,'2025-06-05 08:28:56','99',0,'0000-00-00',NULL),
(284,106,'Take Away','Pepsit 500ML',1,50.00,'2025-06-07 10:22:28','100',0,'0000-00-00',NULL),
(285,106,'Take Away','Salt Lassi',1,50.00,'2025-06-07 10:22:28','100',0,'0000-00-00',NULL),
(286,106,'Take Away','Aloo Pyaj  Parantha',1,100.00,'2025-06-07 10:22:28','100',0,'0000-00-00',NULL),
(287,106,'Take Away','Namkeen Parantha',1,65.00,'2025-06-07 10:22:28','100',0,'0000-00-00',NULL),
(288,106,'Take Away','Aloo Parantha',1,80.00,'2025-06-07 10:22:28','100',0,'0000-00-00',NULL),
(289,107,'Table 4','Tawa Roti',3,75.00,'2025-06-10 06:59:36','109',0,'0000-00-00',NULL),
(290,107,'Table 4','Chicken Mughlai',3,840.00,'2025-06-10 06:59:36','109',0,'0000-00-00',NULL),
(291,108,'Table 9','Tawa Roti',1,25.00,'2025-06-10 07:00:45','102',0,'0000-00-00',NULL),
(292,109,'Table 9','Chanaa Daal',2,240.00,'2025-06-10 07:03:21','102',0,'0000-00-00',NULL),
(293,109,'Table 9','Daal Tarka',1,120.00,'2025-06-10 07:03:21','102',0,'0000-00-00',NULL),
(294,110,'Table 9','Mutton Curry',1,0.00,'2025-06-10 07:04:31','102',0,'0000-00-00',NULL),
(295,110,'Table 9','Mutton Rogan Josh',1,570.00,'2025-06-10 07:04:31','102',0,'0000-00-00',NULL),
(296,111,'Table 9','Mutton Curry',1,0.00,'2025-06-10 07:04:44','102',0,'0000-00-00',NULL),
(297,111,'Table 9','Mutton Rogan Josh',1,570.00,'2025-06-10 07:04:44','102',0,'0000-00-00',NULL),
(298,112,'Table 7','Salt Lassi',1,50.00,'2025-06-10 07:05:03','103',0,'0000-00-00',NULL),
(299,112,'Table 7','Mineral Water',1,40.00,'2025-06-10 07:05:03','103',0,'0000-00-00',NULL),
(300,113,'Take Away','Aloo Parantha',1,80.00,'2025-06-10 07:05:09','192',0,'0000-00-00',NULL),
(301,113,'Take Away','Aloo Pyaj  Parantha',2,200.00,'2025-06-10 07:05:09','192',0,'0000-00-00',NULL),
(302,124,'Table 10','Chicken Mughlai',1,280.00,'2025-06-17 07:19:11','113',0,'0000-00-00',NULL),
(303,124,'Table 10','Chicken Curry',1,250.00,'2025-06-17 07:19:11','113',0,'0000-00-00',NULL),
(304,124,'Table 10','Tandoori Roti',4,100.00,'2025-06-17 07:19:11','113',0,'0000-00-00',NULL),
(305,124,'Table 10','Tawa Roti',5,125.00,'2025-06-17 07:19:11','113',0,'0000-00-00',NULL),
(306,0,'fdsfsdf','Aloo Parantha',1,0.00,'2025-07-08 15:45:29',NULL,1,'0000-00-00',NULL),
(307,0,'fdsfsdf','Aloo Pyaj  Parantha',1,0.00,'2025-07-08 15:45:29',NULL,1,'0000-00-00',NULL),
(308,0,'fdsfsdf','Paneer Kulcha',1,0.00,'2025-07-08 15:45:29',NULL,1,'0000-00-00',NULL),
(309,139,'dasd','Salt Lassi',1,0.00,'2025-07-08 15:50:05',NULL,1,'0000-00-00',NULL),
(310,139,'dasd','Chanaa Daal',1,0.00,'2025-07-08 15:50:05',NULL,1,'0000-00-00',NULL),
(311,139,'dasd','Dal Fry',1,0.00,'2025-07-08 15:50:05',NULL,1,'0000-00-00',NULL),
(312,147,'dasd','Chanaa Daal',1,0.00,'2025-07-08 16:08:50',NULL,1,'0000-00-00',NULL),
(313,147,'dasd','Aloo Parantha',1,0.00,'2025-07-08 16:08:50',NULL,1,'0000-00-00',NULL),
(314,151,'ffsd','Tandoori Roti',1,0.00,'2025-07-08 16:21:17',NULL,1,'0000-00-00',NULL),
(315,151,'ffsd','Chicken Mughlai',1,0.00,'2025-07-08 16:21:17',NULL,1,'0000-00-00',NULL),
(316,152,'','vatitem',1,0.00,'2025-07-08 16:54:54',NULL,1,'0000-00-00',NULL),
(317,152,'','Khoya Barfi',1,0.00,'2025-07-08 16:54:54',NULL,1,'0000-00-00',NULL),
(318,153,'','Kalakand',1,0.00,'2025-07-09 03:23:14',NULL,1,'0000-00-00',NULL),
(319,153,'','Petha',1,0.00,'2025-07-09 03:23:14',NULL,1,'0000-00-00',NULL),
(320,153,'','Gajar Barfi',1,0.00,'2025-07-09 03:23:14',NULL,1,'0000-00-00',NULL),
(321,153,'','ChumChum',1,0.00,'2025-07-09 03:23:14',NULL,1,'0000-00-00',NULL),
(322,160,'','Khoya Barfi',1,0.00,'2025-07-09 06:38:43',NULL,1,'0000-00-00',NULL),
(323,160,'','Coconut Barfi',1,0.00,'2025-07-09 06:38:43',NULL,1,'0000-00-00',NULL),
(324,161,'','Kalakand',1,0.00,'2025-07-09 06:44:36',NULL,1,'0000-00-00',NULL),
(325,161,'','Rasgulle',1,0.00,'2025-07-09 06:44:36',NULL,1,'0000-00-00',NULL),
(326,161,'','Khoya Barfi',1,0.00,'2025-07-09 06:44:36',NULL,1,'0000-00-00',NULL),
(327,165,'','KalakandPakeeza',1,0.00,'2025-07-09 06:49:18',NULL,1,'0000-00-00',NULL),
(328,165,'','Malai Barfi',1,0.00,'2025-07-09 06:49:18',NULL,1,'0000-00-00',NULL),
(329,167,'','Gulabjamun',2,0.00,'2025-07-11 06:44:04',NULL,1,'0000-00-00',NULL),
(330,167,'','Khoya Barfi',1,0.00,'2025-07-11 06:44:04',NULL,1,'0000-00-00',NULL),
(331,167,'','Petha',1,0.00,'2025-07-11 06:44:04',NULL,1,'0000-00-00',NULL),
(332,168,'','Amrati',1,0.00,'2025-07-11 07:28:06',NULL,1,'0000-00-00',NULL),
(333,168,'','Besan Laddu',1,0.00,'2025-07-11 07:28:06',NULL,1,'0000-00-00',NULL),
(334,168,'','Meetha Bdana',1,0.00,'2025-07-11 07:28:06',NULL,1,'0000-00-00',NULL),
(335,168,'','Malai Barfi',3,0.00,'2025-07-11 07:28:06',NULL,1,'0000-00-00',NULL),
(336,169,'','Petha',1,0.00,'2025-07-11 07:38:05',NULL,1,'0000-00-00',NULL),
(337,169,'','Malai Barfi',1,0.00,'2025-07-11 07:38:05',NULL,1,'0000-00-00',NULL),
(338,169,'','Milk Cake',1,0.00,'2025-07-11 07:38:05',NULL,1,'0000-00-00',NULL),
(339,169,'','Kalakand',1,0.00,'2025-07-11 07:38:05',NULL,1,'0000-00-00',NULL),
(340,169,'','Malai Barfi',1,0.00,'2025-07-11 07:38:05',NULL,1,'0000-00-00',NULL),
(341,170,'','taxitem1',1,0.00,'2025-07-11 07:48:04',NULL,1,'0000-00-00',NULL),
(342,170,'','vatitem',1,0.00,'2025-07-11 07:48:04',NULL,1,'0000-00-00',NULL),
(343,171,'','Coconut Barfi',1,0.00,'2025-07-11 07:55:11',NULL,1,'0000-00-00',NULL),
(344,171,'','Sweet Milk',1,0.00,'2025-07-11 07:55:11',NULL,1,'0000-00-00',NULL),
(345,171,'','vatitem',1,0.00,'2025-07-11 07:55:11',NULL,1,'0000-00-00',NULL),
(346,172,'','Malai Barfi',1,0.00,'2025-07-11 08:09:12',NULL,1,'0000-00-00',NULL),
(347,172,'','vatitem',1,0.00,'2025-07-11 08:09:12',NULL,1,'0000-00-00',NULL),
(348,172,'','KalakandPakeeza',1,0.00,'2025-07-11 08:09:12',NULL,1,'0000-00-00',NULL),
(349,173,'','Malai Barfi',1,0.00,'2025-07-11 08:14:39',NULL,1,'0000-00-00',NULL),
(350,173,'','Kalakand',1,0.00,'2025-07-11 08:14:39',NULL,1,'0000-00-00',NULL),
(351,174,'fhdfhfdh','Malai Barfi',1,0.00,'2025-07-11 09:49:27',NULL,1,'0000-00-00',NULL),
(352,174,'fhdfhfdh','Milk Cake',1,0.00,'2025-07-11 09:49:27',NULL,1,'0000-00-00',NULL),
(353,174,'fhdfhfdh','Kalakand',1,0.00,'2025-07-11 09:49:27',NULL,1,'0000-00-00',NULL),
(354,175,'','Amrati',1,0.00,'2025-07-11 09:52:23',NULL,1,'0000-00-00',NULL),
(355,175,'','ChumChum',2,0.00,'2025-07-11 09:52:23',NULL,1,'0000-00-00',NULL),
(356,176,'','Amrati',1,0.00,'2025-07-11 10:46:04',NULL,1,'0000-00-00',NULL),
(357,176,'','Balushahi',1,0.00,'2025-07-11 10:46:04',NULL,1,'0000-00-00',NULL),
(358,176,'','jalebi',2,0.00,'2025-07-11 10:46:04',NULL,1,'0000-00-00',NULL),
(359,176,'','Bhare Chumchum',5,0.00,'2025-07-11 10:46:04',NULL,1,'0000-00-00',NULL),
(360,177,'','vatitem',1,0.00,'2025-07-11 10:48:48',NULL,1,'0000-00-00',NULL),
(361,177,'','Chocolate Barfi',1,0.00,'2025-07-11 10:48:48',NULL,1,'0000-00-00',NULL),
(362,177,'','Kalakand',3,0.00,'2025-07-11 10:48:48',NULL,1,'0000-00-00',NULL),
(363,178,'','Kalakand',1,0.00,'2025-07-11 10:51:22',NULL,1,'0000-00-00',NULL),
(364,178,'','Amrati',1,0.00,'2025-07-11 10:51:22',NULL,1,'0000-00-00',NULL),
(365,179,'','Kalakand',1,0.00,'2025-07-11 12:03:14',NULL,1,'0000-00-00',NULL),
(366,179,'','Malai Barfi',1,0.00,'2025-07-11 12:03:14',NULL,1,'0000-00-00',NULL),
(367,180,'','Khoya Barfi',1,535.00,'2025-07-11 12:08:08',NULL,1,'0000-00-00',NULL),
(368,180,'','Khoya Barfi',2,1070.00,'2025-07-11 12:08:08',NULL,1,'0000-00-00',NULL),
(369,180,'','Patisa',1,363.80,'2025-07-11 12:08:08',NULL,1,'0000-00-00',NULL),
(370,181,'','Kalakand',1,556.40,'2025-07-11 12:16:40',NULL,1,'0000-00-00',NULL),
(371,181,'','KalakandPakeeza',1,556.40,'2025-07-11 12:16:40',NULL,1,'0000-00-00',NULL),
(372,181,'','Chocolate Barfi',1,556.40,'2025-07-11 12:16:40',NULL,1,'0000-00-00',NULL),
(373,182,'','vatitem',1,321.00,'2025-07-11 12:18:00',NULL,1,'0000-00-00',NULL),
(374,182,'','Rasgulle',1,321.00,'2025-07-11 12:18:00',NULL,1,'0000-00-00',NULL),
(375,182,'','Rasgulle',1,321.00,'2025-07-11 12:18:00',NULL,1,'0000-00-00',NULL),
(376,183,'','Khoya Barfi',1,535.00,'2025-07-11 12:38:27',NULL,1,'0000-00-00',NULL),
(377,184,'','Khoya Barfi',1,535.00,'2025-07-11 12:54:06',NULL,1,'0000-00-00',NULL),
(378,184,'','Khoya Barfi',1,535.00,'2025-07-11 12:54:06',NULL,1,'0000-00-00',NULL),
(379,184,'','Khoya Barfi',1,535.00,'2025-07-11 12:54:06',NULL,1,'0000-00-00',NULL),
(380,184,'','Khoya Barfi',3,1605.00,'2025-07-11 12:54:06',NULL,1,'0000-00-00',NULL),
(381,186,'','Kalakand',6,3338.40,'2025-07-12 04:01:46',NULL,1,'0000-00-00',NULL),
(382,186,'','Gajar Barfi',1,492.20,'2025-07-12 04:01:46',NULL,1,'0000-00-00',NULL),
(383,186,'','Chocolate Barfi',1,556.40,'2025-07-12 04:01:46',NULL,1,'0000-00-00',NULL),
(384,187,'','Kalakand',2,1112.80,'2025-07-12 06:14:05',NULL,1,'0000-00-00',NULL),
(385,187,'','Kalakand',1,556.40,'2025-07-12 06:14:05',NULL,1,'0000-00-00',NULL),
(386,187,'','Chocolate Barfi',1,556.40,'2025-07-12 06:14:05',NULL,1,'0000-00-00',NULL),
(387,189,'','Kalakand',1,556.40,'2025-07-14 05:53:32',NULL,1,'0000-00-00',NULL),
(388,189,'','Gulabjamun',1,342.40,'2025-07-14 05:53:32',NULL,1,'0000-00-00',NULL),
(389,189,'','Coconut Barfi',1,556.40,'2025-07-14 05:53:32',NULL,1,'0000-00-00',NULL),
(390,2,'Table 1','VAT ITEM 4',1,100.00,'2025-07-14 10:03:32','190',0,'0000-00-00',NULL),
(391,2,'Table 1','VAT ITEM 3',1,150.00,'2025-07-14 10:03:32','190',0,'0000-00-00',NULL),
(392,2,'Table 1','vatitem',0,75.00,'2025-07-14 10:03:32','190',0,'0000-00-00',NULL),
(393,3,'Table 10','vatitem',4,1275.00,'2025-07-14 10:22:08','195',0,'0000-00-00',NULL),
(394,3,'Table 10','VAT ITEM 3',1,150.00,'2025-07-14 10:22:08','195',0,'0000-00-00',NULL),
(395,4,'Table 2','vatitem',0,75.00,'2025-07-15 05:22:45','191',0,'0000-00-00',NULL),
(396,4,'Table 2','VAT ITEM 3',1,150.00,'2025-07-15 05:22:45','191',0,'0000-00-00',NULL),
(397,4,'Table 2','VAT ITEM 4',1,100.00,'2025-07-15 05:22:45','191',0,'0000-00-00',NULL),
(398,5,'Table 6','VAT ITEM 4',3,300.00,'2025-07-15 05:28:06','210',0,'0000-00-00',NULL),
(399,5,'Table 6','VAT ITEM 3',1,150.00,'2025-07-15 05:28:06','210',0,'0000-00-00',NULL),
(400,6,'Table 4','vatitem',1,150.00,'2025-07-15 05:32:20','204',0,'0000-00-00',NULL),
(401,6,'Table 4','VAT ITEM 3',1,150.00,'2025-07-15 05:32:20','204',0,'0000-00-00',NULL),
(402,7,'Table 6','VAT ITEM 3',2,300.00,'2025-07-15 10:48:19','210',0,'0000-00-00',NULL),
(403,7,'Table 6','VAT ITEM 4',2,200.00,'2025-07-15 10:48:19','210',0,'0000-00-00',NULL),
(404,7,'Table 6','vatitem',4,1050.00,'2025-07-15 10:48:19','210',0,'0000-00-00',NULL),
(405,8,'Table 7','vatitem',0,75.00,'2025-07-15 10:52:29','209',0,'0000-00-00',NULL),
(406,8,'Table 7','VAT ITEM 3',1,150.00,'2025-07-15 10:52:29','209',0,'0000-00-00',NULL),
(407,9,'Table 2','VAT ITEM 4',3,300.00,'2025-07-15 10:54:19','193',0,'0000-00-00',NULL),
(408,9,'Table 2','VAT ITEM 3',1,150.00,'2025-07-15 10:54:19','193',0,'0000-00-00',NULL),
(409,10,'Table 2','vatitem',0,75.00,'2025-07-16 06:55:11','196',0,'0000-00-00',NULL),
(410,10,'Table 2','VAT ITEM 4',1,100.00,'2025-07-16 06:55:11','196',0,'0000-00-00',NULL),
(411,11,'Table 1','VAT ITEM 4',1,100.00,'2025-07-17 08:44:21','197',0,'0000-00-00',NULL),
(412,11,'Table 1','VAT ITEM 3',2,300.00,'2025-07-17 08:44:21','197',0,'0000-00-00',NULL),
(413,198,'','Kalakand',1,556.40,'2025-07-18 09:45:39',NULL,1,'0000-00-00',NULL),
(414,198,'','KalakandPakeeza',1,556.40,'2025-07-18 09:45:39',NULL,1,'0000-00-00',NULL),
(415,12,'Table 2','vatitem',0,75.00,'2025-07-22 10:33:23','199',0,'0000-00-00',NULL),
(416,12,'Table 2','VAT ITEM 4',1,100.00,'2025-07-22 10:33:23','199',0,'0000-00-00',NULL),
(417,13,'Table 2','vatitem',0,75.00,'2025-07-24 08:55:57','203',0,'0000-00-00',NULL),
(418,13,'Table 2','VAT ITEM 4',2,200.00,'2025-07-24 08:55:57','203',0,'0000-00-00',NULL),
(419,14,'Take Away','vatitem',0,75.00,'2025-07-24 10:59:30','200',0,'0000-00-00',NULL),
(420,14,'Take Away','GulabJamaun/plate',1,60.00,'2025-07-24 10:59:30','200',0,'0000-00-00',NULL),
(421,15,'Take Away','vatitem',1,150.00,'2025-07-24 11:00:19','200',0,'0000-00-00',NULL),
(422,16,'Take Away','VAT ITEM 4',2,200.00,'2025-07-24 11:01:51','201',0,'0000-00-00',NULL),
(423,16,'Take Away','VAT ITEM 3',2,300.00,'2025-07-24 11:01:51','201',0,'0000-00-00',NULL),
(424,202,'','Kalakand',1,556.40,'2025-07-24 12:31:55',NULL,1,'0000-00-00',NULL),
(425,202,'','ChumChum',1,321.00,'2025-07-24 12:31:55',NULL,1,'0000-00-00',NULL),
(426,202,'','Petha',1,321.00,'2025-07-24 12:31:55',NULL,1,'0000-00-00',NULL),
(427,17,'Table 3','VAT ITEM 4',1,100.00,'2025-07-25 04:58:19','207',0,'0000-00-00',NULL),
(428,18,'Table 2','vatitem',0,75.00,'2025-07-31 06:39:29','205',0,'0000-00-00',NULL),
(429,18,'Table 2','VAT ITEM 3',1,150.00,'2025-07-31 06:39:29','205',0,'0000-00-00',NULL),
(430,19,'Table 2','vatitem',0,75.00,'2025-07-31 06:42:55','205',0,'0000-00-00',NULL),
(431,20,'Table 2','VAT ITEM 3',1,150.00,'2025-07-31 06:48:17','205',0,'0000-00-00',NULL),
(432,20,'Table 2','VAT ITEM 4',1,100.00,'2025-07-31 06:48:17','205',0,'0000-00-00',NULL),
(433,21,'Table 2','GulabJamaun/plate',1,60.00,'2025-07-31 07:04:20','205',0,'0000-00-00',NULL),
(434,21,'Table 2','vatitem',0,75.00,'2025-07-31 07:04:20','205',0,'0000-00-00',NULL),
(435,22,'Table 2','VAT ITEM 3',1,150.00,'2025-07-31 07:09:23','205',0,'0000-00-00',NULL),
(436,23,'Table 2','VAT ITEM 3',1,150.00,'2025-08-01 12:38:56','211',0,'0000-00-00',NULL),
(437,23,'Table 2','vatitem',0,75.00,'2025-08-01 12:38:56','211',0,'0000-00-00',NULL),
(438,24,'Table 5','VAT ITEM 3',1,150.00,'2025-08-15 09:51:37','206',0,'0000-00-00',NULL),
(439,24,'Table 5','vatitem',0,75.00,'2025-08-15 09:51:37','206',0,'0000-00-00',NULL),
(440,24,'Table 5','VAT ITEM 4',1,100.00,'2025-08-15 09:51:37','206',0,'0000-00-00',NULL),
(441,208,'','Petha',1,321.00,'2025-08-25 16:15:43',NULL,1,'0000-00-00',NULL),
(442,208,'','KalakandPakeeza',1,556.40,'2025-08-25 16:15:43',NULL,1,'0000-00-00',NULL),
(443,208,'','Pakeeza',1,556.40,'2025-08-25 16:15:43',NULL,1,'0000-00-00',NULL),
(444,25,'Table 1','VAT ITEM 3',1,150.00,'2025-08-26 08:41:41','214',0,'0000-00-00',NULL),
(445,25,'Table 1','VAT ITEM 4',1,100.00,'2025-08-26 08:41:41','214',0,'0000-00-00',NULL),
(446,26,'Table 4','VAT ITEM 4',2,200.00,'2025-08-26 08:45:02','212',0,'0000-00-00',NULL),
(447,27,'Table 7','vatitem',0,75.00,'2025-08-26 08:45:19','213',0,'0000-00-00',NULL),
(448,27,'Table 7','GulabJamaun/plate',2,120.00,'2025-08-26 08:45:19','213',0,'0000-00-00',NULL),
(449,27,'Table 7','VAT ITEM 3',1,150.00,'2025-08-26 08:45:19','213',0,'0000-00-00',NULL),
(450,28,'Table 5','VAT ITEM 4',1,100.00,'2025-08-26 08:57:09','215',0,'0000-00-00',NULL),
(451,28,'Table 5','VAT ITEM 3',1,150.00,'2025-08-26 08:57:09','215',0,'0000-00-00',NULL),
(452,29,'Table 3','vatitem',0,75.00,'2025-08-26 08:57:18','216',0,'0000-00-00',NULL),
(453,30,'Table 6','VAT ITEM 4',7,700.00,'2025-08-26 08:57:28','215',0,'0000-00-00',NULL),
(454,31,'Take Away','vatitem',0,75.00,'2025-08-26 08:57:37','215',0,'0000-00-00',NULL),
(455,31,'Take Away','VAT ITEM 4',1,100.00,'2025-08-26 08:57:37','215',0,'0000-00-00',NULL),
(456,32,'Table 7','VAT ITEM 4',4,400.00,'2025-08-26 09:02:39','217',0,'0000-00-00',NULL),
(457,33,'Take Away','VAT ITEM 4',2,200.00,'2025-08-26 09:03:46','218',0,'0000-00-00',NULL),
(458,33,'Take Away','VAT ITEM 3',1,150.00,'2025-08-26 09:03:46','218',0,'0000-00-00',NULL),
(459,34,'Table 7','VAT ITEM 3',1,150.00,'2025-08-26 09:11:34','222',0,'0000-00-00',NULL),
(460,34,'Table 7','vatitem',0,75.00,'2025-08-26 09:11:34','222',0,'0000-00-00',NULL),
(461,35,'Table 5','vatitem',1,210.00,'2025-08-26 09:11:46','219',0,'0000-00-00',NULL),
(462,35,'Table 5','VAT ITEM 4',1,100.00,'2025-08-26 09:11:46','219',0,'0000-00-00',NULL),
(463,36,'Table 3','VAT ITEM 4',2,200.00,'2025-08-26 09:59:38','220',0,'0000-00-00',NULL),
(464,36,'Table 3','VAT ITEM 3',1,150.00,'2025-08-26 09:59:38','220',0,'0000-00-00',NULL),
(465,36,'Table 3','vatitem',0,75.00,'2025-08-26 09:59:38','220',0,'0000-00-00',NULL),
(466,37,'Table 6','VAT ITEM 3',2,300.00,'2025-08-26 10:10:40','221',0,'0000-00-00',NULL),
(467,37,'Table 6','vatitem',0,75.00,'2025-08-26 10:10:40','221',0,'0000-00-00',NULL),
(468,37,'Table 6','GulabJamaun/plate',2,120.00,'2025-08-26 10:10:40','221',0,'0000-00-00',NULL),
(469,37,'Table 6','VAT ITEM 4',1,100.00,'2025-08-26 10:10:40','221',0,'0000-00-00',NULL),
(470,38,'Table 4','VAT ITEM 4',2,200.00,'2025-08-26 10:10:54','221',0,'0000-00-00',NULL),
(471,38,'Table 4','VAT ITEM 3',2,300.00,'2025-08-26 10:10:54','221',0,'0000-00-00',NULL),
(472,38,'Table 4','vatitem',0,75.00,'2025-08-26 10:10:54','221',0,'0000-00-00',NULL),
(473,39,'Table 5','VAT ITEM 3',5,750.00,'2025-08-26 10:11:07','222',0,'0000-00-00',NULL),
(474,2,'Table 3','vatitem',0,75.00,'2025-08-27 08:46:16','223',0,'0000-00-00',NULL),
(475,2,'Table 3','VAT ITEM 4',1,100.00,'2025-08-27 08:46:16','223',0,'0000-00-00',NULL),
(476,3,'Table 10','VAT ITEM 4',3,300.00,'2025-08-27 08:46:26','223',0,'0000-00-00',NULL),
(477,4,'Table 5','vatitem',0,75.00,'2025-08-27 08:55:41','224',0,'0000-00-00',NULL),
(478,4,'Table 5','VAT ITEM 3',1,150.00,'2025-08-27 08:55:41','224',0,'0000-00-00',NULL),
(479,5,'Table 4','VAT ITEM 4',4,400.00,'2025-08-27 09:06:06','225',0,'0000-00-00',NULL),
(480,5,'Table 4','VAT ITEM 3',2,300.00,'2025-08-27 09:06:06','225',0,'0000-00-00',NULL),
(481,5,'Table 4','GulabJamaun/plate',1,60.00,'2025-08-27 09:06:06','225',0,'0000-00-00',NULL),
(482,6,'Table 9','VAT ITEM 3',1,150.00,'2025-08-27 09:06:31','225',0,'0000-00-00',NULL),
(483,6,'Table 9','VAT ITEM 4',1,100.00,'2025-08-27 09:06:31','225',0,'0000-00-00',NULL),
(484,7,'Table 7','VAT ITEM 3',2,300.00,'2025-08-27 09:27:35','225',0,'0000-00-00',NULL),
(485,40,'Table 2','Kalakand',0,130.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(486,40,'Table 2','ChumChum',0,75.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(487,40,'Table 2','Bhare Chumchum',0,112.50,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(488,40,'Table 2','Mix Namkeen',1,160.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(489,40,'Table 2','Samosa',1,15.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(490,40,'Table 2','pakode',0,65.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(491,40,'Table 2','Rasgulla  Per plate',1,50.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(492,40,'Table 2','Rasmalai',1,90.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(493,40,'Table 2','Boil Milk',0,15.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(494,40,'Table 2','Sweet Milk',0,20.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(495,40,'Table 2','Sewiyan Namkeen',1,225.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(496,40,'Table 2','Mattar namkeen',0,65.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(497,40,'Table 2','Moong Dal Namkeen',0,80.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(498,40,'Table 2','Meetha Bdana',0,65.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(499,40,'Table 2','Amrati',0,105.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(500,40,'Table 2','jalebi',1,110.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(501,40,'Table 2','Coconut Barfi',1,260.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(502,40,'Table 2','Petha',0,75.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(503,40,'Table 2','Besan Barfi',0,65.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(504,40,'Table 2','Gujia',0,90.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(505,40,'Table 2','Besan Laddu',0,65.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(506,40,'Table 2','Doda Barfi',0,100.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(507,40,'Table 2','Patisa',0,85.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(508,40,'Table 2','Mix Mithai',0,87.50,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(509,40,'Table 2','Koya Mix',0,130.00,'2025-08-27 11:00:12','227',0,'0000-00-00',NULL),
(510,8,'Table 4','pakode',0,65.00,'2025-08-27 11:08:40','233',0,'2025-08-29',NULL),
(511,8,'Table 4','Samosa',1,15.00,'2025-08-27 11:08:40','233',0,'2025-08-29',NULL),
(512,8,'Table 4','Moong Dal Namkeen',0,80.00,'2025-08-27 11:08:40','233',0,'2025-08-29',NULL),
(513,8,'Table 4','Sewiyan Namkeen',0,75.00,'2025-08-27 11:08:40','233',0,'2025-08-29',NULL),
(514,41,'Table 3','Chai',4,60.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(515,41,'Table 3','Kalakand',0,130.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(516,41,'Table 3','KalakandPakeeza',0,130.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(517,41,'Table 3','Chocolate Barfi',0,130.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(518,41,'Table 3','Kaju Katli',0,250.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(519,41,'Table 3','Gujia',0,90.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(520,41,'Table 3','Doda Barfi',0,100.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(521,41,'Table 3','Patisa',2,765.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(522,41,'Table 3','moong dal pinni',0,100.00,'2025-08-27 16:33:11','228',0,'0000-00-00',NULL),
(523,42,'Table 7','Chocolate Barfi',0,130.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(524,42,'Table 7','KalakandPakeeza',0,130.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(525,42,'Table 7','GulabJamaun/plate',1,50.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(526,42,'Table 7','Rasgulla  Per plate',1,50.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(527,42,'Table 7','Rasmalai',1,90.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(528,42,'Table 7','Boil Milk',0,15.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(529,42,'Table 7','Sweet Milk',0,20.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(530,42,'Table 7','Mix Namkeen',0,80.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(531,42,'Table 7','Mattar namkeen',0,65.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(532,42,'Table 7','pakode',0,65.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(533,42,'Table 7','Moong Dal Namkeen',0,80.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(534,42,'Table 7','Samosa',1,15.00,'2025-08-28 03:49:57','229',0,'0000-00-00',NULL),
(535,43,'Table 3','KalakandPakeeza',0,130.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(536,43,'Table 3','Bhare Chumchum',0,112.50,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(537,43,'Table 3','Rasgulle',0,75.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(538,43,'Table 3','Petha',0,75.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(539,43,'Table 3','Meetha Bdana',0,65.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(540,43,'Table 3','Mix Mithai',0,87.50,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(541,43,'Table 3','GulabJamaun/plate',1,50.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(542,43,'Table 3','Rasgulla  Per plate',1,50.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(543,43,'Table 3','Rasmalai',1,90.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(544,43,'Table 3','Boil Milk',0,15.00,'2025-08-28 07:56:39','234',0,'2025-08-29',NULL),
(545,44,'Table 2','Mattar namkeen',0,65.00,'2025-08-28 10:17:29','232',0,'2025-08-29',NULL),
(546,44,'Table 2','Moong Dal Namkeen',0,80.00,'2025-08-28 10:17:29','232',0,'2025-08-29',NULL),
(547,44,'Table 2','Mix Namkeen',0.25,80.00,'2025-08-28 10:17:29','232',0,'2025-08-29',NULL),
(548,45,'Table 10','Kalakand',0.25,130.00,'2025-08-28 10:21:47','230',0,'2025-08-28',NULL),
(549,45,'Table 10','Milk Cake',0.25,120.00,'2025-08-28 10:21:47','230',0,'2025-08-28',NULL),
(550,45,'Table 10','ChumChum',0.25,75.00,'2025-08-28 10:21:47','230',0,'2025-08-28',NULL),
(551,45,'Table 10','Chocolate Barfi',0.25,130.00,'2025-08-28 10:21:47','230',0,'2025-08-28',NULL),
(552,45,'Table 10','Bhare Chumchum',0.25,112.50,'2025-08-28 10:21:47','230',0,'2025-08-28',NULL),
(553,46,'Table 7','GulabJamaun/plate',2,100.00,'2025-08-28 10:26:48','231',0,'2025-08-28',NULL),
(554,46,'Table 7','Boil Milk',0,0.18,'2025-08-28 10:26:48','231',0,'2025-08-28',NULL),
(555,46,'Table 7','Rasgulla  Per plate',1,50.00,'2025-08-28 10:26:48','231',0,'2025-08-28',NULL),
(556,46,'Table 7','Sewiyan Namkeen',0.25,75.00,'2025-08-28 10:26:48','231',0,'2025-08-28',NULL),
(557,47,'Table 5','Khoya Barfi',0.25,125.00,'2025-08-29 09:53:20','235',0,'2025-08-30',NULL),
(558,47,'Table 5','Milk Cake',0.25,120.00,'2025-08-29 09:53:20','235',0,'2025-08-30',NULL),
(559,47,'Table 5','Rasgulle',0.25,75.00,'2025-08-29 09:53:20','235',0,'2025-08-30',NULL),
(560,48,'Table 9','Rasgulle',0.25,75.00,'2025-08-29 09:53:31','236',0,'2025-08-30',NULL),
(561,48,'Table 9','Chocolate Barfi',0.25,130.00,'2025-08-29 09:53:31','236',0,'2025-08-30',NULL),
(562,48,'Table 9','Bhare Chumchum',0.25,112.50,'2025-08-29 09:53:31','236',0,'2025-08-30',NULL),
(563,49,'Table 4','GulabJamaun/plate',1,50.00,'2025-08-29 10:09:10','237',0,'2025-08-29',NULL),
(564,49,'Table 4','Rasgulla  Per plate',1,50.00,'2025-08-29 10:09:10','237',0,'2025-08-29',NULL),
(565,49,'Table 4','Sweet Milk',0.25,20.00,'2025-08-29 10:09:10','237',0,'2025-08-29',NULL),
(566,50,'Table 2','Rasgulla  Per plate',1,50.00,'2025-08-29 10:10:13','238',0,'2025-08-29',NULL),
(567,50,'Table 2','GulabJamaun/plate',1,50.00,'2025-08-29 10:10:13','238',0,'2025-08-29',NULL),
(568,50,'Table 2','Chai',1,15.00,'2025-08-29 10:10:13','238',0,'2025-08-29',NULL),
(569,51,'Table 9','Kalakand',0.25,130.00,'2025-08-29 10:11:09','239',0,'2025-08-29',NULL),
(570,51,'Table 9','Rasgulle',0.25,75.00,'2025-08-29 10:11:09','239',0,'2025-08-29',NULL),
(571,51,'Table 9','ChumChum',0.25,75.00,'2025-08-29 10:11:09','239',0,'2025-08-29',NULL),
(572,51,'Table 9','Bhare Chumchum',0.25,112.50,'2025-08-29 10:11:09','239',0,'2025-08-29',NULL),
(573,240,'','Malai Barfi',1,520.00,'2025-09-02 11:13:43',NULL,1,'2025-08-30',NULL),
(574,240,'','Milk Cake',1,480.00,'2025-09-02 11:13:43',NULL,1,'2025-08-30',NULL),
(575,52,'Table 1','Chai',2,30.00,'2025-09-03 12:49:35','241',0,'2025-08-30',NULL),
(576,52,'Table 1','Kalakand',1.25,650.00,'2025-09-03 12:49:35','241',0,'2025-08-30',NULL),
(577,52,'Table 1','Gulabjamun',1.25,400.00,'2025-09-03 12:49:35','241',0,'2025-08-30',NULL),
(578,53,'Table 2','Chai',1,15.00,'2025-09-03 12:55:08','242',0,'2025-08-30',NULL),
(579,53,'Table 2','Mattar namkeen',0.25,65.00,'2025-09-03 12:55:08','242',0,'2025-08-30',NULL),
(580,53,'Table 2','Mix Namkeen',0.25,80.00,'2025-09-03 12:55:08','242',0,'2025-08-30',NULL),
(581,53,'Table 2','Coconut Barfi',0.25,130.00,'2025-09-03 12:55:08','242',0,'2025-08-30',NULL),
(582,54,'Table 4','Kalakand',0.25,130.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(583,54,'Table 4','Milk Cake',0.25,120.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(584,54,'Table 4','Rasgulle',0.25,75.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(585,54,'Table 4','Kaju Katli',0.25,250.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(586,54,'Table 4','Coconut Barfi',0.25,130.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(587,54,'Table 4','Besan Barfi',0.25,65.00,'2025-09-03 17:39:10','253',0,'2025-09-06',NULL),
(588,55,'Table 3','Khoya Barfi',0.25,125.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(589,55,'Table 3','Milk Cake',0.25,120.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(590,55,'Table 3','Chocolate Barfi',0.25,130.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(591,55,'Table 3','Rasgulle',0.25,75.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(592,55,'Table 3','Amrati',0.25,105.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(593,55,'Table 3','Balushahi',0.25,65.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(594,55,'Table 3','Khoya Paneer Mix',0.25,125.00,'2025-09-04 07:01:06','250',0,'2025-09-06',NULL),
(595,56,'Table 5','Patisa',0.25,85.00,'2025-09-04 07:04:03','245',0,'2025-08-30',NULL),
(596,56,'Table 5','Koya Mix',0.25,130.00,'2025-09-04 07:04:03','245',0,'2025-08-30',NULL),
(597,56,'Table 5','Patisa',0.25,85.00,'2025-09-04 07:04:05','245',0,'2025-08-30',NULL),
(598,56,'Table 5','Koya Mix',0.25,130.00,'2025-09-04 07:04:05','245',0,'2025-08-30',NULL),
(599,57,'Table 5','Koya Mix',0.25,130.00,'2025-09-04 07:06:18','245',0,'2025-08-30',NULL),
(600,57,'Table 5','Patisa',0.25,85.00,'2025-09-04 07:06:18','245',0,'2025-08-30',NULL),
(601,57,'Table 5','Doda Barfi',0.25,100.00,'2025-09-04 07:06:18','245',0,'2025-08-30',NULL),
(602,58,'Table 5','Mix Mithai',0.25,87.50,'2025-09-04 07:08:57','245',0,'2025-08-30',NULL),
(603,58,'Table 5','Doda Barfi',0.25,100.00,'2025-09-04 07:08:57','245',0,'2025-08-30',NULL),
(604,59,'Table 5','Patisa',0.25,85.00,'2025-09-04 07:11:15','245',0,'2025-08-30',NULL),
(605,59,'Table 5','moong dal pinni',0.25,100.00,'2025-09-04 07:11:15','245',0,'2025-08-30',NULL),
(606,59,'Table 5','Doda Barfi',0.25,100.00,'2025-09-04 07:11:15','245',0,'2025-08-30',NULL),
(607,59,'Table 5','Khoya Paneer Mix',0.25,125.00,'2025-09-04 07:11:15','245',0,'2025-08-30',NULL),
(608,59,'Table 5','jalebi',0.25,55.00,'2025-09-04 07:11:15','245',0,'2025-08-30',NULL),
(609,61,'Table 5','Balushahi',0.25,65.00,'2025-09-04 07:12:30','245',0,'2025-08-30',NULL),
(610,61,'Table 5','Gujia',0.25,90.00,'2025-09-04 07:12:30','245',0,'2025-08-30',NULL),
(611,61,'Table 5','moong dal pinni',0.25,100.00,'2025-09-04 07:12:30','245',0,'2025-08-30',2),
(612,62,'Table 5','Koya Mix',0.25,130.00,'2025-09-04 07:13:19','245',0,'2025-08-30',2),
(613,62,'Table 5','moong dal pinni',0.25,100.00,'2025-09-04 07:13:19','245',0,'2025-08-30',2),
(614,63,'Table 1','Mattar namkeen',0.25,65.00,'2025-09-06 06:47:40','243',0,'2025-08-30',1),
(615,63,'Table 1','Sewiyan Namkeen',0.25,75.00,'2025-09-06 06:47:40','243',0,'2025-08-30',1),
(616,63,'Table 1','Mix Namkeen',0.25,80.00,'2025-09-06 06:47:40','243',0,'2025-08-30',1),
(617,64,'Table 2','Khoya Barfi',0.25,125.00,'2025-09-06 07:36:20','246',0,'2025-08-30',NULL),
(618,64,'Table 2','KalakandPakeeza',0.25,130.00,'2025-09-06 07:36:20','246',0,'2025-08-30',NULL),
(619,64,'Table 2','ChumChum',0.25,75.00,'2025-09-06 07:36:20','246',0,'2025-08-30',NULL),
(620,65,'Take Away','GulabJamaun/plate',2,100.00,'2025-09-06 07:36:37','244',0,'2025-08-30',NULL),
(621,65,'Take Away','Rasgulla  Per plate',1,50.00,'2025-09-06 07:36:37','244',0,'2025-08-30',NULL),
(622,65,'Take Away','Rasmalai',1,90.00,'2025-09-06 07:36:37','244',0,'2025-08-30',NULL),
(623,65,'Take Away','Sweet Milk',0.25,20.00,'2025-09-06 07:36:37','244',0,'2025-08-30',NULL),
(624,66,'Take Away','Khoya Barfi',0.25,125.00,'2025-09-06 07:39:40','253',0,'2025-09-06',NULL),
(625,66,'Take Away','KalakandPakeeza',0.25,130.00,'2025-09-06 07:39:40','253',0,'2025-09-06',NULL),
(626,66,'Take Away','ChumChum',0.25,75.00,'2025-09-06 07:39:40','253',0,'2025-09-06',NULL),
(627,67,'Room2','KalakandPakeeza',0.25,130.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(628,67,'Room2','Chocolate Barfi',0.25,130.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(629,67,'Room2','Milk Cake',0.25,120.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(630,67,'Room2','Khoya Barfi',0.25,125.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(631,67,'Room2','Bhare Chumchum',0.25,112.50,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(632,67,'Room2','Mix Mithai',0.25,87.50,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(633,67,'Room2','Patisa',0.25,85.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(634,67,'Room2','Koya Mix',0.25,130.00,'2025-09-06 07:40:06','247',0,'2025-08-31',NULL),
(635,68,'Room1','Chai',3,45.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(636,68,'Room1','Balushahi',0.25,65.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(637,68,'Room1','Besan Laddu',0.25,65.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(638,68,'Room1','Besan Barfi',0.25,65.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(639,68,'Room1','jalebi',0.25,55.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(640,68,'Room1','Gujia',0.25,90.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(641,68,'Room1','Meetha Bdana',0.25,65.00,'2025-09-06 07:42:57','251',0,'2025-09-06',NULL),
(642,69,'Room2','Amrati',0.25,105.00,'2025-09-06 07:43:15','248',0,'2025-09-06',NULL),
(643,69,'Room2','Besan Barfi',0.25,65.00,'2025-09-06 07:43:15','248',0,'2025-09-06',NULL),
(644,69,'Room2','Gujia',0.25,90.00,'2025-09-06 07:43:15','248',0,'2025-09-06',NULL),
(645,69,'Room2','Coconut Barfi',0.25,130.00,'2025-09-06 07:43:15','248',0,'2025-09-06',NULL),
(646,70,'Table 9','jalebi',0.25,55.00,'2025-09-06 07:43:33','249',0,'2025-09-06',NULL),
(647,70,'Table 9','Balushahi',0.25,65.00,'2025-09-06 07:43:33','249',0,'2025-09-06',NULL),
(648,71,'Room2','Kalakand',0.25,130.00,'2025-09-06 07:50:58','253',0,'2025-09-06',NULL),
(649,71,'Room2','KalakandPakeeza',0.25,130.00,'2025-09-06 07:50:58','253',0,'2025-09-06',NULL),
(650,72,'Table11','Sewiyan Namkeen',0.25,75.00,'2025-09-06 08:25:22','252',0,'2025-09-06',NULL),
(651,72,'Table11','Moong Dal Namkeen',0.25,80.00,'2025-09-06 08:25:22','252',0,'2025-09-06',NULL),
(652,72,'Table11','Mix Namkeen',0.25,80.00,'2025-09-06 08:25:22','252',0,'2025-09-06',NULL),
(653,73,'Table12','Sewiyan Namkeen',0.25,75.00,'2025-09-06 08:28:20','253',0,'2025-09-06',NULL),
(654,73,'Table12','Moong Dal Namkeen',0.25,80.00,'2025-09-06 08:28:20','253',0,'2025-09-06',NULL),
(655,73,'Table12','Samosa',1,15.00,'2025-09-06 08:28:20','253',0,'2025-09-06',NULL),
(656,74,'Room5','Gajar Barfi',0.25,115.00,'2025-09-06 08:32:45','253',0,'2025-09-06',NULL),
(657,74,'Room5','Kaju Katli',0.25,250.00,'2025-09-06 08:32:45','253',0,'2025-09-06',NULL),
(658,74,'Room5','Coconut Barfi',0.25,130.00,'2025-09-06 08:32:45','253',0,'2025-09-06',NULL),
(659,75,'Room4','Gulabjamun',0.25,80.00,'2025-09-06 08:34:53','253',0,'2025-09-06',NULL),
(660,75,'Room4','Gajar Barfi',0.25,115.00,'2025-09-06 08:34:53','253',0,'2025-09-06',NULL),
(661,75,'Room4','Petha',0.25,75.00,'2025-09-06 08:34:53','253',0,'2025-09-06',NULL),
(662,75,'Room4','Amrati',0.25,105.00,'2025-09-06 08:34:53','253',0,'2025-09-06',NULL),
(663,76,'Table11','Gajar Barfi',0.25,115.00,'2025-09-06 08:42:27','253',0,'2025-09-06',NULL),
(664,76,'Table11','jalebi',0.25,55.00,'2025-09-06 08:42:27','253',0,'2025-09-06',NULL),
(665,76,'Table11','Coconut Barfi',0.25,130.00,'2025-09-06 08:42:27','253',0,'2025-09-06',NULL),
(666,77,'Table11','Gajar Barfi',0.25,115.00,'2025-09-06 08:50:03','253',0,'2025-09-06',1),
(667,77,'Table11','Petha',0.25,75.00,'2025-09-06 08:50:03','253',0,'2025-09-06',1),
(668,77,'Table11','Meetha Bdana',0.25,65.00,'2025-09-06 08:50:03','253',0,'2025-09-06',1),
(669,78,'Table 7','Rasgulle',0.25,75.00,'2025-09-08 06:34:17','254',0,'2025-09-07',NULL),
(670,78,'Table 7','ChumChum',0.25,75.00,'2025-09-08 06:34:17','254',0,'2025-09-07',NULL),
(671,79,'Take Away','KalakandPakeeza',0.25,130.00,'2025-09-13 02:44:32','255',0,'2025-09-07',1),
(672,79,'Take Away','Bhare Chumchum',0.25,112.50,'2025-09-13 02:44:32','255',0,'2025-09-07',1),
(673,79,'Take Away','ChumChum',0.25,75.00,'2025-09-13 02:44:32','255',0,'2025-09-07',1),
(674,79,'Take Away','Amrati',0.25,105.00,'2025-09-13 02:44:32','255',0,'2025-09-07',1),
(675,80,'Take Away','moong dal pinni',0.25,100.00,'2025-09-13 02:44:44','255',0,'2025-09-07',1),
(676,81,'Table 4','Samosa',1,15.00,'2025-09-13 02:48:17','256',0,'2025-09-07',1),
(677,81,'Table 4','pakode',0.25,65.00,'2025-09-13 02:48:17','256',0,'2025-09-07',1),
(678,81,'Table 4','Sewiyan Namkeen',0.25,75.00,'2025-09-13 02:48:17','256',0,'2025-09-07',1),
(679,81,'Table 4','Mix Namkeen',0.25,80.00,'2025-09-13 02:48:17','256',0,'2025-09-07',1),
(680,82,'Table 4','Mix Namkeen',0.25,80.00,'2025-09-13 02:48:32','256',0,'2025-09-07',1),
(681,82,'Table 4','Sewiyan Namkeen',0.25,75.00,'2025-09-13 02:48:32','256',0,'2025-09-07',1),
(682,83,'Table 7','Kalakand',0.25,130.00,'2025-09-13 09:34:24','257',0,'2025-09-07',2),
(683,83,'Table 7','Milk Cake',0.25,120.00,'2025-09-13 09:34:24','257',0,'2025-09-07',2),
(684,83,'Table 7','Bhare Chumchum',0.25,112.50,'2025-09-13 09:34:24','257',0,'2025-09-07',2),
(685,84,'Room2','Chai',4,60.00,'2025-09-13 09:36:07','258',0,'2025-09-07',1),
(686,84,'Room2','GulabJamaun/plate',2,100.00,'2025-09-13 09:36:07','258',0,'2025-09-07',1),
(687,84,'Room2','Rasgulla  Per plate',1,50.00,'2025-09-13 09:36:07','258',0,'2025-09-07',1),
(688,84,'Room2','Rasmalai',1,90.00,'2025-09-13 09:36:07','258',0,'2025-09-07',1),
(689,85,'Table 4','Mix Mithai',0.25,87.50,'2025-09-23 15:57:12',NULL,1,'2025-09-07',1),
(690,85,'Table 4','Doda Barfi',0.25,100.00,'2025-09-23 15:57:12',NULL,1,'2025-09-07',1),
(691,85,'Table 4','Khoya Paneer Mix',0.25,125.00,'2025-09-23 15:57:12',NULL,1,'2025-09-07',1);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items_gst`
--

DROP TABLE IF EXISTS `order_items_gst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items_gst` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` decimal(10,0) NOT NULL,
  `uom` varchar(50) NOT NULL,
  `rate` decimal(10,2) NOT NULL,
  `cgst` decimal(10,2) NOT NULL,
  `sgst` decimal(10,2) NOT NULL,
  `igst` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items_gst`
--

LOCK TABLES `order_items_gst` WRITE;
/*!40000 ALTER TABLE `order_items_gst` DISABLE KEYS */;
INSERT INTO `order_items_gst` VALUES
(1,114,'Table 1','Mineral Water',1,'',40.00,0.00,0.00,0.00,0.00,40.00,'2025-06-12 06:27:07','107',0),
(2,114,'Table 1','Coke 320ML',1,'',40.00,0.00,0.00,0.00,0.00,40.00,'2025-06-12 06:27:07','107',0),
(3,114,'Table 1','test',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-12 06:27:07','107',0),
(4,115,'Table 1','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-12 06:36:15','107',0),
(5,115,'Table 1','Pepsit 500ML',2,'',50.00,3.50,3.50,0.00,3.50,100.00,'2025-06-12 06:36:15','107',0),
(6,117,'Table 1','Tawa Roti',2,'',25.00,0.00,0.00,0.00,0.00,50.00,'2025-06-12 06:39:25','107',0),
(7,117,'Table 1','Tandoori Roti',2,'',25.00,0.00,0.00,0.00,0.00,50.00,'2025-06-12 06:39:25','107',0),
(8,117,'Table 1',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-12 06:39:25','107',0),
(9,118,'Table 1','Coke 320ML',3,'',40.00,3.50,3.50,0.00,2.80,120.00,'2025-06-12 06:39:53','107',0),
(10,118,'Table 1','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-12 06:39:53','107',0),
(11,118,'Table 1','Mineral Water',2,'',40.00,2.50,2.50,0.00,2.00,80.00,'2025-06-12 06:39:53','107',0),
(12,119,'Table 3','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-12 06:53:00','106',0),
(13,119,'Table 3','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-12 06:53:00','106',0),
(14,120,'Table 10','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-12 06:54:07','105',0),
(15,120,'Table 10','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-12 06:54:07','105',0),
(16,121,'Table 10','Aloo Parantha',6,'',80.00,0.00,0.00,0.00,0.00,480.00,'2025-06-12 10:49:01','108',0),
(17,121,'Table 10','Paneer Kulcha',1,'',200.00,2.50,2.50,0.00,10.00,200.00,'2025-06-12 10:49:01','108',0),
(18,121,'Table 10','Omlette',7,'',100.00,2.50,2.50,0.00,5.00,700.00,'2025-06-12 10:49:01','108',0),
(19,122,'Table 1','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-17 06:46:10','111',0),
(20,122,'Table 1','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-17 06:46:10','111',0),
(21,122,'Table 1','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-17 06:46:10','111',0),
(22,122,'Table 1','Paneer Kulcha',2,'',200.00,2.50,2.50,0.00,10.00,400.00,'2025-06-17 06:46:10','111',0),
(23,123,'Table 9','Mutton Curry',1,'',0.00,0.00,0.00,0.00,0.00,0.00,'2025-06-17 06:46:20','112',0),
(24,123,'Table 9','Mutton Rogan Josh',1,'',570.00,0.00,0.00,0.00,0.00,570.00,'2025-06-17 06:46:20','112',0),
(25,123,'Table 9','Mutton Rogan',1,'',530.00,0.00,0.00,0.00,0.00,530.00,'2025-06-17 06:46:20','112',0),
(26,125,'Table 2','Chicken Briyani',1,'',250.00,2.50,2.50,0.00,12.50,250.00,'2025-06-18 05:41:49','114',0),
(27,125,'Table 2','Mutton Briyani',1,'',350.00,2.50,2.50,0.00,17.50,350.00,'2025-06-18 05:41:49','114',0),
(28,125,'Table 2','Basmati Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-18 05:41:49','114',0),
(29,125,'Table 2','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-18 05:41:49','114',0),
(30,125,'Table 2','Chicken Curry',1,'',250.00,0.00,0.00,0.00,0.00,250.00,'2025-06-18 05:41:49','114',0),
(31,125,'Table 2','Tawa Roti',3,'',25.00,0.00,0.00,0.00,0.00,75.00,'2025-06-18 05:41:49','114',0),
(32,126,'Table 2','Tawa Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-18 05:42:05','114',0),
(33,126,'Table 2','Tandoori Roti',3,'',25.00,0.00,0.00,0.00,0.00,75.00,'2025-06-18 05:42:05','114',0),
(34,127,'Table 2','Chicken Curry',1,'',250.00,0.00,0.00,0.00,0.00,250.00,'2025-06-20 06:21:35','116',0),
(35,127,'Table 2','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-06-20 06:21:35','116',0),
(36,127,'Table 2','Paneer Briyani',1,'',350.00,2.50,2.50,0.00,17.50,350.00,'2025-06-20 06:21:35','116',0),
(37,127,'Table 2','Mutton Briyani',1,'',350.00,2.50,2.50,0.00,17.50,350.00,'2025-06-20 06:21:35','116',0),
(38,127,'Table 2','Chicken Curry',1,'',250.00,0.00,0.00,0.00,0.00,250.00,'2025-06-20 06:21:42','116',0),
(39,127,'Table 2','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-06-20 06:21:42','116',0),
(40,127,'Table 2','Paneer Briyani',1,'',350.00,2.50,2.50,0.00,17.50,350.00,'2025-06-20 06:21:42','116',0),
(41,127,'Table 2','Mutton Briyani',1,'',350.00,2.50,2.50,0.00,17.50,350.00,'2025-06-20 06:21:42','116',0),
(42,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:16:40',NULL,1),
(43,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:16:40',NULL,1),
(44,128,'Table 10','Basmati Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:16:40',NULL,1),
(45,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:16:40',NULL,1),
(46,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:21:29',NULL,1),
(47,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:21:29',NULL,1),
(48,128,'Table 10','Basmati Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:21:29',NULL,1),
(49,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:21:29',NULL,1),
(50,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:25:50',NULL,1),
(51,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:25:50',NULL,1),
(52,128,'Table 10','Basmati Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:25:50',NULL,1),
(53,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:25:50',NULL,1),
(54,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:26:20',NULL,1),
(55,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:26:20',NULL,1),
(56,128,'Table 10','Basmati Rice',2,'',100.00,2.50,2.50,0.00,5.00,200.00,'2025-06-21 07:26:20',NULL,1),
(57,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:26:20',NULL,1),
(58,129,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:31:24','118',0),
(59,129,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:31:24','118',0),
(60,130,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:33:29','118',0),
(61,130,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:33:29','118',0),
(62,131,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:34:09','118',0),
(63,131,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:34:09','118',0),
(64,132,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:35:31','118',0),
(65,132,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:35:31','118',0),
(66,132,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:36:15','118',0),
(67,132,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:36:15','118',0),
(68,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:36:46',NULL,1),
(69,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:36:46',NULL,1),
(70,128,'Table 10','Basmati Rice',2,'',100.00,2.50,2.50,0.00,5.00,200.00,'2025-06-21 07:36:46',NULL,1),
(71,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:36:46',NULL,1),
(72,128,'Table 10','Tawa Roti',5,'',25.00,0.00,0.00,0.00,0.00,125.00,'2025-06-21 07:37:50',NULL,1),
(73,128,'Table 10','Daal Tarka',3,'',120.00,0.00,0.00,0.00,0.00,360.00,'2025-06-21 07:37:50',NULL,1),
(74,128,'Table 10','Basmati Rice',2,'',100.00,2.50,2.50,0.00,5.00,200.00,'2025-06-21 07:37:50',NULL,1),
(75,128,'Table 10','Peas Pulao Rice',1,'',100.00,2.50,2.50,0.00,5.00,100.00,'2025-06-21 07:37:50',NULL,1),
(76,133,'Table 10','Tawa Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:38:23',NULL,1),
(77,133,'Table 10','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:38:23',NULL,1),
(78,133,'Table 10',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:38:23',NULL,1),
(79,134,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:44:38','118',0),
(80,134,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:44:38','118',0),
(81,134,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-21 07:48:28','118',0),
(82,134,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-21 07:48:28','118',0),
(83,135,'Table 3','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-06-21 08:00:03','115',0),
(84,135,'Table 3','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-21 08:00:03','115',0),
(85,135,'Table 3','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-21 08:00:03','115',0),
(86,135,'Table 3','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-21 08:00:03','115',0),
(87,136,'Table 3','Aloo Parantha',4,'',80.00,0.00,0.00,0.00,0.00,320.00,'2025-06-21 08:59:38','117',0),
(88,136,'Table 3','Namkeen Parantha',3,'',65.00,0.00,0.00,0.00,0.00,195.00,'2025-06-21 08:59:38','117',0),
(89,136,'Table 3','Omlette',2,'',100.00,2.50,2.50,0.00,5.00,200.00,'2025-06-21 08:59:38','117',0),
(90,137,'Table 9','Tawa Roti',2,'',25.00,0.00,0.00,0.00,0.00,50.00,'2025-06-21 09:00:04','118',0),
(91,137,'Table 9',' Missi Roti',5,'',35.00,0.00,0.00,0.00,0.00,175.00,'2025-06-21 09:00:04','118',0),
(92,137,'Table 9','Basmati Rice',2,'',100.00,2.50,2.50,0.00,5.00,200.00,'2025-06-21 09:00:04','118',0),
(93,137,'Table 9','Jeera Rice',3,'',100.00,2.50,2.50,0.00,5.00,300.00,'2025-06-21 09:00:04','118',0),
(94,137,'Table 9','Mutton Briyani',3,'',350.00,2.50,2.50,0.00,17.50,1050.00,'2025-06-21 09:00:04','118',0),
(95,137,'Table 9','Paneer Briyani',2,'',350.00,2.50,2.50,0.00,17.50,700.00,'2025-06-21 09:00:04','118',0),
(96,138,'Table 6','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-21 10:14:05','119',0),
(97,138,'Table 6','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-21 10:14:05','119',0),
(98,138,'Table 6','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-06-21 10:14:05','119',0),
(99,138,'Table 6','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-21 10:14:05','119',0),
(100,138,'Table 6','Namkeen Parantha',1,'',65.00,0.00,0.00,0.00,0.00,65.00,'2025-06-21 10:14:05','119',0),
(101,138,'Table 6','Paneer Kulcha',1,'',200.00,2.50,2.50,0.00,10.00,200.00,'2025-06-21 10:14:05','119',0),
(102,139,'Table 5','Tawa Roti',12,'',25.00,0.00,0.00,0.00,0.00,300.00,'2025-06-23 06:04:55','120',0),
(103,139,'Table 5','Mutton Briyani',2,'',350.00,2.50,2.50,0.00,17.50,700.00,'2025-06-23 06:04:55','120',0),
(104,139,'Table 5','Paneer Briyani',3,'',350.00,2.50,2.50,0.00,17.50,1050.00,'2025-06-23 06:04:55','120',0),
(105,139,'Table 5','Chicken Briyani',3,'',250.00,2.50,2.50,0.00,12.50,750.00,'2025-06-23 06:04:55','120',0),
(106,139,'Table 5','Peas Pulao Rice',4,'',100.00,2.50,2.50,0.00,5.00,400.00,'2025-06-23 06:04:55','120',0),
(107,139,'Table 5','Basmati Rice',4,'',100.00,2.50,2.50,0.00,5.00,400.00,'2025-06-23 06:04:55','120',0),
(108,139,'Table 5','Dal Fry',2,'',80.00,2.50,2.50,0.00,4.00,160.00,'2025-06-23 06:04:55','120',0),
(109,139,'Table 5','Dal Tadka',2,'',80.00,2.50,2.50,0.00,4.00,160.00,'2025-06-23 06:04:55','120',0),
(110,139,'Table 5','Dal Palak',2,'',80.00,2.50,2.50,0.00,4.00,160.00,'2025-06-23 06:04:55','120',0),
(111,139,'Table 5','Dal Makhani',1,'',120.00,2.50,2.50,0.00,6.00,120.00,'2025-06-23 06:04:55','120',0),
(112,139,'Table 5','Chicken Mughlai',7,'',280.00,0.00,0.00,0.00,0.00,1960.00,'2025-06-23 06:04:55','120',0),
(113,140,'Table 3','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-06-23 10:35:43',NULL,1),
(114,140,'Table 3','Mineral Water',1,'',40.00,2.50,2.50,0.00,2.00,40.00,'2025-06-23 10:35:43',NULL,1),
(115,140,'Table 3','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-23 10:35:43',NULL,1),
(116,140,'Table 3','Coke 320ML',3,'',40.00,3.50,3.50,0.00,2.80,120.00,'2025-06-23 10:35:43',NULL,1),
(117,140,'Table 3','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-06-23 10:35:43',NULL,1),
(118,140,'Table 3','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-23 10:35:43',NULL,1),
(119,140,'Table 3','Paneer Kulcha',2,'',200.00,2.50,2.50,0.00,10.00,400.00,'2025-06-23 10:35:43',NULL,1),
(120,141,'Table 7','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-06-23 15:40:07','121',0),
(121,141,'Table 7','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-06-23 15:40:07','121',0),
(122,141,'Table 7','Paneer Kulcha',1,'',200.00,2.50,2.50,0.00,10.00,200.00,'2025-06-23 15:40:07','121',0),
(123,141,'Table 7','Namkeen Parantha',1,'',65.00,0.00,0.00,0.00,0.00,65.00,'2025-06-23 15:40:07','121',0),
(124,141,'Table 7','Plain Prantha',1,'',80.00,2.50,2.50,0.00,4.00,80.00,'2025-06-23 15:40:07','121',0),
(125,141,'Table 7','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-23 15:40:07','121',0),
(126,141,'Table 7','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-23 15:40:07','121',0),
(127,141,'Table 7','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-06-23 15:40:07','121',0),
(128,142,'Table 9','Tawa Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-24 11:46:48','122',0),
(129,142,'Table 9','Tandoori Roti',1,'',25.00,0.00,0.00,0.00,0.00,25.00,'2025-06-24 11:46:48','122',0),
(130,142,'Table 9',' Missi Roti',1,'',35.00,0.00,0.00,0.00,0.00,35.00,'2025-06-24 11:46:48','122',0),
(131,142,'Table 9','Chanaa Daal',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-06-24 11:46:48','122',0),
(132,142,'Table 9','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-06-24 11:46:48','122',0),
(133,143,'Table 5','Samosa',2,'',20.00,2.50,2.50,0.00,1.00,40.00,'2025-06-26 06:11:21','123',0),
(134,143,'Table 5','Paneer Kulcha',1,'',200.00,2.50,2.50,0.00,10.00,200.00,'2025-06-26 06:11:21','123',0),
(135,143,'Table 5','Plain Prantha',2,'',80.00,2.50,2.50,0.00,4.00,160.00,'2025-06-26 06:11:21','123',0),
(136,143,'Table 5','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-06-26 06:11:21','123',0),
(137,143,'Table 5','Coke 320ML',1,'',40.00,3.50,3.50,0.00,2.80,40.00,'2025-06-26 06:11:21','123',0),
(138,143,'Table 5','Pepsit 500ML',1,'',50.00,3.50,3.50,0.00,3.50,50.00,'2025-06-26 06:11:21','123',0),
(139,124,'hgfh','Pepsit 500ML',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 08:18:17',NULL,1),
(140,124,'hgfh','Coke 320ML',1,'',40.00,0.00,0.00,0.00,0.00,40.00,'2025-07-08 08:18:17',NULL,1),
(141,124,'hgfh','Aloo Pyaj  Parantha',5,'',100.00,0.00,0.00,0.00,0.00,500.00,'2025-07-08 08:18:17',NULL,1),
(142,125,'','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 08:20:17',NULL,1),
(143,126,'','Aloo Parantha',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-07-08 08:25:38',NULL,1),
(144,127,'','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 08:28:08',NULL,1),
(145,128,'','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 08:29:06',NULL,1),
(146,129,'','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 08:31:00',NULL,1),
(147,130,'','Aloo Pyaj  Parantha',1,'',100.00,0.00,0.00,0.00,0.00,100.00,'2025-07-08 08:38:21',NULL,1),
(148,130,'','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 08:38:21',NULL,1),
(149,131,'','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-07-08 08:40:43',NULL,1),
(150,132,'','Mutton Rogan Josh',1,'',570.00,0.00,0.00,0.00,0.00,570.00,'2025-07-08 08:43:20',NULL,1),
(151,133,'','Chanaa Daal',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 09:23:28',NULL,1),
(152,134,'','Dal Fry',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-07-08 09:25:26',NULL,1),
(153,135,'','Daal Tarka',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 10:04:23',NULL,1),
(154,135,'','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 10:04:23',NULL,1),
(155,136,'','Chanaa Daal',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 15:25:10',NULL,1),
(156,136,'','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 15:25:10',NULL,1),
(157,136,'','Dal Fry',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-07-08 15:25:10',NULL,1),
(158,140,'yrtfyrtyrt','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-07-08 15:58:40',NULL,1),
(159,140,'yrtfyrtyrt','Dal Fry',1,'',80.00,0.00,0.00,0.00,0.00,80.00,'2025-07-08 15:58:40',NULL,1),
(160,140,'yrtfyrtyrt','Salt Lassi',1,'',50.00,0.00,0.00,0.00,0.00,50.00,'2025-07-08 15:58:40',NULL,1),
(161,148,'','Chanaa Daal',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 16:12:23',NULL,1),
(162,148,'','Chanaa Daal',1,'',120.00,0.00,0.00,0.00,0.00,120.00,'2025-07-08 16:12:23',NULL,1),
(163,148,'','Chicken Mughlai',1,'',280.00,0.00,0.00,0.00,0.00,280.00,'2025-07-08 16:12:23',NULL,1),
(164,149,'','Namkeen Parantha',1,'',65.00,0.00,0.00,0.00,0.00,65.00,'2025-07-08 16:17:40',NULL,1),
(165,149,'','Mutton Curry',1,'',0.00,0.00,0.00,0.00,0.00,0.00,'2025-07-08 16:17:40',NULL,1),
(166,154,'','Khoya Barfi',1,'',500.00,0.00,0.00,0.00,0.00,500.00,'2025-07-09 03:26:30',NULL,1),
(167,154,'','Malai Barfi',1,'',520.00,0.00,0.00,0.00,0.00,520.00,'2025-07-09 03:26:30',NULL,1),
(168,154,'','Balushahi',1,'',260.00,0.00,0.00,0.00,0.00,260.00,'2025-07-09 03:26:30',NULL,1),
(169,155,'ggdfgdfg','Gulabjamun',2,'',320.00,0.00,0.00,0.00,0.00,640.00,'2025-07-09 06:06:46',NULL,1),
(170,155,'ggdfgdfg','Malai Barfi',2,'',520.00,0.00,0.00,0.00,0.00,1040.00,'2025-07-09 06:06:46',NULL,1),
(171,155,'ggdfgdfg','Gulabjamun',1,'',320.00,0.00,0.00,0.00,0.00,320.00,'2025-07-09 06:06:46',NULL,1),
(172,155,'ggdfgdfg','',1,'',0.00,0.00,0.00,0.00,0.00,0.00,'2025-07-09 06:06:46',NULL,1),
(173,156,'','Rasgulle',1,'',300.00,0.00,0.00,0.00,0.00,300.00,'2025-07-09 06:10:22',NULL,1),
(174,156,'','Chocolate Barfi',2,'',520.00,0.00,0.00,0.00,0.00,1040.00,'2025-07-09 06:10:22',NULL,1),
(175,156,'','Gajar Barfi',1,'',460.00,0.00,0.00,0.00,0.00,460.00,'2025-07-09 06:10:22',NULL,1),
(176,157,'','Balushahi',1,'',260.00,0.00,0.00,0.00,0.00,260.00,'2025-07-09 06:10:36',NULL,1),
(177,157,'','Besan Laddu',1,'',260.00,0.00,0.00,0.00,0.00,260.00,'2025-07-09 06:10:36',NULL,1),
(178,158,'','jalebi',1,'',220.00,0.00,0.00,0.00,0.00,220.00,'2025-07-09 06:15:18',NULL,1),
(179,158,'','Gujia',1,'',360.00,0.00,0.00,0.00,0.00,360.00,'2025-07-09 06:15:18',NULL,1),
(180,159,'','Amrati',1,'',420.00,0.00,0.00,0.00,0.00,420.00,'2025-07-09 06:22:41',NULL,1),
(181,159,'','Balushahi',1,'',260.00,0.00,0.00,0.00,0.00,260.00,'2025-07-09 06:22:41',NULL,1),
(182,159,'','Khoya Barfi',1,'',500.00,0.00,0.00,0.00,0.00,500.00,'2025-07-09 06:22:41',NULL,1),
(183,159,'','Khoya Barfi',1,'',500.00,0.00,0.00,0.00,0.00,500.00,'2025-07-09 06:22:41',NULL,1),
(184,166,'','Kalakand',1,'',520.00,0.00,0.00,0.00,0.00,520.00,'2025-07-09 06:51:20',NULL,1),
(185,185,'','Gulabjamun',1,'',320.00,0.00,0.00,0.00,0.00,320.00,'2025-07-12 03:55:31',NULL,1),
(186,185,'','Gajar Barfi',1,'',460.00,0.00,0.00,0.00,0.00,460.00,'2025-07-12 03:55:31',NULL,1),
(187,185,'','Rasgulle',1,'',300.00,0.00,0.00,0.00,0.00,300.00,'2025-07-12 03:55:31',NULL,1),
(188,185,'','Patisa',2,'',340.00,0.00,0.00,0.00,0.00,680.00,'2025-07-12 03:55:31',NULL,1),
(189,144,'Table 9','vatitem',2,'',300.00,3.50,3.50,0.00,21.00,675.00,'2025-07-12 06:21:56','188',0);
/*!40000 ALTER TABLE `order_items_gst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(233) NOT NULL,
  `order_number` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=249 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES
(1,'Jyoti0001',2,'Table 2',660.00,'2025-02-11 10:55:59',NULL,1),
(2,'Jyoti0001',3,'Table 3',790.00,'2025-02-11 10:56:11',NULL,1),
(3,'Jyoti0001',4,'Table 6',840.00,'2025-02-11 10:56:18',NULL,1),
(4,'Jyoti0001',5,'Table 4',780.00,'2025-02-12 08:05:43',NULL,1),
(5,'Jyoti0001',6,'Table 7',660.00,'2025-02-20 07:10:54',NULL,1),
(6,'Jyoti0001',7,'Table 4',540.00,'2025-02-20 07:21:27',NULL,1),
(7,'Jyoti0001',8,'Table 6',400.00,'2025-02-20 07:21:35',NULL,1),
(8,'Jyoti0001',9,'Table 3',650.00,'2025-02-20 08:58:53',NULL,1),
(9,'Jyoti0001',10,'Table 6',660.00,'2025-02-20 08:59:02',NULL,1),
(10,'Jyoti0001',11,'Table 1',360.00,'2025-02-20 09:04:51',NULL,1),
(11,'Jyoti0001',12,'Table 6',720.00,'2025-02-20 09:04:56',NULL,1),
(12,'Jyoti0001',13,'Table 3',360.00,'2025-02-20 09:51:15',NULL,1),
(13,'Jyoti0001',14,'Table 4',1080.00,'2025-02-20 10:16:33',NULL,1),
(14,'Jyoti0001',15,'Table 1',500.00,'2025-02-20 10:22:32',NULL,1),
(15,'Jyoti0001',16,'Table 3',430.00,'2025-02-20 10:25:46',NULL,1),
(16,'Jyoti0001',17,'Table 6',470.00,'2025-02-20 10:25:52',NULL,1),
(17,'Jyoti0001',18,'Table 2',720.00,'2025-02-24 07:13:41',NULL,1),
(18,'Jyoti0001',19,'Table 4',480.00,'2025-02-24 07:17:41',NULL,1),
(19,'Jyoti0001',20,'Table 1',800.00,'2025-02-24 07:18:11',NULL,1),
(20,'Jyoti0001',21,'Table 3',1080.00,'2025-02-24 07:27:05',NULL,1),
(21,'Jyoti0001',22,'Table 4',660.00,'2025-02-24 07:27:12',NULL,1),
(22,'Jyoti0001',23,'Table 2',480.00,'2025-02-24 07:34:24',NULL,1),
(23,'Jyoti0001',24,'Table 6',220.00,'2025-02-24 07:34:29',NULL,1),
(24,'Jyoti0001',25,'Table 9',840.00,'2025-02-24 07:39:46',NULL,1),
(25,'Jyoti0001',26,'Table 4',690.00,'2025-02-24 07:39:53',NULL,1),
(26,'Jyoti0001',27,'Table 1',610.00,'2025-02-24 08:08:23',NULL,1),
(27,'Jyoti0001',28,'Table 7',430.00,'2025-02-24 08:08:33',NULL,1),
(28,'Jyoti0001',29,'Table 9',480.00,'2025-02-24 08:25:01',NULL,1),
(29,'Jyoti0001',30,'Table 9',650.00,'2025-02-24 08:25:08',NULL,1),
(30,'Jyoti0001',31,'Table 4',540.00,'2025-02-24 08:34:53',NULL,1),
(31,'Jyoti0001',32,'Table 6',650.00,'2025-02-24 08:35:00',NULL,1),
(32,'Jyoti0001',33,'Table 9',180.00,'2025-02-24 08:35:15',NULL,1),
(33,'Jyoti0001',34,'Table 2',650.00,'2025-02-24 09:31:32',NULL,1),
(34,'Jyoti0001',35,'Table 3',660.00,'2025-02-24 09:34:11',NULL,1),
(35,'Jyoti0001',36,'Table 2',220.00,'2025-02-24 09:34:20',NULL,1),
(36,'Jyoti0001',37,'Table 4',540.00,'2025-02-24 09:55:32',NULL,1),
(37,'Jyoti0001',38,'Table 2',760.00,'2025-02-24 09:55:42',NULL,1),
(38,'Jyoti0001',39,'Table 6',830.00,'2025-02-24 09:55:50',NULL,1),
(39,'Jyoti0001',40,'Table 3',720.00,'2025-02-24 10:03:53',NULL,1),
(40,'Jyoti0001',41,'Table 2',750.00,'2025-02-24 10:04:01',NULL,1),
(41,'Jyoti0001',42,'Table 3',610.00,'2025-02-24 10:05:54',NULL,1),
(42,'Jyoti0001',43,'Table 7',660.00,'2025-02-24 10:19:26',NULL,1),
(43,'Jyoti0001',44,'Table 5',1130.00,'2025-02-24 10:19:34',NULL,1),
(44,'Jyoti0001',45,'Table 2',295.00,'2025-02-24 11:44:04',NULL,1),
(45,'Jyoti0001',46,'Table 4',345.00,'2025-02-24 11:46:37',NULL,1),
(46,'Jyoti0001',47,'Table 6',570.00,'2025-02-24 11:46:56',NULL,1),
(47,'Jyoti0001',48,'Table 5',830.00,'2025-02-24 11:47:29',NULL,1),
(48,'Jyoti0001',49,'Table 2',100.00,'2025-02-24 11:47:50',NULL,1),
(49,'Jyoti0001',50,'Table 5',100.00,'2025-02-24 11:47:59',NULL,1),
(50,'Jyoti0001',51,'Table 6',1630.00,'2025-02-24 11:48:12',NULL,1),
(51,'Jyoti0001',52,'Table 5',75.00,'2025-02-24 11:48:21',NULL,1),
(52,'Jyoti0001',53,'Table 5',295.00,'2025-02-25 08:48:14',NULL,1),
(53,'Jyoti0001',54,'Table 5',1640.00,'2025-03-13 12:07:34',NULL,1),
(54,'Jyoti0001',55,'Table 9',1060.00,'2025-03-13 12:12:17',NULL,1),
(55,'Jyoti0001',56,'Table 7',1080.00,'2025-03-15 10:07:18',NULL,1),
(56,'Jyoti0001',57,'Table 5',345.00,'2025-03-15 10:29:35',NULL,1),
(57,'Jyoti0001',58,'Table 6',485.00,'2025-03-15 11:04:22',NULL,1),
(58,'Jyoti0001',59,'Table 7',1130.00,'2025-03-15 11:04:41',NULL,1),
(59,'Jyoti0001',60,'Table 10',1990.00,'2025-03-15 11:09:05',NULL,1),
(60,'Jyoti0001',61,'Table 1',500.00,'2025-05-01 09:32:20',NULL,1),
(61,'Jyoti0001',62,'Table 10',880.00,'2025-05-01 09:32:55',NULL,1),
(62,'Jyoti0001',63,'Table 5',630.00,'2025-05-26 07:25:54',NULL,1),
(63,'Jyoti0001',64,'Table 6',670.00,'2025-05-26 07:26:51',NULL,1),
(64,'Jyoti0001',65,'Table 3',145.00,'2025-05-26 07:32:04',NULL,1),
(65,'Jyoti0001',66,'Table 6',555.00,'2025-05-26 07:32:12',NULL,1),
(66,'Jyoti0001',67,'Table 9',330.00,'2025-05-26 07:41:28',NULL,1),
(67,'Jyoti0001',68,'Table 10',310.00,'2025-05-26 07:41:39',NULL,1),
(68,'Jyoti0001',69,'Table 9',200.00,'2025-05-26 07:46:01',NULL,1),
(69,'Jyoti0001',70,'Table 5',50.00,'2025-05-26 07:57:20',NULL,1),
(70,'Jyoti0001',71,'Table 9',530.00,'2025-05-26 07:57:28',NULL,1),
(71,'Jyoti0001',72,'Table 10',50.00,'2025-05-26 08:07:00',NULL,1),
(72,'Jyoti0001',73,'Table 6',580.00,'2025-05-26 08:07:11',NULL,1),
(73,'Jyoti0001',74,'Table 5',500.00,'2025-05-26 08:07:18',NULL,1),
(74,'Jyoti0001',75,'Table 5',230.00,'2025-05-26 11:11:15',NULL,1),
(75,'Jyoti0001',76,'Table 6',145.00,'2025-05-26 11:11:23',NULL,1),
(76,'Jyoti0001',77,'Table 4',50.00,'2025-05-26 11:26:22',NULL,1),
(77,'Jyoti0001',78,'Table 4',180.00,'2025-05-26 11:26:27',NULL,1),
(78,'Jyoti0001',79,'Table 7',240.00,'2025-05-26 11:26:43',NULL,1),
(79,'Jyoti0001',80,'Table 3',240.00,'2025-05-26 11:26:51',NULL,1),
(80,'Jyoti0001',81,'Table 1',230.00,'2025-05-27 08:42:28',NULL,1),
(81,'Jyoti0001',82,'Table 1',295.00,'2025-05-27 09:20:44',NULL,1),
(82,'Jyoti0001',83,'Table 5',570.00,'2025-05-27 09:21:05',NULL,1),
(83,'Jyoti0001',84,'Table 3',340.00,'2025-05-27 09:21:19',NULL,1),
(84,'Jyoti0001',85,'Table 3',360.00,'2025-05-28 08:37:08',NULL,1),
(85,'Jyoti0001',86,'Table 5',330.00,'2025-06-03 07:44:36',NULL,1),
(86,'Jyoti0001',87,'Table 10',325.00,'2025-06-03 07:44:47',NULL,1),
(87,'Jyoti0001',88,'Table 5',75.00,'2025-06-03 07:44:54',NULL,1),
(88,'Jyoti0001',89,'Table 1',50.00,'2025-06-03 07:46:01',NULL,1),
(89,'Jyoti0001',90,'Table 4',340.00,'2025-06-03 10:12:22',NULL,1),
(90,'Jyoti0001',91,'Table 9',275.00,'2025-06-03 10:13:28',NULL,1),
(91,'Jyoti0001',92,'Table 3',460.00,'2025-06-03 10:31:12',NULL,1),
(92,'Jyoti0001',93,'Table 5',110.00,'2025-06-03 10:38:50',NULL,1),
(93,'Jyoti0001',94,'Table 3',665.00,'2025-06-03 10:39:14',NULL,1),
(94,'Jyoti0001',95,'Table 1',635.00,'2025-06-03 10:49:45',NULL,1),
(95,'Jyoti0001',96,'Table 4',365.00,'2025-06-03 10:54:27',NULL,1),
(96,'Jyoti0001',97,'Table 5',530.00,'2025-06-03 10:54:33',NULL,1),
(97,'Jyoti0001',98,'Table 2',580.00,'2025-06-03 10:54:43',NULL,1),
(98,'Jyoti0001',99,'Table 4',320.00,'2025-06-03 10:57:41',NULL,1),
(99,'Jyoti0001',100,'Table 7',365.00,'2025-06-03 11:01:03',NULL,1),
(100,'Jyoti0001',101,'Table 10',1100.00,'2025-06-03 11:01:14',NULL,1),
(101,'Jyoti0001',102,'Table 4',1100.00,'2025-06-04 09:11:07',NULL,1),
(102,'Jyoti0001',103,'Table 5',1100.00,'2025-06-05 07:56:51',NULL,1),
(103,'Jyoti0001',104,'Table 3',250.00,'2025-06-05 07:57:05',NULL,1),
(104,'Jyoti0001',105,'Table 9',340.00,'2025-06-05 08:28:56',NULL,1),
(105,'Jyoti0001',106,'Take Away',345.00,'2025-06-07 10:22:28',NULL,1),
(106,'Jyoti0001',107,'Table 4',915.00,'2025-06-10 06:59:36',NULL,1),
(107,'Jyoti0001',108,'Table 9',25.00,'2025-06-10 07:00:45',NULL,1),
(108,'Jyoti0001',109,'Table 9',360.00,'2025-06-10 07:03:21',NULL,1),
(109,'Jyoti0001',110,'Table 9',570.00,'2025-06-10 07:04:31',NULL,1),
(110,'Jyoti0001',111,'Table 9',570.00,'2025-06-10 07:04:44',NULL,1),
(111,'Jyoti0001',112,'Table 7',90.00,'2025-06-10 07:05:03',NULL,1),
(112,'Jyoti0001',113,'Take Away',280.00,'2025-06-10 07:05:09',NULL,1),
(113,'Jyoti0001',114,'Table 1',180.00,'2025-06-12 06:27:07',NULL,1),
(114,'Jyoti0001',115,'Table 1',140.00,'2025-06-12 06:36:15',NULL,1),
(115,'Jyoti0001',116,'Table 1',135.00,'2025-06-12 06:37:49',NULL,1),
(116,'Jyoti0001',117,'Table 1',135.00,'2025-06-12 06:39:01',NULL,1),
(117,'Jyoti0001',117,'Table 1',135.00,'2025-06-12 06:39:25',NULL,1),
(118,'Jyoti0001',118,'Table 1',250.00,'2025-06-12 06:39:53',NULL,1),
(119,'Jyoti0001',119,'Table 3',90.00,'2025-06-12 06:53:00',NULL,1),
(120,'Jyoti0001',120,'Table 10',90.00,'2025-06-12 06:54:07',NULL,1),
(121,'Jyoti0001',121,'Table 10',1380.00,'2025-06-12 10:49:01',NULL,1),
(122,'Jyoti0001',122,'Table 1',530.00,'2025-06-17 06:46:10',NULL,1),
(123,'Jyoti0001',123,'Table 9',1100.00,'2025-06-17 06:46:20',NULL,1),
(124,'Jyoti0001',124,'Table 10',755.00,'2025-06-17 07:19:11',NULL,1),
(125,'Jyoti0001',125,'Table 2',1125.00,'2025-06-18 05:41:49',NULL,1),
(126,'Jyoti0001',126,'Table 2',100.00,'2025-06-18 05:42:05',NULL,1),
(127,'Jyoti0001',127,'Table 2',1230.00,'2025-06-20 06:21:35',NULL,1),
(128,'Jyoti0001',127,'Table 2',1230.00,'2025-06-20 06:21:42',NULL,1),
(129,'Jyoti0001',128,'Table 10',685.00,'2025-06-21 07:16:40',NULL,1),
(130,'Jyoti0001',128,'Table 10',685.00,'2025-06-21 07:21:29',NULL,1),
(131,'Jyoti0001',128,'Table 10',685.00,'2025-06-21 07:25:49',NULL,1),
(132,'Jyoti0001',128,'Table 10',785.00,'2025-06-21 07:26:20',NULL,1),
(133,'Jyoti0001',129,'Table 9',60.00,'2025-06-21 07:31:24',NULL,1),
(134,'Jyoti0001',130,'Table 9',60.00,'2025-06-21 07:33:29',NULL,1),
(135,'Jyoti0001',131,'Table 9',60.00,'2025-06-21 07:34:09',NULL,1),
(136,'Jyoti0001',132,'Table 9',60.00,'2025-06-21 07:35:31',NULL,1),
(137,'Jyoti0001',132,'Table 9',60.00,'2025-06-21 07:36:15',NULL,1),
(138,'Jyoti0001',128,'Table 10',785.00,'2025-06-21 07:36:45',NULL,1),
(139,'Jyoti0001',128,'Table 10',785.00,'2025-06-21 07:37:50',NULL,1),
(140,'Jyoti0001',133,'Table 10',85.00,'2025-06-21 07:38:23',NULL,1),
(141,'Jyoti0001',134,'Table 9',60.00,'2025-06-21 07:44:38',NULL,1),
(142,'Jyoti0001',134,'Table 9',60.00,'2025-06-21 07:48:27',NULL,1),
(143,'Jyoti0001',135,'Table 3',180.00,'2025-06-21 08:00:03',NULL,1),
(144,'Jyoti0001',136,'Table 3',715.00,'2025-06-21 08:59:38',NULL,1),
(145,'Jyoti0001',137,'Table 9',2475.00,'2025-06-21 09:00:04',NULL,1),
(146,'Jyoti0001',138,'Table 6',525.00,'2025-06-21 10:14:05',NULL,1),
(147,'Jyoti0001',139,'Table 5',6160.00,'2025-06-23 06:04:55',NULL,1),
(148,'Jyoti0001',140,'Table 3',840.00,'2025-06-23 10:35:43',NULL,1),
(149,'Jyoti0001',141,'Table 7',665.00,'2025-06-23 15:40:07',NULL,1),
(150,'Jyoti0001',142,'Table 9',325.00,'2025-06-24 11:46:48',NULL,1),
(151,'Jyoti0001',143,'Table 5',570.00,'2025-06-26 06:11:21',NULL,1),
(152,'Jyoti0001',144,'Table 9',675.00,'2025-07-12 06:21:55',NULL,1),
(153,'3130',2,'Table 1',325.00,'2025-07-14 10:03:31',NULL,1),
(154,'3130',3,'Table 10',1425.00,'2025-07-14 10:22:08',NULL,1),
(155,'3130',4,'Table 2',325.00,'2025-07-15 05:22:45',NULL,1),
(156,'3130',5,'Table 6',450.00,'2025-07-15 05:28:06',NULL,1),
(157,'3130',6,'Table 4',300.00,'2025-07-15 05:32:19',NULL,1),
(158,'3130',7,'Table 6',1550.00,'2025-07-15 10:48:19',NULL,1),
(159,'3130',8,'Table 6',0.00,'2025-07-15 10:48:28',NULL,1),
(160,'3130',8,'Table 7',225.00,'2025-07-15 10:52:29',NULL,1),
(161,'3130',9,'Table 2',450.00,'2025-07-15 10:54:19',NULL,1),
(162,'3130',10,'Table 2',175.00,'2025-07-16 06:55:10',NULL,1),
(163,'3130',11,'Table 1',400.00,'2025-07-17 08:44:21',NULL,1),
(164,'3130',12,'Table 2',175.00,'2025-07-22 10:33:22',NULL,1),
(165,'3130',13,'Table 2',275.00,'2025-07-24 08:55:56',NULL,1),
(166,'3130',14,'Take Away',135.00,'2025-07-24 10:59:30',NULL,1),
(167,'3130',15,'Take Away',150.00,'2025-07-24 11:00:19',NULL,1),
(168,'3130',16,'Take Away',500.00,'2025-07-24 11:01:51',NULL,1),
(169,'3130',17,'Table 3',100.00,'2025-07-25 04:58:19',NULL,1),
(170,'3130',18,'Table 2',225.00,'2025-07-31 06:39:29',NULL,1),
(171,'3130',19,'Table 2',75.00,'2025-07-31 06:42:54',NULL,1),
(172,'3130',20,'Table 2',250.00,'2025-07-31 06:48:17',NULL,1),
(173,'3130',21,'Table 2',135.00,'2025-07-31 07:04:20',NULL,1),
(174,'3130',22,'Table 2',150.00,'2025-07-31 07:09:23',NULL,1),
(175,'3130',23,'Table 2',225.00,'2025-08-01 12:38:56',NULL,1),
(176,'3130',24,'Table 5',325.00,'2025-08-15 09:51:37',NULL,1),
(177,'3130',25,'Table 1',250.00,'2025-08-26 08:41:41',NULL,1),
(178,'3130',26,'Table 4',200.00,'2025-08-26 08:45:02',NULL,1),
(179,'3130',27,'Table 7',345.00,'2025-08-26 08:45:19',NULL,1),
(180,'3130',28,'Table 5',250.00,'2025-08-26 08:57:08',NULL,1),
(181,'3130',29,'Table 3',75.00,'2025-08-26 08:57:18',NULL,1),
(182,'3130',30,'Table 6',700.00,'2025-08-26 08:57:27',NULL,1),
(183,'3130',31,'Take Away',175.00,'2025-08-26 08:57:37',NULL,1),
(184,'3130',32,'Table 7',400.00,'2025-08-26 09:02:38',NULL,1),
(185,'3130',33,'Take Away',350.00,'2025-08-26 09:03:45',NULL,1),
(186,'3130',34,'Table 7',225.00,'2025-08-26 09:11:34',NULL,1),
(187,'3130',35,'Table 5',310.00,'2025-08-26 09:11:46',NULL,1),
(188,'3130',36,'Table 3',425.00,'2025-08-26 09:59:38',NULL,1),
(189,'3130',37,'Table 6',595.00,'2025-08-26 10:10:39',NULL,1),
(190,'3130',38,'Table 4',575.00,'2025-08-26 10:10:54',NULL,1),
(191,'3130',39,'Table 5',750.00,'2025-08-26 10:11:07',NULL,1),
(192,'84584',2,'Table 3',175.00,'2025-08-27 08:46:16',NULL,1),
(193,'84584',3,'Table 10',300.00,'2025-08-27 08:46:25',NULL,1),
(194,'84584',4,'Table 5',225.00,'2025-08-27 08:55:40',NULL,1),
(195,'84584',5,'Table 4',760.00,'2025-08-27 09:06:06',NULL,1),
(196,'84584',6,'Table 9',250.00,'2025-08-27 09:06:30',NULL,1),
(197,'84584',7,'Table 7',300.00,'2025-08-27 09:27:35',NULL,1),
(198,'3130',40,'Table 2',2340.00,'2025-08-27 11:00:12',NULL,1),
(199,'84584',8,'Table 4',235.00,'2025-08-27 11:08:40',NULL,1),
(200,'3130',41,'Table 3',1755.00,'2025-08-27 16:33:11',NULL,1),
(201,'3130',42,'Table 7',790.00,'2025-08-28 03:49:57',NULL,1),
(202,'3130',43,'Table 3',750.00,'2025-08-28 07:56:39',NULL,1),
(203,'3130',44,'Table 2',225.00,'2025-08-28 10:17:29',NULL,1),
(204,'3130',45,'Table 10',567.50,'2025-08-28 10:21:47',NULL,1),
(205,'3130',46,'Table 7',225.18,'2025-08-28 10:26:48',NULL,1),
(206,'3130',47,'Table 5',320.00,'2025-08-29 09:53:20',NULL,1),
(207,'3130',48,'Table 9',317.50,'2025-08-29 09:53:30',NULL,1),
(208,'3130',49,'Table 4',120.00,'2025-08-29 10:09:10',NULL,1),
(209,'3130',50,'Table 2',115.00,'2025-08-29 10:10:13',NULL,1),
(210,'3130',51,'Table 9',392.50,'2025-08-29 10:11:08',NULL,1),
(211,'3130',52,'Table 1',1080.00,'2025-09-03 12:49:34',NULL,1),
(212,'3130',53,'Table 2',290.00,'2025-09-03 12:55:08',NULL,1),
(213,'3130',54,'Table 4',770.00,'2025-09-03 17:39:09',NULL,1),
(214,'3130',55,'Table 3',745.00,'2025-09-04 07:01:06',NULL,1),
(215,'3130',56,'Table 5',215.00,'2025-09-04 07:04:02',NULL,1),
(216,'3130',56,'Table 5',215.00,'2025-09-04 07:04:05',NULL,1),
(217,'3130',57,'Table 5',315.00,'2025-09-04 07:06:17',NULL,1),
(218,'3130',58,'Table 5',187.50,'2025-09-04 07:08:56',NULL,1),
(219,'3130',59,'Table 5',465.00,'2025-09-04 07:11:15',NULL,1),
(220,'3130',60,'Table 5',0.00,'2025-09-04 07:11:26',NULL,1),
(221,'3130',60,'Table 5',0.00,'2025-09-04 07:11:29',NULL,1),
(222,'3130',61,'Table 5',255.00,'2025-09-04 07:12:30',NULL,1),
(223,'3130',62,'Table 5',230.00,'2025-09-04 07:13:19',NULL,1),
(224,'3130',63,'Table 1',220.00,'2025-09-06 06:47:40',NULL,1),
(225,'3130',64,'Table 2',330.00,'2025-09-06 07:36:20',NULL,1),
(226,'3130',65,'Take Away',260.00,'2025-09-06 07:36:37',NULL,1),
(227,'3130',66,'Take Away',330.00,'2025-09-06 07:39:40',NULL,1),
(228,'3130',67,'Room2',920.00,'2025-09-06 07:40:06',NULL,1),
(229,'3130',68,'Room1',450.00,'2025-09-06 07:42:57',NULL,1),
(230,'3130',69,'Room2',390.00,'2025-09-06 07:43:15',NULL,1),
(231,'3130',70,'Table 9',120.00,'2025-09-06 07:43:33',NULL,1),
(232,'3130',71,'Room2',260.00,'2025-09-06 07:50:58',NULL,1),
(233,'3130',72,'Table11',235.00,'2025-09-06 08:25:22',NULL,1),
(234,'3130',73,'Table12',170.00,'2025-09-06 08:28:20',NULL,1),
(235,'3130',74,'Room5',495.00,'2025-09-06 08:32:45',NULL,1),
(236,'3130',75,'Room4',375.00,'2025-09-06 08:34:53',NULL,1),
(237,'3130',76,'Table11',300.00,'2025-09-06 08:42:27',NULL,1),
(238,'3130',77,'Table11',255.00,'2025-09-06 08:46:48',NULL,1),
(239,'3130',77,'Table11',255.00,'2025-09-06 08:48:48',NULL,1),
(240,'3130',77,'Table11',255.00,'2025-09-06 08:50:03',NULL,1),
(241,'3130',78,'Table 7',150.00,'2025-09-08 06:34:17',NULL,1),
(242,'3130',79,'Take Away',422.50,'2025-09-13 02:44:32',NULL,1),
(243,'3130',80,'Take Away',100.00,'2025-09-13 02:44:44',NULL,1),
(244,'3130',81,'Table 4',235.00,'2025-09-13 02:48:17',NULL,1),
(245,'3130',82,'Table 4',155.00,'2025-09-13 02:48:32',NULL,1),
(246,'3130',83,'Table 7',362.50,'2025-09-13 09:34:24',NULL,1),
(247,'3130',84,'Room2',300.00,'2025-09-13 09:36:07',NULL,1),
(248,'3130',85,'Table 4',312.50,'2025-09-23 15:57:12',NULL,1);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_vouchers`
--

DROP TABLE IF EXISTS `payment_vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_vouchers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint(20) NOT NULL,
  `payment_date` datetime DEFAULT current_timestamp(),
  `payment_mode` enum('Cash','Bank','Cheque','Online') NOT NULL,
  `amount_paid` decimal(15,2) NOT NULL,
  `reference_id` bigint(20) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_customer` (`supplier_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_vouchers`
--

LOCK TABLES `payment_vouchers` WRITE;
/*!40000 ALTER TABLE `payment_vouchers` DISABLE KEYS */;
INSERT INTO `payment_vouchers` VALUES
(1,1,'2025-06-07 15:44:53','Bank',2000.00,55,'kk','2025-06-07 15:44:53','2025-06-07 15:44:53'),
(2,1,'2025-06-07 15:45:21','Bank',3000.00,0,'ikky','2025-06-07 15:45:21','2025-06-07 15:45:21'),
(3,1,'2025-06-07 15:47:07','Cash',10000.00,0,'','2025-06-07 15:47:07','2025-06-07 15:47:07'),
(4,1,'2025-06-07 15:48:52','Cash',5000.00,0,'','2025-06-07 15:48:52','2025-06-07 15:48:52'),
(5,2,'2025-06-12 16:54:42','Cash',6000.00,0,'pay finish','2025-06-12 16:54:42','2025-06-12 16:54:42'),
(6,2,'2025-06-23 16:13:41','Cash',5000.00,0,'','2025-06-23 16:13:41','2025-06-23 16:13:41'),
(7,2,'2025-06-23 16:14:22','Bank',4500.00,0,'hgfhfgh','2025-06-23 16:14:22','2025-06-23 16:14:22');
/*!40000 ALTER TABLE `payment_vouchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paymentoptions`
--

DROP TABLE IF EXISTS `paymentoptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paymentoptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(233) NOT NULL,
  `isactive` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paymentoptions`
--

LOCK TABLES `paymentoptions` WRITE;
/*!40000 ALTER TABLE `paymentoptions` DISABLE KEYS */;
INSERT INTO `paymentoptions` VALUES
(1,'Cash',1),
(2,'Bank Transfer',1),
(3,'QR Scan',1),
(4,'UPI',1),
(5,'Credit',1),
(6,'Entertainment',1),
(7,'Card',1);
/*!40000 ALTER TABLE `paymentoptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usertype_id` int(11) DEFAULT NULL,
  `permission` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usertype_id` (`usertype_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES
(1,1,'view'),
(2,1,'edit'),
(3,1,'delete'),
(4,1,'create'),
(5,1,'manage_users'),
(6,2,'view'),
(7,2,'edit'),
(8,2,'create'),
(9,3,'view'),
(10,4,'view'),
(11,4,'create'),
(12,4,'edit_own'),
(13,5,'view_public');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_features`
--

DROP TABLE IF EXISTS `plan_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL,
  `is_enabled` tinyint(1) DEFAULT 1,
  `feature_level` enum('basic','advanced','enterprise') DEFAULT 'basic',
  `usage_limit` int(11) DEFAULT NULL,
  `additional_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_config`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_plan_feature` (`plan_id`,`feature_id`),
  KEY `feature_id` (`feature_id`),
  CONSTRAINT `plan_features_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `plan_features_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_features`
--

LOCK TABLES `plan_features` WRITE;
/*!40000 ALTER TABLE `plan_features` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `quotation_details`
--

DROP TABLE IF EXISTS `quotation_details`;

-- failed on view `quotation_details`: CREATE ALGORITHM=UNDEFINED DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER VIEW `quotation_details` AS select `q`.`id` AS `quotation_id`,`q`.`quotation_number` AS `quotation_number`,`q`.`customer_name` AS `customer_name`,`q`.`customer_phone` AS `customer_phone`,`q`.`customer_email` AS `customer_email`,`q`.`customer_address` AS `customer_address`,`q`.`customer_gst` AS `customer_gst`,`q`.`delivery_place` AS `delivery_place`,`q`.`subtotal` AS `subtotal`,`q`.`discount_type` AS `discount_type`,`q`.`discount_value` AS `discount_value`,`q`.`subtotal_afterdiscount` AS `subtotal_afterdiscount`,`q`.`tax` AS `tax`,`q`.`round_off` AS `round_off`,`q`.`grand_total` AS `grand_total`,`q`.`status` AS `status`,`q`.`valid_until` AS `valid_until`,`q`.`setup_date` AS `setup_date`,`q`.`created_at` AS `created_at`,`qi`.`id` AS `item_id`,`qi`.`item_name` AS `item_name`,`qi`.`description` AS `description`,`qi`.`quantity` AS `quantity`,`qi`.`uom` AS `uom`,`qi`.`rate` AS `rate`,`qi`.`amount` AS `amount`,`qi`.`discount_percent` AS `discount_percent`,`qi`.`discount_value` AS `item_discount`,`qi`.`cgst` AS `cgst`,`qi`.`sgst` AS `sgst`,`qi`.`igst` AS `igst`,`qi`.`vat` AS `vat`,`qi`.`tax_amount` AS `tax_amount`,`qi`.`net_amount` AS `net_amount`,`qi`.`tax_included` AS `tax_included`,`qi`.`sort_order` AS `sort_order` from (`quotations` `q` left join `quotation_items` `qi` on(`q`.`id` = `qi`.`quotation_id`)) order by `q`.`id` desc,`qi`.`sort_order`,`qi`.`id`


--
-- Table structure for table `quotation_history`
--

DROP TABLE IF EXISTS `quotation_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotation_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quotation_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `old_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `action_by` int(11) DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_quotation_id` (`quotation_id`),
  KEY `idx_action_date` (`action_date`),
  CONSTRAINT `fk_quotation_history_quotation` FOREIGN KEY (`quotation_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='History table for tracking quotation status changes';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotation_history`
--

LOCK TABLES `quotation_history` WRITE;
/*!40000 ALTER TABLE `quotation_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `quotation_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotation_items`
--

DROP TABLE IF EXISTS `quotation_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotation_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `table_number` varchar(25) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` float NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `invoice_number` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `setup_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_quotation_items_quotation` (`order_id`),
  CONSTRAINT `fk_quotation_items_quotation` FOREIGN KEY (`order_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotation_items`
--

LOCK TABLES `quotation_items` WRITE;
/*!40000 ALTER TABLE `quotation_items` DISABLE KEYS */;
INSERT INTO `quotation_items` VALUES
(1,15,'','Malai Barfi',1,214.00,'2025-09-01 08:22:56',NULL,1,'2025-08-30'),
(2,15,'','Kalakand',1,90.00,'2025-09-01 08:22:56',NULL,1,'2025-08-30'),
(3,16,'fsdfsf','KalakandPakeeza',1,200.00,'2025-09-01 08:25:52',NULL,1,'2025-08-30'),
(4,16,'fsdfsf','Milk Cake',1,150.00,'2025-09-01 08:25:52',NULL,1,'2025-08-30'),
(5,16,'fsdfsf','Chocolate Barfi',3,360.00,'2025-09-01 08:25:52',NULL,1,'2025-08-30'),
(6,17,'','Kalakand',2,385.20,'2025-09-01 08:51:08',NULL,1,'2025-08-30'),
(7,17,'','Pakeeza',3,750.00,'2025-09-01 08:51:08',NULL,1,'2025-08-30'),
(8,18,'gdfgdgdf','KalakandPakeeza',3,642.00,'2025-09-01 09:03:06',NULL,1,'2025-08-30'),
(9,18,'gdfgdgdf','Kalakand',1,2675.00,'2025-09-01 09:03:06',NULL,1,'2025-08-30'),
(10,18,'gdfgdgdf','Chocolate Barfi',2,3210.00,'2025-09-01 09:03:06',NULL,1,'2025-08-30'),
(11,19,'fthfth','Malai Barfi',5,1605.00,'2025-09-01 09:05:15',NULL,1,'2025-08-30'),
(12,19,'fthfth','Meetha Bdana',1,1605.00,'2025-09-01 09:05:15',NULL,1,'2025-08-30'),
(13,19,'fthfth','Chocolate Barfi',5,8185.50,'2025-09-01 09:05:15',NULL,1,'2025-08-30'),
(14,20,'fdsf','Besan Laddu',3,642.00,'2025-09-01 09:08:41',NULL,1,'2025-08-30'),
(15,20,'fdsf','Rasgulle',5,2675.00,'2025-09-01 09:08:41',NULL,1,'2025-08-30'),
(16,20,'fdsf','Besan Barfi',2,2681.42,'2025-09-01 09:08:41',NULL,1,'2025-08-30'),
(17,21,'ytry','Malai Barfi',5,1605.00,'2025-09-01 09:15:04',NULL,1,'2025-08-30'),
(18,21,'ytry','Malai Barfi',6,1284.00,'2025-09-01 09:15:04',NULL,1,'2025-08-30'),
(19,21,'ytry','Milk Cake',2,3210.00,'2025-09-01 09:15:04',NULL,1,'2025-08-30'),
(20,22,'','KalakandPakeeza',6,1284.00,'2025-09-01 09:55:09',NULL,1,'2025-08-30'),
(21,23,'','KalakandPakeeza',200,1000.00,'2025-09-01 09:58:34',NULL,1,'2025-08-30'),
(22,24,'','Malai Barfi',6,1200.00,'2025-09-01 10:01:42',NULL,1,'2025-08-30'),
(23,25,'','Pakeeza',1,321.00,'2025-09-01 10:07:10',NULL,1,'2025-08-30'),
(24,26,'','Pakeeza',5,1500.00,'2025-09-01 10:08:39',NULL,1,'2025-08-30'),
(25,27,'','Besan Laddu',2,4600.00,'2025-09-01 10:11:51',NULL,1,'2025-08-30'),
(26,28,'','Milk Cake',2,30040.00,'2025-09-01 10:15:31',NULL,1,'2025-08-30'),
(27,29,'','Kalakand',2,428.00,'2025-09-01 10:20:46',NULL,1,'2025-08-30'),
(28,30,'','Kalakand',2,400.00,'2025-09-01 12:45:33',NULL,1,'2025-08-30'),
(29,31,'','KalakandPakeeza',3,4350.00,'2025-09-01 12:48:53',NULL,1,'2025-08-30'),
(30,32,'','Pakeeza',10,15515.00,'2025-09-01 12:50:12',NULL,1,'2025-08-30'),
(31,33,'','Pakeeza',10,3210.00,'2025-09-01 12:51:10',NULL,1,'2025-08-30'),
(32,33,'','Doda Barfi',5,2407.50,'2025-09-01 12:51:10',NULL,1,'2025-08-30');
/*!40000 ALTER TABLE `quotation_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `quotation_summary`
--

DROP TABLE IF EXISTS `quotation_summary`;

-- failed on view `quotation_summary`: CREATE ALGORITHM=UNDEFINED DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER VIEW `quotation_summary` AS select `q`.`id` AS `id`,`q`.`quotation_number` AS `quotation_number`,`q`.`customer_name` AS `customer_name`,`q`.`customer_phone` AS `customer_phone`,`q`.`customer_email` AS `customer_email`,`q`.`grand_total` AS `grand_total`,`q`.`status` AS `status`,`q`.`valid_until` AS `valid_until`,`q`.`setup_date` AS `setup_date`,`q`.`created_at` AS `created_at`,count(`qi`.`id`) AS `item_count`,sum(`qi`.`quantity`) AS `total_quantity` from (`quotations` `q` left join `quotation_items` `qi` on(`q`.`id` = `qi`.`quotation_id`)) group by `q`.`id`,`q`.`quotation_number`,`q`.`customer_name`,`q`.`customer_phone`,`q`.`customer_email`,`q`.`grand_total`,`q`.`status`,`q`.`valid_until`,`q`.`setup_date`,`q`.`created_at`


--
-- Table structure for table `quotations`
--

DROP TABLE IF EXISTS `quotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quotation_number` varchar(50) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `customer_name` varchar(255) NOT NULL,
  `customer_phone` varchar(20) NOT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `customer_address` text DEFAULT NULL,
  `customer_gst` varchar(50) DEFAULT NULL,
  `delivery_place` varchar(255) DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT 0.00,
  `discount_type` enum('percentage','amount') DEFAULT 'percentage',
  `discount_value` decimal(10,2) DEFAULT 0.00,
  `subtotal_afterdiscount` decimal(10,2) DEFAULT 0.00,
  `tax` decimal(10,2) DEFAULT 0.00,
  `round_off` decimal(10,2) DEFAULT 0.00,
  `grand_total` decimal(10,2) DEFAULT 0.00,
  `status` enum('pending','approved','rejected','converted','expired') DEFAULT 'pending',
  `valid_until` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `setup_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_quotation_number` (`quotation_number`),
  KEY `idx_status` (`status`),
  KEY `idx_setup_date` (`setup_date`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_valid_until` (`valid_until`),
  KEY `idx_quotations_customer_status` (`customer_id`,`status`),
  KEY `idx_quotations_date_status` (`setup_date`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master table for storing quotation information';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotations`
--

LOCK TABLES `quotations` WRITE;
/*!40000 ALTER TABLE `quotations` DISABLE KEYS */;
INSERT INTO `quotations` VALUES
(1,'QUO-2025-0001',1,'Vicky Thakur','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','hgfhfghf',500.00,'percentage',0.00,470.00,32.90,0.10,503.00,'pending',NULL,NULL,NULL,NULL,'2025-08-30','2025-09-01 06:52:10','2025-09-01 06:52:10'),
(2,'QUO-2025-0001',1,'Vicky Thakur','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','hgfhfghf',500.00,'percentage',0.00,470.00,32.90,0.10,503.00,'pending',NULL,NULL,NULL,NULL,'2025-08-30','2025-09-01 06:54:09','2025-09-01 06:54:09'),
(3,'QUO-2025-0001',1,'Vicky Thakur','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','hgfhfghf',500.00,'percentage',0.00,470.00,32.90,0.10,503.00,'pending',NULL,NULL,NULL,NULL,'2025-08-30','2025-09-01 07:03:03','2025-09-01 07:03:03'),
(4,'QUO-2025-0001',3,'Vinod Kumar','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','pattaya',1350.00,'percentage',0.00,1290.00,90.30,-0.30,1380.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:10:48','2025-09-01 07:10:48'),
(5,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:22:12','2025-09-01 07:22:12'),
(6,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:26:19','2025-09-01 07:26:19'),
(7,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:27:59','2025-09-01 07:27:59'),
(8,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:36:59','2025-09-01 07:36:59'),
(9,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:37:30','2025-09-01 07:37:30'),
(10,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:38:44','2025-09-01 07:38:44'),
(11,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:43:56','2025-09-01 07:43:56'),
(12,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:47:34','2025-09-01 07:47:34'),
(13,'QUO-2025-0001',2,'Jakjaan','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','sadsad',350.00,'percentage',0.00,335.00,23.45,-0.45,358.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 07:50:43','2025-09-01 07:50:43'),
(14,'QUO-2025-0001',1,'Vicky Thakur','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','',300.00,'percentage',0.00,290.00,14.00,0.00,304.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 08:16:06','2025-09-01 08:16:06'),
(15,'QUO-2025-0001',1,'Vicky Thakur','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','',300.00,'percentage',0.00,290.00,14.00,0.00,304.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 08:22:56','2025-09-01 08:22:56'),
(16,'QUO-2025-0001',3,'Vinod Kumar','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','fsdfsf',710.00,'percentage',0.00,710.00,0.00,0.00,710.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 08:25:52','2025-09-01 08:25:52'),
(17,'QUO-2025-0001',3,'Vinod Kumar','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',1150.00,'percentage',0.00,1110.00,25.20,-0.20,1135.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 08:51:08','2025-09-01 08:51:08'),
(18,'QUO-2025-0001',3,'Vinod Kumar','0986643299','info@cloudnetsoftwares.com','109/19 ,Soi -14 Pattaya','','gdfgdgdf',6100.00,'percentage',0.00,6100.00,427.00,0.00,6527.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:03:06','2025-09-01 09:03:06'),
(19,'QUO-2025-0001',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','fthfth',10650.00,'percentage',0.00,10650.00,745.50,0.50,11396.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:05:14','2025-09-01 09:05:14'),
(20,'QUO-2025-0001',5,'Sopit','0986643299','info@cloudnetsoftwares.com','109/19 ,Soi -14 Pattaya','srfdsf','fdsf',5606.00,'percentage',0.00,5606.00,392.42,-0.42,5998.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:08:41','2025-09-01 09:08:41'),
(21,'QUO-2025-0001',6,'Jack','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','ytry',5700.00,'percentage',0.00,5700.00,399.00,0.00,6099.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:15:04','2025-09-01 09:15:04'),
(22,'QUO-2025-0001',3,'Vinod Kumar','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',1200.00,'percentage',0.00,1200.00,84.00,0.00,1284.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:55:09','2025-09-01 09:55:09'),
(23,'QUO-2025-0001',2,'Jakjaan','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',1000.00,'percentage',0.00,1000.00,0.00,0.00,1000.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 09:58:33','2025-09-01 09:58:33'),
(24,'QUO-2025-0001',4,'Gigu','0986643299','info@cloudnetsoftwares.com','109/19 ,Soi -14 Pattaya','','',1200.00,'percentage',0.00,1200.00,0.00,0.00,1200.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:01:42','2025-09-01 10:01:42'),
(25,'QUO-2025-0001',6,'Jack','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',300.00,'percentage',0.00,300.00,21.00,0.00,321.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:07:09','2025-09-01 10:07:09'),
(26,'QUO-2025-0001',4,'Gigu','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','',1500.00,'percentage',0.00,1500.00,0.00,0.00,1500.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:08:39','2025-09-01 10:08:39'),
(27,'QUO-2025-005',6,'Jack','0986643299','info@cloudnetsoftwares.com','109/19 ,Soi -14 Pattaya','','',4600.00,'percentage',0.00,4600.00,0.00,0.00,4600.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:11:51','2025-09-01 10:11:51'),
(28,'QUO-2025-005',3,'Vinod Kumar','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',30040.00,'percentage',0.00,30040.00,0.00,0.00,30040.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:15:30','2025-09-01 10:15:30'),
(29,'QUO-2025-0001',5,'Sopit','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',400.00,'percentage',0.00,400.00,28.00,0.00,428.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 10:20:46','2025-09-01 10:20:46'),
(30,'QUO-2025-0001',2,'Jakjaan','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',400.00,'percentage',0.00,400.00,0.00,0.00,400.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 12:45:32','2025-09-01 12:45:32'),
(31,'QUO-2025-0001',1,'Vicky Thakur','0986643299','info@cloudnetsoftwares.com','109/19 ,Soi -14 Pattaya','','',4350.00,'percentage',0.00,4350.00,0.00,0.00,4350.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 12:48:53','2025-09-01 12:48:53'),
(32,'QUO-2025-0002',3,'Vinod Kumar','07832807218','AXIALITSOLUTIONS0001@GMAIL.COM','vill tikkar rajputan po bumbloo','','',14500.00,'percentage',0.00,14500.00,1015.00,0.00,15515.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 12:50:11','2025-09-01 12:50:11'),
(33,'QUO-2025-0003',8,'Jannaat','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','',5250.00,'percentage',0.00,5250.00,367.50,0.50,5618.00,'pending','2025-10-01',NULL,NULL,NULL,'2025-08-30','2025-09-01 12:51:10','2025-09-01 12:51:10'),
(34,'QUO-2025-0004',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:03:33','2025-09-13 11:03:33'),
(35,'QUO-2025-0005',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:04:03','2025-09-13 11:04:03'),
(36,'QUO-2025-0006',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:13:50','2025-09-13 11:13:50'),
(37,'QUO-2025-0007',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:14:13','2025-09-13 11:14:13'),
(38,'QUO-2025-0008',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:16:03','2025-09-13 11:16:03'),
(39,'QUO-2025-0009',7,'Hollywood','09816846663','axialtour@gmail.com','vill tikkar rajputan po bumbloo','','FDFSFSFSFSF',9500.00,'percentage',0.00,9500.00,0.00,0.00,9500.00,'pending','2025-10-13',NULL,NULL,NULL,'2025-09-07','2025-09-13 11:21:15','2025-09-13 11:21:15');
/*!40000 ALTER TABLE `quotations` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`pindbulluchi_db`@`localhost`*/ /*!50003 TRIGGER `quotation_number_generator` 
BEFORE INSERT ON `quotations` 
FOR EACH ROW 
BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`pindbulluchi_db`@`localhost`*/ /*!50003 TRIGGER `quotation_status_history` 
AFTER UPDATE ON `quotations` 
FOR EACH ROW 
BEGIN
  IF OLD.status != NEW.status THEN
    INSERT INTO quotation_history (quotation_id, action, old_status, new_status, comments)
    VALUES (NEW.id, 'status_change', OLD.status, NEW.status, CONCAT('Status changed from ', OLD.status, ' to ', NEW.status));
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `receipt_vouchers`
--

DROP TABLE IF EXISTS `receipt_vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receipt_vouchers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(50) NOT NULL,
  `customer_id` bigint(20) NOT NULL,
  `payment_date` datetime DEFAULT current_timestamp(),
  `payment_mode` enum('Cash','Bank','Cheque','Online') NOT NULL,
  `amount_paid` decimal(15,2) NOT NULL,
  `reference_id` bigint(20) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_transaction` (`transaction_id`),
  KEY `idx_customer` (`customer_id`)
) ENGINE=MyISAM AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receipt_vouchers`
--

LOCK TABLES `receipt_vouchers` WRITE;
/*!40000 ALTER TABLE `receipt_vouchers` DISABLE KEYS */;
INSERT INTO `receipt_vouchers` VALUES
(1,'3',1,'2025-03-15 16:18:13','Cash',749.00,0,NULL,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(2,'44',1,'2025-03-15 16:18:13','Cash',284.00,0,NULL,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(3,'45',1,'2025-03-15 16:18:13','Cash',967.00,0,NULL,'2025-03-15 16:18:13','2025-03-15 16:18:13'),
(4,'46',1,'2025-03-15 16:22:34','Cash',1701.00,0,NULL,'2025-03-15 16:22:34','2025-03-15 16:22:34'),
(5,'46',1,'2025-03-15 16:24:59','Cash',1701.00,0,NULL,'2025-03-15 16:24:59','2025-03-15 16:24:59'),
(6,'PAY_1',2,'2025-03-15 17:42:13','Cash',898.80,0,NULL,'2025-03-15 17:42:13','2025-03-15 17:42:13'),
(7,'PAY_4',2,'2025-03-15 17:42:13','Cash',601.20,0,NULL,'2025-03-15 17:42:13','2025-03-15 17:42:13'),
(8,'PAY_48',2,'2025-03-15 17:49:32','Cash',1156.00,0,NULL,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(9,'PAY_49',2,'2025-03-15 17:49:32','Cash',1144.30,0,NULL,'2025-03-15 17:49:32','2025-03-15 17:49:32'),
(10,'PAY_51',1,'2025-03-15 18:10:41','Cash',519.00,0,NULL,'2025-03-15 18:10:41','2025-03-15 18:10:41'),
(11,'PAY_55',1,'2025-05-26 14:23:59','Cash',942.00,0,NULL,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(12,'PAY_56',1,'2025-05-26 14:23:59','Cash',942.00,0,NULL,'2025-05-26 14:23:59','2025-05-26 14:23:59'),
(13,'PAY_58',1,'2025-05-27 15:44:12','Cash',674.00,0,NULL,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(14,'PAY_59',1,'2025-05-27 15:44:12','Cash',717.00,0,NULL,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(15,'PAY_60',1,'2025-05-27 15:44:12','Cash',594.00,0,NULL,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(16,'PAY_61',1,'2025-05-27 15:44:12','Cash',15.00,0,NULL,'2025-05-27 15:44:12','2025-05-27 15:44:12'),
(17,'PAY_62',1,'2025-05-27 16:24:03','Cash',155.00,0,NULL,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(18,'PAY_76',1,'2025-05-27 16:24:03','Cash',246.00,0,NULL,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(19,'PAY_77',1,'2025-05-27 16:24:03','Cash',364.00,0,NULL,'2025-05-27 16:24:03','2025-05-27 16:24:03'),
(20,'PAY_85',1,'2025-06-03 18:28:44','Cash',492.00,0,NULL,'2025-06-03 18:28:44','2025-06-03 18:28:44'),
(21,'RECPT_99',1,'2025-06-05 15:32:10','Cash',200.00,0,NULL,'2025-06-05 15:32:10','2025-06-05 15:32:10'),
(22,'RECPT_100',1,'2025-06-07 17:24:17','Cash',300.00,0,NULL,'2025-06-07 17:24:17','2025-06-07 17:24:17'),
(23,'RECPT_56',1,'2025-06-17 13:38:36','Cash',0.00,0,NULL,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(24,'RECPT_101',1,'2025-06-17 13:38:36','Cash',391.00,0,NULL,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(25,'RECPT_102',1,'2025-06-17 13:38:36','Cash',609.00,0,NULL,'2025-06-17 13:38:36','2025-06-17 13:38:36'),
(26,'RECPT_1750142823887',1,'2025-06-17 13:47:03','Bank',600.00,0,NULL,'2025-06-17 13:47:03','2025-06-17 13:47:03'),
(27,'RECPT_1750146998249',1,'2025-06-17 14:56:38','Bank',755.00,0,NULL,'2025-06-17 14:56:38','2025-06-17 14:56:38'),
(28,'RECPT_1750147102367',2,'2025-06-17 14:58:22','Bank',100.00,0,NULL,'2025-06-17 14:58:22','2025-06-17 14:58:22'),
(29,'RECPT_1750658752062',1,'2025-06-23 13:05:52','Cash',2000.00,0,NULL,'2025-06-23 13:05:52','2025-06-23 13:05:52'),
(30,'RECPT_1750693262933',1,'2025-06-23 22:41:02','Cash',665.00,0,NULL,'2025-06-23 22:41:02','2025-06-23 22:41:02'),
(31,'RECPT_1752041959136',14,'2025-07-09 13:19:19','Cash',300.00,0,NULL,'2025-07-09 13:19:19','2025-07-09 13:19:19');
/*!40000 ALTER TABLE `receipt_vouchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rs485_logs`
--

DROP TABLE IF EXISTS `rs485_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rs485_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) NOT NULL,
  `command_sent` text DEFAULT NULL,
  `response_received` text DEFAULT NULL,
  `status` enum('sent','received','error','timeout') DEFAULT 'sent',
  `error_message` text DEFAULT NULL,
  `response_time_ms` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_rs485_logs_machine_created` (`machine_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rs485_logs`
--

LOCK TABLES `rs485_logs` WRITE;
/*!40000 ALTER TABLE `rs485_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `rs485_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subcategory`
--

DROP TABLE IF EXISTS `subcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subcategory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cat_id` int(11) DEFAULT NULL,
  `subcat` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_subcategory_category` (`cat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subcategory`
--

LOCK TABLES `subcategory` WRITE;
/*!40000 ALTER TABLE `subcategory` DISABLE KEYS */;
INSERT INTO `subcategory` VALUES
(23,10,'Sweet Dishes'),
(24,10,'Namkeen Dishes'),
(25,11,'Hot'),
(26,11,'Cold'),
(28,10,'Serving');
/*!40000 ALTER TABLE `subcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_code` varchar(20) NOT NULL,
  `plan_name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `billing_cycle` enum('monthly','quarterly','yearly') NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `plan_code` (`plan_code`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
INSERT INTO `subscription_plans` VALUES
(9,'basic','Basic Plan',29.99,'monthly',1,1,'2025-07-17 10:25:10','2025-07-17 10:25:10'),
(10,'professional','Professional Plan',79.99,'monthly',1,2,'2025-07-17 10:25:10','2025-07-17 10:25:10'),
(11,'business','Business Plan',149.99,'monthly',1,3,'2025-07-17 10:25:10','2025-07-17 10:25:10'),
(12,'enterprise','Enterprise Plan',299.99,'monthly',1,4,'2025-07-17 10:25:10','2025-07-17 10:25:10');
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `company_name` varchar(233) DEFAULT NULL,
  `contact` bigint(20) NOT NULL,
  `email` varchar(233) NOT NULL,
  `taxid` varchar(233) DEFAULT NULL,
  `address` varchar(233) DEFAULT NULL,
  `createdon` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES
(1,'Vinod Kumar Kumar','Axial IT Solutions',255666,'axialtour@gmail.com','1516165','vill tikkar rajputan po bumbloo','2025-06-02 06:14:27'),
(2,'Sopit','Sopu co. Ltd',992799977,'AXIALITSOLUTIONS0001@GMAIL.COM','0236256926','vill tikkar rajputan po bumbloo','2025-06-12 09:41:44');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `table_category`
--

DROP TABLE IF EXISTS `table_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table_category` (
  `id` int(222) NOT NULL AUTO_INCREMENT,
  `cat_name` varchar(222) NOT NULL,
  `status` int(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `table_category`
--

LOCK TABLES `table_category` WRITE;
/*!40000 ALTER TABLE `table_category` DISABLE KEYS */;
INSERT INTO `table_category` VALUES
(1,'Restaurant',0),
(2,'Hotel',0);
/*!40000 ALTER TABLE `table_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tablelist`
--

DROP TABLE IF EXISTS `tablelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tablelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(22) NOT NULL,
  `name` varchar(233) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tablelist`
--

LOCK TABLES `tablelist` WRITE;
/*!40000 ALTER TABLE `tablelist` DISABLE KEYS */;
INSERT INTO `tablelist` VALUES
(5,'','Table 1',0),
(6,'','Table 2',0),
(7,'','Table 3',0),
(8,'','Table 4',1),
(9,'','Table 5',0),
(13,'','Table 7',0),
(14,'','Table 6',0),
(15,'','Table 9',0),
(16,'','Table 10',0),
(17,'','Take Away',0),
(18,'','Room1',0),
(19,'1','Room2',0),
(20,'2','Room3',0),
(21,'2','Room4',0),
(22,'2','Room5',0),
(23,'1','Table11',0),
(24,'1','Table12',0);
/*!40000 ALTER TABLE `tablelist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxes`
--

DROP TABLE IF EXISTS `taxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `taxname` varchar(122) NOT NULL,
  `taxvalue` int(11) NOT NULL,
  `included` varchar(10) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'InActive',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxes`
--

LOCK TABLES `taxes` WRITE;
/*!40000 ALTER TABLE `taxes` DISABLE KEYS */;
INSERT INTO `taxes` VALUES
(5,'Vat',7,'true','Active'),
(11,'kiom',10,'true','InActive'),
(15,'GST12%',12,'true','InActive'),
(16,'GST 5%',5,'true','InActive');
/*!40000 ALTER TABLE `taxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(233) NOT NULL,
  `description` varchar(233) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES
(2,'KG','sdfjk gdsfg'),
(3,'MG','gfhfgh'),
(4,'Ltr','litre'),
(5,'full plate',''),
(6,'half plate',''),
(7,'plate','plt'),
(8,'pcs','pc'),
(9,'btl.','bottle'),
(10,'cann','Cann');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscriptions`
--

DROP TABLE IF EXISTS `user_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `status` enum('active','expired','cancelled','suspended') DEFAULT 'active',
  `started_at` timestamp NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `payment_status` enum('paid','pending','failed','refunded') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `plan_id` (`plan_id`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `user_subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_subscriptions_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `uname` varchar(233) NOT NULL,
  `pass` text NOT NULL,
  `contact` varchar(233) NOT NULL DEFAULT '0',
  `email` varchar(233) NOT NULL,
  `type` varchar(112) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `last_loggedin` varchar(233) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(123,'Jyoti Thakur','3130','$2a$10$OktzxujrxGpv2H6a5OQ3JuSxpULhZPJ92uDr5Lwko0k1AI1rHf5D2','0','abcs@gmail.com','admin',1,'2025-06-19 18:56:15'),
(124,'VInod Kumar','vicky','$2a$10$RhcYysQ6.2rDbG2jCYYEGOy524lgcq6LlBSe5xBuUM9h0OQ6.Ujxu','0','abcsf@gmail.com','admin',1,'2023-12-14 15:51:57'),
(147,'Vicky','86845','$2a$10$fJT8ki1bWWAH6m.XBXpOo.6A3GhenpdQ/rh5T3BN.V5fUUekd5z1i','5662','hfnjh@gmail.com','admin',1,'2024-05-17 01:39:57'),
(164,'Gigi','84584','$2a$10$C80egwVTEbTczbBazS7qoeOTbFiu3Gw0tSehu0edvQV08pKwsQA5y','0','0','Cashier',1,'2025-06-11 19:05:12'),
(165,'Sopit','56023','$2a$10$WQR3K4IKqrsqUC9hUWVzdu8VzaWmsHOlNUyWROxiJ8kxIhwXPmsES','0','','Account',1,'2025-06-11 19:12:55');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_subs`
--

DROP TABLE IF EXISTS `users_subs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_subs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','manager','cashier','accountant') DEFAULT 'cashier',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_subs`
--

LOCK TABLES `users_subs` WRITE;
/*!40000 ALTER TABLE `users_subs` DISABLE KEYS */;
INSERT INTO `users_subs` VALUES
(1,'3130','adminchef@gmail.com','$2a$10$OktzxujrxGpv2H6a5OQ3JuSxpULhZPJ92uDr5Lwko0k1AI1rHf5D2','admin',1,'2025-07-17 10:55:50','2025-07-17 10:55:50');
/*!40000 ALTER TABLE `users_subs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usertypes`
--

DROP TABLE IF EXISTS `usertypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usertypes` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usertypes`
--

LOCK TABLES `usertypes` WRITE;
/*!40000 ALTER TABLE `usertypes` DISABLE KEYS */;
INSERT INTO `usertypes` VALUES
(1,'Admin','Administrator with full access to all features.'),
(2,'Editor','Editor with access to content creation and editing.'),
(3,'Viewer','Viewer with read-only access to content.'),
(4,'Contributor','Contributor with limited access to create and edit their own content.'),
(5,'Guest','Guest with limited access to view public content.');
/*!40000 ALTER TABLE `usertypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_user_current_subscription`
--

DROP TABLE IF EXISTS `v_user_current_subscription`;
/*!50001 DROP VIEW IF EXISTS `v_user_current_subscription`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_user_current_subscription` AS SELECT
 1 AS `user_id`,
  1 AS `subscription_id`,
  1 AS `plan_code`,
  1 AS `plan_name`,
  1 AS `status`,
  1 AS `started_at`,
  1 AS `expires_at`,
  1 AS `payment_status` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_user_features`
--

DROP TABLE IF EXISTS `v_user_features`;
/*!50001 DROP VIEW IF EXISTS `v_user_features`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_user_features` AS SELECT
 1 AS `user_id`,
  1 AS `plan_code`,
  1 AS `plan_name`,
  1 AS `feature_code`,
  1 AS `feature_name`,
  1 AS `feature_category`,
  1 AS `is_enabled`,
  1 AS `feature_level`,
  1 AS `usage_limit`,
  1 AS `current_usage`,
  1 AS `usage_status` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `vending_inventory`
--

DROP TABLE IF EXISTS `vending_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vending_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) NOT NULL,
  `product_id` varchar(50) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `max_quantity` int(11) DEFAULT 10,
  `min_threshold` int(11) DEFAULT 2,
  `last_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_machine_product` (`machine_id`,`product_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_vending_inventory_machine_quantity` (`machine_id`,`quantity`),
  CONSTRAINT `vending_inventory_ibfk_1` FOREIGN KEY (`machine_id`) REFERENCES `vending_machines` (`machine_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vending_inventory`
--

LOCK TABLES `vending_inventory` WRITE;
/*!40000 ALTER TABLE `vending_inventory` DISABLE KEYS */;
INSERT INTO `vending_inventory` VALUES
(1,'VM001','DRINK001','Coca Cola 330ml',2.50,10,15,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(2,'VM001','DRINK002','Pepsi 330ml',2.50,8,15,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(3,'VM001','SNACK001','Chips - Classic',3.00,5,12,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(4,'VM001','SNACK002','Chocolate Bar',2.75,7,10,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(5,'VM002','DRINK001','Coca Cola 330ml',2.50,12,20,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(6,'VM002','DRINK003','Orange Juice 500ml',3.50,6,10,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(7,'VM002','SNACK003','Cookies Pack',2.25,8,12,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(8,'VM003','DRINK004','Water 500ml',1.50,15,25,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(9,'VM003','DRINK005','Coffee 250ml',3.00,4,8,2,'2025-09-18 16:36:44','2025-09-18 16:36:44'),
(10,'VM003','SNACK004','Nuts Mix',4.00,3,8,2,'2025-09-18 16:36:44','2025-09-18 16:36:44');
/*!40000 ALTER TABLE `vending_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vending_machines`
--

DROP TABLE IF EXISTS `vending_machines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vending_machines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `machine_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `location` varchar(255) NOT NULL,
  `status` enum('online','offline','maintenance','error') DEFAULT 'offline',
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuration`)),
  `last_heartbeat` datetime DEFAULT NULL,
  `setup_date` datetime DEFAULT current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `machine_id` (`machine_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`location`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vending_machines`
--

LOCK TABLES `vending_machines` WRITE;
/*!40000 ALTER TABLE `vending_machines` DISABLE KEYS */;
INSERT INTO `vending_machines` VALUES
(1,'VM001','Main Hall Vending Machine','Building A - Main Hall','offline','{\"temperature_control\": true, \"payment_methods\": [\"cash\", \"card\"], \"max_items\": 50}',NULL,'2025-09-18 16:36:43','2025-09-18 16:36:43','2025-09-18 16:36:43'),
(2,'VM002','Cafeteria Vending Machine','Building B - Cafeteria','offline','{\"temperature_control\": false, \"payment_methods\": [\"cash\", \"card\", \"mobile\"], \"max_items\": 40}',NULL,'2025-09-18 16:36:43','2025-09-18 16:36:43','2025-09-18 16:36:43'),
(3,'VM003','Office Vending Machine','Building C - Office Floor 3','offline','{\"temperature_control\": true, \"payment_methods\": [\"card\", \"mobile\"], \"max_items\": 30}',NULL,'2025-09-18 16:36:43','2025-09-18 16:36:43','2025-09-18 16:36:43');
/*!40000 ALTER TABLE `vending_machines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vending_transactions`
--

DROP TABLE IF EXISTS `vending_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vending_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(100) NOT NULL,
  `machine_id` varchar(50) NOT NULL,
  `product_id` varchar(50) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `payment_method` enum('cash','card','mobile','wallet') DEFAULT 'cash',
  `user_id` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_machine_id` (`machine_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_vending_transactions_machine_status` (`machine_id`,`status`),
  CONSTRAINT `vending_transactions_ibfk_1` FOREIGN KEY (`machine_id`) REFERENCES `vending_machines` (`machine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vending_transactions`
--

LOCK TABLES `vending_transactions` WRITE;
/*!40000 ALTER TABLE `vending_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `vending_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'chefmate_pindbulluchi_db'
--

--
-- Dumping routines for database 'chefmate_pindbulluchi_db'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckFeatureAccess` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`pindbulluchi_db`@`localhost` PROCEDURE `CheckFeatureAccess`(
    IN p_user_id INT,
    IN p_feature_code VARCHAR(50),
    OUT p_has_access BOOLEAN,
    OUT p_usage_limit INT,
    OUT p_current_usage INT
)
BEGIN
    SELECT 
        is_enabled,
        usage_limit,
        current_usage
    INTO p_has_access, p_usage_limit, p_current_usage
    FROM v_user_features
    WHERE user_id = p_user_id 
    AND feature_code = p_feature_code;
    
    IF p_has_access IS NULL THEN
        SET p_has_access = FALSE;
        SET p_usage_limit = 0;
        SET p_current_usage = 0;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveCompanyInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`pindbulluchi_db`@`localhost` PROCEDURE `GetActiveCompanyInfo`()
BEGIN
  SELECT * FROM `company_profile` 
  WHERE `is_active` = 1 
  ORDER BY `created_at` DESC 
  LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserFeatures` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`pindbulluchi_db`@`localhost` PROCEDURE `GetUserFeatures`(IN p_user_id INT)
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateCompanyInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`pindbulluchi_db`@`localhost` PROCEDURE `UpdateCompanyInfo`(
  IN p_id INT,
  IN p_name VARCHAR(255),
  IN p_tax_id VARCHAR(100),
  IN p_phone VARCHAR(50),
  IN p_email VARCHAR(255),
  IN p_address TEXT,
  IN p_website VARCHAR(255),
  IN p_city VARCHAR(100),
  IN p_state VARCHAR(100),
  IN p_zip VARCHAR(20),
  IN p_country VARCHAR(100),
  IN p_updated_by INT
)
BEGIN
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateFeatureUsage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`pindbulluchi_db`@`localhost` PROCEDURE `UpdateFeatureUsage`(
    IN p_user_id INT,
    IN p_feature_code VARCHAR(50),
    IN p_increment INT
)
BEGIN
    INSERT INTO feature_usage (user_id, feature_code, current_usage)
    VALUES (p_user_id, p_feature_code, p_increment)
    ON DUPLICATE KEY UPDATE 
        current_usage = current_usage + p_increment,
        updated_at = CURRENT_TIMESTAMP;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `company_profile_basic`
--

/*!50001 DROP VIEW IF EXISTS `company_profile_basic`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `company_profile_basic` AS select `company_profile`.`id` AS `id`,`company_profile`.`name` AS `name`,`company_profile`.`tax_id` AS `tax_id`,`company_profile`.`phone_number` AS `phone_number`,`company_profile`.`email` AS `email`,`company_profile`.`address` AS `address`,`company_profile`.`website` AS `website`,`company_profile`.`city` AS `city`,`company_profile`.`state` AS `state`,`company_profile`.`zip_code` AS `zip_code`,`company_profile`.`country` AS `country`,`company_profile`.`bank_name` AS `bank_name`,`company_profile`.`account_number` AS `account_number`,`company_profile`.`account_name` AS `account_name`,`company_profile`.`payment_methods` AS `payment_methods`,`company_profile`.`is_active` AS `is_active`,`company_profile`.`created_at` AS `created_at`,`company_profile`.`updated_at` AS `updated_at` from `company_profile` where `company_profile`.`is_active` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `company_profile_display`
--

/*!50001 DROP VIEW IF EXISTS `company_profile_display`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `company_profile_display` AS select `company_profile`.`id` AS `id`,`company_profile`.`name` AS `name`,`company_profile`.`tax_id` AS `tax_id`,`company_profile`.`phone_number` AS `phone_number`,`company_profile`.`email` AS `email`,`company_profile`.`address` AS `address`,`company_profile`.`city` AS `city`,`company_profile`.`state` AS `state`,`company_profile`.`zip_code` AS `zip_code`,`company_profile`.`country` AS `country`,case when `company_profile`.`logo` is not null then 1 else 0 end AS `has_logo`,case when `company_profile`.`qr_code` is not null then 1 else 0 end AS `has_qr_code`,`company_profile`.`terms_and_conditions` AS `terms_and_conditions`,`company_profile`.`payment_methods` AS `payment_methods` from `company_profile` where `company_profile`.`is_active` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `quotation_details`
--

/*!50001 DROP VIEW IF EXISTS `quotation_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `quotation_details` AS select `q`.`id` AS `quotation_id`,`q`.`quotation_number` AS `quotation_number`,`q`.`customer_name` AS `customer_name`,`q`.`customer_phone` AS `customer_phone`,`q`.`customer_email` AS `customer_email`,`q`.`customer_address` AS `customer_address`,`q`.`customer_gst` AS `customer_gst`,`q`.`delivery_place` AS `delivery_place`,`q`.`subtotal` AS `subtotal`,`q`.`discount_type` AS `discount_type`,`q`.`discount_value` AS `discount_value`,`q`.`subtotal_afterdiscount` AS `subtotal_afterdiscount`,`q`.`tax` AS `tax`,`q`.`round_off` AS `round_off`,`q`.`grand_total` AS `grand_total`,`q`.`status` AS `status`,`q`.`valid_until` AS `valid_until`,`q`.`setup_date` AS `setup_date`,`q`.`created_at` AS `created_at`,`qi`.`id` AS `item_id`,`qi`.`item_name` AS `item_name`,`qi`.`description` AS `description`,`qi`.`quantity` AS `quantity`,`qi`.`uom` AS `uom`,`qi`.`rate` AS `rate`,`qi`.`amount` AS `amount`,`qi`.`discount_percent` AS `discount_percent`,`qi`.`discount_value` AS `item_discount`,`qi`.`cgst` AS `cgst`,`qi`.`sgst` AS `sgst`,`qi`.`igst` AS `igst`,`qi`.`vat` AS `vat`,`qi`.`tax_amount` AS `tax_amount`,`qi`.`net_amount` AS `net_amount`,`qi`.`tax_included` AS `tax_included`,`qi`.`sort_order` AS `sort_order` from (`quotations` `q` left join `quotation_items` `qi` on(`q`.`id` = `qi`.`quotation_id`)) `qi`.`sort_order`,`qi`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `quotation_summary`
--

/*!50001 DROP VIEW IF EXISTS `quotation_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `quotation_summary` AS select `q`.`id` AS `id`,`q`.`quotation_number` AS `quotation_number`,`q`.`customer_name` AS `customer_name`,`q`.`customer_phone` AS `customer_phone`,`q`.`customer_email` AS `customer_email`,`q`.`grand_total` AS `grand_total`,`q`.`status` AS `status`,`q`.`valid_until` AS `valid_until`,`q`.`setup_date` AS `setup_date`,`q`.`created_at` AS `created_at`,count(`qi`.`id`) AS `item_count`,sum(`qi`.`quantity`) AS `total_quantity` from (`quotations` `q` left join `quotation_items` `qi` on(`q`.`id` = `qi`.`quotation_id`)) group by `q`.`id`,`q`.`quotation_number`,`q`.`customer_name`,`q`.`customer_phone`,`q`.`customer_email`,`q`.`grand_total`,`q`.`status`,`q`.`valid_until`,`q`.`setup_date`,`q`.`created_at` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_current_subscription`
--

/*!50001 DROP VIEW IF EXISTS `v_user_current_subscription`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_current_subscription` AS select `us`.`user_id` AS `user_id`,`us`.`id` AS `subscription_id`,`sp`.`plan_code` AS `plan_code`,`sp`.`plan_name` AS `plan_name`,`us`.`status` AS `status`,`us`.`started_at` AS `started_at`,`us`.`expires_at` AS `expires_at`,`us`.`payment_status` AS `payment_status` from (`user_subscriptions` `us` join `subscription_plans` `sp` on(`us`.`plan_id` = `sp`.`id`)) where `us`.`status` = 'active' and (`us`.`expires_at` is null or `us`.`expires_at` > current_timestamp()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_features`
--

/*!50001 DROP VIEW IF EXISTS `v_user_features`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`pindbulluchi_db`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_features` AS select `ucs`.`user_id` AS `user_id`,`ucs`.`plan_code` AS `plan_code`,`ucs`.`plan_name` AS `plan_name`,`f`.`feature_code` AS `feature_code`,`f`.`feature_name` AS `feature_name`,`f`.`feature_category` AS `feature_category`,`pf`.`is_enabled` AS `is_enabled`,`pf`.`feature_level` AS `feature_level`,`pf`.`usage_limit` AS `usage_limit`,coalesce(`fu`.`current_usage`,0) AS `current_usage`,case when `pf`.`usage_limit` is null then 'unlimited' when coalesce(`fu`.`current_usage`,0) < `pf`.`usage_limit` then 'within_limit' else 'limit_exceeded' end AS `usage_status` from (((`v_user_current_subscription` `ucs` join `plan_features` `pf` on(`ucs`.`plan_code` = (select `subscription_plans`.`plan_code` from `subscription_plans` where `subscription_plans`.`id` = `pf`.`plan_id`))) join `features` `f` on(`pf`.`feature_id` = `f`.`id`)) left join `feature_usage` `fu` on(`ucs`.`user_id` = `fu`.`user_id` and `f`.`feature_code` = `fu`.`feature_code`)) where `f`.`is_active` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-30 14:20:45
