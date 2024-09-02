const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const { jwt_secret } = process.env

const countRecord = (req, res) => {
    const authToken = req.headers.authorization.split(' ')[1]
    const decode = jwt.verify(authToken, jwt_secret)
    const table = [req.params.tablename]
    const id = [req.params.orderby]
    console.log(`SELECT count(*) as totalrecord FROM ${table} `);
    db.query(
      `SELECT count(*) as totalrecord FROM ${table} `,
      function (err, result, fields) {
        if (err) {
          console.log('Invalid field ' + err)
          return
        } else {
          var value = JSON.parse(JSON.stringify(result))
          return res
            .status(200)
            .send({ success: true, data: value, message: 'Data fetched !!' })
        }
      }
    )
  }
  const todayRecord = (req, res) => {
    const authToken = req.headers.authorization.split(' ')[1]
    const decode = jwt.verify(authToken, jwt_secret)
    const table = [req.params.tablename]
    const col1 = [req.params.col1]
    const val1 = [req.params.val1]
    const para1 = [req.params.para1]
    const id = [req.params.orderby]
    console.log(`SELECT IFNULL(sum(${para1}),0) as totalrecord FROM ${table} where ${col1}='${val1}'   `);
    db.query(
      `SELECT ROUND(IFNULL(sum(${para1}),0),2) as totalrecord FROM ${table} where ${col1}='${val1}' `,
      function (err, result, fields) {
        if (err) {
          console.log('Invalid field ' + err)
          return
        } else {
          var value = JSON.parse(JSON.stringify(result))
          return res
            .status(200)
            .send({ success: true, data: value, message: 'Data fetched !!' })
        }
      }
    )
  }
  const monthlysalechart = (req, res) => {
    const authToken = req.headers.authorization.split(' ')[1]
    const decode = jwt.verify(authToken, jwt_secret)
    const table = [req.params.tablename]
    const col1 = [req.params.col1]
    const val1 = [req.params.val1]
    const para1 = [req.params.para1]
    const id = [req.params.orderby]
    console.log(`SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS date, SUM(total_amount) AS sales FROM invoices GROUP BY DATE_FORMAT(invoice_date, '%Y-%m') ORDER BY DATE_FORMAT(invoice_date, '%Y-%m'); `);
    db.query(
      `SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS date, ROUND(SUM(total_amount),2) AS sales FROM ${table} GROUP BY DATE_FORMAT(invoice_date, '%Y-%m') ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')`,
      function (err, result, fields) {
        if (err) {
          console.log('Invalid field ' + err)
          return
        } else {
          var value = JSON.parse(JSON.stringify(result))
          return res
            .status(200)
            .send({ success: true, data: value, message: 'Data fetched !!' })
        }
      }
    )
  }
  const minimumquantity = (req, res) => {
    const authToken = req.headers.authorization.split(' ')[1]
    const decode = jwt.verify(authToken, jwt_secret)
    const lmt = [req.params.lmt]
    
    //console.log(``);
    db.query(
      `SELECT 
   
      i.prod_name,
      i.balance,
      t.min_qty,
      CASE
          WHEN i.balance < t.min_qty THEN 'Below Minimum'
          ELSE 'Sufficient'
      END AS status
  FROM 
      inventory i
  JOIN 
      (SELECT 
           prod_name, 
           MAX(id) AS latest_id 
       FROM 
           inventory 
       GROUP BY 
           prod_name) latest 
  ON 
      i.prod_name = latest.prod_name AND i.id = latest.latest_id
  JOIN 
      products t ON i.prod_name = t.prod_name
  WHERE 
      i.balance < t.min_qty ${lmt};`,
      function (err, result, fields) {
        if (err) {
          console.log('Invalid field ' + err)
          return
        } else {
          var value = JSON.parse(JSON.stringify(result))
          return res
            .status(200)
            .send({ success: true, data: value, message: 'Data fetched !!' })
        }
      }
    )
  }
module.exports = {
    countRecord,
    todayRecord,
    monthlysalechart,
    minimumquantity,
}