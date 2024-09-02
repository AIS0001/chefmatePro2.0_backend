require("dotenv").config();
// Middleware to handle uncaught errors and unhandled promise rejections
function errorHandlerMiddleware(err, req, res, next) {
  console.error('My Unhandled Error:', err);
  res.status(500).send('Internal Server Error');
}

// Process event listeners for uncaught exceptions and unhandled promise rejections
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1); // Exit the process with an error code
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Promise Rejection:', reason);
  // Optionally, you can log the stack trace of the promise:
  // console.error(reason.stack);
});

const express = require("express");
const cors = require('cors');
const bodyParser = require('body-parser');
const userRouters = require('./routes/userRoutes.js');

require('./config/dbconnection');

const app = express();
app.use(express.json({ limit: "30mb", extended: true }));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

app.use('/api', userRouters);

//error handling
app.use((err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.mesaage = err.message || "Internal Server Error";
  res.status(err.statusCode).json({
    message: err.message,
  })
});

// Register the error handling middleware
app.use(errorHandlerMiddleware);

app.listen(4400, () => console.log('local server connected at port 4400'))