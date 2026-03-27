const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const { db, format } = require('../config/dbconnection'); // updated
const jwt = require('jsonwebtoken');
const path = require('path');
const fs = require('fs');
const csv = require('csv-parser');
const { requireShopId, tableHasShopId } = require('../helpers/shopScope');

const insertdata = async (req, res) => {
  try {
    const table = req.params.tablename;
    const val3 = { ...req.body };

    if (await tableHasShopId(db, table)) {
      const shopId = requireShopId(req, res);
      if (shopId === null) return;
      val3.shop_id = shopId;
    }
    
    // Fix for items table: remove sprice as it doesn't exist in the table
    if (table === 'items' && val3.sprice !== undefined) {
      delete val3.sprice;
    }
    
    const keys = Object.keys(val3);
    const values = Object.values(val3);

    const placeholders = keys.map(() => '?').join(', ');
    const query = format(`INSERT INTO ?? (${keys.join(',')}) VALUES (${placeholders})`, [table, ...values]);

    const [result] = await db.query(query);
    return res.status(200).send({
      msg: 'Data saved successfully',
      id: result.insertId,
    });
  } catch (err) {
    console.error('Insert Error:', err);
    return res.status(400).send({ msg: err.message });
  }
};

const insertquotation = async (req, res) => {
  try {
    const table = req.params.tablename;
    const val3 = { ...req.body };

    if (await tableHasShopId(db, table)) {
      const shopId = requireShopId(req, res);
      if (shopId === null) return;
      val3.shop_id = shopId;
    }

    const keys = Object.keys(val3);
    const values = Object.values(val3);

    const placeholders = keys.map(() => '?').join(', ');
    const query = format(`INSERT INTO ?? (${keys.join(',')}) VALUES (${placeholders})`, [table, ...values]);

    const [result] = await db.query(query);
    return res.status(200).send({
      msg: 'Data saved successfully',
      id: result.insertId,
    });
  } catch (err) {
    console.error('Insert Error:', err);
    return res.status(400).send({ msg: err.message });
  }
};
const savebill = async (req, res) => {
  const connection = await db.getConnection();
  await connection.beginTransaction();
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) {
      await connection.rollback();
      return;
    }

    const { customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, payment_mode, setup_date } = req.body;

    const discount_amounts = discount_type === 'percentage' ? (subtotal * discount_value) / 100 : discount_value;
    const net_total = subtotal + tax - discount_amounts + roundoff;

    const billQuery = `
      INSERT INTO final_bill 
      (shop_id, customer_id, inv_date, inv_time, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode, setup_date)
      VALUES (?, ?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

    const [billResult] = await connection.execute(billQuery, [
      shopId, customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode, setup_date
    ]);
    const bill_id = billResult.insertId;

    const ledgerEntries = [];

    ledgerEntries.push(['Sales Account', 'credit', net_total, bill_id]);
    if (payment_mode === 'Cash') {
      ledgerEntries.push(['Cash Account', 'debit', net_total, bill_id]);
    } else if (payment_mode === 'Credit') {
      ledgerEntries.push(['Accounts Receivable', 'debit', net_total, bill_id]);
    }
    if (discount_amount > 0) {
      ledgerEntries.push(['Discount Given', 'debit', discount_amount, bill_id]);
    }
    if (roundoff !== 0) {
      ledgerEntries.push(['Round Off', roundoff > 0 ? 'debit' : 'credit', Math.abs(roundoff), bill_id]);
    }

    const ledgerQuery = `INSERT INTO ledger_entries (account_name, entry_type, amount, reference_id) VALUES ?`;
    await connection.query(ledgerQuery, [ledgerEntries]);

    await connection.commit();
    res.status(201).json({ success: true, message: 'Bill & Ledger saved successfully!', bill_id });
  } catch (error) {
    await connection.rollback();
    console.error('Error saving bill:', error);
    res.status(500).json({ success: false, message: 'Error saving bill', error: error.message });
  } finally {
    connection.release();
  }
};

const insertdatabulk = async (req, res) => {
  try {
    const tableName = req.params.tablename;
    const validTableNames = ['order_items','quotation_items', 'advance_order_items'];
    if (!validTableNames.includes(tableName)) {
      return res.status(400).json({ success: false, message: 'Invalid table name' });
    }

    const items = req.body.items;
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'No items provided' });
    }

    let query, values;
    
    if (tableName === 'quotation_items') {
      // Handle quotation_items table structure
      values = items.map(item => [
        item.quotation_id || item.quotation_number,
        item.table_number || item.customer_id,
        item.item_name,
        item.quantity,
        item.rate || item.unit_price,
        item.total_amount || item.total_price,
        item.status || 'active',
        item.setup_date,
        item.table_cat_id || null
      ]);
      
      query = `INSERT INTO ${tableName} (quotation_id, customer_id, item_name, quantity, rate, total_amount, status, setup_date, table_cat_id) VALUES ?`;
    } else {
      const shopId = requireShopId(req, res);
      if (shopId === null) return;

      // Handle order_items and advance_order_items table structure
      values = items.map(item => [
        shopId,
        item.order_number || item.order_id,
        item.table_number,
        item.item_name,
        item.item_group || null,
        item.quantity,
        item.total_amount || item.total_price,
        item.status || 'pending',
        item.setup_date,
        item.table_cat_id || null,
        item.catid || item.category_id || null,
        item.subcatid || item.subcategory_id || null
      ]);
      
      query = `INSERT INTO ${tableName} (shop_id, order_id, table_number, item_name, item_group, quantity, total_price, status, setup_date, table_cat_id, catid, subcatid) VALUES ?`;
    }

     console.log('Bulk Insert Query:', query);
    // console.log('Bulk Insert Values:', values);
    // console.log('Table Name:', tableName);
    
    await db.query(query, [values]);

    res.json({ 
      success: true, 
      message: `${tableName === 'quotation_items' ? 'Quotation' : 'Order'} items saved successfully`,
      count: items.length
    });
  } catch (err) {
    console.error('Bulk Insert Error:', err);
    console.error('Error details:', {
      message: err.message,
      code: err.code,
      sqlMessage: err.sqlMessage,
      sqlState: err.sqlState
    });
    res.status(500).json({ 
      success: false, 
      message: `Error saving ${req.params.tablename} items`, 
      error: err.message,
      sqlError: err.sqlMessage || 'Database error'
    });
  }
};

const insertdatabulkgst = async (req, res) => {
  try {
    const tableName = req.params.tablename;
    const validTableNames = ['order_items_gst', 'advance_order_items_gst'];
    if (!validTableNames.includes(tableName)) {
      return res.status(400).json({ success: false, message: 'Invalid table name' });
    }

    const items = req.body.items;
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'No items provided' });
    }

    let values;

    values = items.map(item => [
      item.order_id,
      item.table_number,
      item.item_name,
      item.quantity,
      item.uom || '',
      item.rate || 0,
      item.cgst || 0,
      item.sgst || 0,
      item.igst || 0,
      item.tax_amount || 0,
      item.total_price,
      item.status,
      item.setup_date, // setup_date from frontend
    ]);

    const query = `INSERT INTO ${tableName} 
      (order_id, table_number, item_name, quantity, uom, rate, cgst, sgst, igst, tax_amount, total_price, status, setup_date) 
      VALUES ?`;

    await db.query(query, [values]);
    res.json({ success: true, message: 'Order items saved successfully' });
  } catch (err) {
    console.error('Bulk GST Insert Error:', err);
    res.status(500).json({ success: false, message: 'Error saving order items', error: err.message });
  }
};

const addNewProduct = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const product_id = req.body.product_id;
    const tbl = req.params.tablename;

    // Check if files exist
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }

    const files = req.files.map(file => [
      shopId,
      product_id,
      file.filename,
      file.path,
      file.mimetype,
      file.size,
    ]);

    const query = `INSERT INTO ${tbl} (shop_id, product_id, filename, path, mimetype, size) VALUES ?`;
    await db.query(query, [files]);

    res.status(200).json({ message: 'Images uploaded and saved to database successfully!' });
  } catch (err) {
    console.error('Image Upload Error:', err);
    res.status(500).json({ message: 'Failed to upload images', error: err.message });
  }
};

const uploadcsv = async (req, res) => {
  try {
    const csvFile = req.files.csvFile;
    const results = [];

    fs.createReadStream(csvFile.tempFilePath)
      .pipe(csv())
      .on('data', async (row) => {
        try {
          const sql = `INSERT INTO brands (id, brand_name, description) VALUES (?, ?, ?)`;
          const values = [row.id, row.brand_name, row.description];
          await db.query(sql, values);
        } catch (err) {
          console.error('CSV Row Error:', err.message);
        }
      })
      .on('end', () => {
        res.status(200).json({ message: 'CSV file imported into MySQL successfully' });
      });
  } catch (err) {
    console.error('CSV Upload Error:', err.message);
    res.status(500).json({ message: 'Error uploading CSV', error: err.message });
  }
};

module.exports = {
  insertdata,
  insertquotation,
  savebill,
  insertdatabulk,
  insertdatabulkgst,
  addNewProduct,
  uploadcsv,
};
