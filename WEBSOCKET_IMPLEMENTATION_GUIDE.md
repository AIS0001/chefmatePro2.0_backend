# WebSocket Real-Time Notifications Implementation

## Overview

This document describes the real-time WebSocket notification system for ChefmatePro2. The system enables push notifications to connected clients without requiring polling.

## Architecture

### Components

1. **WebSocket Manager** (`helpers/websocketManager.js`)
   - Manages all WebSocket connections
   - Handles authentication and connection lifecycle
   - Broadcasts notifications to targeted clients
   - Provides statistics and monitoring

2. **Server Integration** (`server.js`)
   - Creates HTTP server with WebSocket support
   - Initializes WebSocket manager on startup
   - Logs connection statistics

3. **Notifications Controller** (`controllers/notificationsController.js`)
   - Integrates WebSocket broadcasting into notification creation
   - Broadcasts deletion events

4. **Notifications Routes** (`routes/notificationsRoutes.js`)
   - Provides WebSocket statistics endpoint

## Installation

### 1. Install Dependencies

```bash
npm install ws@8.14.2
```

The `ws` library is already added to `package.json`. Run npm install to ensure it's installed.

### 2. Environment Configuration

No additional environment variables are required. The system uses:
- `JWT_SECRET` (existing) for token verification
- `PORT` (existing, defaults to 4402) for WebSocket server

## Usage

### Client Connection

#### JavaScript/Node.js

```javascript
// With JWT token in query string
const token = 'your_jwt_token_here';
const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);

// Or with Authorization header (browser)
const ws = new WebSocket('ws://localhost:4402/ws');
ws.onopen = () => {
  // Send authorization after connection
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'your_jwt_token_here'
  }));
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  
  if (message.type === 'connection') {
    console.log('Connected to WebSocket', message);
  } else if (message.type === 'notification') {
    console.log('New notification:', message.data);
  } else if (message.type === 'pong') {
    console.log('Pong received');
  }
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('WebSocket disconnected');
};
```

#### React Example

```javascript
// hooks/useWebSocket.js
import { useEffect, useState, useRef } from 'react';

export const useWebSocket = (token) => {
  const [isConnected, setIsConnected] = useState(false);
  const [notification, setNotification] = useState(null);
  const wsRef = useRef(null);

  useEffect(() => {
    if (!token) return;

    const ws = new WebSocket(`ws://${window.location.hostname}:4402/ws?token=${token}`);

    ws.onopen = () => {
      console.log('WebSocket connected');
      setIsConnected(true);
    };

    ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        if (message.type === 'notification') {
          setNotification(message.data);
          // Show toast/alert to user
        }
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    };

    ws.onerror = () => setIsConnected(false);
    ws.onclose = () => setIsConnected(false);

    wsRef.current = ws;

    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, [token]);

  const sendPing = () => {
    if (wsRef.current && isConnected) {
      wsRef.current.send(JSON.stringify({ type: 'ping' }));
    }
  };

  return { isConnected, notification, sendPing };
};

// Usage in component
function NotificationCenter() {
  const { isConnected, notification } = useWebSocket(authToken);

  useEffect(() => {
    if (notification) {
      showNotificationToast(notification);
    }
  }, [notification]);

  return (
    <div>
      <div className="connection-status">
        {isConnected ? '🟢 Connected' : '🔴 Disconnected'}
      </div>
    </div>
  );
}
```

### Server Broadcasting

The server broadcasts notifications automatically when they are created via the API:

```bash
# Create notification for all users
curl -X POST http://localhost:4402/api/super-admin/notifications/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "System Update",
    "message": "New features available",
    "notificationType": "announcement",
    "targetType": "all",
    "priority": "high"
  }'

# The notification is automatically:
# 1. Saved to database
# 2. Broadcasted to all connected WebSocket clients
# 3. Response includes notification ID
```

### Message Types

#### Connection Message
```javascript
{
  type: 'connection',
  status: 'connected',
  message: 'WebSocket connection established',
  userId: 123,
  shopId: 456,
  timestamp: '2025-03-27T10:30:00.000Z'
}
```

#### Notification Message
```javascript
{
  type: 'notification',
  data: {
    id: 1,
    title: 'System Update',
    message: 'New features available',
    imageUrl: 'https://...',
    notificationType: 'announcement',
    targetType: 'all',
    priority: 'high',
    createdAt: '2025-03-27T10:30:00.000Z'
  },
  timestamp: '2025-03-27T10:30:00.000Z'
}
```

#### Ping/Pong (Keep-alive)
```javascript
// Client sends:
{
  type: 'ping'
}

// Server responds:
{
  type: 'pong',
  timestamp: '2025-03-27T10:30:00.000Z'
}
```

#### Notification Deleted Message
```javascript
{
  type: 'notification',
  data: {
    id: 1,
    type: 'notification_deleted',
    message: 'Notification has been deleted'
  },
  timestamp: '2025-03-27T10:30:00.000Z'
}
```

## API Endpoints

### WebSocket Connection
```
ws://localhost:4402/ws?token=JWT_TOKEN
```

**Authentication:**
- Token can be passed as query parameter: `?token=YOUR_TOKEN`
- Or via headers (for browser: custom headers not allowed in WebSocket upgrade)

**Connection Status Codes:**
- `4001`: Unauthorized (missing or invalid token)

### REST API Endpoint for Stats

```
GET /api/notifications/ws/stats
Headers:
  Authorization: Bearer JWT_TOKEN

Response:
{
  "success": true,
  "data": {
    "totalUsers": 10,
    "totalShops": 5,
    "totalConnections": 15,
    "timestamp": "2025-03-27T10:30:00.000Z"
  }
}
```

## Notification Broadcasting

### Target Types

1. **All Users** (`targetType: 'all'`)
   - Broadcast to all connected clients
   ```javascript
   websocketManager.broadcastNotification(notificationData, {
     targetType: 'all'
   });
   ```

2. **Specific Shops** (`targetType: 'specific_shops'`)
   - Broadcast to users in specific shops
   ```javascript
   websocketManager.broadcastNotification(notificationData, {
     targetType: 'specific_shops',
     shopIds: [1, 2, 3]
   });
   ```

3. **Specific Users** (`targetType: 'specific_users'`)
   - Broadcast to specific users
   ```javascript
   websocketManager.broadcastNotification(notificationData, {
     targetType: 'specific_users',
     userIds: [10, 20, 30]
   });
   ```

## Monitoring & Debugging

### Server Logs

The system logs WebSocket activities:

```
[WebSocket] New client connection
[WebSocket] Client connected - User: 123, Shop: 456
[WebSocket] Broadcast notification to 15 clients (Type: all)
[WebSocket] Client disconnected - User: 123, Shop: 456
[WebSocket Stats] Users: 10, Shops: 5, Connections: 15
```

### Connection Statistics

View live connection statistics:
```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:4402/api/notifications/ws/stats
```

## Error Handling

### Common Errors

1. **401 Unauthorized**
   - Cause: Missing or invalid JWT token
   - Solution: Ensure token is passed correctly in query string or header

2. **Connection Timeout**
   - Cause: Network issues or server not responding
   - Solution: Implement reconnection logic with exponential backoff

3. **Message Parse Error**
   - Cause: Invalid JSON in message
   - Solution: Validate message format before sending

### Reconnection Strategy

```javascript
let reconnectAttempts = 0;
const maxReconnectAttempts = 5;
const reconnectDelay = 1000; // Start with 1 second

function connectWebSocket() {
  try {
    const ws = new WebSocket(`ws://localhost:4402/ws?token=${token}`);
    
    ws.onclose = () => {
      if (reconnectAttempts < maxReconnectAttempts) {
        reconnectAttempts++;
        const delay = reconnectDelay * Math.pow(2, reconnectAttempts - 1);
        console.log(`Reconnecting in ${delay}ms...`);
        setTimeout(connectWebSocket, delay);
      } else {
        console.error('Max reconnection attempts reached');
      }
    };

    ws.onopen = () => {
      reconnectAttempts = 0; // Reset on successful connection
    };
  } catch (error) {
    console.error('WebSocket connection error:', error);
  }
}
```

## Performance Considerations

1. **Connection Limits**
   - Default: No hard limit (depends on server resources)
   - Monitor: Use `/api/notifications/ws/stats` endpoint

2. **Message Frequency**
   - Each broadcast creates one message per connected client
   - For 1000 concurrent users: ~1000 messages per broadcast
   - Consider batching for high-frequency updates

3. **Memory Usage**
   - ~1.5KB per connection overhead
   - 1000 connections ≈ 1.5MB additional memory

## Troubleshooting

### WebSocket Connection Fails

1. Check server is running:
   ```bash
   curl http://localhost:4402/health
   ```

2. Verify JWT token is valid:
   ```bash
   npm run test:jwt TOKEN_HERE
   ```

3. Check firewall/network:
   - Ensure WebSocket port (4402) is not blocked
   - Check CORS configuration if frontend is cross-origin

### Notifications Not Received

1. Verify client is connected:
   - Check browser console for connection status
   - Use `/api/notifications/ws/stats` to see active connections

2. Check notification target type:
   - Ensure `targetType` matches client's scope
   - For `specific_shops`, verify shop ID is in the list

3. Monitor server logs:
   - Look for broadcast confirmation messages
   - Check for JSON parsing errors

### Performance Issues

1. Check active connections:
   ```bash
   # Monitor stats endpoint
   watch -n 1 'curl -H "Authorization: Bearer TOKEN" http://localhost:4402/api/notifications/ws/stats'
   ```

2. Reduce message frequency if needed

3. Implement client-side buffering for high-frequency updates

## Testing

See `WEBSOCKET_TEST_GUIDE.md` for comprehensive testing procedures.

### Quick Test

```bash
# Terminal 1: Start server
npm start

# Terminal 2: Run test script
node test-websocket.js
```

## Security Considerations

1. **JWT Token Validation**
   - All connections require valid JWT token
   - Token is verified on connection and re-verified on sensitive operations

2. **Message Integrity**
   - All messages are JSON-validated
   - Invalid messages are logged and dropped

3. **Rate Limiting**
   - Consider implementing rate limiting for high-frequency messages
   - Can be added to `websocketManager.broaden NotifyNotification()`

4. **HTTPS/WSS**
   - In production, use WSS (WebSocket Secure) with HTTPS
   - Update connection string: `wss://hostname/ws`

## Development Tips

### Enable Verbose Logging

```javascript
// In server.js, before initializing websocketManager
process.env.DEBUG = 'websocket:*';
```

### Test Token Generation

```javascript
const jwt = require('jsonwebtoken');

const token = jwt.sign(
  { id: 123, shop_id: 456 },
  process.env.JWT_SECRET || 'your_secret_key',
  { expiresIn: '24h' }
);

console.log('Test token:', token);
```

## Future Enhancements

1. **Presence Tracking**
   - Track which users are active in each shop
   - Sync with frontend status indicators

2. **Message History**
   - Store recent messages in cache
   - Send to client on reconnection

3. **Selective Subscriptions**
   - Allow clients to subscribe/unsubscribe from specific channels
   - Reduce message volume

4. **Compression**
   - Enable message compression for large payloads
   - Already configured (`perMessageDeflate: false` can be toggled)

## Support & Questions

For issues or questions:
1. Check this documentation
2. Review `WEBSOCKET_TEST_GUIDE.md`
3. Check server logs for errors
4. Test connection using provided scripts

---

## Status
✅ Production Ready (v1.0)

**Last Updated**: March 27, 2025
**Tested On**: Node.js 18+
**Dependencies**: ws v8.14.2
