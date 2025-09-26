const { db } = require('../config/dbconnection');
const { SerialPort } = require('serialport');
const { ReadlineParser } = require('@serialport/parser-readline');

// RS485/USB Configuration for Vending Machine
let rs485Port = null;
const RS485_CONFIG = {
  path: process.env.VENDING_USB_PORT || 'COM5', // USB port for vending machine
  baudRate: parseInt(process.env.VENDING_BAUD_RATE) || 9600,
  dataBits: 8,
  parity: 'none',
  stopBits: 1,
  flowControl: false,
  autoOpen: false, // We'll open it manually for better error handling
  forcePort: process.env.FORCE_VENDING_PORT || 'true' // Force use of configured port
};

// Auto-detect available USB/Serial ports
const detectAvailablePorts = async () => {
  try {
    console.log('🔍 DEBUG: Starting port detection...');
    const ports = await SerialPort.list();
    console.log('🔍 DEBUG: Total ports found:', ports.length);
    console.log('📋 Available serial ports:');
    
    ports.forEach((port, index) => {
      console.log(`  ${index + 1}. 📍 Port: ${port.path}`);
      console.log(`     🏭 Manufacturer: ${port.manufacturer || 'Unknown'}`);
      console.log(`     🔌 Vendor ID: ${port.vendorId || 'N/A'}`);
      console.log(`     📦 Product ID: ${port.productId || 'N/A'}`);
      console.log(`     📝 Serial Number: ${port.serialNumber || 'N/A'}`);
      console.log(`     📍 Location ID: ${port.locationId || 'N/A'}`);
      console.log('     ────────────────────────────');
    });
    
    // Look for common USB-to-Serial adapters or vending machine identifiers
    const vendingPorts = ports.filter(port => 
      port.path.includes('COM') || 
      port.path.includes('ttyUSB') || 
      port.path.includes('ttyACM') ||
      (port.manufacturer && port.manufacturer.toLowerCase().includes('ftdi')) ||
      (port.manufacturer && port.manufacturer.toLowerCase().includes('prolific'))
    );
    
    console.log('🔍 DEBUG: Filtered vending machine compatible ports:', vendingPorts.length);
    
    if (vendingPorts.length > 0) {
      console.log('✅ Potential vending machine ports found:');
      vendingPorts.forEach((port, index) => {
        console.log(`  ${index + 1}. ${port.path} - ${port.manufacturer || 'Unknown'}`);
      });
      console.log(`🎯 DEBUG: Selected port: ${vendingPorts[0].path}`);
      return vendingPorts[0].path; // Return first suitable port
    }
    
    console.log(`⚠️ DEBUG: No compatible ports found, using fallback: ${RS485_CONFIG.path}`);
    return RS485_CONFIG.path; // Fallback to configured port
  } catch (error) {
    console.error('❌ DEBUG: Error detecting ports:', error.message);
    console.error('❌ DEBUG: Stack trace:', error.stack);
    return RS485_CONFIG.path;
  }
};

// Add a helper function to find processes using COM ports (Windows specific)
const findProcessesUsingPort = async (portPath) => {
  try {
    if (process.platform === 'win32') {
      const { exec } = require('child_process');
      return new Promise((resolve) => {
        exec('wmic process get processid,commandline /format:csv', (error, stdout) => {
          if (error) {
            console.log('❌ Could not check processes using ports');
            resolve([]);
            return;
          }
          
          const processes = stdout.split('\n')
            .filter(line => line.includes(portPath) || line.toLowerCase().includes('com5'))
            .map(line => line.split(',').slice(1).join(',').trim())
            .filter(line => line.length > 0);
          
          resolve(processes);
        });
      });
    }
    return [];
  } catch (error) {
    console.log('❌ Error checking processes:', error.message);
    return [];
  }
};

// Check if a port is available (not in use)
const checkPortAvailability = async (portPath) => {
  try {
    console.log(`🔍 DEBUG: Checking availability of port ${portPath}...`);
    
    // Skip check if port is already open
    if (rs485Port && rs485Port.isOpen && rs485Port.path === portPath) {
      console.log(`✅ DEBUG: Port ${portPath} is already open, skipping availability check`);
      return true;
    }
    
    // Try to open and immediately close the port
    const testPort = new SerialPort({ path: portPath, baudRate: 9600, autoOpen: false });
    
    return new Promise(async (resolve) => {
      testPort.open(async (err) => {
        if (err) {
          console.log(`❌ DEBUG: Port ${portPath} is NOT available:`, err.message);
          
          // Try to find what's using the port
          console.log(`🔍 DEBUG: Searching for processes using ${portPath}...`);
          const processes = await findProcessesUsingPort(portPath);
          if (processes.length > 0) {
            console.log(`🚨 DEBUG: Found processes that might be using ${portPath}:`);
            processes.forEach((proc, i) => {
              console.log(`   ${i + 1}. ${proc}`);
            });
          } else {
            console.log(`🤷 DEBUG: No obvious processes found using ${portPath}`);
            console.log(`💡 DEBUG: Port might be locked by Windows or device drivers`);
          }
          
          resolve(false);
        } else {
          console.log(`✅ DEBUG: Port ${portPath} is available`);
          testPort.close(() => {
            resolve(true);
          });
        }
      });
    });
  } catch (error) {
    console.log(`❌ DEBUG: Error checking port ${portPath}:`, error.message);
    return false;
  }
};

// Initialize RS485/USB connection
const initializeRS485 = async () => {
  try {
    // If port is already open, no need to reinitialize
    if (rs485Port && rs485Port.isOpen) {
      console.log(`✅ DEBUG: RS485 port already open on ${rs485Port.path}, skipping initialization`);
      return true;
    }
    
    // If port exists but is closed, clean it up first
    if (rs485Port && !rs485Port.isOpen) {
      console.log('🧹 DEBUG: Cleaning up closed port reference');
      try {
        rs485Port.destroy();
      } catch (destroyError) {
        console.log('⚠️ DEBUG: Error destroying port:', destroyError.message);
      }
      rs485Port = null;
      await new Promise(resolve => setTimeout(resolve, 1000)); // Wait for cleanup
    }
    
    let selectedPort = RS485_CONFIG.path; // Start with configured port (COM5)
    
    console.log(`🔍 DEBUG: Configured port: ${RS485_CONFIG.path}`);
    
    // Check if configured port is available (not in use)
    const isConfiguredPortAvailable = await checkPortAvailability(RS485_CONFIG.path);
    
    if (isConfiguredPortAvailable) {
      selectedPort = RS485_CONFIG.path;
      console.log(`✅ DEBUG: Using configured port (available): ${selectedPort}`);
    } else {
      console.log(`❌ DEBUG: Configured port ${RS485_CONFIG.path} is in use or unavailable`);
      
      // Check if we should force the configured port anyway
      if (RS485_CONFIG.forcePort === 'true') {
        selectedPort = RS485_CONFIG.path;
        console.log(`⚠️ DEBUG: Forcing configured port despite unavailability: ${selectedPort}`);
      } else {
        // Fall back to auto-detection
        console.log(`🔍 DEBUG: Attempting auto-detection...`);
        const detectedPort = await detectAvailablePorts();
        
        // Check if detected port is available
        const isDetectedPortAvailable = await checkPortAvailability(detectedPort);
        
        if (isDetectedPortAvailable) {
          selectedPort = detectedPort;
          console.log(`✅ DEBUG: Using auto-detected available port: ${selectedPort}`);
        } else {
          console.log(`❌ DEBUG: Auto-detected port ${detectedPort} is also unavailable`);
          console.log(`⚠️ DEBUG: Will attempt to use configured port anyway: ${RS485_CONFIG.path}`);
          selectedPort = RS485_CONFIG.path;
        }
      }
    }
    
    const portConfig = { ...RS485_CONFIG, path: selectedPort };
    
    console.log(`🔌 DEBUG: Final port configuration:`, portConfig);
    console.log(`Attempting to connect to vending machine on port: ${portConfig.path}`);
    
    // Create new port instance
    rs485Port = new SerialPort(portConfig);
    const parser = rs485Port.pipe(new ReadlineParser({ delimiter: '\r\n' }));
    
    // Return a promise that resolves when port is opened
    return new Promise((resolve) => {
      // Open the port manually
      rs485Port.open((err) => {
        if (err) {
          console.error('❌ Failed to open USB port:', err.message);
          console.error('❌ Error code:', err.errno || 'N/A');
          
          // Specific error handling
          if (err.message.includes('Access denied') || err.message.includes('EACCES')) {
            console.error('🚨 PORT ACCESS DENIED - Possible causes:');
            console.error('   1. Another application is using COM5 (Arduino IDE, PuTTY, etc.)');
            console.error('   2. Windows has locked the port');
            console.error('   3. Permission issues');
            console.error('   4. Device driver conflict');
            console.error('💡 Solutions:');
            console.error('   - Close any other applications using COM5');
            console.error('   - Run Node.js as Administrator');
            console.error('   - Check Device Manager for port conflicts');
            console.error('   - Restart the computer if port is stuck');
          } else if (err.message.includes('File not found') || err.message.includes('ENOENT')) {
            console.error('🚨 PORT NOT FOUND - COM5 does not exist');
            console.error('💡 Check Device Manager to verify the correct port number');
          }
          
          rs485Port = null; // Reset on error
          resolve(false);
          return;
        }
        console.log(`✅ USB/RS485 Connection opened successfully on ${portConfig.path}`);
        console.log(`📊 Port settings: ${portConfig.baudRate} baud, ${portConfig.dataBits}N${portConfig.stopBits}`);
        resolve(true);
      });
      
      rs485Port.on('error', (err) => {
        console.error('❌ USB/RS485 Connection error:', err.message);
        // Don't auto-reconnect since we close after each command
        console.log('ℹ️ Port will be reopened when next command is sent');
      });
      
      rs485Port.on('close', () => {
        console.log('⚠️ USB/RS485 Connection closed');
      });
      
      parser.on('data', (data) => {
        console.log('📨 USB Data received from vending machine:', data);
        handleRS485Response(data);
      });
    });
    
  } catch (error) {
    console.error('❌ Failed to initialize USB/RS485:', error.message);
    rs485Port = null; // Reset on error
    return false;
  }
};

// Handle USB/RS485 responses from vending machine
const handleRS485Response = (data) => {
  try {
    // Log raw data for debugging
    console.log('🔍 Raw vending machine response:', data);
    
    // Filter out problematic partial responses
    if (data === '.{"a' || data.startsWith('.{"a') || data.length < 3) {
      console.log('⚠️ Ignoring partial/invalid response:', data);
      return; // Don't process or log partial responses
    }
    
    // Try to parse as JSON first
    let response;
    try {
      response = JSON.parse(data);
      console.log('📦 Parsed vending machine response:', response);
      
      // Only log meaningful responses (not just acknowledgments)
      if (response.transaction_id || response.action) {
        logRS485Command('RESPONSE', JSON.stringify(response), 'received');
      }
    } catch (parseError) {
      // If not JSON, treat as plain text command response
      console.log('📝 Plain text response:', data);
      response = { raw_data: data, timestamp: new Date().toISOString() };
      
      // Only log if it's a meaningful response (not just noise)
      if (data.length > 5 && !data.startsWith('.{')) {
        logRS485Command('RESPONSE', data, 'received');
      }
    }
    
    // Store transaction in database if needed
    if (response.transaction_id) {
      logTransaction(response);
    }
    
    // Handle different response types
    if (response.action) {
      switch (response.action) {
        case 'STATUS_RESPONSE':
          updateMachineStatus(response);
          break;
        case 'INVENTORY_RESPONSE':
          updateInventoryData(response);
          break;
        case 'DISPENSE_COMPLETE':
          handleDispenseComplete(response);
          break;
        case 'ERROR':
          handleMachineError(response);
          break;
        default:
          console.log('🤷 Unknown response action:', response.action);
      }
    }
  } catch (error) {
    console.error('❌ Error handling vending machine response:', error.message);
    console.log('🔍 Raw data that caused error:', data);
  }
};

// Update machine status in database
const updateMachineStatus = async (statusData) => {
  try {
    const query = `
      UPDATE vending_machines 
      SET status = ?, last_heartbeat = NOW(), configuration = ?
      WHERE machine_id = ?
    `;
    
    await db.query(query, [
      statusData.status || 'online',
      JSON.stringify(statusData.config || {}),
      statusData.machine_id
    ]);
    
    console.log('✅ Machine status updated for:', statusData.machine_id);
  } catch (error) {
    console.error('❌ Error updating machine status:', error.message);
  }
};

// Handle dispense completion
const handleDispenseComplete = async (response) => {
  try {
    // Update transaction status
    const query = `
      UPDATE vending_transactions 
      SET status = ?, completed_at = NOW()
      WHERE transaction_id = ?
    `;
    
    await db.query(query, ['completed', response.transaction_id]);
    console.log('✅ Dispense completed for transaction:', response.transaction_id);
  } catch (error) {
    console.error('❌ Error updating dispense status:', error.message);
  }
};

// Handle machine errors
const handleMachineError = async (errorData) => {
  console.error('🚨 Vending machine error:', errorData);
  

};

// Send command to vending machine via USB/RS485
const sendRS485Command = (command, timeout = 5000) => {
  return new Promise(async (resolve, reject) => {
    // Initialize connection if not available or closed
    if (!rs485Port || !rs485Port.isOpen) {
      console.log('🔄 RS485 port not open, initializing connection...');
      
      // If port exists but is closed, wait a bit for it to fully close
      if (rs485Port && !rs485Port.isOpen) {
        console.log('⏳ Waiting for port to fully close before reopening...');
        await new Promise(resolve => setTimeout(resolve, 2000));
        rs485Port = null; // Reset port reference
      }
      
      const initialized = await initializeRS485();
      if (!initialized) {
        reject(new Error('Failed to initialize USB/RS485 connection'));
        return;
      }
      
      // Wait longer for port to be fully ready
      console.log('⏳ Waiting for port to be fully ready...');
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Double check port is actually open and ready
      if (!rs485Port || !rs485Port.isOpen) {
        reject(new Error('Port failed to open properly'));
        return;
      }
    }
    
    // Convert command to appropriate format for vending machine
    let commandToSend;
    
    if (typeof command === 'number' || (typeof command === 'string' && !isNaN(command))) {
      // Send numeric commands as string with terminator (not as raw bytes)
      const intCommand = parseInt(command);
      commandToSend = intCommand.toString() + '\r\n'; // Send as string with line terminator
      console.log('📤 Sending integer command to vending machine as string:', intCommand);
    } else if (typeof command === 'object') {
      // For internal system commands, keep as JSON but simplified
      const commandWithId = {
        action: command.action,
        data: command.data || command.product_id || command.machine_id,
        id: `${Date.now()}`
      };
      commandToSend = JSON.stringify(commandWithId) + '\r\n';
      console.log('📤 Sending JSON command to vending machine:', commandWithId);
    } else {
      // For string commands, send as-is
      commandToSend = command.toString() + '\r\n';
      console.log('📤 Sending string command to vending machine:', command.toString());
    }
    
    // Set up timeout
    const timeoutId = setTimeout(() => {
      reject(new Error(`Command timeout after ${timeout}ms`));
    }, timeout);
    
    rs485Port.write(commandToSend, (err) => {
      clearTimeout(timeoutId);
      
      if (err) {
        console.error('❌ Error sending command:', err.message);
        reject(err);
      } else {
        console.log('✅ Command sent successfully '+commandToSend);
        
        // Log only the command being sent (not responses)
        const logCommand = commandToSend.toString().replace('\r\n', '');
        
        // Log the command to database only once
        logRS485Command(logCommand, null, 'sent');
        
        // Wait longer before closing to allow machine to respond properly
        setTimeout(() => {
          if (rs485Port && rs485Port.isOpen) {
            rs485Port.close((closeErr) => {
              if (closeErr) {
                console.log('⚠️ Warning: Error closing RS485 port:', closeErr.message);
              } else {
                console.log('🔐 RS485 connection closed after command sent');
              }
              rs485Port = null; // Clear reference after closing
            });
          }
        }, 2000); // Increased to 2 seconds to allow proper response
        
        resolve(Date.now().toString()); // Return timestamp as ID
      }
    });
  });
};

// Log RS485 communication
const logRS485Command = async (command, response, status) => {
  try {
    const query = `
      INSERT INTO rs485_logs (machine_id, command_sent, response_received, status, created_at)
      VALUES (?, ?, ?, ?, NOW())
    `;
    
    await db.query(query, [
      'SYSTEM', // Default machine ID
      command,
      response || null,
      status
    ]);
  } catch (error) {
    console.error('❌ Error logging RS485 command:', error.message);
  }
};

// Log transaction to database
const logTransaction = async (transactionData) => {
  try {
    const query = `
      INSERT INTO vending_transactions 
      (machine_id, product_id, quantity, amount, transaction_id, status, created_at) 
      VALUES (?, ?, ?, ?, ?, ?, NOW())
    `;
    
    await db.query(query, [
      transactionData.machine_id,
      transactionData.product_id,
      transactionData.quantity,
      transactionData.amount,
      transactionData.transaction_id,
      transactionData.status
    ]);
    
    console.log('Transaction logged successfully');
  } catch (error) {
    console.error('Error logging transaction:', error.message);
  }
};

// Public API Controllers

// Get machine status
const getMachineStatus = async (req, res) => {
  try {
    const { machine_id } = req.params;
    
    // console.log('🔍 DEBUG: getMachineStatus API called');
    // console.log('🔍 DEBUG: Machine ID:', machine_id);
    // console.log('🔍 DEBUG: Current RS485 port status:', rs485Port ? (rs485Port.isOpen ? 'OPEN' : 'CLOSED') : 'NOT_INITIALIZED');
    // console.log('🔍 DEBUG: RS485 port path:', rs485Port ? rs485Port.path : 'N/A');
    
    if (rs485Port && rs485Port.isOpen) {
      // console.log('🔍 DEBUG: Port settings:');
      // console.log(`  - Baud Rate: ${rs485Port.baudRate}`);
      // console.log(`  - Data Bits: ${rs485Port.dataBits}`);
      // console.log(`  - Stop Bits: ${rs485Port.stopBits}`);
      // console.log(`  - Parity: ${rs485Port.parity}`);
    }
    
    // Send status request to vending machine
    const command = JSON.stringify({
      action: 'GET_STATUS',
      machine_id: machine_id
    });
    
    console.log('📤 DEBUG: Sending command to vending machine:', command);
   // await sendRS485Command(command);
    
    // Get last known status from database
    const query = 'SELECT * FROM vending_machines WHERE machine_id = ?';
    const [result] = await db.query(query, [machine_id]);
    
    console.log('🔍 DEBUG: Database query result:', result.length > 0 ? 'Found' : 'Not found');
    
    res.json({
      success: true,
      data: result[0] || null,
      message: 'Status request sent to machine',
      debug: {
        port_connected: rs485Port ? rs485Port.isOpen : false,
        port_path: rs485Port ? rs485Port.path : null,
        command_sent: command
      }
    });
  } catch (error) {
    console.error('❌ DEBUG: Error getting machine status:', error.message);
    console.error('❌ DEBUG: Stack trace:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error getting machine status',
      error: error.message,
      debug: {
        port_connected: rs485Port ? rs485Port.isOpen : false,
        port_path: rs485Port ? rs485Port.path : null
      }
    });
  }
};

// Dispense product
const dispenseProduct = async (req, res) => {
  try {
    const { machine_id, product_id, quantity = 1 } = req.body;
    
    if (!machine_id || !product_id) {
      return res.status(400).json({
        success: false,
        message: 'machine_id and product_id are required'
      });
    }
    
    // Generate transaction ID
    const transaction_id = `TXN_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Send simple integer command to vending machine (product_id as integer)
    const integerCommand = parseInt(product_id) || product_id;
    
    await sendRS485Command(integerCommand);
    
    // Log transaction in database
    try {
      const query = `
        INSERT INTO vending_transactions 
        (machine_id, product_id, quantity, transaction_id, status, created_at) 
        VALUES (?, ?, ?, ?, 'pending', NOW())
      `;
      
      await db.query(query, [
        machine_id,
        product_id,
        quantity,
        transaction_id
      ]);
      
      console.log('Transaction logged successfully');
    } catch (dbError) {
      console.error('Error logging transaction:', dbError.message);
    }
    
    res.json({
      success: true,
      transaction_id: transaction_id,
      command_sent: integerCommand,
      message: 'Dispense command sent to machine'
    });
  } catch (error) {
    console.error('Error dispensing product:', error);
    res.status(500).json({
      success: false,
      message: 'Error dispensing product',
      error: error.message
    });
  }
};

// Get product inventory
const getInventory = async (req, res) => {
  try {
    const { machine_id } = req.params;
    
    // Send inventory request to vending machine
    const command = JSON.stringify({
      action: 'GET_INVENTORY',
      machine_id: machine_id
    });
    
    await sendRS485Command(command);
    
    // Get inventory from database
    const query = `
      SELECT vm.machine_id, vm.location, vi.product_id, vi.product_name, 
             vi.quantity, vi.price, vi.last_updated
      FROM vending_machines vm
      LEFT JOIN vending_inventory vi ON vm.machine_id = vi.machine_id
      WHERE vm.machine_id = ?
    `;
    
    const [result] = await db.query(query, [machine_id]);
    
    res.json({
      success: true,
      data: result,
      message: 'Inventory data retrieved'
    });
  } catch (error) {
    console.error('Error getting inventory:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting inventory',
      error: error.message
    });
  }
};

// Update machine configuration
const updateMachineConfig = async (req, res) => {
  try {
    const { machine_id } = req.params;
    const configData = req.body;
    
    // Send config update to vending machine
    const command = JSON.stringify({
      action: 'UPDATE_CONFIG',
      machine_id: machine_id,
      config: configData
    });
    
    await sendRS485Command(command);
    
    // Update database
    const query = `
      UPDATE vending_machines 
      SET configuration = ?, updated_at = NOW() 
      WHERE machine_id = ?
    `;
    
    await db.query(query, [JSON.stringify(configData), machine_id]);
    
    res.json({
      success: true,
      message: 'Configuration update sent to machine'
    });
  } catch (error) {
    console.error('Error updating machine config:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating machine config',
      error: error.message
    });
  }
};

// Get transaction history
const getTransactionHistory = async (req, res) => {
  try {
    const { machine_id } = req.params;
    const { limit = 50, offset = 0 } = req.query;
    
    const query = `
      SELECT * FROM vending_transactions 
      WHERE machine_id = ? 
      ORDER BY created_at DESC 
      LIMIT ? OFFSET ?
    `;
    
    const [result] = await db.query(query, [machine_id, parseInt(limit), parseInt(offset)]);
    
    res.json({
      success: true,
      data: result,
      message: 'Transaction history retrieved'
    });
  } catch (error) {
    console.error('Error getting transaction history:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting transaction history',
      error: error.message
    });
  }
};

// Test RS485 connection
const testRS485Connection = async (req, res) => {
  try {
    console.log('🔍 DEBUG: testRS485Connection API called');
    console.log('🔍 DEBUG: Current time:', new Date().toISOString());
    console.log('🔍 DEBUG: Environment variables:');
    console.log(`  - VENDING_USB_PORT: ${process.env.VENDING_USB_PORT || 'Not set'}`);
    console.log(`  - VENDING_BAUD_RATE: ${process.env.VENDING_BAUD_RATE || 'Not set'}`);
    
    console.log('🔍 DEBUG: Current RS485_CONFIG:', RS485_CONFIG);
    
    // Check current port status
    if (rs485Port) {
      console.log('🔍 DEBUG: Existing port found:');
      console.log(`  - Path: ${rs485Port.path}`);
      console.log(`  - Open: ${rs485Port.isOpen}`);
      console.log(`  - Readable: ${rs485Port.readable}`);
      console.log(`  - Writable: ${rs485Port.writable}`);
    } else {
      console.log('🔍 DEBUG: No existing port found');
    }
    
    console.log('🔄 DEBUG: Initializing RS485 connection...');
    const isConnected = await initializeRS485();
    
    console.log('🔍 DEBUG: Connection result:', isConnected);
    
    if (isConnected) {
      console.log('✅ DEBUG: Connection successful, sending test command...');
      
      // Send test command
      const testCommand = JSON.stringify({
        action: 'PING',
        timestamp: new Date().toISOString(),
        test_id: `TEST_${Date.now()}`
      });
      
      console.log('📤 DEBUG: Test command:', testCommand);
      
      try {
       // const commandId = await sendRS485Command(testCommand);
        console.log('✅ DEBUG: Test command sent successfully with ID:', commandId);
      } catch (commandError) {
        console.error('❌ DEBUG: Failed to send test command:', commandError.message);
      }
      
      // Get detailed port information
      const portDetails = rs485Port ? {
        path: rs485Port.path,
        baudRate: rs485Port.baudRate,
        dataBits: rs485Port.dataBits,
        stopBits: rs485Port.stopBits,
        parity: rs485Port.parity,
        isOpen: rs485Port.isOpen,
        readable: rs485Port.readable,
        writable: rs485Port.writable
      } : null;
      
      console.log('🔍 DEBUG: Final port details:', portDetails);
      
      res.json({
        success: true,
        message: 'RS485 connection test successful',
        port_config: RS485_CONFIG,
        port_details: portDetails,
        test_command_sent: testCommand,
        debug: {
          connection_time: new Date().toISOString(),
          port_detection_completed: true,
          command_sent: true
        }
      });
    } else {
      console.error('❌ DEBUG: Connection failed');
      res.status(500).json({
        success: false,
        message: 'Failed to establish RS485 connection',
        port_config: RS485_CONFIG,
        debug: {
          connection_time: new Date().toISOString(),
          port_detection_completed: false,
          error: 'Connection initialization failed'
        }
      });
    }
  } catch (error) {
    console.error('❌ DEBUG: Error testing RS485:', error.message);
    console.error('❌ DEBUG: Stack trace:', error.stack);
    res.status(500).json({
      success: false,
      message: 'RS485 connection test failed',
      error: error.message,
      port_config: RS485_CONFIG,
      debug: {
        connection_time: new Date().toISOString(),
        error_details: error.stack
      }
    });
  }
};

// Initialize USB/RS485 connection on startup
setTimeout(async () => {
  console.log('🚀 Starting vending machine USB/RS485 initialization...');
  await initializeRS485();
}, 3000); // Wait 3 seconds for system to be ready

// Log transaction controller (API endpoint)
const logTransactionController = async (req, res) => {
  try {
    const { machine_id, product_id, quantity = 1, amount, user_id, payment_method = 'cash' } = req.body;
    
    if (!machine_id || !product_id || !amount) {
      return res.status(400).json({
        success: false,
        message: 'machine_id, product_id and amount are required'
      });
    }

    // Generate transaction ID
    const transaction_id = `TXN_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Prepare transaction data
    const transactionData = {
      machine_id,
      product_id,
      quantity,
      amount: parseFloat(amount),
      transaction_id,
      status: 'pending'
    };
    
    // Use existing logTransaction function to insert data
    await logTransaction(transactionData);
    
    // After inserting, get the price from vending_transactions table
    let product_price;
    try {
      const transactionQuery = 'SELECT amount FROM vending_transactions WHERE transaction_id = ?';
      const [transactionResult] = await db.query(transactionQuery, [transaction_id]);
      
      if (transactionResult.length > 0) {
        product_price = transactionResult[0].amount;
        console.log(`💰 Retrieved price from vending_transactions table: ${product_price}`);
      } else {
        product_price = parseInt(amount);
        console.log(`💰 Using provided amount as fallback: ${product_price}`);
      }
    } catch (dbError) {
      console.log('Could not fetch price from vending_transactions:', dbError.message);
      product_price = parseInt(amount);
    }
    
    // Convert price to integer command for vending machine
    let priceCommand;
    if (product_price) {
      // Convert price to integer (remove decimal point: 2.50 -> 250, 3.00 -> 300)
      priceCommand = Math.round(parseFloat(product_price));
    } else {
      // Fallback to product_id conversion if no price
      if (typeof product_id === 'string' && product_id.match(/\d+/)) {
        priceCommand = 10;
      } else if (!isNaN(product_id)) {
        priceCommand = parseInt(product_id);
      } else {
        priceCommand = 20; // Default value
      }
    }
    
    console.log(`💰 Price from vending_transactions: ${product_price} -> Integer command: ${priceCommand}`);
    
    try {
      await sendRS485Command(priceCommand);
      console.log(`✅ Price command ${priceCommand} sent to vending machine`);
    } catch (commandError) {
      console.error('❌ Failed to send price command to vending machine:', commandError.message);
    }
    
    res.json({
      success: true,
      data: {
        transaction_id,
        machine_id,
        product_id,
        quantity,
        amount: product_price,
        user_id,
        payment_method,
        price_command_sent: priceCommand
      },
      message: 'Transaction logged and price command sent to machine'
    });
    
  } catch (error) {
    console.error('Error in logTransactionController:', error);
    res.status(500).json({
      success: false,
      message: 'Error logging transaction',
      error: error.message
    });
  }
};

module.exports = {
  getMachineStatus,
  dispenseProduct,
  getInventory,
  updateMachineConfig,
  getTransactionHistory,
  testRS485Connection,
  sendRS485Command,
  initializeRS485,
  detectAvailablePorts,
  logTransactionController
};
