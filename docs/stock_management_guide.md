# Advanced Stock Management System - Implementation Guide

## Overview

This system provides intelligent inventory management with support for complex unit conversions, particularly useful for restaurants and bars with items like liquor that can be sold in multiple serving sizes.

## Features

### 1. **Smart Unit Management**
- Support for multiple units per product (Bottle, Can, Piece, ML, Peg, etc.)
- Base units and derived units
- ML capacity tracking for liquor bottles
- Base unit and conversion factor support

### 2. **Intelligent Stock Deduction**
- Regular unit-based deduction (Add/Remove by unit)
- Variant-based deduction (Sell in different serving sizes)
- Automatic conversion from base units
- ML-level tracking for liquor

### 3. **Product Variants**
- Define serving sizes for products
- Example: 30ML Peg, 60ML, Full Bottle for Whiskey
- Automatic cost and stock calculation
- Variable selling prices per variant

### 4. **Stock Conversions**
- Define conversion rules between units
- Example: 1 Bottle = 25 pegs of 30ML
- Bidirectional conversions
- Decimal support for precise calculations

### 5. **Complete Audit Trail**
- All stock transactions recorded
- Reference tracking (Purchase, Sale, Waste, Adjustment)
- User tracking
- Timestamp and notes

### 6. **Stock Alerts**
- Low stock warnings
- Out of stock alerts
- Critical stock levels
- Min stock configuration per product

---

## Database Schema

### Tables Created

1. **product_units** - Defines units for each product
2. **stock_conversions** - Defines conversion rules between units
3. **stock_transactions** - Audit trail of all stock movements
4. **stock_balance** - Real-time stock levels
5. **product_variants** - Product serving size variants

### SQL Installation

```bash
# Run the migration SQL
mysql -u username -p database_name < database/create_stock_management_schema.sql
```

---

## API Endpoints

### Base URL: `/api/stock`

All endpoints require authentication (`Authorization` header with JWT token)

---

## 1. STOCK OPERATIONS

### Add Stock

**POST** `/api/stock/add`

Add new stock to inventory.

**Request Body:**
```json
{
  "productId": 126,
  "unitId": 1,
  "quantity": 10,
  "referenceType": "PURCHASE",
  "referenceId": 301,
  "notes": "New bottle supply from supplier"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Stock added successfully",
  "data": {
    "productId": 126,
    "unitId": 1,
    "quantity": 10,
    "timestamp": "2025-01-29T10:30:00Z"
  }
}
```

---

### Remove Stock

**POST** `/api/stock/remove`

Remove stock from inventory (for waste, damage, etc.).

**Request Body:**
```json
{
  "productId": 126,
  "unitId": 1,
  "quantity": 2,
  "referenceType": "DAMAGE",
  "notes": "Damaged bottles"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "productId": 126,
    "unitId": 1,
    "quantity": 2,
    "timestamp": "2025-01-29T10:35:00Z"
  }
}
```

---

### Remove Stock Using Variant

**POST** `/api/stock/remove-variant`

Smart deduction for liquor - sell in serving sizes (30ML peg, 60ML, etc.).

**Request Body:**
```json
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": 1001,
  "notes": "2x 30ML pegs sold at Table 5"
}
```

**Example Scenario:**
- Product: Whiskey Bottle (750ML)
- Variant: 30ML Peg
- Quantity: 2 pegs
- Action: Removes 0.08 bottles (2 × 0.04) from inventory

**Response:**
```json
{
  "success": true,
  "message": "Stock removed successfully",
  "data": {
    "productId": 126,
    "variantId": 5,
    "variantName": "30ML Peg - Whiskey",
    "quantitySold": 2,
    "baseUnitQuantityRemoved": 0.08,
    "mlRemoved": 60
  }
}
```

---

## 2. STOCK INQUIRY

### Get Stock Level

**GET** `/api/stock/level/:productId`

Get current stock for all units of a product.

**Query Parameters:**
- `unitId` (optional) - Get stock for specific unit only

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 126,
      "unit_id": 1,
      "unit_name": "Bottle",
      "ml_capacity": 750,
      "current_quantity": 8.92,
      "reserved_quantity": 0,
      "available_quantity": 8.92,
      "product_name": "Whiskey"
    },
    {
      "id": 2,
      "product_id": 126,
      "unit_id": 2,
      "unit_name": "30ML Peg",
      "ml_capacity": 30,
      "current_quantity": 100,
      "reserved_quantity": 10,
      "available_quantity": 90,
      "product_name": "Whiskey"
    }
  ]
}
```

---

### Get All Stock

**GET** `/api/stock/all`

Get complete inventory across all products.

**Query Parameters:**
- `categoryId` (optional) - Filter by category
- `minStock=true` (optional) - Show only low stock items

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 126,
      "product_name": "Whiskey",
      "min_stock": 5,
      "unit_id": 1,
      "unit_name": "Bottle",
      "current_quantity": 8.92,
      "available_quantity": 8.92
    }
  ],
  "count": 15
}
```

---

### Get Stock Report

**GET** `/api/stock/report/:productId`

Complete stock report for a product including variants and transactions.

**Response:**
```json
{
  "success": true,
  "data": {
    "product": {
      "id": 126,
      "iname": "Whiskey",
      "unit": "bottle"
    },
    "currentStock": [
      {
        "unit_id": 1,
        "unit_name": "Bottle",
        "current_quantity": 8.92,
        "available_quantity": 8.92
      }
    ],
    "variants": [
      {
        "id": 5,
        "variant_name": "30ML Peg - Whiskey",
        "selling_price": 150,
        "ml_quantity": 30
      }
    ],
    "recentTransactions": [
      {
        "id": 1,
        "transaction_type": "REMOVE",
        "unit_name": "Bottle",
        "quantity": 0.08,
        "quantity_in_ml": 60,
        "reference_type": "SALE",
        "transaction_date": "2025-01-29T10:30:00Z"
      }
    ]
  }
}
```

---

### Get Transaction History

**GET** `/api/stock/history/:productId`

Get detailed transaction history for a product.

**Query Parameters:**
- `limit=50` - Records per page (max 500)
- `offset=0` - Page offset
- `type` - Filter by type (ADD|REMOVE|SALE|ADJUST)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1001,
      "transaction_type": "REMOVE",
      "quantity": 0.08,
      "unit_name": "Bottle",
      "reference_type": "SALE",
      "transaction_date": "2025-01-29T10:30:00Z"
    }
  ],
  "limit": 50,
  "offset": 0
}
```

---

### Get Low Stock Alerts

**GET** `/api/stock/alerts/low-stock`

Get all items below minimum stock level.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 126,
      "product_name": "Whiskey",
      "min_stock": 10,
      "current_quantity": 3.5,
      "alert_level": "CRITICAL"
    },
    {
      "id": 127,
      "product_name": "Coke",
      "min_stock": 100,
      "current_quantity": 45,
      "alert_level": "LOW"
    }
  ],
  "count": 2
}
```

---

## 3. UNIT MANAGEMENT

### Get All Units for Product

**GET** `/api/stock/units/:productId`

Get all units defined for a product.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 126,
      "unit_name": "Bottle",
      "unit_type": "BASE",
      "is_base_unit": 1,
      "ml_capacity": 750,
      "selling_price": 3000
    },
    {
      "id": 2,
      "product_id": 126,
      "unit_name": "30ML Peg",
      "unit_type": "DERIVED",
      "is_base_unit": 0,
      "ml_capacity": 30,
      "selling_price": 150
    }
  ]
}
```

---

### Create Product Unit

**POST** `/api/stock/units/create`

Create a new unit for a product.

**Request Body:**
```json
{
  "productId": 126,
  "unitName": "60ML Peg",
  "unitType": "DERIVED",
  "mlCapacity": 60,
  "sellingPrice": 300,
  "purchasePrice": 250
}
```

**Response:**
```json
{
  "success": true,
  "message": "Unit created successfully",
  "data": {
    "id": 3,
    "productId": 126,
    "unitName": "60ML Peg",
    "mlCapacity": 60,
    "sellingPrice": 300
  }
}
```

---

## 4. UNIT CONVERSIONS

### Get Conversion Rules

**GET** `/api/stock/conversions/:productId`

Get all conversion rules for a product.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 126,
      "from_unit": "Bottle",
      "from_unit_id": 1,
      "to_unit": "30ML Peg",
      "to_unit_id": 2,
      "conversion_factor": 25
    },
    {
      "id": 2,
      "product_id": 126,
      "from_unit": "Bottle",
      "from_unit_id": 1,
      "to_unit": "60ML Peg",
      "to_unit_id": 3,
      "conversion_factor": 12.5
    }
  ]
}
```

---

### Create Conversion Rule

**POST** `/api/stock/conversions/create`

Create a conversion rule between two units.

**Request Body:**
```json
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 2,
  "conversionFactor": 25
}
```

**Meaning:** 1 Bottle = 25 pegs of 30ML

**Response:**
```json
{
  "success": true,
  "message": "Conversion rule created successfully",
  "data": {
    "id": 1,
    "productId": 126,
    "fromUnitId": 1,
    "toUnitId": 2,
    "conversionFactor": 25
  }
}
```

---

### Convert Units

**POST** `/api/stock/convert`

Convert a quantity from one unit to another.

**Request Body:**
```json
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 2,
  "quantity": 2
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "from": {
      "unitId": 1,
      "unitName": "Bottle",
      "quantity": 2,
      "mlCapacity": 750
    },
    "to": {
      "unitId": 2,
      "unitName": "30ML Peg",
      "quantity": 50,
      "mlCapacity": 30
    },
    "conversionFactor": 25
  }
}
```

---

## 5. PRODUCT VARIANTS

### Get Product Variants

**GET** `/api/stock/variants/:productId`

Get all serving size variants for a product.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "product_id": 126,
      "variant_name": "30ML Peg - Whiskey",
      "base_unit_id": 1,
      "base_unit_name": "Bottle",
      "quantity_in_base_unit": 0.04,
      "ml_quantity": 30,
      "selling_price": 150,
      "cost_price": 120
    },
    {
      "id": 6,
      "product_id": 126,
      "variant_name": "60ML Peg - Whiskey",
      "base_unit_id": 1,
      "base_unit_name": "Bottle",
      "quantity_in_base_unit": 0.08,
      "ml_quantity": 60,
      "selling_price": 300,
      "cost_price": 240
    },
    {
      "id": 7,
      "product_id": 126,
      "variant_name": "Full Bottle - Whiskey",
      "base_unit_id": 1,
      "base_unit_name": "Bottle",
      "quantity_in_base_unit": 1,
      "ml_quantity": 750,
      "selling_price": 3000,
      "cost_price": 2400
    }
  ]
}
```

---

### Create Product Variant

**POST** `/api/stock/variants/create`

Create a new serving size variant for a product.

**Request Body:**
```json
{
  "productId": 126,
  "variantName": "30ML Peg - Whiskey",
  "baseUnitId": 1,
  "quantityInBaseUnit": 0.04,
  "mlQuantity": 30,
  "sellingPrice": 150,
  "costPrice": 120
}
```

**Explanation:**
- 30ML peg is based on Bottle unit
- 1 peg = 0.04 bottles (30/750)
- Selling price: ₹150 per peg
- Cost price: ₹120 per peg

**Response:**
```json
{
  "success": true,
  "message": "Variant created successfully",
  "data": {
    "id": 5,
    "productId": 126,
    "variantName": "30ML Peg - Whiskey",
    "sellingPrice": 150,
    "mlQuantity": 30
  }
}
```

---

## Setup Examples

### Example 1: Setup Whiskey with Serving Sizes

```javascript
// Step 1: Create Base Unit (Bottle)
POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "Bottle",
  "unitType": "BASE",
  "mlCapacity": 750,
  "sellingPrice": 3000
}
// Response: unitId = 1

// Step 2: Create Derived Units
POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "30ML Peg",
  "unitType": "DERIVED",
  "mlCapacity": 30,
  "sellingPrice": 150
}
// Response: unitId = 2

POST /api/stock/units/create
{
  "productId": 126,
  "unitName": "60ML Peg",
  "unitType": "DERIVED",
  "mlCapacity": 60,
  "sellingPrice": 300
}
// Response: unitId = 3

// Step 3: Create Conversion Rules
POST /api/stock/conversions/create
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 2,
  "conversionFactor": 25  // 1 bottle = 25 pegs
}

POST /api/stock/conversions/create
{
  "productId": 126,
  "fromUnitId": 1,
  "toUnitId": 3,
  "conversionFactor": 12.5  // 1 bottle = 12.5 pegs
}

// Step 4: Create Variants for POS
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

POST /api/stock/variants/create
{
  "productId": 126,
  "variantName": "60ML Peg",
  "baseUnitId": 1,
  "quantityInBaseUnit": 0.08,
  "mlQuantity": 60,
  "sellingPrice": 300,
  "costPrice": 240
}

// Step 5: Add Stock
POST /api/stock/add
{
  "productId": 126,
  "unitId": 1,
  "quantity": 12,
  "referenceType": "PURCHASE",
  "referenceId": 301,
  "notes": "Supply from supplier"
}

// Step 6: Sell 30ML Peg
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": 1001,
  "notes": "2x 30ML pegs sold"
}
```

---

### Example 2: Setup Coke (Can/Piece)

```javascript
// Step 1: Create Base Unit
POST /api/stock/units/create
{
  "productId": 127,
  "unitName": "Can",
  "unitType": "BASE",
  "sellingPrice": 80
}
// Response: unitId = 1

// Step 2: Create Crate Unit
POST /api/stock/units/create
{
  "productId": 127,
  "unitName": "Crate",
  "unitType": "DERIVED",
  "sellingPrice": 0
}
// Response: unitId = 2

// Step 3: Create Conversion
POST /api/stock/conversions/create
{
  "productId": 127,
  "fromUnitId": 2,
  "toUnitId": 1,
  "conversionFactor": 24  // 1 crate = 24 cans
}

// Step 4: Add Stock by Crate
POST /api/stock/add
{
  "productId": 127,
  "unitId": 2,
  "quantity": 10,
  "referenceType": "PURCHASE",
  "notes": "10 crates received"
}

// Step 5: Remove Individual Cans for Sale
POST /api/stock/remove
{
  "productId": 127,
  "unitId": 1,
  "quantity": 3,
  "referenceType": "SALE",
  "referenceId": 1001,
  "notes": "3 cans sold at Table 5"
}
```

---

## Error Handling

All endpoints return standardized error responses:

```json
{
  "success": false,
  "message": "Error description"
}
```

Common errors:
- `Product not found` - Invalid productId
- `Unit not found for this product` - Invalid unitId
- `Insufficient stock` - Not enough stock available
- `No conversion rule found` - Conversion doesn't exist
- `Variant not found` - Invalid variantId

---

## Best Practices

1. **Always create Base Units first** - Variants and conversions depend on base units
2. **Use ML capacity for liquor** - Helps with serving size calculations
3. **Record all transactions** - Maintain audit trail with reference IDs
4. **Set min stock levels** - Configure min_stock in items table for alerts
5. **Use variants for POS** - Simplifies selling different serving sizes
6. **Regular stock reconciliation** - Use stock reports to verify counts

---

## Integration with POS

### When taking an order with variants:

```javascript
// User selects: Whiskey - 30ML Peg (Qty: 2)
const sale = {
  billId: 1001,
  items: [
    {
      productId: 126,
      variantId: 5,
      quantity: 2,
      price: 150,
      total: 300
    }
  ]
};

// Remove from stock
POST /api/stock/remove-variant
{
  "productId": 126,
  "variantId": 5,
  "quantity": 2,
  "referenceId": 1001,
  "notes": "Sold at Table 5"
}

// This automatically:
// - Removes 0.08 bottles from stock
// - Records transaction as SALE
// - Maintains ML tracking (60ML removed)
```

---

## Future Enhancements

- [ ] Stock reservations for pending orders
- [ ] Batch operations
- [ ] Stock movement between locations
- [ ] Expiry date tracking
- [ ] Damage and waste reports
- [ ] Stock reconciliation batch upload
- [ ] Historical stock valuation

---

## Support

For issues or questions about the stock management system, review:
- Database schema: `database/create_stock_management_schema.sql`
- Service layer: `services/stockService.js`
- Controller: `controllers/stockController.js`
- Routes: `routes/stockRoutes.js`
