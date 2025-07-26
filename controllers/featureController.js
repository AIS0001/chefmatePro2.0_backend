const FeatureControlService = require('../services/featureControlService');

const featureService = new FeatureControlService();

// Get user's current subscription
const getUserSubscription = async (req, res) => {
    try {
        const userId = req.user.id;
        const subscription = await featureService.getUserSubscription(userId);
        
        if (!subscription) {
            return res.status(404).json({
                success: false,
                message: 'No active subscription found'
            });
        }

        res.json({
            success: true,
            data: subscription
        });
    } catch (error) {
        console.error('Error fetching subscription:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Get all user features
const getUserFeatures = async (req, res) => {
    try {
        const userId = req.user.id;
        const features = await featureService.getUserFeatures(userId);

        res.json({
            success: true,
            data: features
        });
    } catch (error) {
        console.error('Error fetching features:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Check specific feature access
const checkFeatureAccess = async (req, res) => {
    try {
        const userId = req.user.id;
        const { featureCode } = req.params;
        
        const access = await featureService.checkFeatureAccess(userId, featureCode);

        res.json({
            success: true,
            data: access
        });
    } catch (error) {
        console.error('Error checking feature access:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Update feature usage
const updateFeatureUsage = async (req, res) => {
    try {
        const userId = req.user.id;
        const { featureCode } = req.params;
        const { increment = 1 } = req.body;

        // Check if user has access to this feature first
        const access = await featureService.checkFeatureAccess(userId, featureCode);
        
        if (!access.hasAccess) {
            return res.status(403).json({
                success: false,
                message: access.reason,
                data: access
            });
        }

        const usage = await featureService.updateFeatureUsage(userId, featureCode, increment);

        res.json({
            success: true,
            data: usage
        });
    } catch (error) {
        console.error('Error updating feature usage:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Get feature usage for specific feature
const getFeatureUsage = async (req, res) => {
    try {
        const userId = req.user.id;
        const { featureCode } = req.params;
        
        const usage = await featureService.getFeatureUsage(userId, featureCode);

        res.json({
            success: true,
            data: usage
        });
    } catch (error) {
        console.error('Error fetching feature usage:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Get all subscription plans
const getSubscriptionPlans = async (req, res) => {
    try {
        const plans = await featureService.getSubscriptionPlans();

        res.json({
            success: true,
            data: plans
        });
    } catch (error) {
        console.error('Error fetching subscription plans:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Get plan features comparison
const getPlanFeaturesComparison = async (req, res) => {
    try {
        const comparison = await featureService.getPlanFeaturesComparison();

        res.json({
            success: true,
            data: comparison
        });
    } catch (error) {
        console.error('Error fetching plan comparison:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

// Change user subscription
const changeUserSubscription = async (req, res) => {
    try {
        const userId = req.user.id;
        const { planCode } = req.body;

        if (!planCode) {
            return res.status(400).json({
                success: false,
                message: 'Plan code is required'
            });
        }

        const result = await featureService.changeUserSubscription(userId, planCode);

        res.json({
            success: true,
            message: result.message
        });
    } catch (error) {
        console.error('Error changing subscription:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Internal server error'
        });
    }
};

// Middleware to check feature access for protected routes
const checkFeatureAccessMiddleware = (featureCode) => {
    return async (req, res, next) => {
        try {
            const userId = req.user.id;
            const access = await featureService.checkFeatureAccess(userId, featureCode);
            
            if (!access.hasAccess) {
                return res.status(403).json({
                    success: false,
                    message: 'Access denied',
                    reason: access.reason,
                    featureCode: featureCode
                });
            }
            
            // Add feature info to request object
            req.featureAccess = access;
            next();
        } catch (error) {
            console.error('Error checking feature access:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error'
            });
        }
    };
};

// Example protected route handler
const getProtectedSuppliers = (req, res) => {
    res.json({
        success: true,
        message: 'Access granted to suppliers feature',
        featureAccess: req.featureAccess
    });
};

module.exports = {
    getUserSubscription,
    getUserFeatures,
    checkFeatureAccess,
    updateFeatureUsage,
    getFeatureUsage,
    getSubscriptionPlans,
    getPlanFeaturesComparison,
    changeUserSubscription,
    checkFeatureAccessMiddleware,
    getProtectedSuppliers
};
