const express = require('express');
const router = express.Router();
const vendingController = require('../controllers/vendingMachineController');

// Public API Routes (no authentication required for testing)

// Test RS485 connection
router.get('/test-connection', vendingController.testRS485Connection);

// Get machine status
router.get('/machine/:machine_id/status', vendingController.getMachineStatus);

// Get machine inventory
router.get('/machine/:machine_id/inventory', vendingController.getInventory);

// Dispense product
router.post('/machine/dispense', vendingController.dispenseProduct);

// Update machine configuration
router.put('/machine/:machine_id/config', vendingController.updateMachineConfig);

// Get transaction history
router.get('/machine/:machine_id/transactions', vendingController.getTransactionHistory);

// Log new transaction (sends price as command to vending machine)
router.post('/transactions/log', vendingController.logTransactionController);

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Vending Machine API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Get all machines
router.get('/machines', async (req, res) => {
  try {
    const { db } = require('../config/dbconnection');
    const query = 'SELECT * FROM vending_machines ORDER BY machine_id';
    const [result] = await db.query(query);
    
    res.json({
      success: true,
      data: result,
      message: 'Machines retrieved successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error retrieving machines',
      error: error.message
    });
  }
});

// Add new machine
router.post('/machines', async (req, res) => {
  try {
    const { machine_id, location, type, configuration } = req.body;
    const { db } = require('../config/dbconnection');
    
    const query = `
      INSERT INTO vending_machines (machine_id, location, type, configuration, status, created_at) 
      VALUES (?, ?, ?, ?, 'offline', NOW())
    `;
    
    await db.query(query, [machine_id, location, type, JSON.stringify(configuration || {})]);
    
    res.json({
      success: true,
      message: 'Machine added successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding machine',
      error: error.message
    });
  }
});

module.exports = router;
