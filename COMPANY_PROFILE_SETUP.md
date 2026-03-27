# Company Profile Setup Guide

## Overview
The Company Profile module allows you to manage central company information including basic details, branding assets, banking information, and payment methods. This data is used across the system for invoices, receipts, and general business documentation.

## Database Setup

### Step 1: Create the Company Profile Table
Run the SQL script to create the company_profile table:

```bash
# Option 1: Using MySQL CLI
mysql -u root -p chefmatepro < database/create_company_profile_table.sql

# Option 2: Using a database GUI (phpMyAdmin)
# Import the database/create_company_profile_table.sql file
```

### Step 2: Seed Initial Company Data
Run the Node.js setup script to insert the default company profile:

```bash
node setup-company-profile.js
```

This will:
- Create initial company profile with default data
- Display the inserted data
- Set the company profile status to active

## API Endpoints

### Get All Company Profiles
```http
GET /getdata/companyinfo
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Banglore Cafe",
      "tax_id": "TAX123456789",
      "phone_number": "+1-555-123-4567",
      "email": "info@chefmate.com",
      "address": "123 Restaurant Street, Food District",
      "website": "https://www.chefmate.com",
      "city": "Bangkok",
      "state": "Bangkok Metropolitan",
      "zip_code": "10110",
      "country": "Thailand",
      "logo": null,
      "logo_type": null,
      "logo_name": null,
      "qr_code": null,
      "qr_code_type": null,
      "qr_code_name": null,
      "bank_name": "Bangkok Bank",
      "account_number": null,
      "account_name": "ChefMate Restaurant Solutions Co., Ltd.",
      "routing_number": null,
      "swift_code": null,
      "payment_methods": "Cash, Credit Card, Debit Card, Bank Transfer, Mobile Payment",
      "terms_and_conditions": "...",
      "created_at": "2025-09-06 07:35:14",
      "updated_at": "2025-10-03 06:47:50",
      "created_by": 1,
      "updated_by": 1,
      "is_active": 1
    }
  ]
}
```

### Create Company Profile
```http
POST /insertdata/companyinfo
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "Banglore Cafe",
  "tax_id": "TAX123456789",
  "phone_number": "+1-555-123-4567",
  "email": "info@chefmate.com",
  "address": "123 Restaurant Street, Food District",
  "website": "https://www.chefmate.com",
  "city": "Bangkok",
  "state": "Bangkok Metropolitan",
  "zip_code": "10110",
  "country": "Thailand",
  "logo": <file>,
  "logo_type": "image/png",
  "logo_name": "company-logo.png",
  "qr_code": <file>,
  "qr_code_type": "image/png",
  "qr_code_name": "company-qr.png",
  "bank_name": "Bangkok Bank",
  "account_number": "1234567890",
  "account_name": "ChefMate Restaurant Solutions Co., Ltd.",
  "routing_number": "021000021",
  "swift_code": "BKKMMTH",
  "payment_methods": "Cash, Credit Card, Debit Card, Bank Transfer, Mobile Payment",
  "terms_and_conditions": "..."
}
```

### Update Company Profile
```http
PUT /updatedata/companyinfo/{id}
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "Updated Company Name",
  "email": "newemail@chefmate.com",
  ... (other fields)
}
```

### Delete Company Profile
```http
DELETE /deletedata/companyinfo/{id}
Authorization: Bearer {token}
```

## Frontend Usage

### Access the Company Profile Settings
1. Navigate to **Settings** > **Company Information**
2. The form has 4 tabs:
   - **Basic Info**: Company name, tax ID, contact info, address
   - **Branding**: Logo and QR code uploads
   - **Banking**: Bank account details and payment methods
   - **Terms**: Terms and conditions text

### Form Fields

#### Basic Info Tab
- **Company Name** *(Required, SuperAdmin Only)*
- **Tax ID** *(Required, SuperAdmin Only)*
- **Phone Number** *(Required)*
- **Email** *(Required)*
- **Address** *(Required)*
- **Website** (Optional)
- **City, State, Zip Code, Country** (Optional)

#### Branding Tab
- **Company Logo** (Optional, Max 5MB)
- **QR Code** (Optional, Max 5MB)

#### Banking Tab
- **Bank Name** (Optional)
- **Account Number** (Optional)
- **Account Name** (Optional)
- **Routing Number** (Optional)
- **SWIFT Code** (Optional)
- **Payment Methods** (Optional)

#### Terms Tab
- **Terms and Conditions** (Optional, Supports multiline text)

## Data Structure

### Table: company_profile

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| id | INT | NO | Primary Key, Auto Increment |
| shop_id | INT | NO | Foreign Key to shops table - Multi-tenant isolation |
| name | VARCHAR(255) | NO | Company name |
| tax_id | VARCHAR(100) | NO | Unique per shop, Tax identification |
| phone_number | VARCHAR(50) | NO | Primary phone |
| email | VARCHAR(255) | NO | Unique per shop, Primary email |
| address | TEXT | NO | Full address |
| website | VARCHAR(255) | YES | Website URL |
| city | VARCHAR(100) | YES | City |
| state | VARCHAR(100) | YES | State/Province |
| zip_code | VARCHAR(20) | YES | ZIP code |
| country | VARCHAR(100) | YES | Country |
| logo | LONGBLOB | YES | Logo image binary |
| logo_type | VARCHAR(50) | YES | Logo MIME type |
| logo_name | VARCHAR(255) | YES | Original logo filename |
| qr_code | LONGBLOB | YES | QR code image binary |
| qr_code_type | VARCHAR(50) | YES | QR code MIME type |
| qr_code_name | VARCHAR(255) | YES | Original QR code filename |
| bank_name | VARCHAR(255) | YES | Bank name |
| account_number | VARCHAR(100) | YES | Account number |
| account_name | VARCHAR(255) | YES | Account holder name |
| routing_number | VARCHAR(50) | YES | Routing number |
| swift_code | VARCHAR(20) | YES | SWIFT/BIC code |
| payment_methods | TEXT | YES | Payment methods accepted |
| terms_and_conditions | TEXT | YES | T&C text |
| created_at | TIMESTAMP | NO | Record creation time |
| updated_at | TIMESTAMP | NO | Record update time |
| created_by | INT | YES | User ID of creator |
| updated_by | INT | YES | User ID of updater |
| is_active | TINYINT(1) | NO | Status (1=active, 0=inactive) |

## Features

### File Upload
- **Logo Upload**: Supports JPG, PNG, GIF (Max 5MB)
- **QR Code Upload**: Supports JPG, PNG, GIF (Max 5MB)
- Files are stored as BLOBs in the database
- Preview functionality before saving

### Validation
- Email validation (RFC standard format)
- Phone number validation (10+ digits with optional +)
- URL validation (must start with http:// or https://)
- Banking fields: Account number required if bank name provided

### Access Control
- **SuperAdmin Only Fields**: Company Name, Tax ID
- Other users can view but not edit these fields
- All other fields are editable by authorized users

### Image Handling
- Images are converted to base64 for preview
- BLOB format for database storage
- MIME type tracking for proper rendering

## Troubleshooting

### Issue: "Table doesn't exist"
**Solution**: Run the database creation script first
```bash
mysql -u root -p chefmatepro < database/create_company_profile_table.sql
```

### Issue: "Duplicate entry for key 'unique_tax_id'"
**Solution**: The tax ID already exists. Use a unique value or update the existing record.

### Issue: "File size exceeds limit"
**Solution**: Compress the image file to under 5MB or use a smaller image.

### Issue: "Only SuperAdmin can modify this field"
**Solution**: Log in as SuperAdmin or contact your administrator to change company name/tax ID.

## File Size Considerations

The BLOB fields (logo, qr_code) store binary image data. Consider:
- Each field can hold up to 4GB of data
- Practical limit: Keep images under 5MB for good performance
- Recommended image sizes:
  - Logo: 500x200px or similar aspect ratio
  - QR Code: 200x200px (fixed size)

## Best Practices

1. **Keep Information Updated**: Update company profile whenever details change
2. **High-Quality Logo**: Use high-resolution logo for professional appearance
3. **Clear QR Code**: Ensure QR code is clear and scannable
4. **Complete Banking Info**: Add all banking details for proper invoicing
5. **Clear T&C**: Write clear and concise terms and conditions
6. **Regular Backups**: Backup the database regularly to prevent data loss

## Security Notes

- Company profile data is accessible based on user roles
- SuperAdmin fields are protected from unauthorized modification
- All file uploads are validated for file type and size
- Sensitive banking information is stored securely in the database
- Access requires valid authentication token

## Related Documentation

- [API Error Logging Service](../API_ERROR_LOGGING_SERVICE.md)
- [Settings Guide](./SETTINGS_GUIDE.md)
- [Database Schema](../TECHNICAL_ARCHITECTURE.md)

## Support

For issues or questions, contact: support@chefmate.com
