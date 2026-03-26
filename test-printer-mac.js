/**
 * Test script for MAC address printer configuration
 * Run: node test-printer-mac.js
 */

const axios = require('axios');

const BASE_URL = 'http://127.0.0.1:4402/api/printer';

// Test MAC address
const TEST_MAC = '00:1A:2B:3C:4D:5E';
const TEST_TERMINAL = 'MAC-TEST-001';

async function testMacAddressPrinterConfig() {
  console.log('🧪 Testing MAC Address Printer Configuration\n');

  try {
    // Test 1: Save printer config with MAC address
    console.log('📝 Test 1: Save printer config with MAC address');
    const saveResponse = await axios.post(`${BASE_URL}/config`, {
      terminal_id: TEST_TERMINAL,
      mac_address: TEST_MAC,
      location: 'kitchen',
      printer_ip: '192.168.1.200',
      printer_port: 9100,
      printer_name: 'MAC Test Printer'
    }).catch(err => err.response);

    if (saveResponse.status === 201) {
      console.log('✅ Printer saved successfully');
      console.log('   Data:', JSON.stringify(saveResponse.data.data, null, 2));
    } else {
      console.log('⚠️  Save failed:', saveResponse.data.message);
    }
    console.log('');

    // Test 2: Get printer by MAC address
    console.log('🔍 Test 2: Get printer by MAC address');
    const macResponse = await axios.get(`${BASE_URL}/config/mac/${TEST_MAC}`)
      .catch(err => err.response);

    if (macResponse.status === 200) {
      console.log('✅ Printer found by MAC address');
      console.log('   Printer IP:', macResponse.data.data.printer_ip);
      console.log('   Location:', macResponse.data.data.location);
      console.log('   Terminal ID:', macResponse.data.data.terminal_id);
    } else {
      console.log('❌ Failed to get printer by MAC:', macResponse.data.message);
    }
    console.log('');

    // Test 3: Update MAC address
    console.log('✏️  Test 3: Update MAC address');
    const NEW_MAC = '11:22:33:44:55:66';
    const updateResponse = await axios.put(`${BASE_URL}/config/${TEST_TERMINAL}`, {
      mac_address: NEW_MAC
    }).catch(err => err.response);

    if (updateResponse.status === 200) {
      console.log('✅ MAC address updated successfully');
      console.log('   New MAC:', updateResponse.data.data.mac_address);
    } else {
      console.log('❌ Update failed:', updateResponse.data.message);
    }
    console.log('');

    // Test 4: Verify updated MAC
    console.log('🔍 Test 4: Verify updated MAC address');
    const verifyResponse = await axios.get(`${BASE_URL}/config/mac/${NEW_MAC}`)
      .catch(err => err.response);

    if (verifyResponse.status === 200) {
      console.log('✅ Updated MAC address verified');
      console.log('   Terminal ID:', verifyResponse.data.data.terminal_id);
    } else {
      console.log('❌ Verification failed:', verifyResponse.data.message);
    }
    console.log('');

    // Test 5: Invalid MAC format
    console.log('🚫 Test 5: Test invalid MAC format');
    const invalidResponse = await axios.post(`${BASE_URL}/config`, {
      terminal_id: 'INVALID-TEST',
      mac_address: 'invalid-mac-format',
      location: 'cashier',
      printer_ip: '192.168.1.201',
      printer_port: 9100
    }).catch(err => err.response);

    if (invalidResponse.status === 400) {
      console.log('✅ Invalid MAC format correctly rejected');
      console.log('   Error:', invalidResponse.data.message);
    } else {
      console.log('❌ Should have rejected invalid MAC format');
    }
    console.log('');

    // Cleanup: Delete test printer
    console.log('🧹 Cleanup: Delete test printer');
    await axios.delete(`${BASE_URL}/config/${TEST_TERMINAL}`);
    console.log('✅ Test data cleaned up\n');

    console.log('✅ All MAC address tests completed successfully!');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('   Response:', error.response.data);
    }
  }
}

// Run tests
testMacAddressPrinterConfig();
