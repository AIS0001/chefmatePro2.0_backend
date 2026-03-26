/**
 * Test script for printer auto-detection
 * Run: node test-printer-detection.js
 */

const axios = require('axios');

const BASE_URL = 'http://127.0.0.1:4402/api/printer';

async function testPrinterDetection() {
  console.log('🧪 Testing Printer Auto-Detection\n');
  console.log('=====================================\n');

  try {
    // Setup: Create test printers
    console.log('📝 Setup: Creating test printers...\n');

    const kitchenPrinter = {
      terminal_id: 'KITCHEN-TEST-' + Date.now(),
      mac_address: '00:11:22:33:44:55',
      location: 'kitchen',
      printer_ip: '192.168.1.100',
      printer_port: 9100,
      printer_name: 'Kitchen Test Printer'
    };

    const cashierPrinter = {
      terminal_id: 'CASHIER-TEST-' + Date.now(),
      mac_address: '00:11:22:33:44:66',
      location: 'cashier',
      printer_ip: '192.168.1.101',
      printer_port: 9100,
      printer_name: 'Cashier Test Printer'
    };

    // Save printers
    const [kitchenRes, cashierRes] = await Promise.all([
      axios.post(`${BASE_URL}/config`, kitchenPrinter).catch(e => ({ data: { success: false, error: e.message } })),
      axios.post(`${BASE_URL}/config`, cashierPrinter).catch(e => ({ data: { success: false, error: e.message } }))
    ]);

    if (kitchenRes.data.success && cashierRes.data.success) {
      console.log('✅ Test printers created\n');
    } else {
      console.log('⚠️  Some printers may already exist\n');
    }

    // Test 1: Auto-detect (MAC-based lookup)
    console.log('---Test 1: Detect printer by MAC address---');
    console.log('GET /api/printer/agent/detect?mac_address=00:11:22:33:44:55\n');

    const test1 = await axios.get(`${BASE_URL}/agent/detect?mac_address=00:11:22:33:44:55`)
      .catch(err => err.response);

    if (test1.status === 200) {
      console.log('✅ Success');
      console.log('Response:', JSON.stringify(test1.data, null, 2));
    } else {
      console.log('❌ Failed:', test1.data?.message);
    }
    console.log('');

    // Test 2: Get printer by location
    console.log('---Test 2: Get printer by location type (kitchen)---');
    console.log('GET /api/printer/agent/detect?type=kitchen\n');

    const test2 = await axios.get(`${BASE_URL}/agent/detect?type=kitchen`)
      .catch(err => err.response);

    if (test2.status === 200) {
      console.log('✅ Success');
      console.log('Response:', JSON.stringify(test2.data, null, 2));
    } else {
      console.log('❌ Failed:', test2.data?.message);
    }
    console.log('');

    // Test 3: Get printer by location (cashier)
    console.log('---Test 3: Get printer by location type (cashier)---');
    console.log('GET /api/printer/agent/detect?type=cashier\n');

    const test3 = await axios.get(`${BASE_URL}/agent/detect?type=cashier`)
      .catch(err => err.response);

    if (test3.status === 200) {
      console.log('✅ Success');
      console.log('Response:', JSON.stringify(test3.data, null, 2));
    } else {
      console.log('❌ Failed:', test3.data?.message);
    }
    console.log('');

    // Test 4: Invalid MAC
    console.log('---Test 4: Test invalid MAC address---');
    console.log('GET /api/printer/agent/detect?mac_address=invalid-mac\n');

    const test4 = await axios.get(`${BASE_URL}/agent/detect?mac_address=invalid-mac`)
      .catch(err => err.response);

    if (test4.status === 400) {
      console.log('✅ Correctly rejected invalid MAC');
      console.log('Response:', JSON.stringify(test4.data, null, 2));
    } else {
      console.log('❌ Should have rejected invalid MAC');
    }
    console.log('');

    // Test 5: Printer not found
    console.log('---Test 5: Non-existent MAC address---');
    console.log('GET /api/printer/agent/detect?mac_address=FF:FF:FF:FF:FF:FF\n');

    const test5 = await axios.get(`${BASE_URL}/agent/detect?mac_address=FF:FF:FF:FF:FF:FF`)
      .catch(err => err.response);

    if (test5.status === 404) {
      console.log('✅ Correctly returned not found');
      console.log('Response:', JSON.stringify(test5.data, null, 2));
    } else {
      console.log('⚠️  Unexpected status:', test5.status);
    }
    console.log('');

    // Cleanup
    console.log('🧹 Cleanup: Deleting test printers...\n');
    await Promise.all([
      axios.delete(`${BASE_URL}/config/${kitchenPrinter.terminal_id}`).catch(() => {}),
      axios.delete(`${BASE_URL}/config/${cashierPrinter.terminal_id}`).catch(() => {})
    ]);
    console.log('✅ Cleanup complete\n');

    console.log('✅ All tests completed!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
}

testPrinterDetection();
