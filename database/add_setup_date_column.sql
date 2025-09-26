-- Add setup_date column to final_bill and order_items tables
-- Run these SQL commands to add the new setup_date column

-- Add setup_date column to final_bill table
ALTER TABLE final_bill 
ADD COLUMN setup_date DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Add setup_date column to order_items table  
ALTER TABLE order_items 
ADD COLUMN setup_date DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Optional: Update existing records with current timestamp if needed
-- UPDATE final_bill SET setup_date = NOW() WHERE setup_date IS NULL;
-- UPDATE order_items SET setup_date = NOW() WHERE setup_date IS NULL;

-- Verify the columns were added successfully
DESCRIBE final_bill;
DESCRIBE order_items;
