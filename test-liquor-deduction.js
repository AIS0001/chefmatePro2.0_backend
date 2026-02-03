/**
 * Test Script for Liquor Stock Deduction Fix
 * Tests the updated removeStock method for serving unit handling
 * 
 * Run: node test-liquor-deduction.js
 */

const { db } = require('./config/dbconnection');
const stockService = require('./services/stockService');

async function runTests() {
  try {
    console.log('🧪 Starting Liquor Stock Deduction Tests\n');

    const connection = await db.getConnection();

    // Test 1: Setup test data
    console.log('📋 Test 1: Setting up test product and units');
    
    // Create test product (if not exists)
    await connection.query(
      'DELETE FROM items WHERE iname = ?',
      ['Test Vodka']
    );
    
    const [productResult] = await connection.query(
      'INSERT INTO items (iname, description, category) VALUES (?, ?, ?)',
      ['Test Vodka', 'Test liquor product', 'Beverages']
    );
    
    const productId = productResult.insertId;
    console.log(`✅ Created test product: ID ${productId}\n`);

    // Delete old units for this product
    await connection.query('DELETE FROM product_units WHERE product_id = ?', [productId]);

    // Create base unit (Full Bottle)
    const [baseUnitResult] = await connection.query(
      'INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit, unit_type) VALUES (?, ?, ?, ?, ?)',
      [productId, 'Full Bottle', 750, 1, 'BASE']
    );
    
    const baseUnitId = baseUnitResult.insertId;
    console.log(`✅ Created base unit: Full Bottle (ID ${baseUnitId}, 750ml)\n`);

    // Create serving units
    const [unit30Result] = await connection.query(
      'INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit, unit_type) VALUES (?, ?, ?, ?, ?)',
      [productId, '30ml Peg', 30, 0, 'DERIVED']
    );
    const unit30Id = unit30Result.insertId;

    const [unit60Result] = await connection.query(
      'INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit, unit_type) VALUES (?, ?, ?, ?, ?)',
      [productId, '60ml Peg', 60, 0, 'DERIVED']
    );
    const unit60Id = unit60Result.insertId;

    const [unit90Result] = await connection.query(
      'INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit, unit_type) VALUES (?, ?, ?, ?, ?)',
      [productId, '90ml Peg', 90, 0, 'DERIVED']
    );
    const unit90Id = unit90Result.insertId;

    console.log(`✅ Created serving units:`);
    console.log(`   - 30ml Peg (ID ${unit30Id})`);
    console.log(`   - 60ml Peg (ID ${unit60Id})`);
    console.log(`   - 90ml Peg (ID ${unit90Id})\n`);

    connection.release();

    // Test 2: Add initial stock
    console.log('📋 Test 2: Adding initial stock (5 full bottles)');
    const addResult = await stockService.addStock(
      productId,
      baseUnitId,
      5,
      1,
      'PURCHASE',
      null,
      'Initial stock'
    );
    console.log(`✅ Stock added: ${JSON.stringify(addResult)}\n`);

    // Check stock before sale
    const stockBefore = await stockService.getStockLevel(productId);
    console.log('📊 Stock Before Sale:');
    stockBefore.forEach(stock => {
      console.log(`   ${stock.unit_name}: ${stock.current_quantity} units (${stock.available_quantity} available)`);
    });
    console.log('');

    // Test 3: Sell via 30ml peg (should deduct from full bottle)
    console.log('📋 Test 3: Selling 1 × 30ml peg');
    const saleResult = await stockService.removeStock(
      productId,
      unit30Id,  // 30ml peg unit
      1,         // 1 peg
      1,
      'SALE',
      null,
      'Customer order'
    );
    console.log(`✅ Sale processed:`);
    console.log(`   Requested: 1 × 30ml Peg`);
    console.log(`   Deducted from: ${saleResult.deductedFromUnit} (Full Bottle)`);
    console.log(`   Quantity deducted: ${saleResult.deductedQuantity} bottle(s)`);
    console.log(`   ML deducted: ${saleResult.deductedInMl}ml\n`);

    // Check stock after first sale
    const stockAfter1 = await stockService.getStockLevel(productId);
    console.log('📊 Stock After 1st Sale:');
    stockAfter1.forEach(stock => {
      console.log(`   ${stock.unit_name}: ${stock.current_quantity} units (${stock.available_quantity} available)`);
    });
    console.log('');

    // Test 4: Sell multiple servings
    console.log('📋 Test 4: Selling 2 × 60ml pegs');
    const sale2Result = await stockService.removeStock(
      productId,
      unit60Id,  // 60ml peg unit
      2,         // 2 pegs
      1,
      'SALE',
      null,
      'Customer order'
    );
    console.log(`✅ Sale processed:`);
    console.log(`   Requested: 2 × 60ml Pegs`);
    console.log(`   Deducted from: Full Bottle`);
    console.log(`   Quantity deducted: ${sale2Result.deductedQuantity} bottle(s)`);
    console.log(`   ML deducted: ${sale2Result.deductedInMl}ml\n`);

    // Check stock after second sale
    const stockAfter2 = await stockService.getStockLevel(productId);
    console.log('📊 Stock After 2nd Sale:');
    stockAfter2.forEach(stock => {
      console.log(`   ${stock.unit_name}: ${stock.current_quantity} units (${stock.available_quantity} available)`);
    });
    console.log('');

    // Test 5: Verify transaction log
    console.log('📋 Test 5: Checking transaction log');
    const conn = await db.getConnection();
    const [transactions] = await conn.query(
      'SELECT id, transaction_type, unit_id, quantity, quantity_in_ml, notes FROM stock_transactions WHERE product_id = ? ORDER BY id DESC LIMIT 5',
      [productId]
    );
    conn.release();

    console.log(`✅ Last 5 transactions:`);
    transactions.forEach(t => {
      console.log(`   Type: ${t.transaction_type} | Unit: ${t.unit_id} | Qty: ${t.quantity} | ML: ${t.quantity_in_ml} | Notes: ${t.notes}`);
    });
    console.log('');

    // Test 6: Test error handling
    console.log('📋 Test 6: Testing error handling (insufficient stock)');
    try {
      // Try to sell more than available
      await stockService.removeStock(
        productId,
        unit90Id,  // 90ml peg
        10,        // 10 pegs = 900ml total
        1,
        'SALE',
        null,
        'Should fail'
      );
      console.log('❌ ERROR: Should have thrown insufficient stock error');
    } catch (error) {
      console.log(`✅ Correctly caught error: ${error.message}\n`);
    }

    console.log('🎉 All tests completed successfully!\n');

    // Cleanup
    const cleanupConn = await db.getConnection();
    await cleanupConn.query('DELETE FROM product_units WHERE product_id = ?', [productId]);
    await cleanupConn.query('DELETE FROM stock_balance WHERE product_id = ?', [productId]);
    await cleanupConn.query('DELETE FROM stock_transactions WHERE product_id = ?', [productId]);
    await cleanupConn.query('DELETE FROM items WHERE id = ?', [productId]);
    cleanupConn.release();
    console.log('🧹 Test data cleaned up\n');

  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
    console.error(error);
  } finally {
    process.exit(0);
  }
}

// Run tests
runTests();
