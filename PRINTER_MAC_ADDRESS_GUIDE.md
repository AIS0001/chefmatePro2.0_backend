# Printer MAC Address Auto-Detection - Quick Guide

## ✅ Implementation Complete

Added MAC address field to printer configuration for automatic ESC/POS printer detection.

---

## 🚀 Setup Instructions

### Step 1: Run Database Migration

Execute the SQL migration to add `mac_address` column:

```bash
# Using MySQL command line
mysql -u your_user -p chefmatepro < database/add_mac_address_to_printer_config.sql

# Or using phpMyAdmin
# Import: database/add_mac_address_to_printer_config.sql
```

**SQL Migration File:** `database/add_mac_address_to_printer_config.sql`

---

## 📡 New API Endpoints

### 1. Get Printer by MAC Address (Auto-Detection)

**Endpoint:** `GET /api/printer/config/mac/:mac_address`

**Purpose:** Automatically detect printer settings based on client machine MAC address

**Example Request:**
```bash
curl http://127.0.0.1:4402/api/printer/config/mac/00:1A:2B:3C:4D:5E
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "terminal_id": "KITCHEN-001",
    "mac_address": "00:1A:2B:3C:4D:5E",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1",
    "status": "active",
    "created_at": "2026-03-02T15:48:32.000Z",
    "updated_at": "2026-03-02T15:48:32.000Z"
  }
}
```

**404 Response (No config found):**
```json
{
  "success": false,
  "message": "No active printer configuration found for MAC address: 00:1A:2B:3C:4D:5E"
}
```

---

### 2. Save Printer Config (Now with MAC)

**Endpoint:** `POST /api/printer/config`

**Body (Updated):**
```json
{
  "terminal_id": "KITCHEN-001",
  "mac_address": "00:1A:2B:3C:4D:5E",
  "location": "kitchen",
  "printer_ip": "192.168.1.100",
  "printer_port": 9100,
  "printer_name": "Kitchen Printer 1"
}
```

**Note:** `mac_address` is optional but recommended for auto-detection.

---

### 3. Update Printer Config (Now supports MAC)

**Endpoint:** `PUT /api/printer/config/:terminal_id`

**Body:**
```json
{
  "mac_address": "11:22:33:44:55:66",
  "printer_ip": "192.168.1.105"
}
```

---

## 🔧 Frontend Integration Example

### Automatic Printer Detection in ESC/POS Printing

```javascript
// In your print component/service

async function getPrinterSettingsForCurrentMachine() {
  try {
    // Step 1: Get current machine's MAC address
    const macResponse = await axios.get('http://127.0.0.1:4402/api/device/machine-mac');
    const macAddress = macResponse.data.data.mac_address;
    
    console.log('Machine MAC:', macAddress);
    
    // Step 2: Get printer configuration for this MAC
    const printerResponse = await axios.get(
      `http://127.0.0.1:4402/api/printer/config/mac/${macAddress}`
    );
    
    const printerConfig = printerResponse.data.data;
    
    console.log('Detected Printer:', {
      ip: printerConfig.printer_ip,
      port: printerConfig.printer_port,
      location: printerConfig.location
    });
    
    return printerConfig;
    
  } catch (error) {
    if (error.response?.status === 404) {
      console.warn('No printer configured for this machine');
      // Fallback to manual selection or default printer
      return null;
    }
    throw error;
  }
}

// Usage in print function
async function printReceipt(billData) {
  const printerConfig = await getPrinterSettingsForCurrentMachine();
  
  if (!printerConfig) {
    alert('No printer configured for this machine. Please contact admin.');
    return;
  }
  
  // Use ESC/POS library to print to detected printer
  const printer = new EscPosPrinter({
    host: printerConfig.printer_ip,
    port: printerConfig.printer_port
  });
  
  // Print your receipt
  await printer.print(billData);
}
```

---

## 🧪 Testing

Run the test script to verify MAC address functionality:

```bash
node test-printer-mac.js
```

**Test Coverage:**
- ✅ Save printer config with MAC address
- ✅ Get printer by MAC address
- ✅ Update MAC address
- ✅ Verify updated MAC
- ✅ Reject invalid MAC format

---

## 📋 MAC Address Format

**Required Format:** `XX:XX:XX:XX:XX:XX`

**Valid Examples:**
- `00:1A:2B:3C:4D:5E`
- `A1:B2:C3:D4:E5:F6`
- `00-1A-2B-3C-4D-5E` (will be normalized to colon format)

**Invalid Examples:**
- `001A2B3C4D5E` (missing colons)
- `00:1A:2B:3C` (incomplete)
- `192.168.1.1` (IP address, not MAC)

---

## 🔄 Workflow: Auto-Detection

```
┌─────────────────┐
│ Client Machine  │
│ Opens App       │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ GET /device/machine-mac │ ← Detect MAC from network interface
└────────┬────────────────┘
         │ Returns: 00:1A:2B:3C:4D:5E
         ▼
┌──────────────────────────────────┐
│ GET /printer/config/mac/{mac}    │ ← Fetch printer config
└────────┬─────────────────────────┘
         │ Returns: printer_ip, port, location
         ▼
┌─────────────────────┐
│ Print to Detected   │
│ Printer (ESC/POS)   │
└─────────────────────┘
```

---

## 🎯 Use Cases

### 1. **Multi-Terminal Restaurant**
- Each cashier/kitchen terminal has unique MAC
- Automatically routes to correct printer
- No manual printer selection needed

### 2. **Kitchen Order Printing**
- Order placed from any terminal
- Kitchen MAC detected → prints to kitchen printer
- Cashier MAC detected → prints to cashier printer

### 3. **Backup Printers**
- Multiple printers per location
- If primary fails, update MAC to point to backup
- No code changes required

---

## 🛠️ Database Schema Changes

```sql
ALTER TABLE `printer_config` 
ADD COLUMN `mac_address` VARCHAR(17) NULL COMMENT 'Machine MAC address (XX:XX:XX:XX:XX:XX)' AFTER `terminal_id`,
ADD INDEX `idx_mac_address` (`mac_address`);
```

**New Column:**
- **Name:** `mac_address`
- **Type:** `VARCHAR(17)`
- **Format:** `XX:XX:XX:XX:XX:XX`
- **Nullable:** Yes (optional)
- **Indexed:** Yes (for fast lookups)

---

## 📞 Support & Troubleshooting

### MAC Not Detected?
```bash
# Check if machine-mac endpoint works
curl http://127.0.0.1:4402/api/device/machine-mac

# Expected response:
{
  "success": true,
  "data": {
    "mac_address": "00:1A:2B:3C:4D:5E",
    "ip": "192.168.1.50",
    "source": "arp"
  }
}
```

### Printer Not Found?
```bash
# Verify MAC is registered
curl http://127.0.0.1:4402/api/printer/config/mac/00:1A:2B:3C:4D:5E

# If 404, register the MAC:
curl -X POST http://127.0.0.1:4402/api/printer/config \
  -H "Content-Type: application/json" \
  -d '{
    "terminal_id": "YOUR-TERMINAL",
    "mac_address": "00:1A:2B:3C:4D:5E",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100
  }'
```

---

## ✅ Checklist

- [ ] Run SQL migration (`add_mac_address_to_printer_config.sql`)
- [ ] Restart Node.js server
- [ ] Test MAC detection (`GET /device/machine-mac`)
- [ ] Register printers with MAC addresses
- [ ] Test auto-detection (`GET /printer/config/mac/{mac}`)
- [ ] Update frontend to use auto-detection
- [ ] Run test script (`node test-printer-mac.js`)

---

**Implementation Date:** March 3, 2026  
**Status:** ✅ Ready for Production
