const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const { jwt_secret } = process.env

const getSales = (req, res) => {
  const authToken = req.headers.authorization.split(" ")[1];
  const query = `
    SELECT DATE(inv_date) as date, SUM(grand_total) as amount
    FROM final_bill
    GROUP BY DATE(inv_date)
    ORDER BY date
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching sales data:", err);
      return res.status(500).json({ error: "Failed to fetch sales data" });
    }
    res.json(results);
  });
};


const getPurchase  = (req, res) => {
   const query = `
    SELECT DATE(created_at) as date, SUM(netAmount) as amount
    FROM inventory
    GROUP BY DATE(created_at)
    ORDER BY date
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching purchase data:", err);
      return res.status(500).json({ error: "Failed to fetch purchase data" });
    }
    res.json(results);
  });
};
const getSummary  = (req, res) => {
 const salesQuery = `SELECT SUM(grand_total) AS totalSales FROM final_bill`;
  const purchaseQuery = `SELECT SUM(netAmount) AS totalPurchase FROM inventory`;

  db.query(salesQuery, (err, salesResult) => {
    if (err) {
      console.error("Error fetching sales summary:", err);
      return res.status(500).json({ error: "Failed to fetch summary" });
    }

    db.query(purchaseQuery, (err, purchaseResult) => {
      if (err) {
        console.error("Error fetching purchase summary:", err);
        return res.status(500).json({ error: "Failed to fetch summary" });
      }

      res.json({
        totalSales: salesResult[0].totalSales || 0,
        totalPurchase: purchaseResult[0].totalPurchase || 0,
      });
    });
   
  });
};

module.exports = {
    getSales,
    getPurchase,
    getSummary


}