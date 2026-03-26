-- Add MAC address column to printer_config table
-- This enables automatic printer detection based on client machine MAC address

ALTER TABLE `printer_config` 
ADD COLUMN `mac_address` VARCHAR(17) NULL COMMENT 'Machine MAC address (XX:XX:XX:XX:XX:XX)' AFTER `terminal_id`,
ADD INDEX `idx_mac_address` (`mac_address`);

-- Optional: Add comment to explain the column purpose
ALTER TABLE `printer_config` 
MODIFY COLUMN `mac_address` VARCHAR(17) NULL COMMENT 'Machine MAC address for auto-detection (XX:XX:XX:XX:XX:XX format)';
