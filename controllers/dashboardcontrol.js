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

// GET WEEKLY SALES DATA
const getWeeklySales = async (req, res) => {
  try {
    const query = `
      SELECT YEAR(inv_date) AS year, WEEK(inv_date, 1) AS week, 
             MIN(inv_date) AS week_start, MAX(inv_date) AS week_end,
             SUM(grand_total) AS total_sales, COUNT(*) AS bill_count
      FROM final_bill
      GROUP BY YEAR(inv_date), WEEK(inv_date, 1)
      ORDER BY year DESC, week DESC
    `;
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("Error fetching weekly sales data:", err);
    res.status(500).json({ error: "Failed to fetch weekly sales data", details: err.message });
  }
};

// GET MONTHLY SALES DATA
const getMonthlySales = async (req, res) => {
  try {
    const query = `
      SELECT YEAR(inv_date) AS year, MONTH(inv_date) AS month,
             MIN(inv_date) AS month_start, MAX(inv_date) AS month_end,
             SUM(grand_total) AS total_sales, COUNT(*) AS bill_count
      FROM final_bill
      GROUP BY YEAR(inv_date), MONTH(inv_date)
      ORDER BY year DESC, month DESC
    `;
    const [results] = await db.query(query);
    res.json(results);
  } catch (err) {
    console.error("Error fetching monthly sales data:", err);
    res.status(500).json({ error: "Failed to fetch monthly sales data", details: err.message });
  }
};

// GET WEEKLY PURCHASE DATA (Current Week Only)
const getWeeklyPurchase = async (req, res) => {
  try {
    const query = `
      SELECT DATE(MIN(created_at)) AS week_start, DATE(MAX(created_at)) AS week_end,
             YEAR(created_at) AS year, WEEK(created_at, 1) AS week,
             SUM(netAmount) AS total_purchase, COUNT(*) AS purchase_count
      FROM inventory
      WHERE YEAR(created_at) = YEAR(CURDATE()) 
        AND WEEK(created_at, 1) = WEEK(CURDATE(), 1)
      GROUP BY YEAR(created_at), WEEK(created_at, 1)
    `;
    const [results] = await db.query(query);
    
    // If no data for current week, return zero values
    if (results.length === 0) {
      const currentDate = new Date();
      const startOfWeek = new Date(currentDate.setDate(currentDate.getDate() - currentDate.getDay() + 1));
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      
      return res.json([{
        week_start: startOfWeek.toISOString().split('T')[0],
        week_end: endOfWeek.toISOString().split('T')[0],
        amount: 0,
        purchase_count: 0
      }]);
    }
    
    // For graph chart, return week_start, week_end, total_purchase
    res.json(results.map(row => ({
      week_start: row.week_start,
      week_end: row.week_end,
      amount: row.total_purchase,
      purchase_count: row.purchase_count
    })));
  } catch (err) {
    console.error("Error fetching weekly purchase data:", err);
    res.status(500).json({ error: "Failed to fetch weekly purchase data", details: err.message });
  }
};

// GET MONTHLY PURCHASE DATA (Current Month Only)
const getMonthlyPurchase = async (req, res) => {
  try {
    const query = `
      SELECT YEAR(created_at) AS year, MONTH(created_at) AS month,
             MIN(created_at) AS month_start, MAX(created_at) AS month_end,
             SUM(netAmount) AS total_purchase, COUNT(*) AS purchase_count
      FROM inventory
      WHERE YEAR(created_at) = YEAR(CURDATE()) 
        AND MONTH(created_at) = MONTH(CURDATE())
      GROUP BY YEAR(created_at), MONTH(created_at)
    `;
    const [results] = await db.query(query);
    
    // If no data for current month, return zero values
    if (results.length === 0) {
      const currentDate = new Date();
      const startOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
      const endOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
      
      return res.json([{
        year: currentDate.getFullYear(),
        month: currentDate.getMonth() + 1,
        month_start: startOfMonth.toISOString().split('T')[0],
        month_end: endOfMonth.toISOString().split('T')[0],
        total_purchase: 0,
        purchase_count: 0
      }]);
    }
    
    res.json(results);
  } catch (err) {
    console.error("Error fetching monthly purchase data:", err);
    res.status(500).json({ error: "Failed to fetch monthly purchase data", details: err.message });
  }
};

// GET WEEKLY SUMMARY DATA (Current Week Only)
const getWeeklySummary = async (req, res) => {
  try {
    const query = `
      SELECT 
        YEAR(fb.inv_date) AS year, 
        WEEK(fb.inv_date, 1) AS week,
        MIN(fb.inv_date) AS week_start, 
        MAX(fb.inv_date) AS week_end,
        SUM(fb.grand_total) AS total_sales,
        COUNT(fb.id) AS bill_count,
        COALESCE(p.total_purchase, 0) AS total_purchase,
        COALESCE(p.purchase_count, 0) AS purchase_count,
        (SUM(fb.grand_total) - COALESCE(p.total_purchase, 0)) AS profit
      FROM final_bill fb
      LEFT JOIN (
        SELECT 
          YEAR(created_at) AS year, 
          WEEK(created_at, 1) AS week,
          SUM(netAmount) AS total_purchase,
          COUNT(*) AS purchase_count
        FROM inventory
        WHERE YEAR(created_at) = YEAR(CURDATE()) 
          AND WEEK(created_at, 1) = WEEK(CURDATE(), 1)
        GROUP BY YEAR(created_at), WEEK(created_at, 1)
      ) p ON YEAR(fb.inv_date) = p.year AND WEEK(fb.inv_date, 1) = p.week
      WHERE YEAR(fb.inv_date) = YEAR(CURDATE()) 
        AND WEEK(fb.inv_date, 1) = WEEK(CURDATE(), 1)
      GROUP BY YEAR(fb.inv_date), WEEK(fb.inv_date, 1)
    `;
    const [results] = await db.query(query);
    
    // If no data for current week, return zero values
    if (results.length === 0) {
      const currentDate = new Date();
      const startOfWeek = new Date(currentDate.setDate(currentDate.getDate() - currentDate.getDay() + 1));
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      
      return res.json([{
        year: new Date().getFullYear(),
        week: Math.ceil((new Date().getDate() - new Date().getDay() + 1) / 7),
        week_start: startOfWeek.toISOString().split('T')[0],
        week_end: endOfWeek.toISOString().split('T')[0],
        total_sales: 0,
        bill_count: 0,
        total_purchase: 0,
        purchase_count: 0,
        profit: 0
      }]);
    }
    
    res.json(results);
  } catch (err) {
    console.error("Error fetching weekly summary data:", err);
    res.status(500).json({ error: "Failed to fetch weekly summary data", details: err.message });
  }
};

// GET MONTHLY SUMMARY DATA (Current Month Only)
const getMonthlySummary = async (req, res) => {
  try {
    const query = `
      SELECT 
        YEAR(fb.inv_date) AS year, 
        MONTH(fb.inv_date) AS month,
        MIN(fb.inv_date) AS month_start, 
        MAX(fb.inv_date) AS month_end,
        SUM(fb.grand_total) AS total_sales,
        COUNT(fb.id) AS bill_count,
        COALESCE(p.total_purchase, 0) AS total_purchase,
        COALESCE(p.purchase_count, 0) AS purchase_count,
        (SUM(fb.grand_total) - COALESCE(p.total_purchase, 0)) AS profit
      FROM final_bill fb
      LEFT JOIN (
        SELECT 
          YEAR(created_at) AS year, 
          MONTH(created_at) AS month,
          SUM(netAmount) AS total_purchase,
          COUNT(*) AS purchase_count
        FROM inventory
        WHERE YEAR(created_at) = YEAR(CURDATE()) 
          AND MONTH(created_at) = MONTH(CURDATE())
        GROUP BY YEAR(created_at), MONTH(created_at)
      ) p ON YEAR(fb.inv_date) = p.year AND MONTH(fb.inv_date) = p.month
      WHERE YEAR(fb.inv_date) = YEAR(CURDATE()) 
        AND MONTH(fb.inv_date) = MONTH(CURDATE())
      GROUP BY YEAR(fb.inv_date), MONTH(fb.inv_date)
    `;
    const [results] = await db.query(query);
    
    // If no data for current month, return zero values
    if (results.length === 0) {
      const currentDate = new Date();
      const startOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
      const endOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
      
      return res.json([{
        year: currentDate.getFullYear(),
        month: currentDate.getMonth() + 1,
        month_start: startOfMonth.toISOString().split('T')[0],
        month_end: endOfMonth.toISOString().split('T')[0],
        total_sales: 0,
        bill_count: 0,
        total_purchase: 0,
        purchase_count: 0,
        profit: 0
      }]);
    }
    
    res.json(results);
  } catch (err) {
    console.error("Error fetching monthly summary data:", err);
    res.status(500).json({ error: "Failed to fetch monthly summary data", details: err.message });
  }
};

module.exports = {
  getSales,
  getPurchase,
  getSummary,
  todaysalepurchase,
  getLowStockAlerts,
  getTopProducts,
  getWeeklySales,
  getMonthlySales,
  getWeeklyPurchase,
  getMonthlyPurchase,
  getWeeklySummary,
  getMonthlySummary
};