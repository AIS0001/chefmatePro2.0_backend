# Liquor Stock Deduction - API Usage Guide

## Overview
After the fix, the stock system now correctly handles liquor sales in serving sizes. When a customer orders a peg (30ml, 60ml, or 90ml), the system automatically deducts the appropriate amount from the full bottle stock.

## Setup Requirements

### 1. Create Product with Units
```sql
-- Create a liquor product
INSERT INTO items (iname, description, category) 
VALUES ('Premium Vodka', 'Russian vodka 750ml bottle', 'Beverages');

-- Get the product ID (let's assume it's 15)
-- Create base unit (Full Bottle)
INSERT INTO product_units (
  product_id, 
  unit_name, 
  ml_capacity, 
  is_base_unit,
  unit_type
) VALUES (15, 'Full Bottle', 750, 1, 'BASE');

-- Create serving units
INSERT INTO product_units (product_id, unit_name, ml_capacity, is_base_unit, unit_type) 
VALUES 
  (15, '30ml Peg', 30, 0, 'DERIVED'),
  (15, '60ml Peg', 60, 0, 'DERIVED'),
  (15, '90ml Peg', 90, 0, 'DERIVED');
```

### 2. Add Stock (as full bottles)
```bash
curl -X POST http://localhost:3000/api/stock/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "productId": 15,
    "unitId": 1,          # Full Bottle unit ID
    "quantity": 10,       # Add 10 full bottles
    "referenceType": "PURCHASE",
    "referenceId": 123,   # Purchase ID
    "notes": "Stock replenishment"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Stock added successfully",
  "data": {
    "success": true,
    "message": "Stock added successfully",
    "productId": 15,
    "unitId": 1,
    "quantity": 10,
    "timestamp": "2025-01-31T10:30:00.000Z"
  }
}
```

## Sales Operations

### Method 1: Using Serving Unit IDs (Recommended)

When a customer orders a peg, send the serving unit ID directly:

#### Scenario: Customer orders 1 × 30ml peg
```bash
curl -X POST http://localhost:3000/api/stock/remove \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "productId": 15,
    "unitId": 3,          # 30ml Peg unit ID
    "quantity": 1,        # 1 peg
    "referenceType": "SALE",
    "referenceId": 456,   # Sale/Order ID
    "notes": "Customer order - Table 5"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "success": true,
    "message": "Stock removed successfully",
    "productId": 15,
    "unitId": 3,
    "quantity": 1,
    "deductedFromUnit": 1,
    "deductedQuantity": 1,
    "deductedInMl": 30,
    "timestamp": "2025-01-31T10:35:00.000Z"
  }
}
```

**What happened:**
- Customer ordered 1 × 30ml peg (unit 3)
- System found the base unit is unit 1 (Full Bottle, 750ml)
- System calculated: 30ml ÷ 750ml = 0.04 bottles → rounded up to 1 bottle
- **1 full bottle was deducted from inventory**
- Transaction logged with 30ml quantity_in_ml for accurate tracking

#### Scenario: Customer orders 2 × 60ml pegs
```bash
curl -X POST http://localhost:3000/api/stock/remove \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "productId": 15,
    "unitId": 4,          # 60ml Peg unit ID
    "quantity": 2,        # 2 pegs
    "referenceType": "SALE",
    "referenceId": 456,
    "notes": "Customer order - Table 5"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "productId": 15,
    "unitId": 4,
    "quantity": 2,
    "deductedFromUnit": 1,
    "deductedQuantity": 1,
    "deductedInMl": 120,
    "timestamp": "2025-01-31T10:36:00.000Z"
  }
}
```

**What happened:**
- Customer ordered 2 × 60ml pegs
- System calculated: 2 × 60ml = 120ml total
- 120ml ÷ 750ml = 0.16 bottles → rounded up to 1 bottle
- **1 full bottle was deducted**

### Method 2: Using Product Variants (Even Better)

For pre-configured serving options, use the variant endpoint:

#### First: Create a variant
```sql
-- Create 30ml peg variant
INSERT INTO product_variants (
  product_id,
  variant_name,
  base_unit_id,
  quantity_in_base_unit,
  ml_quantity
) VALUES (
  15,
  '30ml Peg',
  1,           # Full Bottle unit
  0.04,        # 30ml out of 750ml
  30
);

-- Get variant ID (let's assume it's 1001)
```

#### Then: Sell using the variant
```bash
curl -X POST http://localhost:3000/api/stock/remove-variant \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "productId": 15,
    "variantId": 1001,     # 30ml Peg variant
    "quantity": 1,         # 1 peg
    "referenceId": 456,
    "notes": "Customer order"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "success": true,
    "message": "Stock removed successfully",
    "productId": 15,
    "variantId": 1001,
    "variantName": "30ml Peg",
    "quantitySold": 1,
    "baseUnitQuantityRemoved": 0.04,
    "mlRemoved": 30,
    "timestamp": "2025-01-31T10:37:00.000Z"
  }
}
```

## Checking Stock Levels

### Get current stock for a product
```bash
curl -X GET http://localhost:3000/api/stock/level/15 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 15,
      "unit_id": 1,
      "unit_name": "Full Bottle",
      "ml_capacity": 750,
      "current_quantity": 8,
      "reserved_quantity": 0,
      "available_quantity": 8,
      "product_name": "Premium Vodka"
    },
    {
      "id": 2,
      "product_id": 15,
      "unit_id": 3,
      "unit_name": "30ml Peg",
      "ml_capacity": 30,
      "current_quantity": 0,
      "reserved_quantity": 0,
      "available_quantity": 0,
      "product_name": "Premium Vodka"
    },
    {
      "id": 3,
      "product_id": 15,
      "unit_id": 4,
      "unit_name": "60ml Peg",
      "ml_capacity": 60,
      "current_quantity": 0,
      "reserved_quantity": 0,
      "available_quantity": 0,
      "product_name": "Premium Vodka"
    }
  ]
}
```

**Interpretation:**
- **8 full bottles** in stock
- Serving units show 0 because they're auto-calculated from base units
- To serve 30ml pegs, you can serve up to 8 ÷ 0.04 = 200 pegs (if each bottle = 25 pegs of 30ml)

## Transaction History

### View transactions
```bash
curl -X GET "http://localhost:3000/api/stock/transactions/15?type=REMOVE&limit=20&offset=0" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response shows:**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": 100,
        "product_id": 15,
        "transaction_type": "REMOVE",
        "unit_id": 3,
        "quantity": 1,
        "quantity_in_ml": 30,
        "reference_type": "SALE",
        "reference_id": 456,
        "user_id": 5,
        "notes": "Customer order - Table 5",
        "transaction_date": "2025-01-31T10:35:00.000Z"
      }
    ],
    "pagination": {
      "total": 5,
      "limit": 20,
      "offset": 0
    }
  }
}
```

## Error Handling

### Insufficient Stock
```json
{
  "success": false,
  "message": "Insufficient stock. Available: 2, Required: 3 units"
}
```

### Unit Not Found
```json
{
  "success": false,
  "message": "No stock available for Full Bottle. Base unit (Full Bottle) required."
}
```

### Invalid Unit
```json
{
  "success": false,
  "message": "Unit not found for this product"
}
```

## Complete Workflow Example

```bash
# 1. Add 10 bottles
POST /api/stock/add
{
  "productId": 15,
  "unitId": 1,
  "quantity": 10,
  "notes": "Delivery from supplier"
}
# Result: 10 bottles added

# 2. Check stock
GET /api/stock/level/15
# Result: Full Bottle = 10 units

# 3. Sell 1 × 30ml peg
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 3,
  "quantity": 1
}
# Result: Full Bottle = 9 units (1 bottle used for 30ml peg)

# 4. Sell 2 × 60ml pegs
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 4,
  "quantity": 2
}
# Result: Full Bottle = 8 units (another bottle used for 120ml total)

# 5. Check transactions
GET /api/stock/transactions/15
# Result: Shows 2 REMOVE transactions totaling 150ml sold
```

## Database View of Operations

After the above workflow:

```sql
-- Stock Balance
SELECT unit_id, unit_name, current_quantity 
FROM stock_balance sb
JOIN product_units pu ON sb.unit_id = pu.id
WHERE product_id = 15;

-- Result:
-- unit_id=1, unit_name=Full Bottle, current_quantity=8
```

```sql
-- Transaction Log
SELECT transaction_type, unit_id, quantity, quantity_in_ml, notes
FROM stock_transactions
WHERE product_id = 15
ORDER BY id DESC;

-- Result:
-- REMOVE, 4, 2, 120, Customer order (60ml × 2)
-- REMOVE, 3, 1, 30,  Customer order (30ml × 1)
-- ADD,    1, 10, 7500, Delivery from supplier
```

## Best Practices

1. **Always use serving unit IDs** (3, 4, 5) when customers order pegs
2. **Never create stock_balance entries** for serving units - they're calculated
3. **Use variants** for fixed serving sizes that appear in menu
4. **Monitor base unit stock** to know actual bottle availability
5. **Check quantity_in_ml** in transactions for accurate consumption tracking
6. **Use product variants endpoint** if you have pre-defined serving sizes
7. **Set ml_capacity** correctly for all units during setup

## Troubleshooting

**Issue: Getting "No stock available" error when base unit has stock**
- Solution: Ensure the serving unit has `is_base_unit = 0` and base unit has `is_base_unit = 1`

**Issue: Stock not being deducted from full bottles**
- Solution: Ensure `ml_capacity` is set for all units (750 for full bottle, 30/60/90 for pegs)

**Issue: Incorrect bottle count being deducted**
- Solution: Verify the unit's `ml_capacity` matches actual bottle size

**Issue: Negative stock showing**
- Solution: Update query uses `GREATEST(0, ...)` to prevent negatives. Check for concurrent requests.
