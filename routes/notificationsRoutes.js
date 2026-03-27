const express = require('express');
const router = express.Router();
const { isAuthorize } = require('../middleware/auth');
const { isSuperAdmin } = require('../middleware/superAdminAuth');
const multer = require('multer');
const path = require('path');
const notificationsController = require('../controllers/notificationsController');
const websocketManager = require('../helpers/websocketManager');

// Multer setup for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/notifications');
    require('fs').mkdirSync(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'notification-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

/**
 * SUPER ADMIN ROUTES
 */

/**
 * Create Notification
 * POST /api/super-admin/notifications/create
 * Body: { title, message, notificationType, targetType, shopIds[], userIds[], priority, scheduledFor, expiresAt }
 * Files: image (optional)
 */
router.post(
  '/create',
  isAuthorize,
  isSuperAdmin,
  upload.single('image'),
  notificationsController.createNotification
);

/**
 * Get All Notifications (Super Admin)
 * GET /api/super-admin/notifications/all
 * Query: page, limit, isActive, sortBy, order
 */
router.get(
  '/all',
  isAuthorize,
  isSuperAdmin,
  notificationsController.getAllNotifications
);

/**
 * Delete/Deactivate Notification
 * DELETE /api/super-admin/notifications/:id
 */
router.delete(
  '/:id',
  isAuthorize,
  isSuperAdmin,
  notificationsController.deleteNotification
);

/**
 * USER ROUTES
 */

/**
 * Get Unread Count (MUST come before /:id route!)
 * GET /api/notifications/unread/count
 */
router.get(
  '/unread/count',
  isAuthorize,
  notificationsController.getUnreadCount
);

/**
 * Get WebSocket Connection Stats (also specific, must come before /:id)
 * GET /api/notifications/ws/stats
 * Requires authorization
 */
router.get(
  '/ws/stats',
  isAuthorize,
  (req, res) => {
    try {
      const stats = websocketManager.getStats();
      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error fetching WebSocket stats:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch WebSocket stats'
      });
    }
  }
);

/**
 * Mark Notification as Read (specific with /read, must come before /:id)
 * PUT /api/notifications/:id/read
 */
router.put(
  '/:id/read',
  isAuthorize,
  notificationsController.markNotificationAsRead
);

/**
 * Get User Notifications
 * GET /api/notifications
 * Query: page, limit, unreadOnly
 */
router.get(
  '/',
  isAuthorize,
  notificationsController.getUserNotifications
);

/**
 * Get Notification Detail (generic :id - must come last!)
 * GET /api/notifications/:id
 * Automatically marks as read
 */
router.get(
  '/:id',
  isAuthorize,
  notificationsController.getNotificationDetail
);

module.exports = router;
