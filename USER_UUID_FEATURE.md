# User UUID Feature

## Overview
This feature adds a unique UUID (Universally Unique Identifier) to each user that is generated on their **first login**.

## Database Changes

### New Column: `user_uuid`
- **Type**: VARCHAR(36)
- **Default**: NULL
- **Index**: Added for performance
- **Location**: After `id` column in `users` table

## Setup Instructions

### 1. Run Database Migration

**Option A: Using the setup script (Recommended)**
```bash
node setup-user-uuid.js
```

**Option B: Using MySQL directly**
```bash
mysql -u root -p chefmatepro < database/add_user_uuid_column.sql
```

### 2. Restart the Backend Server
```bash
npm start
```

## How It Works

1. **Before First Login**: `user_uuid` is `NULL` for all users
2. **On First Login**: 
   - System checks if `user_uuid` is `NULL`
   - If `NULL`, generates a new random UUID (e.g., `"550e8400-e29b-41d4-a716-446655440000"`)
   - Saves the UUID in the database
   - Returns user data with UUID included
3. **Subsequent Logins**: UUID remains the same (not regenerated)

## Example UUID Format
```
550e8400-e29b-41d4-a716-446655440000
```

## Code Changes

### Modified Files
1. **controllers/userControl.js**
   - Added `crypto` import for UUID generation
   - Modified `login()` function to check and generate UUID on first login

2. **database/add_user_uuid_column.sql**
   - SQL migration to add the column

3. **setup-user-uuid.js**
   - Automated setup script

## API Response

After login, the user object will include the UUID:

```json
{
  "msg": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": 123,
    "user_uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Admin",
    "uname": "3130",
    "email": "admin@gmail.com",
    "type": "admin",
    "status": 1,
    "last_loggedin": "2026-03-03 16:30:00"
  }
}
```

## Benefits

- ✅ Unique identifier for each user independent of database ID
- ✅ Can be used for external integrations
- ✅ Useful for device binding/authentication
- ✅ Can track users across different systems
- ✅ Auto-generated on first login (no manual intervention)

## Technical Notes

- Uses Node.js built-in `crypto.randomUUID()` (RFC 4122 version 4)
- UUID is generated only once per user
- No performance impact on subsequent logins
- Index added for efficient queries by UUID

## Verification

To verify users have UUIDs after logging in:

```sql
SELECT id, name, uname, user_uuid FROM users WHERE user_uuid IS NOT NULL;
```

## Rollback (If Needed)

To remove the UUID column:

```sql
ALTER TABLE users DROP COLUMN user_uuid;
ALTER TABLE users DROP INDEX idx_user_uuid;
```
