const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const path = require('path')
const fs = require('fs')
const csv = require('csv-parser')

const insertdata = (req, res) => {
  const table = [req.params.tablename]

  const val3 = req.body
  const val = Object.values(val3)
  const keyval = Object.keys(val3)
  const val2 = val.length ? "'" + val.join("', '") + "'" : ''


  let setty = `INSERT INTO ${table} (${keyval}) values (${val2})`
  console.log(setty)
  db.query(
    `INSERT INTO ${table} (${keyval}) values (${val2})`,
    (err, result) => {
      if (err) {
        return res.status(400).send({
          msg: err
        })
      }
      else{
        return res.status(200).send({
            msg: 'Data saved successfully'
          })

      }
     
    }
  )
}

const insertdata1 = (req, res) => {
  const table = [req.params.tablename]

  const { filename1 } = req.body.stamp
  const { filename2 } = req.body.sign
  const { originalname, mimetype, size, path } = req.file
  const imageData = fs.promises.readFile(path)

  const stamps = `http://localhost:4500/uploads/${filename1}`
  const signs = `http://localhost:4500/uploads/${filename2}`

  const { files } = req
  const imageUrls = files.map(
    file => `http://localhost:4500/uploads/${file.filename}`
  )
  const sql = 'INSERT INTO company_details (url) VALUES ?'
  db.query(sql, [imageUrls.map(url => [url])], (err, result) => {
    if (err) {
      throw err
    }
    console.log('Images uploaded to MySQL database')
    res.send('Images uploaded successfully')
  })
}
//Upload multiple images
const uploadcsv = (req, res) => {
  // Read the CSV file and insert data into MySQL
  const csvFile = req.files.csvFile
  const results = []
  fs.createReadStream(csvFile.tempFilePath)
    .pipe(csv())
    .on('data', row => {
      const sql =
        'INSERT INTO brands (id, brand_name, description) VALUES (?, ?, ?)'
      const values = [row.id, row.brand_name, row.description]

      db.query(sql, values, (err, result) => {
        if (err) throw err
        console.log('Data inserted:', result.affectedRows)
      })
    })
    .on('end', () => {
      console.log('CSV file imported into MySQL')
      // db.end(); // Close the database connection
    })
}

// Function to fetch and increment the alphanumeric code




module.exports = {
  
  insertdata,
  insertdata1,
  uploadcsv,
}
