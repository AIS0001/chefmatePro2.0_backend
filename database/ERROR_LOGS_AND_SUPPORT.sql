-- ============================================================
-- ERROR LOGS TABLE - Track all system errors per shop
-- ============================================================

CREATE TABLE IF NOT EXISTS `error_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `error_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., DATABASE, API, VALIDATION, PAYMENT, PRINTER, etc.',
  `error_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_stack` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Full stack trace',
  `module` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Module where error occurred',
  `route` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'GET, POST, etc.',
  `query_params` json DEFAULT NULL,
  `request_body` json DEFAULT NULL COMMENT 'First 500 chars of body',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `status` enum('OPEN','ACKNOWLEDGED','RESOLVED','IGNORED') COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `resolved_at` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Admin notes',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_error_type` (`error_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shop_error_status` (`shop_id`, `status`, `created_at`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System error logs tracked per shop';

-- ============================================================
-- SUPPORT TICKETS TABLE - Track shop support issues
-- ============================================================

CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `ticket_number` varchar(50) COLLATE utf8mb4_unicode_ci UNIQUE NOT NULL COMMENT 'AUTO-GENERATED: TICKET-SHOPID-YYYYMMDD-XXXX',
  `user_id` int DEFAULT NULL COMMENT 'User who created ticket',
  `assigned_to` int DEFAULT NULL COMMENT 'Admin user assigned',
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., BILLING, TECHNICAL, FEATURE_REQUEST, PAYMENT, PRINTER, INVENTORY, OTHER',
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `status` enum('OPEN','IN_PROGRESS','PENDING_CUSTOMER','ON_HOLD','RESOLVED','CLOSED') COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `error_log_id` int DEFAULT NULL COMMENT 'Link to related error log',
  `notes` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Internal support notes',
  `resolution` text COLLATE utf8mb4_unicode_ci COMMENT 'How issue was resolved',
  `created_by` int DEFAULT NULL COMMENT 'Super admin user creating this ticket',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_ticket_number` (`ticket_number`),
  KEY `idx_shop_id` (`shop_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_shop_status` (`shop_id`, `status`, `created_at`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`error_log_id`) REFERENCES `error_logs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Support tickets for shop issues';

-- ============================================================
-- SUPPORT TICKET COMMENTS TABLE - Track ticket conversations
-- ============================================================

CREATE TABLE IF NOT EXISTS `support_ticket_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'Super admin or shop user',
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_internal` tinyint(1) DEFAULT 0 COMMENT '1 = visible only to admins, 0 = visible to shop',
  `attachment_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Comments and discussion on support tickets';

-- ============================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================

-- Insert sample error log
INSERT INTO `error_logs` (shop_id, error_type, error_message, module, severity, status) 
VALUES 
(1, 'DATABASE', 'Database connection timeout', 'Payment Module', 'HIGH', 'OPEN'),
(1, 'API', 'Payment gateway API returned 500 error', 'Payment Module', 'CRITICAL', 'RESOLVED'),
(2, 'PRINTER', 'Printer not responding', 'Printer Config', 'MEDIUM', 'OPEN');

-- Insert sample support ticket
INSERT INTO `support_tickets` (shop_id, ticket_number, category, subject, description, priority, status) 
VALUES 
(1, 'TICKET-1-20260327-0001', 'TECHNICAL', 'Printer Connection Lost', 'Thermal printer not connecting after power outage', 'HIGH', 'OPEN'),
(1, 'TICKET-1-20260327-0002', 'BILLING', 'Subscription Query', 'Need to upgrade plan to higher tier', 'MEDIUM', 'PENDING_CUSTOMER');
