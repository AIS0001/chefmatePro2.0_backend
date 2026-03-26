const express = require("express");
const router = express.Router();

const cloudAgentController = require("../controllers/cloudAgentController");

router.get("/health", cloudAgentController.getHealth);
router.post("/print", cloudAgentController.sendPrintJob);
router.post("/test-print", cloudAgentController.testPrint);
router.post("/test-print-kot", cloudAgentController.testKot);
router.post("/test-print-bill", cloudAgentController.testBill);
router.post("/print-kot", cloudAgentController.sendKotToBoth);
router.post("/print-bill", cloudAgentController.sendBillToCashier);
router.post("/print-invoice", cloudAgentController.sendInvoiceByBillId);
router.post("/print-invoice/:billId", cloudAgentController.sendInvoiceByBillId);

// ✅ NEW: Print with auto-detected printer IP from database
router.post("/print-with-detection", cloudAgentController.printKotWithDetection);

// ✅ NEW: Print to multiple locations simultaneously
router.post("/print-multi-location", cloudAgentController.printToMultipleLocations);

module.exports = router;
