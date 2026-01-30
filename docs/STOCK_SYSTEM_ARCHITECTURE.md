# Stock Management System - Visual Architecture

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CHEFMATE POS SYSTEM                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              CLIENT APPLICATION                      │  │
│  │  (Web/Mobile - POS Terminal, Admin Dashboard)       │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                    │
│                       │ HTTP REST API                      │
│                       │                                    │
│  ┌────────────────────▼─────────────────────────────────┐  │
│  │              API Gateway (Express)                   │  │
│  │  Route: /api/stock/{endpoint}                        │  │
│  │  Middleware: Authentication, Validation              │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                    │
│    ┌──────────────────┴──────────────────┐                 │
│    │                                     │                 │
│  ┌─▼────────────────────┐    ┌──────────▼──────────┐      │
│  │  Stock Controller    │    │ Other Controllers  │      │
│  │  ─────────────────   │    │ (User, Bill, etc)  │      │
│  │  - addStock()        │    └────────────────────┘      │
│  │  - removeStock()     │                                 │
│  │  - getStockLevel()   │                                 │
│  │  - removeVariant()   │                                 │
│  │  - getVariants()     │                                 │
│  │  - etc...            │                                 │
│  └─────────────┬────────┘                                 │
│                │                                          │
│  ┌─────────────▼──────────────────────────────────────┐  │
│  │         Stock Service Layer                        │  │
│  │  ─────────────────────────────────────────        │  │
│  │  ✓ Smart stock deduction                           │  │
│  │  ✓ Unit conversions                                │  │
│  │  ✓ Variant management                              │  │
│  │  ✓ Audit trail                                     │  │
│  │  ✓ Stock alerts                                    │  │
│  └─────────────┬──────────────────────────────────────┘  │
│                │                                          │
│                │ Database Queries                         │
│                │                                          │
│  ┌─────────────▼──────────────────────────────────────┐  │
│  │           MySQL Database                           │  │
│  │  ─────────────────────────────────────────        │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────────┐       │  │
│  │  │  product_units                         │       │  │
│  │  │  ─────────────                         │       │  │
│  │  │  - id, product_id                      │       │  │
│  │  │  - unit_name (Bottle, Can, Peg)       │       │  │
│  │  │  - ml_capacity                         │       │  │
│  │  │  - selling_price                       │       │  │
│  │  └────────────────────────────────────────┘       │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────────┐       │  │
│  │  │  stock_conversions                     │       │  │
│  │  │  ──────────────────                    │       │  │
│  │  │  - from_unit_id, to_unit_id           │       │  │
│  │  │  - conversion_factor (25, 12.5, etc)  │       │  │
│  │  └────────────────────────────────────────┘       │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────────┐       │  │
│  │  │  stock_balance                         │       │  │
│  │  │  ───────────────                       │       │  │
│  │  │  - product_id, unit_id                 │       │  │
│  │  │  - current_quantity                    │       │  │
│  │  │  - available_quantity (calc field)     │       │  │
│  │  └────────────────────────────────────────┘       │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────────┐       │  │
│  │  │  stock_transactions (Audit Trail)      │       │  │
│  │  │  ──────────────────────────────────    │       │  │
│  │  │  - transaction_type (ADD, REMOVE)      │       │  │
│  │  │  - quantity, reference_id              │       │  │
│  │  │  - user_id, timestamp                  │       │  │
│  │  └────────────────────────────────────────┘       │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────────┐       │  │
│  │  │  product_variants                      │       │  │
│  │  │  ──────────────────                    │       │  │
│  │  │  - variant_name (30ML Peg, 60ML)       │       │  │
│  │  │  - quantity_in_base_unit (0.04)        │       │  │
│  │  │  - selling_price                       │       │  │
│  │  └────────────────────────────────────────┘       │  │
│  │                                                    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 🔄 Unit Conversion & Inventory Flow

### Whiskey Example (750ML Bottle)

```
┌─────────────────────────────────────────────────────┐
│           WHISKEY INVENTORY MANAGEMENT               │
└─────────────────────────────────────────────────────┘

UNITS DEFINED:
┌──────────┐
│ Bottle   │  (Base Unit)
│ 750ML    │  is_base_unit = 1
│ ID = 1   │
└──────────┘
     │
     │  conversion_factor = 25
     │  conversion_factor = 12.5
     ▼
┌──────────┐    ┌──────────┐
│ 30ML Peg │    │ 60ML Peg │  (Derived Units)
│ ID = 2   │    │ ID = 3   │
└──────────┘    └──────────┘

PURCHASE FLOW:
                  
Supplier ships 12 bottles
                  │
                  ▼
┌──────────────────────────────┐
│ POST /api/stock/add          │
│ {                            │
│   productId: 126             │
│   unitId: 1                  │
│   quantity: 12               │
│   referenceType: "PURCHASE"  │
│ }                            │
└──────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────┐
│ stock_balance table:             │
│ ───────────────────────────────  │
│ product_id | unit_id | quantity  │
│ ─────────────────────────────── │
│    126     |   1     |    12     │  (Bottles)
│    126     |   2     |   0       │  (30ML Pegs)
│    126     |   3     |   0       │  (60ML Pegs)
└──────────────────────────────────┘

SALES FLOW (Selling 30ML Pegs):

Customer orders: 2 × 30ML Pegs (₹150 each)
                  │
                  ▼
┌──────────────────────────────────┐
│ POST /api/stock/remove-variant   │
│ {                                │
│   productId: 126                 │
│   variantId: 5  (30ML Peg)       │
│   quantity: 2                    │
│   referenceId: 1001 (Bill ID)    │
│ }                                │
└──────────────────────────────────┘
                  │
     ┌────────────┴────────────┐
     │                         │
     ▼                         ▼
 Calculate what              Record
 to remove from             transaction
 base unit:                 
 - variant uses              
   0.04 bottles              
   per peg                   
 - 2 pegs = 0.08             
   bottles to               
   remove                   

     │
     ▼
┌────────────────────────────────────┐
│ UPDATE stock_balance:              │
│ ──────────────────────────────     │
│ product_id | unit_id | quantity    │
│ ────────────────────────────────  │
│    126     |   1     |  11.92      │  ← Removed 0.08
│    126     |   2     |   0         │
│    126     |   3     |   0         │
└────────────────────────────────────┘

INSERT INTO stock_transactions:
- transaction_type: REMOVE
- quantity: 0.08 (bottles)
- quantity_in_ml: 60 (ML removed)
- reference_type: SALE
- reference_id: 1001 (Bill ID)
- notes: "2x 30ML pegs sold"

RESULT:
✓ 11.92 bottles in stock
✓ 60ML tracked and removed
✓ Transaction recorded
✓ Bill reference linked
✓ User tracked
```

---

## 📊 API Request/Response Flow

### Add Stock Request

```
CLIENT REQUEST:
┌─────────────────────────────────────┐
│ POST /api/stock/add                 │
│ Authorization: Bearer TOKEN         │
│ Content-Type: application/json      │
│                                     │
│ {                                   │
│   "productId": 126,                 │
│   "unitId": 1,                      │
│   "quantity": 10,                   │
│   "referenceType": "PURCHASE",      │
│   "referenceId": 301,               │
│   "notes": "New supply"             │
│ }                                   │
└─────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ VALIDATION (express-validator)   │
│ ────────────────────────────────│
│ ✓ productId is integer           │
│ ✓ unitId is integer              │
│ ✓ quantity > 0                   │
│ ✓ referenceType is string        │
└──────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Stock Controller                 │
│ ────────────────────────────────│
│ Call: stockService.addStock()    │
└──────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Stock Service                    │
│ ────────────────────────────────│
│ 1. Start transaction             │
│ 2. Validate product & unit       │
│ 3. Record transaction            │
│ 4. Update/Create balance         │
│ 5. Commit transaction            │
└──────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Database Updates                 │
│ ────────────────────────────────│
│ INSERT INTO stock_transactions   │
│ UPDATE stock_balance             │
└──────────────────────────────────┘
         │
         ▼
SERVER RESPONSE:
┌────────────────────────────────────┐
│ HTTP 200 OK                        │
│ Content-Type: application/json     │
│                                    │
│ {                                  │
│   "success": true,                 │
│   "message": "Stock added...",     │
│   "data": {                        │
│     "productId": 126,              │
│     "unitId": 1,                   │
│     "quantity": 10,                │
│     "timestamp": "2025-01-29..."   │
│   }                                │
│ }                                  │
└────────────────────────────────────┘
```

---

## 🎯 Variant-Based Sales Flow

```
CUSTOMER ORDERS:
2 × Whiskey 30ML Peg @ ₹150

                  │
                  ▼
┌─────────────────────────────────────┐
│ POST /api/stock/remove-variant      │
│ {                                   │
│   productId: 126                    │
│   variantId: 5                      │
│   quantity: 2                       │
│   referenceId: 1001 (Bill ID)       │
│ }                                   │
└─────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ VARIANT LOOKUP                           │
│ ─────────────────────────────────────   │
│ variant_id = 5                           │
│ variant_name = "30ML Peg"               │
│ base_unit_id = 1 (Bottle)               │
│ quantity_in_base_unit = 0.04            │
│ ml_quantity = 30                         │
│ selling_price = 150                      │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ CALCULATE DEDUCTION                      │
│ ─────────────────────────────────────   │
│ qty to sell = 2 pegs                     │
│ qty per peg = 0.04 bottles              │
│ total = 2 × 0.04 = 0.08 bottles        │
│ ml removed = 2 × 30 = 60 ML             │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ CHECK AVAILABILITY                       │
│ ─────────────────────────────────────   │
│ required: 0.08 bottles                   │
│ available: 11.92 bottles                 │
│ status: ✓ SUFFICIENT                     │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ RECORD TRANSACTION                       │
│ ─────────────────────────────────────   │
│ INSERT INTO stock_transactions:          │
│   - transaction_type: REMOVE            │
│   - unit_id: 1 (Bottle)                 │
│   - quantity: 0.08                       │
│   - quantity_in_ml: 60                   │
│   - reference_type: SALE                │
│   - reference_id: 1001                   │
│   - notes: "2x 30ML pegs..."            │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ UPDATE INVENTORY                         │
│ ─────────────────────────────────────   │
│ UPDATE stock_balance:                    │
│   current_quantity = 11.92 - 0.08       │
│                    = 11.84               │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ RESPONSE                                 │
│ ─────────────────────────────────────   │
│ {                                        │
│   "success": true,                       │
│   "data": {                              │
│     "variantName": "30ML Peg",          │
│     "quantitySold": 2,                   │
│     "baseUnitQuantityRemoved": 0.08,    │
│     "mlRemoved": 60                      │
│   }                                      │
│ }                                        │
└──────────────────────────────────────────┘
```

---

## 📊 Stock Report Generation

```
GET /api/stock/report/126

                  │
                  ▼
┌────────────────────────────────────┐
│ GATHER DATA                        │
│ ──────────────────────────────    │
│ 1. Get product info               │
│ 2. Get all units & balances       │
│ 3. Get all variants               │
│ 4. Get recent transactions (50)   │
└────────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────┐
│ RESPONSE                                   │
│ ──────────────────────────────────────   │
│ {                                          │
│   "product": {                             │
│     "id": 126,                             │
│     "iname": "Whiskey",                    │
│   },                                       │
│   "currentStock": [                        │
│     {                                      │
│       "unit_name": "Bottle",              │
│       "current_quantity": 11.84,          │
│       "ml_capacity": 750                  │
│     }                                      │
│   ],                                       │
│   "variants": [                            │
│     {                                      │
│       "variant_name": "30ML Peg",         │
│       "selling_price": 150,                │
│       "ml_quantity": 30                    │
│     }                                      │
│   ],                                       │
│   "recentTransactions": [                  │
│     {                                      │
│       "transaction_type": "REMOVE",       │
│       "quantity": 0.08,                    │
│       "reference_type": "SALE",            │
│       "transaction_date": "..."            │
│     }                                      │
│   ]                                        │
│ }                                          │
└────────────────────────────────────────────┘
```

---

## 🚨 Low Stock Alert System

```
SCHEDULED CHECK (e.g., every 5 minutes):

                  │
                  ▼
┌──────────────────────────────────┐
│ GET /api/stock/alerts/low-stock  │
└──────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│ DATABASE QUERY                           │
│ ──────────────────────────────────────  │
│ SELECT items WHERE                       │
│   stock_balance.available_quantity <     │
│   items.min_stock                        │
│                                          │
│ CALCULATE ALERT LEVEL:                   │
│ IF qty <= 0: OUT_OF_STOCK                │
│ IF qty < min_stock/2: CRITICAL           │
│ IF qty < min_stock: LOW                  │
└──────────────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────┐
│ RESPONSE                                   │
│ ──────────────────────────────────────   │
│ {                                          │
│   "data": [                                │
│     {                                      │
│       "product_name": "Whiskey",          │
│       "min_stock": 10,                     │
│       "current_quantity": 3,               │
│       "alert_level": "CRITICAL"            │
│     },                                     │
│     {                                      │
│       "product_name": "Coke",             │
│       "min_stock": 100,                    │
│       "current_quantity": 45,              │
│       "alert_level": "LOW"                 │
│     }                                      │
│   ]                                        │
│ }                                          │
└────────────────────────────────────────────┘
                  │
                  ▼
         ALERT ON DASHBOARD
        (Show to manager/owner)
              │
              ▼
        ORDER MORE STOCK!
```

---

## 🔐 Security & Validation Flow

```
CLIENT REQUEST WITH INVALID DATA:

POST /api/stock/add
{
  "productId": "invalid",
  "unitId": -1,
  "quantity": -5
}

                  │
                  ▼
┌─────────────────────────────────────┐
│ EXPRESS-VALIDATOR VALIDATION        │
│ ─────────────────────────────────  │
│ ✗ productId must be integer         │
│ ✗ unitId must be > 0               │
│ ✗ quantity must be > 0              │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ VALIDATION ERROR RESPONSE           │
│ ─────────────────────────────────  │
│ HTTP 400 Bad Request                │
│ {                                   │
│   "success": false,                 │
│   "errors": [                       │
│     {                               │
│       "param": "productId",         │
│       "msg": "must be integer"      │
│     },                              │
│     {                               │
│       "param": "unitId",            │
│       "msg": "must be > 0"          │
│     },                              │
│     {                               │
│       "param": "quantity",          │
│       "msg": "must be > 0"          │
│     }                               │
│   ]                                 │
│ }                                   │
└─────────────────────────────────────┘
```

---

## 📈 Database Relationships

```
items (from existing database)
  │
  └─────────────┬─────────────┬──────────────┐
                │             │              │
                ▼             ▼              ▼
          product_units  product_variants  stock_balance
                │             │              │
                │             │              │
                ├─────────────┼──────────────┤
                │             │              │
                ▼             ▼              ▼
          stock_conversions  (uses)    stock_transactions
                │             │              │
                │             │              │
                └─────────────┴──────────────┘
                         │
                    (references)
                         │
                    user_id,
                    bill_id,
                    order_id
```

---

This visual architecture helps understand how all components work together!
