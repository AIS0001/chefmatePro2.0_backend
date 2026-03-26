/**
 * SUPER ADMIN SEED SCRIPT
 * Creates a default super admin user for initial login
 * Run with: node seed-super-admin.js
 */

const { db } = require('./config/dbconnection');
const bcrypt = require('bcryptjs');

const seedSuperAdmin = async () => {
  let connection;
  try {
    console.log('🌱 Starting Super Admin Seed...\n');

    // Default super admin credentials
    const superAdmin = {
      username: 'superadmin',
      email: 'admin@chefmate.com',
      password: 'Admin@12345', // Change this after first login
      first_name: 'Super',
      last_name: 'Admin',
      phone_number: '+66-839194134',
      role: 'super_admin'
    };

    // Hash password
    const hashedPassword = await bcrypt.hash(superAdmin.password, 10);

    // Get connection from pool
    connection = await db.getConnection();

    // Check if super admin already exists
    const [results] = await connection.query(
      'SELECT * FROM super_admin_users WHERE username = ? OR email = ?',
      [superAdmin.username, superAdmin.email]
    );

    if (results && results.length > 0) {
      console.log('⚠️  Super admin already exists!');
      console.log('\n📋 Existing Super Admin Details:');
      console.log(`   Username: ${results[0].username}`);
      console.log(`   Email: ${results[0].email}`);
      console.log(`   Role: ${results[0].role}`);
      console.log(`   Active: ${results[0].is_active ? 'Yes' : 'No'}`);
      connection.release();
      process.exit(0);
      return;
    }

    // Insert new super admin
    const insertQuery = `
      INSERT INTO super_admin_users 
      (username, email, password_hash, first_name, last_name, phone_number, role, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())
    `;

    const [insertResult] = await connection.query(insertQuery, [
      superAdmin.username,
      superAdmin.email,
      hashedPassword,
      superAdmin.first_name,
      superAdmin.last_name,
      superAdmin.phone_number,
      superAdmin.role
    ]);

    console.log('✅ Super Admin Created Successfully!\n');
    console.log('📋 Super Admin Details:');
    console.log(`   ID: ${insertResult.insertId}`);
    console.log(`   Username: ${superAdmin.username}`);
    console.log(`   Email: ${superAdmin.email}`);
    console.log(`   Password: ${superAdmin.password}`);
    console.log(`   Role: ${superAdmin.role}`);
    console.log(`   Status: Active`);
    console.log('\n🔐 Login Credentials:');
    console.log(`   Username: ${superAdmin.username}`);
    console.log(`   Password: ${superAdmin.password}`);
    console.log('\n⚠️  IMPORTANT: Change the password after first login!');
    console.log(`\n📍 Login Endpoint: POST /api/super-admin/login`);
    console.log(`   Body: { "username": "${superAdmin.username}", "password": "${superAdmin.password}" }`);
    
    connection.release();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error in seed script:', error.message);
    if (connection) connection.release();
    process.exit(1);
  }
};

// Run seed
seedSuperAdmin();
