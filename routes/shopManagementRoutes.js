/**
 * SHOP MANAGEMENT ROUTES
 * Routes for shop owners/managers to manage their shop
 */

const express = require('express');
const router = express.Router();
const shopManagementController = require('../controllers/shopManagementController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { tenantMiddleware, shopAuthMiddleware } = require('../middleware/tenantMiddleware');

// Apply tenant and auth middleware to all routes
router.use(authMiddleware);
router.use(tenantMiddleware);
router.use(shopAuthMiddleware);

// =====================================================
// SHOP PROFILE ROUTES
// =====================================================

// Get current shop profile
router.get('/profile', shopManagementController.getShopProfile);

// Update shop profile
router.put('/profile', shopManagementController.updateShopProfile);

// =====================================================
// STAFF MANAGEMENT ROUTES
// =====================================================

// Get all staff members in shop
router.get('/staff', shopManagementController.getShopStaff);

// Add staff member to shop
router.post('/staff', shopManagementController.addStaffMember);

// Remove staff member
router.delete('/staff/:staff_id', shopManagementController.removeStaffMember);

// =====================================================
// ANALYTICS ROUTES
// =====================================================

// Get shop analytics
router.get('/analytics', shopManagementController.getShopAnalytics);

// =====================================================
// SUBSCRIPTION ROUTES
// =====================================================

// Upgrade subscription plan
router.post('/subscription/upgrade', shopManagementController.upgradeSubscription);

module.exports = router;
