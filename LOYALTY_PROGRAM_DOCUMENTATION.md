# Loyalty Program V2 Documentation

## Overview
This version upgrades loyalty from a single flat point wallet into a shop-wise, multi-program system with configurable offers, redemption history, analytics, and notification queue support.

Key goals implemented:
- Each shop can manage loyalty program(s) separately.
- Shop admin can create any number of loyalty programs.
- Cashier can redeem eligible offers from POS CheckBill modal.
- Redemptions are recorded with offer details for analytics/KPI.
- LINE/SMS queue integration points are provided for customer notifications.

## Recommended Starter Setup for Small Restaurants
The API supports this starter rule model directly.

| Rule | Value |
| --- | --- |
| Earn | 1 point per 20 THB |
| Redeem | 100 points = 50 THB |
| Minimum Redeem | 100 points |
| Expiry | 6 months |
| Birthday Reward | Free dessert |

Starter setup endpoint:
- `POST /api/loyalty/programs/starter-setup`

## Data Model (V2)
Existing tables still used:
- `loyalty_members`
- `loyalty_transactions`

New tables:
1. `loyalty_programs`
- Per-shop program rules (earn, redeem, expiry, birthday rule, active flag).

2. `loyalty_member_programs`
- Per-member points balance per program.
- Supports multiple loyalty programs per customer.

3. `loyalty_offers`
- Configurable offers by program:
  - `DISCOUNT_AMOUNT`
  - `DISCOUNT_PERCENT`
  - `FREE_ITEM`

4. `loyalty_redemptions`
- Full redemption history with offer detail:
  - `offer_name`, `offer_type`, `points_used`, `discount_value`, `free_item_name`, `bill_id`

5. `loyalty_notification_queue`
- Queue for outgoing customer messages by channel:
  - `LINE`, `SMS`
  - `status` (`PENDING`, `SENT`, `FAILED`)

Migration script:
- `database/create-loyalty-program-v2.sql`

## API Endpoints
All endpoints are auth-protected and tenant-scoped by `shop_id`.

### Programs
- `GET /api/loyalty/programs`
- `POST /api/loyalty/programs`
- `PUT /api/loyalty/programs/:program_id`
- `POST /api/loyalty/programs/starter-setup`

### Offers
- `GET /api/loyalty/offers?program_id=...`
- `POST /api/loyalty/offers`
- `PUT /api/loyalty/offers/:offer_id`
- `GET /api/loyalty/offers/eligible/list?member_id=...&program_id=...&bill_amount=...`
- `POST /api/loyalty/offers/redeem`

### Members + Transactions
- `GET /api/loyalty/customers`
- `POST /api/loyalty/members/enroll`
- `GET /api/loyalty/transactions/:member_id`
- `POST /api/loyalty/transactions/earn`
- `POST /api/loyalty/transactions/redeem`
- `POST /api/loyalty/transactions/adjust`

### Redemption + Analytics
- `GET /api/loyalty/redemptions/history?member_id=...&customer_id=...`
- `GET /api/loyalty/analytics/dashboard`

### Notifications (Marketing Automation Queue)
- `POST /api/loyalty/notifications/line/queue`

Suggested campaign templates:
- `LOYALTY_NEAR_REWARD`: "You have 80 points left to get free pizza"
- `LOYALTY_BIRTHDAY`: birthday coupon message
- `LOYALTY_INACTIVE_REMINDER`: inactive customer reminder

## POS Integration (CheckBill Ant)
File:
- `src/components/Modals/CheckBillModalAnt.jsx`

Implemented cashier flow:
1. Open `Loyality Program` modal.
2. Search customer by mobile number.
3. Select customer.
4. Select loyalty program.
5. See eligible offers for current bill amount.
6. Redeem and apply selected offer to current bill.

Behavior:
- `DISCOUNT_AMOUNT`: applied as fixed discount in bill.
- `DISCOUNT_PERCENT`: applied as percentage discount in bill.
- `FREE_ITEM`: redemption logged, cashier is prompted to add item manually.

## Admin Side Capability Mapping
Implemented foundation for:
- Point rules per program
- Reward setup via offers
- Expiry rules per program
- Customer analytics dashboard data
- Top customer ranking
- Redemption history for KPI dashboards
- Marketing queue hooks (LINE/SMS)

## KPI/Analytics Dashboard Ideas
The endpoint `GET /api/loyalty/analytics/dashboard` already returns core blocks:
- `overview`
- `top_customers`
- `programs`
- `inactive_customers`

This can power dashboards like:
- Active members trend
- Redemption rate
- Discount cost vs repeat customer value
- Program-wise ROI

## Notes
- Existing legacy endpoints remain compatible.
- Existing loyalty member balances are preserved.
- Program-level balances are tracked separately in `loyalty_member_programs`.
- Notification sending is queued; actual LINE provider dispatch worker can be added separately.
