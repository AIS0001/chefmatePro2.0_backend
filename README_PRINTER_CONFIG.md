# 🖨️ Printer Configuration Management System

**Complete ESC/POS Printer IP & Terminal Configuration System for ChefMate Pro 2.0**

---

## 📌 Quick Summary

A RESTful API system that manages printer configurations for Kitchen and Cashier terminals. Allows administrators to configure printer IP addresses for specific terminal/machine IDs, and enables POS systems to retrieve printer settings for initialization.

**Key Features:**
- ✅ Store terminal ID → printer IP mappings
- ✅ Support kitchen and cashier locations
- ✅ Network printer IP and port configuration
- ✅ Easy CRUD operations
- ✅ Status management (active/inactive)
- ✅ Comprehensive documentation and examples
- ✅ Full test suite included

---

## 🚀 Quick Start (5 Minutes)

### 1. Create Database Table
```bash
node setup-printer-config.js
```

### 2. Restart Server
```bash
npm start
```

### 3. Test API (Optional)
```bash
node test-printer-config.js
```

### 4. Use in Frontend
```javascript
// Get printer configuration
const response = await fetch('/api/printer/config/KITCHEN-001');
const { data } = await response.json();
console.log(`Printer at: ${data.printer_ip}:${data.printer_port}`);
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [PRINTER_CONFIG_API.md](docs/PRINTER_CONFIG_API.md) | **Complete API Reference** - All endpoints, parameters, responses |
| [PRINTER_CONFIG_QUICK_REFERENCE.md](docs/PRINTER_CONFIG_QUICK_REFERENCE.md) | **Developer Guide** - Common use cases, code examples, React components |
| [PRINTER_CONFIG_VISUAL_GUIDE.md](PRINTER_CONFIG_VISUAL_GUIDE.md) | **Architecture Diagrams** - System flows, data structures, integration points |
| [PRINTER_CONFIG_IMPLEMENTATION.md](PRINTER_CONFIG_IMPLEMENTATION.md) | **Technical Details** - File structure, integration, setup instructions |

---

## 🔗 API Endpoints

### Base URL: `/api/printer`

| Operation | Endpoint | Method | Purpose |
|-----------|----------|--------|---------|
| Create | `/config` | POST | Save new printer configuration |
| Read All | `/config` | GET | Get all active printer configurations |
| Read One | `/config/:terminal_id` | GET | Get specific printer config |
| Read by Location | `/location/:location` | GET | Get all printers in kitchen/cashier |
| Update | `/config/:terminal_id` | PUT | Modify printer settings |
| Delete | `/config/:terminal_id` | DELETE | Remove configuration |

---

## 📊 Data Model

```javascript
{
  id: 1,                              // Auto-generated primary key
  terminal_id: "KITCHEN-001",         // Unique machine identifier
  location: "kitchen",                // Enum: 'kitchen' or 'cashier'
  printer_ip: "192.168.1.100",        // IPv4 address
  printer_port: 9100,                 // ESC/POS default: 9100
  printer_name: "Main Kitchen Printer", // Friendly name
  status: "active",                   // Enum: 'active' or 'inactive'
  created_at: "2026-03-02T10:30:00Z", // Auto timestamp
  updated_at: "2026-03-02T10:30:00Z"  // Auto updated
}
```

---

## 💻 Frontend Integration Examples

### 1️⃣ Admin - Create Printer Config
```javascript
async function savePrinterConfig(formData) {
  const response = await fetch('/api/printer/config', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      terminal_id: formData.terminalId,
      location: formData.location, // 'kitchen' or 'cashier'
      printer_ip: formData.ip,
      printer_port: formData.port || 9100,
      printer_name: formData.name
    })
  });

  const result = await response.json();
  if (result.success) {
    console.log('✅ Printer configured!');
  } else {
    console.error('❌ Error:', result.message);
  }
}
```

### 2️⃣ POS Terminal - Get Printer on Startup
```javascript
async function initializePrinter() {
  const terminalId = localStorage.getItem('terminalId') || 'KITCHEN-001';
  
  const response = await fetch(`/api/printer/config/${terminalId}`);
  const { data } = await response.json();

  if (data) {
    // Use with ESC/POS library
    const printer = new escpos.Network(
      data.printer_ip,
      data.printer_port
    );
    return printer;
  }
}
```

### 3️⃣ Admin Dashboard - List All Printers
```javascript
async function displayAllPrinters() {
  const response = await fetch('/api/printer/config');
  const { data } = await response.json();

  data.forEach(printer => {
    console.log(`${printer.terminal_id}: ${printer.printer_ip}`);
  });
}
```

### 4️⃣ Kitchen Display - Get Kitchen Printers Only
```javascript
async function getKitchenPrinters() {
  const response = await fetch('/api/printer/location/kitchen');
  const { data } = await response.json();
  
  return data; // All active kitchen printers
}
```

### 5️⃣ Admin - Update Printer IP
```javascript
async function updatePrinterIP(terminalId, newIP) {
  const response = await fetch(`/api/printer/config/${terminalId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ printer_ip: newIP })
  });

  const result = await response.json();
  return result.success;
}
```

### 6️⃣ React Component Example
```javascript
import { useState, useEffect } from 'react';

function PrinterManager() {
  const [printers, setPrinters] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/printer/config')
      .then(r => r.json())
      .then(data => {
        if (data.success) setPrinters(data.data);
        setLoading(false);
      });
  }, []);

  const handleDelete = async (terminalId) => {
    await fetch(`/api/printer/config/${terminalId}`, {
      method: 'DELETE'
    });
    setPrinters(p => p.filter(x => x.terminal_id !== terminalId));
  };

  if (loading) return <div>Loading...</div>;

  return (
    <table>
      <thead>
        <tr>
          <th>Terminal</th>
          <th>Location</th>
          <th>IP Address</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {printers.map(p => (
          <tr key={p.id}>
            <td>{p.terminal_id}</td>
            <td>{p.location}</td>
            <td>{p.printer_ip}</td>
            <td>{p.status}</td>
            <td>
              <button onClick={() => handleDelete(p.terminal_id)}>
                Delete
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default PrinterManager;
```

---

## 🔍 Common Scenarios

### Scenario 1: First Time Setup
```
Admin → Admin Panel → "Add Printer"
  ↓ Enters: KITCHEN-001, kitchen, 192.168.1.100, 9100
  ↓ Clicks Save
  ↓ Frontend: POST /api/printer/config
  ↓ Backend: Validates & Inserts into DB
  ↓ Response: 201 Created with config data
  ↓ Admin: Success message shown
```

### Scenario 2: POS Startup
```
POS Terminal → App Starts → Requests Printer Config
  ↓ fetch('/api/printer/config/KITCHEN-001')
  ↓ Backend: Query database by terminal_id
  ↓ Response: 200 OK with {printer_ip, printer_port}
  ↓ App: Initialize ESC/POS with retrieved IP:port
  ↓ Ready: Print commands sent to remote printer
```

### Scenario 3: Printer Relocation
```
Admin → Printer moved to new location with new IP
  ↓ Admin Panel → Edit KITCHEN-001
  ↓ Changes IP to 192.168.1.110
  ↓ Clicks Update
  ↓ Frontend: PUT /api/printer/config/KITCHEN-001
  ↓ Backend: Updates database, sets updated_at
  ↓ Response: 200 OK with new config
  ↓ Next POS startup: Fetches new IP address
```

### Scenario 4: Temporary Disable
```
Admin → Temporarily disable printer for maintenance
  ↓ Admin Panel → Set KITCHEN-001 status to 'inactive'
  ↓ Frontend: PUT /api/printer/config/KITCHEN-001
  ↓         Body: {status: 'inactive'}
  ↓ Backend: Updates status, keeps config data
  ↓ Not returned: In GET /api/printer/location/kitchen queries
  ↓ Later: Set status back to 'active' when ready
```

---

## 📁 File Structure

```
chefmate_backend/
├─ controllers/
│  └─ printerConfigController.js          ✨ NEW
├─ routes/
│  └─ printerConfigRoutes.js              ✨ NEW
├─ database/
│  └─ create_printer_config_table.sql     ✨ NEW
├─ docs/
│  ├─ PRINTER_CONFIG_API.md               ✨ NEW
│  └─ PRINTER_CONFIG_QUICK_REFERENCE.md   ✨ NEW
├─ server.js                              ✏️ MODIFIED
├─ setup-printer-config.js                ✨ NEW
├─ test-printer-config.js                 ✨ NEW
├─ PRINTER_CONFIG_IMPLEMENTATION.md       ✨ NEW
├─ PRINTER_CONFIG_VISUAL_GUIDE.md         ✨ NEW
└─ README_PRINTER_CONFIG.md               ✨ NEW (this file)
```

---

## 🧪 Testing

### Run Complete Test Suite
```bash
node test-printer-config.js
```

### Tests Included (18 total)
- ✅ Create valid printer config
- ✅ Create cashier printer
- ✅ Reject duplicate terminal_id
- ✅ Reject missing fields
- ✅ Reject invalid IP format
- ✅ Reject invalid location
- ✅ Get specific printer
- ✅ Return 404 for non-existent
- ✅ Get all printers
- ✅ Get by location - kitchen
- ✅ Get by location - cashier
- ✅ Reject invalid location filter
- ✅ Update printer IP
- ✅ Update printer name
- ✅ Update status
- ✅ Return 404 on update non-existent
- ✅ Delete printer
- ✅ Return 404 on delete non-existent

**Expected Result:** All 18 tests pass ✨

---

## ⚙️ Configuration

### Database Table
- **Name:** `printer_config`
- **Engine:** InnoDB
- **Charset:** UTF8MB4
- **Collation:** UTF8MB4_unicode_ci

### Default Values
- **printer_port:** 9100 (ESC/POS standard)
- **status:** 'active' (when created)

### Constraints
- **terminal_id:** UNIQUE (no duplicates)
- **location:** ENUM ('kitchen', 'cashier')
- **status:** ENUM ('active', 'inactive')

---

## 🔐 Security Features

✅ **Input Validation**
- IP address format validation
- Location enum validation
- Terminal ID uniqueness check
- Field requirement validation

✅ **SQL Injection Prevention**
- Parameterized queries
- Prepared statements
- Framework protection

✅ **CORS Enabled**
- Cross-origin requests allowed
- Configurable origins
- Safe header transmission

✅ **Error Handling**
- Proper HTTP status codes
- No sensitive data exposure
- Comprehensive error messages

---

## 🛠️ Troubleshooting

### Q: Table not created
**A:** Run `node setup-printer-config.js` and verify MySQL connection

### Q: Cannot find printer config
**A:** Verify terminal_id is exact match (case-sensitive)

### Q: Invalid IP error
**A:** Use IPv4 format: 192.168.1.100 (4 numbers 0-255 separated by dots)

### Q: Duplicate terminal_id error
**A:** terminal_id must be unique. Delete old config or use different ID

### Q: CORS errors
**A:** Check server.js CORS configuration and allowed origins

### Q: Printer not printing
**A:** Verify IP is correct, printer is on network, port is 9100

---

## 📖 Integration with Existing Systems

### with printController.js
```javascript
// Get printer config
const config = await fetch(`/api/printer/config/${terminalId}`);
const { printer_ip, printer_port } = config.data;

// Initialize printer (in printController)
const device = new escpos.Network(printer_ip, printer_port);
```

### with Order Management
```javascript
// Route order based on location
const location = order.location; // 'kitchen' or 'cashier'

const printers = await fetch(`/api/printer/location/${location}`);
printers.data.forEach(printer => {
  // Send order to printer
  printOrder(printer.printer_ip, printer.printer_port, order);
});
```

### with Database Connection
```javascript
// Already uses existing connection
const { db } = require("../config/dbconnection");

// All queries use this pool
const [rows] = await db.query(sql, params);
```

---

## 📞 Support Resources

**Documentation:**
- Full API: `docs/PRINTER_CONFIG_API.md`
- Quick Ref: `docs/PRINTER_CONFIG_QUICK_REFERENCE.md`
- Visual Guide: `PRINTER_CONFIG_VISUAL_GUIDE.md`
- Implementation: `PRINTER_CONFIG_IMPLEMENTATION.md`

**Code Files:**
- Controller: `controllers/printerConfigController.js`
- Routes: `routes/printerConfigRoutes.js`
- SQL: `database/create_printer_config_table.sql`

**Testing:**
- Test Suite: `test-printer-config.js`
- Setup: `setup-printer-config.js`

---

## ✨ Key Highlights

🎯 **Complete Solution**
- Database table ready
- RESTful API implemented
- Frontend examples provided
- Documentation comprehensive
- Tests included

🚀 **Production Ready**
- Proper error handling
- Input validation
- CORS configured
- Indexed queries
- Timestamp tracking

📱 **Easy Integration**
- Simple REST API
- Compatible with frontend
- Works with ESC/POS libs
- Existing DB connection reused
- No dependencies added

👷 **Developer Friendly**
- Clean code structure
- Well-documented
- Examples for all scenarios
- Test suite provided
- Visual guides included

---

## 🎓 Next Steps

1. ✅ Run setup script to create table
2. ✅ Verify table creation in MySQL
3. ✅ Test API endpoints (use test suite)
4. ✅ Integrate into admin panel UI
5. ✅ Add printer config screen
6. ✅ Integrate into POS app
7. ✅ Test end-to-end printing
8. ✅ Monitor in production

---

## 📝 Version Info

- **Version:** 1.0.0
- **Created:** March 2, 2026
- **System:** ChefMate Pro 2.0
- **Backend:** Node.js + Express + MySQL
- **API Style:** RESTful
- **Status:** ✅ Production Ready

---

## 📌 Quick Reference Commands

```bash
# Setup database
node setup-printer-config.js

# Run tests
node test-printer-config.js

# Start server
npm start

# Restart server
npm restart
```

---

## 🔗 Related Files

- Server Entry: `server.js`
- DB Config: `config/dbconnection.js`
- Print Controller: `controllers/printController.js`
- Existing Routes: `routes/*.js`

---

**Complete printer configuration system ready for production use.** 🎉

For detailed information, see the comprehensive documentation in the `docs/` folder.
For visual architecture, see `PRINTER_CONFIG_VISUAL_GUIDE.md`.
For implementation details, see `PRINTER_CONFIG_IMPLEMENTATION.md`.
