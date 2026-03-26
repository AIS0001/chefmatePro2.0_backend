# 🔐 Device/MAC Address Authentication System - Complete Guide

## 📋 Quick Summary

A robust machine authentication system that restricts user logins to specific devices based on MAC addresses. This provides:

- ✅ Device-based login control
- ✅ Multiple device support per user (configurable)
- ✅ Global MAC address blacklisting
- ✅ Comprehensive login audit trail
- ✅ Flexible per-user and global settings
- ✅ Device status management (active/inactive/blocked)

---

## 🚀 Quick Start

### 1. Create Database Tables
```bash
node setup-device-auth.js
```

### 2. Restart Server
```bash
npm start
```

### 3. Configure Global Settings
```bash
# Enable MAC authentication globally
curl -X PUT http://localhost:4402/api/device/settings/global \
  -H "Content-Type: application/json" \
  -d '{
    "enable_mac_auth": true,
    "allow_multiple_devices": true,
    "max_devices_per_user": 3
  }'
```

### 4. Register Device for User
```bash
curl -X POST http://localhost:4402/api/device/register \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "mac_address": "AA:BB:CC:DD:EE:FF",
    "device_name": "Kitchen-POS-1",
    "device_type": "desktop"
  }'
```

### 5. Verify MAC During Login
```bash
curl -X POST http://localhost:4402/api/device/verify-mac \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "mac_address": "AA:BB:CC:DD:EE:FF"
  }'
```

---

## 🗂️ What Was Created

### New Database Tables (4)
1. **user_devices** - Device/MAC assignments for users
2. **device_auth_settings** - Configuration settings
3. **login_attempts** - Audit log of all login attempts
4. **blocked_mac_addresses** - Global MAC blacklist

### New Files
1. **controllers/deviceAuthController.js** - Business logic (10 methods)
2. **routes/deviceAuthRoutes.js** - API endpoints (9 routes)
3. **helpers/deviceAuthUtils.js** - Utility functions
4. **database/create_device_auth_tables.sql** - SQL schema
5. **docs/DEVICE_AUTH_DOCUMENTATION.md** - Full API documentation
6. **setup-device-auth.js** - Automated table creation
7. **README_DEVICE_AUTH.md** - This guide

### Modified Files
1. **server.js** - Added device auth routes

---

## 📊 Database Schema Overview

### user_devices Table
Stores MAC addresses for each user.

```
Columns:
- id (PK)
- user_id (FK) → users.id
- mac_address (UNIQUE per user)
- device_name
- device_type (desktop/laptop/tablet/mobile/other)
- status (active/inactive/blocked)
- last_login_at
- created_at, updated_at
```

### device_auth_settings Table
Configures authentication rules.

```
Columns:
- user_id (NULL = global, otherwise user-specific)
- enable_mac_auth (boolean)
- allow_multiple_devices (boolean)
- require_first_device (boolean)
- block_new_devices (boolean)
- max_devices_per_user (int)
- require_admin_approval (boolean)
- session_timeout_hours (int)
- allow_device_override (boolean)
```

### login_attempts Table
Audit trail of all login attempts.

```
Columns:
- user_id, username
- mac_address, ip_address
- device_name
- status (success/failed_invalid_mac/failed_no_mac/failed_blocked_mac/failed_credentials/failed_other)
- error_message
- user_agent
- created_at
```

### blocked_mac_addresses Table
Global blacklist.

```
Columns:
- mac_address (UNIQUE)
- reason (why blocked)
- blocked_by_user_id (which admin)
- status (active/inactive)
- created_at, updated_at
```

---

## 🔗 API Endpoints (9)

### Base URL: `/api/device`

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/register` | Register device for user |
| GET | `/user/:user_id` | Get user's devices |
| POST | `/verify-mac` | **Verify MAC (core function)** |
| PUT | `/:device_id` | Update device status/name |
| DELETE | `/:device_id` | Delete device |
| GET | `/settings/:user_id` | Get auth settings |
| PUT | `/settings/:user_id` | Update auth settings |
| POST | `/block-mac` | Block MAC globally |
| GET | `/logs/:user_id` | Get login attempt logs |

---

## 💻 Usage Examples

### Frontend: Register Device
```javascript
async function registerDevice(userId, macAddress, deviceName) {
  const response = await fetch('/api/device/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: userId,
      mac_address: macAddress,
      device_name: deviceName,
      device_type: 'desktop'
    })
  });
  
  return await response.json();
}

// Usage
registerDevice(123, 'AA:BB:CC:DD:EE:FF', 'Kitchen-POS-1')
  .then(result => {
    if (result.success) {
      console.log('✅ Device registered!');
    } else {
      console.error('❌ Error:', result.message);
    }
  });
```

### Frontend: Verify MAC (Before Login)
```javascript
async function verifyMacForLogin(userId, macAddress) {
  const response = await fetch('/api/device/verify-mac', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: userId,
      mac_address: macAddress
    })
  });
  
  const result = await response.json();
  return result.authorized;
}

// Usage in login flow
async function handleLogin(username, password, userMacAddress) {
  // 1. Get user ID from username
  const user = await getUserByUsername(username);
  
  // 2. Verify MAC
  const authorized = await verifyMacForLogin(user.id, userMacAddress);
  if (!authorized) {
    console.error('❌ Device not authorized');
    return { success: false };
  }
  
  // 3. Proceed with normal login
  return await normalLogin(username, password);
}
```

### Frontend: Get User Devices
```javascript
async function loadUserDevices(userId) {
  const response = await fetch(`/api/device/user/${userId}`);
  const result = await response.json();
  
  if (result.success) {
    console.log(`Found ${result.count} devices:`);
    result.data.forEach(device => {
      console.log(`- ${device.device_name}: ${device.mac_address} (${device.status})`);
    });
  }
}
```

### Frontend: Block Device
```javascript
async function blockDevice(deviceId, reason = '') {
  const response = await fetch(`/api/device/${deviceId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status: 'blocked'
    })
  });
  
  return await response.json();
}
```

### Frontend: Configure Settings
```javascript
// Enable MAC auth for specific user
async function enableMacAuthForUser(userId, maxDevices = 3) {
  const response = await fetch(`/api/device/settings/${userId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      enable_mac_auth: true,
      allow_multiple_devices: true,
      max_devices_per_user: maxDevices
    })
  });
  
  return await response.json();
}

// Strict settings for admin (single device only)
async function setAdminStrict(adminUserId) {
  const response = await fetch(`/api/device/settings/${adminUserId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      enable_mac_auth: true,
      allow_multiple_devices: false,  // Only 1 device
      block_new_devices: true,         // No new devices
      require_admin_approval: true      // Admin must approve
    })
  });
  
  return await response.json();
}
```

### Backend: Check MAC During Login
```javascript
// In your login controller
const { verifyMacAddress } = require('../controllers/deviceAuthController');

const login = async (req, res) => {
  const { username, password, mac_address } = req.body;
  
  // ... validate credentials ...
  
  const user = await getUserByUsername(username);
  
  // Check MAC if enabled
  if (mac_address) {
    const macResult = await verifyMacAddress({
      body: { user_id: user.id, mac_address }
    });
    
    if (!macResult.json().authorized) {
      return res.status(403).json({
        success: false,
        message: 'Device not authorized for this user'
      });
    }
  }
  
  // ... proceed with login ...
};
```

---

## ⚙️ Configuration Scenarios

### Scenario 1: Strict Security (Single Device Admin)
```javascript
// Admin can only login from one specific POS machine
await fetch('/api/device/settings/123', {
  method: 'PUT',
  body: JSON.stringify({
    enable_mac_auth: true,
    allow_multiple_devices: false,      // Only 1 device
    block_new_devices: true,            // Reject new devices
    max_devices_per_user: 1             // Maximum 1
  })
});

// Register their POS machine
await fetch('/api/device/register', {
  method: 'POST',
  body: JSON.stringify({
    user_id: 123,
    mac_address: 'AA:BB:CC:DD:EE:FF',
    device_name: 'Kitchen-POS-1'
  })
});

// Result: Admin can ONLY login from this MAC
```

### Scenario 2: Flexible Access (Multiple Devices)
```javascript
// Cashier can use multiple devices
await fetch('/api/device/settings/166', {
  method: 'PUT',
  body: JSON.stringify({
    enable_mac_auth: true,
    allow_multiple_devices: true,       // Multiple devices OK
    max_devices_per_user: 5,            // Up to 5 devices
    block_new_devices: false            // Accept new devices
  })
});

// Register multiple devices
const devices = [
  { user_id: 166, mac_address: 'AA:AA:AA:AA:AA:AA', device_name: 'Cashier-Desktop' },
  { user_id: 166, mac_address: 'BB:BB:BB:BB:BB:BB', device_name: 'Cashier-Laptop' },
  { user_id: 166, mac_address: 'CC:CC:CC:CC:CC:CC', device_name: 'Cashier-Tablet' }
];

for (const device of devices) {
  await fetch('/api/device/register', {
    method: 'POST',
    body: JSON.stringify(device)
  });
}

// Result: Cashier can login from any of these 3 devices
```

### Scenario 3: Global Blocklist
```javascript
// Block a stolen device globally
await fetch('/api/device/block-mac', {
  method: 'POST',
  body: JSON.stringify({
    mac_address: 'FF:FF:FF:FF:FF:FF',
    reason: 'Stolen tablet - security incident #2026-001',
    blocked_by_user_id: 123
  })
});

// Result: No user can login from this MAC, even if registered
```

### Scenario 4: Disable MAC Auth
```javascript
// For testing or temporary disable
await fetch('/api/device/settings/global', {
  method: 'PUT',
  body: JSON.stringify({
    enable_mac_auth: false  // Disable globally
  })
});

// Result: All users can login regardless of MAC
```

---

## 🔍 Monitoring & Audit

### View Login Attempts
```javascript
// Get all login attempts for user
async function getLoginHistory(userId) {
  const response = await fetch(`/api/device/logs/${userId}?limit=100`);
  const result = await response.json();
  
  return result.data; // Array of login attempts
}

// Get failed login attempts
async function getFailedLogins(userId) {
  const response = await fetch(`/api/device/logs/${userId}?status=failed_invalid_mac`);
  const result = await response.json();
  
  result.data.forEach(attempt => {
    console.log(`${attempt.username} failed from ${attempt.mac_address}: ${attempt.error_message}`);
  });
}
```

### Analyze Login Patterns
```javascript
// Get all system login attempts
async function analyzeSecurity() {
  const response = await fetch('/api/device/logs?limit=1000');
  const result = await response.json();
  
  const stats = {
    total: result.count,
    successful: result.data.filter(l => l.status === 'success').length,
    failedMac: result.data.filter(l => l.status === 'failed_invalid_mac').length,
    failedBlocked: result.data.filter(l => l.status === 'failed_blocked_mac').length,
    failedCredentials: result.data.filter(l => l.status === 'failed_credentials').length
  };
  
  console.log('Security Stats:', stats);
}
```

---

## 🛠️ Getting MAC Addresses from Devices

### Windows
```bash
# Command line
getmac
ipconfig /all

# PowerShell
Get-NetAdapter | Select-Object Name, MacAddress
```

### macOS
```bash
# Terminal
ifconfig
networksetup -getmacaddress en0

# Get all MACs
networksetup -listallhardwareports
```

### Linux
```bash
# View MAC
ifconfig
ip link show
cat /sys/class/net/eth0/address

# Get specific interface
ethtool eth0 | grep "Permanent address"
```

### Mobile (Electron/Mobile App)
```javascript
// Electron main process
const { execSync } = require('child_process');

function getMacAddress() {
  try {
    const output = execSync('getmac', { encoding: 'utf-8' });
    const match = output.match(/([0-9A-F]{2}[-:]){5}([0-9A-F]{2})/i);
    return match ? match[0].toUpperCase() : null;
  } catch {
    return null;
  }
}

// Send to renderer
ipcMain.handle('get-mac', () => getMacAddress());
```

---

## 🔐 Security Best Practices

1. **Admin accounts:** Restrict to single device
2. **Regular staff:** Allow 2-3 devices max
3. **Monitor logs:** Check for suspicious patterns
4. **Block suspicious MACs:** Use global blocklist
5. **Require approval:** For sensitive roles
6. **Rotate passwords:** Combined with MAC auth
7. **Session timeouts:** Set reasonable limits
8. **Audit trails:** Review login_attempts regularly

---

## ❌ Troubleshooting

### Problem: "MAC address is not registered"
**Solution:**
1. Verify MAC format: XX:XX:XX:XX:XX:XX
2. Check device is registered: `GET /api/device/user/{user_id}`
3. Re-register if needed: `POST /api/device/register`

### Problem: "Device not authorized"
**Solution:**
1. Check enable_mac_auth is true
2. Verify MAC matches registration
3. Check device status isn't 'blocked'
4. Check max_devices_per_user limit

### Problem: "Maximum devices exceeded"
**Solution:**
1. Check max_devices_per_user setting
2. Delete unused devices: `DELETE /api/device/{device_id}`
3. Increase limit: `PUT /api/device/settings/{user_id}`

### Problem: "MAC address is globally blocked"
**Solution:**
1. Check blocked_mac_addresses table
2. Contact admin to unblock
3. Or use different device

---

## 📱 Frontend Integration Checklist

- [ ] Add MAC address detecting library (if web app)
- [ ] Create device registration UI
- [ ] Add MAC verification to login flow
- [ ] Display registered devices in user settings
- [ ] Add device management (block/delete)
- [ ] Show login attempt logs
- [ ] Add settings configuration UI (for admins)
- [ ] Test on different devices
- [ ] Handle offline scenarios (cache MAC)

---

## 📞 API Reference Quick Lookup

```bash
# Register device
POST /api/device/register
{ "user_id": 123, "mac_address": "AA:BB:CC:DD:EE:FF", "device_name": "..." }

# Get user devices
GET /api/device/user/123

# Verify MAC
POST /api/device/verify-mac
{ "user_id": 123, "mac_address": "AA:BB:CC:DD:EE:FF" }

# Update device
PUT /api/device/1
{ "status": "blocked" }

# Delete device
DELETE /api/device/1

# Get settings
GET /api/device/settings/123
GET /api/device/settings/global

# Update settings
PUT /api/device/settings/123
{ "enable_mac_auth": true, "max_devices_per_user": 5 }

# Block MAC
POST /api/device/block-mac
{ "mac_address": "FF:FF:FF:FF:FF:FF", "reason": "Stolen" }

# Get logs
GET /api/device/logs/123?limit=50&status=success
```

---

## ✨ Key Features Summary

| Feature | Status | Notes |
|---------|--------|-------|
| MAC address validation | ✅ | XX:XX:XX:XX:XX:XX format |
| Device registration | ✅ | Per-user and global tracking |
| Multiple devices | ✅ | Configurable per user |
| Login verification | ✅ | Before credentials check |
| Global MAC blocking | ✅ | Emergency security |
| Login audit trail | ✅ | All attempts logged |
| Flexible settings | ✅ | Global and per-user |
| Device status | ✅ | active/inactive/blocked |
| Admin controls | ✅ | Full management API |
| ARP lookup | ✅ | Automatic IP→MAC conversion |

---

## 📈 Implementation Timeline

1. **Day 1:** Setup database tables (`node setup-device-auth.js`)
2. **Day 2:** Test API endpoints
3. **Day 3:** Integrate device registration UI
4. **Day 4:** Integrate MAC verification in login
5. **Day 5:** Test end-to-end
6. **Day 6:** Deploy to production
7. **Day 7+:** Monitor logs, fine-tune settings

---

## 🎓 Final Checklist

- [ ] Run setup script
- [ ] Verify all 4 tables created
- [ ] Test all 9 API endpoints
- [ ] Understand verify-mac endpoint (core)
- [ ] Integrate with login controller
- [ ] Test with sample devices
- [ ] Configure global settings
- [ ] Train admin staff
- [ ] Plan user device registration
- [ ] Set up monitoring
- [ ] Deploy to production

---

**Status:** ✅ Complete & Ready for Deployment

**Created:** March 2, 2026  
**System:** ChefMate Pro 2.0  
**Features:** Device/MAC Authentication

For detailed API documentation, see [DEVICE_AUTH_DOCUMENTATION.md](docs/DEVICE_AUTH_DOCUMENTATION.md)
