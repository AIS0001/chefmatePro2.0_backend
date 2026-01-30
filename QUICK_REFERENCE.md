# 📇 Stock Management System - Quick Reference Card

## 🔗 API Base URL
```
/api/stock
```

All endpoints require `Authorization: Bearer {JWT_TOKEN}` header

---

## 📋 Endpoint Reference

### ADD STOCK
```
POST /api/stock/add
{
  "productId": 126,
  "unitId": 1,
  "quantity": 10,
  "referenceType": "PURCHASE",    // Optional
  "referenceId": 301,              // Optional
  "notes": "String"                // Optional
}
```

### REMOVE STOCK
```
POST /api/stock/remove
{
  "productId": 126,
  "unitId": 1,
  "quantity": 1,
  "referenceType": "DAMAGE",       // WASTE, DAMAGE, ADJUSTMENT
  "notes": "String"                // Optional
}
```

### REMOVE USING VARIANT (SMART)
```
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,                  // 30ML Peg variant
  "quantity": 2,                   // How many pegs
  "referenceId": 1001,             // Bill ID
  "notes": "String"                // Optional
}
```

### GET STOCK LEVEL
```
GET /api/stock/level/126
GET /api/stock/level/126?unitId=1  // Specific unit
```

### GET ALL INVENTORY
```
GET /api/stock/all
GET /api/stock/all?categoryId=10   // By category
GET /api/stock/all?minStock=true   // Only low stock
```

### GET STOCK REPORT
```
GET /api/stock/report/126
```
Returns: Product details, current stock, variants, transactions

### GET TRANSACTION HISTORY
```
GET /api/stock/history/126
GET /api/stock/history/126?limit=50&offset=0
GET /api/stock/history/126?type=REMOVE
```

### GET LOW STOCK ALERTS
```
GET /api/stock/alerts/low-stock
```

### GET ALL UNITS
```
GET /api/stock/units/126
```

### CREATE UNIT
```
POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "30ML Peg",
  "unitType": "DERIVED",           // BASE or DERIVED
  "mlCapacity": 30,                // Optional
  "sellingPrice": 150,             // Optional
  "purchasePrice": 120             // Optional
}
```

### GET CONVERSIONS
```
GET /api/stock/conversions/126
```

### CREATE CONVERSION
```
POST /api/stock/conversions/create
{
  "productId": 126,
  "fromUnitId": 1,                 // Bottle
  "toUnitId": 2,                   // 30ML Peg
  "conversionFactor": 25           // 1 Bottle = 25 Pegs
}
```

### CONVERT UNITS
```
POST /api/stock/convert
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 2,
  "quantity": 2                    // 2 Bottles = 50 Pegs
}
```

### GET VARIANTS
```
GET /api/stock/variants/126
```

### CREATE VARIANT
```
POST /api/stock/variants/create
{
  "productId": 126,
  "variantName": "30ML Peg",
  "baseUnitId": 1,
  "quantityInBaseUnit": 0.04,      // 30/750 = 0.04
  "mlQuantity": 30,                // Optional
  "sellingPrice": 150,
  "costPrice": 120                 // Optional
}
```

---

## 📊 Common Scenarios

### Scenario 1: Add Whiskey Stock
```bash
POST /api/stock/add
{
  "productId": 126,
  "unitId": 1,
  "quantity": 12,
  "referenceType": "PURCHASE",
  "referenceId": 301
}
```

### Scenario 2: Sell 2 Pegs
```bash
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": 1001
}
Result: Removes 0.08 bottles automatically
```

### Scenario 3: Check Stock
```bash
GET /api/stock/level/126
Result: Shows all units (Bottle, 30ML Peg, 60ML Peg, etc.)
```

### Scenario 4: Get Alerts
```bash
GET /api/stock/alerts/low-stock
Result: Shows items below minimum stock level
```

---

## 🗂️ Database Tables

| Table | Purpose |
|-------|---------|
| `product_units` | Define units per product |
| `stock_conversions` | Conversion rules |
| `stock_balance` | Real-time quantities |
| `stock_transactions` | Audit trail |
| `product_variants` | Serving sizes |

---

## 📈 Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed",
  "data": { /* response data */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

---

## 🔍 Key Concepts

| Term | Meaning |
|------|---------|
| Base Unit | Primary unit (Bottle, Can, Piece) |
| Derived Unit | Secondary unit (30ML Peg, Crate) |
| Conversion Factor | Ratio between units (1 Bottle = 25 Pegs) |
| Variant | Serving size option (30ML Peg, 60ML, Full Bottle) |
| Stock Balance | Current quantity in inventory |
| Available Quantity | Current - Reserved quantity |
| Transaction | Any add/remove/adjust operation |

---

## ⚡ Common Commands

### Setup
```bash
node setup-stock-system.js
```

### Test
```bash
bash test-stock-api.sh
```

### Add 10 Bottles
```bash
curl -X POST http://localhost:4402/api/stock/add \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitId": 1,
    "quantity": 10
  }'
```

### Check Stock
```bash
curl -X GET http://localhost:4402/api/stock/level/126 \
  -H "Authorization: Bearer TOKEN"
```

### Sell 2 Pegs
```bash
curl -X POST http://localhost:4402/api/stock/remove-variant \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "variantId": 5,
    "quantity": 2
  }'
```

---

## 📝 Setup Steps

1. **Create Units**
   ```
   POST /api/stock/units/create (Bottle)
   POST /api/stock/units/create (30ML Peg)
   ```

2. **Create Conversions**
   ```
   POST /api/stock/conversions/create (1 Bottle = 25 Pegs)
   ```

3. **Create Variants**
   ```
   POST /api/stock/variants/create (30ML Peg variant)
   ```

4. **Add Stock**
   ```
   POST /api/stock/add (Add bottles)
   ```

5. **Start Using**
   ```
   POST /api/stock/remove-variant (Sell pegs)
   ```

---

## 🎯 Error Codes & Meanings

| Error | Meaning | Solution |
|-------|---------|----------|
| Product not found | Invalid productId | Check product exists |
| Unit not found | Invalid unitId | Create unit first |
| Insufficient stock | Not enough quantity | Check available_quantity |
| No conversion found | Conversion doesn't exist | Create conversion rule |
| Variant not found | Invalid variantId | Create variant first |

---

## 💡 Pro Tips

✅ Always create **base units** first  
✅ Use **ML capacity** for liquor  
✅ Record **all transactions** with references  
✅ Set **minimum stock** levels  
✅ Monitor **low stock alerts** regularly  
✅ Use **variants** for POS integration  

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `STOCK_MANAGEMENT_README.md` | Quick start |
| `docs/stock_management_guide.md` | Full API docs |
| `docs/STOCK_SYSTEM_ARCHITECTURE.md` | System design |
| `IMPLEMENTATION_COMPLETE.md` | Summary |

---

## 🔐 Authentication

All requests require JWT token in header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

---

## 🔄 Variant-Based Sales Workflow

```
1. Customer orders: 2x 30ML Pegs (Whiskey)
2. POST /api/stock/remove-variant
   {
     "productId": 126,
     "variantId": 5,
     "quantity": 2,
     "referenceId": billId
   }
3. System automatically:
   - Calculates: 2 × 0.04 = 0.08 bottles
   - Removes: 0.08 bottles from stock
   - Records: 60ML removed
   - Tracks: Bill reference
   - Logs: User, timestamp
4. Stock updated!
```

---

## 📊 Data Flow

```
REQUEST → VALIDATE → SERVICE → DATABASE → RESPONSE
```

---

## 🎓 Learning Resources

1. **Setup**: Run `setup-stock-system.js`
2. **Understand**: Read `docs/STOCK_SYSTEM_ARCHITECTURE.md`
3. **Learn API**: Study `docs/stock_management_guide.md`
4. **Practice**: Execute `test-stock-api.sh`
5. **Integrate**: Follow examples in documentation

---

## ⏱️ Response Times

- Add/Remove: ~50-100ms
- Get Level: ~20-50ms
- Get Report: ~100-200ms
- Conversions: ~20-50ms

---

Ready to use! Start with documentation or setup script. 🚀
