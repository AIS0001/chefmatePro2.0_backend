-- Create day_close_summary table for daily closing reports
CREATE TABLE IF NOT EXISTS day_close_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    close_date DATE NOT NULL UNIQUE,
    total_sales DECIMAL(10,2) DEFAULT 0.00,
    total_cash DECIMAL(10,2) DEFAULT 0.00,
    total_credit DECIMAL(10,2) DEFAULT 0.00,
    total_upi DECIMAL(10,2) DEFAULT 0.00,
    total_bank_transfer DECIMAL(10,2) DEFAULT 0.00,
    total_qr_code DECIMAL(10,2) DEFAULT 0.00,
    total_orders INT DEFAULT 0,
    total_customers INT DEFAULT 0,
    opening_cash DECIMAL(10,2) DEFAULT 0.00,
    closing_cash DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_close_date (close_date)
);
