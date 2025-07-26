const express = require("express");
const router = express.Router();
const auth = require('../middleware/auth');
const  dashcontroller = require("../controllers/dashboardcontrol");



router.get("/report/purchase", auth.isAuthorize, dashcontroller.getPurchase);
router.get("/report/sale", auth.isAuthorize, dashcontroller.getSales);
router.get("/report/summary", auth.isAuthorize, dashcontroller.getSummary);
router.get("/report/todaysummary", auth.isAuthorize, dashcontroller.todaysalepurchase);
router.get("/report/getlowstockalert", auth.isAuthorize, dashcontroller.getLowStockAlerts);
router.get("/report/gettopproducts", auth.isAuthorize, dashcontroller.getTopProducts);
router.get("/report/weeklysales", auth.isAuthorize, dashcontroller.getWeeklySales);
router.get("/report/monthlysales", auth.isAuthorize, dashcontroller.getMonthlySales);
router.get("/report/weeklypurchase", auth.isAuthorize, dashcontroller.getWeeklyPurchase);
router.get("/report/monthlypurchase", auth.isAuthorize, dashcontroller.getMonthlyPurchase);
router.get("/report/weeklysummary", auth.isAuthorize, dashcontroller.getWeeklySummary);
router.get("/report/monthlysummary", auth.isAuthorize, dashcontroller.getMonthlySummary);


module.exports=router