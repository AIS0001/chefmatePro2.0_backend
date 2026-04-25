const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getEntertainmentReport, getGroupWiseDaywiseReport } = require('../controllers/reportController');

router.get('/entertainment-report', auth.isAuthorize, getEntertainmentReport);
router.get('/groupwise-daywise-report', auth.isAuthorize, getGroupWiseDaywiseReport);

module.exports = router;
