-- Add UUID column to users table
-- This column will store a unique identifier for each user
-- Generated on first login, remains NULL until first login

ALTER TABLE `users` 
ADD COLUMN `user_uuid` VARCHAR(36) NULL DEFAULT NULL 
AFTER `id`,
ADD INDEX `idx_user_uuid` (`user_uuid`);

-- Optional: Add comment to the column
ALTER TABLE `users` 
MODIFY COLUMN `user_uuid` VARCHAR(36) NULL DEFAULT NULL 
COMMENT 'Unique identifier generated on first login';
