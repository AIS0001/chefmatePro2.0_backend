# API Error Logging Service Documentation

## Overview

The API Error Logging Service automatically captures, logs, and monitors all API errors across the ChefMate application. It provides super administrators with detailed insights into system failures, helping with debugging and monitoring.

## Features

✅ **Automatic Error Logging** - Captures all API errors including 404s, server errors, validation failures
✅ **Shop-Based Filtering** - Logs include shop_id for multi-tenant tracking
✅ **Date-Based Organization** - Separate log files per day (YYYY-MM-DD format)
✅ **Rich Context** - Includes timestamps, user info, response times, IP addresses
✅ **Super Admin Dashboard** - Dedicated API endpoints for monitoring
✅ **Statistics & Analytics** - Pre-aggregated error statistics
✅ **Automatic Cleanup** - Old logs automatically deleted after 30 days (configurable)

---

## Log File Format

### Location
```
chefmatePro2.0_backend/logs/error-YYYY-MM-DD.log
```

### Log Entry Format (JSON)
Each line in the log file is a JSON object:

```json
{
  "timestamp": "2026-03-27T14:30:45.123Z",
  "statusCode": 404,
  "method": "GET",
  "endpoint": "/api/accounts/order-items/pending-invoice?shop_id=3",
  "error": "Endpoint not found (404)",
  "shopId": 3,
  "userId": "user123",
  "responseTime": 125,
  "ip": "192.168.1.100",
  "userAgent": "Mozilla/5.0..."
}
```

### Log Fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | ISO 8601 timestamp when error occurred |
| `statusCode` | number | HTTP status code (404, 500, etc.) |
| `method` | string | HTTP method (GET, POST, PUT, DELETE) |
| `endpoint` | string | API endpoint path with query params |
| `error` | string | Error message |
| `shopId` | number | Multi-tenant shop identifier |
| `userId` | string | User who triggered the error |
| `responseTime` | number | Response time in milliseconds |
| `ip` | string | Client IP address |
| `userAgent` | string | Browser/client user agent |
| `stack` | string | Stack trace (development only, omitted in production) |

---

## Super Admin API Endpoints

All endpoints require super admin authentication and use the header:
```
Authorization: Bearer {token}
```

### 1. Get Logs by Date
**Endpoint:** `GET /api/super-admin/logs/by-date`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD format, defaults to today

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/by-date?date=2026-03-27
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-03-27",
    "count": 15,
    "logs": [
      {
        "timestamp": "2026-03-27T14:30:45.123Z",
        "statusCode": 404,
        "method": "GET",
        "endpoint": "/api/accounts/order-items/pending-invoice?shop_id=3",
        "error": "Endpoint not found (404)",
        "shopId": 3,
        "userId": "admin@chefmate.com",
        "responseTime": 45,
        "ip": "192.168.1.100",
        "userAgent": "Mozilla/5.0..."
      }
      // ... more logs
    ]
  }
}
```

---

### 2. Get Logs by Date Range
**Endpoint:** `GET /api/super-admin/logs/by-range`

**Query Parameters:**
- `startDate` (required): YYYY-MM-DD format
- `endDate` (required): YYYY-MM-DD format

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/by-range?startDate=2026-03-25&endDate=2026-03-27
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "startDate": "2026-03-25",
    "endDate": "2026-03-27",
    "count": 45,
    "logs": [...]
  }
}
```

---

### 3. Get Logs by Shop
**Endpoint:** `GET /api/super-admin/logs/by-shop/:shopId`

**URL Parameters:**
- `shopId` (required): Shop identifier

**Query Parameters:**
- `limit` (optional): Number of logs to return, default 100

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/by-shop/3?limit=50
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "shopId": 3,
    "limit": 50,
    "count": 25,
    "logs": [...]
  }
}
```

---

### 4. Get Logs by HTTP Status Code
**Endpoint:** `GET /api/super-admin/logs/by-status/:statusCode`

**URL Parameters:**
- `statusCode` (required): HTTP status code (404, 500, 401, etc.)

**Query Parameters:**
- `limit` (optional): Number of logs to return, default 50

**Example Requests:**
```bash
# Get all 404 errors
GET http://localhost:4402/api/super-admin/logs/by-status/404

# Get all 500 errors with limit
GET http://localhost:4402/api/super-admin/logs/by-status/500?limit=100

# Get all 401 unauthorized errors
GET http://localhost:4402/api/super-admin/logs/by-status/401
```

---

### 5. Get Log Statistics
**Endpoint:** `GET /api/super-admin/logs/statistics`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD format, defaults to today

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/statistics?date=2026-03-27
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-03-27",
    "statistics": {
      "totalErrors": 45,
      "byStatusCode": {
        "404": 25,
        "500": 15,
        "401": 5
      },
      "byEndpoint": {
        "/api/accounts/order-items/pending-invoice": 10,
        "/api/invalid-endpoint": 8,
        "/api/stock/update": 5
      },
      "byShop": {
        "1": 30,
        "2": 10,
        "3": 5
      },
      "byMethod": {
        "GET": 25,
        "POST": 15,
        "PUT": 5
      }
    }
  }
}
```

---

### 6. Get Available Log Files
**Endpoint:** `GET /api/super-admin/logs/available`

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/available
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "count": 15,
    "files": [
      "error-2026-03-27.log",
      "error-2026-03-26.log",
      "error-2026-03-25.log",
      ...
    ]
  }
}
```

---

### 7. Get Log Summary (Quick Overview)
**Endpoint:** `GET /api/super-admin/logs/summary`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD format, defaults to today

**Example Request:**
```bash
GET http://localhost:4402/api/super-admin/logs/summary?date=2026-03-27
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-03-27",
    "overview": {
      "totalErrors": 45,
      "topStatusCodes": [
        { "code": 404, "count": 25 },
        { "code": 500, "count": 15 },
        { "code": 401, "count": 5 }
      ],
      "affectedEndpoints": 8,
      "affectedShops": 3
    },
    "statistics": {
      "totalErrors": 45,
      "byStatusCode": { ... },
      "byEndpoint": { ... },
      "byShop": { ... },
      "byMethod": { ... }
    }
  }
}
```

---

## Captured Error Types

The system automatically captures:

### ✅ 404 Not Found Errors
- Missing endpoints
- Invalid API routes

### ✅ 401 Unauthorized Errors
- Missing authentication token
- Expired JWT tokens
- Invalid credentials

### ✅ 403 Forbidden Errors
- Insufficient permissions
- Super admin access denied

### ✅ 400 Bad Request Errors
- Invalid query parameters
- Malformed request body
- Validation failures

### ✅ 500 Server Errors
- Database connection failures
- Unhandled exceptions
- Internal server errors

### ✅ 5xx Server Errors
- All server-side errors

---

## Service Usage in Code

### Manual Error Logging
If you need to manually log an error:

```javascript
const errorLogService = require('../services/errorLogService');

// Log an error manually
errorLogService.logApiError({
  statusCode: 500,
  method: 'POST',
  endpoint: '/api/custom-endpoint',
  error: 'Custom error message',
  shopId: 3,
  userId: 'user@example.com',
  responseTime: 150,
  ip: '192.168.1.100',
  userAgent: 'Mozilla/5.0...'
});
```

### Get Logs Programmatically
```javascript
const errorLogService = require('../services/errorLogService');

// Get logs for today
const todayLogs = errorLogService.getLogsByDate('2026-03-27');

// Get logs for a date range
const rangeLogs = errorLogService.getLogsByDateRange('2026-03-25', '2026-03-27');

// Get logs for a specific shop
const shopLogs = errorLogService.getLogsByShopId(3, 50);

// Get logs by status code
const notFoundErrors = errorLogService.getLogsByStatusCode(404, 100);

// Get statistics
const stats = errorLogService.getLogStatistics('2026-03-27');

// Get all available log files
const files = errorLogService.getAvailableLogFiles();
```

---

## Configuration

### Log Retention
By default, logs are kept for 30 days. To change this, modify the cleanup task:

```javascript
// In server.js or a cleanup scheduler
const errorLogService = require('./services/errorLogService');

// Keep logs for 60 days instead of 30
errorLogService.clearOldLogs(60);
```

### Auto-cleanup Scheduler (Optional)
Add this to `server.js` or create a separate scheduler:

```javascript
// Clear old logs daily (keep logs for 30 days)
setInterval(() => {
  errorLogService.clearOldLogs(30);
  console.log('[SCHEDULER] Cleaned up old error logs');
}, 24 * 60 * 60 * 1000); // Run daily
```

---

## Frontend Super Admin Dashboard Integration

Example React component to display error logs:

```jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { getHeaders } from '../../utility/getHeader';

const ErrorLogsMonitoring = () => {
  const [logs, setLogs] = useState([]);
  const [stats, setStats] = useState(null);
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);

  useEffect(() => {
    fetchErrorStats();
    fetchErrorLogs();
  }, [date]);

  const fetchErrorLogs = async () => {
    try {
      const response = await axios.get(
        `/api/super-admin/logs/by-date?date=${date}`,
        getHeaders()
      );
      if (response.data.success) {
        setLogs(response.data.data.logs);
      }
    } catch (error) {
      console.error('Error fetching logs:', error);
    }
  };

  const fetchErrorStats = async () => {
    try {
      const response = await axios.get(
        `/api/super-admin/logs/summary?date=${date}`,
        getHeaders()
      );
      if (response.data.success) {
        setStats(response.data.data);
      }
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  return (
    <div className="error-logs-container">
      <h2>API Error Monitoring</h2>
      
      <div className="date-filter">
        <input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
        />
      </div>

      {stats && (
        <div className="error-stats">
          <div className="stat-card">
            <h3>Total Errors</h3>
            <p>{stats.overview.totalErrors}</p>
          </div>
          <div className="stat-card">
            <h3>Affected Shops</h3>
            <p>{stats.overview.affectedShops}</p>
          </div>
          <div className="stat-card">
            <h3>Affected Endpoints</h3>
            <p>{stats.overview.affectedEndpoints}</p>
          </div>
        </div>
      )}

      <div className="error-logs-table">
        <table>
          <thead>
            <tr>
              <th>Time</th>
              <th>Status</th>
              <th>Method</th>
              <th>Endpoint</th>
              <th>Shop ID</th>
              <th>User</th>
              <th>Response Time</th>
            </tr>
          </thead>
          <tbody>
            {logs.map((log, index) => (
              <tr key={index}>
                <td>{new Date(log.timestamp).toLocaleTimeString()}</td>
                <td><span className={`status-${log.statusCode}`}>{log.statusCode}</span></td>
                <td>{log.method}</td>
                <td>{log.endpoint}</td>
                <td>{log.shopId || 'N/A'}</td>
                <td>{log.userId || 'Anonymous'}</td>
                <td>{log.responseTime}ms</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ErrorLogsMonitoring;
```

---

## Database Integration Notes

The error logging service is **file-based** (not database dependent), which means:

✅ No additional database tables needed
✅ Works independently of multi-tenant architecture
✅ Fast write performance
✅ Easy to export/backup logs
✅ Can be accessed even if database is down

---

## Best Practices

1. **Regular Monitoring** - Check error logs daily for anomalies
2. **Action on Patterns** - Investigate if the same error repeats
3. **Shop-Specific Issues** - Filter by shop_id to isolate tenant problems
4. **Response Time Tracking** - Monitor slow endpoints (high responseTime)
5. **User Activity** - Track which users trigger errors
6. **Backup Logs** - Periodically backup logs before they expire

---

## Troubleshooting

### Logs Not Being Written
1. Check `/logs` directory permissions (should be writable)
2. Verify middleware is properly integrated in server.js
3. Check Node.js console for "Failed to write error log" messages

### Missing Logs for Specific Errors
- File-based errors that occur before middleware (e.g., parsing errors) may not be captured
- Database errors return error objects that are logged by the errorLoggingMiddleware

### Performance Impact
- Logging adds minimal overhead (~1-2ms per request)
- Async file operations don't block request processing
- No database queries required

---

## Support & Monitoring

For 24/7 monitoring, consider adding these checks:

```bash
# Monitor log file growth
watch -n 5 'ls -lh logs/error-*.log'

# Count errors by hour
grep -o '"timestamp":"[^"]*' logs/error-*.log | wc -l

# Find most common errors
grep -o '"statusCode":[0-9]*' logs/error-*.log | sort | uniq -c | sort -rn
```

---

## Version
**1.0.0** - Initial implementation
- Basic error logging
- Date-based organization
- Super admin API endpoints
- Statistics aggregation
