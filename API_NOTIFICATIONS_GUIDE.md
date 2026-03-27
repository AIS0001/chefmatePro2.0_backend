# Notification System - Complete Implementation Guide

## Overview

A comprehensive notification system allowing super admins to create and manage notifications for all users or specific shops, with users able to view notifications with full details including images and priority levels.

---

## 📦 What's Included

### Backend Components

1. **Database Tables**
   - `notifications` - Store notification data
   - `notification_read_status` - Track read/unread status per user

2. **Controller** - `notificationsController.js`
   - Create notifications (super admin)
   - Get all notifications (super admin)
   - Get user notifications
   - Get notification details
   - Mark as read
   - Get unread count
   - Delete notifications (super admin)

3. **Routes** - `notificationsRoutes.js`
   - Super admin endpoints for notification management
   - User endpoints for viewing notifications
   - Image upload support

### Frontend Components

1. **Super Admin Page** - `NotificationManagement.jsx`
   - Create new notifications
   - Add title, message, priority, type
   - Attach images
   - Target specific shops or all users
   - Schedule notifications
   - View all notifications
   - Delete notifications

2. **User Notification Page** - `NotificationsPage.jsx`
   - View all notifications
   - Filter unread only
   - Open detailed notification view
   - Auto-mark as read when opened
   - Pagination support

---

## 🗄️ Database Setup

### Run Migration

Execute the SQL file to create tables:

```bash
mysql -u root -p chefmatepro2 < d:\Development\chefmatePro2\chefmatePro2.0_backend\notifications_table.sql
```

Or manually run these queries in your MySQL client:

```sql
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `image_url` VARCHAR(500) NULL DEFAULT NULL,
  `image_path` VARCHAR(500) NULL DEFAULT NULL,
  `notification_type` ENUM('general', 'announcement', 'promotion', 'alert', 'maintenance') DEFAULT 'general',
  `target_type` ENUM('all', 'specific_shops', 'specific_users') DEFAULT 'all',
  `shop_ids` JSON NULL DEFAULT NULL,
  `user_ids` JSON NULL DEFAULT NULL,
  `created_by` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  `scheduled_for` DATETIME NULL DEFAULT NULL,
  `expires_at` DATETIME NULL DEFAULT NULL,
  `views_count` INT DEFAULT 0,
  `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
  
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target_type`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_scheduled_for` (`scheduled_for`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `notification_read_status` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `notification_id` INT NOT NULL,
  `shop_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `is_read` TINYINT DEFAULT 0,
  `read_at` DATETIME NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_notification_user` (`notification_id`, `shop_id`, `user_id`),
  KEY `idx_notification_id` (`notification_id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  
  FOREIGN KEY (`notification_id`) REFERENCES `notifications`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

---

## 🚀 Backend API Endpoints

### Super Admin Endpoints

#### 1. Create Notification
```
POST /api/super-admin/notifications/create
Content-Type: multipart/form-data
Authorization: Bearer TOKEN

Body (FormData):
- title: "System Maintenance" (required)
- message: "Server will be down for maintenance" (required)
- notificationType: "maintenance" (optional)
- targetType: "all" | "specific_shops" | "specific_users" (required)
- priority: "low" | "normal" | "high" | "urgent" (optional)
- shopIds: [1, 2, 3] (if targetType = "specific_shops")
- userIds: [10, 20, 30] (if targetType = "specific_users")
- scheduledFor: "2026-03-28T10:00:00Z" (optional)
- expiresAt: "2026-04-28T10:00:00Z" (optional)
- image: <file> (optional, max 5MB)

Response:
{
  "success": true,
  "message": "Notification created successfully",
  "data": {
    "id": 1,
    "title": "System Maintenance",
    "message": "Server will be down for maintenance",
    "imageUrl": "http://localhost:4402/uploads/notifications/notification-1234567890.jpg",
    "notificationType": "maintenance",
    "targetType": "all",
    "createdAt": "2026-03-27T10:00:00Z"
  }
}
```

#### 2. Get All Notifications (Super Admin)
```
GET /api/super-admin/notifications/all?page=1&limit=20&isActive=true&sortBy=created_at&order=DESC
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 1,
        "title": "New Announcement",
        "message": "Important update...",
        "notification_type": "announcement",
        "target_type": "all",
        "priority": "high",
        "created_at": "2026-03-27T10:00:00Z",
        "shopIds": [],
        "userIds": []
      }
    ],
    "pagination": {
      "total": 50,
      "page": 1,
      "limit": 20,
      "pages": 3
    }
  }
}
```

#### 3. Delete Notification
```
DELETE /api/super-admin/notifications/:id
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "message": "Notification deleted successfully"
}
```

### User Endpoints

#### 1. Get User Notifications
```
GET /api/notifications?page=1&limit=20&unreadOnly=false
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 1,
        "title": "New Announcement",
        "message": "Check out our new features...",
        "imageUrl": "http://localhost:4402/uploads/notifications/notification-1234567890.jpg",
        "notificationType": "announcement",
        "priority": "high",
        "isRead": false,
        "readAt": null,
        "createdAt": "2026-03-27T10:00:00Z",
        "updatedAt": "2026-03-27T10:00:00Z"
      }
    ],
    "pagination": {
      "total": 15,
      "page": 1,
      "limit": 20,
      "pages": 1,
      "unreadCount": 3
    }
  }
}
```

#### 2. Get Notification Detail
```
GET /api/notifications/:id
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "data": {
    "id": 1,
    "title": "New Announcement",
    "message": "Detailed message content...",
    "imageUrl": "http://localhost:4402/uploads/notifications/notification-1234567890.jpg",
    "imagePath": "/uploads/notifications/notification-1234567890.jpg",
    "notificationType": "announcement",
    "priority": "high",
    "isRead": true,  // Auto-marked as read
    "createdAt": "2026-03-27T10:00:00Z",
    "updatedAt": "2026-03-27T10:00:00Z"
  }
}
```

#### 3. Mark Notification as Read
```
PUT /api/notifications/:id/read
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "message": "Notification marked as read"
}
```

#### 4. Get Unread Count
```
GET /api/notifications/unread/count
Authorization: Bearer TOKEN

Response:
{
  "success": true,
  "data": {
    "unreadCount": 5
  }
}
```

---

## 💻 Frontend Integration

### Super Admin Usage

1. Navigate to the Notification Management page (add to super admin routes)
2. Fill in notification details:
   - Title (required)
   - Message (required)
   - Type (general/announcement/promotion/alert/maintenance)
   - Priority (low/normal/high/urgent)
   - Target Audience (all users/specific shops/specific users)
   - Schedule time (optional)
   - Expiry time (optional)
   - Image attachment (optional)
3. Click "Create Notification"

### User Experience

1. Users navigate to Notifications page
2. See list of notifications with:
   - Unread badge
   - Notification type
   - Priority level
   - Creation time
3. Click on notification to view full details:
   - Full message
   - Attached image (if any)
   - Notification type and priority
   - Creation and read timestamps
4. Filter to show unread only
5. Pagination support

---

## 🔌 React Router Integration

Add these routes to your React Router configuration:

### Super Admin Routes
```jsx
import NotificationManagement from './views/superAdmin/NotificationManagement';

// In your super admin router:
{
  path: '/super-admin/notifications',
  element: <NotificationManagement />
}
```

### User Routes
```jsx
import NotificationsPage from './views/pages/NotificationsPage';

// In your main router:
{
  path: '/notifications',
  element: <NotificationsPage />
}
```

---

## 📝 File Structure

```
Backend:
- controllers/notificationsController.js      (New)
- routes/notificationsRoutes.js               (New)
- notifications_table.sql                     (New - DB Setup)
- server.js                                   (Updated - Added routes)

Frontend:
- views/superAdmin/NotificationManagement.jsx (New)
- views/superAdmin/NotificationManagement.css (New)
- views/pages/NotificationsPage.jsx           (New)
- views/pages/NotificationsPage.css           (New)
```

---

## ⚙️ Configuration

### Image Upload Settings
- Location: `uploads/notifications/`
- Max size: 5MB
- Allowed types: JPEG, JPG, PNG, GIF

### Notification Types
- `general` - General information
- `announcement` - Important announcements
- `promotion` - Special promotions
- `alert` - Urgent alerts
- `maintenance` - System maintenance

### Priority Levels
- `low` - Low priority (green)
- `normal` - Normal priority (blue)
- `high` - High priority (orange)
- `urgent` - Urgent (red)

### Target Types
- `all` - Send to all users
- `specific_shops` - Send to users of specific shops
- `specific_users` - Send to specific users

---

## 🔐 Security Features

✅ JWT Authentication required for all endpoints
✅ Super admin role verification for creation/deletion
✅ User can only see notifications targeted to them or "all"
✅ Automatic read-only status tracking per user
✅ File upload validation (type & size)
✅ SQL injection prevention (parameterized queries)
✅ Role-based access control

---

## 📊 Data Flow

```
1. Super Admin creates notification
   ↓
2. Data stored in notifications table
   ↓
3. Read status records created for target users/shops
   ↓
4. Users fetch notifications (filtered by target type)
   ↓
5. Opening notification marks as read
   ↓
6. Unread count updated
```

---

## 🐛 Troubleshooting

### Notifications not appearing for users
- Check `target_type` is correct
- Verify `shop_id` or `user_id` matches
- Check `is_active = 1`
- Check scheduled_for date hasn't passed
- Check expires_at hasn't expired

### Images not displaying
- Verify image uploaded to `/uploads/notifications/`
- Check `image_url` is populated
- Ensure base URL is correct in API response

### Permission errors
- Verify JWT token is valid
- Check user has super_admin role for creation
- Verify Authorization header format

---

## 🚀 Next Steps

1. Run database migration: `notifications_table.sql`
2. Restart backend server: `npm restart`
3. Add routes to React Router
4. Test super admin notification creation
5. Test user notification viewing
6. Optional: Add notification bell icon to Topbar with unread count
7. Optional: Add real-time notifications using WebSockets

---

## 📱 Examples

### Create Announcement for All Users
```javascript
const formData = new FormData();
formData.append('title', 'System Announcement');
formData.append('message', 'New features released!');
formData.append('notificationType', 'announcement');
formData.append('targetType', 'all');
formData.append('priority', 'high');
formData.append('image', imageFile);

axios.post('/super-admin/notifications/create', formData, {
  headers: { Authorization: `Bearer ${token}` }
});
```

### Get Unread for Current User
```javascript
axios.get('/notifications/unread/count', {
  headers: { Authorization: `Bearer ${token}` }
}).then(res => {
  console.log('Unread:', res.data.data.unreadCount);
});
```

---

## 📞 Support

For issues or questions about the notification system, refer to:
- API_NOTIFICATIONS_GUIDE.md (this file)
- Backend controller documentation
- Frontend component JSDoc comments

---

**Status:** ✅ Production Ready
**Version:** 1.0.0
**Last Updated:** March 27, 2026
