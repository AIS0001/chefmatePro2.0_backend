-- Populate stock_conversions table for all products with units

-- For each product, calculate conversion factors between all unit pairs
-- Conversion formula: conversion_factor = from_unit.conversion_factor / to_unit.conversion_factor

-- Get all products with multiple units
SET @product_id = 1;
SET @product_id_2 = 2;

-- Clear existing conversions (optional - comment out to keep history)
-- DELETE FROM stock_conversions;

-- Get all units for product 1 and create conversions
INSERT INTO stock_conversions (product_id, from_unit_id, to_unit_id, conversion_factor, is_active)
SELECT DISTINCT
  pu1.product_id,
  pu1.id as from_unit_id,
  pu2.id as to_unit_id,
  ROUND(pu1.conversion_factor / pu2.conversion_factor, 4) as conversion_factor,
  1 as is_active
FROM product_units pu1
CROSS JOIN product_units pu2
WHERE pu1.product_id = 1
  AND pu2.product_id = 1
  AND pu1.id != pu2.id
ON DUPLICATE KEY UPDATE
  conversion_factor = VALUES(conversion_factor),
  is_active = 1;

-- Get all units for product 2 and create conversions
INSERT INTO stock_conversions (product_id, from_unit_id, to_unit_id, conversion_factor, is_active)
SELECT DISTINCT
  pu1.product_id,
  pu1.id as from_unit_id,
  pu2.id as to_unit_id,
  ROUND(pu1.conversion_factor / pu2.conversion_factor, 4) as conversion_factor,
  1 as is_active
FROM product_units pu1
CROSS JOIN product_units pu2
WHERE pu1.product_id = 2
  AND pu2.product_id = 2
  AND pu1.id != pu2.id
ON DUPLICATE KEY UPDATE
  conversion_factor = VALUES(conversion_factor),
  is_active = 1;

-- Verify conversions were created
SELECT 'Stock Conversions for Product 1 (Black Label)' as title;
SELECT 
  sc.product_id,
  pu1.unit_name as from_unit,
  pu2.unit_name as to_unit,
  sc.conversion_factor,
  CONCAT('1 ', pu1.unit_name, ' = ', sc.conversion_factor, ' ', pu2.unit_name) as description
FROM stock_conversions sc
JOIN product_units pu1 ON sc.from_unit_id = pu1.id
JOIN product_units pu2 ON sc.to_unit_id = pu2.id
WHERE sc.product_id = 1
ORDER BY pu1.unit_name, pu2.unit_name;

SELECT 'Stock Conversions for Product 2 (Gold Label)' as title;
SELECT 
  sc.product_id,
  pu1.unit_name as from_unit,
  pu2.unit_name as to_unit,
  sc.conversion_factor,
  CONCAT('1 ', pu1.unit_name, ' = ', sc.conversion_factor, ' ', pu2.unit_name) as description
FROM stock_conversions sc
JOIN product_units pu1 ON sc.from_unit_id = pu1.id
JOIN product_units pu2 ON sc.to_unit_id = pu2.id
WHERE sc.product_id = 2
ORDER BY pu1.unit_name, pu2.unit_name;

SELECT 'Total conversions created:' as status;
SELECT COUNT(*) as conversion_count FROM stock_conversions;
