# Printer Configuration API Documentation

## Overview
This API manages ESC/POS printer configurations for kitchen and cashier terminals. It allows saving, retrieving, and updating printer IP addresses associated with specific terminal/machine IDs.

## Base URL
```
/api/printer
```

---

## Endpoints

### 1. Save New Printer Configuration
**Endpoint:** `POST /api/printer/config`

**Description:** Create a new printer configuration for a terminal.

**Request Body:**
```json
{
  "terminal_id": "KITCHEN-001",
  "location": "kitchen",
  "printer_ip": "192.168.1.100",
  "printer_port": 9100,
  "printer_name": "Kitchen Printer 1"
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| terminal_id | String | ✅ | Unique machine/terminal identifier |
| location | String | ✅ | Must be `kitchen` or `cashier` |
| printer_ip | String | ✅ | Valid IPv4 address (e.g., 192.168.1.100) |
| printer_port | Integer | ❌ | Port number (default: 9100) |
| printer_name | String | ❌ | Friendly name for the printer |

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "Printer configuration saved successfully",
  "data": {
    "id": 1,
    "terminal_id": "KITCHEN-001",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1",
    "status": "active",
    "created_at": "2026-03-02T10:30:00.000Z"
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Missing required fields: terminal_id, location, printer_ip"
}
```

---

### 2. Get All Printer Configurations
**Endpoint:** `GET /api/printer/config`

**Description:** Retrieve all active printer configurations.

**Response (Success - 200):**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "terminal_id": "KITCHEN-001",
      "location": "kitchen",
      "printer_ip": "192.168.1.100",
      "printer_port": 9100,
      "printer_name": "Kitchen Printer 1",
      "status": "active",
      "created_at": "2026-03-02T10:30:00.000Z",
      "updated_at": "2026-03-02T10:30:00.000Z"
    },
    {
      "id": 2,
      "terminal_id": "CASHIER-001",
      "location": "cashier",
      "printer_ip": "192.168.1.101",
      "printer_port": 9100,
      "printer_name": "Cashier Printer 1",
      "status": "active",
      "created_at": "2026-03-02T10:35:00.000Z",
      "updated_at": "2026-03-02T10:35:00.000Z"
    }
  ]
}
```

---

### 3. Get Printer Details by Terminal ID
**Endpoint:** `GET /api/printer/config/:terminal_id`

**Description:** Retrieve printer configuration for a specific terminal.

**URL Parameters:**
| Field | Type | Required |
|-------|------|----------|
| terminal_id | String | ✅ |

**Example Request:**
```
GET /api/printer/config/KITCHEN-001
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "terminal_id": "KITCHEN-001",
    "location": "kitchen",
    "printer_ip": "192.168.1.100",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1",
    "status": "active",
    "created_at": "2026-03-02T10:30:00.000Z",
    "updated_at": "2026-03-02T10:30:00.000Z"
  }
}
```

**Response (Not Found - 404):**
```json
{
  "success": false,
  "message": "No printer configuration found for terminal ID: KITCHEN-001"
}
```

---

### 4. Get Printers by Location
**Endpoint:** `GET /api/printer/location/:location`

**Description:** Retrieve all active printers for a specific location (kitchen or cashier).

**URL Parameters:**
| Field | Type | Required | Values |
|-------|------|----------|--------|
| location | String | ✅ | `kitchen` or `cashier` |

**Example Request:**
```
GET /api/printer/location/kitchen
```

**Response (Success - 200):**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "terminal_id": "KITCHEN-001",
      "location": "kitchen",
      "printer_ip": "192.168.1.100",
      "printer_port": 9100,
      "printer_name": "Kitchen Printer 1",
      "status": "active",
      "created_at": "2026-03-02T10:30:00.000Z",
      "updated_at": "2026-03-02T10:30:00.000Z"
    },
    {
      "id": 3,
      "terminal_id": "KITCHEN-002",
      "location": "kitchen",
      "printer_ip": "192.168.1.105",
      "printer_port": 9100,
      "printer_name": "Kitchen Printer 2",
      "status": "active",
      "created_at": "2026-03-02T10:40:00.000Z",
      "updated_at": "2026-03-02T10:40:00.000Z"
    }
  ]
}
```

---

### 5. Update Printer Configuration
**Endpoint:** `PUT /api/printer/config/:terminal_id`

**Description:** Update an existing printer configuration.

**URL Parameters:**
| Field | Type | Required |
|-------|------|----------|
| terminal_id | String | ✅ |

**Request Body:**
```json
{
  "printer_ip": "192.168.1.102",
  "printer_port": 9100,
  "printer_name": "Kitchen Printer 1 - Updated",
  "status": "active"
}
```

**Parameters (All Optional):**
| Field | Type | Description |
|-------|------|-------------|
| printer_ip | String | New printer IP address |
| printer_port | Integer | New printer port |
| printer_name | String | New friendly name |
| status | String | `active` or `inactive` |

**Example Request:**
```
PUT /api/printer/config/KITCHEN-001
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Printer configuration updated successfully",
  "data": {
    "id": 1,
    "terminal_id": "KITCHEN-001",
    "location": "kitchen",
    "printer_ip": "192.168.1.102",
    "printer_port": 9100,
    "printer_name": "Kitchen Printer 1 - Updated",
    "status": "active",
    "created_at": "2026-03-02T10:30:00.000Z",
    "updated_at": "2026-03-02T11:30:00.000Z"
  }
}
```

---

### 6. Delete Printer Configuration
**Endpoint:** `DELETE /api/printer/config/:terminal_id`

**Description:** Delete a printer configuration.

**URL Parameters:**
| Field | Type | Required |
|-------|------|----------|
| terminal_id | String | ✅ |

**Example Request:**
```
DELETE /api/printer/config/KITCHEN-001
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Printer configuration for terminal 'KITCHEN-001' deleted successfully"
}
```

**Response (Not Found - 404):**
```json
{
  "success": false,
  "message": "No printer configuration found for terminal ID: KITCHEN-001"
}
```

---

## Error Codes

| Status | Message | Meaning |
|--------|---------|---------|
| 201 | Created | Configuration saved successfully |
| 200 | OK | Request successful |
| 400 | Bad Request | Missing or invalid parameters |
| 404 | Not Found | Configuration not found |
| 409 | Conflict | Terminal ID already configured |
| 500 | Server Error | Internal server error |

---

## Frontend Integration Examples

### JavaScript/Frontend Implementation

#### 1. Save Printer Configuration
```javascript
async function savePrinterConfig() {
  const printerConfig = {
    terminal_id: "KITCHEN-001",
    location: "kitchen",
    printer_ip: "192.168.1.100",
    printer_port: 9100,
    printer_name: "Kitchen Main Printer"
  };

  try {
    const response = await fetch('/api/printer/config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(printerConfig)
    });

    const result = await response.json();
    if (result.success) {
      console.log("Printer configured:", result.data);
    } else {
      console.error("Error:", result.message);
    }
  } catch (error) {
    console.error("Request failed:", error);
  }
}
```

#### 2. Get Printer Details
```javascript
async function getPrinterDetails(terminalId) {
  try {
    const response = await fetch(`/api/printer/config/${terminalId}`);
    const result = await response.json();

    if (result.success) {
      const printer = result.data;
      console.log(`Printer IP: ${printer.printer_ip}:${printer.printer_port}`);
      return printer;
    } else {
      console.error("Printer not found");
    }
  } catch (error) {
    console.error("Request failed:", error);
  }
}
```

#### 3. Get All Kitchen Printers
```javascript
async function getKitchenPrinters() {
  try {
    const response = await fetch('/api/printer/location/kitchen');
    const result = await response.json();

    if (result.success) {
      console.log(`Found ${result.count} kitchen printers`);
      result.data.forEach(printer => {
        console.log(`${printer.printer_name}: ${printer.printer_ip}`);
      });
      return result.data;
    }
  } catch (error) {
    console.error("Request failed:", error);
  }
}
```

#### 4. Update Printer Configuration
```javascript
async function updatePrinterConfig(terminalId) {
  const updates = {
    printer_ip: "192.168.1.110",
    printer_name: "Kitchen Printer - New Location"
  };

  try {
    const response = await fetch(`/api/printer/config/${terminalId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updates)
    });

    const result = await response.json();
    if (result.success) {
      console.log("Configuration updated:", result.data);
    }
  } catch (error) {
    console.error("Request failed:", error);
  }
}
```

---

## Database Schema

```sql
CREATE TABLE printer_config (
  id INT PRIMARY KEY AUTO_INCREMENT,
  terminal_id VARCHAR(50) NOT NULL UNIQUE,
  location ENUM('kitchen', 'cashier') NOT NULL,
  printer_ip VARCHAR(20) NOT NULL,
  printer_port INT DEFAULT 9100,
  printer_name VARCHAR(100),
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## Usage Flow

### Setup Phase (Admin/Manager)
1. **Save printer configuration** using `POST /api/printer/config`
2. Store terminal_id, location, printer_ip, and port
3. Verify configuration using `GET /api/printer/config/:terminal_id`

### Runtime Phase (POS/Kiosk)
1. **Retrieve printer details** at application startup
2. Use `GET /api/printer/config/:terminal_id` with the current terminal's ID
3. Store printer IP and port in session/memory
4. Initialize ESC/POS printer connection with retrieved IP and port

### Management Phase (Updates)
1. **Update settings** using `PUT /api/printer/config/:terminal_id`
2. Changes take effect immediately
3. Monitor printer status for connectivity issues

---

## Security Notes
- Validate terminal_id format in frontend
- Ensure IP address is within trusted network range
- Use HTTPS for production deployments
- Implement authentication/authorization for admin endpoints
- Log all printer configuration changes

---

## Support
For API issues or integration questions, refer to the controller implementation in `controllers/printerConfigController.js` or contact the development team.
