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

const addNewProduct = (req, res) => {
  const product_id = req.body.product_id;
  
  const files = req.files.map(file => [
    product_id,
    file.filename,
    file.path,
    file.mimetype,
    file.size,
    
  ]);
  const query = 'INSERT INTO images (product_id,filename, path, mimetype, size) VALUES ?';
  console.log(query);
  db.query(query, [files], (err, results) => {
    if (err) {
      console.error('Failed to insert images into database:', err);
      return res.status(500).json({ message: 'Failed to upload images', error: err });
    }
    res.status(200).json({ message: 'Images uploaded and saved to database successfully!', images: results });
  });

 
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
  addNewProduct,
  uploadcsv,
}
