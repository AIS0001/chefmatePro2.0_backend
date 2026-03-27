/**
 * SUPER ADMIN AUTHENTICATION MIDDLEWARE
 * Verifies that the user is a super admin
 */

const isSuperAdmin = (req, res, next) => {
  try {
    // Check if user is authenticated
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required'
      });
    }

    // Check if user has super admin role
    const isSuperAdminUser = 
      req.user.role === 'super_admin' || 
      req.user.is_super_admin === true ||
      req.user.is_super_admin === 1;

    if (!isSuperAdminUser) {
      return res.status(403).json({
        success: false,
        error: 'Super admin access required',
        message: 'You do not have permission to access this resource'
      });
    }

    // User is super admin, proceed
    next();
  } catch (error) {
    console.error('Error in super admin middleware:', error);
    res.status(500).json({
      success: false,
      error: 'Authentication check failed',
      details: error.message
    });
  }
};

module.exports = {
  isSuperAdmin
};
