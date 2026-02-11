ALTER TABLE day_close_summary
  ADD COLUMN entertainment_sales DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER online_sales;
