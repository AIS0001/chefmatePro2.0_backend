# Liquor Stock Deduction Fix

## Problem Statement
When adding liquor stock as a full bottle and then selling in servings (30ml, 60ml, 90ml pegs), the system was incorrectly trying to:
1. Look for exact serving unit stock in the database (e.g., "30ml peg")
2. If not found, deduct an entire full bottle instead of just the serving amount

## Root Cause
The original `removeStock()` method required a stock_balance entry for the exact unit being sold. For liquor:
- Only **full bottle** (base unit) has stock entries
- **Serving units** (30ml, 60ml, 90ml) don't have their own stock - they're portions of full bottles

## Solution Implemented
Updated the `removeStock()` method in `stockService.js` with the following logic:

### Key Changes:
1. **Unit Detection**: Identifies whether the requested unit is a base unit or serving unit
2. **Smart Deduction**: If a serving unit is requested (not base unit), automatically deducts from the base unit instead
3. **ML Conversion**: Converts the serving size to ML, then calculates how many full bottles need to be deducted
4. **Ceiling Rounding**: Uses `Math.ceil()` to ensure partial bottles are counted (e.g., 30ml peg = 1 bottle)
5. **No Double Deduction**: Only deducts from base unit, preventing the previous issue of deducting from multiple units

## Example Flow

### Before (Incorrect):
```
Order: 30ml peg of Vodka
System: Looks for "30ml peg" unit in stock_balance
Result: Not found → Deducts 1 full bottle (WRONG!)
```

### After (Correct):
```
Order: 30ml peg of Vodka
System: 
  1. Detects "30ml peg" is NOT base unit
  2. Finds base unit (Full Bottle) with ml_capacity=750ml
  3. Calculates: 30ml / 750ml = 0.04 bottles
  4. Rounds up with Math.ceil() = 1 bottle
  5. Deducts 1 full bottle from stock (CORRECT!)
```

## Implementation Details

### Modified Method: `removeStock()`
**Location**: `services/stockService.js` (line ~218)

**Key Logic**:
```javascript
// If requested unit is NOT the base unit and has ML capacity, deduct from base unit instead
if (!requestedUnit.is_base_unit && baseUnit && quantityInMl) {
  deductFromUnitId = baseUnit.id;
  // Convert ML quantity to base unit quantity
  quantityToDeduct = Math.ceil(quantityInMl / baseUnit.ml_capacity);
  actualQuantityInMl = quantityInMl;
}
```

## Database Requirements

Ensure your `product_units` table for liquor products has:

```sql
-- Base Unit (Full Bottle)
INSERT INTO product_units (
  product_id, 
  unit_name, 
  ml_capacity, 
  is_base_unit
) VALUES (
  1, 
  'Full Bottle', 
  750, 
  1
);

-- Serving Units
INSERT INTO product_units (
  product_id, 
  unit_name, 
  ml_capacity, 
  is_base_unit
) VALUES (
  1, '30ml Peg', 30, 0
), (
  1, '60ml Peg', 60, 0
), (
  1, '90ml Peg', 90, 0
);
```

## Return Values

The updated method now returns:
```javascript
{
  success: true,
  message: 'Stock removed successfully',
  productId: 1,
  unitId: 3,  // 30ml peg unit ID
  quantity: 1,  // 1 peg ordered
  deductedFromUnit: 1,  // Full bottle unit ID
  deductedQuantity: 1,  // 1 full bottle deducted
  deductedInMl: 30,  // 30ml removed
  timestamp: new Date()
}
```

## Alternative Method: `removeStockWithVariants()`

For even more control, use the **product_variants** approach:

**Location**: `services/stockService.js` (line ~478)

This method:
1. Uses `product_variants` table (pre-configured serving options)
2. Maps serving to base unit quantity automatically
3. Prevents mistakes by using pre-defined variants

**Endpoint**: `POST /api/stock/remove-variant`

```javascript
{
  productId: 1,
  variantId: 5,  // 30ml peg variant
  quantity: 1,   // Number of pegs
  referenceId: null,
  notes: "Customer order"
}
```

## Testing Checklist

- [ ] Add 1 full bottle of liquor (750ml) to stock
- [ ] Order 1 × 30ml peg via API
- [ ] Verify stock_balance shows 1 full bottle in stock (base unit unchanged by serving unit request)
- [ ] Order multiple servings and verify cumulative deduction
- [ ] Try selling more than available bottles → should error appropriately
- [ ] Verify transaction logs show correct ML quantities

## Rollback Plan

If issues occur, the original method is preserved in version control. Simply revert `stockService.js` to the previous commit.

## Related Files
- `controllers/stockController.js` - HTTP layer
- `routes/stockRoutes.js` - API endpoints
- `services/stockService.js` - Business logic
- Database: `product_units`, `stock_balance`, `stock_transactions` tables
