const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const path = require('path')
const fs = require('fs')
const csv = require('csv-parser')
const updateDataPara1 = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const table = [req.params.tablename]
  const inv = [req.body.inv]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  console.log(`UPDATE ${table} SET inv= ${inv} where ${col1}= ${val1}`)
  db.query(
    `UPDATE ${table} SET inv= ${inv} where ${col1}= ${val1}`,
    (err, result) => {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      }
      return res.status(200).send({
        msg: 'Data updated'
      })
    }
  )
}
const updateStatus = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const table = [req.params.tablename]
  //const inv = [req.body.inv]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  console.log(`UPDATE ${table} SET status= 'paid' where ${col1}= ${val1}`)
  db.query(
    `UPDATE ${table} SET status= 'paid'  where ${col1}= ${val1}`,
    (err, result) => {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      }
      return res.status(200).send({
        msg: 'Data updated'
      })
    }
  )
}
const updateStatus1 = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const table = [req.params.tablename]
  const mode = [req.body.payment_mode]
  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  console.log(`UPDATE ${table} SET status= 'paid' where ${col1}= ${val1}`)
  db.query(
    `UPDATE ${table} SET payment_mode= '${mode}'  where ${col1}= ${val1}`,
    (err, result) => {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      }
      return res.status(200).send({
        msg: 'Data updated'
      })
    }
  )
}
const updateCompanyInfo = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const table = [req.params.tablename]
  const cname = [req.body.cname]
  const address = [req.body.address]
  const pincode = [req.body.pincode]
  const gst = [req.body.gst]
  const contact = [req.body.contact]
  const state = [req.body.state]
  const bank = [req.body.bank]
  const t1 = [req.body.t1]
  const t2 = [req.body.t2]
  const t3 = [req.body.t3]

  const col1 = [req.params.col1]
  const val1 = [req.params.val1]
  console.log(`UPDATE ${table} SET status= 'paid' where ${col1}= ${val1}`)
  db.query(
    `UPDATE ${table} SET 
      cname= ${cname},
      address= ${address},
      pincode= ${pincode},
      contact= ${contact},
      gst= ${gst},
      state= ${state},
      bank= ${bank},
      t1= ${t1},
      t2= ${t2},
      t3= ${t3},
      
      where ${col1}= ${val1}`,
    (err, result) => {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      }
      return res.status(200).send({
        msg: 'Data updated'
      })
    }
  )
}
module.exports = {
  updateDataPara1,
  updateStatus,
  updateStatus1,
  updateCompanyInfo,
}
