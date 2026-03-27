const shopIdTableCache = new WeakMap();

const getRequestShopId = (req) => {
  const candidates = [
    req.shop_id,
    req.params?.shop_id,
    req.query?.shop_id,
    req.body?.shop_id,
    req.user?.shop_id,
    req.session?.shop_id,
  ];

  for (const candidate of candidates) {
    const parsed = Number.parseInt(candidate, 10);
    if (Number.isInteger(parsed) && parsed > 0) {
      return parsed;
    }
  }

  return null;
};

const requireShopId = (req, res) => {
  const shopId = getRequestShopId(req);
  if (shopId !== null) {
    return shopId;
  }

  if (res && !res.headersSent) {
    res.status(400).json({
      success: false,
      message: 'shop_id is required for tenant-scoped access',
    });
  }

  return null;
};

const getShopIdTables = async (db) => {
  if (!db) {
    return new Set();
  }

  let cachedPromise = shopIdTableCache.get(db);
  if (!cachedPromise) {
    cachedPromise = db
      .query("SELECT TABLE_NAME FROM information_schema.COLUMNS WHERE COLUMN_NAME = 'shop_id' AND TABLE_SCHEMA = DATABASE()")
      .then(([rows]) => new Set(rows.map((row) => row.TABLE_NAME)))
      .catch(() => new Set());

    shopIdTableCache.set(db, cachedPromise);
  }

  return cachedPromise;
};

const tableHasShopId = async (db, tableName) => {
  if (!tableName) {
    return false;
  }

  const shopIdTables = await getShopIdTables(db);
  return shopIdTables.has(tableName);
};

module.exports = {
  getRequestShopId,
  requireShopId,
  tableHasShopId,
};