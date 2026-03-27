#!/usr/bin/env node

/**
 * Basic WebSocket Connection Test
 * Tests minimal WebSocket connection and message reception
 * 
 * Usage: node test-websocket-basic.js
 */

const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your_secret_key';
const WS_URL = 'ws://localhost:4402/ws';
const TEST_DURATION = 30000; // 30 seconds

// Generate test token
const token = jwt.sign(
  {
    id: 1,
    username: 'testuser',
    shop_id: 1,
    role: 'admin'
  },
  JWT_SECRET,
  { expiresIn: '24h' }
);

console.log('🧪 WebSocket Basic Connection Test\n');
console.log('Configuration:');
console.log(`- WebSocket URL: ${WS_URL}`);
console.log(`- Test Duration: ${TEST_DURATION / 1000} seconds`);
console.log(`- User ID: 1`);
console.log(`- Shop ID: 1\n`);

let testPassed = false;
let messagesReceived = [];

const ws = new WebSocket(`${WS_URL}?token=${token}`);

ws.on('open', () => {
  console.log('✅ Connected to WebSocket');
  console.log('Waiting for messages...\n');
});

ws.on('message', (data) => {
  try {
    const message = JSON.parse(data);
    messagesReceived.push(message.type);
    
    console.log(`📨 Message received (${message.type}):`);
    console.log(`   ${JSON.stringify(message).substring(0, 100)}...\n`);

    if (message.type === 'connection') {
      console.log('✅ Connection confirmation received\n');
      testPassed = true;
    }
  } catch (error) {
    console.error('❌ Error parsing message:', error.message);
  }
});

ws.on('error', (error) => {
  console.error('❌ WebSocket error:', error.message);
  process.exit(1);
});

ws.on('close', (code, reason) => {
  console.log(`\nWebSocket closed (Code: ${code})`);
  
  console.log('\n📊 Test Summary:');
  console.log(`- Messages received: ${messagesReceived.length}`);
  console.log(`- Message types: ${messagesReceived.join(', ') || 'none'}`);
  console.log(`- Test passed: ${testPassed ? '✅' : '❌'}`);
  
  process.exit(testPassed ? 0 : 1);
});

// Close after test duration
setTimeout(() => {
  console.log('\nTest duration reached, closing connection...');
  ws.close();
}, TEST_DURATION);

// Send ping to keep connection alive
const pingInterval = setInterval(() => {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ type: 'ping' }));
  }
}, 10000);

process.on('exit', () => {
  clearInterval(pingInterval);
});
