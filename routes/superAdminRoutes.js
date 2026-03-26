/**
 * SUPER ADMIN ROUTES
 * Routes for managing all shops and SaaS platform
 */

const express = require('express');
const router = express.Router();
const superAdminController = require('../controllers/superAdminController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Ensure user is authenticated and is super admin
const superAdminAuth = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  if (req.user.role !== 'super_admin' && !req.user.is_super_admin) {
    return res.status(403).json({ error: 'Super admin access required' });
  }

  next();
};

// =====================================================
// AUTHENTICATION ROUTES (Public - No Auth Required)
// =====================================================

// Super admin login
router.post('/login', superAdminController.login);

// =====================================================
// AUTHENTICATED ROUTES (Auth Required)
// =====================================================

// Get current profile
router.get('/profile', authMiddleware, superAdminAuth, superAdminController.getProfile);

// Change password
router.post('/change-password', authMiddleware, superAdminAuth, superAdminController.changePassword);

// =====================================================
// SHOP MANAGEMENT ROUTES
// =====================================================

// Get all shops with pagination and filters
router.get('/shops', authMiddleware, superAdminAuth, superAdminController.getAllShops);

// Get specific shop details
router.get('/shops/:shop_id', authMiddleware, superAdminAuth, superAdminController.getShopDetails);

// Create new shop
router.post('/shops', authMiddleware, superAdminAuth, superAdminController.createShop);

// Update shop details
router.put('/shops/:shop_id', authMiddleware, superAdminAuth, superAdminController.updateShop);

// Activate/Deactivate shop
router.patch('/shops/:shop_id/status', authMiddleware, superAdminAuth, superAdminController.toggleShopStatus);

// =====================================================
// SHOP USER MANAGEMENT ROUTES (users table)
// =====================================================

// Get ALL users across all shops (User Management page)
router.get('/users/all', authMiddleware, superAdminAuth, superAdminController.getAllUsers);

// Create a user (assign to shop)
router.post('/users', authMiddleware, superAdminAuth, superAdminController.createUser);

// Update a user
router.put('/users/:user_id', authMiddleware, superAdminAuth, superAdminController.updateUser);

// Delete a user (terminate)
router.delete('/users/:user_id', authMiddleware, superAdminAuth, superAdminController.deleteUser);

// Get all users for a shop
router.get('/shops/:shop_id/users', authMiddleware, superAdminAuth, superAdminController.getShopUsers);

// Create user for a shop
router.post('/shops/:shop_id/users', authMiddleware, superAdminAuth, superAdminController.createShopUser);

// Update a shop user
router.put('/shops/:shop_id/users/:user_id', authMiddleware, superAdminAuth, superAdminController.updateShopUser);

// Delete a shop user
router.delete('/shops/:shop_id/users/:user_id', authMiddleware, superAdminAuth, superAdminController.deleteShopUser);

// =====================================================
// BILLING MANAGEMENT ROUTES
// =====================================================

// Get billing information for a shop
router.get('/shops/:shop_id/billing', authMiddleware, superAdminAuth, superAdminController.getShopBilling);

// =====================================================
// USER MANAGEMENT (SUPER ADMIN) ROUTES
// =====================================================

// Get all super admin users
router.get('/users/super-admins', authMiddleware, superAdminAuth, superAdminController.getSuperAdminUsers);

// Create new super admin user
router.post('/users/super-admins', authMiddleware, superAdminAuth, superAdminController.createSuperAdminUser);

// Update super admin user
router.put('/users/super-admins/:user_id', authMiddleware, superAdminAuth, superAdminController.updateSuperAdminUser);

// Delete super admin user
router.delete('/users/super-admins/:user_id', authMiddleware, superAdminAuth, superAdminController.deleteSuperAdminUser);

// =====================================================
// SUBSCRIPTION PLANS ROUTES
// =====================================================

// Get all subscription plans
router.get('/subscription-plans', authMiddleware, superAdminAuth, superAdminController.getSubscriptionPlans);

// Create subscription plan
router.post('/subscription-plans', authMiddleware, superAdminAuth, superAdminController.createSubscriptionPlan);

// Update subscription plan
router.put('/subscription-plans/:plan_id', authMiddleware, superAdminAuth, superAdminController.updateSubscriptionPlan);

// Delete subscription plan
router.delete('/subscription-plans/:plan_id', authMiddleware, superAdminAuth, superAdminController.deleteSubscriptionPlan);

// =====================================================
// ANALYTICS & REPORTING ROUTES
// =====================================================

// Get platform dashboard statistics
router.get('/dashboard/stats', authMiddleware, superAdminAuth, superAdminController.getDashboardStats);

// Get revenue analytics
router.get('/analytics/revenue', authMiddleware, superAdminAuth, superAdminController.getRevenueAnalytics);

// Get shop comparison analytics
router.get('/analytics/shops-comparison', authMiddleware, superAdminAuth, superAdminController.getShopComparison);

// Get system health metrics
router.get('/analytics/system-health', authMiddleware, superAdminAuth, superAdminController.getSystemHealth);

// Get audit logs
router.get('/audit-logs', authMiddleware, superAdminAuth, superAdminController.getAuditLogs);

module.exports = router;
