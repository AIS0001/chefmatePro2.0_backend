# Machine/Device MAC Address Authentication System

## 📌 Overview

A comprehensive device-based authentication system that restricts user logins to specific machines/computers based on MAC addresses. This adds an extra layer of security by ensuring that users can only log in from registered devices.

**Key Features:**
- ✅ Register device MAC addresses per user
- ✅ Allow multiple devices per user (configurable)
- ✅ Global MAC address blocking
- ✅ Login attempt logging and audit trail
- ✅ Flexible settings (per-user & global)
- ✅ Device status management
- ✅ ARP-based MAC detection on local networks

---

## 🗂️ Database Tables

### 1. `user_devices`
Stores registered MAC addresses for each user.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| user_id | INT | Reference to users.id |
| mac_address | VARCHAR(17) | Device MAC (XX:XX:XX:XX:XX:XX) |
| device_name | VARCHAR(100) | Friendly name (e.g., "Kitchen-POS-1") |
| device_type | ENUM | desktop, laptop, tablet, mobile, other |
| status | ENUM | active, inactive, blocked |
| last_login_at | TIMESTAMP | Last successful login |
| created_at | TIMESTAMP | Registration date |
| updated_at | TIMESTAMP | Last update |

### 2. `device_auth_settings`
Configuration for MAC authentication (global & per-user).

| Column | Type | Description |
|--------|------|-------------|
| user_id | INT | NULL = global, otherwise user-specific |
| enable_mac_auth | BOOLEAN | Enable/disable MAC checking |
| allow_multiple_devices | BOOLEAN | Allow multiple MAC addresses |
| require_first_device | BOOLEAN | Must use first registered device |
| block_new_devices | BOOLEAN | Block unregistered MACs |
| max_devices_per_user | INT | Max devices allowed (-1 = unlimited) |
| require_admin_approval | BOOLEAN | New devices need approval |
| session_timeout_hours | INT | Session duration |
| allow_device_override | BOOLEAN | User can add own devices |

### 3. `login_attempts`
Audit log of all login attempts.

| Column | Type | Description |
|--------|------|-------------|
| user_id | INT | User attempting login |
| username | VARCHAR(233) | Username used |
| mac_address | VARCHAR(17) | Device MAC |
| ip_address | VARCHAR(45) | Client IP |
| device_name | VARCHAR(100) | Device name |
| status | ENUM | success, failed_invalid_mac, failed_no_mac, failed_blocked_mac, failed_credentials, failed_other |
| error_message | TEXT | Failure reason |
| user_agent | TEXT | Browser info |
| created_at | TIMESTAMP | Attempt time |

### 4. `blocked_mac_addresses`
Global blacklist of suspicious MACs.

| Column | Type | Description |
|--------|------|-------------|
| mac_address | VARCHAR(17) | Blocked MAC address |
| reason | TEXT | Why blocked |
| blocked_by_user_id | INT | Admin who blocked it |
| status | ENUM | active, inactive |
| created_at | TIMESTAMP | Block date |

---

## 🔗 API Endpoints

### Base URL: `/api/device`

#### 1. Register Device for User
```
POST /api/device/register
```

**Request:**
```json
{
  "user_id": 123,
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "device_name": "Kitchen-POS-1",
  "device_type": "desktop"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Device registered successfully",
  "data": {
    "id": 1,
    "user_id": 123,
    "mac_address": "AA:BB:CC:DD:EE:FF",
    "device_name": "Kitchen-POS-1",
    "device_type": "desktop",
    "status": "active",
    "created_at": "2026-03-02T10:30:00Z"
  }
}
```

---

#### 2. Get User's Devices
```
GET /api/device/user/:user_id
```

**Response (200):**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "user_id": 123,
      "mac_address": "AA:BB:CC:DD:EE:FF",
      "device_name": "Kitchen-POS-1",
      "status": "active",
      "last_login_at": "2026-03-02T15:25:00Z",
      "created_at": "2026-03-02T10:30:00Z"
    }
  ]
}
```

---

#### 3. Verify MAC Address (Core Function)
```
POST /api/device/verify-mac
```

**Request:**
```json
{
  "user_id": 123,
  "mac_address": "AA:BB:CC:DD:EE:FF"
}
```

**Response (200):**
```json
{
  "success": true,
  "authorized": true,
  "reason": "MAC address is authorized",
  "device_name": "Kitchen-POS-1",
  "device_id": 1
}
```

**Response (Unauthorized):**
```json
{
  "success": true,
  "authorized": false,
  "reason": "MAC address is not registered for this user"
}
```

---

#### 4. Update Device Status
```
PUT /api/device/:device_id
```

**Request:**
```json
{
  "status": "blocked",
  "device_name": "Compromised Device"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Device updated successfully",
  "data": { ... }
}
```

---

#### 5. Delete Device
```
DELETE /api/device/:device_id
```

**Response (200):**
```json
{
  "success": true,
  "message": "Device deleted successfully"
}
```

---

#### 6. Get Device Auth Settings
```
GET /api/device/settings/:user_id
GET /api/device/settings/global
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user_id": null,
    "enable_mac_auth": true,
    "allow_multiple_devices": true,
    "block_new_devices": false,
    "max_devices_per_user": 3,
    "require_admin_approval": false
  }
}
```

---

#### 7. Update Device Auth Settings
```
PUT /api/device/settings/:user_id
PUT /api/device/settings/global
```

**Request:**
```json
{
  "enable_mac_auth": true,
  "allow_multiple_devices": true,
  "max_devices_per_user": 5
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Settings updated successfully",
  "data": { ... }
}
```

---

#### 8. Block MAC Address Globally
```
POST /api/device/block-mac
```

**Request:**
```json
{
  "mac_address": "FF:FF:FF:FF:FF:FF",
  "reason": "Suspicious activity detected",
  "blocked_by_user_id": 123
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "MAC address blocked successfully",
  "data": { ... }
}
```

---

#### 9. Get Login Attempt Logs
```
GET /api/device/logs/:user_id?limit=50&status=success
GET /api/device/logs?limit=50&status=failed_invalid_mac
```

**Response (200):**
```json
{
  "success": true,
  "count": 15,
  "data": [
    {
      "id": 1,
      "user_id": 123,
      "username": "admin",
      "mac_address": "AA:BB:CC:DD:EE:FF",
      "ip_address": "192.168.1.100",
      "status": "success",
      "created_at": "2026-03-02T15:25:00Z"
    }
  ]
}
```

---

## 💻 Frontend Integration

### 1. Get Client MAC Address (Browser)
On modern browsers, you can't directly get the MAC address due to security restrictions. Options:

**A. Desktop App (Electron):**
```javascript
// In Electron main process
const { execSync } = require('child_process');

function getMacAddress() {
  try {
    if (process.platform === 'win32') {
      const output = execSync('getmac', { encoding: 'utf-8' });
      return output.match(/([0-9A-F]{2}[-:]){5}([0-9A-F]{2})/i)[0];
    } else {
      const output = execSync('ifconfig', { encoding: 'utf-8' });
      return output.match(/([0-9A-F]{2}:){5}([0-9A-F]{2})/i)[0];
    }
  } catch (error) {
    console.error('Error getting MAC:', error);
    return null;
  }
}

// Send to renderer
ipcMain.handle('get-mac', () => getMacAddress());
```

**B. Web Browser (Limited):**
```javascript
// Try to get from WebRTC
async function getClientMac() {
  // This is limited and may not always work
  // Consider using server-side detection instead
}
```

**C. Manual Registration (Recommended for Web):**
```javascript
// User manually enters or confirms their MAC
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
  
  return response.json();
}
```

---

### 2. Verify MAC Before Login
```javascript
async function loginWithMacVerification(username, password, macAddress) {
  // 1. Get user ID from username (first request)
  const userResponse = await fetch('/api/auth/get-user-by-username', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username })
  });

  const { userId } = await userResponse.json();

  // 2. Verify MAC for this user
  const macResponse = await fetch('/api/device/verify-mac', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: userId,
      mac_address: macAddress
    })
  });

  const macResult = await macResponse.json();

  if (!macResult.authorized) {
    console.log('❌ Login denied: ' + macResult.reason);
    return { success: false, message: macResult.reason };
  }

  // 3. Proceed with normal login
  const loginResponse = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username,
      password,
      mac_address: macAddress
    })
  });

  return await loginResponse.json();
}
```

---

### 3. Register New Device (Admin Panel)
```javascript
async function registerNewDevice() {
  const userId = document.getElementById('userId').value;
  const macAddress = document.getElementById('macAddress').value;
  const deviceName = document.getElementById('deviceName').value;

  const response = await fetch('/api/device/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: parseInt(userId),
      mac_address: macAddress,
      device_name: deviceName,
      device_type: 'desktop'
    })
  });

  const result = await response.json();
  
  if (result.success) {
    alert('✅ Device registered successfully!');
    loadUserDevices(userId);
  } else {
    alert('❌ Error: ' + result.message);
  }
}

async function loadUserDevices(userId) {
  const response = await fetch(`/api/device/user/${userId}`);
  const result = await response.json();

  if (result.success) {
    const table = document.getElementById('devicesTable');
    table.innerHTML = result.data.map(device => `
      <tr>
        <td>${device.device_name}</td>
        <td>${device.mac_address}</td>
        <td>${device.status}</td>
        <td>${new Date(device.last_login_at).toLocaleString()}</td>
        <td>
          <button onclick="blockDevice(${device.id})">Block</button>
          <button onclick="deleteDevice(${device.id})">Delete</button>
        </td>
      </tr>
    `).join('');
  }
}
```

---

## ⚙️ Configuration Options

### Global Settings
Enable MAC authentication for all users:

```javascript
// Enable globally
fetch('/api/device/settings/global', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    enable_mac_auth: true,
    allow_multiple_devices: true,
    max_devices_per_user: 3,
    block_new_devices: false
  })
});
```

### Per-User Settings
Different rules for different users:

```javascript
// Strict settings for admin
fetch('/api/device/settings/123', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    enable_mac_auth: true,
    allow_multiple_devices: false,  // Only 1 device
    block_new_devices: true,         // No new devices
    require_admin_approval: true      // Admin must approve
  })
});

// Relaxed settings for cashier
fetch('/api/device/settings/166', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    enable_mac_auth: true,
    allow_multiple_devices: true,
    max_devices_per_user: 5,
    block_new_devices: false
  })
});
```

---

## 🔐 Security Scenarios

### Scenario 1: Restrict Admin to Single Kitchen POS
```
Admin (id=123):
- Only device: Kitchen-POS-1 (AA:BB:CC:DD:EE:FF)
- Settings: allow_multiple_devices = false
- Blocked: Any login from different MAC = DENIED
```

### Scenario 2: Allow Cashier Multiple Device
```
Cashier (id=166):
- Devices:
  1. Cashier-Desk (CC:DD:EE:FF:AA:BB)
  2. Cashier-Tablet (DD:EE:FF:AA:BB:CC)
- Settings: allow_multiple_devices = true, max_devices_per_user = 2
- Can login from both devices
- Third device = DENIED
```

### Scenario 3: Global Block for Compromised Device
```
Blocked MAC: FF:FF:FF:FF:FF:FF
Reason: "Stolen device"
Result: No user can login from this MAC, even if registered
```

### Scenario 4: Dynamic Device Approval
```
New device attempts login:
- Settings: require_admin_approval = true
- Result: Login PENDING approval
- Admin approves via device management
- Next login from same MAC = SUCCESS
```

---

## 🛠️ Integration with Login Controller

Modify your existing login controller to check MAC addresses:

```javascript
// In your existing login function
const { deviceAuthController } = require('../controllers/deviceAuthController');
const { getClientInfo } = require('../helpers/deviceAuthUtils');

const login = async (req, res) => {
  const { username, password, mac_address } = req.body;
  
  // ... existing credential validation ...

  // Get user from database
  const user = await getUserByUsername(username);

  // Check MAC address if enabled
  const settings = await deviceAuthController.getDeviceAuthSettings(user.id);
  
  if (settings && settings.enable_mac_auth) {
    const macVerification = await fetch('http://localhost:4402/api/device/verify-mac', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_id: user.id,
        mac_address: mac_address
      })
    });

    const macResult = await macVerification.json();

    if (!macResult.authorized) {
      // Log failed attempt
      await deviceAuthController.logLoginAttempt(
        user.id,
        username,
        mac_address,
        getClientInfo(req).ip,
        'failed_invalid_mac',
        macResult.reason
      );

      return res.status(403).json({
        success: false,
        message: 'Device not authorized for this user'
      });
    }
  }

  // ... proceed with normal login ...
  
  // Log successful login
  await deviceAuthController.logLoginAttempt(
    user.id,
    username,
    mac_address,
    getClientInfo(req).ip,
    'success',
    null
  );

  return res.json({
    success: true,
    token: generateToken(user),
    user: user
  });
};
```

---

## 📊 Usage Workflow

### Setup Phase (Admin)
1. **Register devices** for each user
   - Kitchen admins register their POS machines
   - Cashiers register their terminals
   - Staff register their tablets

2. **Configure settings**
   - Global: Enable MAC authentication
   - Per-user: Set device limits and restrictions

### Operati Phase
1. **User logs in** with their device (contains MAC)
2. **System verifies**:
   - Is MAC authentication enabled?
   - Is this MAC registered for this user?
   - Is this MAC globally blocked?
   - Have max devices been exceeded?
3. **Login succeeds or fails** based on verification
4. **Audit log** records all attempts

### Maintenance Phase
1. **Monitor** login attempt logs
2. **Block** suspicious MACs
3. **Approve** new devices if needed
4. **Update** device statuses
5. **Review** failed login attempts

---

## 🧪 Testing MAC Verification

```javascript
// Test case 1: Authorized device
fetch('/api/device/verify-mac', {
  method: 'POST',
  body: JSON.stringify({
    user_id: 123,
    mac_address: 'AA:BB:CC:DD:EE:FF'
  })
})
.then(r => r.json())
.then(data => console.log(data.authorized)); // true

// Test case 2: Unauthorized device
fetch('/api/device/verify-mac', {
  method: 'POST',
  body: JSON.stringify({
    user_id: 123,
    mac_address: 'FF:FF:FF:FF:FF:FF'
  })
})
.then(r => r.json())
.then(data => console.log(data.authorized)); // false
```

---

## 📱 Getting MAC Address from Different Devices

### Windows
```bash
getmac
ipconfig /all
```

### macOS
```bash
ifconfig
networksetup -getmacaddress en0
```

### Linux
```bash
ifconfig
ip link show
cat /sys/class/net/eth0/address
```

### Android
```javascript
// Requires special permissions
// Use WifiManager API
```

### iOS
```javascript
// macOS address not accessible, use bundleID instead
```

---

## 🔍 Troubleshooting

### Problem: MAC address validation fails
**Solution:** Ensure format is XX:XX:XX:XX:XX:XX (with colons)

### Problem: ARP lookup not working
**Solution:** 
- Client must be on same local network
- May not work across VPN
- Use manual MAC entry as fallback

### Problem: Too many devices registered
**Solution:** 
- Check max_devices_per_user setting
- Delete unused devices
- Increase limit if needed

### Problem: Device blocked unexpectedly
**Solution:**
- Check blocked_mac_addresses table
- Verify user hasn't changed network
- Unblock or re-register device

---

## 📞 Support

For questions or issues with device authentication:
1. Check login_attempts log for error details
2. Verify device is registered: `GET /api/device/user/{user_id}`
3. Check settings: `GET /api/device/settings/global`
4. Review blocked MACs: Query blocked_mac_addresses table

---

**Created:** March 2, 2026
**System:** ChefMate Pro 2.0
**Feature:** Device/MAC Authentication
