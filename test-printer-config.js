/**
 * Printer Configuration API - Test Suite
 * 
 * Tests all printer configuration endpoints
 * Usage: node test-printer-config.js
 */

const BASE_URL = process.env.BASE_URL || 'http://localhost:4402';
const API_PATH = '/api/printer';

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m',
  bold: '\x1b[1m'
};

let testsPassed = 0;
let testsFailed = 0;
const testResults = [];

// Helper function to log results
function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Helper function for API calls
async function apiCall(method, endpoint, body = null) {
  const url = `${BASE_URL}${API_PATH}${endpoint}`;
  const options = {
    method,
    headers: { 'Content-Type': 'application/json' }
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  try {
    const response = await fetch(url, options);
    const data = await response.json();
    return { status: response.status, data };
  } catch (error) {
    return { error: error.message };
  }
}

// Test helper
async function test(name, fn) {
  try {
    await fn();
    testsPassed++;
    testResults.push({ name, status: 'PASS' });
    log(`✅ ${name}`, 'green');
  } catch (error) {
    testsFailed++;
    testResults.push({ name, status: 'FAIL', error: error.message });
    log(`❌ ${name}: ${error.message}`, 'red');
  }
}

// Assertion helpers
function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertEquals(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(`${message} - Expected: ${expected}, Got: ${actual}`);
  }
}

// Test Suite
async function runTests() {
  log('\n' + '='.repeat(70), 'bold');
  log('🧪 PRINTER CONFIGURATION API TEST SUITE', 'blue');
  log('='.repeat(70) + '\n', 'bold');

  // ==========================================
  // Test 1: Save Printer Configuration
  // ==========================================
  await test('POST /config - Save new kitchen printer', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'KITCHEN-TEST-001',
      location: 'kitchen',
      printer_ip: '192.168.1.100',
      printer_port: 9100,
      printer_name: 'Test Kitchen Printer'
    });

    assert(response.status === 201, `Expected status 201, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(response.data.data.terminal_id === 'KITCHEN-TEST-001', 'Terminal ID mismatch');
    assert(response.data.data.location === 'kitchen', 'Location mismatch');
  });

  // ==========================================
  // Test 2: Save Cashier Printer
  // ==========================================
  await test('POST /config - Save new cashier printer', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'CASHIER-TEST-001',
      location: 'cashier',
      printer_ip: '192.168.1.101',
      printer_port: 9100,
      printer_name: 'Test Cashier Printer'
    });

    assert(response.status === 201, `Expected status 201, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(response.data.data.location === 'cashier', 'Location mismatch');
  });

  // ==========================================
  // Test 3: Duplicate Terminal ID (Should fail)
  // ==========================================
  await test('POST /config - Reject duplicate terminal_id', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'KITCHEN-TEST-001',
      location: 'kitchen',
      printer_ip: '192.168.1.102',
      printer_port: 9100,
      printer_name: 'Duplicate Test'
    });

    assert(response.status === 409, `Expected status 409, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for duplicate');
  });

  // ==========================================
  // Test 4: Missing Required Fields
  // ==========================================
  await test('POST /config - Reject missing required fields', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'KITCHEN-TEST-002'
      // Missing location and printer_ip
    });

    assert(response.status === 400, `Expected status 400, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for missing fields');
  });

  // ==========================================
  // Test 5: Invalid IP Address Format
  // ==========================================
  await test('POST /config - Reject invalid IP format', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'KITCHEN-TEST-003',
      location: 'kitchen',
      printer_ip: 'invalid-ip',
      printer_port: 9100,
      printer_name: 'Invalid IP Test'
    });

    assert(response.status === 400, `Expected status 400, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for invalid IP');
  });

  // ==========================================
  // Test 6: Invalid Location
  // ==========================================
  await test('POST /config - Reject invalid location', async () => {
    const response = await apiCall('POST', '/config', {
      terminal_id: 'KITCHEN-TEST-004',
      location: 'invalid-location',
      printer_ip: '192.168.1.100',
      printer_port: 9100
    });

    assert(response.status === 400, `Expected status 400, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for invalid location');
  });

  // ==========================================
  // Test 7: Get Printer Details
  // ==========================================
  await test('GET /config/:terminal_id - Get specific printer', async () => {
    const response = await apiCall('GET', '/config/KITCHEN-TEST-001');

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(response.data.data.terminal_id === 'KITCHEN-TEST-001', 'Terminal ID mismatch');
  });

  // ==========================================
  // Test 8: Get Non-existent Printer
  // ==========================================
  await test('GET /config/:terminal_id - Return 404 for non-existent printer', async () => {
    const response = await apiCall('GET', '/config/NON-EXISTENT-001');

    assert(response.status === 404, `Expected status 404, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for non-existent printer');
  });

  // ==========================================
  // Test 9: Get All Printer Configs
  // ==========================================
  await test('GET /config - Get all active printer configurations', async () => {
    const response = await apiCall('GET', '/config');

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(Array.isArray(response.data.data), 'Data should be an array');
    assert(response.data.count >= 2, 'Should have at least 2 printers from earlier tests');
  });

  // ==========================================
  // Test 10: Get Printers by Location - Kitchen
  // ==========================================
  await test('GET /location/:location - Get all kitchen printers', async () => {
    const response = await apiCall('GET', '/location/kitchen');

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(Array.isArray(response.data.data), 'Data should be an array');
    assert(response.data.count >= 1, 'Should have at least 1 kitchen printer');
    assert(response.data.data.every(p => p.location === 'kitchen'), 'All should be kitchen printers');
  });

  // ==========================================
  // Test 11: Get Printers by Location - Cashier
  // ==========================================
  await test('GET /location/:location - Get all cashier printers', async () => {
    const response = await apiCall('GET', '/location/cashier');

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(Array.isArray(response.data.data), 'Data should be an array');
    assert(response.data.data.every(p => p.location === 'cashier'), 'All should be cashier printers');
  });

  // ==========================================
  // Test 12: Invalid Location Filter
  // ==========================================
  await test('GET /location/:location - Reject invalid location filter', async () => {
    const response = await apiCall('GET', '/location/invalid');

    assert(response.status === 400, `Expected status 400, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for invalid location');
  });

  // ==========================================
  // Test 13: Update Printer Configuration
  // ==========================================
  await test('PUT /config/:terminal_id - Update printer IP', async () => {
    const response = await apiCall('PUT', '/config/KITCHEN-TEST-001', {
      printer_ip: '192.168.1.110'
    });

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');
    assert(response.data.data.printer_ip === '192.168.1.110', 'IP should be updated');
  });

  // ==========================================
  // Test 14: Update Printer Name
  // ==========================================
  await test('PUT /config/:terminal_id - Update printer name', async () => {
    const response = await apiCall('PUT', '/config/KITCHEN-TEST-001', {
      printer_name: 'Updated Kitchen Printer'
    });

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.data.printer_name === 'Updated Kitchen Printer', 'Name should be updated');
  });

  // ==========================================
  // Test 15: Update Printer Status
  // ==========================================
  await test('PUT /config/:terminal_id - Update printer status to inactive', async () => {
    const response = await apiCall('PUT', '/config/KITCHEN-TEST-001', {
      status: 'inactive'
    });

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.data.status === 'inactive', 'Status should be inactive');
  });

  // ==========================================
  // Test 16: Update Non-existent Printer
  // ==========================================
  await test('PUT /config/:terminal_id - Return 404 for non-existent printer', async () => {
    const response = await apiCall('PUT', '/config/NON-EXISTENT-001', {
      printer_ip: '192.168.1.200'
    });

    assert(response.status === 404, `Expected status 404, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for non-existent printer');
  });

  // ==========================================
  // Test 17: Delete Printer Configuration
  // ==========================================
  await test('DELETE /config/:terminal_id - Delete printer configuration', async () => {
    // First create a printer to delete
    await apiCall('POST', '/config', {
      terminal_id: 'DELETE-TEST-001',
      location: 'kitchen',
      printer_ip: '192.168.1.200',
      printer_port: 9100
    });

    // Then delete it
    const response = await apiCall('DELETE', '/config/DELETE-TEST-001');

    assert(response.status === 200, `Expected status 200, got ${response.status}`);
    assert(response.data.success === true, 'Response success should be true');

    // Verify it's deleted
    const getResponse = await apiCall('GET', '/config/DELETE-TEST-001');
    assert(getResponse.status === 404, 'Should not find deleted printer');
  });

  // ==========================================
  // Test 18: Delete Non-existent Printer
  // ==========================================
  await test('DELETE /config/:terminal_id - Return 404 for non-existent printer', async () => {
    const response = await apiCall('DELETE', '/config/NON-EXISTENT-001');

    assert(response.status === 404, `Expected status 404, got ${response.status}`);
    assert(response.data.success === false, 'Should fail for non-existent printer');
  });

  // ==========================================
  // Print Summary
  // ==========================================
  log('\n' + '='.repeat(70), 'bold');
  log('📊 TEST SUMMARY', 'blue');
  log('='.repeat(70), 'bold');

  log(`\n✅ Passed: ${testsPassed}`, 'green');
  log(`❌ Failed: ${testsFailed}`, testsFailed > 0 ? 'red' : 'green');
  log(`📈 Total:  ${testsPassed + testsFailed}\n`);

  if (testsFailed === 0) {
    log('🎉 ALL TESTS PASSED!', 'green');
  } else {
    log(`⚠️  ${testsFailed} test(s) failed`, 'yellow');
    log('\nFailed Tests:');
    testResults
      .filter(t => t.status === 'FAIL')
      .forEach(t => log(`  ❌ ${t.name}: ${t.error}`, 'red'));
  }

  log('\n' + '='.repeat(70) + '\n', 'bold');

  process.exit(testsFailed > 0 ? 1 : 0);
}

// Run the tests
if (!process.env.SKIP_FETCH_WARNING) {
  log('\n⚠️  Note: This test requires the node-fetch package or Node.js 18+', 'yellow');
  log('Make sure your server is running at: ' + BASE_URL + '\n', 'yellow');
}

runTests().catch(error => {
  log(`\n❌ Test execution error: ${error.message}`, 'red');
  process.exit(1);
});
