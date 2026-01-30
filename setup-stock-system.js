/**
 * Stock Management System - Setup & Test Script
 * This script helps set up the stock management system with example data
 */

const { db } = require('./config/dbconnection');

async function setupStockManagement() {
  try {
    console.log('🚀 Starting Stock Management System Setup...\n');

    // Create tables
    console.log('📋 Creating tables...');
    const schemaSQL = `
      -- product_units table
      CREATE TABLE IF NOT EXISTS \`product_units\` (
        \`id\` int(11) NOT NULL AUTO_INCREMENT,
        \`product_id\` int(11) NOT NULL,
        \`unit_name\` varchar(50) NOT NULL,
        \`unit_type\` varchar(20) NOT NULL,
        \`conversion_factor\` decimal(10,2) DEFAULT 1.00,
        \`is_base_unit\` tinyint(1) DEFAULT 0,
        \`ml_capacity\` int(11) DEFAULT NULL,
        \`purchase_price\` decimal(10,2) DEFAULT 0.00,
        \`selling_price\` decimal(10,2) DEFAULT 0.00,
        \`is_active\` tinyint(1) DEFAULT 1,
        \`created_at\` datetime DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (\`id\`),
        KEY \`idx_product_id\` (\`product_id\`),
        CONSTRAINT \`fk_product_units_item\` FOREIGN KEY (\`product_id\`) REFERENCES \`items\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

      -- stock_conversions table
      CREATE TABLE IF NOT EXISTS \`stock_conversions\` (
        \`id\` int(11) NOT NULL AUTO_INCREMENT,
        \`product_id\` int(11) NOT NULL,
        \`from_unit_id\` int(11) NOT NULL,
        \`to_unit_id\` int(11) NOT NULL,
        \`conversion_factor\` decimal(10,4) NOT NULL,
        \`is_active\` tinyint(1) DEFAULT 1,
        \`created_at\` datetime DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (\`id\`),
        KEY \`idx_product_conversion\` (\`product_id\`),
        UNIQUE KEY \`unique_conversion\` (\`product_id\`, \`from_unit_id\`, \`to_unit_id\`),
        CONSTRAINT \`fk_conversion_product\` FOREIGN KEY (\`product_id\`) REFERENCES \`items\` (\`id\`) ON DELETE CASCADE,
        CONSTRAINT \`fk_conversion_from_unit\` FOREIGN KEY (\`from_unit_id\`) REFERENCES \`product_units\` (\`id\`) ON DELETE CASCADE,
        CONSTRAINT \`fk_conversion_to_unit\` FOREIGN KEY (\`to_unit_id\`) REFERENCES \`product_units\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

      -- stock_transactions table
      CREATE TABLE IF NOT EXISTS \`stock_transactions\` (
        \`id\` int(11) NOT NULL AUTO_INCREMENT,
        \`product_id\` int(11) NOT NULL,
        \`transaction_type\` varchar(20) NOT NULL,
        \`unit_id\` int(11) NOT NULL,
        \`quantity\` decimal(10,4) NOT NULL,
        \`quantity_in_ml\` decimal(15,2) DEFAULT NULL,
        \`reference_type\` varchar(50) DEFAULT NULL,
        \`reference_id\` int(11) DEFAULT NULL,
        \`user_id\` int(11) DEFAULT NULL,
        \`notes\` text,
        \`transaction_date\` datetime DEFAULT CURRENT_TIMESTAMP,
        \`created_at\` datetime DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (\`id\`),
        KEY \`idx_product_id\` (\`product_id\`),
        KEY \`idx_transaction_type\` (\`transaction_type\`),
        KEY \`idx_transaction_date\` (\`transaction_date\`),
        CONSTRAINT \`fk_stock_trans_product\` FOREIGN KEY (\`product_id\`) REFERENCES \`items\` (\`id\`) ON DELETE CASCADE,
        CONSTRAINT \`fk_stock_trans_unit\` FOREIGN KEY (\`unit_id\`) REFERENCES \`product_units\` (\`id\`) ON DELETE RESTRICT
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

      -- stock_balance table
      CREATE TABLE IF NOT EXISTS \`stock_balance\` (
        \`id\` int(11) NOT NULL AUTO_INCREMENT,
        \`product_id\` int(11) NOT NULL,
        \`unit_id\` int(11) NOT NULL,
        \`current_quantity\` decimal(10,4) NOT NULL DEFAULT 0,
        \`reserved_quantity\` decimal(10,4) NOT NULL DEFAULT 0,
        \`available_quantity\` decimal(10,4) GENERATED ALWAYS AS (\`current_quantity\` - \`reserved_quantity\`) STORED,
        \`last_updated\` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (\`id\`),
        UNIQUE KEY \`unique_product_unit\` (\`product_id\`, \`unit_id\`),
        KEY \`idx_product_stock\` (\`product_id\`),
        CONSTRAINT \`fk_stock_balance_product\` FOREIGN KEY (\`product_id\`) REFERENCES \`items\` (\`id\`) ON DELETE CASCADE,
        CONSTRAINT \`fk_stock_balance_unit\` FOREIGN KEY (\`unit_id\`) REFERENCES \`product_units\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

      -- product_variants table
      CREATE TABLE IF NOT EXISTS \`product_variants\` (
        \`id\` int(11) NOT NULL AUTO_INCREMENT,
        \`product_id\` int(11) NOT NULL,
        \`variant_name\` varchar(100) NOT NULL,
        \`base_unit_id\` int(11) NOT NULL,
        \`quantity_in_base_unit\` decimal(10,4) NOT NULL,
        \`ml_quantity\` int(11) DEFAULT NULL,
        \`selling_price\` decimal(10,2) NOT NULL,
        \`cost_price\` decimal(10,2) DEFAULT 0.00,
        \`is_active\` tinyint(1) DEFAULT 1,
        \`created_at\` datetime DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (\`id\`),
        KEY \`idx_product_variant\` (\`product_id\`),
        CONSTRAINT \`fk_variant_product\` FOREIGN KEY (\`product_id\`) REFERENCES \`items\` (\`id\`) ON DELETE CASCADE,
        CONSTRAINT \`fk_variant_base_unit\` FOREIGN KEY (\`base_unit_id\`) REFERENCES \`product_units\` (\`id\`) ON DELETE RESTRICT
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    `;

    // Execute table creation
    const statements = schemaSQL.split(';').filter(stmt => stmt.trim());
    for (const stmt of statements) {
      await db.query(stmt + ';');
    }
    console.log('✅ Tables created successfully!\n');

    // Check if we have a whiskey product
    const [products] = await db.query('SELECT id FROM items WHERE iname LIKE "%whiskey%" OR iname LIKE "%Whiskey%" LIMIT 1', []);
    
    if (products.length === 0) {
      console.log('⚠️  No whiskey product found. Skipping example setup.');
      console.log('\n📝 To set up example, ensure product exists in database.\n');
      return;
    }

    const whiskeyId = products[0].id;
    console.log(`📦 Setting up example for Product ID: ${whiskeyId}\n`);

    // Setup Whiskey with Serving Sizes
    console.log('🥃 Creating Whiskey units...');

    // Create Bottle unit
    const [bottleResult] = await db.query(
      `INSERT INTO product_units (product_id, unit_name, unit_type, is_base_unit, ml_capacity, selling_price)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [whiskeyId, 'Bottle (750ML)', 'BASE', 1, 750, 3000]
    );
    const bottleUnitId = bottleResult.insertId;
    console.log(`  ✓ Bottle unit created (ID: ${bottleUnitId})`);

    // Create 30ML Peg unit
    const [peg30Result] = await db.query(
      `INSERT INTO product_units (product_id, unit_name, unit_type, ml_capacity, selling_price)
       VALUES (?, ?, ?, ?, ?)`,
      [whiskeyId, '30ML Peg', 'DERIVED', 30, 150]
    );
    const peg30UnitId = peg30Result.insertId;
    console.log(`  ✓ 30ML Peg unit created (ID: ${peg30UnitId})`);

    // Create 60ML Peg unit
    const [peg60Result] = await db.query(
      `INSERT INTO product_units (product_id, unit_name, unit_type, ml_capacity, selling_price)
       VALUES (?, ?, ?, ?, ?)`,
      [whiskeyId, '60ML Peg', 'DERIVED', 60, 300]
    );
    const peg60UnitId = peg60Result.insertId;
    console.log(`  ✓ 60ML Peg unit created (ID: ${peg60UnitId})\n`);

    // Create Conversions
    console.log('🔄 Creating conversion rules...');

    await db.query(
      `INSERT INTO stock_conversions (product_id, from_unit_id, to_unit_id, conversion_factor)
       VALUES (?, ?, ?, ?)`,
      [whiskeyId, bottleUnitId, peg30UnitId, 25]
    );
    console.log('  ✓ 1 Bottle = 25 × 30ML Pegs');

    await db.query(
      `INSERT INTO stock_conversions (product_id, from_unit_id, to_unit_id, conversion_factor)
       VALUES (?, ?, ?, ?)`,
      [whiskeyId, bottleUnitId, peg60UnitId, 12.5]
    );
    console.log('  ✓ 1 Bottle = 12.5 × 60ML Pegs\n');

    // Create Variants
    console.log('🎯 Creating serving size variants...');

    const [variant30Result] = await db.query(
      `INSERT INTO product_variants (product_id, variant_name, base_unit_id, quantity_in_base_unit, ml_quantity, selling_price, cost_price)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [whiskeyId, '30ML Peg', bottleUnitId, 0.04, 30, 150, 120]
    );
    console.log(`  ✓ 30ML Peg variant created (ID: ${variant30Result.insertId})`);

    const [variant60Result] = await db.query(
      `INSERT INTO product_variants (product_id, variant_name, base_unit_id, quantity_in_base_unit, ml_quantity, selling_price, cost_price)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [whiskeyId, '60ML Peg', bottleUnitId, 0.08, 60, 300, 240]
    );
    console.log(`  ✓ 60ML Peg variant created (ID: ${variant60Result.insertId})`);

    const [variantBottleResult] = await db.query(
      `INSERT INTO product_variants (product_id, variant_name, base_unit_id, quantity_in_base_unit, ml_quantity, selling_price, cost_price)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [whiskeyId, 'Full Bottle', bottleUnitId, 1, 750, 3000, 2400]
    );
    console.log(`  ✓ Full Bottle variant created (ID: ${variantBottleResult.insertId})\n`);

    // Add initial stock
    console.log('📥 Adding initial stock...');
    const [stockResult] = await db.query(
      `INSERT INTO stock_balance (product_id, unit_id, current_quantity)
       VALUES (?, ?, ?)`,
      [whiskeyId, bottleUnitId, 12]
    );
    console.log(`  ✓ Added 12 bottles to stock\n`);

    // Add transaction record
    await db.query(
      `INSERT INTO stock_transactions (product_id, transaction_type, unit_id, quantity, reference_type, notes)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [whiskeyId, 'ADD', bottleUnitId, 12, 'PURCHASE', 'Initial stock setup']
    );
    console.log('✅ Setup completed successfully!\n');

    console.log('📊 Setup Summary:');
    console.log('─'.repeat(50));
    console.log(`Product ID: ${whiskeyId}`);
    console.log(`Bottle Unit ID: ${bottleUnitId}`);
    console.log(`30ML Peg Unit ID: ${peg30UnitId}`);
    console.log(`60ML Peg Unit ID: ${peg60UnitId}`);
    console.log('─'.repeat(50));
    console.log('\n✨ Stock management system is ready!');
    console.log('\n📚 Test the APIs:');
    console.log(`\n1️⃣  Get Stock Level:`);
    console.log(`   GET /api/stock/level/${whiskeyId}`);
    console.log(`\n2️⃣  Get Variants:`);
    console.log(`   GET /api/stock/variants/${whiskeyId}`);
    console.log(`\n3️⃣  Sell 2 × 30ML Pegs:`);
    console.log(`   POST /api/stock/remove-variant`);
    console.log(`   { "productId": ${whiskeyId}, "variantId": ${variant30Result.insertId}, "quantity": 2 }`);
    console.log('\n');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  }
}

// Run setup
setupStockManagement().then(() => {
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});
