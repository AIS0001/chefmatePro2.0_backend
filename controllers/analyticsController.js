const { validationResult } = require('express-validator');
const db = require('../config/dbconnection1');
const { requireShopId } = require('../helpers/shopScope');

const tableColumnsCache = new Map();

const getTableColumns = async (tableName) => {
  if (tableColumnsCache.has(tableName)) {
    return tableColumnsCache.get(tableName);
  }

  const [columns] = await db.query(`
    SELECT COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = ?
  `, [tableName]);

  const columnSet = new Set(columns.map((column) => column.COLUMN_NAME));
  tableColumnsCache.set(tableName, columnSet);
  return columnSet;
};

const hasTableColumn = async (tableName, columnName) => {
  const columns = await getTableColumns(tableName);
  return columns.has(columnName);
};

const getOrderItemsGroupExpression = async () => {
  const hasItemGroup = await hasTableColumn('order_items', 'item_group');
  return hasItemGroup ? "NULLIF(TRIM(oi.item_group), '')" : 'NULL';
};

const getOrderItemsToFinalBillCondition = async () => {
  const joinConditions = [];

  if (await hasTableColumn('order_items', 'bill_id')) {
    joinConditions.push('oi.bill_id = fb.id');
  }

  if (await hasTableColumn('order_items', 'order_id')) {
    joinConditions.push('oi.order_id = fb.id');
  }

  if (await hasTableColumn('order_items', 'invoice_number')) {
    joinConditions.push("oi.invoice_number = COALESCE(NULLIF(fb.inv_number, ''), CAST(fb.id AS CHAR))");
  }

  return joinConditions.length > 0 ? `(${joinConditions.join(' OR ')})` : '1 = 0';
};

const getOrderItemsShopPredicate = async (alias = 'oi') => {
  const hasShopId = await hasTableColumn('order_items', 'shop_id');
  return hasShopId ? `${alias}.shop_id = ?` : null;
};

// GET ANALYTICS DASHBOARD DATA
const getAnalyticsDashboard = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const formatDate = (dateValue) => {
      const date = new Date(dateValue);
      return date.toISOString().split('T')[0];
    };

    const [latestCloseRows] = await db.query(
      `SELECT close_date FROM day_close_summary WHERE shop_id = ? ORDER BY close_date DESC LIMIT 1`,
      [shopId]
    );

    let today;
    let yesterday;

    if (latestCloseRows.length > 0 && latestCloseRows[0].close_date) {
      const latestCloseDate = new Date(latestCloseRows[0].close_date);
      const todayDate = new Date(latestCloseDate);
      todayDate.setDate(todayDate.getDate() + 1);

      today = formatDate(todayDate);
      yesterday = formatDate(latestCloseDate);
    } else {
      today = formatDate(new Date());
      yesterday = formatDate(new Date(Date.now() - 86400000));
    }
    
    // Today's and Yesterday's Sales
    const [todaySales] = await db.query(`SELECT COALESCE(SUM(grand_total), 0) AS val FROM final_bill WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(payment_mode) != 'entertainment' AND status != 2`, [shopId, today]);
    const [yesterdaySales] = await db.query(`SELECT COALESCE(SUM(grand_total), 0) AS val FROM final_bill WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(payment_mode) != 'entertainment' AND status != 2`, [shopId, yesterday]);
    const [todayDiscount] = await db.query(`SELECT COALESCE(SUM(discount_amount), 0) AS val FROM final_bill WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(payment_mode) != 'entertainment' AND status != 2`, [shopId, today]);
    
    // Monthly and Today's Purchases  
    const [monthlyPurchases] = await db.query(`
      SELECT COALESCE(SUM(inv.netAmount), 0) AS val
      FROM inventory inv
      INNER JOIN items i ON i.id = inv.item_id
      WHERE i.shop_id = ? AND YEAR(inv.created_at) = YEAR(CURDATE()) AND MONTH(inv.created_at) = MONTH(CURDATE())
    `, [shopId]);
    const [todayPurchases] = await db.query(`
      SELECT COALESCE(SUM(inv.netAmount), 0) AS val
      FROM inventory inv
      INNER JOIN items i ON i.id = inv.item_id
      WHERE i.shop_id = ? AND DATE(inv.created_at) = ?
    `, [shopId, today]);
    
    // Total Orders this month
    const [totalOrders] = await db.query(`SELECT COUNT(*) AS val FROM final_bill WHERE shop_id = ? AND YEAR(inv_date) = YEAR(CURDATE()) AND MONTH(inv_date) = MONTH(CURDATE())`, [shopId]);

    const [cancelledBills] = await db.query(`SELECT COUNT(*) AS val FROM final_bill WHERE shop_id = ? AND status = 2`, [shopId]);
    const [entertainmentTotal] = await db.query(`SELECT COALESCE(SUM(grand_total), 0) AS val FROM final_bill WHERE shop_id = ? AND LOWER(payment_mode) = 'entertainment'`, [shopId]);
    
    const [suppliersCount] = await db.query(`
      SELECT COUNT(DISTINCT inv.supplier_id) AS val
      FROM inventory inv
      INNER JOIN items i ON i.id = inv.item_id
      WHERE i.shop_id = ?
        AND inv.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        AND inv.supplier_id IS NOT NULL
    `, [shopId]);

    res.json({
      success: true,
      data: {
        todaySales: todaySales[0].val,
        yesterdaySales: yesterdaySales[0].val,
        monthlyPurchases: monthlyPurchases[0].val,
        todayPurchases: todayPurchases[0].val,
        totalOrders: totalOrders[0].val,
        totalSuppliers: suppliersCount[0].val,
        cancelledBills: cancelledBills[0].val,
        entertainmentTotal: entertainmentTotal[0].val,
        todayDiscount: todayDiscount[0].val
      }
    });
  } catch (err) {
    console.error("Error fetching analytics dashboard data:", err);
    res.status(500).json({ error: "Failed to fetch analytics dashboard data", details: err.message });
  }
};

// GET MONTHLY SALES VS PURCHASES DATA
const getMonthlySalesVsPurchases = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const query = `
      SELECT 
        MONTHNAME(DATE_FORMAT(CURDATE() - INTERVAL n MONTH, '%Y-%m-01')) as month,
        COALESCE(sales.total_sales, 0) as sales,
        COALESCE(purchases.total_purchases, 0) as purchases
      FROM (
        SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11
      ) as months
      LEFT JOIN (
        SELECT 
          DATE_FORMAT(inv_date, '%Y-%m-01') as month_date,
          SUM(grand_total) as total_sales
        FROM final_bill
        WHERE shop_id = ? AND inv_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        GROUP BY YEAR(inv_date), MONTH(inv_date)
      ) as sales ON DATE_FORMAT(CURDATE() - INTERVAL months.n MONTH, '%Y-%m-01') = sales.month_date
      LEFT JOIN (
        SELECT 
          DATE_FORMAT(inv.created_at, '%Y-%m-01') as month_date,
          SUM(inv.netAmount) as total_purchases
        FROM inventory inv
        INNER JOIN items i ON i.id = inv.item_id
        WHERE i.shop_id = ? AND inv.created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        GROUP BY YEAR(inv.created_at), MONTH(inv.created_at)
      ) as purchases ON DATE_FORMAT(CURDATE() - INTERVAL months.n MONTH, '%Y-%m-01') = purchases.month_date
      ORDER BY months.n DESC
      LIMIT 12
    `;
    
    const [results] = await db.query(query, [shopId, shopId]);
    res.json({ success: true, data: results });
  } catch (err) {
    console.error("Error fetching monthly sales vs purchases:", err);
    res.status(500).json({ error: "Failed to fetch monthly sales vs purchases", details: err.message });
  }
};

// GET SUPPLIERS OUTSTANDING PAYMENT DATA
const getSuppliersOutstanding = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    // First, let's check if suppliers table exists by trying a simple query
    const checkSuppliersQuery = `
      SELECT 
        CONCAT('Supplier ', i.supplier_id) as supplier_name,
        COUNT(i.id) as total_orders,
        COALESCE(SUM(i.netAmount), 0) as total_amount,
        4.5 as avg_rating
      FROM inventory i
      INNER JOIN items it ON it.id = i.item_id
      WHERE it.shop_id = ?
        AND i.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        AND i.supplier_id IS NOT NULL
      GROUP BY i.supplier_id
      HAVING total_orders > 0
      ORDER BY total_amount DESC
      LIMIT 8
    `;
    
    const [results] = await db.query(checkSuppliersQuery, [shopId]);
    
    res.json({ success: true, data: results });
  } catch (err) {
    console.error("Error fetching suppliers outstanding:", err);
    res.status(500).json({ error: "Failed to fetch suppliers outstanding", details: err.message });
  }
};

// GET ORDER STATUS DISTRIBUTION
const getOrderStatusDistribution = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const query = `
      SELECT 
        CASE 
          WHEN status = '1' OR status = 'Paid' THEN 'Completed'
          WHEN status = '0' OR status = 'Pending' THEN 'Processing'
          WHEN status = 'Pending' THEN 'Pending'
          WHEN status = 'Delivered' THEN 'Delivered'
          WHEN status = 'Cancelled' THEN 'Cancelled'
          WHEN status = 'Returned' THEN 'Returned'
          ELSE 'Processing'
        END as status_name,
        COUNT(*) as count,
        ROUND((COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM final_bill WHERE shop_id = ? AND inv_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)), 0)), 1) as percentage
      FROM final_bill 
      WHERE shop_id = ? AND inv_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY 
        CASE 
          WHEN status = '1' OR status = 'Paid' THEN 'Completed'
          WHEN status = '0' OR status = 'Pending' THEN 'Processing'
          WHEN status = 'Pending' THEN 'Pending'
          WHEN status = 'Delivered' THEN 'Delivered'
          WHEN status = 'Cancelled' THEN 'Cancelled'
          WHEN status = 'Returned' THEN 'Returned'
          ELSE 'Processing'
        END
      ORDER BY count DESC
    `;
    
    const [results] = await db.query(query, [shopId, shopId]);
    
    // Define colors for each status
    const statusColors = {
      'Completed': '#27ae60',
      'Processing': '#f39c12',
      'Pending': '#e74c3c',
      'Delivered': '#3498db',
      'Cancelled': '#95a5a6',
      'Returned': '#e67e22'
    };
    
    const formattedResults = results.map(row => ({
      status: row.status_name,
      value: row.percentage,
      count: row.count,
      color: statusColors[row.status_name] || '#95a5a6'
    }));
    
    res.json({ success: true, data: formattedResults });
  } catch (err) {
    console.error("Error fetching order status distribution:", err);
    res.status(500).json({ error: "Failed to fetch order status distribution", details: err.message });
  }
};

// GET TOP SELLING PRODUCTS
const getTopSellingProducts = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const billJoinCondition = await getOrderItemsToFinalBillCondition();
    const orderItemsShopPredicate = await getOrderItemsShopPredicate('oi');

    const itemNameExpression = "COALESCE(NULLIF(TRIM(oi.item_name), ''), 'Unknown Item')";

    const whereConditions = [];
    const queryParams = [];

    if (orderItemsShopPredicate) {
      whereConditions.push(orderItemsShopPredicate);
      queryParams.push(shopId);
    }

    whereConditions.push(`EXISTS (
          SELECT 1
          FROM final_bill fb
          WHERE fb.shop_id = ?
            AND fb.inv_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            AND fb.status != 2
            AND ${billJoinCondition}
        )`);
    queryParams.push(shopId);

    const query = `
      SELECT 
        ${itemNameExpression} as name,
        SUM(COALESCE(oi.quantity, 0)) as sales,
        ROUND(SUM(COALESCE(oi.total_price, 0)), 2) as revenue
      FROM order_items oi
      WHERE ${whereConditions.join('\n        AND ')}
      GROUP BY ${itemNameExpression}
      ORDER BY sales DESC, revenue DESC
      LIMIT 4
    `;
    
    const [results] = await db.query(query, queryParams);
    
    const colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12'];
    const formattedResults = results.map((product, index) => ({
      ...product,
      color: colors[index] || '#95a5a6'
    }));

    res.json({ success: true, data: formattedResults });
  } catch (err) {
    console.error("Error fetching top selling products:", err);
    res.status(500).json({ error: "Failed to fetch top selling products", details: err.message });
  }
};

// GET CATEGORY DISTRIBUTION
const getCategoryDistribution = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const orderItemsGroupExpression = await getOrderItemsGroupExpression();
    const billJoinCondition = await getOrderItemsToFinalBillCondition();
    const orderItemsShopPredicate = await getOrderItemsShopPredicate('oi');
    const hasOrderItemsItemName = await hasTableColumn('order_items', 'item_name');

    const itemNameExpression = hasOrderItemsItemName
      ? "NULLIF(TRIM(oi.item_name), '')"
      : 'NULL';

    const categorySourceExpression = `COALESCE(${orderItemsGroupExpression}, ${itemNameExpression}, '')`;

    const filteredWhereConditions = [];
    const totalsWhereConditions = [];
    const queryParams = [];

    if (orderItemsShopPredicate) {
      filteredWhereConditions.push(orderItemsShopPredicate);
      totalsWhereConditions.push(orderItemsShopPredicate);
      queryParams.push(shopId);
    }

    filteredWhereConditions.push(`EXISTS (
            SELECT 1
            FROM final_bill fb
            WHERE fb.shop_id = ?
              AND fb.inv_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
              AND fb.status != 2
              AND ${billJoinCondition}
          )`);
    queryParams.push(shopId);

    if (orderItemsShopPredicate) {
      queryParams.push(shopId);
    }

    totalsWhereConditions.push(`EXISTS (
            SELECT 1
            FROM final_bill fb
            WHERE fb.shop_id = ?
              AND fb.inv_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
              AND fb.status != 2
              AND ${billJoinCondition}
          )`);
    queryParams.push(shopId);

    const query = `
      SELECT 
        filtered_items.category_name,
        COUNT(*) as count,
        ROUND((COUNT(*) * 100.0 / NULLIF(totals.total_count, 0)), 1) as percentage
      FROM (
        SELECT
          CASE
            WHEN LOWER(${categorySourceExpression}) REGEXP 'bar|beverage|drink|liquor|cocktail|mocktail|juice|coffee|tea|smoothie' THEN 'Beverages'
            WHEN LOWER(${categorySourceExpression}) REGEXP 'food|starter|main|dessert|meal|snack|kitchen|burger|pizza|rice|pasta|bbq' THEN 'Food Items'
            ELSE 'Other Items'
          END as category_name
        FROM order_items oi
        WHERE ${filteredWhereConditions.join('\n          AND ')}
      ) filtered_items
      CROSS JOIN (
        SELECT COUNT(*) as total_count
        FROM order_items oi
        WHERE ${totalsWhereConditions.join('\n          AND ')}
      ) totals
      GROUP BY filtered_items.category_name, totals.total_count
      ORDER BY count DESC
    `;
    
    const [results] = await db.query(query, queryParams);
    
    const categoryColors = {
      'Food Items': '#e74c3c',
      'Beverages': '#3498db',
      'Other Items': '#9b59b6'
    };
    
    const formattedResults = results.map(row => ({
      name: row.category_name,
      value: row.percentage,
      count: row.count,
      color: categoryColors[row.category_name] || '#95a5a6'
    }));
    
    res.json({ success: true, data: formattedResults });
  } catch (err) {
    console.error("Error fetching category distribution:", err);
    res.status(500).json({ error: "Failed to fetch category distribution", details: err.message });
  }
};

// GET TOTAL SALES & EXPENSES
const getTotalSalesExpenses = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const [salesResult] = await db.query(`
      SELECT COALESCE(SUM(net_sales), 0) as total_sales 
      FROM day_close_summary 
      WHERE shop_id = ?
        AND YEAR(close_date) = YEAR(CURDATE()) 
        AND MONTH(close_date) = MONTH(CURDATE())
    `, [shopId]);
    
    const [expensesResult] = await db.query(`
      SELECT COALESCE(SUM(inv.netAmount), 0) as total_expenses 
      FROM inventory inv
      INNER JOIN items i ON i.id = inv.item_id
      WHERE i.shop_id = ? AND YEAR(inv.created_at) = YEAR(CURDATE()) AND MONTH(inv.created_at) = MONTH(CURDATE())
    `, [shopId]);
    
    const totalSales = salesResult[0].total_sales;
    const totalExpenses = expensesResult[0].total_expenses;
    const netProfit = totalSales - totalExpenses;
    
    res.json({
      success: true,
      data: {
        totalSales,
        totalExpenses,
        netProfit
      }
    });
  } catch (err) {
    console.error("Error fetching sales & expenses:", err);
    res.status(500).json({ error: "Failed to fetch sales & expenses", details: err.message });
  }
};

// GET DAILY SALES TREND (Last 6 days)
const getDailySalesTrend = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const query = `
      SELECT 
        DATE_FORMAT(inv_date, '%a') as day,
        DATE(inv_date) as date,
        COALESCE(SUM(grand_total), 0) as sales
      FROM final_bill
      WHERE shop_id = ? AND inv_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      GROUP BY DATE(inv_date)
      ORDER BY inv_date
    `;
    
    const [results] = await db.query(query, [shopId]);
    res.json({ success: true, data: results });
  } catch (err) {
    console.error("Error fetching daily sales trend:", err);
    res.status(500).json({ error: "Failed to fetch daily sales trend", details: err.message });
  }
};

// GET PURCHASE TRENDS (Last 6 days)
const getPurchaseTrends = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const query = `
      SELECT 
        DATE_FORMAT(inv.created_at, '%a') as day,
        DATE(inv.created_at) as date,
        COALESCE(SUM(inv.netAmount), 0) as purchases
      FROM inventory inv
      INNER JOIN items i ON i.id = inv.item_id
      WHERE i.shop_id = ? AND inv.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      GROUP BY DATE(inv.created_at)
      ORDER BY inv.created_at
    `;
    
    const [results] = await db.query(query, [shopId]);

    res.json({ success: true, data: results });
  } catch (err) {
    console.error("Error fetching purchase trends:", err);
    res.status(500).json({ error: "Failed to fetch purchase trends", details: err.message });
  }
};

// GET FOOD AND DRINKS/LIQUOR SALES
const getFoodAndDrinksSale = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    console.log("getFoodAndDrinksSale - Function called");



    const formatDate = (dateValue) => {
      const date = new Date(dateValue);
      return date.toISOString().split('T')[0];
    };

    const [latestCloseRows] = await db.query(
      `SELECT close_date FROM day_close_summary WHERE shop_id = ? ORDER BY close_date DESC LIMIT 1`,
      [shopId]
    );

    let today;

    if (latestCloseRows.length > 0 && latestCloseRows[0].close_date) {
      const latestCloseDate = new Date(latestCloseRows[0].close_date);
      const todayDate = new Date(latestCloseDate);
      todayDate.setDate(todayDate.getDate() + 1);
      today = formatDate(todayDate);
    } else {
      today = formatDate(new Date());
    }

    // Get Food Sales
    const [foodSales] = await db.query(`
      SELECT COALESCE(SUM(total_price), 0) as total_food_sale
      FROM order_items
      WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(COALESCE(item_group, '')) = 'food'
    `, [shopId, today]);

    // Get Drinks/Liquor Sales
    const [drinksSales] = await db.query(`
      SELECT COALESCE(SUM(total_price), 0) as total_drinks_sale
      FROM order_items
      WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(COALESCE(item_group, '')) = 'bar'
    `, [shopId, today]);

    // Get Shisha Sales
    const [shishaSales] = await db.query(`
      SELECT COALESCE(SUM(total_price), 0) as total_shisha_sale
      FROM order_items
      WHERE shop_id = ? AND DATE(setup_date) = ? AND LOWER(COALESCE(item_group, '')) = 'shisha'
    `, [shopId, today]);

    const totalFoodSale = Number(foodSales[0].total_food_sale || 0);
    const totalDrinksSale = Number(drinksSales[0].total_drinks_sale || 0);
    const totalShishaSale = Number(shishaSales[0].total_shisha_sale || 0);

    res.json({
      success: true,
      data: {
        sales_by_group: {
          food: { total_sale: totalFoodSale },
          bar: { total_sale: totalDrinksSale },
          shisha: { total_sale: totalShishaSale }
        },
        saleDate: today,
        total_all_sales: totalFoodSale + totalDrinksSale + totalShishaSale,
        totalFoodSale,
        totalDrinksSale,
        totalShishaSale
      }
    });
  } catch (err) {
    console.error("Error fetching food and drinks sales:", err);
    res.status(500).json({ error: "Failed to fetch food and drinks sales", details: err.message });
  }
};

module.exports = {
  getAnalyticsDashboard,
  getMonthlySalesVsPurchases,
  getSuppliersOutstanding,
  getOrderStatusDistribution,
  getTopSellingProducts,
  getCategoryDistribution,
  getTotalSalesExpenses,
  getDailySalesTrend,
  getPurchaseTrends,
  getFoodAndDrinksSale
};
