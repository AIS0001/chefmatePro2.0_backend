-- Create vending machines table
CREATE TABLE IF NOT EXISTS vending_machines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    machine_id VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(255) NOT NULL,
    type VARCHAR(100) DEFAULT 'standard',
    status ENUM('online', 'offline', 'maintenance') DEFAULT 'offline',
    configuration JSON,
    last_heartbeat TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create vending inventory table
CREATE TABLE IF NOT EXISTS vending_inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    machine_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    slot_number VARCHAR(10),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (machine_id) REFERENCES vending_machines(machine_id) ON DELETE CASCADE,
    UNIQUE KEY unique_machine_product (machine_id, product_id)
);

-- Create vending transactions table
CREATE TABLE IF NOT EXISTS vending_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    machine_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    customer_id VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (machine_id) REFERENCES vending_machines(machine_id) ON DELETE CASCADE
);

-- Create RS485 communication logs table
CREATE TABLE IF NOT EXISTS rs485_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    machine_id VARCHAR(50),
    command_sent TEXT,
    response_received TEXT,
    status ENUM('success', 'error', 'timeout') DEFAULT 'success',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT IGNORE INTO vending_machines (machine_id, location, type, status) VALUES
('VM001', 'Office Floor 1', 'snack_machine', 'offline'),
('VM002', 'Cafeteria', 'beverage_machine', 'offline'),
('VM003', 'Lobby', 'combo_machine', 'offline');

INSERT IGNORE INTO vending_inventory (machine_id, product_id, product_name, quantity, price, slot_number) VALUES
('VM001', 'P001', 'Coca Cola', 10, 25.00, 'A1'),
('VM001', 'P002', 'Pepsi', 8, 25.00, 'A2'),
('VM001', 'P003', 'Chips', 15, 20.00, 'B1'),
('VM001', 'P004', 'Chocolate', 12, 30.00, 'B2'),
('VM002', 'P005', 'Water Bottle', 20, 15.00, 'A1'),
('VM002', 'P006', 'Energy Drink', 5, 45.00, 'A2'),
('VM003', 'P007', 'Sandwich', 6, 60.00, 'C1'),
('VM003', 'P008', 'Cookies', 10, 35.00, 'C2');
