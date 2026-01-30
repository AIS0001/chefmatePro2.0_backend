#!/bin/bash
# Stock Management API - Test Examples
# Replace YOUR_TOKEN with actual JWT token

BASE_URL="http://localhost:4402/api/stock"
TOKEN="YOUR_JWT_TOKEN_HERE"

echo "🧪 Stock Management System - Test Examples"
echo "=========================================="
echo ""

# ==================== SETUP ====================
echo "1️⃣ CREATE UNITS FOR WHISKEY"
echo "---"
echo "Creating Bottle unit..."
curl -X POST "$BASE_URL/units/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitName": "Bottle (750ML)",
    "unitType": "BASE",
    "mlCapacity": 750,
    "sellingPrice": 3000
  }' | jq .
echo ""

echo "Creating 30ML Peg unit..."
curl -X POST "$BASE_URL/units/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitName": "30ML Peg",
    "unitType": "DERIVED",
    "mlCapacity": 30,
    "sellingPrice": 150
  }' | jq .
echo ""

# ==================== CONVERSIONS ====================
echo "2️⃣ CREATE CONVERSION RULES"
echo "---"
echo "Creating 1 Bottle = 25 Pegs conversion..."
curl -X POST "$BASE_URL/conversions/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "fromUnitId": 1,
    "toUnitId": 2,
    "conversionFactor": 25
  }' | jq .
echo ""

# ==================== VARIANTS ====================
echo "3️⃣ CREATE PRODUCT VARIANTS"
echo "---"
echo "Creating 30ML Peg variant..."
curl -X POST "$BASE_URL/variants/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "variantName": "30ML Peg",
    "baseUnitId": 1,
    "quantityInBaseUnit": 0.04,
    "mlQuantity": 30,
    "sellingPrice": 150,
    "costPrice": 120
  }' | jq .
echo ""

# ==================== ADD STOCK ====================
echo "4️⃣ ADD STOCK TO INVENTORY"
echo "---"
echo "Adding 12 bottles..."
curl -X POST "$BASE_URL/add" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitId": 1,
    "quantity": 12,
    "referenceType": "PURCHASE",
    "referenceId": 301,
    "notes": "New shipment from supplier"
  }' | jq .
echo ""

# ==================== GET STOCK ====================
echo "5️⃣ GET CURRENT STOCK LEVEL"
echo "---"
curl -X GET "$BASE_URL/level/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET UNITS ====================
echo "6️⃣ GET ALL UNITS FOR PRODUCT"
echo "---"
curl -X GET "$BASE_URL/units/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET CONVERSIONS ====================
echo "7️⃣ GET CONVERSION RULES"
echo "---"
curl -X GET "$BASE_URL/conversions/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET VARIANTS ====================
echo "8️⃣ GET PRODUCT VARIANTS"
echo "---"
curl -X GET "$BASE_URL/variants/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== REMOVE STOCK ====================
echo "9️⃣ REMOVE STOCK (WASTE/DAMAGE)"
echo "---"
echo "Removing 1 bottle due to damage..."
curl -X POST "$BASE_URL/remove" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "unitId": 1,
    "quantity": 1,
    "referenceType": "DAMAGE",
    "notes": "Damaged during delivery"
  }' | jq .
echo ""

# ==================== SELL USING VARIANT ====================
echo "🔟 SELL USING VARIANT (SMART DEDUCTION)"
echo "---"
echo "Selling 2 x 30ML Pegs (automatically removes from bottles)..."
curl -X POST "$BASE_URL/remove-variant" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "variantId": 1,
    "quantity": 2,
    "referenceId": 1001,
    "notes": "2 x 30ML pegs sold at Table 5"
  }' | jq .
echo ""

# ==================== GET UPDATED STOCK ====================
echo "1️⃣1️⃣ GET UPDATED STOCK LEVEL"
echo "---"
curl -X GET "$BASE_URL/level/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET REPORT ====================
echo "1️⃣2️⃣ GET COMPLETE STOCK REPORT"
echo "---"
curl -X GET "$BASE_URL/report/126" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET HISTORY ====================
echo "1️⃣3️⃣ GET TRANSACTION HISTORY"
echo "---"
curl -X GET "$BASE_URL/history/126?limit=10" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET ALL STOCK ====================
echo "1️⃣4️⃣ GET ALL INVENTORY"
echo "---"
curl -X GET "$BASE_URL/all" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== GET LOW STOCK ALERTS ====================
echo "1️⃣5️⃣ GET LOW STOCK ALERTS"
echo "---"
curl -X GET "$BASE_URL/alerts/low-stock" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

# ==================== CONVERT UNITS ====================
echo "1️⃣6️⃣ CONVERT UNITS"
echo "---"
echo "Converting 2 bottles to 30ML pegs..."
curl -X POST "$BASE_URL/convert" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 126,
    "fromUnitId": 1,
    "toUnitId": 2,
    "quantity": 2
  }' | jq .
echo ""

echo "✅ Test examples completed!"
echo ""
echo "📝 Notes:"
echo "  - Replace 'YOUR_JWT_TOKEN_HERE' with actual token"
echo "  - Replace productId, unitId, variantId with actual IDs"
echo "  - Ensure jq is installed for pretty JSON output"
echo "  - Each endpoint requires authentication"
