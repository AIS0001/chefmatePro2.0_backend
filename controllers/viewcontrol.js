const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const db = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const { jwt_secret } = process.env


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
const combolistwithWhere = (req, res) => {
  const { where } = req.query;
  const table = [req.params.tablename]
  const id = [req.params.groupby]
  // console.log(`SELECT * 
  //   FROM ${table} 
  //   ${where ? `WHERE ${where}` : ""}
  //   group by ${id}`);
  db.query(
    `SELECT * 
    FROM ${table} 
    ${where ? `WHERE ${where}` : ""}
    group by ${id}`,
    
    function (err, results, fields) {
      if (err) {
        res.status(500).send('Error fetching data from the database');
        return;
      }
      res.json(results);

    }
  )
}
const viewAllData = (req, res) => {
  const authToken = req.headers.authorization.split(' ')[1]
  const decode = jwt.verify(authToken, jwt_secret)
  const table = [req.params.tablename]
  const id = [req.params.orderby]
  // console.log(`SELECT * FROM ${table} order by ${id}  DESC`);
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

  const table = [req.params.tablename]
  const id = [req.params.groupby]
 // console.log(`SELECT * FROM ${table} group by ${id} `);
  db.query(
    `SELECT * FROM ${table} group by ${id}  `,
    function (err, results, fields) {
      if (err) {
        res.status(500).send('Error fetching data from the database');
        return;
      }
      res.json(results);

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

const fetchData = (req, res) => {
  const tblname = req.params.tblname;
  const orderby = req.params.orderby;
  const where = req.params[0] ? decodeURIComponent(req.params[0]) : '';

  // Validate inputs
  if (!tblname || !orderby) {
    return res.status(400).json({
      status: 'error',
      message: 'Table name and order by fields are required',
      data: null
    });
  }

  // Create URLSearchParams object
  const params = new URLSearchParams(where);

  // Build WHERE clause with quoted values
  const conditions = [];
  for (const [key, value] of params.entries()) {
    conditions.push(`${key}="${value}"`);
  }
  const whereClause = conditions.length > 0 ? conditions.join(' AND ') : null;

  // Construct the SQL query
  let query;
  const queryParams = [tblname, orderby];

  if (whereClause) {
    query = `SELECT * FROM ?? WHERE ${whereClause} ORDER BY ??`;
  } else {
    query = `SELECT * FROM ?? ORDER BY ??`;
  }

  // Log the query for debugging
  //console.log('Constructed Query:', query);

  const formattedQuery = db.format(query, queryParams);
 // console.log('Formatted Query:', formattedQuery);

  // Execute the query
  db.query(formattedQuery, (error, results) => {
    if (error) {
      console.error('SQL Error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'An error occurred while fetching data',
        data: null
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Data fetched successfully',
      data: results
    });
  });
};
const fetchDataFromTwoTables = (req, res) => {
  const { tbl1, tbl2, col1, col2, orderby } = req.params;
  const { where } = req.query;

  const query = `
      SELECT t1.*, t2.*
      FROM ${tbl1} t1
      INNER JOIN ${tbl2} t2 ON t1.${col1} = t2.${col2}
      ${where ? `WHERE ${where}` : ""}
      ${orderby ? `ORDER BY ${orderby}` : ""}`;
  
  console.log(query);

  db.query(query, (err, results) => {
      if (err) {
          return res.status(500).json({ error: "Database error" });
      }
      res.json({ data: results });
  });
};
module.exports = {

  allUsers,
  combolist,
  viewAllData,
  viewAllDataLimit,
  fetchData,
  combolistwithWhere,
  fetchDataFromTwoTables,

}