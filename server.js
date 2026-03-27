require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const path = require("path");
const http = require("http");
const fileUpload = require("express-fileupload");

const userRouters = require("./routes/userRoutes");
const dashboardRouters = require("./routes/dashboardRoutes");
const printRouters = require("./routes/printRoutes");
const printerConfigRouters = require("./routes/printerConfigRoutes");
const deviceAuthRouters = require("./routes/deviceAuthRoutes");
const cloudAgentRouters = require("./routes/cloudAgentRoutes");
const analyticsRouters = require("./routes/analyticsRoutes");
const accountsRouters = require("./routes/accountsRoutes");
const kioskRouters = require("./routes/kioskRoutes");
const scbRouters = require('./routes/scbRoutes.js');
const stockRouters = require('./routes/stockRoutes.js');
const purchaseRouters = require('./routes/purchaseRoutes.js');
const superAdminRouters = require('./routes/superAdminRoutes.js');
const shopManagementRouters = require('./routes/shopManagementRoutes.js');
const errorLogsRouters = require('./routes/errorLogsRoutes.js');
const notificationsRouters = require('./routes/notificationsRoutes.js');
const logsRouters = require('./routes/logsRoutes.js');

// ===== ERROR LOGGING MIDDLEWARE =====
const { responseTimeMiddleware, errorLoggingMiddleware, notFoundMiddleware } = require('./middleware/errorLoggingMiddleware');

// ===== WEBSOCKET MANAGER =====
const websocketManager = require('./helpers/websocketManager');

require("./config/dbconnection");

const app = express();

const isAllowedOrigin = (origin) => {
  return typeof origin === "string" && origin.length > 0;
};

const applyCorsHeaders = (req, res) => {
  const origin = req.headers.origin;

  if (isAllowedOrigin(origin)) {
    res.header("Access-Control-Allow-Origin", origin);
    res.header("Vary", "Origin");
  }

  res.header("Access-Control-Allow-Credentials", "true");
  res.header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  );
};

const corsOptionsDelegate = (req, callback) => {
  const origin = req.headers.origin;

  callback(null, {
    origin: isAllowedOrigin(origin),
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Origin", "X-Requested-With", "Content-Type", "Accept", "Authorization"],
    optionsSuccessStatus: 204
  });
};

/* ==================================
   CORS
================================== */
app.use((req, res, next) => {
  applyCorsHeaders(req, res);
  next();
});
app.use(cors(corsOptionsDelegate));
app.options("*", cors(corsOptionsDelegate));

/* ==================================
   MIDDLEWARES
================================== */
const isMultipartRequest = (req) => {
  const contentType = (req.headers['content-type'] || '').toLowerCase();
  return contentType.includes('multipart/form-data');
};

app.use((req, res, next) => {
  if (isMultipartRequest(req)) {
    return next();
  }
  return express.json({ limit: "30mb" })(req, res, next);
});

app.use((req, res, next) => {
  if (isMultipartRequest(req)) {
    return next();
  }
  return bodyParser.urlencoded({ limit: "30mb", extended: true })(req, res, next);
});

// Skip express-fileUpload for multer routes (/addnewproduct)
app.use((req, res, next) => {
  if (isMultipartRequest(req) && req.path.includes('/addnewproduct')) {
    return next();
  }
  return fileUpload({ limits: { fileSize: 30 * 1024 * 1024 } })(req, res, next);
});

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ===== ERROR HANDLER FOR REQUEST STREAM ERRORS =====
app.use((req, res, next) => {
  req.on('error', (err) => {
    console.error('Request stream error:', err);
    if (!res.headersSent) {
      res.status(400).json({ 
        message: 'Request error: ' + err.message,
        error: 'Stream aborted or incomplete data'
      });
    }
  });
  next();
});

// ===== RESPONSE TIME TRACKING MIDDLEWARE (EARLY) =====
app.use(responseTimeMiddleware);

// ===== TENANT MIDDLEWARE FOR MULTI-TENANT SUPPORT =====
const { tenantMiddleware } = require('./middleware/tenantMiddleware');
app.use(tenantMiddleware);

/* ==================================
   ROUTES
================================== */
app.use("/api", userRouters);
app.use("/api", printRouters);
app.use("/api/printer", printerConfigRouters);
app.use("/api/device", deviceAuthRouters);
app.use("/api/cloud-agent", cloudAgentRouters);
app.use("/api", dashboardRouters);
app.use("/api/analytics", analyticsRouters);
app.use("/api/accounts", accountsRouters);
app.use("/api/kiosk", kioskRouters);
app.use("/kiosk", kioskRouters);
app.use('/api/scb', scbRouters);
app.use('/kiosk/scb', scbRouters);
app.use('/api/stock', stockRouters);
app.use('/api/purchase', purchaseRouters);

// ===== NEW SAAS ROUTES =====
app.use('/api/super-admin', superAdminRouters);
app.use('/api/super-admin', errorLogsRouters);
app.use('/api/super-admin/notifications', notificationsRouters);
app.use('/api/notifications', notificationsRouters);
app.use('/api/shop', shopManagementRouters);
app.use('/api/super-admin', logsRouters);


/* ==================================
   404 & ERROR LOGGING HANDLERS
================================== */
// Error logging middleware catches errors in responses
app.use(errorLoggingMiddleware);

// 404 handler (must be after all routes)
app.use(notFoundMiddleware);


/* ==================================
   GLOBAL ERROR HANDLER (LAST)
================================== */
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);

  applyCorsHeaders(req, res);

  // Handle multer errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      message: 'File too large. Maximum size is 50MB'
    });
  }

  if (err.code === 'LIMIT_FILE_COUNT') {
    return res.status(400).json({
      message: 'Too many files. Maximum 5 files allowed'
    });
  }

  if (err.message && err.message.includes('Unexpected end of form')) {
    return res.status(400).json({
      message: 'Invalid form data: ' + err.message,
      hint: 'Ensure all files are uploaded correctly and request body is complete'
    });
  }

  res.status(err.status || 500).json({
    message: err.message || "Internal Server Error"
  });
});

/* ==================================
   UNHANDLED ERROR HANDLERS
================================== */
// Handle unhandled Promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Log to error logging service if available
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  // Optionally restart the process or log to error tracking service
});

/* ==================================
   SERVER
================================== */
const PORT = process.env.PORT || 4402;

// Create HTTP server
const server = http.createServer(app);

// Initialize WebSocket manager
websocketManager.initialize(server, {
  perMessageDeflate: false,
  backpressureLimit: 100 * 1024 * 1024 // 100MB
});

// Start server
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`WebSocket available at ws://localhost:${PORT}/ws`);
  
  // Log server stats every 30 seconds
  setInterval(() => {
    const stats = websocketManager.getStats();
    if (stats.totalConnections > 0) {
      console.log(`[WebSocket Stats] Users: ${stats.totalUsers}, Shops: ${stats.totalShops}, Connections: ${stats.totalConnections}`);
    }
  }, 30000);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down gracefully...');
  websocketManager.close();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

