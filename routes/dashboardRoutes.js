const express = require("express");
const router = express.Router();
const auth = require('../middleware/auth');
const  dashcontroller = require("../controllers/dashboardcontrol");



router.get("/report/purchase", auth.isAuthorize, dashcontroller.getPurchase);
router.get("/report/sale", auth.isAuthorize, dashcontroller.getSales);
router.get("/report/summary", auth.isAuthorize, dashcontroller.getSummary);


module.exports=router