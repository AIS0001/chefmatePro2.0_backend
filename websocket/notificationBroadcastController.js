const { 
  broadcastToShop, 
  broadcastToAll, 
  getConnectedUsersCount,
  getConnectedUsers,
  isUserConnected 
} = require('./notificationWebSocket');
const db = require('../config/dbconnection1');

/**
 * WEBSOCKET BROADCAST CONTROLLER
 * Handles broadcasting notifications via WebSocket after creation
 */

/**
 * Broadcast notification after creation
 */
const broadcastNotificationAfterCreation = async (notificationId) => {
  try {
    // Fetch the created notification
    const [notifications] = await db.query(
      'SELECT * FROM notifications WHERE id = ? AND is_active = 1',
      [notificationId]
    );

    if (!notifications || notifications.length === 0) {
      console.log('Notification not found for broadcast');
      return;
    }

    const notification = notifications[0];

    // Prepare broadcast data
    const broadcastData = {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      image_url: notification.image_url,
      notification_type: notification.notification_type,
      priority: notification.priority,
      created_at: notification.created_at
    };

    // Broadcast based on target type
    let result = {};

    if (notification.target_type === 'all') {
      // Broadcast to all connected users
      result = broadcastToAll(broadcastData);
      console.log(`📢 Notification broadcast to ALL users`);
    } 
    else if (notification.target_type === 'specific_shops') {
      // Broadcast to users of specific shops
      const shopIds = JSON.parse(notification.shop_ids || '[]');
      const broadcastResults = [];

      for (const shopId of shopIds) {
        const res = broadcastToShop(shopId, broadcastData);
        broadcastResults.push(res);
      }

      result = {
        sentTo: broadcastResults.flatMap(r => r.sentTo),
        failed: broadcastResults.flatMap(r => r.failed)
      };

      console.log(`📢 Notification broadcast to shops: ${shopIds.join(', ')}`);
    } 
    else if (notification.target_type === 'specific_users') {
      // Broadcast to specific users
      const userIds = JSON.parse(notification.user_ids || '[]');
      const { sendNotificationToUsers } = require('./notificationWebSocket');
      result = sendNotificationToUsers(userIds, broadcastData);
      console.log(`📢 Notification broadcast to users: ${userIds.join(', ')}`);
    }

    console.log(`✅ Broadcast result:`, result);
    return result;
  } catch (error) {
    console.error('Error broadcasting notification:', error);
  }
};

/**
 * Manual broadcast endpoint (super admin can re-trigger)
 */
const manualBroadcastNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const result = await broadcastNotificationAfterCreation(notificationId);

    res.json({
      success: true,
      message: 'Notification broadcast triggered',
      data: result
    });
  } catch (error) {
    console.error('Error in manual broadcast:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to broadcast notification'
    });
  }
};

/**
 * Get WebSocket connection stats
 */
const getWebSocketStats = async (req, res) => {
  try {
    const connectedCount = getConnectedUsersCount();
    const connectedUsers = getConnectedUsers();

    res.json({
      success: true,
      data: {
        totalConnected: connectedCount,
        connectedUsers: connectedUsers
      }
    });
  } catch (error) {
    console.error('Error getting WebSocket stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get stats'
    });
  }
};

/**
 * Check if user is connected via WebSocket
 */
const checkUserConnection = async (req, res) => {
  try {
    const { userId } = req.params;
    const connected = isUserConnected(parseInt(userId));

    res.json({
      success: true,
      data: {
        userId,
        isConnected: connected
      }
    });
  } catch (error) {
    console.error('Error checking user connection:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to check connection'
    });
  }
};

module.exports = {
  broadcastNotificationAfterCreation,
  manualBroadcastNotification,
  getWebSocketStats,
  checkUserConnection
};
