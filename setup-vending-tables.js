const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'cloudnet_chefmate',
  multipleStatements: true
};

async function createVendingMachineTables() {
  let connection;
  
  try {
    console.log('🔍 Connecting to database...');
    console.log('Database:', dbConfig.database);
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connected to database successfully');
    
    // Read SQL file
    const sqlFilePath = path.join(__dirname, 'database', 'vending_machine_tables.sql');
    console.log('📖 Reading SQL file:', sqlFilePath);
    
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
    console.log('✅ SQL file read successfully');
    
    // Execute SQL statements
    console.log('🚀 Executing SQL statements...');
    const result = await connection.execute(sqlContent);
    console.log('✅ SQL statements executed successfully');
    
    // Check if tables were created
    const [tables] = await connection.execute("SHOW TABLES LIKE '%vending%'");
    console.log('📋 Vending machine related tables:');
    tables.forEach((table, index) => {
      console.log(`  ${index + 1}. ${Object.values(table)[0]}`);
    });
    
    console.log('✅ Vending machine tables setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Error creating vending machine tables:', error.message);
    
    if (error.code === 'ER_BAD_DB_ERROR') {
      console.error('💡 Database does not exist. Please create the database first:');
      console.error(`   CREATE DATABASE ${dbConfig.database};`);
    } else if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('💡 Access denied. Please check your database credentials.');
    } else {
      console.error('💡 Full error:', error);
    }
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔐 Database connection closed');
    }
  }
}

// Run the setup
createVendingMachineTables();
