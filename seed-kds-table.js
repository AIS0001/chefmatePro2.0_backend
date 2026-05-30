/**
 * seed-kds-table.js
 * Run once to create the kds_orders table and optionally seed sample rows.
 * Usage:  node seed-kds-table.js
 */
require('dotenv').config();
const { db } = require('./config/dbconnection');
const { ensureKdsOrdersTable } = require('./helpers/kdsTable');

const SEED_SAMPLE_ROWS = process.argv.includes('--seed');

const sampleRows = [
  { shop_id: 1, order_id: 'ORD-0001', table_number: 'T1', item_name: 'Butter Chicken', quantity: 2, total_price: 400, status: 'queue',      setup_date: new Date().toISOString().split('T')[0] },
  { shop_id: 1, order_id: 'ORD-0001', table_number: 'T1', item_name: 'Garlic Naan',    quantity: 4, total_price: 120, status: 'queue',      setup_date: new Date().toISOString().split('T')[0] },
  { shop_id: 1, order_id: 'ORD-0002', table_number: 'T2', item_name: 'Paneer Tikka',   quantity: 1, total_price: 220, status: 'processing', setup_date: new Date().toISOString().split('T')[0] },
  { shop_id: 1, order_id: 'ORD-0003', table_number: 'T3', item_name: 'Dal Makhani',    quantity: 2, total_price: 300, status: 'completed',  setup_date: new Date().toISOString().split('T')[0] },
];

(async () => {
  try {
    console.log('⏳  Ensuring kds_orders table exists...');
    await ensureKdsOrdersTable();
    console.log('✅  kds_orders table is ready.');

    if (SEED_SAMPLE_ROWS) {
      console.log('⏳  Seeding sample rows...');
      for (const row of sampleRows) {
        await db.query(
          `INSERT INTO kds_orders
            (shop_id, source_table, order_id, table_number, item_name, quantity, total_price, status, setup_date)
           VALUES (?, 'order_items', ?, ?, ?, ?, ?, ?, ?)`,
          [row.shop_id, row.order_id, row.table_number, row.item_name, row.quantity, row.total_price, row.status, row.setup_date]
        );
      }
      console.log(`✅  Inserted ${sampleRows.length} sample KDS rows for today (shop_id=1).`);
    }

    console.log('🎉  Done.');
    process.exit(0);
  } catch (err) {
    console.error('❌  Seed failed:', err.message);
    process.exit(1);
  }
})();
