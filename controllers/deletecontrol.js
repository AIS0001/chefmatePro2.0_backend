const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const db = require('../config/dbconnection');
const jwt = require('jsonwebtoken');
const { jwt_secret } = process.env;

const deletedatabyid =(req, res) =>{

    const authToken =  req.headers.authorization.split(' ')[1];
    const decode = jwt.verify(authToken,jwt_secret);
    const id = [req.params.id];
    const colid = [req.params.colid];
    const table = [req.params.tablename];
    db.query(
        `DELETE FROM ${table} WHERE ${colid}=?`,id,function(err,result,fields){
            if (err) {
                return res.status(400).send({
                  msg: err
                })
              }
              else{
                var value= JSON.parse(JSON.stringify(result));
                return res.status(200).send({success:true, data:value,message:"Data Deleted Successfully!!!"})
           
              }

          }
    )
 
 }

 module.exports = {
    deletedatabyid
 }