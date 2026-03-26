const { db } = require("../config/dbconnection");
const {
  getLocalMacAddress,
  getMacFromArp,
  getClientIp,
  formatMacAddress
} = require("../helpers/deviceAuthUtils");

/**
 * Get global or user-specific device authentication settings
 * @param {number} userId - Optional user ID for user-specific settings
 */
const getDeviceAuthSettings = async (userId = null) => {
  try {
    let query = "SELECT * FROM device_auth_settings WHERE user_id IS NULL";
    let params = [];

    if (userId) {
      query = "SELECT * FROM device_auth_settings WHERE user_id = ? OR user_id IS NULL ORDER BY user_id DESC LIMIT 1";
      params = [userId];
    }

    const [settings] = await db.query(query, params);
    return settings.length > 0 ? settings[0] : null;
  } catch (error) {
    console.error("getDeviceAuthSettings error:", error);
    return null;
  }
};

/**
 * Register a new device/MAC address for a user
 * POST /device/register
 */
const registerDevice = async (req, res) => {
  try {
    const { user_id, mac_address, device_name, device_type = 'desktop' } = req.body;

    // Validation
    if (!user_id || !mac_address) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: user_id, mac_address"
      });
    }

    // Validate MAC address format (XX:XX:XX:XX:XX:XX)
    const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
    if (!macRegex.test(mac_address)) {
      return res.status(400).json({
        success: false,
        message: "Invalid MAC address format. Use XX:XX:XX:XX:XX:XX"
      });
    }

    // Check if user exists
    const [userExists] = await db.query("SELECT id FROM users WHERE id = ?", [user_id]);
    if (userExists.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // Check if MAC is globally blocked
    const [blockedMac] = await db.query(
      "SELECT id FROM blocked_mac_addresses WHERE mac_address = ? AND status = 'active'",
      [mac_address]
    );
    if (blockedMac.length > 0) {
      return res.status(403).json({
        success: false,
        message: "This MAC address is globally blocked"
      });
    }

    // Get user's device authentication settings
    const settings = await getDeviceAuthSettings(user_id);
    
    // Check device limit
    if (settings && settings.max_devices_per_user > 0) {
      const [deviceCount] = await db.query(
        "SELECT COUNT(*) as count FROM user_devices WHERE user_id = ? AND status != 'blocked'",
        [user_id]
      );

      if (deviceCount[0].count >= settings.max_devices_per_user) {
        return res.status(409).json({
          success: false,
          message: `Maximum ${settings.max_devices_per_user} devices allowed per user`
        });
      }
    }

    // Check if device already registered
    const [existing] = await db.query(
      "SELECT id FROM user_devices WHERE user_id = ? AND mac_address = ?",
      [user_id, mac_address]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        success: false,
        message: "This MAC address is already registered for this user"
      });
    }

    // Register device
    const [result] = await db.query(
      "INSERT INTO user_devices (user_id, mac_address, device_name, device_type, status) VALUES (?, ?, ?, ?, 'active')",
      [user_id, mac_address, device_name || null, device_type]
    );

    res.status(201).json({
      success: true,
      message: "Device registered successfully",
      data: {
        id: result.insertId,
        user_id,
        mac_address,
        device_name,
        device_type,
        status: 'active',
        created_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("registerDevice error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to register device",
      error: error.message
    });
  }
};

/**
 * Get all devices registered for a user
 * GET /device/user/:user_id
 */
const getUserDevices = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "User ID is required"
      });
    }

    const [devices] = await db.query(
      "SELECT * FROM user_devices WHERE user_id = ? ORDER BY created_at DESC",
      [user_id]
    );

    res.json({
      success: true,
      count: devices.length,
      data: devices
    });
  } catch (error) {
    console.error("getUserDevices error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user devices",
      error: error.message
    });
  }
};

/**
 * Check if a MAC address is authorized for a user
 * POST /device/verify-mac
 */
const verifyMacAddress = async (req, res) => {
  try {
    const { user_id, mac_address } = req.body;

    if (!user_id || !mac_address) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: user_id, mac_address"
      });
    }

    // Get user's settings
    const settings = await getDeviceAuthSettings(user_id);

    // If MAC auth is disabled, return success
    if (!settings || !settings.enable_mac_auth) {
      return res.json({
        success: true,
        authorized: true,
        reason: "MAC authentication is disabled"
      });
    }

    // Check if MAC is globally blocked
    const [blockedMac] = await db.query(
      "SELECT reason FROM blocked_mac_addresses WHERE mac_address = ? AND status = 'active'",
      [mac_address]
    );

    if (blockedMac.length > 0) {
      return res.json({
        success: true,
        authorized: false,
        reason: "MAC address is globally blocked",
        block_reason: blockedMac[0].reason
      });
    }

    // Check if user has registered devices
    const [userDevices] = await db.query(
      "SELECT id, device_name, status FROM user_devices WHERE user_id = ? AND status IN ('active', 'inactive')",
      [user_id]
    );

    // If user has no devices registered
    if (userDevices.length === 0) {
      return res.json({
        success: true,
        authorized: false,
        reason: "No devices registered for this user"
      });
    }

    // Check if MAC matches any registered device
    const [authorizedMac] = await db.query(
      "SELECT id, device_name, status FROM user_devices WHERE user_id = ? AND mac_address = ?",
      [user_id, mac_address]
    );

    if (authorizedMac.length > 0) {
      const device = authorizedMac[0];
      
      // Check if device is blocked
      if (device.status === 'blocked') {
        return res.json({
          success: true,
          authorized: false,
          reason: "Device is blocked for this user",
          device_name: device.device_name
        });
      }

      // Update last login time
      await db.query(
        "UPDATE user_devices SET last_login_at = NOW() WHERE id = ?",
        [device.id]
      );

      return res.json({
        success: true,
        authorized: true,
        reason: "MAC address is authorized",
        device_name: device.device_name,
        device_id: device.id
      });
    } else {
      return res.json({
        success: true,
        authorized: false,
        reason: "MAC address is not registered for this user"
      });
    }
  } catch (error) {
    console.error("verifyMacAddress error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify MAC address",
      error: error.message
    });
  }
};

/**
 * Update device status (active/inactive/blocked)
 * PUT /device/:device_id
 */
const updateDeviceStatus = async (req, res) => {
  try {
    const { device_id } = req.params;
    const { status, device_name } = req.body;

    if (!device_id) {
      return res.status(400).json({
        success: false,
        message: "Device ID is required"
      });
    }

    // Validate status if provided
    if (status && !['active', 'inactive', 'blocked'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Status must be 'active', 'inactive', or 'blocked'"
      });
    }

    // Get current device
    const [device] = await db.query(
      "SELECT * FROM user_devices WHERE id = ?",
      [device_id]
    );

    if (device.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Device not found"
      });
    }

    // Update device
    const updates = {};
    if (status) updates.status = status;
    if (device_name) updates.device_name = device_name;

    const updateFields = Object.entries(updates)
      .map(([key]) => `${key} = ?`)
      .join(', ');
    const updateValues = Object.values(updates);

    if (updateFields) {
      await db.query(
        `UPDATE user_devices SET ${updateFields} WHERE id = ?`,
        [...updateValues, device_id]
      );
    }

    res.json({
      success: true,
      message: "Device updated successfully",
      data: {
        ...device[0],
        ...updates
      }
    });
  } catch (error) {
    console.error("updateDeviceStatus error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update device",
      error: error.message
    });
  }
};

/**
 * Delete a device
 * DELETE /device/:device_id
 */
const deleteDevice = async (req, res) => {
  try {
    const { device_id } = req.params;

    if (!device_id) {
      return res.status(400).json({
        success: false,
        message: "Device ID is required"
      });
    }

    // Check if device exists
    const [device] = await db.query(
      "SELECT * FROM user_devices WHERE id = ?",
      [device_id]
    );

    if (device.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Device not found"
      });
    }

    // Delete device
    await db.query("DELETE FROM user_devices WHERE id = ?", [device_id]);

    res.json({
      success: true,
      message: "Device deleted successfully"
    });
  } catch (error) {
    console.error("deleteDevice error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete device",
      error: error.message
    });
  }
};

/**
 * Get device authentication settings
 * GET /device/settings/:user_id or GET /device/settings/global
 */
const getSettings = async (req, res) => {
  try {
    const { user_id } = req.params;

    let settings;
    if (user_id && user_id !== 'global') {
      settings = await getDeviceAuthSettings(user_id);
    } else {
      settings = await getDeviceAuthSettings();
    }

    if (!settings) {
      return res.status(404).json({
        success: false,
        message: "Settings not found"
      });
    }

    res.json({
      success: true,
      data: settings
    });
  } catch (error) {
    console.error("getSettings error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch settings",
      error: error.message
    });
  }
};

/**
 * Update device authentication settings
 * PUT /device/settings/:user_id or PUT /device/settings/global
 */
const updateSettings = async (req, res) => {
  try {
    const { user_id } = req.params;
    const updates = req.body;

    let settingUserId = null;
    if (user_id && user_id !== 'global') {
      settingUserId = user_id;
      
      // Verify user exists
      const [userExists] = await db.query("SELECT id FROM users WHERE id = ?", [user_id]);
      if (userExists.length === 0) {
        return res.status(404).json({
          success: false,
          message: "User not found"
        });
      }
    }

    // Check if settings already exist
    const [existing] = await db.query(
      "SELECT id FROM device_auth_settings WHERE user_id " + (settingUserId ? "= ?" : "IS NULL"),
      settingUserId ? [settingUserId] : []
    );

    const updateFields = Object.entries(updates)
      .map(([key]) => `\`${key}\` = ?`)
      .join(', ');
    const updateValues = Object.values(updates);

    if (existing.length > 0) {
      // Update existing
      await db.query(
        `UPDATE device_auth_settings SET ${updateFields} WHERE user_id ` + (settingUserId ? "= ?" : "IS NULL"),
        [...updateValues, ...(settingUserId ? [settingUserId] : [])]
      );
    } else {
      // Insert new
      const fields = ['user_id', ...Object.keys(updates)];
      const placeholders = fields.map(() => '?').join(', ');
      const values = [settingUserId, ...updateValues];

      await db.query(
        `INSERT INTO device_auth_settings (${fields.join(', ')}) VALUES (${placeholders})`,
        values
      );
    }

    // Get updated settings
    const [updated] = await db.query(
      "SELECT * FROM device_auth_settings WHERE user_id " + (settingUserId ? "= ?" : "IS NULL"),
      settingUserId ? [settingUserId] : []
    );

    res.json({
      success: true,
      message: "Settings updated successfully",
      data: updated[0]
    });
  } catch (error) {
    console.error("updateSettings error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update settings",
      error: error.message
    });
  }
};

/**
 * Block a MAC address globally
 * POST /device/block-mac
 */
const blockMacAddress = async (req, res) => {
  try {
    const { mac_address, reason, blocked_by_user_id } = req.body;

    if (!mac_address) {
      return res.status(400).json({
        success: false,
        message: "MAC address is required"
      });
    }

    // Validate MAC format
    const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
    if (!macRegex.test(mac_address)) {
      return res.status(400).json({
        success: false,
        message: "Invalid MAC address format"
      });
    }

    // Check if already blocked
    const [existing] = await db.query(
      "SELECT id FROM blocked_mac_addresses WHERE mac_address = ?",
      [mac_address]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        success: false,
        message: "MAC address is already blocked"
      });
    }

    // Block the MAC
    const [result] = await db.query(
      "INSERT INTO blocked_mac_addresses (mac_address, reason, blocked_by_user_id, status) VALUES (?, ?, ?, 'active')",
      [mac_address, reason || null, blocked_by_user_id || null]
    );

    res.status(201).json({
      success: true,
      message: "MAC address blocked successfully",
      data: {
        id: result.insertId,
        mac_address,
        reason,
        status: 'active',
        created_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("blockMacAddress error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to block MAC address",
      error: error.message
    });
  }
};

/**
 * Get login attempt logs
 * GET /device/login-logs/:user_id or GET /device/login-logs
 */
const getLoginLogs = async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 50, status } = req.query;

    let query = "SELECT * FROM login_attempts WHERE 1=1";
    let params = [];

    if (user_id) {
      query += " AND user_id = ?";
      params.push(user_id);
    }

    if (status) {
      query += " AND status = ?";
      params.push(status);
    }

    query += " ORDER BY created_at DESC LIMIT ?";
    params.push(parseInt(limit));

    const [logs] = await db.query(query, params);

    res.json({
      success: true,
      count: logs.length,
      data: logs
    });
  } catch (error) {
    console.error("getLoginLogs error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch login logs",
      error: error.message
    });
  }
};

/**
 * Get machine MAC address
 * GET /device/machine-mac
 * Optional query: ?ip=192.168.1.100
 */
const getMachineMacAddress = async (req, res) => {
  try {
    const requestedIp = req.query.ip;
    const clientIp = getClientIp(req);
    const lookupIp = requestedIp || clientIp;

    let detectedMac = null;
    let source = null;

    if (lookupIp) {
      detectedMac = getMacFromArp(lookupIp);
      if (detectedMac) {
        source = "arp";
      }
    }

    if (!detectedMac) {
      detectedMac = getLocalMacAddress();
      if (detectedMac) {
        source = "server-local";
      }
    }

    const formattedMac = detectedMac ? formatMacAddress(detectedMac) : null;

    if (!formattedMac) {
      return res.status(404).json({
        success: false,
        message: "MAC address could not be detected",
        data: {
          ip: lookupIp || null,
          source: source || "none"
        }
      });
    }

    return res.json({
      success: true,
      message: "MAC address fetched successfully",
      data: {
        mac_address: formattedMac,
        ip: lookupIp || null,
        source
      }
    });
  } catch (error) {
    console.error("getMachineMacAddress error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to get machine MAC address",
      error: error.message
    });
  }
};

/**
 * Log a login attempt
 * Internal function called during login
 */
const logLoginAttempt = async (userId, username, macAddress, ipAddress, status, errorMessage, deviceName = null, userAgent = null) => {
  try {
    await db.query(
      "INSERT INTO login_attempts (user_id, username, mac_address, ip_address, device_name, status, error_message, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [userId || null, username, macAddress || null, ipAddress, deviceName || null, status, errorMessage || null, userAgent || null]
    );
  } catch (error) {
    console.error("logLoginAttempt error:", error);
  }
};

module.exports = {
  registerDevice,
  getUserDevices,
  verifyMacAddress,
  updateDeviceStatus,
  deleteDevice,
  getSettings,
  updateSettings,
  blockMacAddress,
  getLoginLogs,
  getMachineMacAddress,
  logLoginAttempt,
  getDeviceAuthSettings
};
