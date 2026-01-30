-- Add stock balance entries for Black Label serving units
-- This allows deduction from individual pegs while tracking bottle inventory

-- Add 60ML Peg stock (unit_id 3)
-- 12 bottles × 750ML = 9000ML total
-- 9000ML ÷ 60ML = 150 pegs available
INSERT INTO stock_balance (product_id, unit_id, current_quantity, reserved_quantity, last_updated)
VALUES (1, 3, 150, 0, NOW())
ON DUPLICATE KEY UPDATE 
  current_quantity = 150,
  reserved_quantity = 0,
  last_updated = NOW();

-- Add 30ML Peg stock (unit_id 2)
-- 9000ML ÷ 30ML = 300 pegs available
INSERT INTO stock_balance (product_id, unit_id, current_quantity, reserved_quantity, last_updated)
VALUES (1, 2, 300, 0, NOW())
ON DUPLICATE KEY UPDATE 
  current_quantity = 300,
  reserved_quantity = 0,
  last_updated = NOW();

-- Add 90ML Large Peg stock (unit_id 4)
-- 9000ML ÷ 90ML = 100 pegs available
INSERT INTO stock_balance (product_id, unit_id, current_quantity, reserved_quantity, last_updated)
VALUES (1, 4, 100, 0, NOW())
ON DUPLICATE KEY UPDATE 
  current_quantity = 100,
  reserved_quantity = 0,
  last_updated = NOW();

-- Verify all stock balances
SELECT 
  sb.product_id,
  sb.unit_id,
  pu.unit_name,
  pu.ml_capacity,
  sb.current_quantity,
  sb.available_quantity,
  CONCAT(sb.current_quantity, ' × ', pu.ml_capacity, 'ML = ', sb.current_quantity * pu.ml_capacity, 'ML') as total_ml
FROM stock_balance sb
JOIN product_units pu ON sb.unit_id = pu.id
WHERE sb.product_id = 1
ORDER BY pu.ml_capacity DESC;
