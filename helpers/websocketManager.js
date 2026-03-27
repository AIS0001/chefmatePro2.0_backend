const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

/**
 * WEBSOCKET MANAGER
 * Manages WebSocket connections and broadcasts notifications to clients
 */

class WebSocketManager {
  constructor() {
    this.wss = null;
    this.clients = new Map(); // Map of client connections: key = userId, value = Set of WebSocket connections
    this.shopConnections = new Map(); // Map of shop connections: key = shopId, value = Set of connections
  }

  /**
   * Initialize WebSocket server
   * @param {http.Server} server - Express server instance
   * @param {Object} options - Configuration options
   */
  initialize(server, options = {}) {
    try {
      this.wss = new WebSocket.Server({ 
        server,
        path: '/ws',
        ...options
      });

      this.wss.on('connection', (ws, req) => {
        console.log('[WebSocket] 🔌 New client connection attempt');
        
        let isAuthenticated = false;
        let userId = null;
        let shopId = null;
        let authTimeout = null;

        // Set authentication timeout (5 seconds)
        authTimeout = setTimeout(() => {
          if (!isAuthenticated) {
            console.log('[WebSocket] ❌ Authentication timeout - no token received');
            ws.close(4001, 'Unauthorized: No token received');
          }
        }, 5000);

        // Handle incoming messages including auth
        const messageHandler = (data) => {
          if (!isAuthenticated) {
            try {
              const message = JSON.parse(data);
              
              // Check if this is an auth message
              if (message.type === 'auth' && message.token) {
                console.log('[WebSocket] 🔐 Auth token received, verifying...');
                
                try {
                  const decoded = jwt.verify(message.token, process.env.JWT_SECRET || 'your_secret_key');
                  userId = decoded.id;
                  shopId = decoded.shop_id;
                  isAuthenticated = true;
                  
                  // Clear auth timeout
                  clearTimeout(authTimeout);

                  // Store client connection
                  this.addClient(ws, userId, shopId);

                  console.log(`[WebSocket] ✅ Client authenticated - User: ${userId}, Shop: ${shopId}`);
                  console.log(`[WebSocket Stats] Total Users: ${this.clients.size}, Total Shops: ${this.shopConnections.size}`);

                  // Send connection success message
                  ws.send(JSON.stringify({
                    type: 'connection',
                    status: 'connected',
                    message: 'WebSocket connection established',
                    userId,
                    shopId,
                    timestamp: new Date().toISOString()
                  }));
                } catch (error) {
                  console.log('[WebSocket] ❌ Token verification failed:', error.message);
                  ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Invalid token',
                    timestamp: new Date().toISOString()
                  }));
                  ws.close(4001, 'Unauthorized: Invalid token');
                }
              }
            } catch (error) {
              console.error('[WebSocket] Error parsing initial message:', error);
            }
          } else {
            // Handle regular messages after authentication
            this.handleMessage(ws, data, userId, shopId);
          }
        };

        ws.on('message', messageHandler);

        // Handle client disconnect
        ws.on('close', () => {
          clearTimeout(authTimeout);
          if (isAuthenticated) {
            this.removeClient(ws, userId, shopId);
            console.log(`[WebSocket] ❌ Client disconnected - User: ${userId}, Shop: ${shopId}`);
            console.log(`[WebSocket Stats] Total Users: ${this.clients.size}, Total Shops: ${this.shopConnections.size}`);
          } else {
            console.log('[WebSocket] ❌ Unauthenticated client disconnected');
          }
        });

        // Handle error
        ws.on('error', (error) => {
          console.error('[WebSocket] Client error:', error);
          clearTimeout(authTimeout);
        });
      });

      this.wss.on('error', (error) => {
        console.error('[WebSocket] Server error:', error);
      });

      console.log('[WebSocket] Manager initialized successfully');
      return this.wss;
    } catch (error) {
      console.error('[WebSocket] Error initializing WebSocket manager:', error);
      throw error;
    }
  }

  /**
   * Extract JWT token from request
   * @param {http.IncomingMessage} req - WebSocket upgrade request
   * @returns {string|null} - JWT token or null
   */
  extractToken(req) {
    // Try to get token from query string
    const url = new URL(req.url, `http://${req.headers.host}`);
    const token = url.searchParams.get('token');
    
    if (token) return token;

    // Try to get token from Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    return null;
  }

  /**
   * Add client connection
   * @param {WebSocket} ws - WebSocket connection
   * @param {number} userId - User ID
   * @param {number} shopId - Shop ID
   */
  addClient(ws, userId, shopId) {
    // Add to user clients
    if (!this.clients.has(userId)) {
      this.clients.set(userId, new Set());
    }
    this.clients.get(userId).add(ws);

    // Add to shop connections
    if (!this.shopConnections.has(shopId)) {
      this.shopConnections.set(shopId, new Set());
    }
    this.shopConnections.get(shopId).add(ws);

    // Attach metadata to WebSocket
    ws.userId = userId;
    ws.shopId = shopId;
  }

  /**
   * Remove client connection
   * @param {WebSocket} ws - WebSocket connection
   * @param {number} userId - User ID
   * @param {number} shopId - Shop ID
   */
  removeClient(ws, userId, shopId) {
    // Remove from user clients
    if (this.clients.has(userId)) {
      this.clients.get(userId).delete(ws);
      if (this.clients.get(userId).size === 0) {
        this.clients.delete(userId);
      }
    }

    // Remove from shop connections
    if (this.shopConnections.has(shopId)) {
      this.shopConnections.get(shopId).delete(ws);
      if (this.shopConnections.get(shopId).size === 0) {
        this.shopConnections.delete(shopId);
      }
    }
  }

  /**
   * Handle incoming message from client
   * @param {WebSocket} ws - WebSocket connection
   * @param {Buffer} data - Message data
   * @param {number} userId - User ID
   * @param {number} shopId - Shop ID
   */
  handleMessage(ws, data, userId, shopId) {
    try {
      const message = JSON.parse(data);
      
      switch (message.type) {
        case 'ping':
          ws.send(JSON.stringify({ type: 'pong', timestamp: new Date().toISOString() }));
          break;
        
        case 'subscribe':
          console.log(`[WebSocket] User ${userId} subscribed to shop ${shopId} notifications`);
          break;
        
        default:
          console.log('[WebSocket] Unknown message type:', message.type);
      }
    } catch (error) {
      console.error('[WebSocket] Error handling message:', error);
    }
  }

  /**
   * Broadcast notification to all connected clients
   * @param {Object} notification - Notification object
   * @param {string} notification.id - Notification ID
   * @param {string} notification.title - Notification title
   * @param {string} notification.message - Notification message
   * @param {string} notification.type - Notification type (general, announcement, alert, etc.)
   * @param {number|null} notification.priority - Notification priority
   * @param {Object} options - Broadcast options
   * @param {string} options.targetType - Target type: 'all', 'specific_shops', 'specific_users'
   * @param {number[]} options.shopIds - Shop IDs to target
   * @param {number[]} options.userIds - User IDs to target
   */
  broadcastNotification(notification, options = {}) {
    try {
      if (!this.wss) {
        console.warn('[WebSocket] WebSocket server not initialized');
        return;
      }

      const message = JSON.stringify({
        type: 'notification',
        notification: notification,
        timestamp: new Date().toISOString()
      });

      let clientsToNotify = [];

      if (options.targetType === 'all') {
        // Broadcast to all connected clients
        clientsToNotify = Array.from(this.clients.values()).flat();
        console.log(`[WebSocket Broadcast] Target: ALL - Found ${this.clients.size} users, ${clientsToNotify.length} total connections`);
      } else if (options.targetType === 'specific_shops' && options.shopIds) {
        // Broadcast to specific shops
        options.shopIds.forEach(shopId => {
          if (this.shopConnections.has(shopId)) {
            clientsToNotify.push(...this.shopConnections.get(shopId));
          }
        });
        console.log(`[WebSocket Broadcast] Target: SHOPS [${options.shopIds.join(',')}] - Found ${clientsToNotify.length} connections`);
      } else if (options.targetType === 'specific_users' && options.userIds) {
        // Broadcast to specific users
        options.userIds.forEach(userId => {
          if (this.clients.has(userId)) {
            clientsToNotify.push(...this.clients.get(userId));
          }
        });
        console.log(`[WebSocket Broadcast] Target: USERS [${options.userIds.join(',')}] - Found ${clientsToNotify.length} connections`);
      }

      // Remove duplicates and send
      const sentTo = new Set();
      clientsToNotify.forEach(ws => {
        if (ws.readyState === WebSocket.OPEN && !sentTo.has(ws)) {
          ws.send(message);
          sentTo.add(ws);
          console.log(`[WebSocket Broadcast] Sent notification to user ${ws.userId}, shop ${ws.shopId}`);
        }
      });

      console.log(`[WebSocket] ✅ Broadcast notification "${notification.title}" to ${sentTo.size} clients (Type: ${options.targetType})`);
      return sentTo.size;
    } catch (error) {
      console.error('[WebSocket] Error broadcasting notification:', error);
    }
  }

  /**
   * Send notification to specific user
   * @param {number} userId - User ID
   * @param {Object} notification - Notification object
   */
  sendToUser(userId, notification) {
    try {
      if (!this.clients.has(userId)) {
        console.warn(`[WebSocket] User ${userId} not connected`);
        return 0;
      }

      const message = JSON.stringify({
        type: 'notification',
        data: notification,
        timestamp: new Date().toISOString()
      });

      let sentCount = 0;
      this.clients.get(userId).forEach(ws => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(message);
          sentCount++;
        }
      });

      console.log(`[WebSocket] Sent notification to user ${userId} (${sentCount} connections)`);
      return sentCount;
    } catch (error) {
      console.error('[WebSocket] Error sending to user:', error);
    }
  }

  /**
   * Send notification to all users in a shop
   * @param {number} shopId - Shop ID
   * @param {Object} notification - Notification object
   */
  sendToShop(shopId, notification) {
    try {
      if (!this.shopConnections.has(shopId)) {
        console.warn(`[WebSocket] No connections in shop ${shopId}`);
        return 0;
      }

      const message = JSON.stringify({
        type: 'notification',
        data: notification,
        timestamp: new Date().toISOString()
      });

      let sentCount = 0;
      this.shopConnections.get(shopId).forEach(ws => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(message);
          sentCount++;
        }
      });

      console.log(`[WebSocket] Sent notification to shop ${shopId} (${sentCount} users)`);
      return sentCount;
    } catch (error) {
      console.error('[WebSocket] Error sending to shop:', error);
    }
  }

  /**
   * Get connection statistics
   * @returns {Object} - Statistics object
   */
  getStats() {
    let totalConnections = 0;
    let totalUsers = 0;
    let totalShops = 0;

    this.clients.forEach(connections => {
      totalConnections += connections.size;
    });

    totalUsers = this.clients.size;
    totalShops = this.shopConnections.size;

    return {
      totalUsers,
      totalShops,
      totalConnections,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Close all WebSocket connections
   */
  close() {
    if (this.wss) {
      this.wss.clients.forEach(ws => {
        ws.close();
      });
      this.wss.close();
      console.log('[WebSocket] WebSocket server closed');
    }
  }
}

module.exports = new WebSocketManager();
