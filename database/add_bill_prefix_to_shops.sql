-- ======================================================================
-- ADD BILL_PREFIX TO SHOPS
-- Superadmin-managed bill series prefix per shop.
-- ======================================================================

ALTER TABLE `shops`
ADD COLUMN `bill_prefix` VARCHAR(10) NULL AFTER `shop_code`;

UPDATE `shops`
SET `bill_prefix` = CASE
  WHEN `id` = 1 THEN 'DEF'
  WHEN `id` = 2 THEN 'TVW'
  ELSE UPPER(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(`shop_code`, '-', ''), '_', ''), ' ', ''), '.', ''), 10))
END
WHERE `bill_prefix` IS NULL OR `bill_prefix` = '';

ALTER TABLE `shops`
MODIFY COLUMN `bill_prefix` VARCHAR(10) NOT NULL;

ALTER TABLE `shops`
ADD UNIQUE KEY `uk_shops_bill_prefix` (`bill_prefix`);

-- Optional verification
-- SELECT id, name, shop_code, bill_prefix FROM shops ORDER BY id;