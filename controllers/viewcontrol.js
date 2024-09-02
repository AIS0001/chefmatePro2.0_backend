const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const { jwt_secret } = process.env

//Play with Supplier Table data
const allsuppliers = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  db.query(
    `SELECT * FROM supplier order by id ASC `,
    function (err, result, fields) {
      if (err) throw err
      var value = JSON.parse(JSON.stringify(result))
      return res
        .status(200)
        .send({
          success: true,
          data: result,
          message: 'Fetch Data Sucessfully'
        })
    }
  )
}

const allUsers = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  db.query(
    `SELECT * FROM user order by id ASC `,
    function (err, result, fields) {
      if (err) throw err
      var value = JSON.parse(JSON.stringify(result))
      return res
        .status(200)
        .send({
          success: true,
          data: result,
          message: 'Fetch Data Sucessfully'
        })
    }
  )
}
const closingStock = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  console.log(
    `SELECT * FROM ${table} where id in (SELECT max(id) FROM ${table} GROUP BY prod_name )
     AND ${col1} = '${val1}'  order by prod_name ASC`
  )
  db.query(
   
    `SELECT * FROM ${table} where id in (SELECT max(id) FROM ${table} GROUP BY prod_name )
     AND ${col1} = '${val1}'  order by prod_name ASC`,
    
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
const viewAllData = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const id = [req.params.orderby]
  console.log(`SELECT * FROM ${table} order by ${id}  DESC`);
  db.query(
    `SELECT * FROM ${table} order by ${id}  DESC`,
    function (err, result, fields) {
      if (err) {
        console.log('Invalid field ' + err)
        return
      } else {
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data Saved !!' })
      }
    }
  )
}
const combolist = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const id = [req.params.orderby]
  console.log(`SELECT * FROM ${table} group by ${id} `);
  db.query(
    `SELECT * FROM ${table} group by ${id}  `,
    function (err, result, fields) {
      if (err) {
        console.log('Invalid field ' + err)
        return
      } else {
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data Saved !!' })
      }
    }
  )
}
const viewAllDataLimit = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const lmt = [req.params.limit]
  db.query(
    `SELECT * FROM ${table} order by id DESC limit ${lmt}`,
    function (err, result, fields) {
      if (err) {
        console.log('Invalid field' + err)
        return
      } else {
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data Saved !!' })
      }
    }
  )
}

const filterData1 = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]

  const orderby = [req.params.orderby]
  console.log(
    `SELECT * FROM ${table} where ${col1} = '${val1}' order by ${orderby} DESC`
  )
  db.query(
    `SELECT * FROM ${table} where ${col1} = '${val1}'  order by ${orderby} DESC `,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
const filterData2 = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1];
  const decode = jwt.verify(authToken, jwt_secret);
  const table = [req.params.tablename];
  const col1 = [req.params.col1];
  const val1 = [req.params.val1];
  const lmt = [req.params.limit];
  const orderby = [req.params.orderby];
  console.log(
    `SELECT * FROM ${table} where ${col1} = '${val1}' order by ${orderby} DESC ${lmt}`
  )
  db.query(
    `SELECT * FROM ${table} where ${col1} = '${val1}'  order by ${orderby} DESC ${lmt}`,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: "Product not found "+err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
const filterData2withlimit = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1];
  const decode = jwt.verify(authToken, jwt_secret);
  const table = [req.params.tablename];
  const col1 = [req.params.col1];
  const val1 = [req.params.val1];
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const lmt = [req.params.limit];
  const orderby = [req.params.orderby];
  console.log(
    `SELECT * FROM ${table} where ${col1} = '${val1}' AND ${col2} = '${val2}'  order by ${orderby} DESC ${lmt}`
  )
  db.query(
    `SELECT * FROM ${table} where ${col1} = '${val1}'  AND  ${col2} = '${val2}'  order by ${orderby} DESC ${lmt}`,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: "Product not found "+err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
const filterData2param = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const lmt = [req.params.limit]
  const orderby = [req.params.orderby]
 
  db.query(
    `SELECT * FROM ${table} where ${col1} = '${val1}' AND ${col2} = '${val2}' order by ${orderby} DESC `,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
//By date filter data range
const filterDataByDate2param = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const orderby = [req.params.orderby]
  console.log(
    `SELECT * FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' order by ${orderby} DESC`
  )
  db.query(
    `SELECT * FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' order by ${orderby} DESC `,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
const filterDataByDateName = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const col3 = [req.params.col3]
  const val3 = [req.params.val3]
  const orderby = [req.params.orderby]
  console.log(
    `SELECT * FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' AND ${col3} = '${val3}' order by ${orderby} DESC`
  )
  db.query(
    `SELECT * FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' AND ${col3} = '${val3}' order by ${orderby} DESC `,
    function (err, result, fields) {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      } else {
        //console.log(fields);
        var value = JSON.parse(JSON.stringify(result))
        return res
          .status(200)
          .send({ success: true, data: value, message: 'Data fetched !!' })
      }
    }
  )
}
//Vendor Invoice Details
const vendor_bill_summary = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const table = [req.params.tablename]
  console.log(`SELECT sum(total_cost) as total_cost,sum(tax_value) as total_tax_value,SUM(disc) as disc,sum(subtotal) as subtotal  FROM ${table} WHERE  ${col1}='${val1} '`);
  db.query(
    `SELECT IFNULL(ROUND(sum(total_cost),2),0) as total_cost,IFNULL(ROUND(sum(tax_value),2),0) as total_tax_value,IFNULL(ROUND(SUM(disc),2),0) as disc,IFNULL(ROUND(sum(subtotal),2),0) as subtotal  FROM ${table} WHERE  ${col1}=${val1} `,
    (err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const customer_bill_summary = (req, res) => {
   const authToken = req.headers.authorization.split(' ')[1]
   const col1 = [req.params.col1]
   const val1 = [req.params.val1]
   const col2 = [req.params.col2]
   const val2 = [req.params.val2]
   const table = [req.params.tablename]
   console.log(`SELECT sum(total_price) as total_cost,sum(tax) as total_tax_value,SUM(disc) as disc,sum(subtotal) as subtotal  FROM ${table} WHERE  ${col1}=${val1} AND ${col2}=${val2}  `);
   db.query(
     `SELECT sum(total_price) as total_cost,sum(tax) as total_tax_value,SUM(disc) as disc,sum(subtotal) as subtotal  FROM ${table} WHERE  ${col1}=${val1} AND ${col2}=${val2}  `,
     (err, result) => {
       if (err) throw err
       //var value= JSON.parse(JSON.stringify(result));
       return res
         .status(200)
         .send({ success: true, data: result, message: 'Summary Fetched' })
     }
   )
 }
 const account_head_ledger_summary = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const id = [req.params.orderby]
  const table = [req.params.tablename]
  let query1="";
  if(val1=="all")
    {
       query1 = `SELECT head_name as Name ,IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit,remark as Remark FROM ${table} order by ${id} DESC`;
    }
    else{
       query1 =  `SELECT head_name as Name ,IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit,remark as Remark  FROM ${table} WHERE  ${col1}='${val1}' order by ${id} DESC `;
    }
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const account_head_ledger_summary2param = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const id = [req.params.orderby]
  const table = [req.params.tablename]
  let query1="";
  if(val1=="all")
    {
       query1 = `SELECT head_name as Head ,IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit FROM ${table} WHERE  ${col1}='${val1}' AND ${col2}='${val2}'  order by ${id} DESC `;
    }
    else{
       query1 =  `SELECT head_name as Head , IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit  FROM ${table} WHERE  ${col1}='${val1}' AND ${col2}='${val2}'  order by ${id} DESC `;
    }
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
 //get ledger total balance
 const ledger_summary = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const vat = [req.params.vat]
  const disc = [req.params.disc]
  const id = [req.params.orderby]
  const table = [req.params.tablename]
  let query1="";
  if(val1=="all")
    {
       query1 = `SELECT IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit,IFNULL(ROUND(SUM(${vat}),2),0) as vat,IFNULL(ROUND(sum(${disc}),2),0) as disc  FROM ${table} order by ${id} DESC`;
    }
    else{
       query1 =  `SELECT IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit,IFNULL(SUM(${vat}),0) as vat,IFNULL(sum(${disc}),0) as disc  FROM ${table} WHERE  ${col1}='${val1}' order by ${id} DESC `;
    }
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const ledger_summary2param = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const vat = [req.params.vat]
  const disc = [req.params.disc]
  const id = [req.params.orderby]
  const table = [req.params.tablename]
  let query1="";
  if(val1=="all")
    {
       query1 = `SELECT IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit,IFNULL(ROUND(SUM(${vat}),2),0) as vat,IFNULL(ROUND(sum(${disc}),2),0) as disc  FROM ${table} WHERE  ${col1}='${val1}' AND ${col2}='${val2}'  order by ${id} DESC `;
    }
    else{
       query1 =  `SELECT IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit,IFNULL(SUM(${vat}),0) as vat,IFNULL(sum(${disc}),0) as disc  FROM ${table} WHERE  ${col1}='${val1}' AND ${col2}='${val2}'  order by ${id} DESC `;
    }
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const ledger_summary_bydate = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const vat = [req.params.vat]
  const disc = [req.params.disc]
  const table = [req.params.tablename]
  
  let query1 = `SELECT IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit,IFNULL(ROUND(SUM(${vat}),2),0) as vat,IFNULL(ROUND(sum(${disc}),2),0) as disc  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' `;
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const ledger_summary_bydatename = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const col3 = [req.params.col3]
  const val3 = [req.params.val3]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const vat = [req.params.vat]
  const disc = [req.params.disc]
  const table = [req.params.tablename]
  let query1="";
  if(val3=="all")
    {
       query1 = `SELECT IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit,IFNULL(ROUND(SUM(${vat}),2),0) as vat,IFNULL(ROUND(sum(${disc}),2),0) as disc  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' `;
    }
    else{
       query1 =  `SELECT IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit,IFNULL(SUM(${vat}),0) as vat,IFNULL(sum(${disc}),0) as disc  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' AND ${col3} = '${val3}' `;
    }
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const account_head_ledger_summary_bydatename = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const col3 = [req.params.col3]
  const val3 = [req.params.val3]
  const credit = [req.params.credit]
  const debit = [req.params.debit]
  const table = [req.params.tablename]
  let query1="";
  if(val3=="all")
    {
       query1 = `SELECT IFNULL(ROUND(sum(${credit}),2),0) as credit,IFNULL(ROUND(sum(${debit}),2),0) as debit  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' `;
    }
    else{
       query1 =  `SELECT IFNULL(sum(${credit}),0) as credit,IFNULL(sum(${debit}),0) as debit FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' AND ${col3} = '${val3}' `;
    }
   // console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
//Date Wise Sale Report
const datewise_salereport = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  
  const table = [req.params.tablename]
  
  let query1 = `SELECT invoice_date,IFNULL(ROUND(sum(subtotal),2),0) as subtotal,IFNULL(ROUND(sum(shipping),2),0) as shipping,IFNULL(ROUND(sum(taxvalue),2),0) as taxvalue,IFNULL(ROUND(SUM(total_amount),2),0) as total_amount,IFNULL(ROUND(sum(disc),2),0) as disc  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' GROUP BY invoice_date `;
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const billwise_salereport = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  
  const table = [req.params.tablename]
  
  let query1 = `SELECT invoice_date,IFNULL(ROUND(sum(subtotal),2),0) as subtotal,IFNULL(ROUND(sum(shipping),2),0) as shipping,IFNULL(ROUND(sum(taxvalue),2),0) as taxvalue,IFNULL(ROUND(SUM(total_amount),2),0) as total_amount,IFNULL(ROUND(sum(disc),2),0) as disc  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' GROUP BY invoice_date `;
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
const datewise_vehiclemileage = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const col3 = [req.params.col3]
  const val3 = [req.params.val3]
  const table = [req.params.tablename]
  
  let query1 = `SELECT vehicle,DATE_FORMAT(log_date, '%Y-%m') AS date,IFNULL(ROUND(sum(fuel),2),0) as fuel,IFNULL(ROUND(SUM(km),2),0) as km  FROM ${table} where ${col1} >= '${val1}' AND ${col2} <= '${val2}' AND ${col3} = '${val3}' GROUP BY DATE_FORMAT(log_date, '%Y-%m') ORDER BY DATE_FORMAT(log_date, '%Y-%m') `;
    console.log(query1);
  db.query(query1,(err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}
//Vendor invoice details End
const getCode = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const tables = [req.params.tablename]
  // console.log(`SELECT * FROM ${tables} order by id ASC limit 1`);
  db.query(
    `SELECT * FROM ${tables} order by id DESC limit 1`,
    function (err, result, fields) {
      if (err) throw err
      var value = JSON.parse(JSON.stringify(result))
      return res
        .status(200)
        .send({ success: true, data: result[0], message: 'Data fetched !!' })
    }
  )
}




const getOrder = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  // const decode = jwt.verify(authToken,jwt_secret);
  const table = [req.params.tablename]

  const maxdata = [req.params.max]
  console.log(`SELECT IFNULL(max(${maxdata}),0)+1 as orderno FROM ${table}`);
  db.query(
    `SELECT IFNULL(max(${maxdata}),0)+1 as orderno FROM ${table} `,
    (err, result) => {
      if (err) {
        console.log('Invalid field ' + err)
        return
      } else {
        //var value= JSON.parse(JSON.stringify(result));
        return res
          .status(200)
          .send({
            success: true,
            data: result,
            message: 'new order number fetched'
          })
      }
    }
  )
}
const lastInsertId = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1];
  const table = [req.params.tablename];

  const maxdata = [req.params.max];
  console.log(`SELECT IFNULL(max(${maxdata}),0) as maxid FROM ${table}`);
  db.query(
    `SELECT IFNULL(max(${maxdata}),0) as orderno FROM ${table} `,
    (err, result) => {
      if (err) {
        console.log('Invalid field ' + err);
        return
      } else {
        //var value= JSON.parse(JSON.stringify(result));
        return res
          .status(200)
          .send({
            success: true,
            data: result,
            message: 'Max ID Fetched'
          })
      }
    }
  )
}

//Acquitance report
const search_by_staff = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const table = [req.params.tablename]
  const groupby = [req.params.groupby]
  console.log(`SELECT main_account,sum(credit) as payment_recieved ,sum(debit) as payment_made,sum(debit)-sum(credit) as balance FROM ${table}  where ${col1}='${val1}' group by ${groupby}`);
  db.query(
    `SELECT main_account,sum(credit) as payment_recieved ,sum(debit) as payment_made,sum(debit)-sum(credit) as balance FROM ${table}  where ${col1}='${val1}' group by ${groupby} `,
    (err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}

const search_by_staff_date = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  const col2 = [req.params.col2]
  const val2 = [req.params.val2]
  const col3 = [req.params.col3]
  const val3 = [req.params.val3]
  const table = [req.params.tablename]
  const groupby = [req.params.groupby]
  console.log(`SELECT main_account,sum(credit) as payment_recieved ,sum(debit) as payment_made,sum(debit)-sum(credit) as balance FROM ${table}  where ${col1}='${val1}' AND ${col2}>='${val2}' AND ${col3}<='${val3}' group by ${groupby} `);
  db.query(
    `SELECT main_account,sum(credit) as payment_recieved ,sum(debit) as payment_made,sum(debit)-sum(credit) as balance FROM ${table}  where ${col1}='${val1}' AND ${col2}>='${val2}' AND ${col3}<='${val3}' group by ${groupby} `,
    (err, result) => {
      if (err) throw err
      //var value= JSON.parse(JSON.stringify(result));
      return res
        .status(200)
        .send({ success: true, data: result, message: 'Summary Fetched' })
    }
  )
}




module.exports = {
  
  allUsers,
  combolist,
  viewAllData,
  viewAllDataLimit,
  filterData1,
  filterData2,
  filterData2withlimit,
  filterData2param,
  getCode,
  getOrder,
  vendor_bill_summary,
  customer_bill_summary,
  closingStock,
  lastInsertId,
  ledger_summary,
  account_head_ledger_summary,
  account_head_ledger_summary2param,
  ledger_summary2param,
  filterDataByDate2param,
  filterDataByDateName,
  ledger_summary_bydate,
  account_head_ledger_summary_bydatename,
  ledger_summary_bydatename,
  datewise_salereport,
  datewise_vehiclemileage,
  search_by_staff,
  search_by_staff_date,
}
