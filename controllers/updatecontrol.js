const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const { db, format } = require('../config/dbconnection');

const jwt = require('jsonwebtoken')
const path = require('path')
const fs = require('fs')
const csv = require('csv-parser')
const { requireShopId, tableHasShopId } = require('../helpers/shopScope');

const updateDataPara1 = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

    const hashed = await bcrypt.hash(req.body.pass, 10);
    const query = scopedTable
      ? `UPDATE ?? SET pass = ? WHERE ?? = ? AND shop_id = ?`
      : `UPDATE ?? SET pass = ? WHERE ?? = ?`;
    const values = scopedTable
      ? [table, hashed, col1, val1, shopId]
      : [table, hashed, col1, val1];

    const [result] = await db.query(query, values);
    res.status(200).json({ msg: 'Password updated successfully' });
  } catch (err) {
    // console.error('Password update error:', err);
    res.status(500).json({ msg: 'Failed to update password', error: err });
  }
};

const updateStatus = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

    const query = scopedTable
      ? `UPDATE ?? SET status = 'paid' WHERE ?? = ? AND shop_id = ?`
      : `UPDATE ?? SET status = 'paid' WHERE ?? = ?`;
    const [result] = await db.query(query, scopedTable ? [table, col1, val1, shopId] : [table, col1, val1]);

    res.status(200).json({ msg: 'Status updated to paid' });
  } catch (err) {
    // console.error('Status update error:', err);
    res.status(500).json({ msg: 'Failed to update status', error: err });
  }
};


const updateStatus1 = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const mode = req.body.payment_mode;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

    const query = scopedTable
      ? `UPDATE ?? SET payment_mode = ? WHERE ?? = ? AND shop_id = ?`
      : `UPDATE ?? SET payment_mode = ? WHERE ?? = ?`;
    const [result] = await db.query(query, scopedTable ? [table, mode, col1, val1, shopId] : [table, mode, col1, val1]);

    res.status(200).json({ msg: 'Payment mode updated' });
  } catch (err) {
    // console.error('Payment mode update error:', err);
    res.status(500).json({ msg: 'Failed to update payment mode', error: err });
  }
};


const updateCompanyInfo = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

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

    const query = scopedTable
      ? `UPDATE ?? SET ${fields} WHERE ?? = ? AND shop_id = ?`
      : `UPDATE ?? SET ${fields} WHERE ?? = ?`;
    const params = scopedTable
      ? [table, ...values, col1, val1, shopId]
      : [table, ...values, col1, val1];
    const [result] = await db.query(query, params);

    res.status(200).json({ msg: 'Data updated' });
  } catch (err) {
    // console.error('Data update error:', err);
    res.status(500).json({ msg: 'Failed to update company info', error: err });
  }
};

/**
 * Update Company Info with FormData Support and Role-Based Restrictions
 * SuperAdmin can update: name, tax_id, and all other fields
 * Shop Admin can update: branding (logo, qrCode), banking details, and other non-critical fields
 */
const updateCompanyInfoFormData = async (req, res) => {
  try {
    const id = req.params.id;
    const shopId = req.shop_id || req.user?.shop_id;

    // Get user role from JWT
    const userRole = req.user?.type || req.user?.role || 'USER';
    const isSuperAdmin = userRole === 'SUPER_ADMIN' || userRole === 'Admin';

    // Fields that only SuperAdmin can modify
    const superAdminOnlyFields = ['name', 'tax_id'];
    
    // Fields that are allowed for regular shop admins (non-critical fields)
    const shopAdminAllowedFields = [
      'phone_number', 'email', 'address', 'website', 'city', 'state', 
      'zip_code', 'country', 'bank_name', 'account_number', 'account_name', 
      'routing_number', 'swift_code', 'payment_methods', 'terms_and_conditions'
    ];

    // Build updateData from FormData fields (in req.body for express-fileupload)
    const updateData = {};
    const allowedFields = isSuperAdmin 
      ? ['name', 'tax_id', ...shopAdminAllowedFields]
      : shopAdminAllowedFields;

    // Extract allowed fields from request body (FormData fields)
    for (const field of allowedFields) {
      if (req.body && field in req.body) {
        // Check if non-superadmin is trying to modify restricted fields
        if (!isSuperAdmin && superAdminOnlyFields.includes(field)) {
          continue; // Skip restricted fields for non-admin users
        }
        updateData[field] = req.body[field];
      }
    }

    // Handle file uploads if present (logo, qrCode)
    if (req.files) {
      if (req.files.logo) {
        updateData.logo = req.files.logo.data; // Binary data
        updateData.logo_type = req.files.logo.mimetype;
        updateData.logo_name = req.files.logo.name;
      }
      if (req.files.qrCode) {
        updateData.qr_code = req.files.qrCode.data; // Binary data
        updateData.qr_code_type = req.files.qrCode.mimetype;
        updateData.qr_code_name = req.files.qrCode.name;
      }
    }

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: isSuperAdmin ? 'No fields to update' : 'Insufficient permissions to update the requested fields'
      });
    }

    // Build query
    const fields = Object.keys(updateData).map(key => `${key} = ?`).join(", ");
    const values = Object.values(updateData);

    const query = shopId 
      ? `UPDATE company_profile SET ${fields} WHERE id = ? AND shop_id = ?`
      : `UPDATE company_profile SET ${fields} WHERE id = ?`;
    
    const params = shopId ? [...values, id, shopId] : [...values, id];

    const [result] = await db.query(query, params);

    if (result.affectedRows === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Company info not found or you do not have permission to modify it'
      });
    }

    res.status(200).json({ 
      success: true, 
      message: 'Company information updated successfully'
    });

  } catch (err) {
    console.error('Error updating company info:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update company info', 
      error: err.message 
    });
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
    // console.error("Subscription update error:", err);
    res.status(500).json({ msg: "Database error", error: err });
  }
};

const updatedata = async (req, res) => {
  // console.log("✅ Entered updatedata function");
  try {
    const table = req.params.tablename;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

    const updatedFields = { ...(req.body.updatedFields || {}) };
    const where = { ...(req.body.where || {}) };

    // console.log("🟢 req body:", req.body);
    // console.log("🟢 Updating table:", table);
    // console.log("🟢 updatedFields:", updatedFields);
    // console.log("🟢 where:", where);

    if (!updatedFields || typeof updatedFields !== "object" || Object.keys(updatedFields).length === 0) {
      return res.status(400).json({ success: false, message: "'updatedFields' must be provided and not empty" });
    }

    if (!where || typeof where !== "object" || Object.keys(where).length === 0) {
      return res.status(400).json({ success: false, message: "'where' must be provided and not empty" });
    }

    if (scopedTable) {
      delete updatedFields.shop_id;
      where.shop_id = shopId;
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
    // console.log("🟠 Formatted Query:", formattedQuery);

    // Execute the query
    const [result] = await db.query(query, [table, ...setValues, ...whereValues]);

    if (result.affectedRows > 0) {
      res.status(200).json({ success: true, message: "Data updated successfully" });
    } else {
      res.status(404).json({ success: false, message: "Data not found" });
    }
  } catch (err) {
    // console.error("❌ Unexpected error:", err);
    res.status(500).json({ success: false, message: "Internal Server Error", error: err.message });
  }
};


const updatecommondata = async (req, res) => {
  try {
    const table = req.params.tablename;
    const col1 = req.params.col1;
    const val1 = req.params.val1;
    const updateData = req.body;
    const scopedTable = await tableHasShopId(db, table);
    const shopId = scopedTable ? requireShopId(req, res) : null;
    if (scopedTable && shopId === null) return;

    // Filter out undefined/null values
    const filteredData = Object.fromEntries(
      Object.entries(updateData).filter(([_, v]) => v !== undefined && v !== null)
    );

    if (scopedTable) {
      delete filteredData.shop_id;
    }

    if (Object.keys(filteredData).length === 0) {
      return res.status(400).json({ msg: 'No valid data provided for update' });
    }

    const fields = Object.keys(filteredData).map(key => `${key} = ?`).join(", ");
    const values = Object.values(filteredData);

    const query = scopedTable
      ? `UPDATE ?? SET ${fields} WHERE ?? = ? AND shop_id = ?`
      : `UPDATE ?? SET ${fields} WHERE ?? = ?`;
    const params = scopedTable
      ? [table, ...values, col1, val1, shopId]
      : [table, ...values, col1, val1];
    const [result] = await db.query(query, params);
console.log('🟢 Update Query Executed:', query);
    if (result.affectedRows === 0) {
      return res.status(404).json({ msg: 'Record not found' });
    }

    res.status(200).json({ msg: 'Data updated', affectedRows: result.affectedRows });
  } catch (err) {
    // console.error('Data update error:', err);
    res.status(500).json({ msg: 'Failed to update data', error: err.message });
  }
};




module.exports = {
  updateDataPara1,
  updateStatus,
  updateStatus1,
  updateCompanyInfo,
  updateCompanyInfoFormData,
  updatedata,
  updateSubscription,
  updatecommondata
}
