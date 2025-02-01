DB_PASSWORD='Realforce@123'
const { DB_HOST, DB_USERNAME, DB_NAME } = process.env;

const mysql = require('mysql2'); // Use mysql2 for better connection management

// Create a pool with the necessary parameters
const pool = mysql.createPool({
  host: DB_HOST,
  user: DB_USERNAME,
  password: DB_PASSWORD,
  database: DB_NAME,
  dateStrings: true,
});

// Export the promise-based pool to handle connections and transactions
module.exports = pool.promise();