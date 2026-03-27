/**
 * PAYMENT CHECK MIDDLEWARE
 * Verifies shop has active subscription and payment is not overdue
 * Prevents login if subscription is not active or payment is overdue
 */

const paymentController = require('../controllers/paymentController');

/**
 * Middleware to check payment status before allowing login/access
 * Attach to protected routes that require active subscription
 */
exports.checkPaymentStatus = async (req, res, next) => {
  try {
    // Only check for shop users, not super admin
    if (req.user && (req.user.role === 'super_admin' || req.user.is_super_admin)) {
      return next();
    }

    // Get shop_id from user
    const shop_id = req.user?.shop_id || req.body?.shop_id || req.query?.shop_id;

    if (!shop_id) {
      return res.status(400).json({
        success: false,
        error: 'Shop ID not found',
        requiresPayment: false
      });
    }

    // Check payment status
    const paymentStatus = await paymentController.checkShopPaymentStatus(shop_id);

    if (!paymentStatus.isActive) {
      return res.status(403).json({
        success: false,
        error: paymentStatus.message,
        requiresPayment: true,
        status: paymentStatus.status,
        dueDate: paymentStatus.dueDate
      });
    }

    // Payment is active, proceed
    req.paymentStatus = paymentStatus;
    next();

  } catch (error) {
    console.error('Error in payment check middleware:', error);
    // Don't block access on error, log and proceed
    console.error('Payment check failed, allowing access:', error.message);
    next();
  }
};

/**
 * Optional: Middleware to warn about upcoming due dates
 * Adds warning to response headers
 */
exports.addPaymentWarning = async (req, res, next) => {
  try {
    const shop_id = req.user?.shop_id;

    if (!shop_id) {
      return next();
    }

    // Get payment status without requiring active
    const paymentStatus = await paymentController.checkShopPaymentStatus(shop_id);

    // Add warning header if close to due date
    if (paymentStatus.dueDate) {
      const daysUntilDue = Math.floor(
        (new Date(paymentStatus.dueDate) - new Date()) / (1000 * 60 * 60 * 24)
      );

      if (daysUntilDue <= 7 && daysUntilDue >= 0) {
        res.set('X-Payment-Warning', `Payment due in ${daysUntilDue} days`);
      }
    }

    next();

  } catch (error) {
    console.error('Error in payment warning middleware:', error);
    next();
  }
};
