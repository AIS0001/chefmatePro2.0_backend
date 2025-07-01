const { validationResult } = require("express-validator");
const bcrypt = require("bcryptjs");
const { db, format } = require("../config/dbconnection");
const jwt = require("jsonwebtoken");
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

    const { uname, pass } = req.body;
    const query = `SELECT * FROM users WHERE uname = ?`;

    const [rows] = await db.query(query, [uname]);

    if (!rows || rows.length === 0) {
      return res.status(401).json({ error: "Invalid Username or Password" });
    }

    const user = rows[0];

    const isMatch = await bcrypt.compare(pass, user.pass);

    if (isMatch) {
      const token = jwt.sign({ id: user.id, type: user.type }, jwt_secret, { expiresIn: "60m" });
      res.status(200).json({ msg: "Login successful", token, data: user });
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


module.exports = {
  register,
  login,
  getuser,
};
