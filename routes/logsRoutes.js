/**
 * LOGS ROUTES
 * API endpoints for accessing and managing log files
 */

const express = require('express');
const router = express.Router();
const logsController = require('../controllers/logsController');
const { isAuthorize } = require('../middleware/auth');

// Get list of all log files
router.get('/logs', isAuthorize, logsController.getLogFiles);

// Get content of a specific log file
router.get('/logs/:filename', isAuthorize, logsController.getLogContent);

// Download a log file
router.get('/logs/:filename/download', isAuthorize, logsController.downloadLogFile);

// Clear a log file (admin only)
router.post('/logs/:filename/clear', isAuthorize, logsController.clearLogFile);

module.exports = router;
