const { db } = require('./config/dbconnection');

async function cleanup() {
  try {
    const [rows] = await db.query('SELECT * FROM printer_config WHERE terminal_id = "TEST-UUID-001"');
    
    if (rows.length > 0) {
      console.log('Test Printer Found:');
      console.table(rows);
      
      await db.query('DELETE FROM printer_config WHERE terminal_id = "TEST-UUID-001"');
      console.log('\n✅ Test printer cleaned up successfully');
    } else {
      console.log('ℹ️  No test printer found to clean up');
    }
  } catch (error) {
    console.error ('❌ Error:', error.message);
  } finally {
    process.exit();
  }
}

cleanup();
