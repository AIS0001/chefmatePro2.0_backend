const express = require("express");
const router = express.Router();
const {signupvalidation,loginValidation}  = require('../helpers/validation');
//const usercontroller = require('../controllers/userControl');
const auth = require('../middleware/auth');
//const  insertcontroller = require("../controllers/insertcontrol");
const  viewcontroller = require("../controllers/viewcontrol");


//View Reports-Collection
// router.post('/paidbillsummarybymode',auth.isAuthorize,viewcontroller.viewbypaymentmode); //Paid Bill Summary Details-Total Collection
// router.post('/summarybymode',auth.isAuthorize,viewcontroller.summarybypaymentmode); //Paid Bill Summary Details-Total Collection
// router.get('/paidbillsummary/:balance',auth.isAuthorize,viewcontroller.paidbillsummary); //View Pending Bill Summary
// router.post('/salesummarygroupbydate',auth.isAuthorize,viewcontroller.salesummarygroupbydate); //Sale Summary Group By date





module.exports=router