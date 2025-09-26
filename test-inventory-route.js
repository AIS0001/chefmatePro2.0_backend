const db = require('./config/dbconnection1');

// Test function for the inventory/joined route
async function testInventoryJoinedRoute() {
    console.log('🔍 Testing /inventory/joined route...\n');

    try {
        // Test 1: Check if tables exist and have required columns
        console.log('1. Checking database tables structure...');
        
        // Check inventory table
        try {
            const [inventoryColumns] = await db.query("DESCRIBE inventory");
            console.log('   ✅ Inventory table exists');
            console.log('   Columns:', inventoryColumns.map(col => col.Field).join(', '));
            
            const hasItemId = inventoryColumns.some(col => col.Field === 'item_id');
            console.log('   Has item_id column:', hasItemId ? '✅' : '❌');
            
        } catch (err) {
            console.log('   ❌ Inventory table issue:', err.message);
            return;
        }

        // Check items table
        try {
            const [itemsColumns] = await db.query("DESCRIBE items");
            console.log('   ✅ Items table exists');
            console.log('   Columns:', itemsColumns.map(col => col.Field).join(', '));
            
            const hasIname = itemsColumns.some(col => col.Field === 'iname');
            console.log('   Has iname column:', hasIname ? '✅' : '❌');
            
        } catch (err) {
            console.log('   ❌ Items table issue:', err.message);
            return;
        }

        // Test 2: Check JOIN relationship
        console.log('\n2. Testing JOIN relationship...');
        try {
            const testQuery = `
                SELECT 
                    inventory.*, 
                    items.iname AS item_name
                FROM 
                    inventory 
                JOIN 
                    items ON inventory.item_id = items.id
                LIMIT 5
            `;
            
            const [results] = await db.query(testQuery);
            console.log('   ✅ JOIN query successful');
            console.log('   Records found:', results.length);
            
            if (results.length > 0) {
                console.log('   Sample fields:', Object.keys(results[0]).join(', '));
            } else {
                console.log('   ⚠️  No joined records found - may need data or item_id relationships');
            }
            
        } catch (err) {
            console.log('   ❌ JOIN query failed:', err.message);
            return;
        }

        // Test 3: Check data relationships
        console.log('\n3. Checking data relationships...');
        try {
            const [relationshipCheck] = await db.query(`
                SELECT 
                    COUNT(*) as total_inventory,
                    COUNT(CASE WHEN item_id IS NOT NULL THEN 1 END) as with_item_id,
                    COUNT(CASE WHEN item_id IS NOT NULL AND EXISTS(SELECT 1 FROM items WHERE items.id = inventory.item_id) THEN 1 END) as valid_relationships
                FROM inventory
            `);
            
            const stats = relationshipCheck[0];
            console.log('   Total inventory records:', stats.total_inventory);
            console.log('   Records with item_id:', stats.with_item_id);
            console.log('   Valid item relationships:', stats.valid_relationships);
            
            if (stats.valid_relationships === 0) {
                console.log('   ⚠️  No valid item relationships found');
            }
            
        } catch (err) {
            console.log('   ❌ Relationship check failed:', err.message);
        }

        // Test 4: Feature protection check
        console.log('\n4. Checking feature protection...');
        try {
            const [featureCheck] = await db.query("SELECT * FROM features WHERE feature_code = 'inventory' LIMIT 1");
            if (featureCheck.length > 0) {
                console.log('   ✅ Inventory feature exists in features table');
            } else {
                console.log('   ⚠️  Inventory feature not found - feature protection may not work');
            }
        } catch (err) {
            console.log('   ❌ Feature check failed:', err.message);
        }

        console.log('\n✅ Route analysis complete!');
        
        // Test 5: Testing alternative LEFT JOIN
        console.log('\n5. Testing alternative LEFT JOIN query...');
        try {
            const [leftJoinResults] = await db.query(`
                SELECT 
                    inventory.*, 
                    items.iname AS item_name
                FROM 
                    inventory 
                LEFT JOIN 
                    items ON inventory.item_id = items.id
                ORDER BY inventory.id DESC
                LIMIT 5
            `);
            
            console.log('   Left JOIN results:', leftJoinResults.length, 'records');
            if (leftJoinResults.length > 0) {
                console.log('   Sample record:', {
                    id: leftJoinResults[0].id,
                    item_id: leftJoinResults[0].item_id,
                    item_name: leftJoinResults[0].item_name
                });
            }
            
        } catch (err) {
            console.log('   ❌ Alternative query failed:', err.message);
        }
        
        // Recommendations
        console.log('\n📝 Recommendations:');
        console.log('   1. Ensure inventory.item_id is properly populated');
        console.log('   2. Verify items.id matches inventory.item_id values');
        console.log('   3. Check if feature "inventory" exists in features table');
        console.log('   4. Test with proper JWT token and user permissions');
        console.log('   5. Consider using LEFT JOIN if some inventory items don\'t have item_id');

    } catch (error) {
        console.error('❌ Test failed:', error.message);
    } finally {
        process.exit(0);
    }
}

// Run tests
console.log('🚀 Starting inventory/joined route tests...\n');
testInventoryJoinedRoute();
