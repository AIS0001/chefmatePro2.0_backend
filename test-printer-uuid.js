/**
 * Test script for printer UUID functionality
 * Tests the new /printer/users-with-uuid endpoint
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:4402/api';

async function testUsersWithUuidEndpoint() {
  console.log('\n🧪 Testing /api/printer/users-with-uuid endpoint...\n');
  
  try {
    const response = await axios.get(`${BASE_URL}/printer/users-with-uuid`);
    
    console.log('✅ Response Status:', response.status);
    console.log('✅ Success:', response.data.success);
    console.log('✅ Count:', response.data.count);
    console.log('\n📋 Users with UUID:');
    console.table(response.data.data);
    
    if (response.data.count === 0) {
      console.log('\n⚠️  No users with UUID found.');
      console.log('💡 Users need to login at least once to generate UUID.');
    } else {
      console.log(`\n✅ Found ${response.data.count} registered machine(s)`);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    
    if (error.response?.status === 404) {
      console.log('\n⚠️  MACHINE NOT REGISTERED yet');
      console.log('💡 Please login to generate UUID first');
    }
  }
}

async function testCreatePrinterWithUuid() {
  console.log('\n\n🧪 Testing printer creation with UUID...\n');
  
  const testPrinter = {
    terminal_id: 'TEST-UUID-001',
    machine_uuid: 'd742be6d-6f13-4d7e-8a3a-908f17728bea', // Admin's UUID
    location: 'kitchen',
    printer_ip: '192.168.1.100',
    printer_port: 9100,
    printer_name: 'Test Printer with UUID'
  };
  
  try {
    const response = await axios.post(`${BASE_URL}/printer/config`, testPrinter);
    console.log('✅ Printer created successfully!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    if (error.response?.status === 409) {
      console.log('⚠️  Terminal ID already exists (expected for repeated tests)');
    } else {
      console.error('❌ Error:', error.response?.data || error.message);
    }
  }
}

async function testInvalidUuid() {
  console.log('\n\n🧪 Testing invalid UUID validation...\n');
  
  const testPrinter = {
    terminal_id: 'TEST-INVALID-UUID',
    machine_uuid: 'invalid-uuid-12345',
    location: 'cashier',
    printer_ip: '192.168.1.101',
    printer_port: 9100,
    printer_name: 'Invalid UUID Test'
  };
  
  try {
    const response = await axios.post(`${BASE_URL}/printer/config`, testPrinter);
    console.log('❌ Should have failed but succeeded:', response.data);
  } catch (error) {
    if (error.response?.data?.message === 'MACHINE NOT REGISTERED yet. UUID not found in users table.') {
      console.log('✅ Validation working correctly!');
      console.log('✅ Error message:', error.response.data.message);
    } else {
      console.error('❌ Unexpected error:', error.response?.data || error.message);
    }
  }
}

async function runTests() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('         PRINTER UUID FUNCTIONALITY TEST SUITE            ');
  console.log('═══════════════════════════════════════════════════════════');
  
  await testUsersWithUuidEndpoint();
  await testCreatePrinterWithUuid();
  await testInvalidUuid();
  
  console.log('\n═══════════════════════════════════════════════════════════');
  console.log('                    TESTS COMPLETED                        ');
  console.log('═══════════════════════════════════════════════════════════\n');
  
  process.exit(0);
}

runTests();
