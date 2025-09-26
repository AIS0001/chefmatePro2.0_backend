const db = require('./config/dbconnection1');

async function testDatabaseStructure() {
  console.log('🔍 Testing Database Structure for Analytics Dashboard...\n');

  try {
    // Test 1: Check final_bill table structure
    console.log('1. Testing final_bill table...');
    const [billColumns] = await db.query("DESCRIBE final_bill");
    console.log('   Final Bill Columns:', billColumns.map(col => col.Field).join(', '));
    
    const [billSample] = await db.query("SELECT * FROM final_bill LIMIT 1");
    console.log('   Sample record exists:', billSample.length > 0 ? '✅' : '❌');

    // Test 2: Check inventory table structure  
    console.log('\n2. Testing inventory table...');
    const [inventoryColumns] = await db.query("DESCRIBE inventory");
    console.log('   Inventory Columns:', inventoryColumns.map(col => col.Field).join(', '));
    
    const [inventorySample] = await db.query("SELECT * FROM inventory LIMIT 1");
    console.log('   Sample record exists:', inventorySample.length > 0 ? '✅' : '❌');

    // Test 3: Check order_items table structure
    console.log('\n3. Testing order_items table...');
    const [orderItemsColumns] = await db.query("DESCRIBE order_items");
    console.log('   Order Items Columns:', orderItemsColumns.map(col => col.Field).join(', '));
    
    const [orderItemsSample] = await db.query("SELECT * FROM order_items LIMIT 1");
    console.log('   Sample record exists:', orderItemsSample.length > 0 ? '✅' : '❌');

    // Test 4: Check items table (if exists)
    console.log('\n4. Testing items table...');
    try {
      const [itemsColumns] = await db.query("DESCRIBE items");
      console.log('   Items Columns:', itemsColumns.map(col => col.Field).join(', '));
      
      const [itemsSample] = await db.query("SELECT * FROM items LIMIT 1");
      console.log('   Sample record exists:', itemsSample.length > 0 ? '✅' : '❌');
    } catch (err) {
      console.log('   Items table not found or inaccessible ❌');
    }

    // Test 5: Check for supplier_id in inventory
    console.log('\n5. Testing supplier relationships...');
    const [supplierCheck] = await db.query("SELECT COUNT(*) as count, COUNT(DISTINCT supplier_id) as unique_suppliers FROM inventory WHERE supplier_id IS NOT NULL");
    console.log('   Records with supplier_id:', supplierCheck[0].count);
    console.log('   Unique suppliers:', supplierCheck[0].unique_suppliers);

    // Test 6: Test key relationships
    console.log('\n6. Testing table relationships...');
    try {
      const [relationshipTest] = await db.query(`
        SELECT COUNT(*) as count 
        FROM order_items oi 
        WHERE EXISTS (SELECT 1 FROM final_bill fb WHERE fb.id = oi.order_id)
      `);
      console.log('   Order items linked to bills:', relationshipTest[0].count, '✅');
    } catch (err) {
      console.log('   Order items relationship test failed ❌');
    }

    // Test 7: Check date ranges
    console.log('\n7. Testing date ranges...');
    try {
      const [dateRange] = await db.query(`
        SELECT 
          MIN(inv_date) as min_date, 
          MAX(inv_date) as max_date,
          COUNT(*) as total_records
        FROM final_bill
      `);
      console.log('   Bill date range:', dateRange[0].min_date, 'to', dateRange[0].max_date);
      console.log('   Total bills:', dateRange[0].total_records);
    } catch (err) {
      console.log('   Date range test failed ❌');
    }

    console.log('\n✅ Database structure test completed!');
    console.log('\n📝 Recommendations:');
    console.log('   - Ensure supplier_id is populated in inventory table for supplier analytics');
    console.log('   - Verify order_items.order_id links correctly to final_bill.id');
    console.log('   - Consider adding indexes on date columns for better performance');

  } catch (error) {
    console.error('❌ Database test failed:', error.message);
  } finally {
    process.exit(0);
  }
}

// Run the test
testDatabaseStructure();
