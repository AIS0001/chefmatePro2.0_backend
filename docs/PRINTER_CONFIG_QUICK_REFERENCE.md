# Printer Configuration API - Quick Reference Guide

## 📌 Quick Links
- **Base URL:** `/api/printer`
- **Documentation:** See [PRINTER_CONFIG_API.md](PRINTER_CONFIG_API.md)
- **Database:** `printer_config` table
- **Controller:** `controllers/printerConfigController.js`
- **Routes:** `routes/printerConfigRoutes.js`

---

## 🚀 Essential API Calls

### Initialize Frontend (On App Load)
```javascript
// Get terminal's printer configuration
fetch(`/api/printer/config/${TERMINAL_ID}`)
  .then(r => r.json())
  .then(data => {
    if (data.success) {
      // Use data.data.printer_ip and data.data.printer_port
      initializePrinter(data.data.printer_ip, data.data.printer_port);
    }
  });
```

### Setup Printer (Admin Panel)
```javascript
// Save new printer configuration
fetch('/api/printer/config', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    terminal_id: 'KITCHEN-001',
    location: 'kitchen',
    printer_ip: '192.168.1.100',
    printer_port: 9100,
    printer_name: 'Main Kitchen Printer'
  })
})
.then(r => r.json())
.then(data => console.log(data));
```

### Get All Printers (Admin Dashboard)
```javascript
// Kitchen printers
fetch('/api/printer/location/kitchen')
  .then(r => r.json())
  .then(data => displayPrinters(data.data));

// Cashier printers
fetch('/api/printer/location/cashier')
  .then(r => r.json())
  .then(data => displayPrinters(data.data));
```

### Update Printer (Change IP)
```javascript
fetch(`/api/printer/config/${TERMINAL_ID}`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    printer_ip: '192.168.1.110'
  })
})
.then(r => r.json())
.then(data => console.log('Updated:', data));
```

---

## 📊 Data Structure

### Printer Configuration Object
```javascript
{
  id: 1,                                    // Auto-generated
  terminal_id: "KITCHEN-001",              // Unique identifier
  location: "kitchen",                      // 'kitchen' or 'cashier'
  printer_ip: "192.168.1.100",             // IPv4 address
  printer_port: 9100,                       // ESC/POS default port
  printer_name: "Main Kitchen Printer",    // Friendly name
  status: "active",                         // 'active' or 'inactive'
  created_at: "2026-03-02T10:30:00Z",      // Auto-generated
  updated_at: "2026-03-02T10:30:00Z"       // Auto-updated
}
```

---

## ✅ Response Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - New configuration saved |
| 400 | Bad Request - Invalid parameters |
| 404 | Not Found - Configuration doesn't exist |
| 409 | Conflict - Terminal ID already exists |
| 500 | Server Error |

---

## 🔧 Integration with ESC/POS Printing

### After retrieving printer config:
```javascript
async function setupPrinting(printerConfig) {
  const { printer_ip, printer_port } = printerConfig;
  
  // Connect to network printer
  const printer = new escpos.Network(printer_ip, printer_port);
  
  return printer;
}

// On application start
const printerConfig = await getPrinterConfig(TERMINAL_ID);
const printer = setupPrinting(printerConfig);
```

---

## 🎯 Common Scenarios

### Scenario 1: First Time Setup
1. Admin enters terminal ID, location, printer IP in frontend
2. Frontend calls `POST /api/printer/config`
3. Configuration saved to database
4. POS terminal retrieves config on startup

### Scenario 2: Printer IP Changes
1. Admin updates IP in admin panel
2. Frontend calls `PUT /api/printer/config/{terminal_id}`
3. Database updated immediately
4. POS terminal reconnects with new IP

### Scenario 3: Getting Kitchen Printers
1. Kitchen display system calls `GET /api/printer/location/kitchen`
2. Receives all active kitchen printers
3. Routes orders to correct printer

### Scenario 4: Printer Management
1. View all printers: `GET /api/printer/config`
2. Deactivate printer: `PUT /api/printer/config/{id}` with status='inactive'
3. Reactivate printer: `PUT /api/printer/config/{id}` with status='active'

---

## ⚡ Frontend Component Example

```javascript
// React Hook Example
import { useState, useEffect } from 'react';

function PrinterManager() {
  const [printers, setPrinters] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch all printers on mount
    fetch('/api/printer/config')
      .then(r => r.json())
      .then(data => {
        if (data.success) setPrinters(data.data);
        setLoading(false);
      });
  }, []);

  const updatePrinter = async (terminalId, updates) => {
    const response = await fetch(`/api/printer/config/${terminalId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updates)
    });
    const data = await response.json();
    return data.success;
  };

  return (
    <div>
      {loading ? (
        <p>Loading printers...</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Terminal</th>
              <th>Location</th>
              <th>IP Address</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {printers.map(p => (
              <tr key={p.id}>
                <td>{p.terminal_id}</td>
                <td>{p.location}</td>
                <td>{p.printer_ip}</td>
                <td>{p.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default PrinterManager;
```

---

## 📱 Mobile/Tablet Integration

```javascript
// Get terminal ID from device
const TERMINAL_ID = localStorage.getItem('terminalId') || 'DEFAULT-KITCHEN-001';

// On app initialization
async function initializeApp() {
  try {
    const response = await fetch(`/api/printer/config/${TERMINAL_ID}`);
    const data = await response.json();
    
    if (data.success) {
      // Store printer config in app state
      window.printerConfig = data.data;
      console.log('Printer ready:', data.data.printer_ip);
    } else {
      console.warn('No printer configured for this terminal');
    }
  } catch (error) {
    console.error('Failed to load printer config:', error);
  }
}
```

---

## 🔍 Troubleshooting

### Terminal not found
- Check terminal_id is exact match
- Verify terminal_id exists in database
- Use `GET /api/printer/config` to view all terminals

### Printer IP invalid
- Verify IP address format: 192.168.1.x (not 0-255 guaranteed)
- Check printer is on network and reachable
- Confirm printer port (usually 9100)

### Configuration conflicts
- Each terminal_id must be unique
- Cannot create duplicate terminal_ids
- Delete old config before reusing ID

---

## 📝 Database Queries (Reference)

```sql
-- Create table
CREATE TABLE printer_config (
  id INT PRIMARY KEY AUTO_INCREMENT,
  terminal_id VARCHAR(50) NOT NULL UNIQUE,
  location ENUM('kitchen', 'cashier'),
  printer_ip VARCHAR(20),
  printer_port INT DEFAULT 9100,
  printer_name VARCHAR(100),
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- View all active printers
SELECT * FROM printer_config WHERE status = 'active';

-- View kitchen printers
SELECT * FROM printer_config WHERE location = 'kitchen' AND status = 'active';

-- Get specific terminal
SELECT * FROM printer_config WHERE terminal_id = 'KITCHEN-001';
```

---

## 🎓 Best Practices

1. **Store terminal_id** in local storage or device settings
2. **Cache printer config** at app startup (refresh every 5 mins)
3. **Handle offline mode** - use cached config if api unavailable
4. **Validate IP format** before saving
5. **Test connectivity** before marking printer as active
6. **Log print failures** for debugging
7. **Implement retry logic** for printer connections

---

## 📞 API Summary Table

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/config` | Create new printer config |
| GET | `/config` | Get all active configs |
| GET | `/config/:terminal_id` | Get specific printer |
| GET | `/location/:location` | Get all in location |
| PUT | `/config/:terminal_id` | Update printer settings |
| DELETE | `/config/:terminal_id` | Remove configuration |

