const express = require('express');
const router = express.Router();
const scbController = require('../controllers/scbController');
const auth = require('../middleware/auth');
const { db } = require('../config/dbconnection');

// ===== LEGACY DEEPLINK API ROUTES =====

// Generate QR payment (main endpoint for QR payment integration)
router.post('/generate-qr-payment', async (req, res) => {
  try {
    const { paymentAmount, orderDetails } = req.body;
    
    if (!paymentAmount) {
      return res.status(400).json({ error: 'Payment amount is required' });
    }

    const result = await scbController.generateQRPayment(paymentAmount, orderDetails);
    res.json(result);
  } catch (err) {
    console.error('SCB QR Payment Error:', {
      message: err.message,
      status: err.response?.status,
      data: err.response?.data,
      headers: err.response?.headers
    });
    
    res.status(500).json({ 
      error: 'Error generating QR payment', 
      details: err.message,
      scbError: err.response?.data || null,
      status: err.response?.status || null
    });
  }
});

// Create payment QR deeplink (legacy endpoint)
router.get('/create-payment/:amount', async (req, res) => {
  try {
    const deeplinkUrl = await scbController.createDeeplink(req.params.amount);
    res.json({ deeplinkUrl });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: 'Error creating payment', details: err.message });
  }
});

// Get transaction details
router.get('/transaction/:transactionId', async (req, res) => {
  try {
    const transaction = await scbController.getTransaction(req.params.transactionId);
    res.json(transaction);
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: 'Error fetching transaction', details: err.message });
  }
});

// ===== NEW QR CODE API ROUTES =====

// Public QR creation for kiosk clients (no auth)
router.post('/public/qrcode', scbController.createQRCode);
// Public status check
router.get('/public/status/:ref1', scbController.checkPaymentStatus);
// Public payment history (mirrors protected)
router.get('/public/payments', scbController.getPaymentHistory);
// Public stats (mirrors protected)
router.get('/public/stats', scbController.getPaymentStats);
// Public legacy aliases
router.post('/public/generate-qr-payment', async (req, res) => {
  try {
    const { paymentAmount, orderDetails } = req.body;
    if (!paymentAmount) {
      return res.status(400).json({ error: 'Payment amount is required' });
    }
    const result = await scbController.generateQRPayment(paymentAmount, orderDetails);
    res.json(result);
  } catch (err) {
    console.error('SCB QR Payment Error:', {
      message: err.message,
      status: err.response?.status,
      data: err.response?.data,
      headers: err.response?.headers
    });
    res.status(500).json({
      error: 'Error generating QR payment',
      details: err.message,
      scbError: err.response?.data || null,
      status: err.response?.status || null
    });
  }
});

router.get('/public/create-payment/:amount', async (req, res) => {
  try {
    const deeplinkUrl = await scbController.createDeeplink(req.params.amount);
    res.json({ deeplinkUrl });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: 'Error creating payment', details: err.message });
  }
});

router.get('/public/transaction/:transactionId', async (req, res) => {
  try {
    const transaction = await scbController.getTransaction(req.params.transactionId);
    res.json(transaction);
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: 'Error fetching transaction', details: err.message });
  }
});

/**
 * @route GET /api/scb/token
 * @desc Get access token from SCB API (for testing)
 * @access Public
 */
router.get('/token', scbController.getToken);

/**
 * @route POST /api/scb/qrcode
 * @desc Create QR code for payment
 * @access Protected
 * @body { amount: Number, ref1: String, ref2?: String, ref3?: String, ppId?: String, billId?: Number }
 */
router.post('/qrcode', auth.isAuthorize, scbController.createQRCode);

/**
 * @route GET /api/scb/status/:ref1
 * @desc Check payment status by reference ID
 * @access Protected
 * @param ref1 - Reference ID from QR code creation
 */
router.get('/status/:ref1', auth.isAuthorize, scbController.checkPaymentStatus);

/**
 * @route POST /api/scb/simulate
 * @desc Simulate sandbox payment (for testing)
 * @access Public
 * @body { amount: Number, ref1: String, ref2?: String, ref3?: String, ppId?: String }
 */
router.post('/simulate', scbController.simulatePayment);

/**
 * @route GET /api/scb/payments
 * @desc Get payment history with filters
 * @access Protected
 * @query status, limit, offset, bill_id
 */
router.get('/payments', auth.isAuthorize, scbController.getPaymentHistory);

/**
 * @route GET /api/scb/stats
 * @desc Get payment statistics
 * @access Protected
 * @query startDate, endDate
 */
router.get('/stats', auth.isAuthorize, scbController.getPaymentStats);

// ===== UTILITY AND DEBUG ROUTES =====

// Debug endpoint to test request structure
router.post('/debug-qr-request', async (req, res) => {
  try {
    const { paymentAmount, orderDetails } = req.body;
    
    // Get access token first
    const accessToken = await scbController.getAccessToken();
    console.log('Access Token obtained successfully');
    
    // Build the corrected QR request payload
    const orderId = (orderDetails?.orderId || `ORDER${Date.now()}`).substring(0, 20);
    const custId = (orderDetails?.customerId || `CUST${Date.now()}`).substring(0, 20);
    const txnId = (orderDetails?.transactionId || `TXN${Date.now()}`).substring(0, 20);

    const payload = {
      qrType: "PP",
      ppType: "BILLERID",
      ppId: process.env.SCB_MERCHANT_ID || "269631402043654",
      amount: parseFloat(paymentAmount),
      ref1: orderId,
      ref2: custId || "",
      ref3: txnId || "",
      merchantId: process.env.SCB_MERCHANT_ID || "269631402043654"
    };

    console.log('Corrected QR Request Payload:', JSON.stringify(payload, null, 2));
    
    res.json({
      success: true,
      message: 'Debug QR request structure (FIXED)',
      accessToken: accessToken ? 'Token obtained' : 'Failed to get token',
      payload: payload,
      changes: [
        'Fixed API endpoint from /v3/deeplink/transactions to /v1/payment/qrcode/create',
        'Changed payload structure from billPayment to QR Code parameters',
        'Fixed header names (acceptLanguage instead of accept-language)',
        'Added proper merchantId and ppId parameters'
      ]
    });
    
  } catch (err) {
    console.error('Debug error:', err);
    res.status(500).json({ 
      error: 'Debug failed', 
      details: err.message,
      scbError: err.response?.data || null
    });
  }
});

// Payment callback endpoint for SCB notifications
router.post('/payment-callback', async (req, res) => {
  try {
    console.log('SCB Payment Callback received:', req.body);
    
    // Here you can implement logic to update your database
    // based on the payment status from SCB
    const { transactionId, status, amount, ref1 } = req.body;
    
    // Update database with payment status
    if (ref1) {
      try {
        const updateQuery = `
          UPDATE scb_payments 
          SET status = ?, paid_at = ?, updated_at = NOW(), callback_data = ?
          WHERE ref1 = ?
        `;
        
        const paidAt = status === 'SUCCESS' ? new Date() : null;
        await db.query(updateQuery, [status, paidAt, JSON.stringify(req.body), ref1]);
        
        console.log('✅ Payment status updated from callback');
      } catch (dbError) {
        console.error('⚠️ Failed to update payment status from callback:', dbError);
      }
    }
    
    res.status(200).json({ 
      success: true, 
      message: 'Payment callback processed successfully',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    console.error('Payment callback error:', err);
    res.status(500).json({ 
      success: false,
      error: 'Error processing payment callback',
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    service: 'SCB Payment Gateway',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    endpoints: {
      legacy: [
        'POST /generate-qr-payment',
        'GET /create-payment/:amount',
        'GET /transaction/:transactionId'
      ],
      qrcode_api: [
        'GET /token',
        'POST /qrcode',
        'GET /status/:ref1',
        'POST /simulate',
        'GET /payments',
        'GET /stats'
      ],
      utility: [
        'POST /debug-qr-request',
        'POST /payment-callback',
        'GET /health'
      ]
    }
  });
});

module.exports = router;
