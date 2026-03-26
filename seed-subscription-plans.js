/**
 * SUBSCRIPTION PLANS SEED SCRIPT
 * Creates default subscription plans for the platform
 * Run with: node seed-subscription-plans.js
 */

const { db } = require('./config/dbconnection');

const seedSubscriptionPlans = async () => {
  let connection;
  try {
    console.log('🌱 Starting Subscription Plans Seed...\n');

    // Get connection from pool
    connection = await db.getConnection();

    // Default subscription plans
    const plans = [
      {
        name: 'Starter',
        description: 'Perfect for small restaurants and startups',
        price_per_month: 299,
        max_terminals: 2,
        max_users: 5,
        storage_quota_gb: 10,
        features: JSON.stringify([
          'POS System',
          'Inventory Management',
          'Basic Reports',
          'Up to 2 Terminals',
          'Up to 5 Users'
        ])
      },
      {
        name: 'Professional',
        description: 'Ideal for growing restaurants',
        price_per_month: 699,
        max_terminals: 5,
        max_users: 15,
        storage_quota_gb: 50,
        features: JSON.stringify([
          'All Starter Features',
          'Advanced Reports',
          'Customer Management',
          'Up to 5 Terminals',
          'Up to 15 Users',
          'API Access',
          'Priority Support'
        ])
      },
      {
        name: 'Enterprise',
        description: 'For large restaurant chains',
        price_per_month: 1999,
        max_terminals: 50,
        max_users: 50,
        storage_quota_gb: 500,
        features: JSON.stringify([
          'All Professional Features',
          'Multi-location Management',
          'Custom Integrations',
          'Unlimited Terminals',
          'Unlimited Users',
          'Dedicated Account Manager',
          '24/7 Premium Support'
        ])
      },
      {
        name: 'Free Trial',
        description: 'Free trial for new users (30 days)',
        price_per_month: 0,
        max_terminals: 3,
        max_users: 10,
        storage_quota_gb: 20,
        features: JSON.stringify([
          'Full POS Access',
          'Inventory Management',
          'Basic Reports',
          '30-Day Trial Period',
          'Community Support'
        ])
      }
    ];

    // Check if plans already exist
    const [existingPlans] = await connection.query(
      'SELECT COUNT(*) as count FROM subscription_plans'
    );

    if (existingPlans[0].count > 0) {
      console.log('⚠️  Subscription plans already exist!\n');
      console.log('📋 Existing Plans:');
      const [results] = await connection.query(
        'SELECT id, name, price_per_month, max_terminals, max_users FROM subscription_plans WHERE is_active = 1 ORDER BY price_per_month ASC'
      );
      results.forEach((plan, index) => {
        console.log(`   ${index + 1}. ${plan.name} - ฿${plan.price_per_month}/month (${plan.max_terminals} terminals, ${plan.max_users} users)`);
      });
      connection.release();
      process.exit(0);
      return;
    }

    // Insert subscription plans
    let insertedCount = 0;
    for (const plan of plans) {
      const insertQuery = `
        INSERT INTO subscription_plans 
        (name, description, price_per_month, max_terminals, max_users, storage_quota_gb, features, is_active, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())
      `;

      const [result] = await connection.query(insertQuery, [
        plan.name,
        plan.description,
        plan.price_per_month,
        plan.max_terminals,
        plan.max_users,
        plan.storage_quota_gb,
        plan.features
      ]);

      if (result.insertId) {
        insertedCount++;
        console.log(`✅ Created: ${plan.name} (ID: ${result.insertId})`);
      }
    }

    console.log(`\n🎉 Successfully created ${insertedCount} subscription plans!\n`);

    // Display all created plans
    const [allPlans] = await connection.query(
      'SELECT id, name, description, price_per_month, max_terminals, max_users, storage_quota_gb FROM subscription_plans WHERE is_active = 1 ORDER BY price_per_month ASC'
    );

    console.log('📋 Subscription Plans Summary:');
    console.log('═'.repeat(80));
    allPlans.forEach((plan, index) => {
      console.log(`\n${index + 1}. ${plan.name}`);
      console.log(`   ID: ${plan.id}`);
      console.log(`   Price: ฿${plan.price_per_month}/month`);
      console.log(`   Max Terminals: ${plan.max_terminals}`);
      console.log(`   Max Users: ${plan.max_users}`);
      console.log(`   Storage: ${plan.storage_quota_gb} GB`);
      console.log(`   Description: ${plan.description}`);
    });
    console.log('\n' + '═'.repeat(80));

    connection.release();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error in seed script:', error.message);
    if (connection) connection.release();
    process.exit(1);
  }
};

// Run seed
seedSubscriptionPlans();
