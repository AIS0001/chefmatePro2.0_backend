/**
 * Test script to verify MAC address is being saved
 * Run: node test-printer-mac-save.js
 */

const axios = require('axios');

const BASE_URL = 'http://127.0.0.1:4402/api/printer';

async function testMacSaving() {
  console.log('🧪 Testing Printer MAC Address Saving\n');

  try {
    // Test 1: Save with MAC address
    console.log('📝 Test 1: Save printer with MAC address');
    const testData = {
      terminal_id: 'TEST-MAC-' + Date.now(),
      mac_address: '00:1A:2B:3C:4D:5E',
      location: 'kitchen',
      printer_ip: '192.168.1.150',
      printer_port: 9100,
      printer_name: 'Test Printer with MAC'
    };

    console.log('Sending data:', JSON.stringify(testData, null, 2));
    console.log('');

    const response = await axios.post(`${BASE_URL}/config`, testData)
      .catch(err => {
        console.error('❌ Request failed:', err.response?.data || err.message);
        throw err;
      });

    console.log('✅ Printer saved - Response:');
    console.log(JSON.stringify(response.data, null, 2));
    console.log('');

    const savedTerminalId = response.data.data.terminal_id;
    const savedMac = response.data.data.mac_address;

    if (savedMac === '00:1A:2B:3C:4D:5E') {
      console.log('✅ MAC address saved correctly in response');
    } else {
      console.log('❌ MAC address NOT saved - got:', savedMac);
    }
    console.log('');

    // Test 2: Retrieve and verify
    console.log('🔍 Test 2: Retrieve printer and verify MAC in database');
    const getResponse = await axios.get(`${BASE_URL}/config/${savedTerminalId}`);
    
    console.log('Retrieved data:');
    console.log(JSON.stringify(getResponse.data.data, null, 2));
    console.log('');

    if (getResponse.data.data.mac_address === '00:1A:2B:3C:4D:5E') {
      console.log('✅ MAC address is persisted in database!');
    } else {
      console.log('❌ MAC address NOT saved in database - got:', getResponse.data.data.mac_address);
    }
    console.log('');

    // Test 3: Test by MAC lookup
    console.log('🔍 Test 3: Lookup printer by MAC address');
    const macResponse = await axios.get(`${BASE_URL}/config/mac/00:1A:2B:3C:4D:5E`)
      .catch(err => {
        console.error('❌ MAC lookup failed:', err.response?.data);
        return null;
      });

    if (macResponse) {
      console.log('✅ Printer found by MAC address!');
      console.log(JSON.stringify(macResponse.data.data, null, 2));
    } else {
      console.log('❌ Printer NOT found by MAC address');
    }

    process.exit(0);
  } catch (error) {
    console.error('Test failed:', error.message);
    process.exit(1);
  }
}

testMacSaving();
