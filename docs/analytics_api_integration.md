# Analytics Dashboard API Integration Guide

## Overview
This document outlines the backend APIs created for the Analytics Dashboard frontend component and how to integrate them.

## API Endpoints

### Base URL: `/api/analytics`

### 1. Dashboard Overview Data
**Endpoint:** `GET /api/analytics/dashboard`
**Description:** Returns the main dashboard metrics displayed in the top row cards
**Response:**
```json
{
  "success": true,
  "data": {
    "todaySales": 15420,
    "yesterdaySales": 12800,
    "monthlyPurchases": 89500,
    "todayPurchases": 3200,
    "totalOrders": 164,
    "totalSuppliers": 28
  }
}
```

### 2. Monthly Sales vs Purchases Chart
**Endpoint:** `GET /api/analytics/monthly-sales-purchases`
**Description:** Returns 12 months of sales vs purchases data for the main bar chart
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "month": "January",
      "sales": 65000,
      "purchases": 45000
    },
    // ... 11 more months
  ]
}
```

### 3. Suppliers Outstanding Payment
**Endpoint:** `GET /api/analytics/suppliers-outstanding`
**Description:** Returns supplier data for the left panel
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "supplier_name": "Fresh Food Suppliers",
      "total_orders": 45,
      "total_amount": 23000,
      "avg_rating": 4.8
    },
    // ... more suppliers
  ]
}
```

### 4. Order Status Distribution
**Endpoint:** `GET /api/analytics/order-status`
**Description:** Returns order status percentages for the right panel
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "status": "Completed",
      "value": 58.5,
      "count": 234,
      "color": "#27ae60"
    },
    // ... more statuses
  ]
}
```

### 5. Top Selling Products
**Endpoint:** `GET /api/analytics/top-products`
**Description:** Returns top 4 selling products
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "name": "Chicken Burgers",
      "sales": 1560,
      "revenue": 15600,
      "color": "#e74c3c"
    },
    // ... 3 more products
  ]
}
```

### 6. Category Distribution
**Endpoint:** `GET /api/analytics/category-distribution`
**Description:** Returns category breakdown for pie chart
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "name": "Food Items",
      "value": 35,
      "count": 140,
      "color": "#e74c3c"
    },
    // ... more categories
  ]
}
```

### 7. Total Sales & Expenses
**Endpoint:** `GET /api/analytics/sales-expenses`
**Description:** Returns financial summary for current month
**Response:**
```json
{
  "success": true,
  "data": {
    "totalSales": 245678,
    "totalExpenses": 123456,
    "netProfit": 122222
  }
}
```

### 8. Daily Sales Trend
**Endpoint:** `GET /api/analytics/daily-sales-trend`
**Description:** Returns last 6 days of sales data for area chart
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "day": "Mon",
      "date": "2025-08-23",
      "sales": 12500
    },
    // ... 5 more days
  ]
}
```

### 9. Purchase Trends
**Endpoint:** `GET /api/analytics/purchase-trends`
**Description:** Returns last 6 days of purchase data for line chart
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "day": "Mon",
      "date": "2025-08-23", 
      "purchases": 8500
    },
    // ... 5 more days
  ]
}
```

## Frontend Integration

### Step 1: Update the Frontend Component

Replace the hardcoded data in `analyticsDashboard.jsx` with API calls:

```jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function AnalyticsDashboard() {
  const [dashboardData, setDashboardData] = useState({});
  const [monthlySalesData, setMonthlySalesData] = useState([]);
  const [suppliersData, setSuppliersData] = useState([]);
  const [orderStatusData, setOrderStatusData] = useState([]);
  const [topProductsData, setTopProductsData] = useState([]);
  const [categoryData, setCategoryData] = useState([]);
  const [salesExpensesData, setSalesExpensesData] = useState({});
  const [dailySalesData, setDailySalesData] = useState([]);
  const [purchaseTrendsData, setPurchaseTrendsData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // API calls
  const fetchAnalyticsData = async () => {
    try {
      setIsLoading(true);
      
      const [
        dashboardRes,
        monthlySalesRes,
        suppliersRes,
        orderStatusRes,
        topProductsRes,
        categoryRes,
        salesExpensesRes,
        dailySalesRes,
        purchaseTrendsRes
      ] = await Promise.all([
        axios.get('/api/analytics/dashboard'),
        axios.get('/api/analytics/monthly-sales-purchases'),
        axios.get('/api/analytics/suppliers-outstanding'),
        axios.get('/api/analytics/order-status'),
        axios.get('/api/analytics/top-products'),
        axios.get('/api/analytics/category-distribution'),
        axios.get('/api/analytics/sales-expenses'),
        axios.get('/api/analytics/daily-sales-trend'),
        axios.get('/api/analytics/purchase-trends')
      ]);

      setDashboardData(dashboardRes.data.data);
      setMonthlySalesData(monthlySalesRes.data.data);
      setSuppliersData(suppliersRes.data.data);
      setOrderStatusData(orderStatusRes.data.data);
      setTopProductsData(topProductsRes.data.data);
      setCategoryData(categoryRes.data.data);
      setSalesExpensesData(salesExpensesRes.data.data);
      setDailySalesData(dailySalesRes.data.data);
      setPurchaseTrendsData(purchaseTrendsRes.data.data);
      
    } catch (error) {
      console.error('Error fetching analytics data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAnalyticsData();
  }, []);

  // Rest of your component...
}
```

### Step 2: Update Data References

Replace the hardcoded arrays with state variables:

```jsx
// Replace hardcoded monthlySalesData with monthlySalesData state
<BarChart data={monthlySalesData}>

// Replace hardcoded suppliersData with suppliersData state  
{suppliersData.map((supplier, index) => (

// Replace hardcoded orderStatusData with orderStatusData state
{orderStatusData.map((status, index) => (

// And so on for all data arrays...
```

### Step 3: Update Chart Data Mapping

Some data may need transformation for the charts:

```jsx
// For daily sales trend (use 'day' instead of 'month')
<AreaChart data={dailySalesData}>
  <XAxis dataKey="day" />

// For purchase trends  
<LineChart data={purchaseTrendsData}>
  <XAxis dataKey="day" />
```

## Database Requirements

### Required Tables:
1. `final_bill` - Sales data ✅
   - Fields: `id`, `grand_total`, `inv_date`, `customer_id`, `status`, `payment_mode`
2. `inventory` - Purchase data ✅  
   - Fields: `id`, `netAmount`, `created_at`, `supplier_id` (optional)
3. `order_items` - Product sales details ✅
   - Fields: `id`, `item_name`, `quantity`, `total_price`, `order_id`
4. `items` - Product information (optional)
   - Fields: `id`, `iname` (item name)

### Database Structure Notes:
- **Date Fields**: Uses `inv_date` for final_bill and `created_at` for inventory
- **Relationships**: order_items.order_id links to final_bill.id  
- **Supplier Data**: If supplier_id not available in inventory, fallback data is used
- **Category Logic**: Based on item_name pattern matching instead of separate category table

### Updated Query Patterns:
```sql
-- Sales data
SELECT grand_total FROM final_bill WHERE DATE(inv_date) = ?

-- Purchase data  
SELECT netAmount FROM inventory WHERE DATE(created_at) = ?

-- Order items with bills
SELECT oi.* FROM order_items oi 
WHERE EXISTS (SELECT 1 FROM final_bill fb WHERE fb.id = oi.order_id)
```

### Optional Supplier Table Creation:
If the `suppliers` table doesn't exist, create it:

```sql
CREATE TABLE suppliers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contact VARCHAR(100),
  email VARCHAR(100),
  address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add sample data
INSERT INTO suppliers (name, contact, email) VALUES 
('Fresh Food Suppliers', '+1234567890', 'contact@freshfood.com'),
('Beverage Distributors', '+1234567891', 'orders@beverages.com'),
('Equipment Suppliers', '+1234567892', 'sales@equipment.com');
```

## Authentication

All endpoints require authentication. Make sure to include the JWT token in the request headers:

```javascript
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
```

## Error Handling

All endpoints return consistent error responses:

```json
{
  "error": "Error message",
  "details": "Detailed error information"
}
```

## Testing

You can test the endpoints using Postman or curl:

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:4402/api/analytics/dashboard
```

## Performance Considerations

- APIs are optimized with appropriate database indexes
- Data is cached for 30-day periods where applicable
- Consider implementing Redis caching for production
- Large datasets are limited to relevant time periods

## Deployment Notes

1. Ensure all required tables exist
2. Update any environment variables if needed
3. Test all endpoints after deployment
4. Monitor performance and add indexes as needed
5. Consider implementing rate limiting for production use
