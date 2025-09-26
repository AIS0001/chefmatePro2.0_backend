-- Sample data for testing inventory/joined route

-- First, add some sample items
INSERT INTO items (catid, subcatid, iname, unit, weight, tax, mrp, offerprice, description, min_stock, isstockable, status) VALUES
(1, 1, 'Rice Bag 25kg', 'bag', 25, 5.0, 2500.00, 2400.00, 'Premium Basmati Rice', 10, 1, 1),
(1, 2, 'Wheat Flour 10kg', 'bag', 10, 5.0, 800.00, 750.00, 'Whole Wheat Flour', 15, 1, 1),
(2, 3, 'Cooking Oil 5L', 'bottle', 5, 12.0, 650.00, 600.00, 'Refined Sunflower Oil', 8, 1, 1),
(3, 4, 'Sugar 1kg', 'packet', 1, 0.0, 60.00, 55.00, 'Crystal White Sugar', 20, 1, 1),
(4, 5, 'Tea Leaves 500g', 'packet', 0.5, 18.0, 450.00, 420.00, 'Premium Assam Tea', 25, 1, 1);

-- Then add inventory records with proper item_id relationships
-- Get the IDs from items table and use them
INSERT INTO inventory (supplier_id, item_id, opening_stock, stock_in, stock_out, closing_stock, unit, refno, pdate, purchase_price, vat, subtotal, vatAmount, netAmount) VALUES
(1, (SELECT id FROM items WHERE iname = 'Rice Bag 25kg' LIMIT 1), 50, 100, 20, 130, 'bag', 'PO-001', '2025-01-01', 2300.00, 5.0, 2300.00, 115.00, 2415.00),
(1, (SELECT id FROM items WHERE iname = 'Wheat Flour 10kg' LIMIT 1), 30, 50, 15, 65, 'bag', 'PO-002', '2025-01-02', 720.00, 5.0, 720.00, 36.00, 756.00),
(2, (SELECT id FROM items WHERE iname = 'Cooking Oil 5L' LIMIT 1), 20, 40, 10, 50, 'bottle', 'PO-003', '2025-01-03', 580.00, 12.0, 580.00, 69.60, 649.60),
(1, (SELECT id FROM items WHERE iname = 'Sugar 1kg' LIMIT 1), 100, 200, 80, 220, 'packet', 'PO-004', '2025-01-04', 52.00, 0.0, 52.00, 0.00, 52.00),
(3, (SELECT id FROM items WHERE iname = 'Tea Leaves 500g' LIMIT 1), 40, 60, 25, 75, 'packet', 'PO-005', '2025-01-05', 400.00, 18.0, 400.00, 72.00, 472.00);

-- Verify the data was inserted correctly
SELECT 
    inventory.id,
    inventory.item_id,
    inventory.closing_stock,
    inventory.unit,
    items.iname AS item_name,
    inventory.created_at
FROM inventory 
JOIN items ON inventory.item_id = items.id
ORDER BY inventory.id DESC;
