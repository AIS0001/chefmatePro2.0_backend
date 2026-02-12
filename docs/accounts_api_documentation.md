# Accounts Analytics API Documentation

Complete API documentation for the accounts and financial analytics system for ChefMate POS dashboard.

## Base URL
```
/api/accounts
```

## Authentication
All endpoints require JWT authentication via the `isAuthorize` middleware.

---

## Table of Contents
1. [Sales Summary Cards](#sales-summary-cards)
2. [Revenue Analytics](#revenue-analytics)
3. [Payment Mode Analytics](#payment-mode-analytics)
4. [Top Performers](#top-performers)
5. [Profit & Loss](#profit--loss)
6. [Dashboard Overview](#dashboard-overview)

---

## Sales Summary Cards

### 1. Get Today's Sales Summary
Get comprehensive sales metrics for the current day.

**Endpoint:** `GET /api/accounts/sales/today`

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-02-03",
    "totalOrders": 45,
    "totalSales": "25670.50",
    "avgOrderValue": "570.45",
    "paymentBreakdown": {
      "cash": "8500.00",
      "card": "10200.50",
      "upi": "6970.00",
      "online": "0.00"
    }
  }
}
```

**Use Cases:**
- Dashboard summary card
- Real-time sales monitoring
- Daily performance tracking

---

### 2. Get Weekly Sales Summary
Get sales data for the last 7 days with daily breakdown.

**Endpoint:** `GET /api/accounts/sales/weekly`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "Last 7 Days",
    "totalSales": "156789.00",
    "totalOrders": 342,
    "avgDailySales": "22398.43",
    "dailyBreakdown": [
      {
        "date": "2026-02-03",
        "day": "Monday",
        "orders": 45,
        "sales": "25670.50"
      },
      {
        "date": "2026-02-02",
        "day": "Sunday",
        "orders": 52,
        "sales": "28900.00"
      }
      // ... more days
    ]
  }
}
```

**Use Cases:**
- Weekly trend analysis
- Week-over-week comparison charts
- Sales pattern identification

---

### 3. Get Monthly Sales Summary
Get current month sales with projections.

**Endpoint:** `GET /api/accounts/sales/monthly`

**Response:**
```json
{
  "success": true,
  "data": {
    "month": "February 2026",
    "totalOrders": 89,
    "totalSales": "52340.75",
    "avgOrderValue": "588.10",
    "avgDailySales": "17446.92",
    "projectedMonthly": "488514.76",
    "paymentBreakdown": {
      "cash": "18500.00",
      "card": "22200.50",
      "upi": "11640.25"
    }
  }
}
```

**Use Cases:**
- Monthly performance dashboard
- Revenue projections
- Budget planning

---

### 4. Get Custom Date Range Sales
Get sales summary for any custom date range.

**Endpoint:** `GET /api/accounts/sales/range`

**Query Parameters:**
- `startDate` (required): YYYY-MM-DD format
- `endDate` (required): YYYY-MM-DD format

**Example:** `/api/accounts/sales/range?startDate=2026-01-01&endDate=2026-01-31`

**Response:**
```json
{
  "success": true,
  "data": {
    "startDate": "2026-01-01",
    "endDate": "2026-01-31",
    "totalDays": 31,
    "totalOrders": 567,
    "totalSales": "345678.90",
    "avgOrderValue": "609.70",
    "avgDailySales": "11151.58",
    "paymentBreakdown": {
      "cash": "125000.00",
      "card": "145678.90",
      "upi": "70000.00",
      "online": "5000.00"
    }
  }
}
```

**Use Cases:**
- Custom reporting periods
- Quarter-end analysis
- Comparative period analysis

---

## Revenue Analytics

### 5. Get Revenue Comparison
Compare revenue across multiple time periods with growth percentages.

**Endpoint:** `GET /api/accounts/revenue/comparison`

**Response:**
```json
{
  "success": true,
  "data": {
    "today": {
      "revenue": "25670.50",
      "growth": "12.45",
      "comparison": "vs Yesterday"
    },
    "yesterday": {
      "revenue": "22834.60"
    },
    "last7Days": {
      "revenue": "156789.00",
      "avgDaily": "22398.43"
    },
    "thisMonth": {
      "revenue": "52340.75",
      "growth": "8.30",
      "comparison": "vs Last Month"
    },
    "lastMonth": {
      "revenue": "48320.50"
    }
  }
}
```

**Use Cases:**
- Growth tracking dashboard
- Performance comparison cards
- Trend visualization

---

### 6. Get Hourly Sales Distribution
Get hour-by-hour sales breakdown for today.

**Endpoint:** `GET /api/accounts/revenue/hourly`

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-02-03",
    "hourlyBreakdown": [
      {
        "hour": 0,
        "timeLabel": "00:00",
        "orders": 0,
        "revenue": "0.00"
      },
      {
        "hour": 12,
        "timeLabel": "12:00",
        "orders": 15,
        "revenue": "8500.50"
      },
      {
        "hour": 19,
        "timeLabel": "19:00",
        "orders": 22,
        "revenue": "12340.00"
      }
      // ... all 24 hours
    ],
    "peakHour": {
      "hour": 19,
      "orders": 22,
      "revenue": "12340.00"
    }
  }
}
```

**Use Cases:**
- Peak hours identification
- Staff scheduling optimization
- Hourly performance charts

---

## Payment Mode Analytics

### 7. Get Payment Mode Distribution
Get breakdown of sales by payment method.

**Endpoint:** `GET /api/accounts/payments/distribution`

**Query Parameters:**
- `period` (optional): `today`, `week`, or `month` (default: `today`)

**Example:** `/api/accounts/payments/distribution?period=week`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "totalRevenue": "156789.00",
    "distribution": [
      {
        "paymentMode": "card",
        "transactionCount": 145,
        "totalAmount": "72450.50",
        "percentage": "46.20"
      },
      {
        "paymentMode": "cash",
        "transactionCount": 98,
        "totalAmount": "52340.00",
        "percentage": "33.38"
      },
      {
        "paymentMode": "upi",
        "transactionCount": 99,
        "totalAmount": "31998.50",
        "percentage": "20.40"
      }
    ]
  }
}
```

**Use Cases:**
- Payment method preference analysis
- Cash flow management
- Payment pie charts

---

## Top Performers

### 8. Get Top Selling Items
Get list of best-selling menu items.

**Endpoint:** `GET /api/accounts/top/items`

**Query Parameters:**
- `limit` (optional): Number of items to return (default: 10)
- `period` (optional): `today`, `week`, or `month` (default: `month`)

**Example:** `/api/accounts/top/items?limit=5&period=week`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "items": [
      {
        "itemName": "Chicken Burger",
        "category": "Burgers",
        "quantitySold": 145,
        "orderCount": 98,
        "totalRevenue": "43500.00",
        "avgPrice": "300.00"
      },
      {
        "itemName": "Margherita Pizza",
        "category": "Pizza",
        "quantitySold": 89,
        "orderCount": 67,
        "totalRevenue": "35600.00",
        "avgPrice": "400.00"
      }
      // ... more items
    ]
  }
}
```

**Use Cases:**
- Menu optimization
- Inventory planning
- Popular items dashboard
- Sales leaderboard

---

### 9. Get Category Performance
Get sales performance by item category.

**Endpoint:** `GET /api/accounts/top/categories`

**Query Parameters:**
- `period` (optional): `today`, `week`, or `month` (default: `month`)

**Example:** `/api/accounts/top/categories?period=month`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "month",
    "categories": [
      {
        "category": "Burgers",
        "orderCount": 234,
        "quantitySold": 456,
        "totalRevenue": "136800.00",
        "percentage": "42.50"
      },
      {
        "category": "Pizza",
        "orderCount": 189,
        "quantitySold": 245,
        "totalRevenue": "98000.00",
        "percentage": "30.45"
      },
      {
        "category": "Beverages",
        "orderCount": 456,
        "quantitySold": 678,
        "totalRevenue": "54000.00",
        "percentage": "16.78"
      }
      // ... more categories
    ]
  }
}
```

**Use Cases:**
- Category performance analysis
- Menu mix optimization
- Category contribution charts

---

## Profit & Loss

### 10. Get Profit & Loss Summary
Get basic P&L with revenue, expenses, and profit margins.

**Endpoint:** `GET /api/accounts/profit-loss`

**Query Parameters:**
- `period` (optional): `today`, `week`, or `month` (default: `month`)

**Example:** `/api/accounts/profit-loss?period=month`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "month",
    "revenue": "345678.90",
    "purchases": "156789.50",
    "grossProfit": "188889.40",
    "profitMargin": "54.65",
    "status": "profitable"
  }
}
```

**Use Cases:**
- Financial health monitoring
- Profit margin tracking
- Cost control analysis
- Executive dashboard

---

## Dashboard Overview

### 11. Get Complete Accounts Dashboard
Get all key metrics in a single call for dashboard overview.

**Endpoint:** `GET /api/accounts/dashboard`

**Response:**
```json
{
  "success": true,
  "data": {
    "todaySummary": {
      "sales": "25670.50",
      "orders": 45,
      "growth": "12.45"
    },
    "monthSummary": {
      "sales": "345678.90",
      "orders": 567,
      "purchases": "156789.50",
      "grossProfit": "188889.40",
      "profitMargin": "54.65"
    },
    "paymentBreakdown": [
      {
        "mode": "card",
        "amount": "10200.50",
        "count": 18
      },
      {
        "mode": "cash",
        "amount": "8500.00",
        "count": 15
      },
      {
        "mode": "upi",
        "amount": "6970.00",
        "count": 12
      }
    ]
  }
}
```

**Use Cases:**
- Main dashboard page
- Executive summary
- Quick overview screen

---

## Error Responses

All endpoints return consistent error format:

```json
{
  "success": false,
  "error": "Error message description",
  "details": "Detailed technical error message"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (missing parameters)
- `401` - Unauthorized (invalid/missing token)
- `500` - Internal Server Error

---

## Frontend Integration Examples

### React Dashboard Card Example
```javascript
import React, { useEffect, useState } from 'react';
import axios from 'axios';

function TodaySalesCard() {
  const [sales, setSales] = useState(null);
  
  useEffect(() => {
    const fetchSales = async () => {
      try {
        const response = await axios.get('/api/accounts/sales/today', {
          headers: { Authorization: `Bearer ${token}` }
        });
        setSales(response.data.data);
      } catch (error) {
        console.error('Failed to fetch sales:', error);
      }
    };
    
    fetchSales();
  }, []);
  
  if (!sales) return <div>Loading...</div>;
  
  return (
    <div className="sales-card">
      <h3>Today's Sales</h3>
      <div className="amount">₹{sales.totalSales}</div>
      <div className="orders">{sales.totalOrders} Orders</div>
      <div className="avg">Avg: ₹{sales.avgOrderValue}</div>
    </div>
  );
}
```

### Chart.js Hourly Sales Example
```javascript
import { Line } from 'react-chartjs-2';

function HourlySalesChart() {
  const [chartData, setChartData] = useState(null);
  
  useEffect(() => {
    const fetchData = async () => {
      const response = await axios.get('/api/accounts/revenue/hourly');
      const hourly = response.data.data.hourlyBreakdown;
      
      setChartData({
        labels: hourly.map(h => h.timeLabel),
        datasets: [{
          label: 'Revenue',
          data: hourly.map(h => parseFloat(h.revenue)),
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      });
    };
    
    fetchData();
  }, []);
  
  return chartData ? <Line data={chartData} /> : <div>Loading...</div>;
}
```

---

## Summary of Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/accounts/sales/today` | GET | Today's sales summary |
| `/api/accounts/sales/weekly` | GET | Last 7 days sales |
| `/api/accounts/sales/monthly` | GET | Current month sales |
| `/api/accounts/sales/range` | GET | Custom date range sales |
| `/api/accounts/revenue/comparison` | GET | Multi-period revenue comparison |
| `/api/accounts/revenue/hourly` | GET | Hourly breakdown for today |
| `/api/accounts/payments/distribution` | GET | Payment mode breakdown |
| `/api/accounts/top/items` | GET | Top selling items |
| `/api/accounts/top/categories` | GET | Category performance |
| `/api/accounts/profit-loss` | GET | P&L summary |
| `/api/accounts/dashboard` | GET | Complete dashboard overview |

---

## Notes

- All monetary values are returned as strings with 2 decimal places
- Dates are in YYYY-MM-DD format
- Growth percentages can be negative (indicating decline)
- Entertainment payments are excluded from all revenue calculations
- Cancelled bills (status = 2) are excluded from all calculations
- All endpoints require valid JWT token in Authorization header

---

## Testing with Postman/cURL

### Example cURL Request
```bash
curl -X GET "http://localhost:4402/api/accounts/sales/today" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Example Postman Collection
Import these as individual requests:
1. Today Sales → GET `/api/accounts/sales/today`
2. Weekly Sales → GET `/api/accounts/sales/weekly`
3. Payment Distribution → GET `/api/accounts/payments/distribution?period=month`
4. Top Items → GET `/api/accounts/top/items?limit=10&period=week`

---

**Last Updated:** February 3, 2026  
**API Version:** 1.0  
**Backend:** ChefMate POS System
