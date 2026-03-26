/**
 * MULTI-TENANT MIDDLEWARE
 * Handles shop context for all requests
 */

const tenantMiddleware = (req, res, next) => {
  try {
    // Get shop_id from:
    // 1. URL params
    // 2. Query string
    // 3. Request body
    // 4. JWT token
    // 5. Session

    let shopId = 
      req.params.shop_id || 
      req.query.shop_id || 
      req.body.shop_id || 
      req.user?.shop_id || 
      req.session?.shop_id ||
      1; // Default to 1 for backward compatibility

    // Store in request object for use in controllers
    req.shop_id = parseInt(shopId);
    req.shopContext = {
      id: req.shop_id,
      user_id: req.user?.id,
      user_role: req.user?.role,
    };

    // Log tenant context for audit
    console.log(`[TENANT] Shop: ${req.shop_id}, User: ${req.user?.username}, Action: ${req.method} ${req.path}`);

    next();
  } catch (error) {
    res.status(400).json({ error: 'Invalid tenant context', details: error.message });
  }
};

/**
 * SHOP AUTHORIZATION MIDDLEWARE
 * Ensures user has access to the requested shop
 */
const shopAuthMiddleware = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  // Super admin has access to all shops
  if (req.user.role === 'super_admin' || req.user.role === 'admin' && req.user.is_super_admin) {
    return next();
  }

  // Regular user can only access their shop
  if (req.user.shop_id !== req.shop_id) {
    return res.status(403).json({ error: 'Access denied to this shop' });
  }

  next();
};

/**
 * QUERY BUILDER WITH SHOP ISOLATION
 * Automatically adds shop_id condition to all queries
 * Usage: getWithShop(connection, 'SELECT * FROM users WHERE id = ?', [userId])
 */
const getWithShop = async (connection, query, params = [], shopId = null) => {
  try {
    const actualShopId = shopId || global.currentShop?.id || 1;
    
    // Add shop_id filter to query
    let isolatedQuery = query;
    if (!query.includes('shop_id')) {
      // Intelligently add shop_id condition
      if (query.toLowerCase().includes('where')) {
        isolatedQuery = query.replace(/where/i, `WHERE shop_id = ${actualShopId} AND`);
      } else if (query.toLowerCase().includes('from')) {
        isolatedQuery = query + ` WHERE shop_id = ${actualShopId}`;
      }
    }

    return [isolatedQuery, params, actualShopId];
  } catch (error) {
    console.error('Query isolation error:', error);
    throw error;
  }
};

module.exports = {
  tenantMiddleware,
  shopAuthMiddleware,
  getWithShop,
};
