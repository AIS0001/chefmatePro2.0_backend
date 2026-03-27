# WebSocket Testing Guide

## Overview

This guide provides comprehensive testing procedures for the WebSocket real-time notification system.

## Prerequisites

1. Backend server running: `npm start`
2. Node.js installed
3. Valid JWT token for testing

## Test Scripts

### 1. Generate Test Token

**File**: `test-websocket-token.js`

```javascript
const jwt = require('jsonwebtoken');

// Generate test token
const testToken = jwt.sign(
  {
    id: 1,  // Test user ID
    username: 'testuser',
    shop_id: 1,  // Test shop ID
    role: 'admin'
  },
  process.env.JWT_SECRET || 'your_secret_key',
  { expiresIn: '24h' }
);

console.log('Test JWT Token:');
console.log(testToken);
console.log('\nUse this token for WebSocket connection:');
console.log(`ws://localhost:4402/ws?token=${testToken}`);
```

### 2. Basic WebSocket Connection Test

**File**: `test-websocket-basic.js`

```javascript
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

// Generate token
const token = jwt.sign(
  { id: 1, shop_id: 1 },
  process.env.JWT_SECRET || 'your_secret_key',
  { expiresIn: '24h' }
);

console.log('Connecting to WebSocket...');

const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);

ws.on('open', () => {
  console.log('✅ Connected to WebSocket');
});

ws.on('message', (data) => {
  try {
    const message = JSON.parse(data);
    console.log('📨 Received message:');
    console.log(JSON.stringify(message, null, 2));
  } catch (error) {
    console.error('Error parsing message:', error);
  }
});

ws.on('error', (error) => {
  console.error('❌ WebSocket error:', error.message);
});

ws.on('close', (code, reason) => {
  console.log(`❌ WebSocket closed (Code: ${code}, Reason: ${reason})`);
});

// Keep connection open for 30 seconds
setTimeout(() => {
  console.log('\nClosing connection...');
  ws.close();
  process.exit(0);
}, 30000);
```

### 3. Broadcast Notification Test

**File**: `test-websocket-broadcast.js`

```javascript
const axios = require('axios');
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

const BASE_URL = 'http://localhost:4402';

// Generate token for both API and WebSocket
const token = jwt.sign(
  { 
    id: 1, 
    shop_id: 1,
    role: 'superadmin'
  },
  process.env.JWT_SECRET || 'your_secret_key',
  { expiresIn: '24h' }
);

async function testBroadcast() {
  try {
    // Connect WebSocket first
    console.log('1. Connecting to WebSocket...');
    const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);

    let connected = false;
    success = {
      connectionReceived: false,
      notificationReceived: false
    };

    ws.on('open', () => {
      console.log('✅ WebSocket connected');
      connected = true;
    });

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data);
        console.log(`📨 Received (${message.type}):`, JSON.stringify(message, null, 2).substring(0, 200));
        
        if (message.type === 'connection') {
          success.connectionReceived = true;
        } else if (message.type === 'notification') {
          success.notificationReceived = true;
        }
      } catch (error) {
        console.error('Error parsing message:', error);
      }
    });

    ws.on('error', (error) => {
      console.error('❌ WebSocket error:', error.message);
    });

    // Wait for connection
    await new Promise(resolve => setTimeout(resolve, 1000));

    if (!connected) {
      console.error('❌ Failed to connect to WebSocket');
      process.exit(1);
    }

    // Create notification via API
    console.log('\n2. Creating notification via API...');
    const createResponse = await axios.post(
      `${BASE_URL}/api/super-admin/notifications/create`,
      {
        title: 'Test Notification',
        message: 'This is a test notification from WebSocket broadcast test',
        notificationType: 'test',
        targetType: 'all',
        priority: 'normal'
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('✅ Notification created:', createResponse.data.data);

    // Wait for broadcast
    console.log('\n3. Waiting for broadcast reception (5 seconds)...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Check stats
    console.log('\n4. Checking WebSocket stats...');
    const statsResponse = await axios.get(
      `${BASE_URL}/api/notifications/ws/stats`,
      {
        headers: { Authorization: `Bearer ${token}` }
      }
    );

    console.log('✅ WebSocket Stats:', statsResponse.data.data);

    // Summary
    console.log('\n📊 Test Summary:');
    console.log(`- Connection received: ${success.connectionReceived ? '✅' : '❌'}`);
    console.log(`- Notification received: ${success.notificationReceived ? '✅' : '❌'}`);

    ws.close();
    process.exit(success.notificationReceived ? 0 : 1);

  } catch (error) {
    console.error('❌ Test error:', error.message);
    process.exit(1);
  }
}

testBroadcast();
```

### 4. Multiple Clients Test

**File**: `test-websocket-multiple-clients.js`

```javascript
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const BASE_URL = 'http://localhost:4402';

async function createClient(clientId, shopId, userId) {
  return new Promise((resolve) => {
    const token = jwt.sign(
      { id: userId, shop_id: shopId },
      process.env.JWT_SECRET || 'your_secret_key',
      { expiresIn: '24h' }
    );

    const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);
    let received = [];

    ws.on('open', () => {
      console.log(`✅ Client ${clientId} connected (User: ${userId}, Shop: ${shopId})`);
    });

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data);
        received.push(message.type);
        console.log(`📨 Client ${clientId} received: ${message.type}`);
      } catch (error) {
        console.error(`Error in client ${clientId}:`, error);
      }
    });

    ws.on('error', (error) => {
      console.error(`❌ Client ${clientId} error:`, error.message);
    });

    ws.on('close', () => {
      console.log(`❌ Client ${clientId} disconnected`);
      resolve({ clientId, received, ws });
    });

    // Keep connection open
    setTimeout(() => {
      console.log(`\n✅ Test complete for Client ${clientId}`);
      console.log(`   Received: ${received.join(', ')}`);
      ws.close();
    }, 15000);
  });
}

async function testMultipleClients() {
  try {
    console.log('🧪 Testing Multiple WebSocket Clients\n');

    // Create multiple clients
    const clientPromises = [
      createClient(1, 1, 1),
      createClient(2, 1, 2),
      createClient(3, 2, 3),
    ];

    await Promise.all(clientPromises);

    // Now send broadcast
    console.log('\n📤 Broadcasting notification...');
    
    const token = jwt.sign(
      { id: 1, shop_id: 1, role: 'superadmin' },
      process.env.JWT_SECRET || 'your_secret_key',
      { expiresIn: '24h' }
    );

    const response = await axios.post(
      `${BASE_URL}/api/super-admin/notifications/create`,
      {
        title: 'Multi-Client Test',
        message: 'Testing broadcast to multiple clients',
        notificationType: 'test',
        targetType: 'all',
        priority: 'high'
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('✅ Broadcast sent');

    // Wait and finish
    await new Promise(resolve => setTimeout(resolve, 10000));
    process.exit(0);

  } catch (error) {
    console.error('❌ Test error:', error.message);
    process.exit(1);
  }
}

testMultipleClients();
```

### 5. Target-Specific Test

**File**: `test-websocket-target-specific.js`

```javascript
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const axios = require('axios');

const BASE_URL = 'http://localhost:4402';

async function connectClient(userId, shopId) {
  return new Promise((resolve, reject) => {
    const token = jwt.sign(
      { id: userId, shop_id: shopId },
      process.env.JWT_SECRET || 'your_secret_key',
      { expiresIn: '24h' }
    );

    const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);
    const received = [];

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data);
        if (message.type === 'notification') {
          received.push(message.data);
        }
      } catch (error) {
        console.error('Parse error:', error);
      }
    });

    ws.on('error', reject);
    ws.on('open', () => resolve({ ws, userId, shopId, received }));
  });
}

async function testTargetSpecific() {
  try {
    console.log('🧪 Testing Target-Specific Broadcasting\n');

    // Connect clients from different shops
    console.log('Connecting clients...');
    const [client1, client2, client3] = await Promise.all([
      connectClient(1, 1),  // USER 1, SHOP 1
      connectClient(2, 1),  // USER 2, SHOP 1
      connectClient(3, 2),  // USER 3, SHOP 2
    ]);

    console.log('✅ All clients connected\n');

    // Wait for connections to stabilize
    await new Promise(resolve => setTimeout(resolve, 1000));

    const adminToken = jwt.sign(
      { id: 99, shop_id: 1, role: 'superadmin' },
      process.env.JWT_SECRET || 'your_secret_key',
      { expiresIn: '24h' }
    );

    // Test 1: Broadcast to specific shop
    console.log('Test 1: Broadcasting to SHOP 1 only...');
    await axios.post(
      `${BASE_URL}/api/super-admin/notifications/create`,
      {
        title: 'Shop 1 Only',
        message: 'This should only reach users in Shop 1',
        notificationType: 'test',
        targetType: 'specific_shops',
        shopIds: [1],
        priority: 'high'
      },
      {
        headers: { Authorization: `Bearer ${adminToken}` }
      }
    );

    await new Promise(resolve => setTimeout(resolve, 2000));
    console.log(`✅ Client 1 received: ${client1.received.length} notifications`);
    console.log(`✅ Client 2 received: ${client2.received.length} notifications`);
    console.log(`✅ Client 3 received: ${client3.received.length} notifications\n`);

    // Test 2: Broadcast to specific users
    console.log('Test 2: Broadcasting to specific USERS [2, 3]...');
    await axios.post(
      `${BASE_URL}/api/super-admin/notifications/create`,
      {
        title: 'Specific Users',
        message: 'This should only reach User 2 and User 3',
        notificationType: 'test',
        targetType: 'specific_users',
        userIds: [2, 3],
        priority: 'high'
      },
      {
        headers: { Authorization: `Bearer ${adminToken}` }
      }
    );

    await new Promise(resolve => setTimeout(resolve, 2000));
    const before1 = client1.received.length;
    console.log(`✅ Client 1 total: ${client1.received.length} (change: ${client1.received.length - before1})`);
    console.log(`✅ Client 2 total: ${client2.received.length} notifications`);
    console.log(`✅ Client 3 total: ${client3.received.length} notifications\n`);

    // Cleanup
    client1.ws.close();
    client2.ws.close();
    client3.ws.close();

    console.log('✅ All tests completed');
    process.exit(0);

  } catch (error) {
    console.error('❌ Test error:', error.message);
    process.exit(1);
  }
}

testTargetSpecific();
```

## Manual Testing

### Using WebSocket Browser Tools

1. **wscat** (command-line)
   ```bash
   npm install -g wscat
   wscat -c "ws://localhost:4402/ws?token=YOUR_TOKEN"
   ```

2. **Browser DevTools**
   ```javascript
   // In browser console
   const ws = new WebSocket('ws://localhost:4402/ws?token=YOUR_TOKEN');
   ws.onmessage = e => console.log(JSON.parse(e.data));
   ```

### curl Testing (Create Notification)

```bash
# Get token first
export TOKEN=$(node -e "const jwt = require('jsonwebtoken'); console.log(jwt.sign({id:1,shop_id:1,role:'superadmin'},'your_secret_key',{expiresIn:'24h'}))")

# Create notification
curl -X POST http://localhost:4402/api/super-admin/notifications/create \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test",
    "message": "Testing WebSocket broadcast",
    "notificationType": "test",
    "targetType": "all",
    "priority": "high"
  }' | jq
```

## Test Execution

### Run All Tests

```bash
# 1. Generate token
node test-websocket-token.js

# 2. Basic connection
node test-websocket-basic.js

# 3. Broadcast test
node test-websocket-broadcast.js

# 4. Multiple clients
node test-websocket-multiple-clients.js

# 5. Target-specific
node test-websocket-target-specific.js
```

### Expected Results

#### Basic Connection Test
```
Connecting to WebSocket...
✅ Connected to WebSocket
📨 Received message:
{
  "type": "connection",
  "status": "connected",
  ...
}
```

#### Broadcast Test
```
1. Connecting to WebSocket...
✅ WebSocket connected
2. Creating notification via API...
✅ Notification created...
3. Waiting for broadcast reception...
📨 Received (notification): {...}
✅ WebSocket Stats: { totalUsers: 1, totalShops: 1, totalConnections: 1 }
```

## Common Test Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `ECONNREFUSED` | Server not running | Start server: `npm start` |
| `401 Unauthorized` | Invalid token | Generate valid JWT token |
| `Connection timeout` | Network issue | Check firewall, port accessibility |
| `Message parse error` | Invalid JSON | Check message format |

## Performance Testing

### Load Test (1000 concurrent connections)

**File**: `test-websocket-load.js`

```javascript
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

async function loadTest(numClients = 100) {
  const clients = [];
  let messagesReceived = 0;

  console.log(`Creating ${numClients} WebSocket connections...`);

  for (let i = 0; i < numClients; i++) {
    const token = jwt.sign(
      { id: i, shop_id: i % 10 },
      process.env.JWT_SECRET || 'your_secret_key'
    );

    const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);
    ws.on('message', () => messagesReceived++);
    ws.on('error', () => { /* ignore */ });
    
    clients.push(ws);
  }

  console.log(`✅ ${numClients} clients connected`);
  console.log(`Messages received: ${messagesReceived}`);

  // Close all
  clients.forEach(ws => ws.close());
}

loadTest(1000);
```

## Monitoring During Tests

### Watch Server Logs
```bash
npm start | grep -E "WebSocket|Broadcast|Client"
```

### Monitor System Resources
```bash
watch -n 1 'ps aux | grep node'
```

### Check Connection Stats
```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:4402/api/notifications/ws/stats | jq
```

---

## Status
✅ All tests created and documented

**Last Updated**: March 27, 2025
