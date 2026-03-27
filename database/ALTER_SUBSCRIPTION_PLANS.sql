-- ============================================================
-- ALTER TABLE - SUBSCRIPTION PLANS ENHANCEMENTS
-- Add additional columns to subscription_plans table
-- ============================================================

-- Add quarterly pricing column
ALTER TABLE `subscription_plans` 
ADD COLUMN `quarterly_price` decimal(10,2) DEFAULT NULL AFTER `price_per_month`;

-- Add yearly pricing column
ALTER TABLE `subscription_plans`
ADD COLUMN `yearly_price` decimal(10,2) DEFAULT NULL AFTER `quarterly_price`;

-- Add supported payment methods
ALTER TABLE `subscription_plans`
ADD COLUMN `payment_methods_allowed` json DEFAULT NULL COMMENT 'JSON array of allowed payment methods' AFTER `features`;

-- Add setup fee
ALTER TABLE `subscription_plans`
ADD COLUMN `setup_fee` decimal(10,2) DEFAULT 0.00 COMMENT 'One-time setup fee' AFTER `storage_quota_gb`;

-- Add support level
ALTER TABLE `subscription_plans`
ADD COLUMN `support_level` enum('BASIC','STANDARD','PREMIUM','24_7') DEFAULT 'BASIC' COMMENT 'Level of support included' AFTER `payment_methods_allowed`;

-- Add trial period in days
ALTER TABLE `subscription_plans`
ADD COLUMN `trial_days` int DEFAULT 0 COMMENT 'Free trial period in days' AFTER `support_level`;

-- Add cancellation policy
ALTER TABLE `subscription_plans`
ADD COLUMN `cancellation_policy` text COMMENT 'Cancellation terms and conditions' AFTER `trial_days`;

-- Add billing cycle
ALTER TABLE `subscription_plans`
ADD COLUMN `billing_cycle` enum('DAILY','WEEKLY','MONTHLY','QUARTERLY','YEARLY') DEFAULT 'MONTHLY' AFTER `cancellation_policy`;

-- Add visibility flag
ALTER TABLE `subscription_plans`
ADD COLUMN `visible_to_customers` tinyint(1) DEFAULT 1 COMMENT 'Whether this plan is visible to customers' AFTER `is_active`;

-- Add tier level for sorting
ALTER TABLE `subscription_plans`
ADD COLUMN `tier_level` int DEFAULT 0 COMMENT 'Tier level for sorting (0=basic, 1=pro, 2=enterprise)' AFTER `visible_to_customers`;

-- Add discount percentage
ALTER TABLE `subscription_plans`
ADD COLUMN `discount_percentage` decimal(5,2) DEFAULT 0.00 COMMENT 'Bulk or promotional discount percentage' AFTER `tier_level`;

-- Add maximum discount amount
ALTER TABLE `subscription_plans`
ADD COLUMN `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT 'Maximum discount that can be applied' AFTER `discount_percentage`;

-- Add refund policy days
ALTER TABLE `subscription_plans`
ADD COLUMN `refund_policy_days` int DEFAULT 30 COMMENT 'Number of days for refund eligibility' AFTER `max_discount_amount`;

-- Add contract period minimum (in months)
ALTER TABLE `subscription_plans`
ADD COLUMN `min_contract_months` int DEFAULT 1 COMMENT 'Minimum contract period requirement' AFTER `refund_policy_days`;

-- Update INDEX if quarterly_price and yearly_price added
-- Create index for faster filtering
ALTER TABLE `subscription_plans`
ADD INDEX `idx_created_at` (`created_at`),
ADD INDEX `idx_tier_level` (`tier_level`),
ADD INDEX `idx_visible` (`visible_to_customers`, `is_active`);

-- ============================================================
-- UPDATE EXISTING RECORDS WITH NEW COLUMN VALUES
-- ============================================================

UPDATE `subscription_plans` 
SET 
  `quarterly_price` = `price_per_month` * 3 * 0.90,
  `yearly_price` = `price_per_month` * 12 * 0.80,
  `setup_fee` = 0.00,
  `support_level` = 'BASIC',
  `trial_days` = 14,
  `billing_cycle` = 'MONTHLY',
  `visible_to_customers` = 1,
  `tier_level` = CASE 
    WHEN `name` = 'Starter' THEN 0
    WHEN `name` = 'Professional' THEN 1
    WHEN `name` = 'Enterprise' THEN 2
    ELSE 0
  END,
  `discount_percentage` = 0.00,
  `refund_policy_days` = 30,
  `min_contract_months` = 1,
  `payment_methods_allowed` = '[\"CREDIT_CARD\", \"BANK_TRANSFER\", \"UPI\"]'
WHERE `is_active` = 1;

-- Set support levels by plan tier
UPDATE `subscription_plans` SET `support_level` = 'STANDARD' WHERE `name` = 'Professional';
UPDATE `subscription_plans` SET `support_level` = 'PREMIUM' WHERE `name` = 'Enterprise';
UPDATE `subscription_plans` SET `support_level` = 'BASIC' WHERE `name` = 'Starter';

-- ============================================================
-- ADD CANCELLATION POLICY TEXT
-- ============================================================

UPDATE `subscription_plans` 
SET `cancellation_policy` = 'Plans can be cancelled anytime. Refund policy applies as per the plan terms.'
WHERE `is_active` = 1;

-- ============================================================
-- VERIFY SCHEMA
-- ============================================================

-- Show updated table structure
SHOW COLUMNS FROM `subscription_plans`;

-- Show sample data
SELECT * FROM `subscription_plans`;
