/**
 * Setup Device Authentication Tables
 * Run this script once to create device authentication tables
 * 
 * Usage: node setup-device-auth.js
 */

require('dotenv').config();
const { db } = require('./config/dbconnection');

const setupDeviceAuthTables = async () => {
  try {
    console.log('📋 Starting Device Authentication Setup...\n');

    // SQL scripts for tables
    const tableQueries = [
      // User Devices Table
      `CREATE TABLE IF NOT EXISTS user_devices (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL COMMENT 'References users.id',
        mac_address VARCHAR(17) NOT NULL COMMENT 'Device MAC address',
        device_name VARCHAR(100) COMMENT 'Friendly device name',
        device_type ENUM('desktop', 'laptop', 'tablet', 'mobile', 'other') DEFAULT 'desktop',
        status ENUM('active', 'inactive', 'blocked') DEFAULT 'active',
        last_login_at TIMESTAMP NULL COMMENT 'Last successful login',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_user_devices_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_mac_address (mac_address),
        INDEX idx_status (status),
        KEY unique_user_mac (user_id, mac_address)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

      // Device Auth Settings Table
      `CREATE TABLE IF NOT EXISTS device_auth_settings (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT UNIQUE COMMENT 'NULL = Global setting',
        enable_mac_auth BOOLEAN DEFAULT FALSE COMMENT 'Enable MAC authentication',
        allow_multiple_devices BOOLEAN DEFAULT TRUE COMMENT 'Allow multiple devices',
        require_first_device BOOLEAN DEFAULT FALSE COMMENT 'Must use first device',
        block_new_devices BOOLEAN DEFAULT FALSE COMMENT 'Block unregistered MACs',
        max_devices_per_user INT DEFAULT 3 COMMENT 'Maximum devices per user',
        require_admin_approval BOOLEAN DEFAULT FALSE COMMENT 'Needs admin approval',
        session_timeout_hours INT DEFAULT 24 COMMENT 'Session timeout',
        allow_device_override BOOLEAN DEFAULT FALSE COMMENT 'User can add devices',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_device_auth_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

      // Login Attempts Log Table
      `CREATE TABLE IF NOT EXISTS login_attempts (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT COMMENT 'User attempting login',
        username VARCHAR(233) COMMENT 'Username used',
        mac_address VARCHAR(17) COMMENT 'MAC address',
        ip_address VARCHAR(45) COMMENT 'IP address',
        device_name VARCHAR(100) COMMENT 'Device/hostname',
        status ENUM('success', 'failed_invalid_mac', 'failed_no_mac', 'failed_blocked_mac', 'failed_credentials', 'failed_other') DEFAULT 'failed_credentials',
        error_message TEXT COMMENT 'Failure reason',
        user_agent TEXT COMMENT 'Browser/client info',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_mac_address (mac_address),
        INDEX idx_status (status),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

      // Blocked MAC Addresses Table
      `CREATE TABLE IF NOT EXISTS blocked_mac_addresses (
        id INT PRIMARY KEY AUTO_INCREMENT,
        mac_address VARCHAR(17) NOT NULL UNIQUE,
        reason TEXT COMMENT 'Why blocked',
        blocked_by_user_id INT COMMENT 'Admin who blocked',
        status ENUM('active', 'inactive') DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_mac_address (mac_address),
        INDEX idx_status (status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`
    ];

    // Execute table creation
    for (const query of tableQueries) {
      const tableName = query.match(/CREATE TABLE IF NOT EXISTS (\w+)/)[1];
      console.log(`Creating table: ${tableName}...`);
      await db.query(query);
    }

    console.log('✅ All tables created successfully!\n');

    // Insert global settings
    console.log('Inserting global device authentication settings...');
    await db.query(
      `INSERT INTO device_auth_settings (user_id, enable_mac_auth, allow_multiple_devices, max_devices_per_user) 
       VALUES (NULL, TRUE, TRUE, 3)
       ON DUPLICATE KEY UPDATE enable_mac_auth=TRUE`
    );
    console.log('✅ Global settings configured!\n');

    // Verify tables
    const [tables] = await db.query(
      `SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
       WHERE TABLE_SCHEMA = DATABASE() 
       AND TABLE_NAME IN ('user_devices', 'device_auth_settings', 'login_attempts', 'blocked_mac_addresses')`
    );

    if (tables.length === 4) {
      console.log('🎉 Device Authentication Setup Complete!\n');
      console.log('📊 Tables Created:');
      tables.forEach(t => {
        console.log(`   ✓ ${t.TABLE_NAME}`);
      });

      console.log('\n📚 Documentation:');
      console.log('   - Full Documentation: docs/DEVICE_AUTH_DOCUMENTATION.md');
      console.log('   - Database: user_devices, device_auth_settings, login_attempts, blocked_mac_addresses');

      console.log('\n🔗 Available Endpoints:');
      console.log('   POST   /api/device/register                      - Register device');
      console.log('   GET    /api/device/user/:user_id                 - Get user devices');
      console.log('   POST   /api/device/verify-mac                    - Verify MAC address');
      console.log('   PUT    /api/device/:device_id                    - Update device');
      console.log('   DELETE /api/device/:device_id                    - Delete device');
      console.log('   GET    /api/device/settings/:user_id             - Get settings');
      console.log('   PUT    /api/device/settings/:user_id             - Update settings');
      console.log('   POST   /api/device/block-mac                     - Block MAC globally');
      console.log('   GET    /api/device/logs/:user_id                 - Get login logs\n');

      process.exit(0);
    } else {
      console.log('❌ Table verification failed!');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Error during setup:', error.message);
    console.error('\nFull error:', error);
    process.exit(1);
  }
};

setupDeviceAuthTables();
