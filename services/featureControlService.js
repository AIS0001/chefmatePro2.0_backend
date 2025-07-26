const db = require('../config/dbconnection1');

class FeatureControlService {
    
    // Get user's current subscription
    async getUserSubscription(userId) {
        try {
            const query = `
                SELECT us.*, sp.plan_name, sp.duration_months, sp.price
                FROM user_subscriptions us
                JOIN subscription_plans sp ON us.plan_id = sp.id
                WHERE us.user_id = ? AND us.status = 'active'
                ORDER BY us.created_at DESC
                LIMIT 1
            `;
            const [result] = await db.query(query, [userId]);
            return result[0] || null;
        } catch (error) {
            console.error('Error fetching user subscription:', error);
            throw error;
        }
    }

    // Get all user features based on subscription
    async getUserFeatures(userId) {
        try {
            const query = `
                SELECT f.*, pf.feature_limit, pf.is_unlimited
                FROM features f
                JOIN plan_features pf ON f.id = pf.feature_id
                JOIN subscription_plans sp ON pf.plan_id = sp.id
                JOIN user_subscriptions us ON sp.id = us.plan_id
                WHERE us.user_id = ? AND us.status = 'active'
                ORDER BY f.feature_name
            `;
            const [result] = await db.query(query, [userId]);
            return result;
        } catch (error) {
            console.error('Error fetching user features:', error);
            throw error;
        }
    }

    // Check if user has access to specific feature
    async checkFeatureAccess(userId, featureCode) {
        try {
            // Get user's subscription and feature limits
            const query = `
                SELECT f.*, pf.feature_limit, pf.is_unlimited, us.status as subscription_status,
                       COALESCE(fu.usage_count, 0) as current_usage,
                       us.expires_at
                FROM features f
                JOIN plan_features pf ON f.id = pf.feature_id
                JOIN subscription_plans sp ON pf.plan_id = sp.id
                JOIN user_subscriptions us ON sp.id = us.plan_id
                LEFT JOIN feature_usage fu ON f.id = fu.feature_id AND fu.user_id = us.user_id
                WHERE us.user_id = ? AND f.feature_code = ?
                ORDER BY us.created_at DESC
                LIMIT 1
            `;
            const [result] = await db.query(query, [userId, featureCode]);
            
            if (!result.length) {
                return {
                    hasAccess: false,
                    reason: 'Feature not available in current subscription',
                    featureCode: featureCode
                };
            }

            const feature = result[0];
            
            // Check if subscription is active
            if (feature.subscription_status !== 'active') {
                return {
                    hasAccess: false,
                    reason: 'Subscription is not active',
                    featureCode: featureCode
                };
            }

            // Check if subscription has expired
            if (feature.expires_at && new Date() > new Date(feature.expires_at)) {
                return {
                    hasAccess: false,
                    reason: 'Subscription has expired',
                    featureCode: featureCode
                };
            }

            // Check usage limits
            if (!feature.is_unlimited && feature.current_usage >= feature.feature_limit) {
                return {
                    hasAccess: false,
                    reason: 'Feature usage limit exceeded',
                    featureCode: featureCode,
                    currentUsage: feature.current_usage,
                    limit: feature.feature_limit
                };
            }

            return {
                hasAccess: true,
                featureCode: featureCode,
                currentUsage: feature.current_usage,
                limit: feature.feature_limit,
                isUnlimited: feature.is_unlimited
            };
        } catch (error) {
            console.error('Error checking feature access:', error);
            throw error;
        }
    }

    // Update feature usage
    async updateFeatureUsage(userId, featureCode, increment = 1) {
        try {
            // First get feature ID
            const [featureResult] = await db.query('SELECT id FROM features WHERE feature_code = ?', [featureCode]);
            if (!featureResult.length) {
                throw new Error('Feature not found');
            }
            const featureId = featureResult[0].id;

            // Check if usage record exists
            const [usageResult] = await db.query(
                'SELECT id, usage_count FROM feature_usage WHERE user_id = ? AND feature_id = ?',
                [userId, featureId]
            );

            if (usageResult.length) {
                // Update existing usage
                await db.query(
                    'UPDATE feature_usage SET usage_count = usage_count + ?, last_used = NOW() WHERE user_id = ? AND feature_id = ?',
                    [increment, userId, featureId]
                );
            } else {
                // Create new usage record
                await db.query(
                    'INSERT INTO feature_usage (user_id, feature_id, usage_count, last_used) VALUES (?, ?, ?, NOW())',
                    [userId, featureId, increment]
                );
            }

            // Return updated usage
            return await this.getFeatureUsage(userId, featureCode);
        } catch (error) {
            console.error('Error updating feature usage:', error);
            throw error;
        }
    }

    // Get feature usage for specific feature
    async getFeatureUsage(userId, featureCode) {
        try {
            const query = `
                SELECT f.feature_name, f.feature_code, 
                       COALESCE(fu.usage_count, 0) as current_usage,
                       pf.feature_limit, pf.is_unlimited,
                       fu.last_used
                FROM features f
                JOIN plan_features pf ON f.id = pf.feature_id
                JOIN subscription_plans sp ON pf.plan_id = sp.id
                JOIN user_subscriptions us ON sp.id = us.plan_id
                LEFT JOIN feature_usage fu ON f.id = fu.feature_id AND fu.user_id = us.user_id
                WHERE us.user_id = ? AND f.feature_code = ? AND us.status = 'active'
                ORDER BY us.created_at DESC
                LIMIT 1
            `;
            const [result] = await db.query(query, [userId, featureCode]);
            return result[0] || null;
        } catch (error) {
            console.error('Error fetching feature usage:', error);
            throw error;
        }
    }

    // Get all subscription plans
    async getSubscriptionPlans() {
        try {
            const query = `
                SELECT * FROM subscription_plans 
                WHERE status = 'active'
                ORDER BY price ASC
            `;
            const [result] = await db.query(query);
            return result;
        } catch (error) {
            console.error('Error fetching subscription plans:', error);
            throw error;
        }
    }

    // Get plan features comparison
    async getPlanFeaturesComparison() {
        try {
            const query = `
                SELECT sp.plan_name, sp.plan_code, sp.price, sp.duration_months,
                       f.feature_name, f.feature_code, f.description,
                       pf.feature_limit, pf.is_unlimited
                FROM subscription_plans sp
                JOIN plan_features pf ON sp.id = pf.plan_id
                JOIN features f ON pf.feature_id = f.id
                WHERE sp.status = 'active'
                ORDER BY sp.price ASC, f.feature_name ASC
            `;
            const [result] = await db.query(query);
            
            // Group by plan
            const planComparison = {};
            result.forEach(row => {
                if (!planComparison[row.plan_code]) {
                    planComparison[row.plan_code] = {
                        plan_name: row.plan_name,
                        plan_code: row.plan_code,
                        price: row.price,
                        duration_months: row.duration_months,
                        features: []
                    };
                }
                planComparison[row.plan_code].features.push({
                    feature_name: row.feature_name,
                    feature_code: row.feature_code,
                    description: row.description,
                    feature_limit: row.feature_limit,
                    is_unlimited: row.is_unlimited
                });
            });

            return Object.values(planComparison);
        } catch (error) {
            console.error('Error fetching plan comparison:', error);
            throw error;
        }
    }

    // Change user subscription
    async changeUserSubscription(userId, planCode) {
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            // Get plan details
            const [planResult] = await connection.query(
                'SELECT * FROM subscription_plans WHERE plan_code = ? AND status = "active"',
                [planCode]
            );

            if (!planResult.length) {
                throw new Error('Invalid plan code');
            }

            const plan = planResult[0];

            // Deactivate current subscription
            await connection.query(
                'UPDATE user_subscriptions SET status = "inactive" WHERE user_id = ? AND status = "active"',
                [userId]
            );

            // Create new subscription
            const expiresAt = new Date();
            expiresAt.setMonth(expiresAt.getMonth() + plan.duration_months);

            await connection.query(`
                INSERT INTO user_subscriptions (user_id, plan_id, status, expires_at, created_at)
                VALUES (?, ?, 'active', ?, NOW())
            `, [userId, plan.id, expiresAt]);

            // Reset feature usage for new subscription
            await connection.query(
                'DELETE FROM feature_usage WHERE user_id = ?',
                [userId]
            );

            await connection.commit();

            return {
                message: `Subscription changed to ${plan.plan_name} successfully`,
                plan: plan
            };
        } catch (error) {
            await connection.rollback();
            console.error('Error changing subscription:', error);
            throw error;
        } finally {
            connection.release();
        }
    }
}

module.exports = FeatureControlService;
