# Stock Entry Guide — How to Enter Purchase Stock Correctly

## The Golden Rule

> **Always enter stock in BOTTLES (base unit). Never enter stock as pegs.**

The system automatically calculates how many pegs (30ml / 60ml) are available from the bottles you entered. When a peg is sold at the POS, the system deducts from the bottle stock.

---

## How the System Works

### Units Setup (product_units table)

Every liquor product must have its units configured like this:

| Unit Name | ML Capacity | Is Base Unit | Conversion Factor |
|-----------|-------------|--------------|-------------------|
| Bottle    | 750         | ✅ YES        | 1                 |
| 60ml Peg  | 60          | ❌ NO         | 0.08              |
| 30ml Peg  | 30          | ❌ NO         | 0.04              |
| Half Btl  | 375         | ❌ NO         | 0.5               |

- **Base Unit** = the unit you physically buy and store (bottle).
- **ML Capacity** = how many ml that unit holds.
- **Conversion Factor** = fraction of base unit (e.g. 60ml ÷ 750ml = 0.08).
p
---

## Entering a Purchase (Stock In)

### Step 1 — Go to Inventory → New Purchase

### Step 2 — Select Supplier and Date

### Step 3 — Add Items

For each item:

| Field        | What to enter                                      |
|--------------|----------------------------------------------------|
| Product      | Select the liquor item (e.g. Black Label)          |
| **Unit**     | **Always select "Bottle"** (the base unit)         |
| Quantity     | Number of bottles bought (e.g. 10)                 |
| Unit Price   | Price per bottle                                   |

> ❌ **Do NOT enter stock as "30ml" or "60ml" pegs in the purchase screen.**  
> The system will store it in ML internally and automatically derive peg availability.

### Example: Buying 10 bottles of Black Label (750ml each)

- Unit = **Bottle**
- Quantity = **10**
- System internally records: **7,500 ml** in stock

---

## What Happens Automatically After Purchase

When you save the purchase:

1. `stock_balance` is updated → `+10 bottles` for Black Label.
2. System also auto-calculates serving unit balances:
   - 60ml pegs available = ⌊7500 ÷ 60⌋ = **125 pegs**
   - 30ml pegs available = ⌊7500 ÷ 30⌋ = **250 pegs**
3. A `stock_transaction` record is created (type = `ADD`, reference = purchase order number).

---

## How Deduction Works at POS (Sale)

When a customer orders **2 × 60ml pegs** of Black Label at the POS:

1. System looks up 60ml unit → `ml_capacity = 60`.
2. Calculates total ml needed → `2 × 60 = 120ml`.
3. Converts to bottles → `⌈120 ÷ 750⌉ = 1 bottle` (ceiling, to cover partial).
4. Deducts **1 bottle** from `stock_balance` (base unit).
5. Records a `stock_transaction` (type = `REMOVE`, reference = order number).

> The system always deducts from the **bottle stock**, not from a "peg stock" counter.

---

## Common Mistakes to Avoid

| ❌ Wrong                                         | ✅ Correct                                    |
|--------------------------------------------------|-----------------------------------------------|
| Entering purchase qty as 250 (pegs)              | Enter as 10 (bottles)                         |
| Selecting "30ml" as unit on purchase screen      | Always select "Bottle" on purchase screen     |
| Adding the same product twice with different units in one purchase | One line per product per unit |
| Not setting `is_base_unit = 1` for bottle in DB  | Bottle must be marked as base unit in DB      |
| Setting `ml_capacity = NULL` for bottle          | Bottle must have `ml_capacity` set (e.g. 750) |

---

## Quick Reference: Bottle ML Sizes

| Product Type    | Standard Bottle ML |
|-----------------|--------------------|
| Whisky / Scotch | 750 ml             |
| Beer            | 330 ml / 650 ml    |
| Wine            | 750 ml             |
| Spirits (small) | 180 ml / 375 ml    |
| Rum / Vodka     | 750 ml / 1000 ml   |

---

## Database Check (for Admin / Setup)

If deduction is not working, verify in `product_units` table:

```sql
SELECT unit_name, ml_capacity, is_base_unit, conversion_factor
FROM product_units
WHERE product_id = <your_product_id>;
```

Expected result for a 750ml whisky:

```
unit_name | ml_capacity | is_base_unit | conversion_factor
----------|-------------|--------------|------------------
Bottle    | 750         | 1            | 1.00
60ml      | 60          | 0            | 0.08
30ml      | 30          | 0            | 0.04
```

If `is_base_unit` is not set or `ml_capacity` is NULL for the bottle → fix those values → stock deduction will work correctly.

---

## Summary

```
BUY  → Enter as Bottles  →  System stores ML total
SELL → Select any unit   →  System deducts equivalent Bottles automatically
```
