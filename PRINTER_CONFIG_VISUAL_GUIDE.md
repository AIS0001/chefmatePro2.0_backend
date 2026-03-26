# Printer Configuration System - Visual Architecture & Flow Guide

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FRONTEND APPLICATIONS                       │
├──────────────────────┬──────────────────────┬───────────────────┤
│   Admin Dashboard    │   POS Terminal       │   Mobile Tablet   │
│  (Setup & Manage)    │  (Print Operations)  │  (Queue Display)  │
└──────────┬───────────┴──────────┬───────────┴──────────┬────────┘
           │                      │                      │
           │ HTTP REST Calls      │ HTTP REST Calls      │ HTTP REST Calls
           │                      │                      │
           └──────────┬───────────┴──────────┬───────────┘
                      │                      │
        ┌─────────────▼──────────────────────▼──────────┐
        │     Express.js Server                         │
        │  (Port: 4402 / API: /api/printer)             │
        │                                                │
        │  ┌────────────────────────────────────────┐   │
        │  │  printerConfigRoutes.js                │   │
        │  │  ┌────────────────────────────────┐   │   │
        │  │  │ POST   /config                 │   │   │
        │  │  │ GET    /config                 │   │   │
        │  │  │ GET    /config/:terminal_id    │   │   │
        │  │  │ GET    /location/:location     │   │   │
        │  │  │ PUT    /config/:terminal_id    │   │   │
        │  │  │ DELETE /config/:terminal_id    │   │   │
        │  │  └────────────────────────────────┘   │   │
        │  └────────────────────────────────────────┘   │
        │                    │                           │
        │  ┌────────────────▼────────────────────────┐  │
        │  │ printerConfigController.js             │  │
        │  │ ├─ savePrinterConfig()                 │  │
        │  │ ├─ getPrinterDetails()                 │  │
        │  │ ├─ getPrintersByLocation()             │  │
        │  │ ├─ getAllPrinterConfigs()              │  │
        │  │ ├─ updatePrinterDetails()              │  │
        │  │ └─ deletePrinterConfig()               │  │
        │  └────────────────┬───────────────────────┘  │
        │                   │                           │
        └───────────────────┼───────────────────────────┘
                            │
                ┌───────────▼──────────┐
                │   MySQL Database     │
                │  ┌────────────────┐  │
                │  │ printer_config │  │
                │  │ - id           │  │
                │  │ - terminal_id  │  │
                │  │ - location     │  │
                │  │ - printer_ip   │  │
                │  │ - printer_port │  │
                │  │ - printer_name │  │
                │  │ - status       │  │
                │  │ - created_at   │  │
                │  │ - updated_at   │  │
                │  └────────────────┘  │
                └────────────────────────┘
```

---

## 🔄 Request/Response Flow

### Flow 1: Admin Creates New Printer Config
```
┌─────────────┐
│   ADMIN UI  │
│   (Page)    │
└──────┬──────┘
       │
       │ User fills form:
       │ - Terminal ID: KITCHEN-001
       │ - Location: Kitchen
       │ - IP: 192.168.1.100
       │ - Port: 9100
       │
       ▼
┌──────────────────────────────┐
│ POST /api/printer/config     │
│ Content-Type: application/json
│ {                            │
│   "terminal_id": "KITCHEN-001"
│   "location": "kitchen"      │
│   "printer_ip": "192.168.1.100"
│   "printer_port": 9100       │
│   "printer_name": "..."      │
│ }                            │
└────────────┬─────────────────┘
             │
             ▼
    ┌────────────────────┐
    │ Server Validates   │
    │ - IP format        │
    │ - Location enum    │
    │ - Required fields  │
    │ - Duplicate ID?    │
    └────────┬───────────┘
             │
             ├─ Valid ──────────┐
             │                  │
             ▼                  ▼
        ┌─────────────┐   ┌───────────┐
        │ Insert DB   │   │ 400 Error │
        └────┬────────┘   └───────────┘
             │
             ▼
    ┌────────────────────────┐
    │ 201 Created Response   │
    │ {                      │
    │   "success": true,     │
    │   "data": {            │
    │     "id": 1,           │
    │     "terminal_id": ...,│
    │     "status": "active" │
    │   }                    │
    │ }                      │
    └────────────────────────┘
             │
             ▼
    ┌────────────────────┐
    │   Admin Success    │
    │   Message Shown    │
    └────────────────────┘
```

### Flow 2: POS Terminal Retrieves Printer Config
```
┌─────────────────────┐
│  POS APP STARTUP    │
└──────┬──────────────┘
       │
       │ Get stored Terminal ID
       │ (from device settings or env)
       │
       ▼
┌────────────────────────────────┐
│ GET /api/printer/config/KITCHEN-001
└────────┬──────────────────────┘
         │
         ▼
  ┌──────────────────┐
  │  Query Database  │
  │  WHERE           │
  │  terminal_id = ? │
  └────────┬─────────┘
           │
           ├─ Found ───────────┐
           │                   │
           ▼                   ▼
    ┌────────────────┐   ┌──────────┐
    │ 200 OK         │   │ 404 Error│
    │ Return Data    │   │ Not Found│
    └────┬───────────┘   └──────────┘
         │
         ▼
    ┌─────────────────────────┐
    │ {                       │
    │   "success": true,      │
    │   "data": {             │
    │     "printer_ip": "192.168.1.100",
    │     "printer_port": 9100│
    │     "status": "active"  │
    │   }                     │
    │ }                       │
    └────────┬────────────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ Initialize ESC/POS       │
    │ new escpos.Network(      │
    │   "192.168.1.100",9100)  │
    └──────────────────────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ POS System Ready         │
    │ (Can now print)          │
    └──────────────────────────┘
```

### Flow 3: Admin Updates Printer IP
```
┌──────────────────────┐
│  ADMIN UI            │
│  View Printer List   │
└──────┬───────────────┘
       │
       │ Click Edit on KITCHEN-001
       │ Change IP to 192.168.1.110
       │
       ▼
┌──────────────────────────────────┐
│ PUT /api/printer/config/KITCHEN-001
│ {                                │
│   "printer_ip": "192.168.1.110"  │
│ }                                │
└────────┬─────────────────────────┘
         │
         ▼
  ┌──────────────────────────┐
  │ Validation               │
  │ - IP format valid?       │
  │ - Terminal exists?       │
  └────────┬─────────────────┘
           │
           ├─ Valid ───────────┐
           │                   │
           ▼                   ▼
    ┌─────────────────┐  ┌──────────────┐
    │ UPDATE printer_ip │  │ 400/404 Error│
    │ WHERE terminal_id │  └──────────────┘
    │ SET updated_at   │
    │ = NOW()          │
    └────────┬────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ 200 OK Response          │
    │ Return updated printer   │
    │ with new IP address      │
    └────────┬─────────────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ Success Message          │
    │ "Printer Updated"        │
    │ Display new IP           │
    └──────────────────────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ Next POS App Startup     │
    │ Will fetch new IP        │
    │ Connects to new address  │
    └──────────────────────────┘
```

---

## 🔀 Data Flow Diagram

```
                    CLIENTS
                      │
        ┌─────────────┼─────────────┐
        │             │             │
      Admin         Kitchen        Cashier
    Dashboard      Display          POS
        │             │             │
        │ Setup        │ Print       │ Print
        │              │            │
        └──────────────┼────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │   REST API Endpoints     │
        │  (/api/printer/...)      │
        └──────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
         ▼             ▼             ▼
      CREATE        READ          UPDATE
      (POST)        (GET)          (PUT)
         │             │             │
         └─────────────┼─────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │  Business Logic          │
        │  (Validation & Rules)    │
        └──────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │   Database Layer         │
        │   (SQL Queries)          │
        └──────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │   MySQL Database         │
        │   printer_config table   │
        └──────────────────────────┘
```

---

## 📊 Database Relationship Diagram

```
printer_config
┌────────────────────────────────────────┐
│ PK  id (int)                           │
│     terminal_id (varchar, UNIQUE)      │
│     location (enum)                    │
│        ├─ kitchen                      │
│        └─ cashier                      │
│     printer_ip (varchar)               │
│     printer_port (int, default: 9100)  │
│     printer_name (varchar, nullable)   │
│     status (enum)                      │
│        ├─ active                       │
│        └─ inactive                     │
│     created_at (timestamp)             │
│     updated_at (timestamp)             │
│                                        │
│ Indexes:                               │
│  - PRIMARY KEY (id)                    │
│  - UNIQUE (terminal_id)                │
│  - INDEX (location)                    │
│  - INDEX (status)                      │
└────────────────────────────────────────┘
```

---

## 🔗 API Endpoint Tree

```
/api/printer/
├── config
│   ├── [POST] Create new printer
│   │   Request: {terminal_id, location, printer_ip, printer_port}
│   │   Response: 201 Created
│   │
│   ├── [GET] Get all active printers
│   │   Response: 200 OK with array
│   │
│   ├── /:terminal_id
│   │   ├── [GET] Get specific printer
│   │   │   Response: 200 OK with object
│   │   │
│   │   ├── [PUT] Update printer settings
│   │   │   Request: {printer_ip?, printer_port?, status?}
│   │   │   Response: 200 OK with updated object
│   │   │
│   │   └── [DELETE] Delete printer config
│   │       Response: 200 OK
│   │
│   └── location
│       └── /:location
│           ├── [GET] Get all kitchen printers (if kitchen)
│           └── [GET] Get all cashier printers (if cashier)
│               Response: 200 OK with array
```

---

## 🔐 Validation Pipeline

```
Request Data Coming In
        │
        ▼
┌─────────────────────────┐
│ Required Fields Check   │
│ - terminal_id          │
│ - location             │
│ - printer_ip           │
└────┬────────────────────┘
     │
     ├─ Missing? → 400 Bad Request
     │
     ▼
┌─────────────────────────┐
│ Format Validation       │
│ IP: xxx.xxx.xxx.xxx    │
│ Location: enum check   │
│ Port: number range     │
└────┬────────────────────┘
     │
     ├─ Invalid? → 400 Bad Request
     │
     ▼
┌─────────────────────────┐
│ Business Logic Check    │
│ - Duplicate terminal_id?│
│ - Record exists?        │
│ - Status valid?         │
└────┬────────────────────┘
     │
     ├─ Conflict? → 409 Conflict
     ├─ Not Found? → 404 Not Found
     │
     ▼
┌─────────────────────────┐
│ Proceed with Operation  │
└──────────┬──────────────┘
           │
           ▼
      Database Query
           │
           ▼
      Return Response
```

---

## 📱 Usage Examples by Role

### Admin/Manager Workflow
```
1. LOG IN TO ADMIN DASHBOARD
   ↓
2. NAVIGATE TO PRINTER SETTINGS
   ↓
3. ADD NEW PRINTER
   ├─ Terminal ID: KITCHEN-001
   ├─ Location: Kitchen
   ├─ Printer IP: 192.168.1.100
   └─ Port: 9100
   ↓
4. SAVE (POST to API)
   ↓
5. CONFIRM SUCCESS
   ↓
6. PRINTER READY FOR USE
```

### POS Terminal Workflow
```
1. POWER ON POS TERMINAL
   ↓
2. APP STARTS UP
   ↓
3. RETRIEVE PRINTER CONFIG
   (GET /api/printer/config/KITCHEN-001)
   ↓
4. INITIALIZE PRINTER CONNECTION
   (IP: 192.168.1.100, Port: 9100)
   ↓
5. AWAIT PRINT REQUESTS
   ↓
6. ON PRINT REQUEST:
   ├─ Format data
   ├─ Connect to printer IP
   ├─ Send ESC/POS commands
   └─ Print receipt
```

### Mobile Tablet (Kitchen Display) Workflow
```
1. OPEN KITCHEN DISPLAY APP
   ↓
2. GET ALL KITCHEN PRINTERS
   (GET /api/printer/location/kitchen)
   ↓
3. DISPLAY ACTIVE ORDERS
   ├─ Route to KITCHEN-001
   ├─ Route to KITCHEN-002
   └─ Route to KITCHEN-003
   ↓
4. SEND ORDERS TO RESPECTIVE PRINTERS
```

---

## 🎯 Location-Based Routing

```
Order Management System
        │
        ├─ Check location in order
        │
        ├─ If location = "kitchen"
        │  └─ GET /api/printer/location/kitchen
        │     └─ Get all active kitchen printers
        │        └─ Route order to KITCHEN-001, KITCHEN-002, etc.
        │
        └─ If location = "cashier"
           └─ GET /api/printer/location/cashier
              └─ Get all active cashier printers
                 └─ Route receipt to CASHIER-001
```

---

## ⚙️ System States & Transitions

```
                    ┌─────────────┐
                    │   NO CONFIG │
                    └────────┬────┘
                             │
                    POST /api/printer/config
                             │
                             ▼
                    ┌─────────────────┐
                    │  ACTIVE CONFIG  │
                    │  (Ready to use)  │
                    └────────┬────────┘
                      ▲      │      ▼
                      │      │  PUT status=inactive
                      │      │      │
                      │      │      ▼
                      │      │   ┌──────────────┐
                      │      │   │  INACTIVE    │
                      │      │   │  (Paused)    │
                      │      │   └──────┬───────┘
                      │      │          │
                      └──────┴──────────┘
                             │
                     DELETE /api/printer/config
                             │
                             ▼
                    ┌─────────────┐
                    │  NO CONFIG  │
                    │  (Removed)   │
                    └─────────────┘
```

---

## 💾 Data Persistence

```
USER ACTION
    │
    ▼
REQUEST TO API
    │
    ▼
VALIDATE DATA
    │
    ├─ Invalid? → Return Error (200 ms)
    │
    ▼ Valid
    │
SERIALIZE TO SQL
    │
    ▼
INSERT/UPDATE/DELETE IN DATABASE
    │
    ├─ ON DISK: Data written to MySQL
    │├─ Binary log entry created
    │├─ Replication (if enabled)
    │└─ Backup ready
    │
    ▼
RETURN SUCCESS RESPONSE
    │
    ▼
FRONTEND UPDATED
    │
    ▼
DATA PERSISTENT (Survives app restart)
```

---

## 🔄 Integration Points

```
External Systems that can use Printer Config:

┌────────────────────────────────────────────┐
│  ESC/POS Print Controller                  │
│  (controllers/printController.js)           │
│  Uses: printer_ip, printer_port from config│
└────────────────┬───────────────────────────┘
                 │
                 ├─ Fetch from printer config
                 ├─ Connect to network printer
                 └─ Send ESC/POS commands

┌────────────────────────────────────────────┐
│  Order Management System                   │
│  Routes orders based on location           │
│  Uses: location field from config          │
└────────────────┬───────────────────────────┘
                 │
                 ├─ Get printers by location
                 ├─ Distribute orders
                 └─ Track print status

┌────────────────────────────────────────────┐
│  Dashboard Analytics                       │
│  Monitors printer availability             │
│  Uses: status and updated_at fields        │
└────────────────┬───────────────────────────┘
                 │
                 ├─ List all printer statuses
                 ├─ Track uptime
                 └─ Alert on issues
```

---

## 🎓 Legend

```
→   Process flow
├   Branch point
│   Continuous flow
✓   Successful operation
✗   Failed operation
⚠   Warning/validation needed
```

---

**This visual guide complements the detailed API documentation.**
**See PRINTER_CONFIG_API.md for complete endpoint specifications.**
**See PRINTER_CONFIG_QUICK_REFERENCE.md for code examples.**
