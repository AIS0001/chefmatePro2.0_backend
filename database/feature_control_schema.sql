-- Feature Control Database Schema
-- Run these SQL commands to create the required tables

-- 1. Subscription Plans Table
CREATE TABLE IF NOT EXISTS subscription_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    plan_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration_months INT NOT NULL DEFAULT 1,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Features Table
CREATE TABLE IF NOT EXISTS features (
    id INT AUTO_INCREMENT PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL,
    feature_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Plan Features Junction Table
CREATE TABLE IF NOT EXISTS plan_features (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id INT NOT NULL,
    feature_id INT NOT NULL,
    feature_limit INT DEFAULT NULL, -- NULL means unlimited
    is_unlimited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (feature_id) REFERENCES features(id) ON DELETE CASCADE,
    UNIQUE KEY unique_plan_feature (plan_id, feature_id)
);

-- 4. User Subscriptions Table
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    status ENUM('active', 'inactive', 'expired') DEFAULT 'active',
    expires_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE CASCADE
);

-- 5. Feature Usage Table
CREATE TABLE IF NOT EXISTS feature_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    feature_id INT NOT NULL,
    usage_count INT DEFAULT 0,
    last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (feature_id) REFERENCES features(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_feature (user_id, feature_id)
);

-- Insert sample subscription plans
INSERT INTO subscription_plans (plan_name, plan_code, description, price, duration_months) VALUES
('Basic', 'basic', 'Basic plan with limited features', 9.99, 1),
('Premium', 'premium', 'Premium plan with advanced features', 19.99, 1),
('Enterprise', 'enterprise', 'Enterprise plan with all features', 49.99, 1);

-- Insert sample features
INSERT INTO features (feature_name, feature_code, description) VALUES
('Suppliers Management', 'suppliers', 'Manage suppliers and vendor information'),
('Inventory Management', 'inventory', 'Track and manage inventory items'),
('Advanced Reports', 'reports', 'Generate detailed business reports'),
('Multi-location', 'multi_location', 'Manage multiple restaurant locations'),
('API Access', 'api_access', 'Access to REST API endpoints'),
('Custom Branding', 'custom_branding', 'Customize app with your brand'),
('Priority Support', 'priority_support', 'Get priority customer support'),
('Data Export', 'data_export', 'Export data in various formats'),
('Online Ordering', 'online_ordering', 'Accept orders online'),
('Staff Management', 'staff_management', 'Manage staff and permissions');

-- Insert plan features (Basic Plan)
INSERT INTO plan_features (plan_id, feature_id, feature_limit, is_unlimited) VALUES
(1, 1, 5, FALSE),      -- Basic: 5 suppliers
(1, 2, 100, FALSE),    -- Basic: 100 inventory items
(1, 8, 10, FALSE);     -- Basic: 10 data exports per month

-- Insert plan features (Premium Plan)
INSERT INTO plan_features (plan_id, feature_id, feature_limit, is_unlimited) VALUES
(2, 1, 50, FALSE),     -- Premium: 50 suppliers
(2, 2, 1000, FALSE),   -- Premium: 1000 inventory items
(2, 3, NULL, TRUE),    -- Premium: Unlimited reports
(2, 5, NULL, TRUE),    -- Premium: API access
(2, 8, 100, FALSE),    -- Premium: 100 data exports per month
(2, 9, NULL, TRUE),    -- Premium: Online ordering
(2, 10, 20, FALSE);    -- Premium: 20 staff members

-- Insert plan features (Enterprise Plan)
INSERT INTO plan_features (plan_id, feature_id, feature_limit, is_unlimited) VALUES
(3, 1, NULL, TRUE),    -- Enterprise: Unlimited suppliers
(3, 2, NULL, TRUE),    -- Enterprise: Unlimited inventory
(3, 3, NULL, TRUE),    -- Enterprise: Unlimited reports
(3, 4, NULL, TRUE),    -- Enterprise: Multi-location
(3, 5, NULL, TRUE),    -- Enterprise: API access
(3, 6, NULL, TRUE),    -- Enterprise: Custom branding
(3, 7, NULL, TRUE),    -- Enterprise: Priority support
(3, 8, NULL, TRUE),    -- Enterprise: Unlimited data exports
(3, 9, NULL, TRUE),    -- Enterprise: Online ordering
(3, 10, NULL, TRUE);   -- Enterprise: Unlimited staff

-- Sample user subscription (assuming user ID 1 exists)
-- INSERT INTO user_subscriptions (user_id, plan_id, expires_at) VALUES
-- (1, 1, DATE_ADD(NOW(), INTERVAL 1 MONTH));
