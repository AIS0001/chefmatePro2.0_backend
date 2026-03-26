-- Add item_group column to order_items if it doesn't exist
-- Run this migration to fix the "Unknown column 'item_group'" error

-- For order_items table
ALTER TABLE order_items 
ADD COLUMN item_group VARCHAR(20) NULL 
AFTER item_name;

-- Verify the columns
DESCRIBE order_items;
