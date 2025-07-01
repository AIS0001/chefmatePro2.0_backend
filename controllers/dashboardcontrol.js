const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const db = require('../config/dbconnection1'); // db is now a promise pool

const jwt = require('jsonwebtoken');
const jwt_secret = process.env.JWT_SECRET || 'setupnewkey';

// GET SALES
const getSales = async (req, res) => {
  try {
    const query = `
      SELECT DATE(inv_date) as date, SUM(grand_total) as amount
      FROM final_bill
      GROUP BY DATE(inv_date)
      ORDER BY date
    `;

    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("Error fetching sales data:", err);
    res.status(500).json({ error: "Failed to fetch sales data", details: err.message });
  }
};


// GET PURCHASE
const getPurchase = (req, res) => {
  const query = `
    SELECT DATE(created_at) as date, SUM(netAmount) as amount
    FROM inventory
    GROUP BY DATE(created_at)
    ORDER BY date
  `;

  db.query(query)
    .then(([results]) => res.json(results))
    .catch(err => {
      console.error("Error fetching purchase data:", err);
      res.status(500).json({ error: "Failed to fetch purchase data" });
    });
};

// GET SUMMARY
const getSummary = async (req, res) => {
  try {
    const [salesResult] = await db.query(`SELECT SUM(grand_total) AS totalSales FROM final_bill`);
    const [purchaseResult] = await db.query(`SELECT SUM(netAmount) AS totalPurchase FROM inventory`);
    const [topProductResult] = await db.query(`
      SELECT item_name, SUM(quantity) AS totalSold
      FROM order_items
      GROUP BY item_name
      ORDER BY totalSold DESC
      LIMIT 1
    `);

    res.json({
      totalSales: salesResult[0].totalSales || 0,
      totalPurchase: purchaseResult[0].totalPurchase || 0,
      topProduct: topProductResult[0]?.item_name || null
    });
  } catch (err) {
    console.error("Error fetching summary:", err);
    res.status(500).json({ error: "Failed to fetch summary" });
  }
};

// GET TOP PRODUCTS
const getTopProducts = (req, res) => {
  const topProductsQuery = `
    SELECT item_name, SUM(quantity) AS totalSold
    FROM order_items
    GROUP BY item_name
    ORDER BY totalSold DESC
    LIMIT 10
  `;

  db.query(topProductsQuery)
    .then(([results]) => res.json(results))
    .catch(err => {
      console.error("Error fetching top products:", err);
      res.status(500).json({ error: "Failed to fetch top products" });
    });
};

// GET TODAY SALE & PURCHASE
const todaysalepurchase = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

    const [todaySales] = await db.query(`SELECT SUM(grand_total) AS val FROM final_bill WHERE DATE(inv_date) = ?`, [today]);
    const [yesterdaySales] = await db.query(`SELECT SUM(grand_total) AS val FROM final_bill WHERE DATE(inv_date) = ?`, [yesterday]);
    const [todayPurchases] = await db.query(`SELECT SUM(netAmount) AS val FROM inventory WHERE DATE(pdate) = ?`, [today]);
    const [yesterdayPurchases] = await db.query(`SELECT SUM(netAmount) AS val FROM inventory WHERE DATE(pdate) = ?`, [yesterday]);
    const [transactionCount] = await db.query(`SELECT COUNT(*) AS val FROM final_bill WHERE DATE(inv_date) = ?`, [today]);

    const sales = todaySales[0].val || 0;
    const purchases = todayPurchases[0].val || 0;
    const profitMargin = sales > 0 ? ((sales - purchases) / sales) * 100 : 0;

    res.json({
      todaySales: sales,
      yesterdaySales: yesterdaySales[0].val || 0,
      todayPurchases: purchases,
      yesterdayPurchases: yesterdayPurchases[0].val || 0,
      profitMargin: profitMargin.toFixed(2),
      todayTransactionCount: transactionCount[0].val || 0
    });
  } catch (err) {
    console.error("Error fetching daily summary:", err);
    res.status(500).json({ error: "Failed to fetch summary" });
  }
};

// LOW STOCK ALERTS
const getLowStockAlerts = (req, res) => {
  const query = `
    SELECT i.id, i.iname, i.min_stock, inv.closing_stock
    FROM items i
    JOIN (SELECT item_id, MAX(id) as latest_id FROM inventory GROUP BY item_id) latest
    ON latest.item_id = i.id
    JOIN inventory inv ON inv.id = latest.latest_id
    WHERE inv.closing_stock <= i.min_stock
  `;

  db.query(query)
    .then(([results]) => res.json(results))
    .catch(err => {
      console.error("Error fetching low stock alerts:", err);
      res.status(500).json({ error: "Failed to fetch low stock alerts" });
    });
};

module.exports = {
  getSales,
  getPurchase,
  getSummary,
  todaysalepurchase,
  getLowStockAlerts,
  getTopProducts
};