const express = require("express");
const router = express.Router();
const {signupvalidation,loginValidation}  = require('../helpers/validation');
const usercontroller = require('../controllers/userControl');
const auth = require('../middleware/auth');
const  insertcontroller = require("../controllers/insertcontrol");
const  billcontroller = require("../controllers/billControl");
const  savebillController = require("../controllers/billControl");
const  deletecontroller = require("../controllers/deletecontrol");
const  viewcontroller = require("../controllers/viewcontrol");
const  updatecontroller = require("../controllers/updatecontrol");
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

router.post('/upload_csv',auth.isAuthorize,insertcontroller.uploadcsv);

//Insert Data 
router.post('/insertdata/:tablename',auth.isAuthorize,insertcontroller.insertdata);
router.post('/savebill',auth.isAuthorize,savebillController.savebill);
router.post('/insertdatabulk/:tablename',auth.isAuthorize,insertcontroller.insertdatabulk);
router.post('/addnewproduct/:tablename', upload.array('images', 5), auth.isAuthorize, insertcontroller.addNewProduct);

//View

router.get('/fetchdata/:tblname/:orderby/*',auth.isAuthorize,viewcontroller.fetchData);
router.get('/viewalldata/:tablename/:orderby',auth.isAuthorize,viewcontroller.viewAllData);
router.get('/combolist/:tablename/:groupby',auth.isAuthorize,viewcontroller.combolist);
router.get('/combolistwithWhere/:tablename/:groupby',auth.isAuthorize,viewcontroller.combolistwithWhere);
router.get('/fetchdatafromtwotables/:tbl1/:tbl2/:col1/:col2/:orderby',auth.isAuthorize,viewcontroller.fetchDataFromTwoTables);

router.get('/getoutstandingbalance/:customer_id', auth.isAuthorize, billcontroller.getOutstandingBalance);

//Get
router.get('/getmaxordernumber/:tbl/:col1/:val1/:field',auth.isAuthorize,viewcontroller.getMaxOrderNumber);
router.get('/getrunningtable/:tbl',auth.isAuthorize,viewcontroller.getRunningTable);
router.get('/getrunningtable/:tbl',auth.isAuthorize,viewcontroller.getOrderDetailsWithSubtotals);
router.get('/getorderdetails/:table1/:table2',auth.isAuthorize,viewcontroller.getOrderDetailsWithSubtotals);

//Update
router.put('/updatedata1/:tablename/:col1/:val1/',auth.isAuthorize,updatecontroller.updateDataPara1);
router.put('/updatedata/:tablename',auth.isAuthorize,updatecontroller.updatedata);

//delete data 
router.delete('/deletebyid/:tablename/:colname/:colval',auth.isAuthorize,deletecontroller.deletedatabyid);


module.exports=router