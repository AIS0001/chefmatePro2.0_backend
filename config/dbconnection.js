require('dotenv').config();
const mysql = require('mysql2/promise');

const { DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_NAME } = process.env;

const db = mysql.createPool({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_USERNAME,
  password: DB_PASSWORD,
  database: DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  dateStrings: true,
});

const format = mysql.format;

// Test connection immediately
(async () => {
  try {
    const connection = await db.getConnection();
    console.log(`✅ connection 1 MySQL connected to database: ${DB_NAME}@${DB_HOST}:${DB_PORT}`);
    connection.release(); // Release back to pool
  } catch (err) {
    console.error('❌ Failed to connect to MySQL:', err.message);
  }
})();

module.exports = { db, format };
