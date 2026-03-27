const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const db = require('../config/dbconnection1');

/**
 * WEBSOCKET NOTIFICATION SERVER
 * Handles real-time notifications for users
 */

// Store active connections: { userId: { ws, shopId, user_id } }
const activeConnections = new Map();

/**
 * Setup WebSocket Server
 * @param {http.Server} server - Express HTTP server
 */
const setupWebSocketServer = (server) => {
  const wss = new WebSocket.Server({ 
    server,
    path: '/notifications-ws'
  });

  console.log('🔌 WebSocket Server initialized at /notifications-ws');

  // Handle new connections
  wss.on('connection', (ws, req) => {
    console.log('✅ New WebSocket connection');

    // Authenticate user via JWT token
    const token = extractToken(req);
    if (!token) {
      console.log('❌ WebSocket connection rejected: No token');
      ws.close(1008, 'Unauthorized: No token provided');
      return;
    }

    // Verify token
    const decoded = verifyToken(token);
    if (!decoded) {
      console.log('❌ WebSocket connection rejected: Invalid token');
      ws.close(1008, 'Unauthorized: Invalid token');
      return;
    }

    const userId = decoded.id;
    const shopId = decoded.shop_id;

    console.log(`✅ WebSocket authenticated: User ${userId}, Shop ${shopId}`);

    // Store connection
    activeConnections.set(userId, {
      ws,
      userId,
      shopId,
      connectedAt: new Date()
    });

    // Send welcome message
    ws.send(JSON.stringify({
      type: 'CONNECTION_SUCCESS',
      message: 'Connected to notification server',
      timestamp: new Date().toISOString(),
      userId
    }));

    // Log connected users count
    console.log(`📊 Active Connections: ${activeConnections.size}`);

    // Handle incoming messages (ping for keep-alive)
    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data);
        
        if (message.type === 'PING') {
          ws.send(JSON.stringify({ 
            type: 'PONG',
            timestamp: new Date().toISOString()
          }));
        }
      } catch (error) {
        console.error('Error processing WebSocket message:', error);
      }
    });

    // Handle client disconnect
    ws.on('close', () => {
      activeConnections.delete(userId);
      console.log(`❌ User ${userId} disconnected. Active Connections: ${activeConnections.size}`);
    });

    // Handle errors
    ws.on('error', (error) => {
      console.error(`⚠️ WebSocket error for user ${userId}:`, error);
    });
  });

  return wss;
};

/**
 * Extract JWT token from WebSocket request
 */
const extractToken = (req) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const token = url.searchParams.get('token');
    return token;
  } catch (error) {
    console.error('Error extracting token:', error);
    return null;
  }
};

/**
 * Verify JWT token
 */
const verifyToken = (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'chefmate_secret_key_2024');
    return decoded;
  } catch (error) {
    console.error('Token verification failed:', error.message);
    return null;
  }
};

/**
 * Broadcast notification to specific user
 */
const sendNotificationToUser = (userId, notification) => {
  const connection = activeConnections.get(userId);
  
  if (connection && connection.ws.readyState === WebSocket.OPEN) {
    const message = {
      type: 'NOTIFICATION',
      data: notification,
      timestamp: new Date().toISOString()
    };

    connection.ws.send(JSON.stringify(message));
    console.log(`📤 Notification sent to user ${userId}`);
    return true;
  } else {
    console.log(`⚠️ User ${userId} not connected or connection not open`);
    return false;
  }
};

/**
 * Broadcast notification to multiple users
 */
const sendNotificationToUsers = (userIds, notification) => {
  const sentTo = [];
  const failed = [];

  userIds.forEach(userId => {
    const sent = sendNotificationToUser(userId, notification);
    if (sent) {
      sentTo.push(userId);
    } else {
      failed.push(userId);
    }
  });

  return { sentTo, failed };
};

/**
 * Broadcast notification to all connected users of a shop
 */
const broadcastToShop = (shopId, notification) => {
  const shopUsers = Array.from(activeConnections.values()).filter(
    conn => conn.shopId === shopId
  );

  const userIds = shopUsers.map(conn => conn.userId);
  return sendNotificationToUsers(userIds, notification);
};

/**
 * Broadcast notification to all connected users (system-wide)
 */
const broadcastToAll = (notification) => {
  const userIds = Array.from(activeConnections.keys());
  return sendNotificationToUsers(userIds, notification);
};

/**
 * Get connected users count
 */
const getConnectedUsersCount = () => {
  return activeConnections.size;
};

/**
 * Get all connected users
 */
const getConnectedUsers = () => {
  return Array.from(activeConnections.values()).map(conn => ({
    userId: conn.userId,
    shopId: conn.shopId,
    connectedAt: conn.connectedAt
  }));
};

/**
 * Check if user is connected
 */
const isUserConnected = (userId) => {
  return activeConnections.has(userId);
};

module.exports = {
  setupWebSocketServer,
  sendNotificationToUser,
  sendNotificationToUsers,
  broadcastToShop,
  broadcastToAll,
  getConnectedUsersCount,
  getConnectedUsers,
  isUserConnected,
  activeConnections
};
