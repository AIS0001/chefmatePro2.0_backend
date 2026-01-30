# Stock Management System - Advanced Inventory Management

## 🎯 Overview

A sophisticated inventory management system for restaurants and bars that handles complex unit conversions and smart stock deduction. Perfect for products like liquor that can be sold in multiple serving sizes (30ML peg, 60ML, full bottle) and items like coke sold in cans or crates.

## ✨ Key Features

### 1. **Multi-Unit Support**
- Define multiple units per product
- Base units and derived units
- ML capacity tracking for liquor bottles
- Support for pieces, cans, bottles, liters, and custom units

### 2. **Smart Serving Sizes** 
- Create product variants (e.g., 30ML peg, 60ML, full bottle)
- Automatic inventory deduction from base units
- Maintain ML-level accuracy for liquor
- Different selling prices per variant

### 3. **Unit Conversions**
- Define conversion rules between units
- Example: 1 Bottle (750ML) = 25 × 30ML pegs
- Bidirectional conversions
- Decimal precision for accurate calculations

### 4. **Complete Audit Trail**
- Track all stock movements
- Record transaction type (Purchase, Sale, Waste, Adjustment)
- User tracking and timestamps
- Reference tracking to bills, orders, or purchases

### 5. **Stock Management**
- Real-time stock balance
- Low stock alerts
- Reserved stock tracking
- Minimum stock level configuration
- Stock transaction history

### 6. **Analytics & Reports**
- Stock reports by product
- Transaction history
- Low stock alerts
- Stock valuation reports

---

## 🚀 Quick Start

### 1. Install Database Schema

```bash
# Option A: Run the SQL migration file
mysql -u username -p database_name < database/create_stock_management_schema.sql

# Option B: Use the setup script
node setup-stock-system.js
```

### 2. Start Using the Stock API

All endpoints are at `/api/stock` and require authentication.

#### Add Stock (Purchase)
```bash
curl -X POST http://localhost:4402/api/stock/add \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitId": 1,
    "quantity": 10,
    "referenceType": "PURCHASE",
    "referenceId": 301,
    "notes": "New bottle supply"
  }'
```

#### Remove Stock (Sale using Variant)
```bash
curl -X POST http://localhost:4402/api/stock/remove-variant \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "variantId": 5,
    "quantity": 2,
    "referenceId": 1001,
    "notes": "2x 30ML pegs sold at Table 5"
  }'
```

#### Get Stock Level
```bash
curl -X GET http://localhost:4402/api/stock/level/126 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📋 API Endpoints Reference

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/stock/add` | Add stock to inventory |
| POST | `/api/stock/remove` | Remove stock (waste/damage) |
| POST | `/api/stock/remove-variant` | Sell using serving size variant |
| GET | `/api/stock/level/:productId` | Get current stock level |
| GET | `/api/stock/all` | Get all inventory |
| GET | `/api/stock/report/:productId` | Complete stock report |
| GET | `/api/stock/history/:productId` | Transaction history |
| GET | `/api/stock/alerts/low-stock` | Low stock alerts |
| GET | `/api/stock/units/:productId` | Get all units for product |
| POST | `/api/stock/units/create` | Create new unit |
| GET | `/api/stock/conversions/:productId` | Get conversion rules |
| POST | `/api/stock/conversions/create` | Create conversion rule |
| POST | `/api/stock/convert` | Convert between units |
| GET | `/api/stock/variants/:productId` | Get product variants |
| POST | `/api/stock/variants/create` | Create serving size variant |

See [docs/stock_management_guide.md](./docs/stock_management_guide.md) for detailed API documentation.

---

## 🔧 Setup Examples

### Example 1: Whiskey with Serving Sizes

**Step 1: Create Base Unit**
```json
POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "Bottle",
  "unitType": "BASE",
  "mlCapacity": 750,
  "sellingPrice": 3000
}
Response: unitId = 1
```

**Step 2: Create Serving Units**
```json
POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "30ML Peg",
  "unitType": "DERIVED",
  "mlCapacity": 30,
  "sellingPrice": 150
}
Response: unitId = 2
```

**Step 3: Create Conversion Rule**
```json
POST /api/stock/conversions/create
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 2,
  "conversionFactor": 25  // 1 bottle = 25 pegs
}
```

**Step 4: Create Variant**
```json
POST /api/stock/variants/create
{
  "productId": 126,
  "variantName": "30ML Peg",
  "baseUnitId": 1,
  "quantityInBaseUnit": 0.04,
  "mlQuantity": 30,
  "sellingPrice": 150,
  "costPrice": 120
}
Response: variantId = 5
```

**Step 5: Add Stock**
```json
POST /api/stock/add
{
  "productId": 126,
  "unitId": 1,
  "quantity": 12,
  "referenceType": "PURCHASE",
  "notes": "Supply from supplier"
}
```

**Step 6: Sell Using Variant**
```json
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": 1001,
  "notes": "2x 30ML pegs sold"
}
// Automatically removes 0.08 bottles from inventory
```

---

### Example 2: Coke (Can & Crate)

**Create Units:**
```json
POST /api/stock/units/create - Can (Base unit)
POST /api/stock/units/create - Crate (Derived unit)
```

**Create Conversion:**
```json
POST /api/stock/conversions/create
{
  "conversionFactor": 24  // 1 crate = 24 cans
}
```

**Add Stock by Crate:**
```json
POST /api/stock/add
{
  "productId": 127,
  "unitId": 2,
  "quantity": 10,
  "notes": "10 crates received"
}
// 240 cans added to inventory
```

**Sell Individual Cans:**
```json
POST /api/stock/remove
{
  "productId": 127,
  "unitId": 1,
  "quantity": 3,
  "referenceType": "SALE",
  "notes": "3 cans sold at Table 5"
}
```

---

## 📊 File Structure

```
controllers/
  stockController.js          # HTTP request handlers
services/
  stockService.js            # Business logic and unit conversions
routes/
  stockRoutes.js             # API endpoints and validation
database/
  create_stock_management_schema.sql  # Database schema
docs/
  stock_management_guide.md   # Detailed API documentation
setup-stock-system.js         # Setup script with examples
```

---

## 🗄️ Database Tables

### `product_units`
Defines units available for each product.
```sql
- id, product_id, unit_name, unit_type
- conversion_factor, is_base_unit, ml_capacity
- purchase_price, selling_price, is_active
```

### `stock_conversions`
Defines conversion rules between units.
```sql
- id, product_id, from_unit_id, to_unit_id
- conversion_factor, is_active
```

### `stock_balance`
Real-time stock quantity for each unit.
```sql
- id, product_id, unit_id
- current_quantity, reserved_quantity, available_quantity
```

### `stock_transactions`
Audit trail of all stock movements.
```sql
- id, product_id, transaction_type, unit_id, quantity
- quantity_in_ml, reference_type, reference_id
- user_id, notes, transaction_date
```

### `product_variants`
Serving size variants for products.
```sql
- id, product_id, variant_name, base_unit_id
- quantity_in_base_unit, ml_quantity
- selling_price, cost_price, is_active
```

---

## 💡 Use Cases

### Restaurant POS
```javascript
// Customer orders: 2x Whiskey 30ML Peg
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": billId,
  "notes": "Table 5"
}
// Automatically deducts from bottle inventory
```

### Inventory Purchase
```javascript
// Received 10 bottles of whiskey
POST /api/stock/add
{
  "productId": 126,
  "unitId": 1,
  "quantity": 10,
  "referenceType": "PURCHASE",
  "referenceId": purchaseOrderId
}
```

### Stock Adjustment
```javascript
// Damage/Waste found during inventory
POST /api/stock/remove
{
  "productId": 126,
  "unitId": 1,
  "quantity": 1,
  "referenceType": "DAMAGE",
  "notes": "Damaged during delivery"
}
```

### Low Stock Alert
```javascript
GET /api/stock/alerts/low-stock
// Returns all items below minimum stock level
```

---

## 🔐 Security Features

- JWT authentication required for all endpoints
- Request validation with express-validator
- Input sanitization
- SQL injection prevention via parameterized queries
- Transactional consistency for stock operations

---

## 📈 Advanced Features

### Stock Reservations
Coming soon - Reserve stock for pending orders without immediate deduction.

### Batch Operations
Perform multiple stock operations in a single transaction.

### Location-based Stock
Track inventory across multiple locations/branches.

### Expiry Date Tracking
Track product expiry dates and FIFO deduction.

### Stock Valuation
Calculate inventory value using different costing methods (FIFO, LIFO, Weighted Average).

---

## ⚠️ Important Notes

1. **Always create base units first** - Conversions and variants depend on base units
2. **Use ML capacity for liquor** - Improves accuracy of serving size calculations
3. **Record all transactions** - Maintain complete audit trail
4. **Set minimum stock** - Configure in items table for alerts
5. **Regular reconciliation** - Verify physical counts match database

---

## 🐛 Troubleshooting

### "Unit not found for this product"
- Ensure unit exists and belongs to the product
- Check unitId matches the productId

### "Insufficient stock"
- Get stock level: `GET /api/stock/level/:productId`
- Check available_quantity (not current_quantity)

### "No conversion rule found"
- Create conversion rule: `POST /api/stock/conversions/create`
- Ensure both units exist

### "Variant not found"
- Get variants: `GET /api/stock/variants/:productId`
- Ensure variantId is valid and active

---

## 📞 Support

For detailed API documentation, see [docs/stock_management_guide.md](./docs/stock_management_guide.md)

For implementation help, refer to the example setup in [setup-stock-system.js](./setup-stock-system.js)

---

## 📝 License

This stock management system is part of ChefMate POS system.
