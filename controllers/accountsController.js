const { validationResult } = require('express-validator');
const db = require('../config/dbconnection1');

/**
 * ACCOUNTS ANALYTICS CONTROLLER
 * Handles all accounting and financial analytics for dashboard
 */

// ============================================
// SALES SUMMARY CARDS
// ============================================

/**
 * Get Today's Sales Summary
 * Returns total sales, orders count, average order value
 */
const getTodaySalesSummary = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const query = `
      SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(grand_total), 0) as total_sales,
        COALESCE(AVG(grand_total), 0) as avg_order_value,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'cash' THEN grand_total ELSE 0 END), 0) as cash_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'card' THEN grand_total ELSE 0 END), 0) as card_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'upi' THEN grand_total ELSE 0 END), 0) as upi_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'online' THEN grand_total ELSE 0 END), 0) as online_sales
      FROM final_bill 
      WHERE DATE(setup_date) = ? 
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `;
    
    const [results] = await db.query(query, [today]);
    const summary = results[0];
    
    res.json({
      success: true,
      data: {
        date: today,
        totalOrders: summary.total_orders,
        totalSales: parseFloat(summary.total_sales).toFixed(2),
        avgOrderValue: parseFloat(summary.avg_order_value).toFixed(2),
        paymentBreakdown: {
          cash: parseFloat(summary.cash_sales).toFixed(2),
          card: parseFloat(summary.card_sales).toFixed(2),
          upi: parseFloat(summary.upi_sales).toFixed(2),
          online: parseFloat(summary.online_sales).toFixed(2)
        }
      }
    });
  } catch (err) {
    console.error("Error fetching today's sales summary:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch today's sales summary", 
      details: err.message 
    });
  }
};

/**
 * Get Weekly Sales Summary
 */
const getWeeklySalesSummary = async (req, res) => {
  try {
    const query = `
      SELECT 
        DATE(setup_date) as sale_date,
        DAYNAME(setup_date) as day_name,
        COUNT(*) as total_orders,
        COALESCE(SUM(grand_total), 0) as total_sales
      FROM final_bill 
      WHERE setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
      GROUP BY DATE(setup_date), DAYNAME(setup_date)
      ORDER BY sale_date DESC
    `;
    
    const [results] = await db.query(query);
    
    const totalSales = results.reduce((sum, day) => sum + parseFloat(day.total_sales), 0);
    const totalOrders = results.reduce((sum, day) => sum + day.total_orders, 0);
    
    res.json({
      success: true,
      data: {
        period: 'Last 7 Days',
        totalSales: totalSales.toFixed(2),
        totalOrders: totalOrders,
        avgDailySales: (totalSales / 7).toFixed(2),
        dailyBreakdown: results.map(row => ({
          date: row.sale_date,
          day: row.day_name,
          orders: row.total_orders,
          sales: parseFloat(row.total_sales).toFixed(2)
        }))
      }
    });
  } catch (err) {
    console.error("Error fetching weekly sales summary:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch weekly sales summary", 
      details: err.message 
    });
  }
};

/**
 * Get Monthly Sales Summary
 */
const getMonthlySalesSummary = async (req, res) => {
  try {
    const query = `
      SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(grand_total), 0) as total_sales,
        COALESCE(AVG(grand_total), 0) as avg_order_value,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'cash' THEN grand_total ELSE 0 END), 0) as cash_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'card' THEN grand_total ELSE 0 END), 0) as card_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'upi' THEN grand_total ELSE 0 END), 0) as upi_sales,
        DAY(LAST_DAY(CURDATE())) as days_in_month,
        DAY(CURDATE()) as current_day
      FROM final_bill 
      WHERE YEAR(inv_date) = YEAR(CURDATE()) 
        AND MONTH(inv_date) = MONTH(CURDATE())
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `;
    
    const [results] = await db.query(query);
    const summary = results[0];
    
    res.json({
      success: true,
      data: {
        month: new Date().toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
        totalOrders: summary.total_orders,
        totalSales: parseFloat(summary.total_sales).toFixed(2),
        avgOrderValue: parseFloat(summary.avg_order_value).toFixed(2),
        avgDailySales: (parseFloat(summary.total_sales) / summary.current_day).toFixed(2),
        projectedMonthly: (parseFloat(summary.total_sales) / summary.current_day * summary.days_in_month).toFixed(2),
        paymentBreakdown: {
          cash: parseFloat(summary.cash_sales).toFixed(2),
          card: parseFloat(summary.card_sales).toFixed(2),
          upi: parseFloat(summary.upi_sales).toFixed(2)
        }
      }
    });
  } catch (err) {
    console.error("Error fetching monthly sales summary:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch monthly sales summary", 
      details: err.message 
    });
  }
};

/**
 * Get Custom Date Range Sales Summary
 */
const getDateRangeSalesSummary = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        error: "startDate and endDate are required"
      });
    }
    
    const query = `
      SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(grand_total), 0) as total_sales,
        COALESCE(AVG(grand_total), 0) as avg_order_value,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'cash' THEN grand_total ELSE 0 END), 0) as cash_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'card' THEN grand_total ELSE 0 END), 0) as card_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'upi' THEN grand_total ELSE 0 END), 0) as upi_sales,
        COALESCE(SUM(CASE WHEN LOWER(payment_mode) = 'online' THEN grand_total ELSE 0 END), 0) as online_sales,
        MIN(DATE(setup_date)) as first_sale_date,
        MAX(DATE(setup_date)) as last_sale_date
      FROM final_bill 
      WHERE DATE(setup_date) BETWEEN ? AND ?
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `;
    
    const [results] = await db.query(query, [startDate, endDate]);
    const summary = results[0];
    
    const daysDiff = Math.ceil((new Date(endDate) - new Date(startDate)) / (1000 * 60 * 60 * 24)) + 1;
    
    res.json({
      success: true,
      data: {
        startDate,
        endDate,
        totalDays: daysDiff,
        totalOrders: summary.total_orders,
        totalSales: parseFloat(summary.total_sales).toFixed(2),
        avgOrderValue: parseFloat(summary.avg_order_value).toFixed(2),
        avgDailySales: (parseFloat(summary.total_sales) / daysDiff).toFixed(2),
        paymentBreakdown: {
          cash: parseFloat(summary.cash_sales).toFixed(2),
          card: parseFloat(summary.card_sales).toFixed(2),
          upi: parseFloat(summary.upi_sales).toFixed(2),
          online: parseFloat(summary.online_sales).toFixed(2)
        }
      }
    });
  } catch (err) {
    console.error("Error fetching date range sales summary:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch date range sales summary", 
      details: err.message 
    });
  }
};

// ============================================
// REVENUE ANALYTICS
// ============================================

/**
 * Get Revenue Comparison (Today vs Yesterday vs Last Week vs Last Month)
 */
const getRevenueComparison = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    const query = `
      SELECT 
        'today' as period,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE DATE(setup_date) = ? AND LOWER(payment_mode) != 'entertainment' AND status != 2
      
      UNION ALL
      
      SELECT 
        'yesterday' as period,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE DATE(setup_date) = ? AND LOWER(payment_mode) != 'entertainment' AND status != 2
      
      UNION ALL
      
      SELECT 
        'last_7_days' as period,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) 
        AND LOWER(payment_mode) != 'entertainment' AND status != 2
      
      UNION ALL
      
      SELECT 
        'this_month' as period,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE YEAR(inv_date) = YEAR(CURDATE()) 
        AND MONTH(inv_date) = MONTH(CURDATE())
        AND LOWER(payment_mode) != 'entertainment' AND status != 2
      
      UNION ALL
      
      SELECT 
        'last_month' as period,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE YEAR(inv_date) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        AND MONTH(inv_date) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        AND LOWER(payment_mode) != 'entertainment' AND status != 2
    `;
    
    const [results] = await db.query(query, [today, yesterday]);
    
    const revenueData = {};
    results.forEach(row => {
      revenueData[row.period] = parseFloat(row.revenue).toFixed(2);
    });
    
    // Calculate growth percentages
    const todayGrowth = revenueData.yesterday > 0 
      ? (((revenueData.today - revenueData.yesterday) / revenueData.yesterday) * 100).toFixed(2)
      : 0;
      
    const monthGrowth = revenueData.last_month > 0
      ? (((revenueData.this_month - revenueData.last_month) / revenueData.last_month) * 100).toFixed(2)
      : 0;
    
    res.json({
      success: true,
      data: {
        today: {
          revenue: revenueData.today,
          growth: todayGrowth,
          comparison: 'vs Yesterday'
        },
        yesterday: {
          revenue: revenueData.yesterday
        },
        last7Days: {
          revenue: revenueData.last_7_days,
          avgDaily: (parseFloat(revenueData.last_7_days) / 7).toFixed(2)
        },
        thisMonth: {
          revenue: revenueData.this_month,
          growth: monthGrowth,
          comparison: 'vs Last Month'
        },
        lastMonth: {
          revenue: revenueData.last_month
        }
      }
    });
  } catch (err) {
    console.error("Error fetching revenue comparison:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch revenue comparison", 
      details: err.message 
    });
  }
};

/**
 * Get Hourly Sales Distribution (for today)
 */
const getHourlySalesDistribution = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const query = `
      SELECT 
        HOUR(setup_date) as hour,
        COUNT(*) as orders,
        COALESCE(SUM(grand_total), 0) as revenue
      FROM final_bill 
      WHERE DATE(setup_date) = ?
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
      GROUP BY HOUR(setup_date)
      ORDER BY hour
    `;
    
    const [results] = await db.query(query, [today]);
    
    // Create 24-hour array with zeros
    const hourlyData = Array.from({ length: 24 }, (_, i) => ({
      hour: i,
      timeLabel: `${i.toString().padStart(2, '0')}:00`,
      orders: 0,
      revenue: '0.00'
    }));
    
    // Fill in actual data
    results.forEach(row => {
      hourlyData[row.hour] = {
        hour: row.hour,
        timeLabel: `${row.hour.toString().padStart(2, '0')}:00`,
        orders: row.orders,
        revenue: parseFloat(row.revenue).toFixed(2)
      };
    });
    
    res.json({
      success: true,
      data: {
        date: today,
        hourlyBreakdown: hourlyData,
        peakHour: results.length > 0 
          ? results.reduce((max, row) => row.revenue > max.revenue ? row : max, results[0])
          : null
      }
    });
  } catch (err) {
    console.error("Error fetching hourly sales distribution:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch hourly sales distribution", 
      details: err.message 
    });
  }
};

// ============================================
// PAYMENT MODE ANALYTICS
// ============================================

/**
 * Get Payment Mode Distribution
 */
const getPaymentModeDistribution = async (req, res) => {
  try {
    const { period = 'today' } = req.query;
    
    let dateCondition = '';
    switch(period.toLowerCase()) {
      case 'today':
        dateCondition = 'DATE(setup_date) = CURDATE()';
        break;
      case 'week':
        dateCondition = 'setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
        break;
      case 'month':
        dateCondition = 'YEAR(inv_date) = YEAR(CURDATE()) AND MONTH(inv_date) = MONTH(CURDATE())';
        break;
      default:
        dateCondition = 'DATE(setup_date) = CURDATE()';
    }
    
    const query = `
      SELECT 
        LOWER(payment_mode) as payment_mode,
        COUNT(*) as transaction_count,
        COALESCE(SUM(grand_total), 0) as total_amount
      FROM final_bill 
      WHERE ${dateCondition}
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
      GROUP BY LOWER(payment_mode)
      ORDER BY total_amount DESC
    `;
    
    const [results] = await db.query(query);
    
    const totalRevenue = results.reduce((sum, row) => sum + parseFloat(row.total_amount), 0);
    
    const distribution = results.map(row => ({
      paymentMode: row.payment_mode,
      transactionCount: row.transaction_count,
      totalAmount: parseFloat(row.total_amount).toFixed(2),
      percentage: totalRevenue > 0 ? ((parseFloat(row.total_amount) / totalRevenue) * 100).toFixed(2) : 0
    }));
    
    res.json({
      success: true,
      data: {
        period,
        totalRevenue: totalRevenue.toFixed(2),
        distribution
      }
    });
  } catch (err) {
    console.error("Error fetching payment mode distribution:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch payment mode distribution", 
      details: err.message 
    });
  }
};

// ============================================
// TOP PERFORMERS
// ============================================

/**
 * Get Top Selling Items
 */
const getTopSellingItems = async (req, res) => {
  try {
    const { limit = 10, period = 'month' } = req.query;
    
    let dateCondition = '';
    switch(period.toLowerCase()) {
      case 'today':
        dateCondition = 'AND DATE(fb.setup_date) = CURDATE()';
        break;
      case 'week':
        dateCondition = 'AND fb.setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
        break;
      case 'month':
        dateCondition = 'AND YEAR(fb.inv_date) = YEAR(CURDATE()) AND MONTH(fb.inv_date) = MONTH(CURDATE())';
        break;
      default:
        dateCondition = 'AND YEAR(fb.inv_date) = YEAR(CURDATE()) AND MONTH(fb.inv_date) = MONTH(CURDATE())';
    }
    
    const query = `
      SELECT 
        i.item_name,
        i.category,
        SUM(oi.quantity) as total_quantity,
        COUNT(DISTINCT oi.bill_id) as order_count,
        COALESCE(SUM(oi.total_price), 0) as total_revenue,
        COALESCE(AVG(oi.price), 0) as avg_price
      FROM order_items oi
      INNER JOIN items i ON oi.item_id = i.id
      INNER JOIN final_bill fb ON oi.bill_id = fb.id
      WHERE fb.status != 2 
        AND LOWER(fb.payment_mode) != 'entertainment'
        ${dateCondition}
      GROUP BY i.id, i.item_name, i.category
      ORDER BY total_revenue DESC
      LIMIT ?
    `;
    
    const [results] = await db.query(query, [parseInt(limit)]);
    
    res.json({
      success: true,
      data: {
        period,
        items: results.map(row => ({
          itemName: row.item_name,
          category: row.category,
          quantitySold: row.total_quantity,
          orderCount: row.order_count,
          totalRevenue: parseFloat(row.total_revenue).toFixed(2),
          avgPrice: parseFloat(row.avg_price).toFixed(2)
        }))
      }
    });
  } catch (err) {
    console.error("Error fetching top selling items:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch top selling items", 
      details: err.message 
    });
  }
};

/**
 * Get Category-wise Sales Performance
 */
const getCategoryPerformance = async (req, res) => {
  try {
    const { period = 'month' } = req.query;
    
    let dateCondition = '';
    switch(period.toLowerCase()) {
      case 'today':
        dateCondition = 'AND DATE(fb.setup_date) = CURDATE()';
        break;
      case 'week':
        dateCondition = 'AND fb.setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
        break;
      case 'month':
        dateCondition = 'AND YEAR(fb.inv_date) = YEAR(CURDATE()) AND MONTH(fb.inv_date) = MONTH(CURDATE())';
        break;
      default:
        dateCondition = 'AND YEAR(fb.inv_date) = YEAR(CURDATE()) AND MONTH(fb.inv_date) = MONTH(CURDATE())';
    }
    
    const query = `
      SELECT 
        COALESCE(i.category, 'Uncategorized') as category,
        COUNT(DISTINCT oi.bill_id) as order_count,
        SUM(oi.quantity) as total_quantity,
        COALESCE(SUM(oi.total_price), 0) as total_revenue
      FROM order_items oi
      INNER JOIN items i ON oi.item_id = i.id
      INNER JOIN final_bill fb ON oi.bill_id = fb.id
      WHERE fb.status != 2 
        AND LOWER(fb.payment_mode) != 'entertainment'
        ${dateCondition}
      GROUP BY i.category
      ORDER BY total_revenue DESC
    `;
    
    const [results] = await db.query(query);
    
    const totalRevenue = results.reduce((sum, row) => sum + parseFloat(row.total_revenue), 0);
    
    res.json({
      success: true,
      data: {
        period,
        categories: results.map(row => ({
          category: row.category,
          orderCount: row.order_count,
          quantitySold: row.total_quantity,
          totalRevenue: parseFloat(row.total_revenue).toFixed(2),
          percentage: totalRevenue > 0 ? ((parseFloat(row.total_revenue) / totalRevenue) * 100).toFixed(2) : 0
        }))
      }
    });
  } catch (err) {
    console.error("Error fetching category performance:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch category performance", 
      details: err.message 
    });
  }
};

// ============================================
// PROFIT & LOSS INSIGHTS
// ============================================

/**
 * Get Basic Profit & Loss Summary
 */
const getProfitLossSummary = async (req, res) => {
  try {
    const { period = 'month' } = req.query;
    
    let dateCondition = '';
    switch(period.toLowerCase()) {
      case 'today':
        dateCondition = 'DATE(setup_date) = CURDATE()';
        break;
      case 'week':
        dateCondition = 'setup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
        break;
      case 'month':
        dateCondition = 'YEAR(inv_date) = YEAR(CURDATE()) AND MONTH(inv_date) = MONTH(CURDATE())';
        break;
      default:
        dateCondition = 'YEAR(inv_date) = YEAR(CURDATE()) AND MONTH(inv_date) = MONTH(CURDATE())';
    }
    
    // Get total revenue
    const revenueQuery = `
      SELECT COALESCE(SUM(grand_total), 0) as total_revenue
      FROM final_bill 
      WHERE ${dateCondition}
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `;
    
    // Get total purchases/expenses
    let purchaseCondition = '';
    switch(period.toLowerCase()) {
      case 'today':
        purchaseCondition = 'DATE(created_at) = CURDATE()';
        break;
      case 'week':
        purchaseCondition = 'created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
        break;
      case 'month':
        purchaseCondition = 'YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())';
        break;
      default:
        purchaseCondition = 'YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())';
    }
    
    const purchaseQuery = `
      SELECT COALESCE(SUM(netAmount), 0) as total_purchases
      FROM inventory 
      WHERE ${purchaseCondition}
    `;
    
    const [revenueResults] = await db.query(revenueQuery);
    const [purchaseResults] = await db.query(purchaseQuery);
    
    const revenue = parseFloat(revenueResults[0].total_revenue);
    const purchases = parseFloat(purchaseResults[0].total_purchases);
    const grossProfit = revenue - purchases;
    const profitMargin = revenue > 0 ? ((grossProfit / revenue) * 100).toFixed(2) : 0;
    
    res.json({
      success: true,
      data: {
        period,
        revenue: revenue.toFixed(2),
        purchases: purchases.toFixed(2),
        grossProfit: grossProfit.toFixed(2),
        profitMargin: profitMargin,
        status: grossProfit >= 0 ? 'profitable' : 'loss'
      }
    });
  } catch (err) {
    console.error("Error fetching profit & loss summary:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch profit & loss summary", 
      details: err.message 
    });
  }
};

// ============================================
// DASHBOARD OVERVIEW
// ============================================

/**
 * Get Complete Accounts Dashboard Overview
 * Combines key metrics for a comprehensive dashboard view
 */
const getAccountsDashboard = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    // Today's Sales
    const [todaySales] = await db.query(`
      SELECT 
        COALESCE(SUM(grand_total), 0) as total,
        COUNT(*) as orders
      FROM final_bill 
      WHERE DATE(setup_date) = ? 
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `, [today]);
    
    // Yesterday's Sales
    const [yesterdaySales] = await db.query(`
      SELECT COALESCE(SUM(grand_total), 0) as total
      FROM final_bill 
      WHERE DATE(setup_date) = ? 
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `, [yesterday]);
    
    // This Month Sales
    const [monthSales] = await db.query(`
      SELECT 
        COALESCE(SUM(grand_total), 0) as total,
        COUNT(*) as orders
      FROM final_bill 
      WHERE YEAR(inv_date) = YEAR(CURDATE()) 
        AND MONTH(inv_date) = MONTH(CURDATE())
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
    `);
    
    // This Month Purchases
    const [monthPurchases] = await db.query(`
      SELECT COALESCE(SUM(netAmount), 0) as total
      FROM inventory 
      WHERE YEAR(created_at) = YEAR(CURDATE()) 
        AND MONTH(created_at) = MONTH(CURDATE())
    `);
    
    // Payment Mode Breakdown (Today)
    const [paymentModes] = await db.query(`
      SELECT 
        LOWER(payment_mode) as mode,
        COALESCE(SUM(grand_total), 0) as amount,
        COUNT(*) as count
      FROM final_bill 
      WHERE DATE(setup_date) = ?
        AND LOWER(payment_mode) != 'entertainment' 
        AND status != 2
      GROUP BY LOWER(payment_mode)
    `, [today]);
    
    const todayGrowth = yesterdaySales[0].total > 0 
      ? (((todaySales[0].total - yesterdaySales[0].total) / yesterdaySales[0].total) * 100).toFixed(2)
      : 0;
    
    const monthProfit = parseFloat(monthSales[0].total) - parseFloat(monthPurchases[0].total);
    const profitMargin = monthSales[0].total > 0 
      ? ((monthProfit / parseFloat(monthSales[0].total)) * 100).toFixed(2)
      : 0;
    
    res.json({
      success: true,
      data: {
        todaySummary: {
          sales: parseFloat(todaySales[0].total).toFixed(2),
          orders: todaySales[0].orders,
          growth: todayGrowth
        },
        monthSummary: {
          sales: parseFloat(monthSales[0].total).toFixed(2),
          orders: monthSales[0].orders,
          purchases: parseFloat(monthPurchases[0].total).toFixed(2),
          grossProfit: monthProfit.toFixed(2),
          profitMargin: profitMargin
        },
        paymentBreakdown: paymentModes.map(mode => ({
          mode: mode.mode,
          amount: parseFloat(mode.amount).toFixed(2),
          count: mode.count
        }))
      }
    });
  } catch (err) {
    console.error("Error fetching accounts dashboard:", err);
    res.status(500).json({ 
      success: false,
      error: "Failed to fetch accounts dashboard", 
      details: err.message 
    });
  }
};

// ============================================
// EXPORTS
// ============================================

module.exports = {
  // Sales Summary Cards
  getTodaySalesSummary,
  getWeeklySalesSummary,
  getMonthlySalesSummary,
  getDateRangeSalesSummary,
  
  // Revenue Analytics
  getRevenueComparison,
  getHourlySalesDistribution,
  
  // Payment Analytics
  getPaymentModeDistribution,
  
  // Top Performers
  getTopSellingItems,
  getCategoryPerformance,
  
  // Profit & Loss
  getProfitLossSummary,
  
  // Dashboard Overview
  getAccountsDashboard
};
