const express = require('express');
const router = express.Router();
const featureController = require('../controllers/featureController');
const auth = require('../middleware/auth');

// Get user's current subscription
router.get('/subscription', auth.isAuthorize, featureController.getUserSubscription);

// Get all user features
router.get('/features', auth.isAuthorize, featureController.getUserFeatures);

// Check specific feature access
router.get('/features/:featureCode/access', auth.isAuthorize, featureController.checkFeatureAccess);

// Update feature usage
router.post('/features/:featureCode/usage', auth.isAuthorize, featureController.updateFeatureUsage);

// Get feature usage for specific feature
router.get('/features/:featureCode/usage', auth.isAuthorize, featureController.getFeatureUsage);

// Get all subscription plans
router.get('/plans', auth.isAuthorize, featureController.getSubscriptionPlans);

// Get plan features comparison
router.get('/plans/comparison', auth.isAuthorize, featureController.getPlanFeaturesComparison);

// Change user subscription
router.post('/subscription/change', auth.isAuthorize, featureController.changeUserSubscription);

// Example protected route using feature access middleware
router.get('/protected/suppliers', 
    auth.isAuthorize, 
    featureController.checkFeatureAccessMiddleware('suppliers'), 
    featureController.getProtectedSuppliers
);

module.exports = router;
