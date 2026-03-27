const { db } = require("../config/dbconnection");
const { getLocalMacAddress, getMacFromArp, formatMacAddress, normalizeMac } = require("../helpers/deviceAuthUtils");
const jwt = require('jsonwebtoken');

const resolveShopId = (req) => {
  const candidate = req.query?.shop_id || req.user?.shop_id || req.shop_id;
  const parsed = Number.parseInt(candidate, 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : null;
};

/**
 * Get all users with UUID for machine selection (shop-scoped)
 * GET /printer/users-with-uuid
 */
const getUsersWithUuid = async (req, res) => {
  try {
    const shopId = resolveShopId(req);

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    const [users] = await db.query(
      "SELECT id, name, uname, user_uuid FROM users WHERE user_uuid IS NOT NULL AND status = 1 AND shop_id = ? ORDER BY name ASC",
      [shopId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No machines registered yet for this shop. Please login to generate UUID."
      });
    }

    res.json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error("getUsersWithUuid error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch users with UUID",
      error: error.message
    });
  }
};

/**
 * Save new printer configuration
 * POST /printer/config
 * Body: { terminal_id, machine_uuid, location, printer_ip, printer_port, printer_name }
 */
const savePrinterConfig = async (req, res) => {
  try {
    const { terminal_id, machine_uuid, location, printer_ip, printer_port = 9100, printer_name } = req.body;
    const shopId = resolveShopId(req);

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id for printer configuration"
      });
    }

    // Validation
    if (!terminal_id || !location || !printer_ip) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: terminal_id, location, printer_ip"
      });
    }

    if (!["kitchen", "cashier"].includes(location)) {
      return res.status(400).json({
        success: false,
        message: "Location must be either 'kitchen' or 'cashier'"
      });
    }

    // Validate IP format (basic validation)
    const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (!ipRegex.test(printer_ip)) {
      return res.status(400).json({
        success: false,
        message: "Invalid printer IP format"
      });
    }

    // Validate machine_uuid if provided (UUID format)
    if (machine_uuid) {
      // Check if UUID exists in users table
      const [userCheck] = await db.query(
        "SELECT id, name, uname FROM users WHERE user_uuid = ?",
        [machine_uuid]
      );
      
      if (userCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: "MACHINE NOT REGISTERED yet. UUID not found in users table."
        });
      }
    }

    // Check if terminal_id already exists for this shop
    const [existing] = await db.query(
      "SELECT id FROM printer_config WHERE terminal_id = ? AND shop_id = ?",
      [terminal_id, shopId]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        success: false,
        message: `Terminal ID '${terminal_id}' already configured for this shop`
      });
    }

    // Insert new printer configuration
    const [result] = await db.query(
      "INSERT INTO printer_config (shop_id, terminal_id, machine_uuid, location, printer_ip, printer_port, printer_name, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'active')",
      [shopId, terminal_id, machine_uuid || null, location, printer_ip, printer_port, printer_name || null]
    );

    res.status(201).json({
      success: true,
      message: "Printer configuration saved successfully",
      data: {
        id: result.insertId,
        terminal_id,
        machine_uuid,
        location,
        printer_ip,
        printer_port,
        printer_name,
        status: "active",
        created_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("savePrinterConfig error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to save printer configuration",
      error: error.message
    });
  }
};

/**
 * Get printer details by terminal_id
 * GET /printer/config/:terminal_id
 */
const getPrinterDetails = async (req, res) => {
  try {
    const { terminal_id } = req.params;
    const shopId = resolveShopId(req);

    if (!terminal_id) {
      return res.status(400).json({
        success: false,
        message: "Terminal ID is required"
      });
    }

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    const [rows] = await db.query(
      "SELECT * FROM printer_config WHERE terminal_id = ? AND shop_id = ?",
      [terminal_id, shopId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No printer configuration found for terminal ID: ${terminal_id}`
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error("getPrinterDetails error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch printer details",
      error: error.message
    });
  }
};

/**
 * Get all printers by location (kitchen or cashier)
 * GET /printer/config/location/:location
 */
const getPrintersByLocation = async (req, res) => {
  try {
    const { location } = req.params;
    const shopId = resolveShopId(req);

    if (!location || !["kitchen", "cashier"].includes(location)) {
      return res.status(400).json({
        success: false,
        message: "Location must be either 'kitchen' or 'cashier'"
      });
    }

    if (!shopId) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: []
      });
    }

    const [rows] = await db.query(
      "SELECT * FROM printer_config WHERE shop_id = ? AND location = ? AND status = 'active' ORDER BY created_at DESC",
      [shopId, location]
    );

    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (error) {
    console.error("getPrintersByLocation error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch printers by location",
      error: error.message
    });
  }
};

/**
 * Get all active printer configurations
 * GET /printer/config
 */
const getAllPrinterConfigs = async (req, res) => {
  try {
    const shopId = resolveShopId(req);
    if (!shopId) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: []
      });
    }

    const [rows] = await db.query(
      "SELECT * FROM printer_config WHERE shop_id = ? AND status = 'active' ORDER BY location, created_at DESC",
      [shopId]
    );

    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (error) {
    console.error("getAllPrinterConfigs error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch printer configurations",
      error: error.message
    });
  }
};

/**
 * Update printer configuration
 * PUT /printer/config/:terminal_id
 * Body: { machine_uuid, printer_ip, printer_port, printer_name, status }
 */
const updatePrinterDetails = async (req, res) => {
  try {
    const { terminal_id } = req.params;
    const { machine_uuid, printer_ip, printer_port, printer_name, status } = req.body;
    const shopId = resolveShopId(req);

    if (!terminal_id) {
      return res.status(400).json({
        success: false,
        message: "Terminal ID is required"
      });
    }

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    // Get current configuration
    const [existing] = await db.query(
      "SELECT * FROM printer_config WHERE terminal_id = ? AND shop_id = ?",
      [terminal_id, shopId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No printer configuration found for terminal ID: ${terminal_id}`
      });
    }

    // Prepare update values
    const updateValues = {
      machine_uuid: machine_uuid !== undefined ? machine_uuid : existing[0].machine_uuid,
      printer_ip: printer_ip || existing[0].printer_ip,
      printer_port: printer_port || existing[0].printer_port,
      printer_name: printer_name !== undefined ? printer_name : existing[0].printer_name,
      status: status || existing[0].status
    };

    // Validate IP if provided
    if (printer_ip) {
      const ipRegex = /^(\d{1,3}\.){3}\d{1,3}$/;
      if (!ipRegex.test(printer_ip)) {
        return res.status(400).json({
          success: false,
          message: "Invalid printer IP format"
        });
      }
    }

    // Validate machine_uuid if provided
    if (machine_uuid) {
      // Check if UUID exists in users table
      const [userCheck] = await db.query(
        "SELECT id, name, uname FROM users WHERE user_uuid = ?",
        [machine_uuid]
      );
      
      if (userCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: "MACHINE NOT REGISTERED yet. UUID not found in users table."
        });
      }
    }

    // Validate status if provided
    if (status && !["active", "inactive"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Status must be either 'active' or 'inactive'"
      });
    }

    // Update the configuration
    await db.query(
      "UPDATE printer_config SET machine_uuid = ?, printer_ip = ?, printer_port = ?, printer_name = ?, status = ? WHERE terminal_id = ? AND shop_id = ?",
      [updateValues.machine_uuid, updateValues.printer_ip, updateValues.printer_port, updateValues.printer_name, updateValues.status, terminal_id, shopId]
    );

    res.json({
      success: true,
      message: "Printer configuration updated successfully",
      data: {
        ...existing[0],
        ...updateValues,
        updated_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("updatePrinterDetails error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update printer configuration",
      error: error.message
    });
  }
};

/**
 * Delete printer configuration
 * DELETE /printer/config/:terminal_id
 */
const deletePrinterConfig = async (req, res) => {
  try {
    const { terminal_id } = req.params;
    const shopId = resolveShopId(req);

    if (!terminal_id) {
      return res.status(400).json({
        success: false,
        message: "Terminal ID is required"
      });
    }

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    // Check if exists
    const [existing] = await db.query(
      "SELECT id FROM printer_config WHERE terminal_id = ? AND shop_id = ?",
      [terminal_id, shopId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No printer configuration found for terminal ID: ${terminal_id}`
      });
    }

    // Delete configuration
    await db.query(
      "DELETE FROM printer_config WHERE terminal_id = ? AND shop_id = ?",
      [terminal_id, shopId]
    );

    res.json({
      success: true,
      message: `Printer configuration for terminal '${terminal_id}' deleted successfully`
    });
  } catch (error) {
    console.error("deletePrinterConfig error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete printer configuration",
      error: error.message
    });
  }
};

/**
 * Get printer configuration by machine UUID
 * GET /printer/config/uuid/:machine_uuid
 * Used for auto-detection of printer settings
 */
const getPrinterByMachineUuid = async (req, res) => {
  try {
    const { machine_uuid } = req.params;
    const shopId = resolveShopId(req);

    if (!machine_uuid) {
      return res.status(400).json({
        success: false,
        message: "Machine UUID is required"
      });
    }

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    const [rows] = await db.query(
      "SELECT * FROM printer_config WHERE machine_uuid = ? AND shop_id = ? AND status = 'active'",
      [machine_uuid, shopId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No active printer configuration found for machine UUID: ${machine_uuid}`
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error("getPrinterByMachineUuid error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch printer configuration by machine UUID",
      error: error.message
    });
  }
};

/**
 * Auto-detect machine and get applicable printer configuration
 * GET /printer/detect - Query params: ?type=kitchen|cashier (optional)
 * Used by local agent to get printer details for ESC/POS printing
 */
const detectAndGetPrinterConfig = async (req, res) => {
  try {
    const { type } = req.query; // 'kitchen' or 'cashier'
    const shopId = resolveShopId(req);

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    // Get client IP address
    const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() ||
                     req.connection.remoteAddress ||
                     req.socket.remoteAddress ||
                     req.ip ||
                     '127.0.0.1';

    console.log(`🔍 Detecting printer for IP: ${clientIp}, Type: ${type || 'any'}`);

    // Try to get MAC from ARP
    let detectedMac = null;
    try {
      detectedMac = getMacFromArp(clientIp);
      if (detectedMac) {
        detectedMac = formatMacAddress(detectedMac);
        console.log(`📍 Detected MAC: ${detectedMac}`);
      }
    } catch (err) {
      console.log(`⚠️  MAC detection via ARP failed: ${err.message}`);
    }

    let query = "SELECT * FROM printer_config WHERE shop_id = ? AND status = 'active'";
    let params = [shopId];

    // If MAC detected, try MAC-based lookup first (highest priority)
    if (detectedMac) {
      const [macMatches] = await db.query(
        "SELECT * FROM printer_config WHERE mac_address = ? AND shop_id = ? AND status = 'active'",
        [detectedMac, shopId]
      );

      if (macMatches.length > 0) {
        let result = macMatches[0];
        
        // If type filter is specified, check if it matches
        if (type && result.location !== type) {
          return res.status(400).json({
            success: false,
            message: `This machine is configured for '${result.location}' printer, but requested type is '${type}'`,
            data: {
              detected_mac: detectedMac,
              detected_location: result.location,
              requested_type: type
            }
          });
        }

        console.log(`✅ Printer found by MAC: ${result.terminal_id}`);
        return res.json({
          success: true,
          message: "Printer detected successfully (matched by MAC address)",
          data: {
            id: result.id,
            terminal_id: result.terminal_id,
            mac_address: result.mac_address,
            location: result.location,
            printer_ip: result.printer_ip,
            printer_port: result.printer_port,
            printer_name: result.printer_name,
            detection_method: 'mac_address',
            client_ip: clientIp,
            client_mac: detectedMac
          }
        });
      }
    }

    // Fallback: Get printer by location/type
    if (type && ['kitchen', 'cashier'].includes(type)) {
      const [typeMatches] = await db.query(
        "SELECT * FROM printer_config WHERE location = ? AND shop_id = ? AND status = 'active' LIMIT 1",
        [type, shopId]
      );

      if (typeMatches.length > 0) {
        let result = typeMatches[0];
        console.log(`✅ Printer found by location: ${result.terminal_id}`);
        return res.json({
          success: true,
          message: "Printer detected by location type (no MAC match found)",
          data: {
            id: result.id,
            terminal_id: result.terminal_id,
            mac_address: result.mac_address,
            location: result.location,
            printer_ip: result.printer_ip,
            printer_port: result.printer_port,
            printer_name: result.printer_name,
            detection_method: 'location_type',
            client_ip: clientIp,
            client_mac: detectedMac || null,
            warning: 'No MAC match found. Using default printer for location.'
          }
        });
      }

      return res.status(404).json({
        success: false,
        message: `No active printer configured for location: ${type}`,
        data: {
          client_ip: clientIp,
          client_mac: detectedMac || null,
          requested_type: type
        }
      });
    }

    // No specific type requested - get first available printer
    const [allPrinters] = await db.query(
      "SELECT * FROM printer_config WHERE shop_id = ? AND status = 'active' LIMIT 1",
      [shopId]
    );

    if (allPrinters.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No active printer configuration found in database",
        data: {
          client_ip: clientIp,
          client_mac: detectedMac || null
        }
      });
    }

    let result = allPrinters[0];
    console.log(`✅ Default printer selected: ${result.terminal_id}`);
    return res.json({
      success: true,
      message: "Default printer returned (no type specified)",
      data: {
        id: result.id,
        terminal_id: result.terminal_id,
        mac_address: result.mac_address,
        location: result.location,
        printer_ip: result.printer_ip,
        printer_port: result.printer_port,
        printer_name: result.printer_name,
        detection_method: 'default',
        client_ip: clientIp,
        client_mac: detectedMac || null
      }
    });

  } catch (error) {
    console.error("detectAndGetPrinterConfig error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to detect and get printer configuration",
      error: error.message
    });
  }
};

/**
 * Get printer for local agent with detailed detection info
 * GET /printer/agent/detect - Used by local printing agent
 */
const getAgentPrinterConfig = async (req, res) => {
  try {
    const { type, mac_address } = req.query;
    const shopId = resolveShopId(req);

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: "Unable to resolve shop_id"
      });
    }

    console.log(`🤖 Agent requesting printer - Type: ${type}, MAC: ${mac_address}`);

    // If MAC provided directly, use it
    if (mac_address) {
      const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
      if (!macRegex.test(mac_address)) {
        return res.status(400).json({
          success: false,
          message: "Invalid MAC address format",
          data: { provided_mac: mac_address }
        });
      }

      const [printers] = await db.query(
        "SELECT * FROM printer_config WHERE mac_address = ? AND shop_id = ? AND status = 'active'",
        [mac_address, shopId]
      );

      if (printers.length === 0) {
        return res.status(404).json({
          success: false,
          message: `No printer configured for MAC: ${mac_address}`,
          data: { mac_address }
        });
      }

      const printer = printers[0];
      console.log(`✅ Agent found printer: ${printer.terminal_id}`);
      return res.json({
        success: true,
        message: "Printer configuration found",
        data: {
          printer_id: printer.id,
          terminal_id: printer.terminal_id,
          location: printer.location,
          printer_ip: printer.printer_ip,
          printer_port: printer.printer_port,
          printer_name: printer.printer_name,
          mac_address: printer.mac_address,
          status: printer.status
        }
      });
    }

    // Otherwise, get by type/location
    if (!type || !['kitchen', 'cashier'].includes(type)) {
      return res.status(400).json({
        success: false,
        message: "Printer type (kitchen/cashier) is required when MAC address not provided"
      });
    }

    const [printers] = await db.query(
      "SELECT * FROM printer_config WHERE location = ? AND shop_id = ? AND status = 'active'",
      [type, shopId]
    );

    if (printers.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No active printer configured for: ${type}`,
        data: { type }
      });
    }

    // Return all matching printers for the location
    const formattedPrinters = printers.map(p => ({
      printer_id: p.id,
      terminal_id: p.terminal_id,
      location: p.location,
      printer_ip: p.printer_ip,
      printer_port: p.printer_port,
      printer_name: p.printer_name,
      mac_address: p.mac_address,
      status: p.status
    }));

    console.log(`✅ Agent found ${printers.length} printer(s) for ${type}`);
    return res.json({
      success: true,
      message: `Found ${printers.length} printer(s) for ${type}`,
      count: printers.length,
      data: formattedPrinters
    });

  } catch (error) {
    console.error("getAgentPrinterConfig error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get printer configuration for agent",
      error: error.message
    });
  }
};

module.exports = {
  getUsersWithUuid,
  savePrinterConfig,
  getPrinterDetails,
  getPrintersByLocation,
  getAllPrinterConfigs,
  updatePrinterDetails,
  deletePrinterConfig,
  getPrinterByMachineUuid,
  detectAndGetPrinterConfig,
  getAgentPrinterConfig
};
