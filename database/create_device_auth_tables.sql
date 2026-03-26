-- User Device/MAC Address Management Tables
-- Restricted login to specific machines/devices based on MAC address

-- ================================================
-- 1. User Device Whitelist Table
-- ================================================
-- Stores which MAC addresses are allowed for each user
-- Allow multiple devices per user optionally

CREATE TABLE IF NOT EXISTS `user_devices` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT 'References users.id',
  `mac_address` VARCHAR(17) NOT NULL COMMENT 'Device MAC address (format: XX:XX:XX:XX:XX:XX)',
  `device_name` VARCHAR(100) COMMENT 'Friendly device name (e.g., Kitchen-POS-1)',
  `device_type` ENUM('desktop', 'laptop', 'tablet', 'mobile', 'other') DEFAULT 'desktop',
  `status` ENUM('active', 'inactive', 'blocked') DEFAULT 'active',
  `last_login_at` TIMESTAMP NULL COMMENT 'Last successful login from this device',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Key
  CONSTRAINT fk_user_devices_user_id FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) ON DELETE CASCADE,
  
  -- Indexes for performance
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_mac_address` (`mac_address`),
  INDEX `idx_status` (`status`),
  KEY `unique_user_mac` (`user_id`, `mac_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- 2. Device MAC Address Settings Table
-- ================================================
-- Global & per-user MAC authentication settings

CREATE TABLE IF NOT EXISTS `device_auth_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT UNIQUE COMMENT 'NULL = Global setting, otherwise user-specific',
  `enable_mac_auth` BOOLEAN DEFAULT FALSE COMMENT 'Enable MAC address authentication',
  `allow_multiple_devices` BOOLEAN DEFAULT TRUE COMMENT 'Allow user to login from multiple MAC addresses',
  `require_first_device` BOOLEAN DEFAULT FALSE COMMENT 'User must use first registered device',
  `block_new_devices` BOOLEAN DEFAULT FALSE COMMENT 'Block login from unregistered MAC addresses',
  `max_devices_per_user` INT DEFAULT 3 COMMENT 'Maximum devices allowed per user (-1 = unlimited)',
  `require_admin_approval` BOOLEAN DEFAULT FALSE COMMENT 'New device needs admin approval',
  `session_timeout_hours` INT DEFAULT 24 COMMENT 'Session timeout in hours',
  `allow_device_override` BOOLEAN DEFAULT FALSE COMMENT 'Allow user to add new devices themselves',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Key (optional)
  CONSTRAINT fk_device_auth_user_id FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- 3. Login Attempt Log Table
-- ================================================
-- Track all login attempts with MAC address info

CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT COMMENT 'User attempting login',
  `username` VARCHAR(233) COMMENT 'Username used',
  `mac_address` VARCHAR(17) COMMENT 'MAC address from login attempt',
  `ip_address` VARCHAR(45) COMMENT 'IP address (IPv4 or IPv6)',
  `device_name` VARCHAR(100) COMMENT 'Device/hostname',
  `status` ENUM('success', 'failed_invalid_mac', 'failed_no_mac', 'failed_blocked_mac', 'failed_credentials', 'failed_other') DEFAULT 'failed_credentials',
  `error_message` TEXT COMMENT 'Why login failed',
  `user_agent` TEXT COMMENT 'Browser/client info',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_mac_address` (`mac_address`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- 4. Blocked MAC Addresses Table (Optional)
-- ================================================
-- Global blacklist of suspicious MAC addresses

CREATE TABLE IF NOT EXISTS `blocked_mac_addresses` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `mac_address` VARCHAR(17) NOT NULL UNIQUE,
  `reason` TEXT COMMENT 'Why this MAC is blocked',
  `blocked_by_user_id` INT COMMENT 'Admin who blocked it',
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_mac_address` (`mac_address`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================
-- 5. Sample Data
-- ================================================

-- Insert global setting (enable MAC auth globally)
INSERT INTO `device_auth_settings` 
(`user_id`, `enable_mac_auth`, `allow_multiple_devices`, `block_new_devices`, `max_devices_per_user`, `require_admin_approval`) 
VALUES 
(NULL, TRUE, TRUE, FALSE, 3, FALSE);

-- Sample user device registration
-- Admin user (id=123) with kitchen POS machine
-- Note: Replace XX:XX:XX:XX:XX:XX with actual MAC addresses
-- INSERT INTO `user_devices` 
-- (`user_id`, `mac_address`, `device_name`, `device_type`, `status`) 
-- VALUES 
-- (123, 'AA:BB:CC:DD:EE:FF', 'Kitchen-POS-1', 'desktop', 'active'),
-- (123, 'BB:CC:DD:EE:FF:AA', 'Kitchen-Tablet-1', 'tablet', 'active');

-- Sample cashier devices
-- INSERT INTO `user_devices` 
-- (`user_id`, `mac_address`, `device_name`, `device_type`, `status`) 
-- VALUES 
-- (166, 'CC:DD:EE:FF:AA:BB', 'Cashier-POS-1', 'desktop', 'active'),
-- (166, 'DD:EE:FF:AA:BB:CC', 'Cashier-Laptop', 'laptop', 'active');
