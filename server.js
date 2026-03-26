require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const path = require("path");

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
app.use(express.json({ limit: "30mb" }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

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
app.use('/api/shop', shopManagementRouters);


/* ==================================
   ERROR HANDLER (LAST)
================================== */
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);

  applyCorsHeaders(req, res);

  res.status(500).json({
    message: err.message || "Internal Server Error"
  });
});

/* ==================================
   SERVER
================================== */
const PORT = process.env.PORT || 4402;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
