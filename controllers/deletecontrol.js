const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const { jwt_secret } = process.env

// const deletedatabyid = async (req, res) => {
//   const authToken = req.headers.authorization.split(' ')[1]
//   const decode = jwt.verify(authToken, jwt_secret)
//   const colval1 = [req.params.colval]
//   const colname1 = [req.params.colname]
//   const table = [req.params.tablename]
// try {
//   await db.query(`DELETE FROM ${table} WHERE ${colname1}=?`,colval1);
//   return res.status(200).json({ message: `Record with ID ${colval1} deleted from ${table}` });
// }
// catch(err)
// {
//  console.error('Error deleting record:', error);
//     return res.status(500).json({ message: 'Internal Server Error', error: error.message });
 

// }
 
// }
const deletedatabyid = async (req, res) => {
  try {
    console.log("🟢 DELETE REQUEST RECEIVED");
    console.log("📋 Request params:", req.params);
    console.log("📋 Request body:", req.body);
    console.log("📋 Request headers:", req.headers);

    const { tablename, colname, colval } = req.params;
    
    console.log("🔍 Extracted parameters:");
    console.log("  - Table:", tablename);
    console.log("  - Column:", colname);
    console.log("  - Value:", colval);

    // Validate required parameters
    if (!tablename || !colname || !colval) {
      console.log("❌ Missing required parameters");
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required parameters: tablename, colname, or colval' 
      });
    }

    // Whitelist of allowed tables for security
    const allowedTables = [
      'items', 'customers', 'suppliers', 'inventory', 'orders', 
      'order_items', 'advance_order_items', 'final_bill', 'payments',
      'categories', 'units', 'taxes', 'discounts'
    ];

    if (!allowedTables.includes(tablename)) {
      console.log("❌ Invalid table name:", tablename);
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid table name' 
      });
    }

    // Check if record exists before deletion
    const checkQuery = `SELECT COUNT(*) as count FROM ?? WHERE ?? = ?`;
    console.log("🔍 Check query:", checkQuery);
    console.log("🔍 Check params:", [tablename, colname, colval]);

    const [checkResult] = await db.query(checkQuery, [tablename, colname, colval]);
    const recordCount = checkResult[0].count;
    
    console.log("📊 Records found:", recordCount);

    if (recordCount === 0) {
      console.log("❌ No records found to delete");
      return res.status(404).json({ 
        success: false, 
        message: 'Record not found' 
      });
    }

    // Perform deletion
    const deleteQuery = `DELETE FROM ?? WHERE ?? = ?`;
    console.log("🗑️ Delete query:", deleteQuery);
    console.log("🗑️ Delete params:", [tablename, colname, colval]);

    const [result] = await db.query(deleteQuery, [tablename, colname, colval]);
    
    console.log("✅ Delete result:", result);
    console.log("📊 Affected rows:", result.affectedRows);

    if (result.affectedRows > 0) {
      console.log("✅ Deletion successful");
      res.status(200).json({ 
        success: true, 
        message: `${result.affectedRows} record(s) deleted successfully`,
        affectedRows: result.affectedRows
      });
    } else {
      console.log("❌ No rows affected");
      res.status(400).json({ 
        success: false, 
        message: 'No records were deleted' 
      });
    }

  } catch (error) {
    console.error("❌ DELETE ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting record', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

// Add bulk delete function
const deleteBulkData = async (req, res) => {
  try {
    console.log("🟢 BULK DELETE REQUEST RECEIVED");
    console.log("📋 Request params:", req.params);
    console.log("📋 Request body:", req.body);

    const { tablename } = req.params;
    const { ids, columnName = 'id' } = req.body;

    console.log("🔍 Extracted parameters:");
    console.log("  - Table:", tablename);
    console.log("  - Column:", columnName);
    console.log("  - IDs:", ids);

    // Validate required parameters
    if (!tablename || !ids || !Array.isArray(ids) || ids.length === 0) {
      console.log("❌ Missing or invalid parameters");
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required parameters: tablename or ids array' 
      });
    }

    // Whitelist of allowed tables for security
    const allowedTables = [
      'items', 'customers', 'suppliers', 'inventory', 'orders', 
      'order_items', 'advance_order_items', 'final_bill', 'payments',
      'categories', 'units', 'taxes', 'discounts'
    ];

    if (!allowedTables.includes(tablename)) {
      console.log("❌ Invalid table name:", tablename);
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid table name' 
      });
    }

    // Create placeholders for IN clause
    const placeholders = ids.map(() => '?').join(',');
    
    // Check if records exist before deletion
    const checkQuery = `SELECT COUNT(*) as count FROM ?? WHERE ?? IN (${placeholders})`;
    console.log("🔍 Check query:", checkQuery);
    console.log("🔍 Check params:", [tablename, columnName, ...ids]);

    const [checkResult] = await db.query(checkQuery, [tablename, columnName, ...ids]);
    const recordCount = checkResult[0].count;
    
    console.log("📊 Records found:", recordCount);

    if (recordCount === 0) {
      console.log("❌ No records found to delete");
      return res.status(404).json({ 
        success: false, 
        message: 'No records found to delete' 
      });
    }

    // Perform bulk deletion
    const deleteQuery = `DELETE FROM ?? WHERE ?? IN (${placeholders})`;
    console.log("🗑️ Delete query:", deleteQuery);
    console.log("🗑️ Delete params:", [tablename, columnName, ...ids]);

    const [result] = await db.query(deleteQuery, [tablename, columnName, ...ids]);
    
    console.log("✅ Bulk delete result:", result);
    console.log("📊 Affected rows:", result.affectedRows);

    if (result.affectedRows > 0) {
      console.log("✅ Bulk deletion successful");
      res.status(200).json({ 
        success: true, 
        message: `${result.affectedRows} record(s) deleted successfully`,
        affectedRows: result.affectedRows,
        requestedIds: ids,
        deletedCount: result.affectedRows
      });
    } else {
      console.log("❌ No rows affected in bulk delete");
      res.status(400).json({ 
        success: false, 
        message: 'No records were deleted' 
      });
    }

  } catch (error) {
    console.error("❌ BULK DELETE ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting records', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

module.exports = {
  deletedatabyid,
  deleteBulkData
};

