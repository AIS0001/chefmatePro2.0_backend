-- Fix day_close_summary UNIQUE KEY to be composite (shop_id, close_date)
-- This allows multiple shops to close on the same date (multi-tenant fix)

-- Drop the old single-column unique key on close_date
ALTER TABLE `day_close_summary` DROP INDEX `close_date`;

-- Add composite unique key on (shop_id, close_date)
ALTER TABLE `day_close_summary` ADD UNIQUE KEY `uq_shop_close_date` (`shop_id`, `close_date`);
