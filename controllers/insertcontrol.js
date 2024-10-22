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
        // result.insertId typically contains the auto-incremented ID of the newly inserted record
        const insertedId = result.insertId; // Get the inserted record's ID
        return res.status(200).send({
            msg: 'Data saved successfully',
            id: insertedId,  // Return the newly inserted ID or any relevant data
          })

      }
     
    }
  )
}


const insertdatabulk = (req, res) => {
  // Check if the table name is provided and is a valid string
  const tableName = req.params.tablename;
  const validTableNames = ['order_items']; // Add valid table names to this array
  
  if (!validTableNames.includes(tableName)) {
    return res.status(400).send({ success: false, message: 'Invalid table name' });
  }

  const items = req.body.items; // Get the items array

  // Check if items is provided and is an array with at least one item
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).send({ success: false, message: 'No items provided' });
  }

  const values = items.map(item => [
    item.order_number,
    item.item_name,
    item.quantity,
    item.total_amount,
  ]);

  // Bulk insert query
  const query = `INSERT INTO ${tableName} (order_id,  item_name, quantity, total_price) VALUES ?`;

  // Log the query and its values for debugging
  console.log('Executing query:', query);
  console.log('With values:', values);

  db.query(query, [values], (err, results) => {
    if (err) {
      console.error('Error saving order items:', err); // Log the error
      return res.status(500).send({ success: false, message: 'Error saving order items' });
    }

    res.send({ success: true, message: 'Order items saved successfully' });
  });
};



const addNewProduct = (req, res) => {
  const product_id = req.body.product_id;
  //const tbl = req.params.tablename;
  const tbl = [req.params.tablename]
  
  const files = req.files.map(file => [
    product_id,
    file.filename,
    file.path,
    file.mimetype,
    file.size,
    
  ]);
  const query = `INSERT INTO ${tbl} (product_id,filename, path, mimetype, size) VALUES ?`;
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
  insertdatabulk,
  addNewProduct,
  uploadcsv,
}
