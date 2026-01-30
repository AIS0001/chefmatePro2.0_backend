const axios = require('axios');
const crypto = require('crypto');
const { db } = require('../config/dbconnection');

// Use Node.js built-in crypto.randomUUID() instead of uuid package
const uuidv4 = () => crypto.randomUUID();

const API_KEY = process.env.SCB_API_KEY || 'l7f9ef599841624f5f8b4650fd27c03e69';
const API_SECRET = process.env.SCB_API_SECRET || '1e7656e70ed84a528898f554ad96d514';
const SCB_BASE_URL = process.env.SCB_BASE_URL || 'https://api-sandbox.partners.scb/partners/sandbox';

// Function to generate QR payment when paymentMethod === 'qr'
async function generateQRPayment(paymentAmount, orderDetails = {}) {
  try {
    const qrResult = await createDeeplink(paymentAmount, orderDetails);
    return {
      success: true,
      qrData: qrResult,
      paymentMethod: 'qr',
      amount: paymentAmount,
      // Keep backwards compatibility
      deeplinkUrl: qrResult.qrRawData || null
    };
  } catch (error) {
    console.error('SCB QR Generation Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      config: error.config?.data
    });
    
    return {
      success: false,
      error: error.message,
      scbError: error.response?.data || null,
      status: error.response?.status || null,
      paymentMethod: 'qr'
    };
  }
}

async function getAccessToken() {
  const url = 'https://api-sandbox.partners.scb/partners/sandbox/v1/oauth/token';
  const headers = {
    'Content-Type': 'application/json',
    resourceOwnerId: API_KEY,
    requestUId: crypto.randomUUID(),
    acceptLanguage: 'EN', // Fixed header name
  };
  const body = {
    applicationKey: API_KEY,
    applicationSecret: API_SECRET,
  };
  const res = await axios.post(url, body, { headers });
  return res.data.data.accessToken;
}

async function createDeeplink(paymentAmount, orderDetails = {}) {
  console.log('🚀 Starting QR Code generation via createDeeplink...');
  console.log('📝 Input parameters:', { paymentAmount, orderDetails });
  
  try {
    const accessToken = await getAccessToken();
    console.log('🔐 Access token obtained successfully');
    
    // Use the correct QR Code API endpoint instead of deeplink
    const url = 'https://api-sandbox.partners.scb/partners/sandbox/v1/payment/qrcode/create';
    
    const headers = {
      'Content-Type': 'application/json',
      authorization: `Bearer ${accessToken}`,
      resourceOwnerId: API_KEY,
      requestUId: crypto.randomUUID(),
      acceptLanguage: 'EN', // Fixed header name (was 'accept-language')
    };

    // Generate reference IDs with proper length limits (max 20 chars for SCB)
    const orderId = (orderDetails.orderId || `ORDER${Date.now()}`).substring(0, 20);
    const custId = (orderDetails.customerId || `CUST${Date.now()}`).substring(0, 20);
    const txnId = (orderDetails.transactionId || `TXN${Date.now()}`).substring(0, 20);

    console.log('🏷️ Generated reference IDs:', { 
      original: { 
        orderId: orderDetails.orderId, 
        customerId: orderDetails.customerId, 
        transactionId: orderDetails.transactionId 
      },
      generated: { orderId, custId, txnId }
    });

    // Correct request body for QR Code API
    const body = {
      qrType: "PP",
      ppType: "BILLERID",
      ppId: process.env.SCB_MERCHANT_ID || "269631402043654", // your biller ID
      amount: Number(paymentAmount).toFixed(2), // always "400.00"
      ref1: orderId.replace(/[^A-Z0-9]/gi, '').substring(0, 20),
      ref2: (custId || "").replace(/[^A-Z0-9]/gi, '').substring(0, 20),
      ref3: (txnId || "").replace(/[^A-Z0-9]/gi, '').substring(0, 20)
    };

    console.log('📋 Sanitized reference IDs:', { 
      ref1: `"${body.ref1}" (length: ${body.ref1.length})`,
      ref2: `"${body.ref2}" (length: ${body.ref2.length})`, 
      ref3: `"${body.ref3}" (length: ${body.ref3.length})`
    });

    console.log('📤 SCB QR Request Payload:');
    console.log(JSON.stringify(body, null, 2));
    console.log('🌐 Request URL:', url);
    
    const res = await axios.post(url, body, { headers });
    
    console.log('📥 SCB QR Response Status:', res.status);
    console.log('📥 SCB QR Response Data:');
    console.log(JSON.stringify(res.data, null, 2));
    
    // For QR Code API, we need to return the QR data, not a deeplink URL
    if (res.data && res.data.data) {
      const qrResult = {
        qrRawData: res.data.data.qrRawData,
        qrImage: res.data.data.qrImage,
        transactionId: res.data.data.transactionId,
        ref1: body.ref1, // Use sanitized ref1 from body
        ref2: body.ref2, // Use sanitized ref2 from body
        ref3: body.ref3, // Use sanitized ref3 from body
        amount: body.amount, // Use formatted amount from body
        expiryDateTime: res.data.data.expiryDateTime
      };
      
      console.log('✅ QR Code creation successful!');
      console.log('📊 QR Result summary:', {
        hasQrData: !!qrResult.qrRawData,
        hasQrImage: !!qrResult.qrImage,
        transactionId: qrResult.transactionId,
        refs: { ref1: qrResult.ref1, ref2: qrResult.ref2, ref3: qrResult.ref3 },
        amount: qrResult.amount,
        expiryDateTime: qrResult.expiryDateTime
      });
      
      // Save QR code data to database
      try {
        const insertQuery = `
          INSERT INTO scb_payments 
          (ref1, ref2, ref3, amount, qr_raw_data, qr_image, transaction_id, status, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW())
        `;
        
        await db.query(insertQuery, [
          qrResult.ref1,
          qrResult.ref2 || null,
          qrResult.ref3 || null,
          qrResult.amount,
          qrResult.qrRawData || null,
          qrResult.qrImage || null,
          qrResult.transactionId || null
        ]);
        
        console.log('✅ Payment record saved to database');
        
      } catch (dbError) {
        console.error('⚠️ Failed to save payment to database:', dbError);
        // Don't fail the request if database save fails, but log the error
      }
      
      return qrResult;
    }
    
    throw new Error('Invalid response structure from SCB API');
  } catch (error) {
    console.log('❌ QR Code creation failed!');
    console.error('🚫 SCB QR API Error Details:');
    console.error('  Status:', error.response?.status);
    console.error('  Status Text:', error.response?.statusText);
    console.error('  Error Data:', JSON.stringify(error.response?.data, null, 2));
    console.error('  Request Headers:', JSON.stringify(headers, null, 2));
    console.error('  Request Body:', JSON.stringify(body, null, 2));
    console.error('  Full Error:', error.message);
    
    // Log specific error codes for debugging
    if (error.response?.data?.status?.code) {
      console.error(`🔍 SCB Error Code: ${error.response.data.status.code}`);
      console.error(`🔍 SCB Error Description: ${error.response.data.status.description}`);
    }
    
    throw error;
  }
}

async function getTransaction(transactionId) {
  const accessToken = await getAccessToken();
  const url = `https://api-sandbox.partners.scb/partners/sandbox/v2/transactions/${transactionId}`;
  const headers = {
    authorization: `Bearer ${accessToken}`,
    resourceOwnerId: API_KEY,
    requestUId: crypto.randomUUID(),
    acceptLanguage: 'EN', // Fixed header name
  };
  const res = await axios.get(url, { headers });
  return res.data;
}

// ===== NEW QR CODE API FUNCTIONS =====

/**
 * Get Access Token using new OAuth endpoint
 */
async function getAccessTokenV2() {
  try {
    console.log('🔐 Requesting SCB access token (v2)...');
    
    const tokenResponse = await axios.post(
      `${SCB_BASE_URL}/v1/oauth/token`,
      {
        applicationKey: process.env.SCB_API_KEY,
        applicationSecret: process.env.SCB_API_SECRET
      },
      {
        headers: {
          "Content-Type": "application/json",
          resourceOwnerId: process.env.SCB_CLIENT_ID,
          requestUId: uuidv4(),
          acceptLanguage: "EN"
        }
      }
    );

    console.log('✅ SCB access token (v2) retrieved successfully');
    return tokenResponse.data.data.accessToken;
    
  } catch (error) {
    console.error('❌ Failed to get SCB access token (v2):', error.response?.data || error.message);
    throw new Error('Failed to get access token from SCB API');
  }
}

/**
 * Get Access Token Endpoint (for testing purposes)
 * GET /api/scb/token
 */
const getToken = async (req, res) => {
  try {
    const token = await getAccessTokenV2();
    
    res.status(200).json({ 
      success: true,
      accessToken: token,
      message: 'Access token retrieved successfully',
      timestamp: new Date().toISOString()
    });
    
  } catch (err) {
    console.error('Token endpoint error:', err);
    res.status(500).json({ 
      success: false,
      error: "Failed to get access token",
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Create QR Code for Payment
 * POST /api/scb/qrcode
 * Body: { amount, ref1, ref2, ref3, ppId, billId }
 */
const createQRCode = async (req, res) => {
  console.log('🚀 Starting QR Code creation via createQRCode API...');
  console.log('📝 Request body:', JSON.stringify(req.body, null, 2));
  
  let requestBody = null;
  
  try {
    const { amount, ref1, ref2, ref3, ppId, billId } = req.body;
    
    // Validate required fields
    if (!amount || !ref1) {
      console.log('❌ Validation failed - missing required fields');
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
        details: 'amount and ref1 are required fields',
        timestamp: new Date().toISOString()
      });
    }

    console.log('✅ Input validation passed');
    console.log('📋 Input parameters:', { 
      amount: `${amount} (${typeof amount})`, 
      ref1: `"${ref1}" (${typeof ref1})`, 
      ref2: ref2 ? `"${ref2}" (${typeof ref2})` : 'undefined', 
      ref3: ref3 ? `"${ref3}" (${typeof ref3})` : 'undefined',
      ppId: ppId || 'using default',
      billId: billId || 'undefined'
    });
    
    console.log('🔐 Getting access token...');
    const token = await getAccessTokenV2();
    console.log('✅ Access token obtained successfully');
    
    requestBody = {
      qrType: "PP",
      ppType: "BILLERID", 
      ppId: ppId || process.env.SCB_MERCHANT_ID || "269631402043654", // your biller ID
      amount: Number(amount).toFixed(2), // always "400.00"
      ref1: ref1.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20),
      ref2: ref2 ? ref2.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20) : "",
      ref3: ref3 ? ref3.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20) : ""
    };

    console.log('🧹 Reference sanitization results:');
    console.log(`  ref1: "${ref1}" → "${requestBody.ref1}" (length: ${requestBody.ref1.length})`);
    console.log(`  ref2: "${ref2 || ''}" → "${requestBody.ref2}" (length: ${requestBody.ref2.length})`);
    console.log(`  ref3: "${ref3 || ''}" → "${requestBody.ref3}" (length: ${requestBody.ref3.length})`);
    console.log(`  amount: ${amount} → "${requestBody.amount}"`);

    console.log('📤 SCB QR Request Payload:');
    console.log(JSON.stringify(requestBody, null, 2));
    
    const apiUrl = `${SCB_BASE_URL}/v1/payment/qrcode/create`;
    console.log('🌐 API URL:', apiUrl);

    const qrResponse = await axios.post(
      apiUrl,
      requestBody,
      {
        headers: {
          authorization: `Bearer ${token}`,
          requestUId: uuidv4(),
          resourceOwnerId: process.env.SCB_CLIENT_ID,
          "Content-Type": "application/json"
        }
      }
    );

    console.log('📥 SCB Response Status:', qrResponse.status);
    console.log('📥 SCB Response Data:');
    console.log(JSON.stringify(qrResponse.data, null, 2));

    const qrData = qrResponse.data.data;
    console.log('✅ QR code created successfully!');
    console.log('📊 QR Data summary:', {
      hasQrRawData: !!qrData.qrRawData,
      hasQrImage: !!qrData.qrImage,
      transactionId: qrData.transactionId,
      expiryDateTime: qrData.expiryDateTime,
      qrRawDataLength: qrData.qrRawData ? qrData.qrRawData.length : 0
    });

    // Store QR code data in database
    try {
      const insertQuery = `
        INSERT INTO scb_payments 
        (bill_id, ref1, ref2, ref3, amount, qr_raw_data, qr_image, transaction_id, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW())
      `;
      
      await db.query(insertQuery, [
        billId || null,
        ref1,
        ref2 || null,
        ref3 || null,
        amount,
        qrData.qrRawData || null,
        qrData.qrImage || null,
        qrData.transactionId || null
      ]);
      
      console.log('✅ Payment record saved to database');
      
    } catch (dbError) {
      console.error('⚠️ Failed to save payment to database:', dbError);
      // Don't fail the request if database save fails
    }

    res.status(200).json({
      success: true,
      data: {
        qrRawData: qrData.qrRawData,
        qrImage: qrData.qrImage,
        ref1: requestBody.ref1, // Use sanitized ref1
        ref2: requestBody.ref2, // Use sanitized ref2
        ref3: requestBody.ref3, // Use sanitized ref3
        amount: requestBody.amount, // Use formatted amount
        transactionId: qrData.transactionId,
        expiryDateTime: qrData.expiryDateTime
      },
      message: 'QR code created successfully',
      timestamp: new Date().toISOString()
    });

    console.log('🎉 QR Code API response sent successfully');

  } catch (err) {
    console.log('❌ QR Code creation failed!');
    console.error('🚫 Error Details:');
    console.error('  HTTP Status:', err.response?.status);
    console.error('  Status Text:', err.response?.statusText);
    console.error('  Error Message:', err.message);
    console.error('  SCB Error Data:', JSON.stringify(err.response?.data, null, 2));
    
    if (err.response?.data?.status?.code) {
      console.error(`🔍 SCB Error Code: ${err.response.data.status.code}`);
      console.error(`🔍 SCB Error Description: ${err.response.data.status.description}`);
    }
    
    // Log request details for debugging
    console.error('🔍 Failed Request Details:');
    console.error('  Request Body:', JSON.stringify(req.body, null, 2));
    console.error('  Processed Request Body:', JSON.stringify(requestBody || {}, null, 2));
    console.error('  API URL:', `${process.env.SCB_BASE_URL}/v1/payment/qrcode/create`);
    
    res.status(500).json({ 
      success: false,
      error: "Failed to create QR code",
      details: err.response?.data?.status?.description || err.message,
      errorCode: err.response?.data?.status?.code || null,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Check Payment Status
 * GET /api/scb/status/:ref1
 */
const checkPaymentStatus = async (req, res) => {
  try {
    const { ref1 } = req.params;
    
    if (!ref1) {
      return res.status(400).json({
        success: false,
        error: 'Missing ref1 parameter',
        timestamp: new Date().toISOString()
      });
    }

    console.log('🔍 Checking payment status for ref1:', ref1);
    
    const token = await getAccessTokenV2();
    
    const statusResponse = await axios.get(
      `${SCB_BASE_URL}/v1/payment/qrcode/${ref1}`,
      {
        headers: {
          authorization: `Bearer ${token}`,
          resourceOwnerId: process.env.SCB_CLIENT_ID,
          requestUId: uuidv4()
        }
      }
    );

    const statusData = statusResponse.data.data;
    console.log('✅ Payment status retrieved:', statusData.status);

    // Update database with payment status
    try {
      const updateQuery = `
        UPDATE scb_payments 
        SET status = ?, paid_at = ?, updated_at = NOW()
        WHERE ref1 = ?
      `;
      
      const paidAt = statusData.status === 'SUCCESS' ? new Date() : null;
      await db.query(updateQuery, [statusData.status, paidAt, ref1]);
      
      console.log('✅ Payment status updated in database');
      
    } catch (dbError) {
      console.error('⚠️ Failed to update payment status in database:', dbError);
    }

    res.status(200).json({
      success: true,
      data: {
        ref1: ref1,
        status: statusData.status,
        amount: statusData.amount,
        paidDateTime: statusData.paidDateTime,
        transactionId: statusData.transactionId
      },
      message: 'Payment status retrieved successfully',
      timestamp: new Date().toISOString()
    });

  } catch (err) {
    console.error('❌ Payment status check failed:', err.response?.data || err.message);
    res.status(500).json({ 
      success: false,
      error: "Failed to get payment status",
      details: err.response?.data?.status?.description || err.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Simulate Sandbox Payment (for testing)
 * POST /api/scb/simulate
 * Body: { amount, ref1, ref2, ref3, ppId }
 */
const simulatePayment = async (req, res) => {
  try {
    const { amount, ref1, ref2, ref3, ppId } = req.body;
    
    if (!amount || !ref1) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
        details: 'amount and ref1 are required fields',
        timestamp: new Date().toISOString()
      });
    }

    console.log('🧪 Simulating sandbox payment...', { amount, ref1 });
    
    const token = await getAccessTokenV2();
    
    const simulateResponse = await axios.post(
      `${process.env.SCB_BASE_URL}/v1/sandbox/payment/simulator/qrpayment`,
      {
        qrType: "PP",
        ppType: "BILLERID",
        ppId: ppId || process.env.SCB_MERCHANT_ID || "269631402043654", // your biller ID
        amount: Number(amount).toFixed(2), // always "400.00"
        ref1: ref1.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20),
        ref2: ref2 ? ref2.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20) : "",
        ref3: ref3 ? ref3.toString().replace(/[^A-Z0-9]/gi, '').substring(0, 20) : "",
        paidAt: new Date().toISOString()
      },
      {
        headers: {
          authorization: `Bearer ${token}`,
          requestUId: uuidv4(),
          resourceOwnerId: process.env.SCB_CLIENT_ID,
          "Content-Type": "application/json"
        }
      }
    );

    console.log('✅ Sandbox payment simulated successfully');

    // Update payment status to SUCCESS in database
    try {
      const updateQuery = `
        UPDATE scb_payments 
        SET status = 'SUCCESS', paid_at = NOW(), updated_at = NOW()
        WHERE ref1 = ?
      `;
      
      await db.query(updateQuery, [ref1]);
      console.log('✅ Payment status updated to SUCCESS in database');
      
    } catch (dbError) {
      console.error('⚠️ Failed to update payment status in database:', dbError);
    }

    res.status(200).json({
      success: true,
      message: "Sandbox payment simulated successfully",
      data: {
        ref1: ref1,
        amount: amount,
        status: 'SUCCESS',
        simulatedAt: new Date().toISOString(),
        responseData: simulateResponse.data
      },
      timestamp: new Date().toISOString()
    });

  } catch (err) {
    console.error('❌ Sandbox payment simulation failed:', err.response?.data || err.message);
    res.status(500).json({ 
      success: false,
      error: "Failed to simulate payment",
      details: err.response?.data?.status?.description || err.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Get Payment History
 * GET /api/scb/payments?status=PENDING&limit=10
 */
const getPaymentHistory = async (req, res) => {
  try {
    const { status, limit = 50, offset = 0, bill_id } = req.query;
    
    let query = 'SELECT * FROM scb_payments WHERE 1=1';
    const params = [];
    
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }
    
    if (bill_id) {
      query += ' AND bill_id = ?';
      params.push(bill_id);
    }
    
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));
    
    const [payments] = await db.query(query, params);
    
    res.status(200).json({
      success: true,
      data: payments,
      count: payments.length,
      filters: { status, bill_id, limit, offset },
      message: 'Payment history retrieved successfully',
      timestamp: new Date().toISOString()
    });
    
  } catch (err) {
    console.error('❌ Failed to get payment history:', err);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve payment history',
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Get Payment Statistics
 * GET /api/scb/stats
 */
const getPaymentStats = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let dateFilter = '';
    const params = [];
    
    if (startDate && endDate) {
      dateFilter = 'AND DATE(created_at) BETWEEN ? AND ?';
      params.push(startDate, endDate);
    }
    
    const [stats] = await db.query(`
      SELECT 
        COUNT(*) as total_payments,
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_payments,
        COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_payments,
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_payments,
        COALESCE(SUM(CASE WHEN status = 'SUCCESS' THEN amount END), 0) as total_amount_success,
        COALESCE(AVG(CASE WHEN status = 'SUCCESS' THEN amount END), 0) as avg_amount_success,
        MIN(created_at) as first_payment,
        MAX(created_at) as latest_payment
      FROM scb_payments 
      WHERE 1=1 ${dateFilter}
    `, params);
    
    res.status(200).json({
      success: true,
      data: stats[0],
      period: startDate && endDate ? { startDate, endDate } : 'All time',
      message: 'Payment statistics retrieved successfully',
      timestamp: new Date().toISOString()
    });
    
  } catch (err) {
    console.error('❌ Failed to get payment statistics:', err);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve payment statistics',
      details: err.message,
      timestamp: new Date().toISOString()
    });
  }
};

module.exports = {
  getAccessToken,
  createDeeplink,
  getTransaction,
  generateQRPayment,
  // New QR Code API functions
  getToken,
  createQRCode,
  checkPaymentStatus,
  simulatePayment,
  getPaymentHistory,
  getPaymentStats,
  getAccessTokenV2  // Export for use in other modules
};
