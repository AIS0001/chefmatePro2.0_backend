# Accounts Analytics - Quick Reference

## 📊 Available Endpoints (11 Total)

### Sales Summary Cards
```
GET /api/accounts/sales/today          → Today's sales with payment breakdown
GET /api/accounts/sales/weekly         → Last 7 days with daily breakdown
GET /api/accounts/sales/monthly        → Current month with projections
GET /api/accounts/sales/range          → Custom date range (requires ?startDate & ?endDate)
```

### Revenue Analytics
```
GET /api/accounts/revenue/comparison   → Multi-period comparison with growth %
GET /api/accounts/revenue/hourly       → 24-hour breakdown for today
```

### Payment Analytics
```
GET /api/accounts/payments/distribution → Payment mode breakdown (?period=today|week|month)
```

### Top Performers
```
GET /api/accounts/top/items            → Best sellers (?limit=10 &period=month)
GET /api/accounts/top/categories       → Category performance (?period=month)
```

### Financial Reports
```
GET /api/accounts/profit-loss          → P&L summary (?period=month)
GET /api/accounts/dashboard            → Complete overview (all key metrics)
```

---

## 🎯 Common Use Cases

### Dashboard Summary Card
```javascript
// GET /api/accounts/dashboard
{
  todaySummary: { sales, orders, growth },
  monthSummary: { sales, orders, profit, profitMargin },
  paymentBreakdown: [...]
}
```

### Sales Chart (7 Days)
```javascript
// GET /api/accounts/sales/weekly
{
  dailyBreakdown: [
    { date, day, orders, sales },
    ...
  ]
}
```

### Payment Pie Chart
```javascript
// GET /api/accounts/payments/distribution?period=month
{
  distribution: [
    { paymentMode, totalAmount, percentage },
    ...
  ]
}
```

### Top 5 Items Leaderboard
```javascript
// GET /api/accounts/top/items?limit=5&period=week
{
  items: [
    { itemName, quantitySold, totalRevenue },
    ...
  ]
}
```

---

## 🔑 Query Parameters

| Endpoint | Parameter | Values | Default | Required |
|----------|-----------|--------|---------|----------|
| `/sales/range` | startDate | YYYY-MM-DD | - | ✅ |
| `/sales/range` | endDate | YYYY-MM-DD | - | ✅ |
| `/payments/distribution` | period | today\|week\|month | today | ❌ |
| `/top/items` | limit | number | 10 | ❌ |
| `/top/items` | period | today\|week\|month | month | ❌ |
| `/top/categories` | period | today\|week\|month | month | ❌ |
| `/profit-loss` | period | today\|week\|month | month | ❌ |

---

## 📝 Response Structure

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "details": "Technical details"
}
```

---

## 🛡️ Authentication
All endpoints require JWT token:
```javascript
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN'
}
```

---

## 🚀 Quick Test Commands

```bash
# Today's Sales
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:4402/api/accounts/sales/today

# Weekly Sales
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:4402/api/accounts/sales/weekly

# Top 5 Items This Week
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:4402/api/accounts/top/items?limit=5&period=week"

# Payment Distribution This Month
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:4402/api/accounts/payments/distribution?period=month"

# Complete Dashboard
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:4402/api/accounts/dashboard
```

---

## 📊 Data Exclusions
All endpoints automatically exclude:
- ❌ Entertainment payments (`payment_mode = 'entertainment'`)
- ❌ Cancelled bills (`status = 2`)

---

## 💰 Monetary Format
- All amounts: **String with 2 decimals** (e.g., "25670.50")
- Percentages: **String with 2 decimals** (e.g., "12.45")
- Dates: **YYYY-MM-DD format** (e.g., "2026-02-03")

---

## 📁 File Locations
```
controllers/accountsController.js  → Business logic (13 functions)
routes/accountsRoutes.js          → Route definitions (11 endpoints)
server.js                         → Registered as /api/accounts
docs/accounts_api_documentation.md → Full API docs
```

---

## ⚡ Performance Tips
1. Use `/dashboard` for overview instead of multiple calls
2. Cache frequently accessed data (e.g., today's sales)
3. Use appropriate `period` parameter to limit data
4. Use `limit` parameter for top items to reduce payload

---

## 🎨 Frontend Integration

### React Hook Example
```javascript
import { useState, useEffect } from 'react';
import axios from 'axios';

function useSalesSummary(period = 'today') {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(
          `/api/accounts/sales/${period}`,
          { headers: { Authorization: `Bearer ${token}` } }
        );
        setData(response.data.data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, [period]);
  
  return { data, loading, error };
}

// Usage
function SalesCard() {
  const { data, loading } = useSalesSummary('today');
  
  if (loading) return <Spinner />;
  
  return (
    <div>
      <h3>Sales: ₹{data.totalSales}</h3>
      <p>{data.totalOrders} orders</p>
    </div>
  );
}
```

---

**Last Updated:** February 3, 2026  
**Version:** 1.0
