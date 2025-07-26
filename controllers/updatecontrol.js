const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const { db, format } = require('../config/dbconnection');

const jwt = require('jsonwebtoken')
const path = require('path')
const fs = require('fs')
const csv = require('csv-parser')

const updateDataPara1 = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;

    const hashed = await bcrypt.hash(req.body.pass, 10);
    const query = `UPDATE ?? SET pass = ? WHERE ?? = ?`;
    const values = [table, hashed, col1, val1];

    const [result] = await db.query(query, values);
    res.status(200).json({ msg: 'Password updated successfully' });
  } catch (err) {
    console.error('Password update error:', err);
    res.status(500).json({ msg: 'Failed to update password', error: err });
  }
};

const updateStatus = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;

    const query = `UPDATE ?? SET status = 'paid' WHERE ?? = ?`;
    const [result] = await db.query(query, [table, col1, val1]);

    res.status(200).json({ msg: 'Status updated to paid' });
  } catch (err) {
    console.error('Status update error:', err);
    res.status(500).json({ msg: 'Failed to update status', error: err });
  }
};


const updateStatus1 = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const mode = req.body.payment_mode;

    const query = `UPDATE ?? SET payment_mode = ? WHERE ?? = ?`;
    const [result] = await db.query(query, [table, mode, col1, val1]);

    res.status(200).json({ msg: 'Payment mode updated' });
  } catch (err) {
    console.error('Payment mode update error:', err);
    res.status(500).json({ msg: 'Failed to update payment mode', error: err });
  }
};


const updateCompanyInfo = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;

    const updateData = {
      cname: req.body.cname,
      address: req.body.address,
      pincode: req.body.pincode,
      contact: req.body.contact,
      gst: req.body.gst,
      state: req.body.state,
      bank: req.body.bank,
      t1: req.body.t1,
      t2: req.body.t2,
      t3: req.body.t3,
    };

    const fields = Object.keys(updateData).map(key => `${key} = ?`).join(", ");
    const values = Object.values(updateData);
    values.push(val1);

    const query = `UPDATE ?? SET ${fields} WHERE ?? = ?`;
    const [result] = await db.query(query, [table, ...values.slice(0, -1), col1, values[values.length - 1]]);

    res.status(200).json({ msg: 'Data updated' });
  } catch (err) {
    console.error('Data update error:', err);
    res.status(500).json({ msg: 'Failed to update company info', error: err });
  }
};

const updateSubscription = async (req, res) => {
  try {
    const id = req.params.id;
    const updateData = req.body;

    const fields = Object.keys(updateData).map(field => `${field} = ?`).join(", ");
    const values = [...Object.values(updateData), id];

    const query = `UPDATE coresetting SET ${fields} WHERE id = ?`;
    const [result] = await db.query(query, values);

    if (result.affectedRows === 0) {
      return res.status(404).json({ msg: "Subscription not found" });
    }

    res.status(200).json({ msg: "Subscription updated successfully" });
  } catch (err) {
    console.error("Subscription update error:", err);
    res.status(500).json({ msg: "Database error", error: err });
  }
};

const updatedata = async (req, res) => {
  console.log("✅ Entered updatedata function");
  try {
    const table = req.params.tablename;
    const { updatedFields, where } = req.body;

    console.log("🟢 req body:", req.body);
    console.log("🟢 Updating table:", table);
    console.log("🟢 updatedFields:", updatedFields);
    console.log("🟢 where:", where);

    if (!updatedFields || typeof updatedFields !== "object" || Object.keys(updatedFields).length === 0) {
      return res.status(400).json({ success: false, message: "'updatedFields' must be provided and not empty" });
    }

    if (!where || typeof where !== "object" || Object.keys(where).length === 0) {
      return res.status(400).json({ success: false, message: "'where' must be provided and not empty" });
    }

    // Build SET clause
    const setFields = Object.keys(updatedFields).map(key => `${key} = ?`).join(", ");
    const setValues = Object.values(updatedFields);

    // Build WHERE clause
    const whereClause = Object.keys(where).map(key => `${key} = ?`).join(" AND ");
    const whereValues = Object.values(where);

    const query = `UPDATE ?? SET ${setFields} WHERE ${whereClause}`;

    // Format query for debugging
    const formattedQuery = format(query, [table, ...setValues, ...whereValues]);
    console.log("🟠 Formatted Query:", formattedQuery);

    // Execute the query
    const [result] = await db.query(query, [table, ...setValues, ...whereValues]);

    if (result.affectedRows > 0) {
      res.status(200).json({ success: true, message: "Data updated successfully" });
    } else {
      res.status(404).json({ success: false, message: "Data not found" });
    }
  } catch (err) {
    console.error("❌ Unexpected error:", err);
    res.status(500).json({ success: false, message: "Internal Server Error", error: err.message });
  }
};


const updatecommondata = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const updateData = req.body;

    // Filter out undefined/null values
    const filteredData = Object.fromEntries(
      Object.entries(updateData).filter(([_, v]) => v !== undefined && v !== null)
    );

    if (Object.keys(filteredData).length === 0) {
      return res.status(400).json({ msg: 'No valid data provided for update' });
    }

    const fields = Object.keys(filteredData).map(key => `${key} = ?`).join(", ");
    const values = Object.values(filteredData);

    const query = `UPDATE ?? SET ${fields} WHERE ?? = ?`;
    const [result] = await db.query(query, [table, ...values, col1, val1]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ msg: 'Record not found' });
    }

    res.status(200).json({ msg: 'Data updated', affectedRows: result.affectedRows });
  } catch (err) {
    console.error('Data update error:', err);
    res.status(500).json({ msg: 'Failed to update data', error: err.message });
  }
};




module.exports = {
  updateDataPara1,
  updateStatus,
  updateStatus1,
  updateCompanyInfo,
  updatedata,
  updateSubscription,
  updatecommondata
}
