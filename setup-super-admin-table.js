/**
 * SETUP SUPER ADMIN TABLE SCRIPT
 * Creates the super_admin_users table if it doesn't exist
 * Run with: node setup-super-admin-table.js
 */

const { db } = require('./config/dbconnection');

const setupSuperAdminTable = async () => {
  let connection;
  try {
    console.log('🔧 Setting up Super Admin Table...\n');

    connection = await db.getConnection();

    // Create super_admin_users table if it doesn't exist
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS super_admin_users (
        id INT PRIMARY KEY AUTO_INCREMENT,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        phone_number VARCHAR(20),
        role VARCHAR(50) DEFAULT 'super_admin',
        is_active TINYINT(1) DEFAULT 1,
        login_attempts INT DEFAULT 0,
        account_locked_until DATETIME,
        last_login DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_username (username),
        INDEX idx_email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `;

    await connection.query(createTableQuery);
    console.log('✅ Super Admin Table Created/Verified!\n');

    connection.release();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating table:', error.message);
    if (connection) connection.release();
    process.exit(1);
  }
};

// Run setup
setupSuperAdminTable();
