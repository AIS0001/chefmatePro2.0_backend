const { db } = require('../config/dbconnection');
const { ensureKdsOrdersTable, normalizeKdsStatus } = require('../helpers/kdsTable');
const websocketManager = require('../helpers/websocketManager');

const STATUS_BUCKETS = {
  queue: new Set(['pending', 'queue', 'queued', 'new', '1']),
  processing: new Set(['processing', 'in_process', 'in-progress', 'in progress', 'preparing', 'cooking']),
  completed: new Set(['completed', 'done', 'served', 'ready', '2'])
};

const UPDATE_ALLOWED_STATUSES = new Set(['queue', 'processing', 'completed', 'pending']);

const normalizeStatus = (rawStatus) => String(rawStatus || '').trim().toLowerCase();

const resolveBucket = (status) => {
  const normalized = normalizeStatus(status);
  if (STATUS_BUCKETS.processing.has(normalized)) return 'processing';
  if (STATUS_BUCKETS.completed.has(normalized)) return 'completed';
  return 'queue';
};

const resolveShopId = (req) => {
  const candidate = req.query?.shop_id || req.user?.shop_id || req.shop_id;
  const parsed = Number.parseInt(candidate, 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : null;
};

const listOrders = async (req, res) => {
  try {
    await ensureKdsOrdersTable();

    const shopId = resolveShopId(req);
    if (!shopId) {
      return res.status(400).json({ success: false, message: 'shop_id is required' });
    }

    const requestedDate = String(req.query?.date || '').trim();
    const reportDate = requestedDate || new Date().toISOString().split('T')[0];

    const [rows] = await db.query(
      `SELECT id, order_item_id, source_table, order_id, table_number, item_name, item_group, quantity, total_price, status, setup_date
       FROM kds_orders
       WHERE shop_id = ?
         AND DATE(created_at) = ?
       ORDER BY id DESC`,
      [shopId, reportDate]
    );

    const queueOrders = [];
    const processingOrders = [];
    const completedOrders = [];

    for (const row of rows) {
      const order = {
        ...row,
        status_bucket: resolveBucket(row.status)
      };

      if (order.status_bucket === 'processing') {
        processingOrders.push(order);
      } else if (order.status_bucket === 'completed') {
        completedOrders.push(order);
      } else {
        queueOrders.push(order);
      }
    }

    return res.status(200).json({
      success: true,
      date: reportDate,
      data: {
        queueOrders,
        processingOrders,
        completedOrders,
        counts: {
          queue: queueOrders.length,
          processing: processingOrders.length,
          completed: completedOrders.length
        }
      }
    });
  } catch (error) {
    console.error('KDS listOrders error:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch KDS orders' });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    await ensureKdsOrdersTable();

    const shopId = resolveShopId(req);
    if (!shopId) {
      return res.status(400).json({ success: false, message: 'shop_id is required' });
    }

    const orderItemId = Number.parseInt(req.params.id, 10);
    if (!Number.isInteger(orderItemId) || orderItemId <= 0) {
      return res.status(400).json({ success: false, message: 'Valid order item id is required' });
    }

    const nextStatusRaw = normalizeStatus(req.body?.status);
    if (!UPDATE_ALLOWED_STATUSES.has(nextStatusRaw)) {
      return res.status(400).json({
        success: false,
        message: 'status must be one of: queue, processing, completed'
      });
    }

    const nextStatus = normalizeKdsStatus(nextStatusRaw);

    const [result] = await db.query(
      `UPDATE kds_orders
       SET status = ?
       WHERE id = ?
         AND shop_id = ?`,
      [nextStatus, orderItemId, shopId]
    );

    if (!result.affectedRows) {
      return res.status(404).json({ success: false, message: 'Order item not found' });
    }

    // Notify KDS dashboard via WebSocket
    try {
      websocketManager.sendToShop(shopId, { type: 'kds_update', shop_id: shopId });
    } catch (_) { /* non-fatal */ }

    return res.status(200).json({ success: true, message: 'Order status updated successfully' });
  } catch (error) {
    console.error('KDS updateOrderStatus error:', error);
    return res.status(500).json({ success: false, message: 'Failed to update order status' });
  }
};

module.exports = {
  listOrders,
  updateOrderStatus
};
