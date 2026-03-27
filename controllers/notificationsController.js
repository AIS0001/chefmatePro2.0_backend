const db = require('../config/dbconnection1');
const fs = require('fs');
const path = require('path');
const websocketManager = require('../helpers/websocketManager');

/**
 * NOTIFICATIONS CONTROLLER
 * Handles notification creation, retrieval, and management
 * Includes WebSocket real-time broadcast support
 */

// ============================================
// SUPER ADMIN - CREATE NOTIFICATIONS
// ============================================

/**
 * Create a new notification
 * Super admin only
 */
const createNotification = async (req, res) => {
  try {
    let { title, message, notificationType, targetType, shopIds, userIds, priority, scheduledFor, expiresAt } = req.body;

    // FormData sends arrays/objects as JSON strings — parse them
    if (typeof shopIds === 'string') {
      try { shopIds = JSON.parse(shopIds); } catch { shopIds = []; }
    }
    if (typeof userIds === 'string') {
      try { userIds = JSON.parse(userIds); } catch { userIds = []; }
    }
    // Validate required fields
    if (!title || !message) {
      return res.status(400).json({
        success: false,
        error: 'Title and message are required'
      });
    }

    // Validate target type
    if (targetType === 'specific_shops' && (!shopIds || shopIds.length === 0)) {
      return res.status(400).json({
        success: false,
        error: 'At least one shop must be selected for specific_shops target type'
      });
    }

    if (targetType === 'specific_users' && (!userIds || userIds.length === 0)) {
      return res.status(400).json({
        success: false,
        error: 'At least one user must be selected for specific_users target type'
      });
    }

    const userId = req.user?.id || 1; // Get from JWT token

    const insertQuery = `
      INSERT INTO notifications (
        title, message, notification_type,
        target_type, shop_ids, user_ids, created_by, priority,
        scheduled_for, expires_at, is_active
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      title,
      message,
      notificationType || 'general',
      targetType || 'all',
      targetType === 'specific_shops' ? JSON.stringify(shopIds) : null,
      targetType === 'specific_users' ? JSON.stringify(userIds) : null,
      userId,
      priority || 'normal',
      scheduledFor || null,
      expiresAt || null,
      1 // is_active
    ];

    const [result] = await db.query(insertQuery, values);

    // If targeting specific shops/users, create read status records
    if (targetType === 'specific_shops' && shopIds.length > 0) {
      await createReadStatusRecords(result.insertId, shopIds, targetType);
    } else if (targetType === 'specific_users' && userIds.length > 0) {
      await createReadStatusRecords(result.insertId, userIds, targetType, 'users');
    } else if (targetType === 'all') {
      // For 'all' target, we'll create records on-the-fly when users fetch
    }

    // Prepare notification data for response and WebSocket broadcast
    const notificationData = {
      id: result.insertId,
      title,
      message,
      notificationType: notificationType || 'general',
      targetType: targetType || 'all',
      priority: priority || 'normal',
      createdAt: new Date().toISOString()
    };

    // Broadcast notification in real-time via WebSocket
    try {
      websocketManager.broadcastNotification(notificationData, {
        targetType: targetType || 'all',
        shopIds: targetType === 'specific_shops' ? shopIds : undefined,
        userIds: targetType === 'specific_users' ? userIds : undefined
      });
      console.log(`[Notifications] Broadcasted notification ${result.insertId} via WebSocket`);
    } catch (wsError) {
      console.error('[Notifications] WebSocket broadcast error:', wsError);
      // Don't fail the API call if WebSocket broadcast fails
    }

    res.json({
      success: true,
      message: 'Notification created successfully',
      data: notificationData
    });
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create notification',
      details: error.message
    });
  }
};

/**
 * Helper function to create read status records
 */
const createReadStatusRecords = async (notificationId, ids, targetType, idType = 'shops') => {
  try {
    console.log(`[Notifications] Creating read status records for notification ${notificationId}, targetType: ${targetType}, ids:`, ids);
    
    if (idType === 'shops') {
      // For specific shops, create records for all users in those shops
      for (const shopId of ids) {
        console.log(`[Notifications] Creating records for shop ${shopId}`);
        // Get all users in this shop
        const [users] = await db.query('SELECT id FROM users WHERE shop_id = ?', [shopId]);
        console.log(`[Notifications] Found ${users.length} users in shop ${shopId}`);
        
        for (const user of users) {
          const [result] = await db.query(
            'INSERT IGNORE INTO notification_read_status (notification_id, shop_id, user_id, is_read) VALUES (?, ?, ?, 0)',
            [notificationId, shopId, user.id]
          );
          console.log(`[Notifications] Created read status for notification ${notificationId}, shop ${shopId}, user ${user.id}`);
        }
      }
    } else if (idType === 'users') {
      // For specific users, create records with their shop_id
      for (const userId of ids) {
        const [user] = await db.query('SELECT shop_id FROM users WHERE id = ?', [userId]);
        const shopId = user?.[0]?.shop_id || 0;
        
        const [result] = await db.query(
          'INSERT IGNORE INTO notification_read_status (notification_id, shop_id, user_id, is_read) VALUES (?, ?, ?, 0)',
          [notificationId, shopId, userId]
        );
        console.log(`[Notifications] Created read status for notification ${notificationId}, shop ${shopId}, user ${userId}`);
      }
    }
  } catch (error) {
    console.error('Error creating read status records:', error);
  }
};

// ============================================
// SUPER ADMIN - GET ALL NOTIFICATIONS
// ============================================

/**
 * Get all notifications (super admin only)
 */
const getAllNotifications = async (req, res) => {
  try {
    const { page = 1, limit = 20, isActive, sortBy = 'created_at', order = 'DESC' } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM notifications WHERE 1=1';
    const params = [];

    if (isActive !== undefined) {
      query += ' AND is_active = ?';
      params.push(isActive === 'true' ? 1 : 0);
    }

    query += ` ORDER BY ${sortBy} ${order} LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), offset);

    const [notifications] = await db.query(query, params);

    // Get total count
    const [countResult] = await db.query('SELECT COUNT(*) as total FROM notifications');
    const total = countResult[0].total;

    res.json({
      success: true,
      data: {
        notifications: notifications.map(notif => ({
          ...notif,
          shopIds: notif.shop_ids ? JSON.parse(notif.shop_ids) : [],
          userIds: notif.user_ids ? JSON.parse(notif.user_ids) : []
        })),
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications'
    });
  }
};

// ============================================
// USER - GET NOTIFICATIONS FOR CURRENT USER/SHOP
// ============================================

/**
 * Get notifications for current user/shop
 */
const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user?.id || 1;
    const shopId = req.user?.shop_id || req.query.shop_id || req.shop_id;
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    const offset = (page - 1) * limit;

    console.log(`[Notifications] Fetching notifications for User ${userId}, Shop ${shopId}, Page ${page}, UnreadOnly: ${unreadOnly}`);

    // Query notifications that are either 'all' or target this shop/user
    let query = `
      SELECT n.*, 
             COALESCE(nrs.is_read, 0) as is_read,
             COALESCE(nrs.read_at, NULL) as read_at,
             COUNT(*) OVER() as total_count
      FROM notifications n
      LEFT JOIN notification_read_status nrs 
        ON n.id = nrs.notification_id 
        AND nrs.user_id = ?
      WHERE n.is_active = 1
        AND (
          n.target_type = 'all' 
          OR (n.target_type = 'specific_shops' AND (n.shop_ids LIKE CONCAT('%', ?, '%')))
          OR (n.target_type = 'specific_users' AND (n.user_ids LIKE CONCAT('%', ?, '%')))
        )
        AND (n.scheduled_for IS NULL OR n.scheduled_for <= NOW())
        AND (n.expires_at IS NULL OR n.expires_at > NOW())
    `;

    const params = [userId, shopId, userId];

    if (unreadOnly === 'true') {
      query += ' AND (nrs.is_read = 0 OR nrs.is_read IS NULL)';
    }

    query += ` ORDER BY n.priority DESC, n.created_at DESC LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), offset);

    console.log(`[Notifications] Params:`, params);

    const [notifications] = await db.query(query, params);

    const total = notifications.length > 0 ? notifications[0].total_count : 0;

    console.log(`[Notifications] ✅ Found ${notifications.length} notifications for User ${userId}, Shop ${shopId}`);

    res.json({
      success: true,
      data: {
        notifications: notifications.map(notif => ({
          id: notif.id,
          title: notif.title,
          message: notif.message,
          imageUrl: notif.image_url,
          imagePath: notif.image_path,
          notificationType: notif.notification_type,
          priority: notif.priority,
          isRead: notif.is_read || false,
          readAt: notif.read_at,
          createdAt: notif.created_at,
          updatedAt: notif.updated_at
        })),
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit),
          unreadCount: notifications.filter(n => !n.is_read).length
        }
      }
    });
  } catch (error) {
    console.error('❌ Error fetching user notifications:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications',
      details: error.message
    });
  }
};

// ============================================
// USER - GET SINGLE NOTIFICATION DETAIL
// ============================================

/**
 * Get single notification with full details
 */
const getNotificationDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const shopId = req.shop_id || req.query.shop_id || 0;
    const userId = req.user?.id || 1;

    console.log(`[Notifications] Fetching detail for notification ${id}, user ${userId}, shop ${shopId}`);

    const [notifications] = await db.query(`
      SELECT n.*, 
             COALESCE(nrs.is_read, 0) as is_read, 
             COALESCE(nrs.read_at, NULL) as read_at
      FROM notifications n
      LEFT JOIN notification_read_status nrs 
        ON n.id = nrs.notification_id 
        AND nrs.user_id = ?
      WHERE n.id = ? 
        AND (
          n.target_type = 'all' 
          OR (n.target_type = 'specific_shops' AND (n.shop_ids LIKE CONCAT('%', ?, '%')))
          OR (n.target_type = 'specific_users' AND (n.user_ids LIKE CONCAT('%', ?, '%')))
        )
    `, [userId, id, shopId, userId]);

    if (!notifications || notifications.length === 0) {
      console.warn(`[Notifications] Notification ${id} not found for user ${userId}`);
      return res.status(404).json({
        success: false,
        error: 'Notification not found'
      });
    }

    const notification = notifications[0];

    // Mark as read using INSERT ... ON DUPLICATE KEY UPDATE
    if (!notification.is_read) {
      await db.query(
        `INSERT INTO notification_read_status (notification_id, shop_id, user_id, is_read, read_at)
         VALUES (?, ?, ?, 1, NOW())
         ON DUPLICATE KEY UPDATE is_read = 1, read_at = NOW()`,
        [id, shopId, userId]
      );
      console.log(`[Notifications] Marked notification ${id} as read for user ${userId}`);
    }

    res.json({
      success: true,
      data: {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        imageUrl: notification.image_url,
        imagePath: notification.image_path,
        notificationType: notification.notification_type,
        priority: notification.priority,
        isRead: true, // We just marked it as read
        createdAt: notification.created_at,
        updatedAt: notification.updated_at
      }
    });
  } catch (error) {
    console.error('Error fetching notification detail:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notification details'
    });
  }
};

// ============================================
// USER - MARK NOTIFICATION AS READ
// ============================================

/**
 * Mark notification as read
 */
const markNotificationAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    // Get shop_id from multiple sources: body, middleware, or query
    const shopId = req.body?.shop_id || req.shop_id || req.query.shop_id || 0;
    const userId = req.user?.id || 1;

    console.log(`[Notifications] Marking notification ${id} as read for User ${userId}, Shop ${shopId}`);

    // Use INSERT ... ON DUPLICATE KEY UPDATE to create record if it doesn't exist
    const [result] = await db.query(
      `INSERT INTO notification_read_status (notification_id, shop_id, user_id, is_read, read_at)
       VALUES (?, ?, ?, 1, NOW())
       ON DUPLICATE KEY UPDATE is_read = 1, read_at = NOW()`,
      [id, shopId, userId]
    );

    console.log(`[Notifications] ✅ Notification ${id} marked as read, affected rows: ${result.affectedRows}`);

    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to mark notification as read'
    });
  }
};

// ============================================
// USER - GET UNREAD COUNT
// ============================================

/**
 * Get unread notification count for current user
 */
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user?.id || 1;
    const shopId = req.user?.shop_id || req.query.shop_id || req.shop_id;

    console.log(`[Notifications] Fetching unread count for User ${userId}, Shop ${shopId}`);

    const [result] = await db.query(`
      SELECT COUNT(*) as unread_count
      FROM notifications n
      LEFT JOIN notification_read_status nrs 
        ON n.id = nrs.notification_id 
        AND nrs.user_id = ?
      WHERE n.is_active = 1
        AND (nrs.is_read = 0 OR nrs.is_read IS NULL)
        AND (
          n.target_type = 'all' 
          OR (n.target_type = 'specific_shops' AND (n.shop_ids LIKE CONCAT('%', ?, '%')))
          OR (n.target_type = 'specific_users' AND (n.user_ids LIKE CONCAT('%', ?, '%')))
        )
        AND (n.scheduled_for IS NULL OR n.scheduled_for <= NOW())
        AND (n.expires_at IS NULL OR n.expires_at > NOW())
    `, [userId, shopId, userId]);

    const unreadCount = result[0]?.unread_count || 0;
    console.log(`[Notifications] ✅ Unread count: ${unreadCount} for User ${userId}, Shop ${shopId}`);

    res.json({
      success: true,
      data: {
        unreadCount
      }
    });
  } catch (error) {
    console.error('❌ Error fetching unread count:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch unread count',
      details: error.message
    });
  }
};

// ============================================
// SUPER ADMIN - DELETE NOTIFICATION
// ============================================

/**
 * Delete/deactivate notification
 */
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.query(
      'UPDATE notifications SET is_active = 0 WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'Notification not found'
      });
    }

    // Broadcast deletion event via WebSocket
    try {
      websocketManager.broadcastNotification({
        id,
        type: 'notification_deleted',
        message: 'Notification has been deleted'
      }, {
        targetType: 'all'
      });
      console.log(`[Notifications] Broadcasted deletion of notification ${id} via WebSocket`);
    } catch (wsError) {
      console.error('[Notifications] WebSocket broadcast error:', wsError);
      // Don't fail the API call if WebSocket broadcast fails
    }

    res.json({
      success: true,
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete notification'
    });
  }
};

module.exports = {
  createNotification,
  getAllNotifications,
  getUserNotifications,
  getNotificationDetail,
  markNotificationAsRead,
  getUnreadCount,
  deleteNotification
};
