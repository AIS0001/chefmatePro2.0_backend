const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const { db, format } = require('../config/dbconnection');

const jwt = require('jsonwebtoken');
const jwt_secret = 'setupnewkey';

const allUsers = async (req, res) => {
  try {
    const authToken = req.headers.authorization.split(' ')[1];
    jwt.verify(authToken, jwt_secret);
    const [result] = await db.query(`SELECT * FROM user ORDER BY id ASC`);
    res.status(200).send({ success: true, data: result, message: 'Fetch Data Successfully' });
  } catch (err) {
    console.error('Error in allUsers:', err);
    res.status(500).send({ success: false, message: 'Internal Server Error' });
  }
};

const combolistwithWhere = async (req, res) => {
  try {
    const { where } = req.query;
    const table = req.params.tablename;
    const id = req.params.groupby;
    const query = `SELECT * FROM ?? ${where ? `WHERE ${where}` : ""} GROUP BY ??`;
    const formattedQuery = format(query, [table, id]);
    const [results] = await db.query(formattedQuery);
    res.json(results);
  } catch (err) {
    console.error('Error in combolistwithWhere:', err);
    res.status(500).send('Error fetching data from the database');
  }
};

const viewAllData = async (req, res) => {
  try {
    const authToken = req.headers.authorization.split(' ')[1];
    jwt.verify(authToken, jwt_secret);
    const table = req.params.tablename;
    const id = req.params.orderby;
    const query = format(`SELECT * FROM ?? ORDER BY ?? DESC`, [table, id]);
    const [result] = await db.query(query);
    res.status(200).send({ success: true, data: result, message: 'Data Saved !!' });
  } catch (err) {
    console.error('Error in viewAllData:', err);
    res.status(500).send('Error retrieving data');
  }
};

const combolist = async (req, res) => {
  try {
    const table = req.params.tablename;
    const id = req.params.groupby;
    const query = format(`SELECT * FROM ?? GROUP BY ??`, [table, id]);
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error('Error in combolist:', err);
    res.status(500).send('Error fetching data from the database');
  }
};

const viewAllDataLimit = async (req, res) => {
  try {
    const authToken = req.headers.authorization.split(' ')[1];
    jwt.verify(authToken, jwt_secret);
    const table = req.params.tablename;
    const lmt = parseInt(req.params.limit);
    const query = format(`SELECT * FROM ?? ORDER BY id DESC LIMIT ?`, [table, lmt]);
    const [result] = await db.query(query);
    res.status(200).send({ success: true, data: result, message: 'Data Saved !!' });
  } catch (err) {
    console.error('Error in viewAllDataLimit:', err);
    res.status(500).send('Error retrieving data');
  }
};

const fetchData = async (req, res) => {
  try {
    const tblname = req.params.tblname;
    const orderby = req.params.orderby;
    const where = req.params[0] ? decodeURIComponent(req.params[0]) : '';
    const params = new URLSearchParams(where);

    const conditions = [];
    const values = [];

    for (const [key, value] of params.entries()) {
      conditions.push(`${key} = ?`);
      values.push(value);
    }

    const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';
    const query = `SELECT * FROM ?? ${whereClause} ORDER BY ??`;
    const formattedQuery = format(query, [tblname, ...values, orderby]);
console.log(formattedQuery);
    const [results] = await db.query(formattedQuery);
    res.status(200).json({ status: 'success', message: 'Data fetched successfully', data: results });
  } catch (err) {
    console.error('SQL Error:', err);
    res.status(500).json({ status: 'error', message: 'An error occurred while fetching data', data: null });
  }
};
const fetchDatanotequal = async (req, res) => {
  try {
    const tblname = req.params.tblname;
    const orderby = req.params.orderby;
    const where = req.params[0] ? decodeURIComponent(req.params[0]) : '';
    const params = new URLSearchParams(where);

    const conditions = [];
    const values = [];

    for (const [key, value] of params.entries()) {
      conditions.push(`${key} != ?`);
      values.push(value);
    }

    const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';
    const query = `SELECT * FROM ?? ${whereClause} ORDER BY ??`;
    const formattedQuery = format(query, [tblname, ...values, orderby]);

    const [results] = await db.query(formattedQuery);
    res.status(200).json({ status: 'success', message: 'Data fetched successfully', data: results });
  } catch (err) {
    console.error('SQL Error:', err);
    res.status(500).json({ status: 'error', message: 'An error occurred while fetching data', data: null });
  }
};


const fetchDataFromTwoTables = async (req, res) => {
  try {
    const { tbl1, tbl2, col1, col2, orderby } = req.params;
    const { where } = req.query;

    // Build dynamic SQL
    let query = `
      SELECT t1.*, t2.*
      FROM ${tbl1} t1
      INNER JOIN ${tbl2} t2 ON t1.${col1} = t2.${col2}
    `;

    if (where) {
      query += ` WHERE ${where}`;
    }

    if (orderby) {
      query += ` ORDER BY ${orderby}`;
    }

    console.log("SQL Query:", query);

    const [results] = await db.query(query);
    res.status(200).json({ success: true, data: results });

  } catch (err) {
    console.error("Database error:", err);
    res.status(500).json({ success: false, error: "Database error", details: err.message });
  }
};

const fetchDataFromTwoTables1 = (req, res) => {
  let { tbl1, tbl2, col1, col2, orderby } = req.params;
  const { where } = req.query;

  // Basic sanitization
  if (!allowedTables.includes(tbl1) || !allowedTables.includes(tbl2)) {
    return res.status(400).json({ error: "Invalid table names" });
  }

  if (!allowedColumns.includes(col1) || !allowedColumns.includes(col2)) {
    return res.status(400).json({ error: "Invalid column names" });
  }

  // Optional: sanitize orderby column
  if (orderby && !allowedColumns.includes(orderby)) {
    return res.status(400).json({ error: "Invalid orderby column" });
  }

  let query = `
    SELECT t1.*, t2.name AS supplier_name
    FROM ${tbl1} t1
    INNER JOIN ${tbl2} t2 ON t1.${col1} = t2.${col2}
    ${where ? `WHERE ${where}` : ""}
    ${orderby ? `ORDER BY ${orderby}` : ""}
  `;

  console.log("SQL Query:", query);

  db.query(query, (err, results) => {
    if (err) {
      console.error("Query Error:", err);
      return res.status(500).json({ error: "Database error" });
    }
    res.json({ data: results });
  });
};


const getMaxOrderNumber = async (req, res) => {
  const { col1, val1, tbl: table, field: field1 } = req.params;

  try {
    const query = `SELECT IFNULL(MAX(${field1}), 1) AS maxOrderNumber FROM ${table} WHERE ${col1} = ?`;

    const [results] = await db.query(query, [val1]);

    let newOrderNumber = 1;
    if (results.length && results[0].maxOrderNumber !== null) {
      newOrderNumber = results[0].maxOrderNumber + 1;
    }

    res.json({ data: newOrderNumber });
    // console.log(`New order number for ${col1}=${val1}: ${newOrderNumber}`);
  } catch (err) {
    console.error("DB Error:", err);
    res.status(500).json({ error: "Failed to fetch max order number" });
  }
};


const getRunningTable = async (req, res) => {
  try {
    const table = req.params.tbl;
    const query = format(`SELECT * FROM ?? WHERE invoice_number IS NULL`, [table]);
    const [results] = await db.query(query);
    res.json({ data: results });
  } catch (err) {
    console.error('Error in getRunningTable:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};



// Get Order Details with Subtotals
const getOrderDetailsWithSubtotals = async (req, res) => {
  const table1 = req.params.table1 || "orders";
  const table2 = req.params.table2 || "order_items";
  const tableNumber = req.query.tableNumber;
  const status = 1;

  let query = `
    SELECT 
      o.order_number,
      oi.item_name AS item_name,
      oi.quantity AS qty,
      oi.total_price AS rate,
      (oi.quantity * oi.total_price) AS subtotal
    FROM 
      ${table1} o
    JOIN 
      ${table2} oi ON o.id = oi.order_id
    WHERE 
      o.status = ?`;

  const queryParams = [status];
  if (tableNumber) {
    query += ` AND o.table_number = ?`;
    queryParams.push(tableNumber);
  }

  try {
    const [results] = await db.query(query, queryParams);
    res.json({ data: results });
  } catch (err) {
    console.error("Error fetching order details:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// Check if a ledger entry exists
const checkledgerentry = async (req, res) => {
  const { refno } = req.params;
  try {
    const [rows] = await db.query('SELECT * FROM ledger_entries WHERE transaction_id = ?', [refno]);
    res.json({
      exists: rows.length > 0,
      data: rows
    });
  } catch (err) {
    console.error('Ledger check error:', err);
    res.status(500).json({ error: 'Ledger lookup failed' });
  }
};

// Check Line Discount eligibility
const checklLineDiscount = async (req, res) => {
  const { phone } = req.body;

  try {
    const [rows] = await db.query("SELECT * FROM line_discount_customers WHERE phone = ?", [phone]);
    if (rows.length > 0) {
      return res.json({ eligible: false });
    }
    return res.json({ eligible: true });
  } catch (err) {
    console.error("Error checking line discount:", err);
    res.status(500).json({ error: "Failed to check line discount" });
  }
};

// Get order_items_gst joined with item/category/subcategory
const getOrderItemsGstJoined = async (req, res) => {
  const query = `
    SELECT 
      o.*, 
      i.iname, 
      i.catid, 
      i.subcatid,
      c.name AS category_name, 
      s.subcat AS subcategory_name
    FROM 
      order_items_gst o
    JOIN 
      items i ON TRIM(LOWER(o.item_name)) = TRIM(LOWER(i.iname))
    LEFT JOIN 
      categories c ON i.catid = c.id
    LEFT JOIN 
      subcategory s ON i.subcatid = s.id
    ORDER BY 
      o.id DESC
  `;

  try {
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("JOIN query error:", err);
    res.status(500).json({ error: "Failed to fetch joined order items GST data" });
  }
};
const getOrderItemsJoined = async (req, res) => {
  const query = `
    SELECT 
      o.*, 
      i.iname, 
      i.catid, 
      i.subcatid,
      c.name AS category_name, 
      s.subcat AS subcategory_name
    FROM 
      order_items o
    JOIN 
      items i ON TRIM(LOWER(o.item_name)) = TRIM(LOWER(i.iname))
    LEFT JOIN 
      categories c ON i.catid = c.id
    LEFT JOIN 
      subcategory s ON i.subcatid = s.id
    ORDER BY 
      o.id DESC
  `;

  try {
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("JOIN query error:", err);
    res.status(500).json({ error: "Failed to fetch joined order items GST data" });
  }
};




// viewcontroller.js
const getInventoryClosingStock = async (req, res) => {
  try {
    const { item_id } = req.params;
    const query = `SELECT closing_stock FROM inventory WHERE item_id = ? ORDER BY id DESC LIMIT 1`;
    const [rows] = await db.query(query, [item_id]);

    res.json(rows[0] || { closing_stock: 0 });
  } catch (err) {
    console.error("DB Error:", err);
    res.status(500).json({ error: "Failed to fetch closing stock" });
  }
};

const getInventoryWithItems = async (req, res) => {
  try {
    const query = `
      SELECT 
        inventory.*, 
        items.iname AS item_name
      FROM 
        inventory 
      JOIN 
        items ON inventory.item_id = items.id
      ORDER BY inventory.id DESC
    `;
 console.log(query);
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("JOIN query error:", err);
    res.status(500).json({ error: "Failed to fetch joined inventory data" });
  }
};

const getinvoiceitems = async (req, res) => {
  const { refno } = req.params;
  const query = `SELECT * FROM inventory WHERE refno = ?`;

  try {
    const [rows] = await db.query(query, [refno]);
    res.json(rows);
  } catch (err) {
    console.error('Get invoice items error:', err);
    res.status(500).json({ error: 'Error fetching items' });
  }
};


// ...existing code...

const getLatestRecord = async (req, res) => {
  try {
    const authToken = req.headers.authorization.split(' ')[1];
    jwt.verify(authToken, jwt_secret);
    
    const table = req.params.tablename;
    const query = format(`SELECT * FROM ?? ORDER BY id DESC LIMIT 1`, [table]);
    
    console.log('Latest Record Query:', query);
    
    const [result] = await db.query(query);
    
    if (result.length === 0) {
      return res.status(404).send({ 
        success: false, 
        message: 'No records found in the table',
        data: null 
      });
    }
    
    let latestRecord = result[0];
    
    // Check if quotation_number exists and increment it
    if (latestRecord.quotation_number) {
      // Extract the numeric part from quotation_number (e.g., QUO-2025-0001 -> 0001)
      const quotationMatch = latestRecord.quotation_number.match(/(\d+)$/);
      if (quotationMatch) {
        const currentNumber = parseInt(quotationMatch[1]);
        const nextNumber = (currentNumber + 1).toString().padStart(4, '0');
        const year = new Date().getFullYear();
        const nextQuotationNumber = `QUO-${year}-${nextNumber}`;
        
        latestRecord = {
          ...latestRecord,
          next_quotation_number: nextQuotationNumber
        };
      }
    }
    
    res.status(200).send({ 
      success: true, 
      data: latestRecord, 
      message: 'Latest record fetched successfully' 
    });
  } catch (err) {
    console.error('Error in getLatestRecord:', err);
    res.status(500).send({ 
      success: false, 
      message: 'Internal Server Error',
      error: err.message 
    });
  }
};

// ...existing code...

module.exports = {
  getMaxOrderNumber,
  allUsers,
  combolist,
  viewAllData,
  viewAllDataLimit,
  fetchData,
  combolistwithWhere,
  fetchDataFromTwoTables,
  getRunningTable,
  getOrderDetailsWithSubtotals,
  getInventoryClosingStock,
  getInventoryWithItems,
  checkledgerentry,
  getinvoiceitems,
  checklLineDiscount,
  getOrderItemsGstJoined,
  getOrderItemsJoined,
  fetchDatanotequal,
  getLatestRecord,
}



