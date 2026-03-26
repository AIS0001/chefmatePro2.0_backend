/**
 * USER SEED SCRIPT
 * Creates a default test user for login
 * Run with: node seed-user.js
 */

const { db } = require('./config/dbconnection');
const bcrypt = require('bcryptjs');

const seedUser = async () => {
  let connection;
  try {
    console.log('🌱 Starting User Seed...\n');

    // Default test user credentials
    const testUser = {
      name: 'Test Admin',
      uname: 'admin', // Username for login
      password: 'Admin@12345', // Change this after first login
      contact: '+66-839194134',
      email: 'admin@test.com',
      type: 'admin' // admin, Cashier, Account, etc.
    };

    // Hash password
    const hashedPassword = await bcrypt.hash(testUser.password, 10);

    // Get connection from pool
    connection = await db.getConnection();

    // Check if user already exists
    const [results] = await connection.query(
      'SELECT * FROM users WHERE uname = ? OR email = ?',
      [testUser.uname, testUser.email]
    );

    if (results && results.length > 0) {
      console.log('⚠️  User already exists!');
      console.log('\n📋 Existing User Details:');
      console.log(`   ID: ${results[0].id}`);
      console.log(`   Name: ${results[0].name}`);
      console.log(`   Username: ${results[0].uname}`);
      console.log(`   Email: ${results[0].email}`);
      console.log(`   Type: ${results[0].type}`);
      console.log(`   Status: ${results[0].status ? 'Active' : 'Inactive'}`);
      connection.release();
      process.exit(0);
      return;
    }

    // Insert new user
    const insertQuery = `
      INSERT INTO users 
      (name, uname, pass, contact, email, type, status, last_loggedin)
      VALUES (?, ?, ?, ?, ?, ?, 1, NOW())
    `;

    const [insertResult] = await connection.query(insertQuery, [
      testUser.name,
      testUser.uname,
      hashedPassword,
      testUser.contact,
      testUser.email,
      testUser.type
    ]);

    console.log('✅ User Created Successfully!\n');
    console.log('📋 User Details:');
    console.log(`   ID: ${insertResult.insertId}`);
    console.log(`   Name: ${testUser.name}`);
    console.log(`   Username: ${testUser.uname}`);
    console.log(`   Email: ${testUser.email}`);
    console.log(`   Password: ${testUser.password}`);
    console.log(`   Type: ${testUser.type}`);
    console.log(`   Status: Active`);
    console.log('\n🔐 Login Credentials:');
    console.log(`   Username: ${testUser.uname}`);
    console.log(`   Password: ${testUser.password}`);
    console.log('\n⚠️  IMPORTANT: Change the password after first login!');
    console.log(`\n📍 Login Endpoint: POST /api/login`);
    console.log(`   Body: { "uname": "${testUser.uname}", "pass": "${testUser.password}" }`);
    
    connection.release();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error in seed script:', error.message);
    if (connection) connection.release();
    process.exit(1);
  }
};

// Run seed
seedUser();
