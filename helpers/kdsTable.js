const { db } = require('../config/dbconnection');

let tableEnsured = false;

const ensureKdsOrdersTable = async () => {
  if (tableEnsured) return;

  await db.query(`
    CREATE TABLE IF NOT EXISTS kds_orders (
      id INT AUTO_INCREMENT PRIMARY KEY,
      shop_id INT NOT NULL,
      order_item_id INT NULL,
      source_table VARCHAR(64) NOT NULL DEFAULT 'order_items',
      order_id VARCHAR(100) NULL,
      table_number VARCHAR(100) NULL,
      item_name VARCHAR(255) NOT NULL,
      item_group VARCHAR(255) NULL,
      quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
      total_price DECIMAL(12,2) NOT NULL DEFAULT 0,
      status VARCHAR(32) NOT NULL DEFAULT 'queue',
      setup_date DATE NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_kds_shop_date_status (shop_id, setup_date, status),
      INDEX idx_kds_order_item       (order_item_id),
      INDEX idx_kds_order_ref        (order_id),
      INDEX idx_kds_created_at       (shop_id, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  tableEnsured = true;
};

const normalizeKdsStatus = (rawStatus) => {
  const normalized = String(rawStatus || '').trim().toLowerCase();

  if (['processing', 'in_process', 'in-progress', 'in progress', 'preparing', 'cooking'].includes(normalized)) {
    return 'processing';
  }

  if (['completed', 'done', 'served', 'ready', '2'].includes(normalized)) {
    return 'completed';
  }

  return 'queue';
};

module.exports = {
  ensureKdsOrdersTable,
  normalizeKdsStatus
};
