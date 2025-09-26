const express = require("express");
const router = express.Router();
const {signupvalidation,loginValidation}  = require('../helpers/validation');
const usercontroller = require('../controllers/userControl');
const auth = require('../middleware/auth');
const insertcontroller = require("../controllers/insertcontrol");
const billcontroller = require("../controllers/billControl");
const savebillController = require("../controllers/billControl");
const deletecontroller = require("../controllers/deletecontrol");
const viewcontroller = require("../controllers/viewcontrol");
const updatecontroller = require("../controllers/updatecontrol");
const featureController = require("../controllers/featureController");
const { requireFeatureAccess, trackFeatureUsage, protectFeature } = require('../middleware/featureAccess');
const path = require('path');
const multer = require('multer');


//const { jwt_secret } = process.env;
// Configure Multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });
router.post('/register', usercontroller.register);
router.post('/login',loginValidation, usercontroller.login);
router.get('/getusers',auth.isAuthorize,usercontroller.getuser);
router.get('/allusers',auth.isAuthorize,viewcontroller.allUsers);
router.get('/getlatestrecord/:tablename',auth.isAuthorize,viewcontroller.getLatestRecord);

router.post('/upload_csv',auth.isAuthorize,insertcontroller.uploadcsv);
router.get('/test', (req, res) => {
  res.send('API is working');
});

//Insert Data 
router.post('/insertdata/:tablename',auth.isAuthorize,insertcontroller.insertdata);
router.post('/savepayment',auth.isAuthorize,billcontroller.savePayment);
router.post('/saveSupplierPayment',auth.isAuthorize, ...protectFeature('suppliers'), billcontroller.saveSupplierPayment);
router.post('/savebill',auth.isAuthorize,savebillController.savebill);
router.post('/advancesavebill',auth.isAuthorize,savebillController.advancesavebill);
router.post('/insertdatabulk/:tablename',auth.isAuthorize,insertcontroller.insertdatabulk);
router.post('/insertdatabulkgst/:tablename',auth.isAuthorize,insertcontroller.insertdatabulkgst);
router.post('/addnewproduct/:tablename', upload.array('images', 5), auth.isAuthorize, ...protectFeature('inventory'), insertcontroller.addNewProduct);

//View

router.get('/checkline',auth.isAuthorize,viewcontroller.checklLineDiscount);
router.get('/test', (req, res) => {
  console.log("🟢 /test route hit");
  res.json({ message: "Test route working" });
});

router.get('/fetchdata/:tblname/:orderby/*',auth.isAuthorize,viewcontroller.fetchData);
router.get('/fetchdatanotequal/:tblname/:orderby/*',auth.isAuthorize,viewcontroller.fetchDatanotequal);
router.get('/viewalldata/:tablename/:orderby',auth.isAuthorize,viewcontroller.viewAllData);
router.get('/combolist/:tablename/:groupby',auth.isAuthorize,viewcontroller.combolist);
router.get('/combolistwithWhere/:tablename/:groupby',auth.isAuthorize,viewcontroller.combolistwithWhere);
router.get('/fetchdatafromtwotables/:tbl1/:tbl2/:col1/:col2/:orderby',auth.isAuthorize,viewcontroller.fetchDataFromTwoTables);

router.get('/getoutstandingbalance/:customer_id', auth.isAuthorize, billcontroller.getOutstandingBalance);
router.get('/getoutstandingbalance/:ac_type/:customer_id', auth.isAuthorize, billcontroller.getOutstandingBalance);
router.get('/getclosingstock/:item_id', auth.isAuthorize, viewcontroller.getInventoryClosingStock);
// routes/userroutes.js
router.get("/inventory/joined", auth.isAuthorize, viewcontroller.getInventoryWithItems);
router.get("/checkledgerentry/:refno", auth.isAuthorize, viewcontroller.checkledgerentry);
router.get("/getinvoiceitems/:refno", auth.isAuthorize, viewcontroller.getinvoiceitems);
router.get("/order_items_gst_joined", auth.isAuthorize, viewcontroller.getOrderItemsGstJoined);
router.get("/order_items_vat_joined", auth.isAuthorize, viewcontroller.getOrderItemsJoined);


//Get
router.get('/getmaxordernumber/:tbl/:col1/:val1/:field',auth.isAuthorize,viewcontroller.getMaxOrderNumber);
router.get('/getrunningtable/:tbl',auth.isAuthorize,viewcontroller.getRunningTable);
router.get('/getrunningtable/:tbl',auth.isAuthorize,viewcontroller.getOrderDetailsWithSubtotals);
router.get('/getorderdetails/:table1/:table2',auth.isAuthorize,viewcontroller.getOrderDetailsWithSubtotals);

//Update
router.put('/updatedata1/:tablename/:col1/:val1/',auth.isAuthorize,updatecontroller.updateDataPara1);
router.put('/updatedata/:tablename',updatecontroller.updatedata);
router.put('/updatesubscription/:tablename/:id',auth.isAuthorize,updatecontroller.updateSubscription);
router.put('/updatecompanyinfo/',auth.isAuthorize,updatecontroller.updateCompanyInfo);
router.put('/updatecommondata/:tablename/:col1/:val1/',auth.isAuthorize,updatecontroller.updatecommondata);
//delete data 
router.delete('/deletebyid/:tablename/:colname/:colval',auth.isAuthorize,deletecontroller.deletedatabyid);

// Feature Control Routes
router.get('/subscription', auth.isAuthorize, featureController.getUserSubscription);
router.get('/features', auth.isAuthorize, featureController.getUserFeatures);
router.get('/features/:featureCode/access', auth.isAuthorize, featureController.checkFeatureAccess);
router.post('/features/:featureCode/usage', auth.isAuthorize, featureController.updateFeatureUsage);
router.get('/features/:featureCode/usage', auth.isAuthorize, featureController.getFeatureUsage);
router.get('/plans', auth.isAuthorize, featureController.getSubscriptionPlans);
router.get('/plans/comparison', auth.isAuthorize, featureController.getPlanFeaturesComparison);
router.post('/subscription/change', auth.isAuthorize, featureController.changeUserSubscription);

// Example protected route using feature access middleware
router.get('/protected/suppliers', 
    auth.isAuthorize, 
    featureController.checkFeatureAccessMiddleware('suppliers'), 
    featureController.getProtectedSuppliers
);

module.exports=router