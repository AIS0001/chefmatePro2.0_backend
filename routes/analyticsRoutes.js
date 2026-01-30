const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');
const auth = require('../middleware/auth');

// Analytics Dashboard Routes
router.get('/dashboard', auth.isAuthorize, analyticsController.getAnalyticsDashboard);
router.get('/monthly-sales-purchases', auth.isAuthorize, analyticsController.getMonthlySalesVsPurchases);
router.get('/suppliers-outstanding', auth.isAuthorize, analyticsController.getSuppliersOutstanding);
router.get('/order-status', auth.isAuthorize, analyticsController.getOrderStatusDistribution);
router.get('/top-products', auth.isAuthorize, analyticsController.getTopSellingProducts);
router.get('/category-distribution', auth.isAuthorize, analyticsController.getCategoryDistribution);
router.get('/sales-expenses', auth.isAuthorize, analyticsController.getTotalSalesExpenses);
router.get('/daily-sales-trend', auth.isAuthorize, analyticsController.getDailySalesTrend);
router.get('/purchase-trends', auth.isAuthorize, analyticsController.getPurchaseTrends);

module.exports = router;
