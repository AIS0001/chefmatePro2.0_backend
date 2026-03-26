/**
 * Setup script to add mac_address column to printer_config table
 * Run: node setup-printer-mac.js
 */

const { db } = require('./config/dbconnection');

async function setupPrinterMacAddress() {
  try {
    console.log('🔄 ChefMate Pro - Printer MAC Address Setup\n');

    // Check if mac_address column exists
    console.log('📋 Checking if mac_address column exists...');
    const [columns] = await db.query(`
      SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'printer_config' AND COLUMN_NAME = 'mac_address'
    `);

    if (columns.length > 0) {
      console.log('✅ mac_address column already exists\n');
      
      // Verify data
      const [printers] = await db.query('SELECT * FROM printer_config LIMIT 1');
      if (printers.length > 0) {
        console.log('📊 Sample Printer Config:');
        console.log(JSON.stringify(printers[0], null, 2));
      }
      
      return;
    }

    // Add mac_address column
    console.log('➕ Adding mac_address column to printer_config table...');
    await db.query(`
      ALTER TABLE printer_config 
      ADD COLUMN mac_address VARCHAR(17) NULL 
      COMMENT 'Machine MAC address for auto-detection (XX:XX:XX:XX:XX:XX format)' 
      AFTER terminal_id
    `);
    console.log('✅ mac_address column added successfully\n');

    // Add index for mac_address
    console.log('🔍 Adding index for mac_address...');
    await db.query(`
      ALTER TABLE printer_config 
      ADD INDEX idx_mac_address (mac_address)
    `);
    console.log('✅ mac_address index created successfully\n');

    // Verify the changes
    console.log('📋 Verifying column structure...');
    const [verifyColumns] = await db.query(`
      SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'printer_config' 
      ORDER BY ORDINAL_POSITION
    `);

    console.log('\n📊 Printer Config Table Structure:');
    console.log('=====================================');
    verifyColumns.forEach(col => {
      console.log(`  ${col.COLUMN_NAME}: ${col.COLUMN_TYPE} (${col.IS_NULLABLE === 'YES' ? 'nullable' : 'required'})`);
      if (col.COLUMN_COMMENT) console.log(`    └─ ${col.COLUMN_COMMENT}`);
    });

    console.log('\n✅ Setup completed successfully!');
    console.log('\n📝 Example API Usage:');
    console.log('  POST /api/printer/config');
    console.log('  Body: {');
    console.log('    "terminal_id": "KITCHEN-001",');
    console.log('    "mac_address": "00:1A:2B:3C:4D:5E",');
    console.log('    "location": "kitchen",');
    console.log('    "printer_ip": "192.168.1.100",');
    console.log('    "printer_port": 9100,');
    console.log('    "printer_name": "Kitchen Printer 1"');
    console.log('  }\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    if (error.sql) {
      console.error('SQL:', error.sql);
    }
    process.exit(1);
  }
}

// Run setup
setupPrinterMacAddress();
