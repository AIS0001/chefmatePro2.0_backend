require("dotenv").config();
const mysql = require("mysql");

const {
  DB_HOST,
  DB_PORT,
  DB_USERNAME,
  DB_PASSWORD,
  DB_NAME,
} = process.env;

const pool = mysql.createPool({
  host: DB_HOST,
  port: DB_PORT || 3306,
  user: DB_USERNAME,
  password: DB_PASSWORD,
  database: DB_NAME,
  dateStrings: true,
  connectionLimit: 10, // number of connections in pool
  waitForConnections: true,
  queueLimit: 0,
});

pool.getConnection((err, connection) => {
  if (err) {
    console.error("Database connection failed:", err);
  } else {
    console.log(`${DB_NAME} Database Connected successfully (Pool)`);
    connection.release(); // release back to pool
  }
});

module.exports = pool;
