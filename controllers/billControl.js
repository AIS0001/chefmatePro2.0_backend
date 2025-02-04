const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const db = require('../config/dbconnection1'); // Import updated dbconnection.js
const jwt = require('jsonwebtoken');
const path = require('path');
const fs = require('fs');
const csv = require('csv-parser');

// ✅ Function to Save a New Bill

const savebill = async (req, res) => {
    const connection = await db.getConnection(); // Get a connection from the pool
  
    try {
      await connection.beginTransaction(); // Start transaction
  
      const { customer_id, tablenumber,subtotal,subtotal_afterdiscount, tax, discount_type, discount_value, round_off,grand_total, payment_mode } = req.body;
  
      // Calculate discount amount
      let discount_amount = discount_type === "percentage" ? (subtotal * discount_value) / 100 : discount_value;
      let net_total = subtotal + tax - discount_amount + round_off;
  
      // Insert Bill into `final_bill`
      const billQuery = `
        INSERT INTO final_bill (customer_id, inv_date, inv_time, table_number,subtotal, discount_type, discount_value,subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode)
        VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;
  
      console.log('Executing Query:', billQuery);
  
      const [billResult] = await connection.execute(
        billQuery,
        [customer_id,tablenumber, subtotal,  discount_type, discount_value, subtotal_afterdiscount,tax,round_off, grand_total, payment_mode]
      );
  
      const bill_id = billResult.insertId; // Get the final bill ID
      if (!bill_id) throw new Error("Bill ID not generated");
  
      // Use `bill_id` as `transaction_id`
      const transaction_id = bill_id;
  
      // Default account IDs (adjust as needed)
      const sales_account_id = 1; // Sales Account
      const cash_account_id = 2; // Cash Account
      const receivable_account_id = 3; // Accounts Receivable
      const discount_account_id = 4; // Discount Given
      const roundoff_account_id = 5; // Round Off Account
      const tax_account_id = 6; // Tax Account
  
      // Create Ledger Entries
      let ledgerEntries = [
        [transaction_id, new Date(), "Sales", sales_account_id, `Bill #${bill_id} - Sales`, 0.00, net_total, bill_id]
      ];
  
      if (payment_mode === "Cash" ) {
        ledgerEntries.push([transaction_id, new Date(), "Cash", cash_account_id, `Bill #${bill_id} - Cash Payment`, net_total, 0.00, bill_id]);
      } 
      else if (payment_mode === "Bank Transfer") {
        ledgerEntries.push([transaction_id, new Date(), "Bank Transfer", cash_account_id, `Bill #${bill_id} - Bank Transfer Payment`, net_total, 0.00, bill_id]);
    }
      else if (payment_mode === "QR Code") {
        ledgerEntries.push([transaction_id, new Date(), "QR Code", cash_account_id, `Bill #${bill_id} - QR Payment`, net_total, 0.00, bill_id]);
    }
      else if (payment_mode === "UPI") {
        ledgerEntries.push([transaction_id, new Date(), "UPI", cash_account_id, `Bill #${bill_id} - UPI Payment`, net_total, 0.00, bill_id]);
    }
    else if (payment_mode === "Credit") {
      ledgerEntries.push([transaction_id, new Date(), "Account Recievable", receivable_account_id, `Bill #${bill_id} - Credit Sale`, net_total, 0.00, bill_id]);
  }
  
      if (discount_amount > 0) {
        ledgerEntries.push([transaction_id, new Date(), "Discount", discount_account_id, `Bill #${bill_id} - Discount Given`, discount_amount, 0.00, bill_id]);
      }
  
      if (round_off !== 0) {
        ledgerEntries.push([
          transaction_id, 
          new Date(), 
          "Round Off", 
          roundoff_account_id, 
          `Bill #${bill_id} - Round Off`, 
          round_off > 0 ? round_off : 0.00, 
          round_off < 0 ? Math.abs(round_off) : 0.00, 
          bill_id
        ]);
      }
  
      if (tax > 0) {
        ledgerEntries.push([transaction_id, new Date(), "Tax", tax_account_id, `Bill #${bill_id} - Tax`, tax, 0.00, bill_id]);
      }
  
      // Insert into `ledger_entries`
      const ledgerQuery = `
        INSERT INTO ledger_entries (transaction_id, date, account_type, account_id, description, debit_amount, credit_amount, reference_id)
        VALUES ?
      `;
  
      console.log('Executing Ledger Query:', ledgerQuery);
      
      await connection.query(ledgerQuery, [ledgerEntries]);
  
      await connection.commit(); // Commit transaction
      res.status(201).json({ success: true, message: "Bill & Ledger saved successfully!", bill_id });
  
    } catch (error) {
      await connection.rollback(); // Rollback on error
      console.error("Error saving bill:", error);
      res.status(500).json({ success: false, message: "Error saving bill", error });
    } finally {
      connection.release(); // Release the connection back to the pool
    }
  };
  
  

// ✅ Function to Retrieve All Bills
const getBills = async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM final_bill ORDER BY inv_date DESC");
    res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error("Error fetching bills:", error);
    res.status(500).json({ success: false, message: "Error fetching bills", error });
  }
};

// ✅ Function to Get a Single Bill by ID
const getBillById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.execute("SELECT * FROM final_bill WHERE id = ?", [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: "Bill not found" });
    }

    res.status(200).json({ success: true, data: rows[0] });
  } catch (error) {
    console.error("Error fetching bill:", error);
    res.status(500).json({ success: false, message: "Error fetching bill", error });
  }
};

// ✅ Function to Delete a Bill
const deleteBill = async (req, res) => {
  const connection = await db.getConnection(); // Get a connection from the pool
  try {
    await connection.beginTransaction();

    const { id } = req.params;

    // Delete Ledger Entries First
    await connection.execute("DELETE FROM ledger_entries WHERE reference_id = ?", [id]);

    // Then Delete Bill
    const [result] = await connection.execute("DELETE FROM final_bill WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: "Bill not found" });
    }

    await connection.commit();
    res.status(200).json({ success: true, message: "Bill deleted successfully" });

  } catch (error) {
    await connection.rollback();
    console.error("Error deleting bill:", error);
    res.status(500).json({ success: false, message: "Error deleting bill", error });
  } finally {
    connection.release();
  }
};

// ✅ Function to Update a Bill
const updateBill = async (req, res) => {
  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const { id } = req.params;
    const { subtotal, tax, discount_type, discount_value, roundoff, payment_mode } = req.body;

    let discount_amount = discount_type === "percentage" ? (subtotal * discount_value) / 100 : discount_value;
    let net_total = subtotal + tax - discount_amount + round_off;

    // Update Bill
    const updateQuery = `
      UPDATE final_bill 
      SET subtotal = ?, tax = ?, discount_type = ?, discount_value = ?, discount_amount = ?, round_off = ?, net_total = ?, payment_mode = ? 
      WHERE id = ?
    `;
    const [result] = await connection.execute(updateQuery, [
      subtotal, tax, discount_type, discount_value, discount_amount, round_off, net_total, payment_mode, id
    ]);

    if (result.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: "Bill not found" });
    }

    await connection.commit();
    res.status(200).json({ success: true, message: "Bill updated successfully" });

  } catch (error) {
    await connection.rollback();
    console.error("Error updating bill:", error);
    res.status(500).json({ success: false, message: "Error updating bill", error });
  } finally {
    connection.release();
  }
};

module.exports = { savebill, getBills, getBillById, deleteBill, updateBill };
