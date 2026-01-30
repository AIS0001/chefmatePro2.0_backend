-- Create features table for feature protection middleware
CREATE TABLE IF NOT EXISTS features (
    id INT AUTO_INCREMENT PRIMARY KEY,
    feature_code VARCHAR(50) UNIQUE NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert inventory feature
INSERT INTO features (feature_code, feature_name, description) 
VALUES ('inventory', 'Inventory Management', 'Access to inventory management features')
ON DUPLICATE KEY UPDATE feature_name = VALUES(feature_name);

-- Insert other common features that might be needed
INSERT INTO features (feature_code, feature_name, description) VALUES
('analytics', 'Analytics Dashboard', 'Access to analytics and reporting'),
('billing', 'Billing System', 'Access to billing and invoicing'),
('user_management', 'User Management', 'Access to user management features'),
('reports', 'Reports', 'Access to reports generation')
ON DUPLICATE KEY UPDATE feature_name = VALUES(feature_name);

-- Check what was created
SELECT * FROM features;
