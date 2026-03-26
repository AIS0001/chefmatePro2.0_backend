# ChefMate Pro - SaaS Implementation Guide

## Overview
This guide walks through converting the ChefMate POS system from a single-tenant application to a multi-tenant SaaS platform where:
- Multiple restaurants/shops can use the same database
- Each shop has isolated data using `shop_id`
- A super admin dashboard manages all shops
- Billing and subscription management is built-in

---

## PHASE 1: Database Migration

### Step 1: Run Migration Script
```bash
# Import the migration SQL file into your database
mysql -u [username] -p [database_name] < database/SAAS_MIGRATION_01_ADD_SHOP_ID.sql
```

### What the Migration Does:
1. **Creates new management tables:**
   - `shops` - Stores all shop/restaurant information
   - `super_admin_users` - Super admin user accounts
   - `shop_admins` - Mapping of users to shops
   - `subscription_plans` - Available subscription tiers
   - `shop_billing` - Billing records for each shop
   - `shop_audit_logs` - Audit trail for all actions

2. **Adds `shop_id` to these existing tables:**
   - users
   - categories
   - menu_items
   - bills
   - advance_final_bill
   - advance_orders
   - advance_order_items
   - bill_edit_logs
   - cash_drawer
   - purchase_orders
   - stock
   - company_profile
   - printer_config
   - device_auth

3. **Creates default shop:**
   - Shop ID = 1 for existing data
   - All legacy data automatically associated with default shop

### Verification:
```sql
-- Verify shops table created
SELECT * FROM shops;

-- Verify shop_id added to users
DESCRIBE users;
```

---

## PHASE 2: Backend API Implementation

### Step 1: Update Environment Variables
Create/update `.env` file:
```env
DB_HOST=localhost
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=chefmatepro
ENABLE_MULTI_TENANT=true
DEFAULT_SHOP_ID=1
JWT_SECRET=your_jwt_secret
```

### Step 2: Install New Middleware
The following middleware files have been created:
- `middleware/tenantMiddleware.js` - Handles shop context extraction and validation

### Step 3: Update Existing Controllers
For each controller, add shop_id filtering:

**Example: Before (Single Tenant)**
```javascript
exports.getUsers = (req, res) => {
  const query = 'SELECT * FROM users';
  connection.query(query, (err, results) => {
    res.json(results);
  });
};
```

**Example: After (Multi-Tenant)**
```javascript
const { getWithShop } = require('../middleware/tenantMiddleware');

exports.getUsers = (req, res) => {
  const shopId = req.shop_id;
  const query = 'SELECT * FROM users WHERE shop_id = ?';
  connection.query(query, [shopId], (err, results) => {
    res.json(results);
  });
};
```

### Step 4: API Routes

**Super Admin Routes:**
```
GET    /api/super-admin/shops               - Get all shops
GET    /api/super-admin/shops/:shop_id      - Get shop details
POST   /api/super-admin/shops               - Create new shop
PUT    /api/super-admin/shops/:shop_id      - Update shop
PATCH  /api/super-admin/shops/:shop_id/status - Activate/deactivate
GET    /api/super-admin/shops/:shop_id/billing - Get billing info
GET    /api/super-admin/dashboard/stats     - Platform statistics
GET    /api/super-admin/audit-logs          - View audit logs
```

**Shop Management Routes:**
```
GET    /api/shop/profile                 - Get shop profile
PUT    /api/shop/profile                 - Update shop profile
GET    /api/shop/staff                   - Get shop staff
POST   /api/shop/staff                   - Add staff member
DELETE /api/shop/staff/:staff_id         - Remove staff
GET    /api/shop/analytics               - Get shop analytics
POST   /api/shop/subscription/upgrade    - Upgrade plan
```

---

## PHASE 3: Frontend Implementation

### Super Admin Dashboard Structure
```
/src/pages/superadmin/
├── Dashboard.jsx              - Main analytics dashboard
├── ShopsManagement.jsx        - List and manage shops
├── ShopDetails.jsx            - Shop profile and settings
├── BillingManagement.jsx      - Subscription and billing
├── AuditLogs.jsx              - View all activities
├── SubscriptionPlans.jsx      - Manage plans
└── SuperAdminLayout.jsx       - Navigation wrapper
```

### Shop Admin Dashboard Structure
```
/src/pages/shop/
├── Dashboard.jsx              - Shop dashboard
├── TeamManagement.jsx         - Manage staff
├── ShopSettings.jsx           - Shop configuration
├── Subscriptions.jsx          - Current plan info
└── ShopLayout.jsx             - Navigation wrapper
```

### Example: Super Admin Dashboard (React)
```jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function SuperAdminDashboard() {
  const [stats, setStats] = useState(null);
  const [shops, setShops] = useState([]);

  useEffect(() => {
    // Fetch dashboard statistics
    axios.get('/api/super-admin/dashboard/stats', {
      headers: { Authorization: `Bearer ${token}` }
    }).then(res => setStats(res.data.data));

    // Fetch all shops
    axios.get('/api/super-admin/shops', {
      headers: { Authorization: `Bearer ${token}` }
    }).then(res => setShops(res.data.data));
  }, []);

  return (
    <div className="super-admin-dashboard">
      <h1>SaaS Platform Dashboard</h1>
      
      {stats && (
        <div className="stats-grid">
          <div className="stat-card">
            <h3>Total Shops</h3>
            <p>{stats.totalShops.count}</p>
          </div>
          <div className="stat-card">
            <h3>Active Subscriptions</h3>
            <p>{stats.activeSubscriptions.count}</p>
          </div>
          <div className="stat-card">
            <h3>Total Revenue</h3>
            <p>₹{stats.totalRevenue.total}</p>
          </div>
          <div className="stat-card">
            <h3>Pending Payments</h3>
            <p>{stats.pendingPayments.count}</p>
          </div>
        </div>
      )}

      <div className="shops-section">
        <h2>All Shops</h2>
        <table>
          <thead>
            <tr>
              <th>Shop Name</th>
              <th>Code</th>
              <th>Status</th>
              <th>Plan</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {shops.map(shop => (
              <tr key={shop.id}>
                <td>{shop.name}</td>
                <td>{shop.shop_code}</td>
                <td><span className={`badge ${shop.subscription_status}`}>{shop.subscription_status}</span></td>
                <td>{shop.plan_name}</td>
                <td>{new Date(shop.created_at).toLocaleDateString()}</td>
                <td>
                  <button onClick={() => viewShopDetails(shop.id)}>View</button>
                  <button onClick={() => editShop(shop.id)}>Edit</button>
                  <button onClick={() => toggleStatus(shop.id)}>
                    {shop.is_active ? 'Deactivate' : 'Activate'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default SuperAdminDashboard;
```

---

## PHASE 4: Authentication & Authorization

### Update User Authentication
Modify login response to include shop information:

```javascript
// Updated login response
{
  success: true,
  token: "jwt_token_here",
  user: {
    id: 1,
    username: "admin",
    email: "admin@shop.com",
    role: "admin",
    is_super_admin: false,
    shop_id: 1,
    shop_name: "JANNAAT LOUNGE"
  }
}
```

### User Roles Structure:
```
Super Admin Roles:
  - super_admin (full access)
  - admin (manage shops)
  - support (customer support)
  - billing (billing management)

Shop User Roles:
  - owner
  - manager
  - admin
  - staff
  - viewer (read-only)
```

---

## PHASE 5: Existing Functionality Updates

### Update Controllers to Support Multi-Tenant

**Example: User Controller Update**
```javascript
// OLD: Get all bills
exports.getAllBills = (req, res) => {
  const query = 'SELECT * FROM bills ORDER BY created_at DESC';
  connection.query(query, (err, results) => {
    if (err) res.status(500).json(err);
    res.json(results);
  });
};

// NEW: Get bills for specific shop
exports.getAllBills = (req, res) => {
  const shopId = req.shop_id; // From tenantMiddleware
  const query = 'SELECT * FROM bills WHERE shop_id = ? ORDER BY created_at DESC';
  connection.query(query, [shopId], (err, results) => {
    if (err) res.status(500).json(err);
    res.json(results);
  });
};
```

### Key Controllers to Update:
1. `billControl.js` - Add shop_id filter
2. `stockController.js` - Add shop_id filter
3. `printController.js` - Handle multi-shop printers
4. `userControl.js` - Add shop_id filter
5. `analyticsController.js` - Add shop_id filter
6. All other controllers - Add shop-level filtering

---

## PHASE 6: Testing Checklist

### Database Testing
- [ ] All migration SQL statements executed successfully
- [ ] Default shop created with ID = 1
- [ ] Existing data has shop_id = 1
- [ ] Foreign key relationships working
- [ ] Indexes created for performance

### API Testing
- [ ] Super admin can create new shops
- [ ] Shop data is isolated by shop_id
- [ ] Tenant middleware extracts shop context correctly
- [ ] Users can only access their assigned shop
- [ ] Billing records created correctly
- [ ] Audit logs recording all actions

### Frontend Testing
- [ ] Super admin dashboard displays all shops
- [ ] Shop managers see only their shop data
- [ ] Shop creation form works
- [ ] Staff management works
- [ ] Subscription upgrades work

---

## PHASE 7: Post-Migration

### 1. Backup Database
```bash
mysqldump -u [user] -p [database] > backup_before_saas.sql
```

### 2. Monitor Performance
- Check query performance with shop_id filters
- Monitor database size
- Track API response times

### 3. Set Up Monitoring
```javascript
// Add to logging middleware
console.log(`[SHOP ${req.shop_id}] ${req.method} ${req.path}`);
```

### 4. Create Documentation
- User guides for super admin
- Shop admin setup guide
- API documentation for developers

---

## Common Implementation Patterns

### Pattern 1: Always Filter by Shop
```javascript
// All select queries should include shop_id
const query = 'SELECT * FROM table WHERE shop_id = ? AND other_conditions';
```

### Pattern 2: Always Set Shop on Insert
```javascript
// All insert queries should include shop_id
const query = 'INSERT INTO table (shop_id, ... other_fields) VALUES (?, ...)';
```

### Pattern 3: Check Shop Access
```javascript
// Always verify user can access requested shop
if (req.user.shop_id !== req.shop_id && !req.user.is_super_admin) {
  return res.status(403).json({ error: 'Access denied' });
}
```

---

## Performance Optimization

### 1. Database Indexes
Already created in migration script:
- `idx_shops_subscription_status` - For filtering active shops
- `idx_shop_id` - On all major tables
- `idx_shop_billing_by_shop` - For billing queries
- `idx_shop_audit_logs_shop_action` - For audit filtering

### 2. Caching Strategy
```javascript
// Cache shop data
const redis = require('redis');
const client = redis.createClient();

const getCachedShop = async (shopId) => {
  const cached = await client.get(`shop:${shopId}`);
  if (cached) return JSON.parse(cached);
  
  // If not cached, fetch and cache
  const shop = await getShopFromDB(shopId);
  await client.setex(`shop:${shopId}`, 3600, JSON.stringify(shop));
  return shop;
};
```

### 3. Query Optimization
Use `EXPLAIN` to analyze queries:
```sql
EXPLAIN SELECT * FROM bills WHERE shop_id = 1 AND created_at > DATE_SUB(NOW(), INTERVAL 30 DAY);
```

---

## Troubleshooting

### Issue: Old queries returning wrong data
**Solution:** Add shop_id filter to all SELECT queries

### Issue: Users accessing other shops' data
**Solution:** Implement shopAuthMiddleware on all protected routes

### Issue: Foreign key constraint errors
**Solution:** Ensure shop_id values exist in shops table before inserting

### Issue: Performance degradation
**Solution:** Add indexes on (shop_id, other_frequently_filtered_columns)

---

## Next Steps After Implementation

1. **Monitor Usage** - Track which features are most used per shop
2. **Implement Logging** - Log all important actions to audit_logs
3. **Set Up Alerts** - Alert on subscription expiration, payment failures
4. **Create Reports** - Generate performance reports per shop
5. **Plan Features** - Add shop-specific customizations based on feedback

---

## Support & Maintenance

### Regular Maintenance Tasks
- Weekly: Check for failed payments
- Monthly: Generate billing reports, review audit logs
- Quarterly: Review database growth, optimize queries
- Annually: Plan feature updates, upgrade infrastructure

### Emergency Procedures
- **Shop Lockout:** Immediately disable subscription temporarily
- **Data Corruption:** Restore from backup, audit affected records
- **DDoS Attack:** Rate limit by shop_id, temporarily restrict access
- **Data Breach:** Audit logs will show access patterns

---

**End of Implementation Guide**

For questions or issues, refer to the API documentation in `/docs/` directory.
