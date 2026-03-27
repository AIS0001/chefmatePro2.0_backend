-- Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `image_url` VARCHAR(500) NULL DEFAULT NULL,
  `image_path` VARCHAR(500) NULL DEFAULT NULL,
  `notification_type` ENUM('general', 'announcement', 'promotion', 'alert', 'maintenance') DEFAULT 'general',
  `target_type` ENUM('all', 'specific_shops', 'specific_users') DEFAULT 'all',
  `shop_ids` JSON NULL DEFAULT NULL COMMENT 'Array of shop_ids for specific shops',
  `user_ids` JSON NULL DEFAULT NULL COMMENT 'Array of user_ids for specific users',
  `created_by` INT NOT NULL COMMENT 'Super admin user ID who created this',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  `scheduled_for` DATETIME NULL DEFAULT NULL COMMENT 'Schedule notification for future time',
  `expires_at` DATETIME NULL DEFAULT NULL COMMENT 'When notification expires/becomes inactive',
  `views_count` INT DEFAULT 0,
  `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
  
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target_type`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_scheduled_for` (`scheduled_for`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Notifications Read Status (track which users have read which notifications)
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
