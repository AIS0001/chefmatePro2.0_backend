-- Purchase Management Tables
-- Tracks purchase orders and purchase items
-- Note: Uses existing suppliers table

-- Add missing columns to existing suppliers table (if needed)
ALTER TABLE suppliers 
ADD COLUMN IF NOT EXISTS is_active TINYINT(1) DEFAULT 1 AFTER address;

-- Purchase orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  purchase_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'PO-2026-001',
  supplier_id INT NOT NULL,
  purchase_date DATE NOT NULL,
  invoice_number VARCHAR(100),
  invoice_date DATE,
  total_amount DECIMAL(10,2) DEFAULT 0.00,
  tax_amount DECIMAL(10,2) DEFAULT 0.00,
  discount_amount DECIMAL(10,2) DEFAULT 0.00,
  net_amount DECIMAL(10,2) DEFAULT 0.00,
  payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING, PARTIAL, PAID',
  payment_method VARCHAR(50) COMMENT 'CASH, CARD, UPI, BANK_TRANSFER',
  notes TEXT,
  created_by INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE RESTRICT,
  INDEX idx_purchase_date (purchase_date),
  INDEX idx_supplier (supplier_id),
  INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Purchase order items table
CREATE TABLE IF NOT EXISTS purchase_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  purchase_id INT NOT NULL,
  product_id INT NOT NULL,
  unit_id INT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  tax_rate DECIMAL(5,2) DEFAULT 0.00,
  tax_amount DECIMAL(10,2) DEFAULT 0.00,
  total_amount DECIMAL(10,2) NOT NULL,
  batch_number VARCHAR(50),
  expiry_date DATE,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (purchase_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES items(id) ON DELETE RESTRICT,
  FOREIGN KEY (unit_id) REFERENCES product_units(id) ON DELETE RESTRICT,
  INDEX idx_purchase (purchase_id),
  INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Purchase payments table (for tracking partial payments)
CREATE TABLE IF NOT EXISTS purchase_payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  purchase_id INT NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  reference_number VARCHAR(100),
  notes TEXT,
  created_by INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (purchase_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
  INDEX idx_purchase (purchase_id),
  INDEX idx_payment_date (payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

