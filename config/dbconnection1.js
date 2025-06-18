require('dotenv').config(); // Ensure environment variables are loaded first
const mysql = require('mysql2');

// Destructure all DB-related env variables
const {
  DB_HOST,
  DB_PORT = 3306,         // Default MySQL port
  DB_USERNAME,
  DB_PASSWORD,
  DB_NAME
} = process.env;

// Create a connection pool with promise support
const pool = mysql.createPool({
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

// Wrap the pool in a promise wrapper for async/await support
const db = pool.promise();

// Optional: Test connection
db.getConnection()
  .then((conn) => {
    console.log(`✅ MySQL connected: ${DB_NAME}@${DB_HOST}:${DB_PORT}`);
    conn.release(); // release back to pool
  })
  .catch((err) => {
    console.error('❌ MySQL connection failed:', err.message);
    process.exit(1);
  });

module.exports = db;
