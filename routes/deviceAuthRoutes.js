const express = require("express");
const router = express.Router();
const deviceAuthController = require("../controllers/deviceAuthController");

/**
 * Device & MAC Address Authentication Routes
 * Base URL: /api/device
 */

// Register a new device/MAC address for a user
router.post("/register", deviceAuthController.registerDevice);

// Verify if a MAC address is authorized for a user
router.post("/verify-mac", deviceAuthController.verifyMacAddress);

// Get machine MAC address (from ARP/client IP or server NIC)
router.get("/machine-mac", deviceAuthController.getMachineMacAddress);

// Get all devices for a user
router.get("/user/:user_id", deviceAuthController.getUserDevices);

// Update device status or name
router.put("/:device_id", deviceAuthController.updateDeviceStatus);

// Delete a device
router.delete("/:device_id", deviceAuthController.deleteDevice);

// Get device authentication settings (global or user-specific)
router.get("/settings/:user_id", deviceAuthController.getSettings);

// Update device authentication settings
router.put("/settings/:user_id", deviceAuthController.updateSettings);

// Block a MAC address globally
router.post("/block-mac", deviceAuthController.blockMacAddress);

// Get login attempt logs
router.get("/logs/:user_id", deviceAuthController.getLoginLogs);
router.get("/logs", deviceAuthController.getLoginLogs);

module.exports = router;
