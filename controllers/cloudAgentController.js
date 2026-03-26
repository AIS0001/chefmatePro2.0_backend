const ioClient = require("socket.io-client");
const { db } = require("../config/dbconnection");

let socket;

const getSocket = () => {
  if (socket) {
    return socket;
  }

  const url = process.env.LOCAL_AGENT_URL || "http://localhost:5010";
  socket = ioClient(url, {
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 1000
  });

  socket.on("connect_error", (err) => {
    console.error("Local agent socket error:", err.message);
  });

  return socket;
};

const ensureConnected = (socketClient) => {
  if (socketClient.connected) {
    return Promise.resolve(true);
  }

  socketClient.connect();

  return new Promise((resolve, reject) => {
    const timeoutId = setTimeout(() => {
      reject(new Error("Local agent connection timeout"));
    }, 5000);

    socketClient.once("connect", () => {
      clearTimeout(timeoutId);
      resolve(true);
    });

    socketClient.once("connect_error", (err) => {
      clearTimeout(timeoutId);
      reject(err);
    });
  });
};

const sendPrintJobPayload = async (payload) => {
  const socketClient = getSocket();

  await ensureConnected(socketClient);

  return new Promise((resolve, reject) => {
    const timeoutId = setTimeout(() => {
      reject(new Error("Local agent timeout"));
    }, 5000);

    socketClient.emit("print", payload, (ack) => {
      clearTimeout(timeoutId);
      resolve(ack || { success: true });
    });
  });
};

const buildSamplePayload = (jobIdPrefix, overrides = {}) => {
  return {
    jobId: `${jobIdPrefix}-${Date.now()}`,
    table: "Test",
    items: [
      { name: "Test Item A", quantity: 1, price: 10 },
      { name: "Test Item B", quantity: 2, price: 20 }
    ],
    total: 50,
    ...overrides
  };
};

const fetchCompanyName = async () => {
  let companyName = "Restaurant Name";
  try {
    const [companyRows] = await db.query(
      `SELECT name FROM companyinfo ORDER BY id DESC LIMIT 1`
    );
    if (companyRows && companyRows.length > 0) {
      companyName = companyRows[0].name;
    }
  } catch (dbErr) {
    console.error("Failed to fetch company name:", dbErr.message);
  }

  return companyName;
};

const fetchCompanyInfo = async () => {
  try {
    const [rows] = await db.query(
      `SELECT name, tax_id, phone_number, address
       FROM companyinfo
       ORDER BY id DESC
       LIMIT 1`
    );

    if (rows && rows.length > 0) {
      return rows[0];
    }
  } catch (dbErr) {
    console.error("Failed to fetch company info:", dbErr.message);
  }

  return {
    name: "Restaurant Name",
    tax_id: "",
    phone_number: "",
    address: ""
  };
};

const fetchBillItems = async (billId) => {
  try {
    const [rows] = await db.query(
      `SELECT item_name, quantity, total_price
       FROM order_items
       WHERE bill_id = ?`,
      [billId]
    );
    return rows;
  } catch (error) {
    if (!String(error.message || "").toLowerCase().includes("unknown column")) {
      throw error;
    }
  }

  const [fallbackRows] = await db.query(
    `SELECT item_name, quantity, total_price
     FROM order_items
     WHERE invoice_number = ?`,
    [String(billId)]
  );

  return fallbackRows;
};

const normalizeGroup = (value) => {
  return String(value || "").trim().toLowerCase();
};

const resolveGroup = (item) => {
  const raw =
    item.item_group ??
    item.itemGroup ??
    item.group ??
    item.category ??
    item.item_type ??
    item.itemType ??
    item.item_type_id ??
    item.itemTypeId ??
    item.type;

  const normalized = normalizeGroup(raw);
  if (!normalized) {
    return "";
  }

  if (["food", "foods", "food items", "fooditems", "1"].includes(normalized)) {
    return "food";
  }

  if (
    [
      "bar",
      "beverage",
      "beverages",
      "drink",
      "drinks",
      "liquor",
      "liquors",
      "bar items",
      "baritems",
      "2"
    ].includes(normalized)
  ) {
    return "bar";
  }

  if (["shisha", "hookah", "3"].includes(normalized)) {
    return "shisha";
  }

  return "";
};

const groupItemsByGroup = (items) => {
  const groups = {
    food: [],
    bar: [],
    shisha: []
  };

  items.forEach((item) => {
    const group = resolveGroup(item);
    if (groups[group]) {
      groups[group].push(item);
    }
  });

  return groups;
};

const sendPrintJob = async (req, res) => {
  const payload = req.body || {};

  if (!payload || !payload.jobId) {
    return res.status(400).json({
      success: false,
      message: "jobId is required"
    });
  }

  try {
    const result = await sendPrintJobPayload(payload);

    return res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error("Local agent print error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver print job"
    });
  }
};

const sendKotToBoth = async (req, res) => {
  const payload = req.body || {};
  const jobId = payload.jobId || `kot-${Date.now()}`;

  if (!payload.table || !Array.isArray(payload.items) || payload.items.length === 0) {
    return res.status(400).json({
      success: false,
      message: "table and items are required"
    });
  }

  try {
    // DEBUG: Log full payload structure
    console.log("\n=== FULL PAYLOAD ===");
    console.log(JSON.stringify(payload, null, 2));
    console.log("\n=== INDIVIDUAL ITEMS ===");
    payload.items.forEach((item, idx) => {
      console.log(`Item ${idx}:`, JSON.stringify(item, null, 2));
    });

    const companyName = await fetchCompanyName();
    console.log("Fetched company name from DB:", companyName);

    const grouped = groupItemsByGroup(payload.items);
    const groupCounts = Object.fromEntries(
      Object.entries(grouped).map(([groupName, items]) => [groupName, items.length])
    );
    console.log("KOT group counts:", groupCounts);
    const groupsToPrint = Object.entries(grouped).filter(([, items]) => items.length > 0);

    if (groupsToPrint.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No items found for food/bar/shisha groups"
      });
    }

    // Determine target printer(s) based on item group
    const getPrinterTargets = (groupName) => {
      if (groupName === "food") {
        return ["kitchen", "cashier"]; // Food goes to BOTH printers
      } else if (groupName === "bar" || groupName === "shisha") {
        return ["cashier"]; // Bar and Shisha go to cashier printer only
      }
      return ["kitchen"]; // Default to kitchen
    };

    // ✅ Function to get printer config from database based on location
    const getPrinterByLocation = async (location) => {
      try {
        const [printers] = await db.query(
          "SELECT * FROM printer_config WHERE location = ? AND status = 'active' LIMIT 1",
          [location]
        );
        
        if (printers.length > 0) {
          const printer = printers[0];
          console.log(`✅ Printer found for ${location}: ${printer.terminal_id} (${printer.printer_ip}:${printer.printer_port})`);
          return {
            printer_ip: printer.printer_ip,
            printer_port: printer.printer_port,
            terminal_id: printer.terminal_id,
            mac_address: printer.mac_address
          };
        } else {
          console.warn(`⚠️  No printer configured for location: ${location}`);
          return null;
        }
      } catch (err) {
        console.error(`Error fetching printer for ${location}:`, err);
        return null;
      }
    };

    const results = await Promise.all(
      groupsToPrint.flatMap(([groupName, items]) => {
        const heading = `${groupName.toUpperCase()} KOT`;
        const targets = getPrinterTargets(groupName);

        return targets.map(async (target) => {
          // ✅ Get printer config from database
          const printerConfig = await getPrinterByLocation(target);
          
          if (!printerConfig) {
            console.error(`Cannot print ${groupName} to ${target} - printer not configured`);
            return {
              group: groupName,
              target: target,
              result: { success: false, message: `Printer not configured for ${target}` }
            };
          }

          const basePayload = {
            ...payload,
            jobId: `${jobId}-${groupName}-${target}`,
            items,
            companyName,
            heading,
            target,
            // ✅ Add printer details from database
            printerIp: printerConfig.printer_ip,
            printerPort: printerConfig.printer_port,
            terminalId: printerConfig.terminal_id,
            macAddress: printerConfig.mac_address
          };

          console.log(`📤 Sending ${groupName} KOT to ${target}`);
          const result = await sendPrintJobPayload(basePayload);

          return {
            group: groupName,
            target: target,
            printer: printerConfig.terminal_id,
            printerIp: printerConfig.printer_ip,
            result: result
          };
        });
      })
    );

    return res.json({
      success: true,
      message: "KOT sent to separate printers by item group",
      data: results,
      groups: groupCounts
    });
  } catch (error) {
    console.error("Local agent KOT print error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver KOT print job"
    });
  }
};

const sendBillToCashier = async (req, res) => {
  const payload = req.body || {};
  const jobId = payload.jobId || `bill-${Date.now()}`;

  if (!payload.table || !Array.isArray(payload.items) || payload.items.length === 0) {
    return res.status(400).json({
      success: false,
      message: "table and items are required"
    });
  }

  try {
    // Fetch company name
    let companyName = "Restaurant Name";
    try {
      const [companyRows] = await db.query(
        `SELECT name FROM companyinfo ORDER BY id DESC LIMIT 1`
      );
      if (companyRows && companyRows.length > 0) {
        companyName = companyRows[0].name;
      }
    } catch (dbErr) {
      console.error("Failed to fetch company name:", dbErr.message);
    }

    const result = await sendPrintJobPayload({
      ...payload,
      jobId,
      target: "cashier",
      companyName
    });

    return res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error("Local agent bill print error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver bill print job"
    });
  }
};

const sendInvoiceByBillId = async (req, res) => {
  const rawBillId = req.body?.billId ?? req.params?.billId ?? req.query?.billId;
  const billId = Number(rawBillId);
  const machineUuid = req.body?.machine_uuid ?? req.body?.user_uuid ?? req.query?.machine_uuid;

  if (!billId || Number.isNaN(billId)) {
    return res.status(400).json({
      success: false,
      message: "Valid billId is required"
    });
  }

  try {
    const [[billRow]] = await db.query(
      `SELECT id, inv_date, inv_time, table_number, subtotal, subtotal_afterdiscount, tax, roundoff, grand_total, payment_mode
       FROM final_bill
       WHERE id = ?
       LIMIT 1`,
      [billId]
    );

    if (!billRow) {
      return res.status(404).json({
        success: false,
        message: "Bill not found"
      });
    }

    const itemRows = await fetchBillItems(billId);

    if (!itemRows || itemRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No order items found for this bill"
      });
    }

    const companyInfo = await fetchCompanyInfo();

    // ✅ Single mode printer resolution for cashier invoice printing
    let cashierPrinter = null;
    try {
      if (machineUuid) {
        const [printerRows] = await db.query(
          `SELECT terminal_id, printer_ip, printer_port, location, machine_uuid
           FROM printer_config
           WHERE machine_uuid = ? AND location = 'cashier' AND status = 'active'
           ORDER BY id ASC
           LIMIT 1`,
          [machineUuid]
        );
        if (printerRows && printerRows.length > 0) {
          cashierPrinter = printerRows[0];
        }
      }

      if (!cashierPrinter) {
        const [fallbackRows] = await db.query(
          `SELECT terminal_id, printer_ip, printer_port, location, machine_uuid
           FROM printer_config
           WHERE location = 'cashier' AND status = 'active'
           ORDER BY id ASC
           LIMIT 1`
        );
        if (fallbackRows && fallbackRows.length > 0) {
          cashierPrinter = fallbackRows[0];
        }
      }
    } catch (printerErr) {
      console.error("Cashier printer lookup error:", printerErr);
      return res.status(500).json({
        success: false,
        message: "Failed to resolve cashier printer configuration"
      });
    }

    if (!cashierPrinter) {
      return res.status(404).json({
        success: false,
        message: "No active cashier printer configuration found"
      });
    }

    const items = itemRows.map((item) => {
      const quantity = Number(item.quantity || 0);
      const lineTotal = Number(item.total_price || 0);
      const rate = quantity > 0 ? lineTotal / quantity : lineTotal;

      return {
        name: item.item_name,
        quantity,
        rate,
        total: lineTotal
      };
    });

    const payload = {
      jobId: `invoice-${billId}-${Date.now()}`,
      target: "cashier",
      mode: "single",
      printType: "invoice",
      bill_id: billRow.id,
      table: billRow.table_number,
      date: billRow.inv_date,
      time: billRow.inv_time,
      payment_mode: billRow.payment_mode,
      subtotal: Number(billRow.subtotal_afterdiscount || billRow.subtotal || 0),
      tax: Number(billRow.tax || 0),
      roundoff: Number(billRow.roundoff || 0),
      grand_total: Number(billRow.grand_total || 0),
      companyName: companyInfo.name || "Restaurant Name",
      companyAddress: companyInfo.address || "",
      companyPhone: companyInfo.phone_number || "",
      tax_id: companyInfo.tax_id || "",
      items,
      printerIp: cashierPrinter.printer_ip,
      printerPort: cashierPrinter.printer_port,
      terminalId: cashierPrinter.terminal_id,
      machine_uuid: machineUuid || cashierPrinter.machine_uuid || null
    };

    const result = await sendPrintJobPayload(payload);

    return res.json({
      success: true,
      data: result,
      billId,
      itemsCount: items.length,
      printer: {
        terminal_id: cashierPrinter.terminal_id,
        printer_ip: cashierPrinter.printer_ip,
        printer_port: cashierPrinter.printer_port,
        location: cashierPrinter.location
      }
    });
  } catch (error) {
    console.error("Local agent invoice print error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to print invoice by billId"
    });
  }
};

const testPrint = async (req, res) => {
  const target = (req.body && req.body.target) || req.query.target || "kitchen";
  const payload = buildSamplePayload("test", { target });

  try {
    const result = await sendPrintJobPayload(payload);

    return res.json({
      success: true,
      data: result,
      payload
    });
  } catch (error) {
    console.error("Local agent test print error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver test print job"
    });
  }
};

const testKot = async (req, res) => {
  const payload = buildSamplePayload("kot");

  try {
    const companyName = await fetchCompanyName();

    const [kitchenResult, cashierResult] = await Promise.all([
      sendPrintJobPayload({ ...payload, target: "kitchen", companyName }),
      sendPrintJobPayload({ ...payload, target: "cashier", companyName })
    ]);

    return res.json({
      success: true,
      data: {
        kitchen: kitchenResult,
        cashier: cashierResult
      },
      payload
    });
  } catch (error) {
    console.error("Local agent test KOT error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver test KOT print job"
    });
  }
};

const testBill = async (req, res) => {
  const payload = buildSamplePayload("bill", { target: "cashier" });

  try {
    const companyName = await fetchCompanyName();

    const result = await sendPrintJobPayload({ ...payload, companyName });

    return res.json({
      success: true,
      data: result,
      payload
    });
  } catch (error) {
    console.error("Local agent test bill error:", error);
    return res.status(502).json({
      success: false,
      message: "Failed to deliver test bill print job"
    });
  }
};

const getHealth = (req, res) => {
  const socketClient = getSocket();

  return res.json({
    success: true,
    connected: socketClient.connected,
    url: process.env.LOCAL_AGENT_URL || "http://localhost:5010"
  });
};

/**
 * Print KOT/Bill with Auto-detected Printer IPs (Item Group Aware)
 * POST /cloud-agent/print-kot
 * Body: { items, table, jobId, heading, total, companyName, ... }
 * Groups items by type (food/bar/shisha) and sends SEPARATE KOTs to appropriate printers
 * Food → kitchen + cashier (separate KOT per location)
 * Bar/Shisha → cashier only
 */
const printKotWithDetection = async (req, res) => {
  try {
    console.log('🖨️ Received print request with item grouping');
    // ✅ Extract both machine_uuid and user_uuid (or device_uuid)
    const { jobId, table, items, heading, total, companyName, machine_uuid, user_uuid, device_uuid, ...otherData } = req.body;
    
    // Use machine_uuid if provided, fallback to user_uuid or device_uuid
    const uuid = machine_uuid || user_uuid || device_uuid;

    // Validation
    if (!jobId || !table || !items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: jobId, table, items'
      });
    }

    console.log(`📍 Table: ${table}, Items: ${items.length}, UUID: ${uuid || 'not provided'}`);

    // 🔐 DEVICE-SPECIFIC PRINTER ROUTING
    if (machine_uuid) {
      console.log(`\n🔍 Looking up ALL printers for Machine UUID: ${machine_uuid}`);
      
      try {
        // ✅ FIXED: Get ALL printers (not LIMIT 1) so we can send to all locations
        const [devicePrinters] = await db.query(
          "SELECT * FROM printer_config WHERE machine_uuid = ? AND status = 'active' ORDER BY location",
          [machine_uuid]
        );

        if (!devicePrinters || devicePrinters.length === 0) {
          return res.status(404).json({
            success: false,
            message: `No printer found for machine UUID: ${machine_uuid}. Please configure printer in admin panel.`
          });
        }

        console.log(`✅ Found ${devicePrinters.length} printer(s) for UUID ${machine_uuid}`);
        devicePrinters.forEach((p, idx) => {
          console.log(`   ${idx + 1}. ${p.terminal_id} (${p.location}): ${p.printer_ip}:${p.printer_port}`);
        });

        // ✅ If multiple printers, send to ALL; if single, send to that one
        if (devicePrinters.length === 1) {
          // Single printer: Send directly
          const printer = devicePrinters[0];
          const payload = {
            jobId: jobId,
            table,
            items,
            heading: heading || 'KOT',
            total,
            target: printer.location,
            companyName: companyName || await fetchCompanyName(),
            printerIp: printer.printer_ip,
            printerPort: printer.printer_port,
            terminalId: printer.terminal_id,
            machineUuid: machine_uuid,
            ...otherData
          };

          console.log(`📤 Sending KOT to single printer: ${printer.terminal_id} (${printer.location})`);
          const result = await sendPrintJobPayload(payload);

          return res.json({
            success: true,
            message: 'KOT sent to printer',
            data: {
              jobId,
              printer: printer.terminal_id,
              location: printer.location,
              printerIp: printer.printer_ip,
              itemsCount: items.length,
              result
            }
          });
        } else {
          // ✅ Multiple printers: Send to ALL locations via multi-printer mode
          console.log(`\n📤 Sending to ${devicePrinters.length} printers (multi-location mode)...`);

          const allPrinterIps = devicePrinters.map(p => ({
            ip: p.printer_ip,
            port: p.printer_port,
            location: p.location,
            terminal_id: p.terminal_id,
            mac_address: p.mac_address
          }));

          const multiPayload = {
            jobId: jobId,
            table,
            items,
            heading: heading || 'KOT',
            total,
            target: 'multi-location',
            companyName: companyName || await fetchCompanyName(),
            printers: allPrinterIps,
            allPrinterIps: allPrinterIps,
            machineUuid: machine_uuid,
            ...otherData
          };

          console.log(`📤 Sending KOT to multiple locations`);
          const result = await sendPrintJobPayload(multiPayload);

          return res.json({
            success: true,
            message: 'KOT sent to all assigned printers',
            data: {
              jobId,
              printersCount: devicePrinters.length,
              printers: allPrinterIps.map(p => ({
                terminal_id: p.terminal_id,
                location: p.location,
                printer_ip: p.ip
              })),
              itemsCount: items.length,
              result
            }
          });
        }
      } catch (uuidError) {
        console.error('Error looking up UUID printer:', uuidError);
        return res.status(500).json({
          success: false,
          message: 'Error looking up printer configuration'
        });
      }
    }

    // 📍 FALLBACK: GROUP-BASED ROUTING (when machine_uuid/user_uuid is not provided)
    if (!uuid) {
      console.warn('⚠️  User UUID not provided - cannot determine assigned printers');
      return res.status(400).json({
        success: false,
        message: 'Missing required field: user_uuid (or machine_uuid). Please pass user_uuid in request body.',
        code: 'MISSING_UUID'
      });
    }
    
    console.log(`\n📍 Using UUID-based device routing: ${uuid}`);

    // Step 1: Group items by type (same logic as sendKotToBoth)
    const grouped = groupItemsByGroup(items);
    const groupsToPrint = Object.entries(grouped)
      .filter(([, groupItems]) => groupItems.length > 0);

    if (groupsToPrint.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No items found for food/bar/shisha groups'
      });
    }

    console.log(`📊 Item groups found: ${groupsToPrint.map(([g, items]) => `${g}(${items.length})`).join(', ')}`);

    // Step 2: Determine target printer location(s) based on item groups
    const getPrinterTargets = (groupName) => {
      if (groupName === "food") {
        return ["kitchen", "cashier"]; // Food goes to BOTH printers (separate KOTs)
      } else if (groupName === "bar" || groupName === "shisha") {
        return ["cashier"]; // Bar and Shisha go to cashier printer only
      }
      return ["kitchen"]; // Default to kitchen
    };

    // Step 3: Build printable payloads with grouped items
    const getPrinterByLocation = async (location, userUuid) => {
      try {
        // ✅ FIXED: Filter by both machine_uuid AND location
        const [printers] = await db.query(
          "SELECT * FROM printer_config WHERE machine_uuid = ? AND location = ? AND status = 'active' LIMIT 1",
          [userUuid, location]
        );
        
        if (printers.length > 0) {
          const printer = printers[0];
          console.log(`✅ Selected printer for ${location}: ${printer.terminal_id} (${printer.printer_ip}:${printer.printer_port})`);
          return {
            printer_ip: printer.printer_ip,
            printer_port: printer.printer_port,
            terminal_id: printer.terminal_id,
            location: printer.location,
            mac_address: printer.mac_address
          };
        } else {
          console.warn(`⚠️  No printer configured for UUID ${userUuid} at location: ${location}`);
          return null;
        }
      } catch (err) {
        console.error(`Error fetching printer for ${location}:`, err);
        return null;
      }
    };

    // Step 4: Build payloads for each group+location combination
    const printPayloads = [];

    for (const [groupName, groupItems] of groupsToPrint) {
      const targets = getPrinterTargets(groupName);
      console.log(`\n🎯 Group: ${groupName} (${groupItems.length} items) → Targets: ${targets.join(', ')}`);

      for (const target of targets) {
        // ✅ Pass UUID (user_uuid or machine_uuid) to getPrinterByLocation
        const printer = await getPrinterByLocation(target, uuid);
        
        if (!printer) {
          console.warn(`⚠️  Printer not found for UUID ${uuid} at location ${target}, skipping ${groupName}`);
          continue;
        }

        const payload = {
          jobId: `${jobId}-${groupName}-${target}`,
          table,
          items: groupItems, // ✅ ONLY items from this group
          heading: `${groupName.toUpperCase()} KOT`,
          total,
          target,
          companyName: companyName || await fetchCompanyName(),
          printerIp: printer.printer_ip,
          printerPort: printer.printer_port,
          terminalId: printer.terminal_id,
          machineUuid: uuid,  // ✅ Include UUID in payload
          userUuid: uuid,
          macAddress: printer.mac_address,
          ...otherData
        };

        printPayloads.push({
          group: groupName,
          location: target,
          printer: printer.terminal_id,
          printerIp: printer.printer_ip,
          payload
        });

        console.log(`   ✓ Payload created: ${groupItems.length} items → ${target.toUpperCase()} (${printer.terminal_id})`);
      }
    }

    console.log(`\n📋 TOTAL PAYLOADS TO SEND: ${printPayloads.length}`);
    printPayloads.forEach((p, idx) => {
      console.log(`   ${idx + 1}. ${p.group.toUpperCase()} → ${p.location.toUpperCase()}: ${p.payload.items.length} items`);
    });

    if (printPayloads.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No printers configured for target locations'
      });
    }

    // Step 5: Send all payloads sequentially (not in parallel) to ensure each completes
    console.log(`\n📤 Sending ${printPayloads.length} KOT(s) sequentially...`);
    
    const results = [];
    for (const p of printPayloads) {
      try {
        console.log(`   📨 Sending: ${p.group.toUpperCase()} → ${p.location} (${p.printer})`);
        const result = await sendPrintJobPayload(p.payload);
        
        results.push({
          group: p.group,
          location: p.location,
          printer: p.printer,
          printerIp: p.printerIp,
          itemsCount: p.payload.items.length,
          result
        });
        
        console.log(`   ✅ ${p.group.toUpperCase()} sent to ${p.location}`);
        
        // Small delay between sends to allow socket to process
        await new Promise(resolve => setTimeout(resolve, 300));
      } catch (err) {
        console.error(`   ❌ Error sending ${p.group} to ${p.location}:`, err.message);
        results.push({
          group: p.group,
          location: p.location,
          printer: p.printer,
          printerIp: p.printerIp,
          itemsCount: p.payload.items.length,
          error: err.message
        });
      }
    }

    return res.json({
      success: true,
      message: `Print job(s) sent - ${printPayloads.length} separate KOT(s) based on item groups`,
      data: {
        jobId,
        table,
        totalKots: printPayloads.length,
        kots: results
      }
    });

  } catch (error) {
    console.error('❌ Print error:', error);
    const message = error.message || 'Failed to process print request';
    
    return res.status(500).json({
      success: false,
      message,
      error: error.message
    });
  }
};

/**
 * Print to Specific Location (Kitchen + Cashier simultaneous)
 * POST /cloud-agent/print-both
 * Prints KOT to kitchen and receipt to cashier at the same time
 */
const printToMultipleLocations = async (req, res) => {
  try {
    console.log('🖨️ Received multi-location print request');
    const { jobId, table, items, total, companyName, ...otherData } = req.body;

    if (!jobId || !table || !items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: jobId, table, items'
      });
    }

    console.log(`📍 Multi-location print for table: ${table}`);

    // Get both kitchen and cashier printers
    const [printers] = await db.query(
      "SELECT * FROM printer_config WHERE status = 'active' AND location IN ('kitchen', 'cashier')",
      []
    );

    if (printers.length < 2) {
      return res.status(404).json({
        success: false,
        message: 'Both kitchen and cashier printers must be configured'
      });
    }

    const printerMap = {};
    printers.forEach(p => {
      printerMap[p.location] = p;
    });

    // Prepare payloads for both locations
    const kitchenPayload = {
      jobId: `${jobId}-kt`,
      table,
      items,
      heading: 'KITCHEN KOT',
      target: 'kitchen',
      companyName: companyName || await fetchCompanyName(),
      printerIp: printerMap.kitchen.printer_ip,
      printerPort: printerMap.kitchen.printer_port,
      ...otherData
    };

    const cashierPayload = {
      jobId: `${jobId}-cash`,
      table,
      items,
      heading: 'CASHIER RECEIPT',
      total,
      target: 'cashier',
      companyName: companyName || await fetchCompanyName(),
      printerIp: printerMap.cashier.printer_ip,
      printerPort: printerMap.cashier.printer_port,
      ...otherData
    };

    console.log(`📤 Sending to both kitchen and cashier...`);

    // Send both simultaneously
    const results = await Promise.all([
      sendPrintJobPayload(kitchenPayload),
      sendPrintJobPayload(cashierPayload)
    ]);

    return res.json({
      success: true,
      message: 'Print jobs sent to both locations',
      data: {
        kitchen: {
          terminal_id: printerMap.kitchen.terminal_id,
          printer_ip: printerMap.kitchen.printer_ip,
          ack: results[0]
        },
        cashier: {
          terminal_id: printerMap.cashier.terminal_id,
          printer_ip: printerMap.cashier.printer_ip,
          ack: results[1]
        }
      }
    });

  } catch (error) {
    console.error('❌ Multi-location print error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to process multi-location print request'
    });
  }
};

module.exports = {
  sendPrintJob,
  getHealth,
  testPrint,
  testKot,
  testBill,
  sendKotToBoth,
  sendBillToCashier,
  sendInvoiceByBillId,
  printKotWithDetection,
  printToMultipleLocations
};
