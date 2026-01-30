require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");

const userRouters = require("./routes/userRoutes");
const dashboardRouters = require("./routes/dashboardRoutes");
const printRouters = require("./routes/printRoutes");
const analyticsRouters = require("./routes/analyticsRoutes");
const kioskRouters = require("./routes/kioskRoutes");
const scbRouters = require('./routes/scbRoutes.js');
const stockRouters = require('./routes/stockRoutes.js');
const purchaseRouters = require('./routes/purchaseRoutes.js');

require("./config/dbconnection");

const app = express();

/* ==================================
   🔥 FORCE CORS HEADERS (CRITICAL)
================================== */
app.use((req, res, next) => {
  const allowedOrigins = [
    "https://balibeachclub.livecloudnet.com",
    "http://localhost:3000",
    "https://localhost:3000"
  ];

  const origin = req.headers.origin;
  if (origin && allowedOrigins.includes(origin)) {
    res.header("Access-Control-Allow-Origin", origin);
  }

  res.header("Access-Control-Allow-Credentials", "true");
  res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  );

  // 🔥 Handle preflight HERE
  if (req.method === "OPTIONS") {
    return res.sendStatus(204);
  }

  next();
});

/* ==================================
   MIDDLEWARES
================================== */
app.use(express.json({ limit: "30mb" }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

/* ==================================
   ROUTES
================================== */
app.use("/api", userRouters);
app.use("/api", printRouters);
app.use("/api", dashboardRouters);
app.use("/api/analytics", analyticsRouters);
app.use("/api/kiosk", kioskRouters);
app.use("/kiosk", kioskRouters);
app.use('/api/scb', scbRouters);
app.use('/kiosk/scb', scbRouters);
app.use('/api/stock', stockRouters);
app.use('/api/purchase', purchaseRouters);


/* ==================================
   ERROR HANDLER (LAST)
================================== */
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);

  // 🔥 ENSURE CORS HEADERS EVEN ON ERROR
  res.header("Access-Control-Allow-Origin", "https://balibeachclub.livecloudnet.com");
  res.header("Access-Control-Allow-Credentials", "true");

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
