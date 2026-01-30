const express = require("express");
const router = express.Router();
const kioskController = require("../controllers/kioskController");
const billController = require("../controllers/billControl");

router.get("/categories", kioskController.getCategories);
router.get("/categories/:categoryId/subcategories", kioskController.getSubcategoriesByCategory);
router.get("/items", kioskController.getItems);
router.get("/items/:id", kioskController.getItemById);
router.get("/menu", kioskController.getMenu);
router.get("/companyinfo", kioskController.getCompanyInfo);

// Kiosk public billing endpoint (guest orders, generates queue number)
router.post("/savebill", billController.kiosksavebill);

module.exports = router;
