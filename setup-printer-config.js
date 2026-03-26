/**
 * Setup Printer Configuration Table
 * Run this script once to create the printer_config table in your database
 * 
 * Usage: node setup-printer-config.js
 */

require('dotenv').config();
const { db } = require('./config/dbconnection');

const setupPrinterConfigTable = async () => {
  try {
    console.log('📋 Starting Printer Configuration Table Setup...\n');

    // Create table SQL
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS printer_config (
        id INT PRIMARY KEY AUTO_INCREMENT,
        terminal_id VARCHAR(50) NOT NULL UNIQUE COMMENT 'Machine/Terminal ID',
        location ENUM('kitchen', 'cashier') NOT NULL COMMENT 'Printer location type',
        printer_ip VARCHAR(20) NOT NULL COMMENT 'Printer IP address',
        printer_port INT DEFAULT 9100 COMMENT 'Printer port for ESC/POS (default: 9100)',
        printer_name VARCHAR(100) COMMENT 'Friendly name for the printer',
        status ENUM('active', 'inactive') DEFAULT 'active' COMMENT 'Printer configuration status',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_location (location),
        INDEX idx_terminal_id (terminal_id),
        INDEX idx_status (status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `;

    console.log('Creating table: printer_config');
    await db.query(createTableSQL);
    console.log('✅ Table created successfully!\n');

    // Optional: Insert sample data
    console.log('📝 Would you like to insert sample data? (Optional)\n');
    console.log('Sample Kitchen Printer: KITCHEN-001, IP: 192.168.1.100');
    console.log('Sample Cashier Printer: CASHIER-001, IP: 192.168.1.101\n');

    const sampleData = `
      INSERT INTO printer_config (terminal_id, location, printer_ip, printer_port, printer_name, status) 
      VALUES 
      ('KITCHEN-001', 'kitchen', '192.168.1.100', 9100, 'Kitchen Main Printer', 'active'),
      ('CASHIER-001', 'cashier', '192.168.1.101', 9100, 'Cashier Main Printer', 'active')
      ON DUPLICATE KEY UPDATE status='active';
    `;

    try {
      await db.query(sampleData);
      console.log('✅ Sample data inserted successfully!\n');
    } catch (err) {
      console.log('⚠️  Sample data insertion skipped (may already exist)\n');
    }

    // Verify table
    const [tables] = await db.query(
      "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'printer_config'"
    );

    if (tables.length > 0) {
      console.log('🎉 Printer Configuration Setup Complete!\n');
      console.log('📊 Table Statistics:');
      
      const [rows] = await db.query('SELECT COUNT(*) as count FROM printer_config');
      console.log(`   - Total configurations: ${rows[0].count}`);

      const [kitchen] = await db.query("SELECT COUNT(*) as count FROM printer_config WHERE location = 'kitchen' AND status = 'active'");
      console.log(`   - Active kitchen printers: ${kitchen[0].count}`);

      const [cashier] = await db.query("SELECT COUNT(*) as count FROM printer_config WHERE location = 'cashier' AND status = 'active'");
      console.log(`   - Active cashier printers: ${cashier[0].count}`);

      console.log('\n📚 API Documentation:');
      console.log('   - Full API Docs: docs/PRINTER_CONFIG_API.md');
      console.log('   - Quick Reference: docs/PRINTER_CONFIG_QUICK_REFERENCE.md');

      console.log('\n🔗 Available Endpoints:');
      console.log('   POST   /api/printer/config                    - Create new printer config');
      console.log('   GET    /api/printer/config                    - Get all active configs');
      console.log('   GET    /api/printer/config/:terminal_id       - Get specific printer');
      console.log('   GET    /api/printer/location/:location        - Get printers by location');
      console.log('   PUT    /api/printer/config/:terminal_id       - Update printer settings');
      console.log('   DELETE /api/printer/config/:terminal_id       - Delete configuration\n');

      process.exit(0);
    } else {
      console.log('❌ Table creation verification failed!');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Error during setup:', error.message);
    console.error('\nFull error:', error);
    process.exit(1);
  }
};

// Run setup
setupPrinterConfigTable();
