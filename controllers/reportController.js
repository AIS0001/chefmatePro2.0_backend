const { db } = require('../config/dbconnection');
const { requireShopId } = require('../helpers/shopScope');

const getColumnSet = async (tableName) => {
  const [columns] = await db.query(`SHOW COLUMNS FROM ${tableName}`);
  return new Set(columns.map((column) => String(column.Field || '').toLowerCase()));
};

const buildOrderItemsQueryParts = async () => {
  const orderItemsColumns = await getColumnSet('order_items');
  const finalBillColumns = await getColumnSet('final_bill');

  const hasItemGroup = orderItemsColumns.has('item_group');
  const hasTotalPrice = orderItemsColumns.has('total_price');
  const hasAmount = orderItemsColumns.has('amount');
  const hasPrice = orderItemsColumns.has('price');
  const hasQuantity = orderItemsColumns.has('quantity');
  const hasStatus = orderItemsColumns.has('status');
  const hasItemId = orderItemsColumns.has('item_id');
  const hasBillId = orderItemsColumns.has('bill_id');
  const hasOrderId = orderItemsColumns.has('order_id');
  const hasInvoiceNumber = orderItemsColumns.has('invoice_number');
  const hasFinalBillId = finalBillColumns.has('id');
  const hasFinalBillInvNumber = finalBillColumns.has('inv_number');
  const hasFinalBillInvoiceNumber = finalBillColumns.has('invoice_number');
  const hasSetupDate = finalBillColumns.has('setup_date');
  const hasInvDate = finalBillColumns.has('inv_date');

  const amountExpr = hasTotalPrice
    ? 'oi.total_price'
    : hasAmount
      ? 'oi.amount'
      : hasPrice && hasQuantity
        ? '(oi.price * oi.quantity)'
        : '0';

  const qtyExpr = hasQuantity ? 'oi.quantity' : '0';

  const groupExpr = hasItemGroup
    ? 'oi.item_group COLLATE utf8mb4_unicode_ci'
    : hasItemId
      ? "COALESCE(i.category COLLATE utf8mb4_unicode_ci, 'Other' COLLATE utf8mb4_unicode_ci)"
      : "'Other' COLLATE utf8mb4_unicode_ci";
  const itemsJoin = !hasItemGroup && hasItemId
    ? 'LEFT JOIN items i ON i.id = oi.item_id AND i.shop_id = fb.shop_id'
    : '';

  const itemStatusFilter = hasStatus ? 'AND oi.status = 0' : '';
  const billStatusFilter = finalBillColumns.has('status') ? 'AND fb.status != 2' : '';

  const joinConditions = [];
  if (hasBillId && hasFinalBillId) {
    joinConditions.push('oi.bill_id = fb.id');
  }
  if (hasOrderId && hasFinalBillId) {
    joinConditions.push('oi.order_id = fb.id');
  }
  if (hasInvoiceNumber && hasFinalBillInvNumber) {
    // Primary invoice-number matching using final_bill.inv_number.
    joinConditions.push("oi.invoice_number COLLATE utf8mb4_unicode_ci = fb.inv_number COLLATE utf8mb4_unicode_ci");
  }
  if (hasInvoiceNumber && hasFinalBillInvoiceNumber) {
    joinConditions.push("oi.invoice_number COLLATE utf8mb4_unicode_ci = fb.invoice_number COLLATE utf8mb4_unicode_ci");
  }
  if (hasInvoiceNumber && hasFinalBillId) {
    joinConditions.push('oi.invoice_number COLLATE utf8mb4_unicode_ci = CAST(fb.id AS CHAR) COLLATE utf8mb4_unicode_ci');
  }

  const billJoinCondition = joinConditions.length > 0 ? `(${joinConditions.join(' OR ')})` : '1 = 0';

  let billDateExpr = null;
  if (hasSetupDate) {
    billDateExpr = 'fb.setup_date';
  } else if (hasInvDate) {
    billDateExpr = 'fb.inv_date';
  }

  if (!billDateExpr) {
    throw new Error('Missing date column in final_bill: expected setup_date or inv_date');
  }

  return {
    amountExpr,
    qtyExpr,
    groupExpr,
    billDateExpr,
    billJoinCondition,
    itemsJoin,
    itemStatusFilter,
    billStatusFilter,
  };
};

/**
 * Entertainment Report
 * Returns date-wise totals of order_items grouped by item_group (Food/Bar/Shisha)
 * for bills where payment_mode = 'Entertainment'.
 *
 * GET /api/entertainment-report?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
 */
const getEntertainmentReport = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const { amountExpr, qtyExpr, groupExpr, billDateExpr, billJoinCondition, itemsJoin, itemStatusFilter, billStatusFilter } = await buildOrderItemsQueryParts();

    const { startDate, endDate } = req.query;

    const dateCondition =
      startDate && endDate
        ? `AND DATE(${billDateExpr}) BETWEEN ? AND ?`
        : '';
    const dateParams = startDate && endDate ? [startDate, endDate] : [];

    const query = `
      SELECT
        DATE(${billDateExpr}) AS date,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Food' COLLATE utf8mb4_unicode_ci   THEN ${amountExpr} ELSE 0 END), 0) AS Food,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Bar' COLLATE utf8mb4_unicode_ci    THEN ${amountExpr} ELSE 0 END), 0) AS Bar,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Shisha' COLLATE utf8mb4_unicode_ci THEN ${amountExpr} ELSE 0 END), 0) AS Shisha,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Food' COLLATE utf8mb4_unicode_ci   THEN ${qtyExpr} ELSE 0 END), 0) AS FoodQty,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Bar' COLLATE utf8mb4_unicode_ci    THEN ${qtyExpr} ELSE 0 END), 0) AS BarQty,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Shisha' COLLATE utf8mb4_unicode_ci THEN ${qtyExpr} ELSE 0 END), 0) AS ShishaQty
      FROM order_items oi
      INNER JOIN final_bill fb ON ${billJoinCondition}
      ${itemsJoin}
      WHERE fb.shop_id = ?
        ${itemStatusFilter}
        AND LOWER(fb.payment_mode) COLLATE utf8mb4_unicode_ci = 'entertainment' COLLATE utf8mb4_unicode_ci
        ${billStatusFilter}
        ${dateCondition}
      GROUP BY DATE(${billDateExpr})
      ORDER BY date ASC
    `;

    const params = [shopId, ...dateParams];
    const [rows] = await db.query(query, params);

    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('Error fetching entertainment report:', err);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch entertainment report',
      details: err.message,
      code: err.code || null,
      sqlMessage: err.sqlMessage || null,
    });
  }
};

/**
 * Group Wise Day-wise Report
 * Returns date-wise totals of order_items grouped by item_group (Food/Bar/Shisha)
 * for bills where payment_mode != 'Entertainment', including entertainment amount info per day.
 *
 * GET /api/groupwise-daywise-report?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
 */
const getGroupWiseDaywiseReport = async (req, res) => {
  try {
    const shopId = requireShopId(req, res);
    if (shopId === null) return;

    const { amountExpr, qtyExpr, groupExpr, billDateExpr, billJoinCondition, itemsJoin, itemStatusFilter, billStatusFilter } = await buildOrderItemsQueryParts();

    const { startDate, endDate } = req.query;

    const dateCondition =
      startDate && endDate
        ? `AND DATE(${billDateExpr}) BETWEEN ? AND ?`
        : '';
    const dateParams = startDate && endDate ? [startDate, endDate] : [];

    const mainQuery = `
      SELECT
        DATE(${billDateExpr}) AS date,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Food' COLLATE utf8mb4_unicode_ci   THEN ${amountExpr} ELSE 0 END), 0) AS Food,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Bar' COLLATE utf8mb4_unicode_ci    THEN ${amountExpr} ELSE 0 END), 0) AS Bar,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Shisha' COLLATE utf8mb4_unicode_ci THEN ${amountExpr} ELSE 0 END), 0) AS Shisha,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Food' COLLATE utf8mb4_unicode_ci   THEN ${qtyExpr} ELSE 0 END), 0) AS FoodQty,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Bar' COLLATE utf8mb4_unicode_ci    THEN ${qtyExpr} ELSE 0 END), 0) AS BarQty,
        COALESCE(SUM(CASE WHEN ${groupExpr} = 'Shisha' COLLATE utf8mb4_unicode_ci THEN ${qtyExpr} ELSE 0 END), 0) AS ShishaQty,
        COALESCE(SUM(${amountExpr}), 0) AS totalAmount
      FROM order_items oi
      INNER JOIN final_bill fb ON ${billJoinCondition}
      ${itemsJoin}
      WHERE fb.shop_id = ?
        ${itemStatusFilter}
        AND LOWER(fb.payment_mode) COLLATE utf8mb4_unicode_ci != 'entertainment' COLLATE utf8mb4_unicode_ci
        ${billStatusFilter}
        ${dateCondition}
      GROUP BY DATE(${billDateExpr})
      ORDER BY date ASC
    `;

    // Separately fetch entertainment amounts per day for "note" column
    const entertainmentQuery = `
      SELECT
        DATE(${billDateExpr}) AS date,
        COALESCE(SUM(${amountExpr}), 0) AS entertainmentAmount
      FROM order_items oi
      INNER JOIN final_bill fb ON ${billJoinCondition}
      ${itemsJoin}
      WHERE fb.shop_id = ?
        ${itemStatusFilter}
        AND LOWER(fb.payment_mode) COLLATE utf8mb4_unicode_ci = 'entertainment' COLLATE utf8mb4_unicode_ci
        ${billStatusFilter}
        ${dateCondition}
      GROUP BY DATE(${billDateExpr})
    `;

    const [mainRows] = await db.query(mainQuery, [shopId, ...dateParams]);
    const [entertainmentRows] = await db.query(entertainmentQuery, [shopId, ...dateParams]);

    // Build a map of entertainment amounts keyed by date string
    const entertainmentMap = new Map(
      entertainmentRows.map((r) => [String(r.date), parseFloat(r.entertainmentAmount)])
    );

    const data = mainRows.map((row) => ({
      ...row,
      entertainmentAmount: entertainmentMap.get(String(row.date)) || 0,
    }));

    return res.json({ success: true, data });
  } catch (err) {
    console.error('Error fetching group wise daywise report:', err);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch group wise daywise report',
      details: err.message,
      code: err.code || null,
      sqlMessage: err.sqlMessage || null,
    });
  }
};

module.exports = {
  getEntertainmentReport,
  getGroupWiseDaywiseReport,
};
