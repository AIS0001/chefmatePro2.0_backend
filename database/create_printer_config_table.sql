-- Printer Configuration Table for ESC/POS Management
-- Stores terminal/machine ID with printer IP for kitchen and cashier

CREATE TABLE IF NOT EXISTS `printer_config` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `terminal_id` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Machine/Terminal ID',
  `mac_address` VARCHAR(17) NULL COMMENT 'Machine MAC address (XX:XX:XX:XX:XX:XX)',
  `location` ENUM('kitchen', 'cashier') NOT NULL COMMENT 'Printer location type',
  `printer_ip` VARCHAR(20) NOT NULL COMMENT 'Printer IP address',
  `printer_port` INT DEFAULT 9100 COMMENT 'Printer port for ESC/POS (default: 9100)',
  `printer_name` VARCHAR(100) COMMENT 'Friendly name for the printer',
  `status` ENUM('active', 'inactive') DEFAULT 'active' COMMENT 'Printer configuration status',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_location` (`location`),
  INDEX `idx_terminal_id` (`terminal_id`),
  INDEX `idx_mac_address` (`mac_address`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add sample data (optional)
-- INSERT INTO printer_config (terminal_id, location, printer_ip, printer_port, printer_name, status) 
-- VALUES 
-- ('KITCHEN-001', 'kitchen', '192.168.1.100', 9100, 'Kitchen Printer 1', 'active'),
-- ('CASHIER-001', 'cashier', '192.168.1.101', 9100, 'Cashier Printer 1', 'active');
