# Printer Auto-Detection for ESC/POS - Local Agent Guide

## 📋 Overview

The system now supports automatic printer detection based on machine MAC address or printer location type. This enables seamless printing for kitchen and cashier terminals without manual printer selection.

---

## 🎯 Architecture

```
┌─────────────────────────────────┐
│  POS Client (React/Frontend)    │
│  - User prints receipt/order    │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Local Printing Agent           │
│  (Node.js/Electron App)         │
│  - Detects machine MAC/IP       │
│  - Requests printer config      │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Backend API (ChefMate Pro)     │
│  - /api/printer/detect          │
│  - /api/printer/agent/detect    │
│  - Database lookup              │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Database Query                 │
│  - Match MAC or location        │
│  - Return printer config        │
└─────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Local Agent (Returns to caller) │
│  - Printer IP                   │
│  - Printer Port                 │
│  - Location (kitchen/cashier)   │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  ESC/POS Print                  │
│  - Connect to printer IP:port    │
│  - Send print commands          │
│  - Handle success/error         │
└─────────────────────────────────┘
```

---

## 🔌 API Endpoints

### 1. **Auto-Detect Printer (Client-Side)**

**Endpoint:** `GET /api/printer/detect`

**Purpose:** Browser requests printer based on client IP/MAC (used by frontend)

**Query Parameters:**
- `type` (optional): `'kitchen'` or `'cashier'` - forces specific printer type

**Example Requests:**

```bash
# Auto-detect any available printer
curl http://127.0.0.1:4402/api/printer/detect

# Auto-detect kitchen printer
curl http://127.0.0.1:4402/api/printer/detect?type=kitchen

# Auto-detect cashier printer
curl http://127.0.0.1:4402/api/printer/detect?type=cashier
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Printer detected successfully (matched by MAC address)",
  "data": {
    "id": 1,
    "terminal_id": "KITCHEN-001",
    "mac_address": "00:1A:2B:3C:4D:5E",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1",
    "detection_method": "mac_address",
    "client_ip": "192.168.1.50",
    "client_mac": "00:1A:2B:3C:4D:5E"
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "No active printer configuration found in database",
  "data": {
    "client_ip": "192.168.1.50",
    "client_mac": "00:1A:2B:3C:4D:5E"
  }
}
```

---

### 2. **Agent Printer Detection (Local Agent)**

**Endpoint:** `GET /api/printer/agent/detect`

**Purpose:** Local printing agent requests printer configuration (most important endpoint)

**Query Parameters:**
- `mac_address` (optional): Direct MAC lookup `'00:1A:2B:3C:4D:5E'`
- `type` (optional): `'kitchen'` or `'cashier'`

**Example Requests:**

```bash
# Get printer by MAC address
curl http://127.0.0.1:4402/api/printer/agent/detect?mac_address=00:1A:2B:3C:4D:5E

# Get all kitchen printers
curl http://127.0.0.1:4402/api/printer/agent/detect?type=kitchen

# Get all cashier printers
curl http://127.0.0.1:4402/api/printer/agent/detect?type=cashier
```

**Success Response (200) - Single MAC match:**
```json
{
  "success": true,
  "message": "Printer configuration found",
  "data": {
    "printer_id": 1,
    "terminal_id": "KITCHEN-001",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1",
    "mac_address": "00:1A:2B:3C:4D:5E",
    "status": "active"
  }
}
```

**Success Response (200) - Location match (multiple printers):**
```json
{
  "success": true,
  "message": "Found 2 printer(s) for kitchen",
  "count": 2,
  "data": [
    {
      "printer_id": 1,
      "terminal_id": "KITCHEN-001",
      "location": "kitchen",
      "printer_ip": "192.168.1.100",
      "printer_port": 9100,
      "printer_name": "Kitchen Printer 1",
      "mac_address": "00:1A:2B:3C:4D:5E",
      "status": "active"
    },
    {
      "printer_id": 2,
      "terminal_id": "KITCHEN-002",
      "location": "kitchen",
      "printer_ip": "192.168.1.105",
      "printer_port": 9100,
      "printer_name": "Kitchen Printer 2 (Backup)",
      "mac_address": null,
      "status": "active"
    }
  ]
}
```

**Error Response (404) - No printer found:**
```json
{
  "success": false,
  "message": "No active printer configured for MAC: FF:FF:FF:FF:FF:FF",
  "data": {
    "mac_address": "FF:FF:FF:FF:FF:FF"
  }
}
```

**Error Response (400) - Invalid format:**
```json
{
  "success": false,
  "message": "Invalid MAC address format"
}
```

---

## 🤖 Local Agent Implementation

### Node.js Example

```javascript
const axios = require('axios');
const { execSync } = require('child_process');
const os = require('os');

class LocalPrintingAgent {
  constructor(backendUrl = 'http://127.0.0.1:4402') {
    this.backendUrl = backendUrl;
  }

  /**
   * Get machine MAC address
   */
  getMachineMAC() {
    try {
      const interfaces = os.networkInterfaces();
      
      for (const name of Object.keys(interfaces)) {
        if (name.includes('lo') || name.includes('vbox')) continue;
        
        for (const iface of interfaces[name]) {
          if (iface.family === 'IPv4' && !iface.internal) {
            return iface.mac;
          }
        }
      }
    } catch (error) {
      console.error('Failed to get MAC:', error);
    }
    return null;
  }

  /**
   * Detect and get printer configuration
   * @param {string} printerType - 'kitchen' or 'cashier' (optional)
   * @returns {Promise<Object>} Printer configuration
   */
  async detectPrinter(printerType = null) {
    try {
      const mac = this.getMachineMAC();
      console.log(`🔍 Detecting printer... MAC: ${mac}`);

      let url = `${this.backendUrl}/api/printer/agent/detect`;
      
      if (mac) {
        // Try MAC-based detection first
        url += `?mac_address=${mac}`;
      } else if (printerType) {
        // Fallback to type-based detection
        url += `?type=${printerType}`;
      } else {
        throw new Error('Cannot detect printer - No MAC and no type specified');
      }

      const response = await axios.get(url);

      if (!response.data.success) {
        throw new Error(response.data.message);
      }

      console.log(`✅ Printer detected: ${response.data.data.terminal_id || response.data.data[0].terminal_id}`);
      return response.data.data;

    } catch (error) {
      console.error(`❌ Printer detection failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Print to detected printer
   * @param {Object} printerConfig - Printer configuration from detectPrinter()
   * @param {string} printData - ESC/POS print commands
   */
  async printToDetectedPrinter(printerConfig, printData) {
    try {
      const printerIp = printerConfig.printer_ip;
      const printerPort = printerConfig.printer_port || 9100;
      const printerName = printerConfig.printer_name;

      console.log(`🖨️  Printing to: ${printerName} (${printerIp}:${printerPort})`);

      // Use your ESC/POS library here
      // Example: await this.escPosPrinter.print(printerIp, printerPort, printData);

      console.log(`✅ Print sent successfully`);
      return { success: true, printer: printerName };

    } catch (error) {
      console.error(`❌ Print failed: ${error.message}`);
      throw error;
    }
  }
}

// Usage Example
async function printReceipt() {
  const agent = new LocalPrintingAgent();

  try {
    // Detect printer
    const printerConfig = await agent.detectPrinter('kitchen');

    // Print ESC/POS data
    const escposData = '\x1B\x40'; // ESC @ (Initialize)
    await agent.printToDetectedPrinter(printerConfig, escposData);

  } catch (error) {
    console.error('Printing failed:', error.message);
  }
}
```

---

## 🎬 Frontend Integration (React)

```javascript
import axios from 'axios';

async function getPrinterForPrinting(printerType = 'kitchen') {
  try {
    console.log(`📍 Requesting printer config for: ${printerType}`);

    const response = await axios.get('http://127.0.0.1:4402/api/printer/detect', {
      params: { type: printerType }
    });

    if (!response.data.success) {
      throw new Error(response.data.message);
    }

    const printer = response.data.data;
    console.log(`✅ Got printer: ${printer.printer_name}`);

    // Return printer details for local agent to use
    return {
      ip: printer.printer_ip,
      port: printer.printer_port,
      location: printer.location,
      name: printer.printer_name,
      mac: printer.mac_address
    };

  } catch (error) {
    console.error('Failed to get printer:', error.message);
    alert(`Error: ${error.message}`);
    return null;
  }
}

// Usage in print handler
async function handlePrintClick(billData, printerType) {
  const printer = await getPrinterForPrinting(printerType);
  
  if (!printer) {
    alert('Printer not found. Please check configuration.');
    return;
  }

  // Send to local agent via IPC, socket, or HTTP
  // Example: window.api.print({ printer, billData })
}
```

---

## 🔧 Setup Checklist

- [ ] **Printer Configuration** - Register all printers with MAC addresses
  ```bash
  POST /api/printer/config
  {
    "terminal_id": "KITCHEN-001",
    "mac_address": "00:1A:2B:3C:4D:5E",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer"
  }
  ```

- [ ] **Detect Machine MAC** - Ensure client can detect its MAC
  - Windows: Uses network interfaces or ARP
  - macOS/Linux: Reads from ifconfig/ip output

- [ ] **Local Agent Running** - Start printing agent on client machines
  ```bash
  node local-printer-agent.js
  ```

- [ ] **Database Configured** - Printers registered with correct MAC addresses
  ```sql
  SELECT * FROM printer_config WHERE status = 'active';
  ```

- [ ] **Test Detection** - Verify detection works
  ```bash
  # Run test
  node test-printer-detection.js
  
  # Manual test
  curl http://127.0.0.1:4402/api/printer/detect?type=kitchen
  ```

---

## 📊 Detection Priority

The system uses this priority order:

1. **MAC Address Match** (Highest Priority)
   - Direct database lookup by MAC
   - Most accurate for specific terminals

2. **Location Type Match** (Medium Priority)
   - Match by 'kitchen' or 'cashier'
   - Returns first active printer of that type

3. **Default Printer** (Lowest Priority)
   - Returns any active printer
   - Used when no filters specified

---

## 🚨 Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| "No active printer configuration found" | No printers in database | Register printers via `/api/printer/config` |
| "Invalid MAC address format" | Malformed MAC | Use format `XX:XX:XX:XX:XX:XX` |
| "No printer configured for MAC: ..." | MAC not registered | Register the machine's MAC in database |
| Connection timeout | Printer IP unreachable | Verify printer IP is correct and online |

---

## 🧪 Testing

```bash
# Run detection test
node test-printer-detection.js

# Test specific MAC
curl "http://127.0.0.1:4402/api/printer/agent/detect?mac_address=00:1A:2B:3C:4D:5E"

# Test kitchen printer
curl "http://127.0.0.1:4402/api/printer/agent/detect?type=kitchen"

# View all active printers
curl "http://127.0.0.1:4402/api/printer/config"
```

---

## 📝 Notes

- MAC addresses are **case-insensitive** and can use colons (`:`) or hyphens (`-`)
- All comparisons normalize to uppercase with colons
- Printers must be marked as `status='active'` to be detected
- For multiple printers per location, the API returns all matches
- Local agent should implement retry logic for network failures

---

**Created:** March 3, 2026  
**Status:** ✅ Ready for Production
