-- Allocent MFB: Portfolio 3 demo data (re-runnable reset)
-- One company, one HR wallet with NGN 200,000, four staff, five requests.

BEGIN;

TRUNCATE receipts, cards, wallet_transactions, payments, approvals,
  expense_requests, vendors, budget_allocations, department_wallets,
  company_accounts, staff, departments, companies RESTART IDENTITY CASCADE;

-- Company 1
INSERT INTO companies (name, rc_number, email)
VALUES ('Demo Logistics Ltd', 'RC200001', 'info@demologistics.ng');

-- Main account (after funding the HR wallet)
INSERT INTO company_accounts (company_id, account_number, balance)
VALUES (1, '1000000001', 800000);

-- Department 1 (HR) and its wallet (wallet 1)
INSERT INTO departments (company_id, name) VALUES (1, 'HR');
INSERT INTO department_wallets (department_id, balance) VALUES (1, 200000);

-- Staff: 1 = finance, 2 = HR manager, 3 and 4 = HR staff
INSERT INTO staff (company_id, department_id, full_name, email, role) VALUES
  (1, NULL, 'Kemi Adeyemi', 'kemi@demologistics.ng',  'FINANCE'),
  (1, 1,    'Musa Bello',   'musa@demologistics.ng',  'MANAGER'),
  (1, 1,    'Ada Obi',      'ada@demologistics.ng',   'STAFF'),
  (1, 1,    'Tunde Lawal',  'tunde@demologistics.ng', 'STAFF');

-- Vendor 1
INSERT INTO vendors (company_id, name, bank_name, account_number)
VALUES (1, 'PrintHub Ltd', 'GTBank', '2000000001');

-- The allocation that funded the wallet, and its ledger entry
INSERT INTO budget_allocations
  (wallet_id, source_account_id, allocated_by, amount, period_start, period_end)
VALUES (1, 1, 1, 200000, '2026-10-01', '2026-12-31');

INSERT INTO wallet_transactions
  (wallet_id, txn_type, amount, balance_after, allocation_id, reference)
VALUES (1, 'ALLOCATION', 200000, 200000, 1, 'ALLOC-1');

-- Expense requests
INSERT INTO expense_requests
  (wallet_id, requested_by, vendor_id, amount, category, description, status) VALUES
  (1, 3, 1, 150000, 'EQUIPMENT', 'Office printer',      'APPROVED'),  -- R1: both approvals
  (1, 4, 1, 150000, 'EQUIPMENT', 'Laptop',              'APPROVED'),  -- R2: both approvals
  (1, 3, 1, 120000, 'SOFTWARE',  'HR software licence', 'APPROVED'),  -- R3: manager only (missing finance)
  (1, 4, 1,  60000, 'TRAVEL',    'Training trip',       'APPROVED'),  -- R4: manager only (under threshold)
  (1, 3, 1,  50000, 'OTHER',     'Team lunch',          'PENDING');   -- R5: not yet approved

-- Approvals (level 1 = manager Musa, level 2 = finance Kemi)
INSERT INTO approvals (request_id, approver_id, approval_level, decision) VALUES
  (1, 2, 1, 'APPROVED'), (1, 1, 2, 'APPROVED'),
  (2, 2, 1, 'APPROVED'), (2, 1, 2, 'APPROVED'),
  (3, 2, 1, 'APPROVED'),
  (4, 2, 1, 'APPROVED');

COMMIT;

-- Starting state
SELECT wallet_id, balance FROM department_wallets;
SELECT request_id, requested_by, amount, status FROM expense_requests ORDER BY request_id;