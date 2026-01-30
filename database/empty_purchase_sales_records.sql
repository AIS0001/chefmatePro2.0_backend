-- Clear all purchase and sale related records

-- 1. Clear purchase order items
DELETE FROM `purchase_items`;
ALTER TABLE `purchase_items` AUTO_INCREMENT = 1;

-- 2. Clear purchase orders
DELETE FROM `purchase_orders`;
ALTER TABLE `purchase_orders` AUTO_INCREMENT = 1;

-- 3. Clear purchase payments
DELETE FROM `purchase_payments`;
ALTER TABLE `purchase_payments` AUTO_INCREMENT = 1;

-- 4. Clear final bills (sales)
DELETE FROM `final_bill`;
ALTER TABLE `final_bill` AUTO_INCREMENT = 1;

-- 5. Clear advance final bills
DELETE FROM `advance_final_bill`;
ALTER TABLE `advance_final_bill` AUTO_INCREMENT = 1;

-- 6. Clear orders
DELETE FROM `orders`;
ALTER TABLE `orders` AUTO_INCREMENT = 1;

-- 7. Clear order items
DELETE FROM `order_items`;
ALTER TABLE `order_items` AUTO_INCREMENT = 1;

-- 8. Clear order items GST
DELETE FROM `order_items_gst`;
ALTER TABLE `order_items_gst` AUTO_INCREMENT = 1;

-- 9. Clear advance orders
DELETE FROM `advance_orders`;
ALTER TABLE `advance_orders` AUTO_INCREMENT = 1;

-- 10. Clear advance order items
DELETE FROM `advance_order_items`;
ALTER TABLE `advance_order_items` AUTO_INCREMENT = 1;

-- 11. Clear advance order items GST
DELETE FROM `advance_order_items_gst`;
ALTER TABLE `advance_order_items_gst` AUTO_INCREMENT = 1;

-- 12. Clear payment transactions
DELETE FROM `payment_transactions`;
ALTER TABLE `payment_transactions` AUTO_INCREMENT = 1;

-- 13. Clear SCB payments
DELETE FROM `scb_payments`;
ALTER TABLE `scb_payments` AUTO_INCREMENT = 1;

-- 14. Clear kiosk queue
DELETE FROM `kiosk_queue`;
ALTER TABLE `kiosk_queue` AUTO_INCREMENT = 1;

-- 15. Clear day close summary
DELETE FROM `day_close_summary`;
ALTER TABLE `day_close_summary` AUTO_INCREMENT = 1;

-- 16. Clear quotations
DELETE FROM `quotations`;
ALTER TABLE `quotations` AUTO_INCREMENT = 1;

-- 17. Clear quotation items
DELETE FROM `quotation_items`;
ALTER TABLE `quotation_items` AUTO_INCREMENT = 1;

-- 18. Clear quotation history
DELETE FROM `quotation_history`;
ALTER TABLE `quotation_history` AUTO_INCREMENT = 1;

-- 19. Clear receipt vouchers
DELETE FROM `receipt_vouchers`;
ALTER TABLE `receipt_vouchers` AUTO_INCREMENT = 1;

-- 20. Clear payment vouchers
DELETE FROM `payment_vouchers`;
ALTER TABLE `payment_vouchers` AUTO_INCREMENT = 1;

-- 21. Clear inventory
DELETE FROM `inventory`;
ALTER TABLE `inventory` AUTO_INCREMENT = 1;

-- 22. Clear cash drawer
DELETE FROM `cash_drawer`;
ALTER TABLE `cash_drawer` AUTO_INCREMENT = 1;

-- 23. Clear items
DELETE FROM `items`;
ALTER TABLE `items` AUTO_INCREMENT = 1;

-- 24. Clear item images
DELETE FROM `item_images`;
ALTER TABLE `item_images` AUTO_INCREMENT = 1;

-- 25. Clear product units
DELETE FROM `product_units`;
ALTER TABLE `product_units` AUTO_INCREMENT = 1;
