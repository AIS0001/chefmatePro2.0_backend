const express = require("express");
const router = express.Router();
const printerConfigController = require("../controllers/printerConfigController");

/**
 * Printer Configuration Routes
 * Base URL: /printer
 */

// Get all users with UUID (for dropdown selection)
router.get("/users-with-uuid", printerConfigController.getUsersWithUuid);

// Save new printer configuration
router.post("/config", printerConfigController.savePrinterConfig);

// Get all active printer configurations
router.get("/config", printerConfigController.getAllPrinterConfigs);

// Get printer configuration by machine UUID (for auto-detection) - MUST come before :terminal_id route
router.get("/config/uuid/:machine_uuid", printerConfigController.getPrinterByMachineUuid);

// Get printer details by terminal_id
router.get("/config/:terminal_id", printerConfigController.getPrinterDetails);

// Get all printers by location (kitchen or cashier)
router.get("/location/:location", printerConfigController.getPrintersByLocation);

// Auto-detect machine and get printer configuration
router.get("/detect", printerConfigController.detectAndGetPrinterConfig);

// Get printer for local agent (with MAC or type)
router.get("/agent/detect", printerConfigController.getAgentPrinterConfig);

// Update printer configuration
router.put("/config/:terminal_id", printerConfigController.updatePrinterDetails);

// Delete printer configuration
router.delete("/config/:terminal_id", printerConfigController.deletePrinterConfig);

module.exports = router;
