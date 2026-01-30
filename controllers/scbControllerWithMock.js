const axios = require('axios');
const crypto = require('crypto');

const API_KEY = process.env.SCB_API_KEY || 'l7f9ef599841624f5f8b4650fd27c03e69';
const API_SECRET = process.env.SCB_API_SECRET || '1e7656e70ed84a528898f554ad96d514';
const USE_MOCK = process.env.SCB_USE_MOCK === 'true' || false; // Set to true for development

// Function to generate QR payment when paymentMethod === 'qr'
async function generateQRPayment(paymentAmount, orderDetails = {}) {
  try {
    if (USE_MOCK) {
      return generateMockQRPayment(paymentAmount, orderDetails);
    }
    
    const deeplinkUrl = await createDeeplink(paymentAmount, orderDetails);
    return {
      success: true,
      deeplinkUrl,
      paymentMethod: 'qr',
      amount: paymentAmount
    };
  } catch (error) {
    console.error('SCB QR Generation Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      config: error.config?.data
    });
    
    // Fallback to mock if SCB fails
    console.log('Falling back to mock QR payment due to SCB error');
    return generateMockQRPayment(paymentAmount, orderDetails);
  }
}

function generateMockQRPayment(paymentAmount, orderDetails = {}) {
  const mockTransactionId = `mock_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  const mockDeeplink = `https://mock-scb-deeplink.com/payment/${mockTransactionId}?amount=${paymentAmount}`;
  
  console.log('🔧 MOCK SCB Payment Generated:', {
    amount: paymentAmount,
    orderId: orderDetails.orderId,
    transactionId: mockTransactionId
  });
  
  return {
    success: true,
    deeplinkUrl: mockDeeplink,
    paymentMethod: 'qr',
    amount: paymentAmount,
    transactionId: mockTransactionId,
    isMock: true,
    message: 'Mock QR payment generated for development'
  };
}

async function getAccessToken() {
  if (USE_MOCK) {
    return `mock_token_${Date.now()}`;
  }
  
  const url = 'https://api-sandbox.partners.scb/partners/sandbox/v1/oauth/token';
  const headers = {
    'Content-Type': 'application/json',
    resourceOwnerId: API_KEY,
    requestUId: crypto.randomUUID(),
    'accept-language': 'EN',
  };
  const body = {
    applicationKey: API_KEY,
    applicationSecret: API_SECRET,
  };
  
  try {
    const res = await axios.post(url, body, { headers });
    return res.data.data.accessToken;
  } catch (error) {
    console.error('SCB Token Error:', error.response?.data || error.message);
    throw new Error(`SCB Authentication failed: ${error.response?.data?.status?.description || error.message}`);
  }
}

async function createDeeplink(paymentAmount, orderDetails = {}) {
  if (USE_MOCK) {
    return generateMockQRPayment(paymentAmount, orderDetails).deeplinkUrl;
  }
  
  const accessToken = await getAccessToken();
  const url = 'https://api-sandbox.partners.scb/partners/sandbox/v3/deeplink/transactions';
  
  const headers = {
    'Content-Type': 'application/json',
    authorization: `Bearer ${accessToken}`,
    resourceOwnerId: API_KEY,
    requestUId: crypto.randomUUID(),
    channel: 'scbeasy',
    'accept-language': 'EN',
  };

  // Generate reference IDs with proper length limits (max 20 chars for SCB)
  const orderId = (orderDetails.orderId || `ORDER${Date.now()}`).substring(0, 20);
  const custId = (orderDetails.customerId || `CUST${Date.now()}`).substring(0, 20);
  const txnId = (orderDetails.transactionId || `TXN${Date.now()}`).substring(0, 20);

  // Use the exact format from SCB documentation
  const body = {
    transactionType: 'PURCHASE',
    transactionSubType: ['BP'],
    sessionValidityPeriod: 60,
    billPayment: {
      paymentAmount: parseFloat(paymentAmount),
      accountTo: '123456789012345',
      ref1: orderId,
      ref2: custId,
      ref3: txnId
    },
    merchantMetaData: {
      callbackUrl: orderDetails.callbackUrl || '',
      merchantInfo: { 
        name: 'SANDBOX MERCHANT NAME' 
      },
      extraData: {},
      paymentInfo: []
    }
  };

  console.log('SCB Request:', JSON.stringify(body, null, 2));
  
  try {
    const res = await axios.post(url, body, { headers });
    console.log('SCB Response:', res.data);
    return res.data.data.deeplinkUrl;
  } catch (error) {
    console.error('SCB API Error Details:', {
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data,
      requestData: body
    });
    throw new Error(`SCB Deeplink creation failed: ${error.response?.data?.status?.description || error.message}`);
  }
}

async function getTransaction(transactionId) {
  if (USE_MOCK || transactionId.startsWith('mock_')) {
    return {
      success: true,
      transactionId: transactionId,
      status: 'PENDING',
      amount: 100,
      isMock: true,
      message: 'Mock transaction status'
    };
  }
  
  const accessToken = await getAccessToken();
  const url = `https://api-sandbox.partners.scb/partners/sandbox/v2/transactions/${transactionId}`;
  const headers = {
    authorization: `Bearer ${accessToken}`,
    resourceOwnerId: API_KEY,
    requestUId: crypto.randomUUID(),
    'accept-language': 'EN',
  };
  const res = await axios.get(url, { headers });
  return res.data;
}

module.exports = {
  getAccessToken,
  createDeeplink,
  getTransaction,
  generateQRPayment,
  generateMockQRPayment,
};
