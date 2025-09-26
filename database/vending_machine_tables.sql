-- Create vending machine related tables
-- This file creates all necessary tables for the vending machine system

-- 1. Create vending_machines table
CREATE TABLE IF NOT EXISTS vending_machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    status ENUM('online', 'offline', 'maintenance', 'error') DEFAULT 'offline',
    configuration JSON,
    last_heartbeat DATETIME,
    setup_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_machine_id (machine_id),
    INDEX idx_status (status),
    INDEX idx_location (location)
);

-- 2. Create vending_transactions table
CREATE TABLE IF NOT EXISTS vending_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(100) NOT NULL UNIQUE,
    machine_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    quantity INT DEFAULT 1,
    amount DECIMAL(10, 2),
    status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('cash', 'card', 'mobile', 'wallet') DEFAULT 'cash',
    user_id VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_machine_id (machine_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (machine_id) REFERENCES vending_machines(machine_id) ON DELETE CASCADE
);

-- 3. Create rs485_logs table
CREATE TABLE IF NOT EXISTS rs485_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id VARCHAR(50) NOT NULL,
    command_sent TEXT,
    response_received TEXT,
    status ENUM('sent', 'received', 'error', 'timeout') DEFAULT 'sent',
    error_message TEXT,
    response_time_ms INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_machine_id (machine_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- 4. Create vending_inventory table (if not exists)
CREATE TABLE IF NOT EXISTS vending_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    max_quantity INT DEFAULT 10,
    min_threshold INT DEFAULT 2,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_machine_product (machine_id, product_id),
    INDEX idx_machine_id (machine_id),
    INDEX idx_product_id (product_id),
    FOREIGN KEY (machine_id) REFERENCES vending_machines(machine_id) ON DELETE CASCADE
);

-- Insert sample vending machine data
INSERT INTO vending_machines (machine_id, name, location, status, configuration) VALUES
('VM001', 'Main Hall Vending Machine', 'Building A - Main Hall', 'offline', '{"temperature_control": true, "payment_methods": ["cash", "card"], "max_items": 50}'),
('VM002', 'Cafeteria Vending Machine', 'Building B - Cafeteria', 'offline', '{"temperature_control": false, "payment_methods": ["cash", "card", "mobile"], "max_items": 40}'),
('VM003', 'Office Vending Machine', 'Building C - Office Floor 3', 'offline', '{"temperature_control": true, "payment_methods": ["card", "mobile"], "max_items": 30}')
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    location = VALUES(location),
    configuration = VALUES(configuration);

-- Insert sample inventory data
INSERT INTO vending_inventory (machine_id, product_id, product_name, price, quantity, max_quantity) VALUES
('VM001', 'DRINK001', 'Coca Cola 330ml', 2.50, 10, 15),
('VM001', 'DRINK002', 'Pepsi 330ml', 2.50, 8, 15),
('VM001', 'SNACK001', 'Chips - Classic', 3.00, 5, 12),
('VM001', 'SNACK002', 'Chocolate Bar', 2.75, 7, 10),
('VM002', 'DRINK001', 'Coca Cola 330ml', 2.50, 12, 20),
('VM002', 'DRINK003', 'Orange Juice 500ml', 3.50, 6, 10),
('VM002', 'SNACK003', 'Cookies Pack', 2.25, 8, 12),
('VM003', 'DRINK004', 'Water 500ml', 1.50, 15, 25),
('VM003', 'DRINK005', 'Coffee 250ml', 3.00, 4, 8),
('VM003', 'SNACK004', 'Nuts Mix', 4.00, 3, 8)
ON DUPLICATE KEY UPDATE 
    product_name = VALUES(product_name),
    price = VALUES(price),
    quantity = VALUES(quantity),
    max_quantity = VALUES(max_quantity);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vending_transactions_machine_status ON vending_transactions(machine_id, status);
CREATE INDEX IF NOT EXISTS idx_rs485_logs_machine_created ON rs485_logs(machine_id, created_at);
CREATE INDEX IF NOT EXISTS idx_vending_inventory_machine_quantity ON vending_inventory(machine_id, quantity);
