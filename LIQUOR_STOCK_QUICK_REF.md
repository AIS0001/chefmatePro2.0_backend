# Liquor Stock Deduction - QUICK REFERENCE

## The Problem
```
❌ Old Behavior:
Customer orders 30ml peg → System looks for 30ml stock → Not found → Deducts 1 full bottle
(Customer gets 30ml, loses 750ml from inventory)

✅ New Behavior:
Customer orders 30ml peg → System deducts from full bottle stock → Removes 30ml worth
(System correctly tracks 30ml consumption from 750ml bottle)
```

---

## Setup (5 minutes)

### Step 1: Create Product Units
```sql
-- For Vodka (product_id = 15)

-- Base Unit
INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit)
VALUES (15, 'Full Bottle', 750, 1);

-- Serving Units
INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit)
VALUES 
  (15, '30ml Peg', 30, 0),
  (15, '60ml Peg', 60, 0),
  (15, '90ml Peg', 90, 0);
```

### Step 2: Add Stock (as full bottles only)
```bash
POST /api/stock/add
{
  "productId": 15,
  "unitId": 1,
  "quantity": 10
}
```

### Step 3: Sell Serving Units
```bash
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 3,    # 30ml Peg unit (from Step 1)
  "quantity": 1   # 1 peg
}
# System auto-deducts 1 full bottle
```

---

## API Quick Reference

### Add Stock
```bash
POST /api/stock/add
{
  "productId": 15,
  "unitId": 1,          # ALWAYS full bottle unit
  "quantity": 10
}
```

### Sell Serving
```bash
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 3,          # Serving unit (30ml, 60ml, 90ml, etc)
  "quantity": 1         # Number of servings
}
```

### Check Stock
```bash
GET /api/stock/level/15
# Response shows: Full Bottle = X units
```

### Alternative: Sell by Variant
```bash
POST /api/stock/remove-variant
{
  "productId": 15,
  "variantId": 101,     # Pre-configured variant
  "quantity": 1
}
```

---

## Common Tasks

### Add 12 Bottles of Whiskey
```bash
POST /api/stock/add
{
  "productId": 20,
  "unitId": 8,          # Full Bottle unit for whiskey
  "quantity": 12
}
```

### Customer Orders 2 × 60ml Pegs
```bash
POST /api/stock/remove
{
  "productId": 20,
  "unitId": 10,         # 60ml Peg unit for whiskey
  "quantity": 2
}
# System deducts 1 full bottle (2×60ml = 120ml from 750ml)
```

### Customer Orders 1 × 90ml Peg
```bash
POST /api/stock/remove
{
  "productId": 20,
  "unitId": 11,         # 90ml Peg unit
  "quantity": 1
}
# System deducts 1 full bottle (90ml from 750ml)
```

---

## Database Structure

```
PRODUCTS: items
├── Vodka (id=15)
└── Whiskey (id=20)

UNITS: product_units
├── Vodka
│   ├── Full Bottle (id=1, ml=750, is_base=1)
│   ├── 30ml Peg (id=3, ml=30, is_base=0)
│   ├── 60ml Peg (id=4, ml=60, is_base=0)
│   └── 90ml Peg (id=5, ml=90, is_base=0)
└── Whiskey
    ├── Full Bottle (id=8, ml=750, is_base=1)
    ├── 30ml Peg (id=9, ml=30, is_base=0)
    └── 60ml Peg (id=10, ml=60, is_base=0)

STOCK: stock_balance
├── Vodka, Full Bottle = 10 units
├── Vodka, 30ml Peg = NO ENTRY (auto-calculated)
├── Whiskey, Full Bottle = 12 units
└── Whiskey, 60ml Peg = NO ENTRY (auto-calculated)
```

---

## Key Points

✅ **ALWAYS**
- Add stock as full bottles only (unit_id = base unit)
- Use serving unit IDs when selling pegs (from product_units table)
- Set ml_capacity for all units

❌ **NEVER**
- Create stock_balance entries for serving units
- Add stock as serving units (30ml, 60ml, etc.)
- Manually deduct from multiple units

---

## Response Example

### Sale Request:
```bash
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 3,
  "quantity": 1
}
```

### Response:
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "productId": 15,
    "unitId": 3,              # Requested: 30ml Peg
    "quantity": 1,            # Requested: 1 peg
    "deductedFromUnit": 1,    # Actual: Full Bottle unit
    "deductedQuantity": 1,    # Actual: 1 bottle removed
    "deductedInMl": 30        # Actual: 30ml consumed
  }
}
```

---

## Error Messages

| Error | Solution |
|-------|----------|
| "Unit not found" | Unit ID doesn't exist for product |
| "Insufficient stock" | Not enough bottles for ordered pegs |
| "No stock available" | Missing stock_balance for base unit |

---

## Unit IDs for Your Products

Find your serving unit IDs:
```sql
SELECT id, unit_name, ml_capacity, is_base_unit
FROM product_units
WHERE product_id = 15
ORDER BY ml_capacity DESC;
```

| unit_name | ml_capacity | id | Use When |
|-----------|-------------|-----|----------|
| Full Bottle | 750 | 1 | Adding stock |
| 30ml Peg | 30 | 3 | Selling 30ml |
| 60ml Peg | 60 | 4 | Selling 60ml |
| 90ml Peg | 90 | 5 | Selling 90ml |

---

## Troubleshooting

**Issue: "No stock available" error**
- Check: Is `is_base_unit = 1` set for Full Bottle?
- Check: Is stock_balance entry created for full bottle unit?

**Issue: Wrong amount deducted**
- Check: ml_capacity set correctly? (750 for full bottle)
- Check: Using serving unit ID, not base unit ID?

**Issue: Can't find unit IDs**
```sql
SELECT id, product_id, unit_name, ml_capacity, is_base_unit
FROM product_units
WHERE product_id = 15;
```

---

## Testing

Run test script:
```bash
node test-liquor-deduction.js
```

---

## Summary

| Action | API | Notes |
|--------|-----|-------|
| Add Stock | POST /api/stock/add | Use base unit only |
| Sell Serving | POST /api/stock/remove | Use serving unit ID |
| Check Stock | GET /api/stock/level/{id} | Shows base unit amount |
| View History | GET /api/stock/transactions | Shows ML consumed |

---

**Last Updated**: January 31, 2025
**Status**: ✅ PRODUCTION READY
