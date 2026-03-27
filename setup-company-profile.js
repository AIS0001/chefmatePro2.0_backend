/**
 * COMPANY PROFILE SETUP SCRIPT
 * Seeds the company_profile table with initial company data
 * Run with: node setup-company-profile.js
 */

const { db } = require('./config/dbconnection');

const setupCompanyProfile = async () => {
  let connection;
  try {
    console.log('🌱 Starting Company Profile Setup...\n');

    // Get connection from pool
    connection = await db.getConnection();

    // Fetch first shop to use as default
    const [shops] = await connection.query('SELECT id FROM shops LIMIT 1');
    
    if (!shops || shops.length === 0) {
      console.error('❌ Error: No shops found in database!');
      console.log('   Please create a shop first before setting up company profile.');
      connection.release();
      process.exit(1);
      return;
    }

    const shopId = shops[0].id;
    console.log(`✅ Found default shop (ID: ${shopId})\n`);

    // Company profile data matching the schema
    const companyProfile = {
      shop_id: shopId,
      name: 'Banglore Cafe',
      tax_id: 'TAX123456789',
      phone_number: '+1-555-123-4567',
      email: 'info@chefmate.com',
      address: '123 Restaurant Street, Food District',
      website: 'https://www.chefmate.com',
      city: 'Bangkok',
      state: 'Bangkok Metropolitan',
      zip_code: '10110',
      country: 'Thailand',
      bank_name: 'Bangkok Bank',
      account_number: null,
      account_name: 'ChefMate Restaurant Solutions Co., Ltd.',
      routing_number: null,
      swift_code: null,
      payment_methods: 'Cash, Credit Card, Debit Card, Bank Transfer, Mobile Payment',
      terms_and_conditions: `Terms and Conditions:

1. Payment Terms:
   - Payment is due upon receipt of invoice
   - Late payments may incur additional charges
   - All prices are subject to applicable taxes

2. Return Policy:
   - Items must be returned within 30 days
   - Original receipt required for all returns
   - Perishable items cannot be returned

3. Warranty:
   - Equipment warranty as per manufacturer terms
   - Software support included for first year
   - Extended warranty available upon request

4. Liability:
   - Company liability limited to product value
   - Customer responsible for proper usage
   - Installation and training provided

For questions or support, contact us at support@chefmate.com`,
      is_active: 1
    };

    // Check if company profile already exists for this shop
    const [existingRecords] = await connection.query(
      'SELECT * FROM company_profile WHERE shop_id = ?',
      [shopId]
    );

    if (existingRecords && existingRecords.length > 0) {
      console.log('⚠️  Company profile already exists for this shop!');
      console.log('\n📋 Existing Company Profile:');
      console.log(`   ID: ${existingRecords[0].id}`);
      console.log(`   Shop ID: ${existingRecords[0].shop_id}`);
      console.log(`   Name: ${existingRecords[0].name}`);
      console.log(`   Tax ID: ${existingRecords[0].tax_id}`);
      console.log(`   Email: ${existingRecords[0].email}`);
      console.log(`   City: ${existingRecords[0].city}`);
      console.log(`   Status: ${existingRecords[0].is_active ? 'Active' : 'Inactive'}`);
      
      // Ask about updating
      console.log('\n💡 To update the company profile, use the admin panel or update the script data.');
      connection.release();
      process.exit(0);
      return;
    }

    // Insert new company profile
    const insertQuery = `
      INSERT INTO company_profile 
      (shop_id, name, tax_id, phone_number, email, address, website, city, state, zip_code, country, 
       bank_name, account_number, account_name, routing_number, swift_code, 
       payment_methods, terms_and_conditions, is_active, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    `;

    const [insertResult] = await connection.query(insertQuery, [
      companyProfile.shop_id,
      companyProfile.name,
      companyProfile.tax_id,
      companyProfile.phone_number,
      companyProfile.email,
      companyProfile.address,
      companyProfile.website,
      companyProfile.city,
      companyProfile.state,
      companyProfile.zip_code,
      companyProfile.country,
      companyProfile.bank_name,
      companyProfile.account_number,
      companyProfile.account_name,
      companyProfile.routing_number,
      companyProfile.swift_code,
      companyProfile.payment_methods,
      companyProfile.terms_and_conditions,
      companyProfile.is_active
    ]);

    console.log('✅ Company Profile Setup Successfully!\n');
    console.log('📋 Company Profile Details:');
    console.log(`   ID: ${insertResult.insertId}`);
    console.log(`   Shop ID: ${companyProfile.shop_id}`);
    console.log(`   Name: ${companyProfile.name}`);
    console.log(`   Tax ID: ${companyProfile.tax_id}`);
    console.log(`   Email: ${companyProfile.email}`);
    console.log(`   Phone: ${companyProfile.phone_number}`);
    console.log(`   Address: ${companyProfile.address}`);
    console.log(`   City: ${companyProfile.city}`);
    console.log(`   Country: ${companyProfile.country}`);
    console.log(`   Bank: ${companyProfile.bank_name}`);
    console.log(`   Website: ${companyProfile.website}`);
    console.log(`   Status: ${companyProfile.is_active ? 'Active' : 'Inactive'}`);
    
    console.log('\n📝 Next Steps:');
    console.log('   1. Access the Settings > Company Information section');
    console.log('   2. Upload company logo and QR code if needed');
    console.log('   3. Update bank account details and other information as required');
    
    connection.release();
    console.log('\n✨ Company Profile setup complete!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error during company profile setup:', err.message);
    if (connection) connection.release();
    process.exit(1);
  }
};

setupCompanyProfile();
