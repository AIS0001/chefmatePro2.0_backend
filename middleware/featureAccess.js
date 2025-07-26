const FeatureControlService = require('../services/featureControlService');

const featureService = new FeatureControlService();

// Middleware to check feature access for protected routes
const requireFeatureAccess = (featureCode) => {
    return async (req, res, next) => {
        try {
            // Check if user is authenticated
            if (!req.user || !req.user.id) {
                return res.status(401).json({
                    success: false,
                    message: 'Authentication required'
                });
            }

            const userId = req.user.id;
            const access = await featureService.checkFeatureAccess(userId, featureCode);
            
            if (!access.hasAccess) {
                return res.status(403).json({
                    success: false,
                    message: 'Access denied',
                    reason: access.reason,
                    featureCode: featureCode,
                    upgradeRequired: true
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

// Middleware to track feature usage
const trackFeatureUsage = (featureCode, increment = 1) => {
    return async (req, res, next) => {
        try {
            if (req.user && req.user.id) {
                // Track usage in background, don't block the request
                setImmediate(async () => {
                    try {
                        await featureService.updateFeatureUsage(req.user.id, featureCode, increment);
                    } catch (error) {
                        console.error('Error tracking feature usage:', error);
                    }
                });
            }
            next();
        } catch (error) {
            console.error('Error in trackFeatureUsage middleware:', error);
            next(); // Don't block the request if tracking fails
        }
    };
};

// Combined middleware for access control and usage tracking
const protectFeature = (featureCode, trackUsage = true) => {
    return [
        requireFeatureAccess(featureCode),
        ...(trackUsage ? [trackFeatureUsage(featureCode)] : [])
    ];
};

module.exports = {
    requireFeatureAccess,
    trackFeatureUsage,
    protectFeature
};
