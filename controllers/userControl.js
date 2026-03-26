const { validationResult } = require("express-validator");
const bcrypt = require("bcryptjs");
const { db, format } = require("../config/dbconnection");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const jwt_secret = process.env.JWT_SECRET || "setupnewkey";

// REGISTER
const register = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { name, contact, email, type, lastloggedin, pass } = req.body;
  const userid = Math.floor(Math.random() * (99999 - 1000) + 1000);

  try {
    // Check for existing user
    const [existingUsers] = await db.execute(
      `SELECT * FROM users WHERE LOWER(email) = LOWER(?)`,
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({ msg: "This user is already registered" });
    }

    // Hash password
    const hashedPass = await bcrypt.hash(pass, 10);

    // Insert user
    const [insertResult] = await db.execute(
      `INSERT INTO users (name, uname, contact, pass, type, email, last_loggedin)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [name, userid, contact, hashedPass, type, email, lastloggedin]
    );

    res.status(201).json({ msg: "User registered successfully", userId: insertResult.insertId });

  } catch (err) {
    console.error("Register error:", err);
    res.status(500).json({ msg: "Server error", error: err });
  }
};

// LOGIN
const login = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { uname, pass, mac_address, device_name } = req.body;
    const query = `SELECT u.*, s.name AS shop_name FROM users u LEFT JOIN shops s ON u.shop_id = s.id WHERE u.uname = ?`;

    const [rows] = await db.query(query, [uname]);

    if (!rows || rows.length === 0) {
      return res.status(401).json({ error: "Invalid Username or Password" });
    }

    const user = rows[0];

    const isMatch = await bcrypt.compare(pass, user.pass);

    if (isMatch) {
      // ✅ Check if user_uuid is NULL (first time login)
      if (!user.user_uuid) {
        // Generate a new UUID
        const newUuid = crypto.randomUUID();
        
        // Update the user record with the new UUID
        await db.execute(
          `UPDATE users SET user_uuid = ? WHERE id = ?`,
          [newUuid, user.id]
        );
        
        // Update the user object with the new UUID
        user.user_uuid = newUuid;
        
        console.log(`✅ Generated UUID for user ${user.uname}: ${newUuid}`);
      }

      // 🔐 DEVICE AUTHENTICATION CHECK
      // ✅ BYPASS only for admin users
      const isAdmin = user.type === 'admin';
      
      if (!isAdmin && user.user_uuid && mac_address) {
        // Check if user has any registered devices
        const [registeredDevices] = await db.query(
          `SELECT * FROM user_devices WHERE user_id = ? AND status = 'active'`,
          [user.id]
        );

        if (registeredDevices.length === 0) {
          // First time login: AUTO-REGISTER the device
          try {
            await db.execute(
              `INSERT INTO user_devices (user_id, mac_address, device_name, device_type, status) 
               VALUES (?, ?, ?, ?, 'active')`,
              [user.id, mac_address, device_name || `Device - ${user.name}`, 'desktop']
            );
            console.log(`✅ Device auto-registered for user ${user.uname}: ${mac_address}`);
          } catch (deviceError) {
            console.error("Device registration error:", deviceError);
            return res.status(500).json({ 
              error: "Failed to register device. Please try again." 
            });
          }
        } else {
          // Subsequent logins: VERIFY device is registered
          const [authorizedDevice] = await db.query(
            `SELECT id FROM user_devices WHERE user_id = ? AND mac_address = ? AND status = 'active'`,
            [user.id, mac_address]
          );

          if (authorizedDevice.length === 0) {
            // Device not registered for this user
            return res.status(403).json({ 
              error: "❌ Wrong Device login. Try to login with same device user login first time.",
              code: "DEVICE_MISMATCH"
            });
          }
        }
      } else if (isAdmin) {
        console.log(`✅ Admin user ${user.uname} - Device verification bypassed`);
      } else if (user.user_uuid && !mac_address) {
        console.warn(`⚠️ Login attempt without device MAC for user ${user.uname}`);
      }

      const token = jwt.sign({ id: user.id, type: user.type, shop_id: user.shop_id }, jwt_secret, { expiresIn: "60m" });
      
      // Add bypass flags for admin users
      const response = { 
        msg: "Login successful", 
        token, 
        data: user
      };

      // If user is admin, bypass MAC verification
      if (isAdmin) {
        response.skip_mac_verification = true;
        response.bypass_device_auth = true;
      }

      res.status(200).json(response);
    } else {
      res.status(401).json({ error: "Invalid Password" });
    }
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};


// GET USER BY TOKEN
const getuser = async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: "Authorization header missing" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, jwt_secret); // Ensure jwt_secret is defined properly
    const [rows] = await db.query(`SELECT * FROM users WHERE id = ?`, [decoded.id]);

    res.status(200).json({
      success: true,
      data: rows,
      message: "User fetched successfully",
    });
  } catch (err) {
    console.error("Error verifying token or querying DB:", err);
    return res.status(403).json({ error: "Invalid token or DB error" });
  }
};

// GET ALL USERS WITH UUID
const getUsersWithUuid = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, name, uname, email, type, status, user_uuid, last_loggedin
       FROM users
       WHERE user_uuid IS NOT NULL AND user_uuid <> ''
       ORDER BY id ASC`
    );

    return res.status(200).json({
      success: true,
      count: rows.length,
      data: rows,
      message: "Users with UUID fetched successfully"
    });
  } catch (err) {
    console.error("getUsersWithUuid error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch users with UUID"
    });
  }
};

// DELETE/CLEAR UUID FOR PARTICULAR USER
const clearUserUuid = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || Number.isNaN(Number(id))) {
      return res.status(400).json({
        success: false,
        message: "Valid user id is required"
      });
    }

    const [users] = await db.query(
      `SELECT id, uname, name, user_uuid FROM users WHERE id = ? LIMIT 1`,
      [id]
    );

    if (!users || users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    const currentUser = users[0];

    if (!currentUser.user_uuid) {
      return res.status(200).json({
        success: true,
        message: "User UUID already empty",
        data: {
          id: currentUser.id,
          uname: currentUser.uname,
          user_uuid: null
        }
      });
    }

    await db.query(`UPDATE users SET user_uuid = NULL WHERE id = ?`, [id]);

    return res.status(200).json({
      success: true,
      message: "User UUID cleared successfully",
      data: {
        id: currentUser.id,
        uname: currentUser.uname,
        cleared_uuid: currentUser.user_uuid
      }
    });
  } catch (err) {
    console.error("clearUserUuid error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to clear user UUID"
    });
  }
};


module.exports = {
  register,
  login,
  getuser,
  getUsersWithUuid,
  clearUserUuid,
};
