const errorLogService = require('../services/errorLogService');

/**
 * ERROR LOGGING MIDDLEWARE
 * Captures and logs all API errors to file with shop_id and other context
 */

/**
 * Global error logging middleware
 * Should be used after all other middleware and route handlers
 */
const errorLoggingMiddleware = (err, req, res, next) => {
  try {
    // Extract relevant information
    const errorData = {
      statusCode: err.statusCode || res.statusCode || 500,
      method: req.method,
      endpoint: req.originalUrl || req.path,
      error: err.message || 'Unknown error',
      shopId: req.shop_id || req.body?.shop_id || req.query?.shop_id || null,
      userId: req.user?.id || req.user?.username || null,
      responseTime: req.responseTime || 0,
      ip: req.ip || req.connection.remoteAddress,
      userAgent: req.get('user-agent') || 'Unknown',
      stack: process.env.NODE_ENV === 'production' ? undefined : err.stack
    };

    // Log the error
    errorLogService.logApiError(errorData);

    // Pass to next error handler if defined
    next(err);
  } catch (loggingError) {
    console.error('Error in error logging middleware:', loggingError);
    next(err);
  }
};

/**
 * Response time tracking middleware
 * Should be used early in middleware stack to measure response time
 */
const responseTimeMiddleware = (req, res, next) => {
  const startTime = Date.now();
  
  // Override res.json and res.send to capture response time
  const originalJson = res.json;
  const originalSend = res.send;

  res.json = function(data) {
    req.responseTime = Date.now() - startTime;
    
    // Log errors in successful responses (errors returned in response body)
    if (data && data.success === false) {
      const errorData = {
        statusCode: res.statusCode || 200,
        method: req.method,
        endpoint: req.originalUrl || req.path,
        error: data.error || 'Unknown error in response',
        details: data.details,
        shopId: req.shop_id || req.body?.shop_id || req.query?.shop_id || null,
        userId: req.user?.id || req.user?.username || null,
        responseTime: req.responseTime,
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.get('user-agent') || 'Unknown'
      };

      errorLogService.logApiError(errorData);
    }

    return originalJson.call(this, data);
  };

  res.send = function(data) {
    req.responseTime = Date.now() - startTime;
    return originalSend.call(this, data);
  };

  next();
};

/**
 * 404 Not Found middleware
 * Logs when endpoints don't exist
 */
const notFoundMiddleware = (req, res) => {
  const errorData = {
    statusCode: 404,
    method: req.method,
    endpoint: req.originalUrl || req.path,
    error: 'Endpoint not found (404)',
    shopId: req.shop_id || req.body?.shop_id || req.query?.shop_id || null,
    userId: req.user?.id || req.user?.username || null,
    responseTime: req.responseTime || 0,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('user-agent') || 'Unknown'
  };

  errorLogService.logApiError(errorData);

  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.originalUrl
  });
};

module.exports = {
  errorLoggingMiddleware,
  responseTimeMiddleware,
  notFoundMiddleware
};
