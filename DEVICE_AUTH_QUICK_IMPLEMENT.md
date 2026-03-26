# 🔐 Device Authentication - Quick Implementation Guide

## 🎯 5-Minute Integration with Existing Login

### Step 1: Setup (1 minute)
```bash
node setup-device-auth.js
npm restart
```

### Step 2: Find Your Login Controller
Look for your login endpoint. It's likely in:
- `controllers/userControl.js` or
- `routes/userRoutes.js` or
- `controllers/authController.js`

### Step 3: Add MAC Verification (5 minutes)

**Before (Original Login):**
```javascript
const login = async (req, res) => {
  const { username, password } = req.body;
  
  // Validate credentials
  const user = await db.query("SELECT * FROM users WHERE uname = ?", [username]);
  if (!user.length) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }
  
  // Check password
  const validPassword = await bcrypt.compare(password, user[0].pass);
  if (!validPassword) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }
  
  // Login success
  return res.json({ success: true, user: user[0], token: generateToken(user[0]) });
};
```

**After (With MAC Verification):**
```javascript
const { deviceAuthController } = require("../controllers/deviceAuthController");

const login = async (req, res) => {
  const { username, password, mac_address } = req.body;
  
  // Validate credentials (existing code)
  const [user] = await db.query("SELECT * FROM users WHERE uname = ?", [username]);
  if (!user.length) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }
  
  const validPassword = await bcrypt.compare(password, user[0].pass);
  if (!validPassword) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }
  
  // NEW: Verify MAC address (if provided)
  if (mac_address) {
    // Create a fake request/response for verify-mac controller
    const mockReq = { body: { user_id: user[0].id, mac_address } };
    const mockRes = {
      json: (data) => data,
      status: (code) => ({ json: (data) => data })
    };
    
    const verifyResult = await deviceAuthController.verifyMacAddress(mockReq, mockRes);
    
    if (verifyResult && !verifyResult.authorized) {
      // Log failed attempt
      await deviceAuthController.logLoginAttempt(
        user[0].id,
        username,
        mac_address,
        req.ip || req.connection.remoteAddress,
        'failed_invalid_mac',
        verifyResult.reason
      );
      
      return res.status(403).json({
        success: false,
        message: "Device not authorized for this user",
        details: verifyResult.reason
      });
    }
  }
  
  // Log successful login
  if (mac_address) {
    await deviceAuthController.logLoginAttempt(
      user[0].id,
      username,
      mac_address,
      req.ip || req.connection.remoteAddress,
      'success'
    );
  }
  
  // Login success (existing code)
  return res.json({ 
    success: true, 
    user: user[0], 
    token: generateToken(user[0]) 
  });
};
```

---

## 📱 Frontend: Add MAC to Login Form

**Before:**
```javascript
async function handleLogin(e) {
  e.preventDefault();
  
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  
  const response = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  
  const result = await response.json();
  if (result.success) {
    localStorage.setItem('token', result.token);
    window.location.href = '/dashboard';
  }
}
```

**After (Add MAC):**
```javascript
async function handleLogin(e) {
  e.preventDefault();
  
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  
  // Get MAC address (method depends on your platform)
  let macAddress = null;
  
  // Option 1: If using Electron (Desktop app)
  if (window.ipcRenderer) {
    macAddress = await window.ipcRenderer.invoke('get-mac');
  }
  
  // Option 2: If you have it stored
  else if (localStorage.getItem('deviceMac')) {
    macAddress = localStorage.getItem('deviceMac');
  }
  
  // Option 3: Manual entry (fallback)
  else {
    macAddress = prompt('Enter your device MAC address (or leave blank):');
  }
  
  const response = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ 
      username, 
      password,
      mac_address: macAddress || undefined  // Include if available
    })
  });
  
  const result = await response.json();
  if (result.success) {
    localStorage.setItem('token', result.token);
    localStorage.setItem('deviceMac', macAddress); // Save for next time
    window.location.href = '/dashboard';
  } else if (result.message.includes('Device')) {
    alert('❌ ' + result.message + '\n\nDetails: ' + result.details);
  } else {
    alert('❌ Login failed');
  }
}
```

---

## 🔧 Setup for Desktop/Electron App

**In Electron main process:**
```javascript
const { ipcMain, app } = require('electron');
const { execSync } = require('child_process');

ipcMain.handle('get-mac', () => {
  try {
    const platform = process.platform;
    
    if (platform === 'win32') {
      // Windows
      const output = execSync('getmac', { encoding: 'utf-8' });
      const match = output.match(/([0-9A-F]{2}[-:]){5}([0-9A-F]{2})/i);
      return match ? match[0].toUpperCase().replace(/-/g, ':') : null;
    } else if (platform === 'darwin') {
      // macOS
      const output = execSync('ifconfig', { encoding: 'utf-8' });
      const match = output.match(/([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})/);
      return match ? match[0].toUpperCase() : null;
    } else {
      // Linux
      const output = execSync('/bin/cat /sys/class/net/eth0/address', { encoding: 'utf-8' });
      return output.trim().toUpperCase();
    }
  } catch (error) {
    console.error('Failed to get MAC:', error);
    return null;
  }
});
```

**In Electron renderer process:**
```javascript
async function getMacAndLogin() {
  const mac = await window.ipcRenderer.invoke('get-mac');
  console.log('Device MAC:', mac);
  
  // Proceed with login
  handleLoginWithMac(mac);
}
```

---

## ⚙️ Configuration: Enable MAC Auth

### Option 1: Enable for All Users
```bash
curl -X PUT http://localhost:4402/api/device/settings/global \
  -H "Content-Type: application/json" \
  -d '{
    "enable_mac_auth": true,
    "allow_multiple_devices": true,
    "max_devices_per_user": 3
  }'
```

### Option 2: Enable Only for Admins
```bash
# For user ID 123 (Admin)
curl -X PUT http://localhost:4402/api/device/settings/123 \
  -H "Content-Type: application/json" \
  -d '{
    "enable_mac_auth": true,
    "allow_multiple_devices": false,
    "max_devices_per_user": 1
  }'
```

### Option 3: Keep Disabled (Testing)
```bash
# Default: MAC auth is disabled
# You can test full flow without enforcing
```

---

## 📝 Admin Panel: Device Management

**Create this HTML form:**
```html
<div class="device-management">
  <h2>Device Management</h2>
  
  <!-- Register New Device -->
  <form id="registerDeviceForm">
    <input type="number" id="userId" placeholder="User ID" required>
    <input type="text" id="macAddress" placeholder="MAC (AA:BB:CC:DD:EE:FF)" required>
    <input type="text" id="deviceName" placeholder="Device Name (e.g., Kitchen-POS-1)">
    <select id="deviceType">
      <option value="desktop">Desktop</option>
      <option value="laptop">Laptop</option>
      <option value="tablet">Tablet</option>
      <option value="mobile">Mobile</option>
    </select>
    <button type="submit">Register Device</button>
  </form>
  
  <!-- User's Devices -->
  <table id="devicesTable">
    <thead>
      <tr>
        <th>Device Name</th>
        <th>MAC Address</th>
        <th>Type</th>
        <th>Status</th>
        <th>Last Login</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
</div>

<script>
// Register device
document.getElementById('registerDeviceForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const userId = document.getElementById('userId').value;
  const macAddress = document.getElementById('macAddress').value;
  const deviceName = document.getElementById('deviceName').value;
  const deviceType = document.getElementById('deviceType').value;
  
  const response = await fetch('/api/device/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: parseInt(userId),
      mac_address: macAddress,
      device_name: deviceName,
      device_type: deviceType
    })
  });
  
  const result = await response.json();
  if (result.success) {
    alert('✅ Device registered!');
    loadUserDevices(userId);
    document.getElementById('registerDeviceForm').reset();
  } else {
    alert('❌ Error: ' + result.message);
  }
});

// Load user devices
async function loadUserDevices(userId) {
  const response = await fetch(`/api/device/user/${userId}`);
  const result = await response.json();
  
  const tbody = document.querySelector('#devicesTable tbody');
  tbody.innerHTML = result.data.map(device => `
    <tr>
      <td>${device.device_name || 'Unnamed'}</td>
      <td>${device.mac_address}</td>
      <td>${device.device_type}</td>
      <td>
        <select onchange="updateDeviceStatus(${device.id}, this.value)">
          <option value="active" ${device.status === 'active' ? 'selected' : ''}>Active</option>
          <option value="inactive" ${device.status === 'inactive' ? 'selected' : ''}>Inactive</option>
          <option value="blocked" ${device.status === 'blocked' ? 'selected' : ''}>Blocked</option>
        </select>
      </td>
      <td>${device.last_login_at ? new Date(device.last_login_at).toLocaleString() : 'Never'}</td>
      <td>
        <button onclick="deleteDevice(${device.id})">Delete</button>
      </td>
    </tr>
  `).join('');
}

// Update device status
async function updateDeviceStatus(deviceId, status) {
  const response = await fetch(`/api/device/${deviceId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status })
  });
  
  const result = await response.json();
  if (result.success) {
    console.log('✅ Device status updated');
  }
}

// Delete device
async function deleteDevice(deviceId) {
  if (confirm('Delete this device?')) {
    const response = await fetch(`/api/device/${deviceId}`, {
      method: 'DELETE'
    });
    
    const result = await response.json();
    if (result.success) {
      alert('✅ Device deleted');
      location.reload();
    }
  }
}

// Load on page load
document.getElementById('userId').addEventListener('change', (e) => {
  loadUserDevices(e.target.value);
});
</script>
```

---

## 🧪 Testing the Integration

### Test 1: Register Device
```bash
curl -X POST http://localhost:4402/api/device/register \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "mac_address": "AA:BB:CC:DD:EE:FF",
    "device_name": "Test-Device",
    "device_type": "desktop"
  }'

# Expected: 201 Created
```

### Test 2: Verify MAC (Authorized)
```bash
curl -X POST http://localhost:4402/api/device/verify-mac \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "mac_address": "AA:BB:CC:DD:EE:FF"
  }'

# Expected: { "authorized": true }
```

### Test 3: Verify MAC (Unauthorized)
```bash
curl -X POST http://localhost:4402/api/device/verify-mac \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123,
    "mac_address": "FF:FF:FF:FF:FF:FF"
  }'

# Expected: { "authorized": false }
```

### Test 4: Login with MAC
```bash
curl -X POST http://localhost:4402/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "password123",
    "mac_address": "AA:BB:CC:DD:EE:FF"
  }'

# Expected: { "success": true, "token": "..." }
```

---

## 📋 Checklist for Implementation

- [ ] Run `node setup-device-auth.js`
- [ ] Verify tables created: `SHOW TABLES LIKE 'user_devices'`
- [ ] Test API with CURL (all 4 tests above)
- [ ] Find your login controller
- [ ] Add MAC verification code
- [ ] Update frontend login form to include MAC
- [ ] Register test device
- [ ] Test login with registered MAC (should succeed)
- [ ] Test login with unregistered MAC (should fail if enabled)
- [ ] Create admin device management UI
- [ ] Configure global or per-user settings
- [ ] Train staff on new feature
- [ ] Monitor login_attempts table for issues

---

## ⚠️ If Something Goes Wrong

### "Table device_auth_settings already exists"
**Solution:** That's OK, just means tables already created. Proceed with testing.

### "Verify returns authorized but login still fails"
**Solution:** Make sure your login controller is calling the verify-mac code.

### "Can't get MAC address from frontend"
**Solution:** Use manual entry as fallback, or store MAC during registration.

### "Permission denied" on database
**Solution:** Check DB user has proper permissions or use root user.

---

## 🎓 Final Notes

1. **MAC verification is OPTIONAL** - Users don't need to send MAC to login
2. **You control whether it's enforced** - Set `enable_mac_auth: false` to disable
3. **Start testing, then enable** - Set up and test before enabling globally
4. **Admin panel is separate** - Device management API works independently
5. **Audit logging is automatic** - All attempts logged to login_attempts table

---

**Quick Integration Summary:**
1. Run setup script
2. Add 15 lines to login controller
3. Update frontend login form
4. Test with CURL
5. Create admin UI
6. Deploy

**Estimated time:** 30 minutes end-to-end

For full API reference, see [DEVICE_AUTH_DOCUMENTATION.md](docs/DEVICE_AUTH_DOCUMENTATION.md)
