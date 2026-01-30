-- Add test stock data for Black Label (Item ID 1)
-- This script adds inventory to stock_balance table so stock deduction can work

-- First, verify the product and unit exist
SELECT 'Verifying Item 1 (Black Label)' as status;
SELECT id, name, isstockable FROM items WHERE id = 1;

SELECT 'Verifying Unit 3 (3-Liter)' as status;
SELECT id, product_id, unit_name, ml_capacity FROM product_units WHERE id = 3 AND product_id = 1;

-- Add stock balance for Black Label in 3-Liter unit
-- If record exists, update it; otherwise insert
INSERT INTO stock_balance (product_id, unit_id, current_quantity, available_quantity, last_updated)
VALUES (1, 3, 100, 100, NOW())
ON DUPLICATE KEY UPDATE 
  current_quantity = 100,
  available_quantity = 100,
  last_updated = NOW();

-- Verify the stock was added
SELECT 'Final Stock Balance for Item 1, Unit 3' as status;
SELECT product_id, unit_id, current_quantity, available_quantity, last_updated 
FROM stock_balance 
WHERE product_id = 1 AND unit_id = 3;

-- Also add stock for other common units of Black Label if they exist
INSERT INTO stock_balance (product_id, unit_id, current_quantity, available_quantity, last_updated)
SELECT 1, id, 50, 50, NOW() FROM product_units WHERE product_id = 1
ON DUPLICATE KEY UPDATE 
  current_quantity = 50,
  available_quantity = 50,
  last_updated = NOW();

SELECT 'All stock balances for Item 1' as status;
SELECT sb.product_id, sb.unit_id, pu.unit_name, sb.current_quantity, sb.available_quantity 
FROM stock_balance sb
JOIN product_units pu ON sb.unit_id = pu.id
WHERE sb.product_id = 1
ORDER BY pu.ml_capacity DESC;
