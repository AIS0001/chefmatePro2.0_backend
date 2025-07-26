# Feature Control System Usage Guide

## Overview
This feature control system allows you to manage user subscriptions and restrict access to features based on subscription plans.

## API Endpoints

### 1. Get User Subscription
```
GET /api/subscription
```
Returns the user's current active subscription details.

### 2. Get User Features
```
GET /api/features
```
Returns all features available to the user based on their subscription.

### 3. Check Feature Access
```
GET /api/features/:featureCode/access
```
Check if user has access to a specific feature.

### 4. Update Feature Usage
```
POST /api/features/:featureCode/usage
Body: { "increment": 1 }
```
Increment usage count for a feature.

### 5. Get Feature Usage
```
GET /api/features/:featureCode/usage
```
Get current usage statistics for a feature.

### 6. Get All Plans
```
GET /api/plans
```
Get all available subscription plans.

### 7. Get Plans Comparison
```
GET /api/plans/comparison
```
Get detailed comparison of all plans and their features.

### 8. Change Subscription
```
POST /api/subscription/change
Body: { "planCode": "premium" }
```
Change user's subscription plan.

## Available Features

1. **suppliers** - Supplier management
2. **inventory** - Inventory management
3. **reports** - Advanced reporting
4. **multi_location** - Multiple locations
5. **api_access** - API access
6. **custom_branding** - Custom branding
7. **priority_support** - Priority support
8. **data_export** - Data export functionality
9. **online_ordering** - Online ordering
10. **staff_management** - Staff management

## How to Protect Routes

### Method 1: Using Middleware in Routes
```javascript
const { protectFeature } = require('../middleware/featureAccess');

// Protect a route with feature access
router.get('/suppliers', auth.isAuthorize, ...protectFeature('suppliers'), supplierController.getSuppliers);

// Protect without tracking usage
router.get('/suppliers', auth.isAuthorize, requireFeatureAccess('suppliers'), supplierController.getSuppliers);
```

### Method 2: Using Controller Middleware
```javascript
const { requireFeatureAccess } = require('../middleware/featureAccess');

// In your controller
router.get('/inventory', 
    auth.isAuthorize, 
    requireFeatureAccess('inventory'), 
    viewcontroller.getInventoryWithItems
);
```

## Frontend Integration

### Check Feature Access Before Showing UI
```javascript
// Check if user has access to suppliers feature
const checkSupplierAccess = async () => {
    try {
        const response = await fetch('/api/features/suppliers/access', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const data = await response.json();
        
        if (data.success && data.data.hasAccess) {
            // Show suppliers menu/button
            showSuppliersMenu();
        } else {
            // Show upgrade message
            showUpgradeMessage(data.data.reason);
        }
    } catch (error) {
        console.error('Error checking feature access:', error);
    }
};
```

### Display Usage Information
```javascript
// Get current usage for a feature
const getFeatureUsage = async (featureCode) => {
    try {
        const response = await fetch(`/api/features/${featureCode}/usage`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const data = await response.json();
        
        if (data.success) {
            const { current_usage, feature_limit, is_unlimited } = data.data;
            
            if (is_unlimited) {
                return `Usage: ${current_usage} (Unlimited)`;
            } else {
                return `Usage: ${current_usage}/${feature_limit}`;
            }
        }
    } catch (error) {
        console.error('Error getting feature usage:', error);
    }
};
```

### Handle Feature Access Errors
```javascript
// Handle API responses for feature-protected endpoints
const handleFeatureResponse = (response) => {
    if (response.status === 403) {
        // Feature access denied
        response.json().then(data => {
            if (data.upgradeRequired) {
                showUpgradeModal(data.reason, data.featureCode);
            } else {
                showErrorMessage(data.reason);
            }
        });
        return false;
    }
    return true;
};
```

## Database Setup

Run the SQL script in `database/feature_control_schema.sql` to create the required tables:

```sql
mysql -u username -p database_name < database/feature_control_schema.sql
```

## Configuration

Make sure your `auth.js` middleware sets `req.user.id` for authenticated users.

## Error Handling

The system returns structured error responses:

```javascript
{
    "success": false,
    "message": "Access denied",
    "reason": "Feature usage limit exceeded",
    "featureCode": "suppliers",
    "upgradeRequired": true
}
```

## Example Usage in Controllers

```javascript
// In your controller, after feature access is granted
const createSupplier = async (req, res) => {
    try {
        // Feature access already verified by middleware
        // Create supplier logic here
        
        // Usage is automatically tracked by middleware
        res.json({ success: true, data: newSupplier });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
```

## Testing

Test the feature access system:

1. Create a user with basic subscription
2. Try to access premium features
3. Verify proper error responses
4. Test usage limits
5. Test subscription changes
