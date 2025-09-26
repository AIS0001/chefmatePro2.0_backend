# Database Schema Update: setup_date Column Addition

## Overview
Added a new `setup_date` column to both `final_bill` and `order_items` tables to track when records are created/setup.

## Database Changes

### SQL Commands to Run
```sql
-- Add setup_date column to final_bill table
ALTER TABLE final_bill 
ADD COLUMN setup_date DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Add setup_date column to order_items table  
ALTER TABLE order_items 
ADD COLUMN setup_date DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Optional: Update existing records with current timestamp if needed
-- UPDATE final_bill SET setup_date = NOW() WHERE setup_date IS NULL;
-- UPDATE order_items SET setup_date = NOW() WHERE setup_date IS NULL;
```

## Code Changes Made

### 1. insertcontrol.js - savebill function
**Before:**
```javascript
const { customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, payment_mode } = req.body;
const billQuery = `
  INSERT INTO final_bill 
  (customer_id, inv_date, inv_time, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode, setup_date)
  VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, NOW())`;
const [billResult] = await connection.execute(billQuery, [
  customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode
]);
```

**After:**
```javascript
const { customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, payment_mode, setup_date } = req.body;
const billQuery = `
  INSERT INTO final_bill 
  (customer_id, inv_date, inv_time, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode, setup_date)
  VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
const [billResult] = await connection.execute(billQuery, [
  customer_id, subtotal, tax, discount_type, discount_value, discount_amount, roundoff, net_total, payment_mode, setup_date
]);
```

### 2. insertcontrol.js - insertdatabulk function
**Before:**
```javascript
const values = items.map(item => [
  item.order_number,
  item.table_number,
  item.item_name,
  item.quantity,
  item.total_amount,
  item.status,
  new Date(), // setup_date
]);

const query = `INSERT INTO ${tableName} (order_id, table_number, item_name, quantity, total_price, status, setup_date) VALUES ?`;
```

**After:**
```javascript
const values = items.map(item => [
  item.order_number,
  item.table_number,
  item.item_name,
  item.quantity,
  item.total_amount,
  item.status,
  item.setup_date,
]);

const query = `INSERT INTO ${tableName} (order_id, table_number, item_name, quantity, total_price, status, setup_date) VALUES ?`;
```

### 3. insertcontrol.js - insertdatabulkgst function
**Before:**
```javascript
values = items.map(item => [
  item.order_id,
  item.table_number,
  item.item_name,
  item.quantity,
  item.uom || '',
  item.rate || 0,
  item.cgst || 0,
  item.sgst || 0,
  item.igst || 0,
  item.tax_amount || 0,
  item.total_price,
  item.status,
  new Date(), // setup_date
]);

const query = `INSERT INTO ${tableName} 
  (order_id, table_number, item_name, quantity, uom, rate, cgst, sgst, igst, tax_amount, total_price, status, setup_date) 
  VALUES ?`;
```

**After:**
```javascript
values = items.map(item => [
  item.order_id,
  item.table_number,
  item.item_name,
  item.quantity,
  item.uom || '',
  item.rate || 0,
  item.cgst || 0,
  item.sgst || 0,
  item.igst || 0,
  item.tax_amount || 0,
  item.total_price,
  item.status,
  item.setup_date, // setup_date from frontend
]);

const query = `INSERT INTO ${tableName} 
  (order_id, table_number, item_name, quantity, uom, rate, cgst, sgst, igst, tax_amount, total_price, status, setup_date) 
  VALUES ?`;
```

### 4. billControl.js - savebill function
**Before:**
```javascript
const { customer_id, tablenumber, subtotal, subtotal_afterdiscount, tax, discount_type, discount_value, round_off, grand_total, payment_mode, status } = req.body;
const billQuery = `
    INSERT INTO final_bill (customer_id, inv_date, inv_time, table_number,subtotal, discount_type, discount_value,discount_amount,subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode,status, setup_date)
    VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?, NOW())
  `;
const [billResult] = await connection.execute(
  billQuery,
  [customer_id, tablenumber, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, round_off, grand_total, payment_mode, status]
);
```

**After:**
```javascript
const { customer_id, tablenumber, subtotal, subtotal_afterdiscount, tax, discount_type, discount_value, round_off, grand_total, payment_mode, status, setup_date } = req.body;
const billQuery = `
    INSERT INTO final_bill (customer_id, inv_date, inv_time, table_number,subtotal, discount_type, discount_value,discount_amount,subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode,status, setup_date)
    VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?, ?)
  `;
const [billResult] = await connection.execute(
  billQuery,
  [customer_id, tablenumber, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, round_off, grand_total, payment_mode, status, setup_date]
);
```

### 5. billControl.js - advancesavebill function
**Before:**
```javascript
const { customer_id, table_number, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode, status, pickup_date, pickup_time, special_note, order_type, bill_generated_by, final_billed, paid_amount } = req.body;
INSERT INTO advance_final_bill (customer_id, inv_date, inv_time, table_number, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode, status, pickup_date, pickup_time, special_note, order_type, bill_generated_by, final_billed, paid_amount)
VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
```

**After:**
```javascript
const { customer_id, table_number, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode, status, pickup_date, pickup_time, special_note, order_type, bill_generated_by, final_billed, paid_amount, setup_date } = req.body;
INSERT INTO advance_final_bill (customer_id, inv_date, inv_time, table_number, subtotal, discount_type, discount_value, discount_amount, subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode, status, pickup_date, pickup_time, special_note, order_type, bill_generated_by, final_billed, paid_amount, setup_date)
VALUES (?, CURDATE(), CURTIME(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
```

## Additional Considerations

### Tables That May Need setup_date Column
If you have these related tables, consider adding setup_date to them as well:
- `advance_order_items`
- `order_items_gst` 
- `advance_order_items_gst`
- `advance_final_bill`

### Frontend Changes Required
Update your frontend API calls to:
1. **Send setup_date** - Include setup_date in request body for all bill/order creation calls
2. **Handle setup_date in responses** - The column will now be returned in SELECT queries
3. **Update any forms/displays** - If you want to show when records were created

### Example Frontend API Calls
```javascript
// For order items
const response = await axios.post(`/insertdata/orders`, {
  userid: getUserName(),
  order_number: maxNumber,
  table_number: selectedTable,
  total_amount: total,
  status: "1",
  setup_date: new Date().toISOString() // ✅ Add setup_date from frontend
});

// For bills
const response = await axios.post(`/bills/save`, {
  customer_id: customerId,
  subtotal: subtotal,
  tax: tax,
  discount_type: discountType,
  discount_value: discountValue,
  payment_mode: paymentMode,
  setup_date: new Date().toISOString() // ✅ Add setup_date from frontend
});

// For bulk order items
const response = await axios.post(`/insertdata/bulk/order_items`, {
  items: items.map(item => ({
    ...item,
    setup_date: new Date().toISOString() // ✅ Add setup_date to each item
  }))
});
```

### API Response Changes
After these changes, API responses from final_bill and order_items will include:
```json
{
  "id": 123,
  "customer_id": 456,
  "inv_date": "2025-08-28",
  "setup_date": "2025-08-28 10:30:45",
  // ... other fields
}
```

## Migration Steps
1. **Run the SQL commands** to add the columns
2. **Deploy the updated code** 
3. **Test the APIs** to ensure they work correctly
4. **Update frontend** if needed to handle the new field
5. **Monitor logs** for any issues

## Benefits
- **Audit Trail**: Track when records were actually created
- **Reporting**: Better time-based analysis 
- **Debugging**: Easier to trace when data was inserted
- **Data Integrity**: Automatic timestamp prevents manual errors
