# Liquor Stock Deduction - VISUAL GUIDE

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    POS / Order System                        │
│         (Customer orders 30ml peg of Vodka)                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  POST /api/stock/remove    │
        │  {                         │
        │    productId: 15,          │
        │    unitId: 3,    (30ml)    │
        │    quantity: 1             │
        │  }                         │
        └────────────┬───────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │   Stock Service: removeStock()         │
        │   ✓ Check if unit is serving unit      │
        │   ✓ Get base unit (Full Bottle)        │
        │   ✓ Convert ML: 30ml ÷ 750ml           │
        │   ✓ Math.ceil() = 1 bottle needed      │
        │   ✓ Check availability (10 bottles)    │
        │   ✓ Deduct 1 from stock_balance        │
        └────────────┬───────────────────────────┘
                     │
                     ▼
        ┌──────────────────────────────────────────────┐
        │        Database Update                        │
        ├──────────────────────────────────────────────┤
        │ 1. stock_balance UPDATE                      │
        │    WHERE unit_id=1 AND product_id=15        │
        │    SET current_quantity = 9  (10-1)         │
        │                                              │
        │ 2. stock_transactions INSERT                 │
        │    unit_id: 3 (30ml Peg)                     │
        │    quantity: 1 (1 peg)                       │
        │    quantity_in_ml: 30 (30ml)                 │
        │    notes: "Customer order"                   │
        └──────────────────────┬───────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  Response to Client   │
                    ├──────────────────────┤
                    │ success: true         │
                    │ deductedFromUnit: 1   │
                    │ deductedQuantity: 1   │
                    │ deductedInMl: 30      │
                    └──────────────────────┘
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                      REQUEST LIFECYCLE                              │
└─────────────────────────────────────────────────────────────────────┘

STEP 1: CUSTOMER ORDER
────────────────────────────────────────────────────────────────────
    POS System              Request                Stock Service
    ─────────────           ───────                ──────────────
    [Customer orders    →   POST /api/stock/remove  →  Check unit
     30ml peg]                                         validation


STEP 2: UNIT INTELLIGENCE
────────────────────────────────────────────────────────────────────
    Requested Unit          Base Unit               Decision
    ──────────────          ─────────               ────────
    30ml Peg (id=3)    →   Full Bottle (id=1)  →  "Use base unit
    is_base_unit: 0        is_base_unit: 1         for deduction"
    ml_capacity: 30        ml_capacity: 750


STEP 3: CALCULATION
────────────────────────────────────────────────────────────────────
    ML Needed       ÷   Base Unit Size    =    Bottles Needed
    ─────────          ──────────────           ───────────
    1 × 30ml        ÷   750ml            =    0.04 bottles
                                              (ceiling = 1)


STEP 4: AVAILABILITY CHECK
────────────────────────────────────────────────────────────────────
    Available               Required         Status
    ─────────               ────────         ──────
    10 bottles          ≥   1 bottle    →    ✅ PROCEED


STEP 5: DATABASE UPDATE
────────────────────────────────────────────────────────────────────
    Table: stock_balance
    ┌──────────────────────────────────┐
    │ product_id │ unit_id │ quantity  │
    ├──────────────────────────────────┤
    │ 15         │ 1       │ 10  → 9   │  ← DEDUCT 1 BOTTLE
    │ 15         │ 3       │ 0         │  ← NO CHANGE
    └──────────────────────────────────┘

    Table: stock_transactions
    ┌──────────────────────────────────────────────┐
    │ unit_id │ quantity │ quantity_in_ml │ type   │
    ├──────────────────────────────────────────────┤
    │ 3       │ 1        │ 30             │ REMOVE │  ← NEW ENTRY
    └──────────────────────────────────────────────┘


STEP 6: RESPONSE
────────────────────────────────────────────────────────────────────
    {
      success: true,
      deductedFromUnit: 1,          ← Actual deduction source
      deductedQuantity: 1,          ← Full bottles deducted
      deductedInMl: 30              ← ML consumed
    }
```

---

## Before vs After

```
╔═══════════════════════════════════════════════════════════════════════╗
║                           BEFORE (BROKEN)                             ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  Customer Order: 1 × 30ml peg                                        ║
║                                                                       ║
║  System Logic:                                                        ║
║    1. Try to find: stock_balance                                     ║
║       WHERE unit_id = 3 (30ml Peg)                                   ║
║       AND product_id = 15                                            ║
║                                                                       ║
║    2. NOT FOUND (serving units don't have stock entries)             ║
║                                                                       ║
║    3. Result: Deduct 1 full bottle anyway (DEFAULT FALLBACK)         ║
║                                                                       ║
║    ❌ WRONG: Customer gets 30ml, loses 750ml from inventory          ║
║    ❌ WRONG: No ML tracking                                          ║
║    ❌ WRONG: Stock rapidly depletes                                  ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════════╗
║                           AFTER (FIXED)                               ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  Customer Order: 1 × 30ml peg                                        ║
║                                                                       ║
║  System Logic:                                                        ║
║    1. Identify unit: 30ml Peg                                        ║
║       is_base_unit = 0 ✓ (serving unit detected)                     ║
║                                                                       ║
║    2. Find base unit: Full Bottle                                    ║
║       is_base_unit = 1 ✓                                             ║
║       ml_capacity = 750 ✓                                            ║
║                                                                       ║
║    3. Calculate bottles: 30 ÷ 750 = 0.04                             ║
║       Math.ceil(0.04) = 1 bottle                                     ║
║                                                                       ║
║    4. Check stock_balance (Full Bottle): 10 available ✓              ║
║                                                                       ║
║    5. Deduct from Full Bottle: 10 - 1 = 9                            ║
║                                                                       ║
║    6. Log transaction:                                               ║
║       - unit_id: 3 (30ml Peg)                                        ║
║       - quantity: 1 (peg)                                            ║
║       - quantity_in_ml: 30 (ML consumed)                             ║
║                                                                       ║
║    ✅ CORRECT: 30ml removed from 750ml bottle inventory              ║
║    ✅ CORRECT: Accurate ML tracking                                  ║
║    ✅ CORRECT: Realistic stock depletion                             ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

---

## Stock Balance Examples

### Scenario: Vodka Bottle (750ml)

```
AFTER ADDING 10 BOTTLES:
┌────────────────────────────────────┐
│ stock_balance for Vodka            │
├────────────────────────────────────┤
│ Full Bottle: 10 units              │  ← Only this has stock
│ 30ml Peg:    —  (no entry)         │  ← Calculated from base
│ 60ml Peg:    —  (no entry)         │  ← Calculated from base
│ 90ml Peg:    —  (no entry)         │  ← Calculated from base
└────────────────────────────────────┘

AFTER SELLING 1 × 30ML PEG:
┌────────────────────────────────────┐
│ stock_balance for Vodka            │
├────────────────────────────────────┤
│ Full Bottle: 9 units               │  ← Reduced by 1
│ 30ml Peg:    —  (no entry)         │  ← Still no entry needed
│ 60ml Peg:    —  (no entry)         │
│ 90ml Peg:    —  (no entry)         │
└────────────────────────────────────┘

AFTER SELLING 2 × 60ML PEGS:
┌────────────────────────────────────┐
│ stock_balance for Vodka            │
├────────────────────────────────────┤
│ Full Bottle: 8 units               │  ← Reduced by 1 more
│ 30ml Peg:    —  (no entry)         │     (120ml ÷ 750ml = 1 bottle)
│ 60ml Peg:    —  (no entry)         │
│ 90ml Peg:    —  (no entry)         │
└────────────────────────────────────┘
```

---

## Transaction Audit Trail

```
TIMELINE OF VODKA TRANSACTIONS:

Time    Action                    Unit            Qty    ML       Result
────────────────────────────────────────────────────────────────────────
10:00   ADD Stock                Full Bottle     10     7500     Balance: 10
10:15   SALE: 1×30ml Peg        30ml Peg        1      30       Balance: 9
10:30   SALE: 2×60ml Pegs       60ml Peg        2      120      Balance: 8
10:45   SALE: 1×90ml Peg        90ml Peg        1      90       Balance: 7
11:00   SALE: 3×30ml Pegs       30ml Peg        3      90       Balance: 6
────────────────────────────────────────────────────────────────────────
                                Total Sold:     7 pegs  330ml

CALCULATION CHECK:
Full Bottle: 750ml
Sold: 30 + 120 + 90 + 90 = 330ml
Remaining per bottle: 750 - 330 = 420ml
Bottles consumed: 330 ÷ 750 = 0.44 bottles
Actual bottles used: ceil(0.44) = 1 bottle (first bottle used for 330ml)

Inventory:
Started: 10 bottles × 750ml = 7500ml
Used: 1 bottle = 750ml
Remaining: 9 bottles × 750ml = 6750ml + 420ml = 7170ml ✓
Stock shows: 6 bottles (complete bottles) + partial (shown in transaction)
```

---

## API Call Sequence

```
REQUEST 1: Add Stock
──────────────────────────────────────────────────
POST /api/stock/add
{
  "productId": 15,
  "unitId": 1,
  "quantity": 10,
  "notes": "Delivery"
}

RESPONSE:
{ success: true, message: "Stock added" }

DATABASE STATE: stock_balance
  product_id: 15, unit_id: 1, current_quantity: 10


REQUEST 2: Sell 1 × 30ml Peg
──────────────────────────────────────────────────
POST /api/stock/remove
{
  "productId": 15,
  "unitId": 3,        ← 30ml Peg unit
  "quantity": 1
}

PROCESSING:
  ✓ Unit 3 is NOT base unit
  ✓ Base unit is 1 (Full Bottle, 750ml)
  ✓ Calculate: 1 × 30ml = 30ml
  ✓ Bottles needed: ceil(30 ÷ 750) = 1
  ✓ Check: 10 available ≥ 1 required ✓
  ✓ Deduct: 10 - 1 = 9
  ✓ Log transaction

RESPONSE:
{
  success: true,
  data: {
    deductedFromUnit: 1,
    deductedQuantity: 1,
    deductedInMl: 30
  }
}

DATABASE STATE: stock_balance
  product_id: 15, unit_id: 1, current_quantity: 9

DATABASE STATE: stock_transactions
  product_id: 15, unit_id: 3, quantity: 1, quantity_in_ml: 30


REQUEST 3: Get Stock Level
──────────────────────────────────────────────────
GET /api/stock/level/15

RESPONSE:
[
  {
    unit_name: "Full Bottle",
    current_quantity: 9,
    available_quantity: 9
  }
]
```

---

## Decision Tree

```
                    ┌─ Request to Remove Stock ─┐
                    │  (Product & Unit & Qty)    │
                    └────────────┬────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Is unit a base unit?    │
                    │ (is_base_unit = 1)      │
                    └────┬──────────────────┬──┘
                         │ YES              │ NO
                    ┌────▼──┐        ┌──────▼──────┐
                    │ DEDUCT │        │ Serving     │
                    │ FROM   │        │ Unit        │
                    │DIRECTLY│        └──────┬──────┘
                    └────┬──┘                │
                         │                  ▼
                         │         ┌─────────────────────┐
                         │         │ Find base unit for  │
                         │         │ this product        │
                         │         └──────┬──────────────┘
                         │                │
                         │                ▼
                         │         ┌─────────────────────┐
                         │         │ Convert ML:         │
                         │         │ qty × ml_capacity   │
                         │         └──────┬──────────────┘
                         │                │
                         │                ▼
                         │         ┌─────────────────────┐
                         │         │ Calculate bottles:  │
                         │         │ ceil(ml / 750)      │
                         │         └──────┬──────────────┘
                         │                │
                         └────┬───────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │ Check availability   │
                    │ in stock_balance     │
                    └────┬──────────┬──────┘
                         │ ENOUGH   │ INSUFFICIENT
                         │          │
                    ┌────▼─┐    ┌───▼────────────┐
                    │DEDUCT│    │ERROR: Out of   │
                    │FROM  │    │stock           │
                    │STOCK │    └────────────────┘
                    └────┬─┘
                         │
                         ▼
                    ┌─────────────────────┐
                    │ Update stock_balance│
                    │ Log transaction     │
                    │ Return success      │
                    └─────────────────────┘
```

---

**Visual Guide Created**: January 31, 2025
**Use With**: LIQUOR_STOCK_QUICK_REF.md
