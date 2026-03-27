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
const { db } = require('../config/dbconnection');
// const featureController = require("../controllers/featureController"); // Disabled
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

const fileFilter = (req, file, cb) => {
  const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB file size limit
    files: 5, // Max 5 files
  },
  fileFilter: fileFilter,
});
router.post('/register', usercontroller.register);
router.post('/login',loginValidation, usercontroller.login);

// Business date - derived from last day_close_summary
router.get('/business-date', auth.isAuthorize, async (req, res) => {
  try {
    const shopId = req.query.shop_id || req.user?.shop_id;
    const [rows] = await db.query(
      'SELECT close_date FROM day_close_summary WHERE shop_id = ? ORDER BY close_date DESC LIMIT 1',
      [shopId]
    );
    let businessDate;
    if (rows.length > 0 && rows[0].close_date) {
      const lastClose = new Date(rows[0].close_date);
      lastClose.setDate(lastClose.getDate() + 1);
      businessDate = lastClose.toISOString().split('T')[0];
    } else {
      businessDate = new Date().toISOString().split('T')[0];
    }
    res.json({ success: true, business_date: businessDate });
  } catch (err) {
    console.error('Business date error:', err);
    res.json({ success: true, business_date: new Date().toISOString().split('T')[0] });
  }
});

// Get shop name by shop_id (for Topbar display)
router.get('/shop-name', auth.isAuthorize, async (req, res) => {
  try {
    const shopId = req.query.shop_id || req.user?.shop_id;
    if (!shopId) {
      return res.json({ success: false, shop_name: '' });
    }
    const [rows] = await db.query('SELECT name FROM shops WHERE id = ?', [shopId]);
    res.json({ success: true, shop_name: rows.length > 0 ? rows[0].name : '' });
  } catch (err) {
    console.error('Shop name error:', err);
    res.json({ success: false, shop_name: '' });
  }
});

router.get('/getusers',auth.isAuthorize,usercontroller.getuser);
router.get('/users-with-uuid', auth.isAuthorize, usercontroller.getUsersWithUuid);
router.delete('/users/:id/uuid', auth.isAuthorize, usercontroller.clearUserUuid);
router.get('/allusers',auth.isAuthorize,viewcontroller.allUsers);
router.get('/users',auth.isAuthorize,viewcontroller.allUsers);

// Public endpoint for device management - without auth requirement
router.get('/public/users', async (req, res) => {
  try {
    const [result] = await db.query(`SELECT id, name, uname, email, contact, type, status FROM users ORDER BY id ASC`);
    res.status(200).send({ success: true, data: result, message: 'Fetch Data Successfully' });
  } catch (err) {
    console.error('Error fetching users:', err);
    res.status(500).send({ success: false, message: 'Internal Server Error' });
  }
});

router.get('/getlatestrecord/:tablename',auth.isAuthorize,viewcontroller.getLatestRecord);
router.get('/getnextitemcode',auth.isAuthorize,viewcontroller.getNextItemCode);

router.post('/upload_csv',auth.isAuthorize,insertcontroller.uploadcsv);
router.get('/test', (req, res) => {
  res.send('API is working');
});

//Insert Data 
router.post('/insertdata/:tablename',auth.isAuthorize,insertcontroller.insertdata);
router.post('/savepayment',auth.isAuthorize,billcontroller.savePayment);
router.post('/saveSupplierPayment',auth.isAuthorize, billcontroller.saveSupplierPayment);
router.post('/savebill',auth.isAuthorize,savebillController.savebill);
router.post('/public/savebill',savebillController.kiosksavebill);
router.post('/advancesavebill',auth.isAuthorize,savebillController.advancesavebill);
router.post('/insertdatabulk/:tablename',auth.isAuthorize,insertcontroller.insertdatabulk);
router.post('/insertdatabulkgst/:tablename',auth.isAuthorize,insertcontroller.insertdatabulkgst);

// Error handling wrapper for file upload route
const handleUploadErrors = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'FILE_TOO_LARGE') {
      return res.status(413).json({ message: 'File too large. Maximum size is 50MB' });
    }
    return res.status(400).json({ message: `Upload error: ${err.message}` });
  } else if (err) {
    return res.status(400).json({ message: `Error: ${err.message}` });
  }
  next();
};

router.post('/addnewproduct/:tablename', 
  auth.isAuthorize,
  (req, res, next) => {
    upload.array('images', 5)(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        if (err.code === 'FILE_TOO_LARGE') {
          return res.status(413).json({ message: 'File too large. Maximum size is 50MB' });
        }
        if (err.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({ message: 'Maximum 5 files allowed' });
        }
        console.error('Multer Error:', err);
        return res.status(400).json({ message: `Upload error: ${err.message}` });
      } else if (err) {
        console.error('Upload Error:', err);
        return res.status(400).json({ message: `Error: ${err.message}` });
      }
      next();
    });
  },
  insertcontroller.addNewProduct
);

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
router.put('/updatedata/companyinfo/:id', auth.isAuthorize, updatecontroller.updateCompanyInfoFormData);
router.put('/updatedata/:tablename',updatecontroller.updatedata);
router.put('/updatesubscription/:tablename/:id',auth.isAuthorize,updatecontroller.updateSubscription);
router.put('/updatecompanyinfo/',auth.isAuthorize,updatecontroller.updateCompanyInfo);
router.put('/updatecommondata/:tablename/:col1/:val1/',auth.isAuthorize,updatecontroller.updatecommondata);
//delete data 
router.delete('/deletebyid/:tablename/:colname/:colval',auth.isAuthorize,deletecontroller.deletedatabyid);

// Delete item with associated images and files
router.delete('/deleteitem/:id', auth.isAuthorize, deletecontroller.deleteItemById);

// Bulk delete items with associated images and files
router.post('/deleteitems/bulk', auth.isAuthorize, deletecontroller.deleteBulkItemsById);

// Feature Control Routes - All disabled to remove subscription restrictions
// router.get('/subscription', auth.isAuthorize, featureController.getUserSubscription);
// router.get('/features', auth.isAuthorize, featureController.getUserFeatures);
// Feature access routes disabled
// router.get('/features/:featureCode/access', auth.isAuthorize, featureController.checkFeatureAccess);
// Feature usage tracking routes disabled
// router.post('/features/:featureCode/usage', auth.isAuthorize, featureController.updateFeatureUsage);
// router.get('/features/:featureCode/usage', auth.isAuthorize, featureController.getFeatureUsage);
// router.get('/plans', auth.isAuthorize, featureController.getSubscriptionPlans);
// router.get('/plans/comparison', auth.isAuthorize, featureController.getPlanFeaturesComparison);
// router.post('/subscription/change', auth.isAuthorize, featureController.changeUserSubscription);

// Protected routes with feature access disabled
// router.get('/protected/suppliers', 
//     auth.isAuthorize, 
//     featureController.checkFeatureAccessMiddleware('suppliers'), 
//     featureController.getProtectedSuppliers
// );

module.exports=router