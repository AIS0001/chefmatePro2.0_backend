-- ======================================================================
-- ADD INV_NUMBER TO FINAL_BILL
-- Keeps final_bill aligned with orders.invoice_number and order_items.invoice_number
-- ======================================================================

ALTER TABLE `final_bill`
ADD COLUMN `inv_number` VARCHAR(255) NULL AFTER `customer_id`;

CREATE INDEX `idx_final_bill_inv_number` ON `final_bill` (`shop_id`, `inv_number`);

-- Backfill existing rows.
-- Where running orders already have an invoice_number, reuse that value.
-- Otherwise default to the bill id as a string, which matches the current POS flow.
UPDATE `final_bill` fb
LEFT JOIN (
  SELECT
    `shop_id`,
    `invoice_number`,
    CAST(`invoice_number` AS UNSIGNED) AS `bill_id`
  FROM `order_items`
  WHERE `invoice_number` IS NOT NULL
    AND `invoice_number` <> ''
  GROUP BY `shop_id`, `invoice_number`
) oi
  ON oi.`shop_id` = fb.`shop_id`
 AND oi.`bill_id` = fb.`id`
SET fb.`inv_number` = COALESCE(NULLIF(oi.`invoice_number`, ''), CAST(fb.`id` AS CHAR))
WHERE fb.`inv_number` IS NULL
   OR fb.`inv_number` = '';

-- Optional verification
-- SELECT fb.id, fb.inv_number, o.invoice_number AS order_invoice, oi.invoice_number AS item_invoice
-- FROM final_bill fb
-- LEFT JOIN orders o ON o.shop_id = fb.shop_id AND o.invoice_number = fb.inv_number
-- LEFT JOIN order_items oi ON oi.shop_id = fb.shop_id AND oi.invoice_number = fb.inv_number
-- ORDER BY fb.id DESC;