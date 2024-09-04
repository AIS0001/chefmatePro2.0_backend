const express = require("express");
const router = express.Router();
const {signupvalidation,loginValidation}  = require('../helpers/validation');
const usercontroller = require('../controllers/userControl');
const auth = require('../middleware/auth');
const  insertcontroller = require("../controllers/insertcontrol");
const  deletecontroller = require("../controllers/deletecontrol");
const  viewcontroller = require("../controllers/viewcontrol");
const  updatecontroller = require("../controllers/updatecontrol");
const path = require('path');
const multer = require('multer');


//const { jwt_secret } = process.env;

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      if(file.mimetype=='image/png')
      {
        cb(null, 'uploads/');
      }
      
    },
    filename: function (req, file, cb) {
      cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
  });

  const fileFilter = (req,file,cb)=>{
    if(file.fieldname==="stamp")
    {
      (file.mimetype==='image/png')
      ?cb(null,true)
      :(null,false);
    }
   else if(file.fieldname==="sign")
    {
      (file.mimetype==='image/png')
      ?cb(null,true)
      :(null,false);
    }
    
  };
  
  const upload = multer({
     storage: storage, 
    fileFilter:fileFilter
    }).fields([{name:'stamp',maxcount:1},{name:'sign',maxcount:1}]);

router.post('/register', usercontroller.register);
router.post('/login',loginValidation, usercontroller.login);
router.get('/getusers',auth.isAuthorize,usercontroller.getuser);
router.get('/allusers',auth.isAuthorize,viewcontroller.allUsers);

router.post('/upload_csv',auth.isAuthorize,insertcontroller.uploadcsv);

//Insert Data 
router.post('/insertdata/:tablename',auth.isAuthorize,insertcontroller.insertdata);

//View
router.get('/fetchdata/:tblname/:orderby/*',auth.isAuthorize,viewcontroller.fetchData);
router.get('/viewalldata/:tablename/:orderby',auth.isAuthorize,viewcontroller.viewAllData);
router.get('/combolist/:tablename/:groupby',auth.isAuthorize,viewcontroller.combolist);

//Update
router.put('/updatedata1/:tablename/:col1/:val1/',auth.isAuthorize,updatecontroller.updateDataPara1);


//delete data 
router.delete('/deletebyid/:tablename/:id/:colid',auth.isAuthorize,deletecontroller.deletedatabyid);


module.exports=router