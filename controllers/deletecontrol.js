const { validationResult } = require('express-validator')
const bcrypt = require('bcryptjs')
const { db } = require('../config/dbconnection')
const jwt = require('jsonwebtoken')
const fs = require('fs')
const path = require('path')
const { jwt_secret } = process.env

// const deletedatabyid = async (req, res) => {
//   const authToken = req.headers.authorization.split(' ')[1]
//   const decode = jwt.verify(authToken, jwt_secret)
//   const colval1 = [req.params.colval]
//   const colname1 = [req.params.colname]
//   const table = [req.params.tablename]
// try {
//   await db.query(`DELETE FROM ${table} WHERE ${colname1}=?`,colval1);
//   return res.status(200).json({ message: `Record with ID ${colval1} deleted from ${table}` });
// }
// catch(err)
// {
//  console.error('Error deleting record:', error);
//     return res.status(500).json({ message: 'Internal Server Error', error: error.message });
 

// }
 
// }
const deletedatabyid = async (req, res) => {
  try {
    console.log("🟢 DELETE REQUEST RECEIVED");
    console.log("📋 Request params:", req.params);
    console.log("📋 Request body:", req.body);
    console.log("📋 Request headers:", req.headers);

    const { tablename, colname, colval } = req.params;
    
    console.log("🔍 Extracted parameters:");
    console.log("  - Table:", tablename);
    console.log("  - Column:", colname);
    console.log("  - Value:", colval);

    // Validate required parameters
    if (!tablename || !colname || !colval) {
      console.log("❌ Missing required parameters");
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required parameters: tablename, colname, or colval' 
      });
    }

    // Whitelist of allowed tables for security
    const allowedTables = [
      'items', 'customers', 'suppliers', 'inventory', 'orders', 
      'order_items', 'advance_order_items', 'final_bill', 'payments',
      'categories', 'units', 'taxes', 'discounts'
    ];

    if (!allowedTables.includes(tablename)) {
      console.log("❌ Invalid table name:", tablename);
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid table name' 
      });
    }

    // Check if record exists before deletion
    const checkQuery = `SELECT COUNT(*) as count FROM ?? WHERE ?? = ?`;
    console.log("🔍 Check query:", checkQuery);
    console.log("🔍 Check params:", [tablename, colname, colval]);

    const [checkResult] = await db.query(checkQuery, [tablename, colname, colval]);
    const recordCount = checkResult[0].count;
    
    console.log("📊 Records found:", recordCount);

    if (recordCount === 0) {
      console.log("❌ No records found to delete");
      return res.status(404).json({ 
        success: false, 
        message: 'Record not found' 
      });
    }

    // Perform deletion
    const deleteQuery = `DELETE FROM ?? WHERE ?? = ?`;
    console.log("🗑️ Delete query:", deleteQuery);
    console.log("🗑️ Delete params:", [tablename, colname, colval]);

    const [result] = await db.query(deleteQuery, [tablename, colname, colval]);
    
    console.log("✅ Delete result:", result);
    console.log("📊 Affected rows:", result.affectedRows);

    if (result.affectedRows > 0) {
      console.log("✅ Deletion successful");
      res.status(200).json({ 
        success: true, 
        message: `${result.affectedRows} record(s) deleted successfully`,
        affectedRows: result.affectedRows
      });
    } else {
      console.log("❌ No rows affected");
      res.status(400).json({ 
        success: false, 
        message: 'No records were deleted' 
      });
    }

  } catch (error) {
    console.error("❌ DELETE ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting record', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

// Add bulk delete function
const deleteBulkData = async (req, res) => {
  try {
    console.log("🟢 BULK DELETE REQUEST RECEIVED");
    console.log("📋 Request params:", req.params);
    console.log("📋 Request body:", req.body);

    const { tablename } = req.params;
    const { ids, columnName = 'id' } = req.body;

    console.log("🔍 Extracted parameters:");
    console.log("  - Table:", tablename);
    console.log("  - Column:", columnName);
    console.log("  - IDs:", ids);

    // Validate required parameters
    if (!tablename || !ids || !Array.isArray(ids) || ids.length === 0) {
      console.log("❌ Missing or invalid parameters");
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required parameters: tablename or ids array' 
      });
    }

    // Whitelist of allowed tables for security
    const allowedTables = [
      'items', 'customers', 'suppliers', 'inventory', 'orders', 
      'order_items', 'advance_order_items', 'final_bill', 'payments',
      'categories', 'units', 'taxes', 'discounts'
    ];

    if (!allowedTables.includes(tablename)) {
      console.log("❌ Invalid table name:", tablename);
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid table name' 
      });
    }

    // Create placeholders for IN clause
    const placeholders = ids.map(() => '?').join(',');
    
    // Check if records exist before deletion
    const checkQuery = `SELECT COUNT(*) as count FROM ?? WHERE ?? IN (${placeholders})`;
    console.log("🔍 Check query:", checkQuery);
    console.log("🔍 Check params:", [tablename, columnName, ...ids]);

    const [checkResult] = await db.query(checkQuery, [tablename, columnName, ...ids]);
    const recordCount = checkResult[0].count;
    
    console.log("📊 Records found:", recordCount);

    if (recordCount === 0) {
      console.log("❌ No records found to delete");
      return res.status(404).json({ 
        success: false, 
        message: 'No records found to delete' 
      });
    }

    // Perform bulk deletion
    const deleteQuery = `DELETE FROM ?? WHERE ?? IN (${placeholders})`;
    console.log("🗑️ Delete query:", deleteQuery);
    console.log("🗑️ Delete params:", [tablename, columnName, ...ids]);

    const [result] = await db.query(deleteQuery, [tablename, columnName, ...ids]);
    
    console.log("✅ Bulk delete result:", result);
    console.log("📊 Affected rows:", result.affectedRows);

    if (result.affectedRows > 0) {
      console.log("✅ Bulk deletion successful");
      res.status(200).json({ 
        success: true, 
        message: `${result.affectedRows} record(s) deleted successfully`,
        affectedRows: result.affectedRows,
        requestedIds: ids,
        deletedCount: result.affectedRows
      });
    } else {
      console.log("❌ No rows affected in bulk delete");
      res.status(400).json({ 
        success: false, 
        message: 'No records were deleted' 
      });
    }

  } catch (error) {
    console.error("❌ BULK DELETE ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting records', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

// Delete item with associated images and files
const deleteItemById = async (req, res) => {
  try {
    console.log("🟢 DELETE ITEM REQUEST RECEIVED");
    console.log("📋 Request params:", req.params);

    const { id } = req.params;
    
    console.log("🔍 Item ID to delete:", id);

    // Validate required parameters
    if (!id) {
      console.log("❌ Missing item ID");
      return res.status(400).json({ 
        success: false, 
        message: 'Item ID is required' 
      });
    }

    // Start database transaction
    await db.query('START TRANSACTION');

    try {
      // Step 1: Get all images associated with this item
      console.log("🔍 Fetching images for item ID:", id);
      const imageQuery = `SELECT id, path, filename FROM item_images WHERE product_id = ?`;
      const [imageResults] = await db.query(imageQuery, [id]);
      
      console.log("📸 Images found:", imageResults.length);
      console.log("📸 Image details:", imageResults);

      // Step 2: Check if item exists
      const itemCheckQuery = `SELECT COUNT(*) as count FROM items WHERE id = ?`;
      const [itemCheckResult] = await db.query(itemCheckQuery, [id]);
      const itemExists = itemCheckResult[0].count > 0;

      if (!itemExists) {
        await db.query('ROLLBACK');
        console.log("❌ Item not found");
        return res.status(404).json({ 
          success: false, 
          message: 'Item not found' 
        });
      }

      // Step 3: Delete image files from upload folder
      let deletedFiles = [];
      let failedFiles = [];

      for (const image of imageResults) {
        try {
          // Try different possible paths for the image
          const possiblePaths = [
            path.join(__dirname, '../uploads', image.filename),
            path.join(__dirname, '../uploads', image.path),
            path.join(__dirname, '..', image.path)
          ];

          let fileDeleted = false;
          for (const filePath of possiblePaths) {
            if (fs.existsSync(filePath)) {
              console.log("🗑️ Deleting file:", filePath);
              fs.unlinkSync(filePath);
              deletedFiles.push(filePath);
              fileDeleted = true;
              break;
            }
          }

          if (!fileDeleted) {
            console.log("⚠️ File not found at any expected path:", image.filename);
            failedFiles.push(image.filename);
          }

        } catch (fileError) {
          console.error("❌ Error deleting file:", image.filename, fileError.message);
          failedFiles.push(image.filename);
        }
      }

      // Step 4: Delete images from database
      if (imageResults.length > 0) {
        console.log("🗑️ Deleting images from database");
        const deleteImagesQuery = `DELETE FROM item_images WHERE product_id = ?`;
        const [deleteImagesResult] = await db.query(deleteImagesQuery, [id]);
        console.log("✅ Images deleted from database:", deleteImagesResult.affectedRows);
      }

      // Step 5: Delete item from database
      console.log("🗑️ Deleting item from database");
      const deleteItemQuery = `DELETE FROM items WHERE id = ?`;
      const [deleteItemResult] = await db.query(deleteItemQuery, [id]);
      
      console.log("✅ Item delete result:", deleteItemResult);

      if (deleteItemResult.affectedRows === 0) {
        await db.query('ROLLBACK');
        return res.status(400).json({ 
          success: false, 
          message: 'Failed to delete item' 
        });
      }

      // Commit transaction
      await db.query('COMMIT');
      console.log("✅ Transaction committed successfully");

      // Prepare response
      const response = {
        success: true,
        message: 'Item and associated data deleted successfully',
        details: {
          itemId: id,
          itemDeleted: true,
          imagesDeletedFromDB: imageResults.length,
          filesDeletedFromDisk: deletedFiles.length,
          failedFilesDeletion: failedFiles.length
        }
      };

      if (deletedFiles.length > 0) {
        response.details.deletedFiles = deletedFiles;
      }

      if (failedFiles.length > 0) {
        response.details.failedFiles = failedFiles;
        response.message += ` (Warning: ${failedFiles.length} files could not be deleted from disk)`;
      }

      console.log("✅ Delete operation completed:", response);
      res.status(200).json(response);

    } catch (transactionError) {
      // Rollback transaction on error
      await db.query('ROLLBACK');
      console.error("❌ Transaction rolled back due to error:", transactionError);
      throw transactionError;
    }

  } catch (error) {
    console.error("❌ DELETE ITEM ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting item and associated data', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

// Delete multiple items with their images
const deleteBulkItemsById = async (req, res) => {
  try {
    console.log("🟢 BULK DELETE ITEMS REQUEST RECEIVED");
    console.log("📋 Request body:", req.body);

    const { ids } = req.body;

    // Validate required parameters
    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      console.log("❌ Missing or invalid item IDs");
      return res.status(400).json({ 
        success: false, 
        message: 'Array of item IDs is required' 
      });
    }

    console.log("🔍 Item IDs to delete:", ids);

    // Start database transaction
    await db.query('START TRANSACTION');

    try {
      let totalDeletedFiles = [];
      let totalFailedFiles = [];
      let deletedItemsCount = 0;
      let deletedImagesCount = 0;

      // Process each item
      for (const id of ids) {
        console.log(`\n🔄 Processing item ID: ${id}`);

        // Get all images for this item
        const imageQuery = `SELECT id, path, filename FROM item_images WHERE product_id = ?`;
        const [imageResults] = await db.query(imageQuery, [id]);
        
        console.log(`📸 Images found for item ${id}:`, imageResults.length);

        // Delete image files from upload folder
        for (const image of imageResults) {
          try {
            const possiblePaths = [
              path.join(__dirname, '../uploads', image.filename),
              path.join(__dirname, '../uploads', image.path),
              path.join(__dirname, '..', image.path)
            ];

            let fileDeleted = false;
            for (const filePath of possiblePaths) {
              if (fs.existsSync(filePath)) {
                console.log("🗑️ Deleting file:", filePath);
                fs.unlinkSync(filePath);
                totalDeletedFiles.push(filePath);
                fileDeleted = true;
                break;
              }
            }

            if (!fileDeleted) {
              console.log("⚠️ File not found:", image.filename);
              totalFailedFiles.push(`${id}:${image.filename}`);
            }

          } catch (fileError) {
            console.error("❌ Error deleting file:", image.filename, fileError.message);
            totalFailedFiles.push(`${id}:${image.filename}`);
          }
        }

        // Delete images from database for this item
        if (imageResults.length > 0) {
          const deleteImagesQuery = `DELETE FROM item_images WHERE product_id = ?`;
          const [deleteImagesResult] = await db.query(deleteImagesQuery, [id]);
          deletedImagesCount += deleteImagesResult.affectedRows;
          console.log(`✅ Images deleted from DB for item ${id}:`, deleteImagesResult.affectedRows);
        }
      }

      // Delete all items in one query
      const placeholders = ids.map(() => '?').join(',');
      const deleteItemsQuery = `DELETE FROM items WHERE id IN (${placeholders})`;
      const [deleteItemsResult] = await db.query(deleteItemsQuery, ids);
      deletedItemsCount = deleteItemsResult.affectedRows;
      
      console.log("✅ Items deleted from database:", deletedItemsCount);

      if (deletedItemsCount === 0) {
        await db.query('ROLLBACK');
        return res.status(400).json({ 
          success: false, 
          message: 'No items were deleted' 
        });
      }

      // Commit transaction
      await db.query('COMMIT');
      console.log("✅ Bulk delete transaction committed successfully");

      // Prepare response
      const response = {
        success: true,
        message: `${deletedItemsCount} items and associated data deleted successfully`,
        details: {
          requestedItemIds: ids,
          itemsDeleted: deletedItemsCount,
          imagesDeletedFromDB: deletedImagesCount,
          filesDeletedFromDisk: totalDeletedFiles.length,
          failedFilesDeletion: totalFailedFiles.length
        }
      };

      if (totalDeletedFiles.length > 0) {
        response.details.deletedFiles = totalDeletedFiles;
      }

      if (totalFailedFiles.length > 0) {
        response.details.failedFiles = totalFailedFiles;
        response.message += ` (Warning: ${totalFailedFiles.length} files could not be deleted from disk)`;
      }

      console.log("✅ Bulk delete operation completed:", response);
      res.status(200).json(response);

    } catch (transactionError) {
      // Rollback transaction on error
      await db.query('ROLLBACK');
      console.error("❌ Bulk delete transaction rolled back due to error:", transactionError);
      throw transactionError;
    }

  } catch (error) {
    console.error("❌ BULK DELETE ITEMS ERROR:", error);
    console.error("❌ Error details:", {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sqlMessage: error.sqlMessage,
      sqlState: error.sqlState,
      sql: error.sql
    });

    res.status(500).json({ 
      success: false, 
      message: 'Error deleting items and associated data', 
      error: error.message,
      sqlError: error.sqlMessage || 'Unknown SQL error'
    });
  }
};

module.exports = {
  deletedatabyid,
  deleteBulkData,
  deleteItemById,
  deleteBulkItemsById
};

