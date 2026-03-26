/**
 * Setup script to add user_uuid column to users table
 * Run this once to apply the database migration
 */

const { db } = require("../config/dbconnection");
const fs = require("fs");
const path = require("path");

const setupUserUuidColumn = async () => {
  try {
    console.log("🔧 Starting user_uuid column setup...\n");

    // Check if column already exists
    const [columns] = await db.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'users' 
        AND COLUMN_NAME = 'user_uuid'
    `);

    if (columns.length > 0) {
      console.log("✅ user_uuid column already exists in users table");
      console.log("   Skipping migration\n");
      process.exit(0);
    }

    console.log("📝 Adding user_uuid column to users table...");

    // Add the column
    await db.query(`
      ALTER TABLE users 
      ADD COLUMN user_uuid VARCHAR(36) NULL DEFAULT NULL 
      AFTER id
    `);

    console.log("✅ Column added successfully\n");

    // Add index for better performance
    console.log("📝 Adding index on user_uuid column...");
    
    await db.query(`
      ALTER TABLE users 
      ADD INDEX idx_user_uuid (user_uuid)
    `);

    console.log("✅ Index added successfully\n");

    // Verify the changes
    const [verifyColumns] = await db.query(`
      SHOW COLUMNS FROM users WHERE Field = 'user_uuid'
    `);

    if (verifyColumns.length > 0) {
      console.log("✅ Migration verified successfully!");
      console.log("\n📊 Column details:");
      console.log(verifyColumns[0]);
      console.log("\n🎉 Setup complete! Users will now get UUIDs on first login.\n");
    }

    process.exit(0);

  } catch (error) {
    console.error("❌ Error during setup:", error);
    process.exit(1);
  }
};

setupUserUuidColumn();
