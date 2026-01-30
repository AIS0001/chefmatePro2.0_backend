const { db } = require("../config/dbconnection");

const getCategories = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT id, name FROM categories ORDER BY name ASC"
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("kiosk:getCategories", err);
    res.status(500).json({ success: false, message: "Failed to fetch categories" });
  }
};

const getSubcategoriesByCategory = async (req, res) => {
  const { categoryId } = req.params;
  try {
    const [rows] = await db.query(
      "SELECT id, cat_id, subcat FROM subcategory WHERE cat_id = ? ORDER BY subcat ASC",
      [categoryId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("kiosk:getSubcategoriesByCategory", err);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch subcategories" });
  }
};

const getItems = async (req, res) => {
  try {
    const { catid, subcatid, status } = req.query;

    const conditions = [];
    const values = [];

    if (catid) {
      conditions.push("i.catid = ?");
      values.push(catid);
    }

    if (subcatid) {
      conditions.push("i.subcatid = ?");
      values.push(subcatid);
    }

    if (status) {
      conditions.push("i.status = ?");
      values.push(status);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

    const query = `
      SELECT
        i.id,
        i.catid,
        i.subcatid,
        i.iname,
        i.unit,
        i.weight,
        i.tax,
        i.mrp,
        i.offerprice,
        i.description,
        i.min_stock,
        i.isstockable,
        i.status,
        c.name AS category_name,
        s.subcat AS subcategory_name,
        img.filename AS image_filename,
        img.path AS image_path,
        img.mimetype AS image_mimetype
      FROM items i
      LEFT JOIN categories c ON i.catid = c.id
      LEFT JOIN subcategory s ON i.subcatid = s.id
      LEFT JOIN (
        SELECT product_id, MIN(id) AS first_image_id
        FROM item_images
        GROUP BY product_id
      ) fi ON fi.product_id = i.id
      LEFT JOIN item_images img ON img.id = fi.first_image_id
      ${whereClause}
      ORDER BY i.catid, i.subcatid, i.iname;
    `;

    const [rows] = await db.query(query, values);
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error("kiosk:getItems", err);
    res.status(500).json({ success: false, message: "Failed to fetch items" });
  }
};

const getItemById = async (req, res) => {
  const { id } = req.params;
  try {
    const itemQuery = `
      SELECT
        i.id,
        i.catid,
        i.subcatid,
        i.iname,
        i.unit,
        i.weight,
        i.tax,
        i.mrp,
        i.offerprice,
        i.description,
        i.min_stock,
        i.isstockable,
        i.status,
        c.name AS category_name,
        s.subcat AS subcategory_name
      FROM items i
      LEFT JOIN categories c ON i.catid = c.id
      LEFT JOIN subcategory s ON i.subcatid = s.id
      WHERE i.id = ?
      LIMIT 1;
    `;

    const [itemRows] = await db.query(itemQuery, [id]);
    if (!itemRows.length) {
      return res
        .status(404)
        .json({ success: false, message: "Item not found" });
    }

    const [images] = await db.query(
      `SELECT id, filename, path, mimetype, size, dateUploaded FROM item_images WHERE product_id = ? ORDER BY id ASC`,
      [id]
    );

    res.json({ success: true, data: { ...itemRows[0], images } });
  } catch (err) {
    console.error("kiosk:getItemById", err);
    res.status(500).json({ success: false, message: "Failed to fetch item" });
  }
};

const getMenu = async (_req, res) => {
  try {
    const [categories] = await db.query(
      "SELECT id, name FROM categories ORDER BY name ASC"
    );
    const [subcategories] = await db.query(
      "SELECT id, cat_id, subcat FROM subcategory ORDER BY subcat ASC"
    );
    const [items] = await db.query(`
      SELECT
        i.id,
        i.catid,
        i.subcatid,
        i.iname,
        i.unit,
        i.weight,
        i.tax,
        i.mrp,
        i.offerprice,
        i.description,
        i.min_stock,
        i.isstockable,
        i.status,
        img.filename AS image_filename,
        img.path AS image_path,
        img.mimetype AS image_mimetype
      FROM items i
      LEFT JOIN (
        SELECT product_id, MIN(id) AS first_image_id
        FROM item_images
        GROUP BY product_id
      ) fi ON fi.product_id = i.id
      LEFT JOIN item_images img ON img.id = fi.first_image_id
      ORDER BY i.catid, i.subcatid, i.iname;
    `);

    const categoryMap = categories.map((cat) => ({
      id: cat.id,
      name: cat.name,
      subcategories: [],
    }));

    const subcategoryMap = {};
    for (const sub of subcategories) {
      if (!subcategoryMap[sub.cat_id]) {
        subcategoryMap[sub.cat_id] = [];
      }
      subcategoryMap[sub.cat_id].push({
        id: sub.id,
        name: sub.subcat,
        items: [],
      });
    }

    for (const cat of categoryMap) {
      cat.subcategories = subcategoryMap[cat.id] || [];
    }

    const subcatLookup = {};
    for (const cat of categoryMap) {
      for (const sub of cat.subcategories) {
        subcatLookup[sub.id] = sub;
      }
    }

    for (const item of items) {
      const sub = subcatLookup[item.subcatid];
      if (sub) {
        sub.items.push(item);
      }
    }

    res.json({ success: true, data: categoryMap });
  } catch (err) {
    console.error("kiosk:getMenu", err);
    res.status(500).json({ success: false, message: "Failed to build kiosk menu" });
  }
};

const getCompanyInfo = async (_req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT 
        id,
        name,
        tax_id,
        phone_number,
        email,
        address,
        website,
        city,
        state,
        zip_code,
        country,
        bank_name,
        account_number,
        account_name,
        routing_number,
        swift_code,
        payment_methods,
        terms_and_conditions,
        created_at,
        updated_at,
        is_active
      FROM company_profile
      WHERE is_active = 1
      ORDER BY updated_at DESC
      LIMIT 1`
    );

    if (!rows.length) {
      return res.status(404).json({ success: false, message: "Company profile not found" });
    }

    res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error("kiosk:getCompanyInfo", err);
    res.status(500).json({ success: false, message: "Failed to fetch company info" });
  }
};

module.exports = {
  getCategories,
  getSubcategoriesByCategory,
  getItems,
  getItemById,
  getMenu,
  getCompanyInfo,
};
