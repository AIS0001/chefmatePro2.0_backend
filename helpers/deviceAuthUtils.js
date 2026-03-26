/**
 * Device/MAC Address Utilities
 * Functions for MAC address detection, validation, and ARP lookup
 */

const { execSync } = require('child_process');
const os = require('os');

/**
 * Get MAC address from local machine (server-side)
 * Useful for registering server machines
 */
const getLocalMacAddress = () => {
  try {
    const interfaces = os.networkInterfaces();
    
    for (const name of Object.keys(interfaces)) {
      // Skip loopback and virtualbox adapters
      if (name.includes('lo') || name.includes('vbox')) continue;
      
      for (const iface of interfaces[name]) {
        // Skip internal and IPv6
        if (iface.family === 'IPv4' && !iface.internal) {
          return iface.mac;
        }
      }
    }
  } catch (error) {
    console.error("getLocalMacAddress error:", error);
  }
  return null;
};

/**
 * Validate MAC address format
 * Supports XX:XX:XX:XX:XX:XX and XX-XX-XX-XX-XX-XX formats
 */
const isValidMacAddress = (mac) => {
  const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
  return macRegex.test(mac);
};

/**
 * Format MAC address to standard format (XX:XX:XX:XX:XX:XX)
 */
const formatMacAddress = (mac) => {
  if (!mac) return null;
  
  // Remove any hyphens and convert to colons
  let formatted = mac.replace(/-/g, ':').toUpperCase();
  
  // Validate
  if (isValidMacAddress(formatted)) {
    return formatted;
  }
  
  return null;
};

/**
 * Get MAC address from IP using ARP table (Linux/Mac/Windows)
 * Useful if client IP is known
 */
const getMacFromArp = (ipAddress) => {
  try {
    const platform = process.platform;
    let command;
    let pattern;

    if (platform === 'win32') {
      // Windows
      command = `arp -a ${ipAddress}`;
      pattern = /([0-9a-f]{2}-){5}[0-9a-f]{2}/i;
    } else if (platform === 'darwin') {
      // macOS
      command = `arp ${ipAddress}`;
      pattern = /([0-9a-f]{2}:){5}[0-9a-f]{2}/i;
    } else {
      // Linux
      command = `arp -n ${ipAddress}`;
      pattern = /([0-9a-f]{2}:){5}[0-9a-f]{2}/i;
    }

    const result = execSync(command, { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'ignore'] });
    const match = result.match(pattern);
    
    if (match) {
      return formatMacAddress(match[0]);
    }
  } catch (error) {
    console.error("getMacFromArp error:", error.message);
  }
  
  return null;
};

/**
 * Get client IP address from request
 * Handles proxied requests
 */
const getClientIp = (req) => {
  return (
    req.headers['x-forwarded-for']?.split(',')[0].trim() ||
    req.headers['x-forwarded-for'] ||
    req.connection.remoteAddress ||
    req.socket.remoteAddress ||
    req.connection.socket?.remoteAddress
  );
};

/**
 * Get client info (IP and optionally MAC from ARP)
 */
const getClientInfo = (req) => {
  const ip = getClientIp(req);
  
  // Try to get MAC from ARP table if on local network
  let mac = null;
  if (ip && ip.match(/^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])/)) {
    mac = getMacFromArp(ip);
  }

  return {
    ip,
    mac,
    userAgent: req.headers['user-agent'] || null
  };
};

/**
 * Normalize MAC address for comparison
 */
const normalizeMac = (mac) => {
  if (!mac) return null;
  return mac.toUpperCase().replace(/-/g, ':');
};

/**
 * Check if two MAC addresses are the same (handling format differences)
 */
const isSameMac = (mac1, mac2) => {
  return normalizeMac(mac1) === normalizeMac(mac2);
};

/**
 * Generate a device name from MAC and IP
 */
const generateDeviceName = (mac, ip) => {
  if (mac && ip) {
    return `${mac.substring(0, 8)}-${ip.split('.').pop()}`;
  } else if (mac) {
    return `Device-${mac.substring(0, 8)}`;
  } else if (ip) {
    return `IP-${ip.split('.').pop()}`;
  }
  return 'Unknown-Device';
};

module.exports = {
  getLocalMacAddress,
  isValidMacAddress,
  formatMacAddress,
  getMacFromArp,
  getClientIp,
  getClientInfo,
  normalizeMac,
  isSameMac,
  generateDeviceName
};
