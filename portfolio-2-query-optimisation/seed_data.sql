-- Allocent MFB: test data generator for Portfolio 2
-- Clears all existing data (including Portfolio 1 test rows) and loads realistic volume.
-- Note: company account balances are not reconciled against allocations; wallets and ledger are.

BEGIN;

SELECT setseed(0.42);  -- makes the random data reproducible

TRUNCATE receipts, cards, wallet_transactions, payments, approvals,
  expense_requests, vendors, budget_allocations, department_wallets,
  company_accounts, staff, departments, companies RESTART IDENTITY CASCADE;

-- 50 companies

INSERT INTO companies (name, rc_number, email)
SELECT (ARRAY['Zenith','Bluewave','Crestline','Harmattan','Lagoon','Savanna','Kolanut',
              'Riverside','Sahel','Delta'])[1 + (g % 10)]
       || ' ' || (ARRAY['Logistics','Media','Foods','Energy','Tech','Agro','Pharma',
                        'Realty','Telecom','Textiles'])[1 + ((g / 10) % 10)] || ' Ltd ' || g,
       'RC' || (100000 + g),
       'info@company' || g || '.ng'
FROM generate_series(1, 50) g;

-- One main account per company

INSERT INTO company_accounts (company_id, account_number, balance)
SELECT company_id, (1000000000 + company_id)::text, 5000000000
FROM companies;

-- 6 departments per company (300 total)

INSERT INTO departments (company_id, name)
SELECT c.company_id, d.name
FROM companies c
CROSS JOIN unnest(ARRAY['HR','Development','Finance','Sales','Operations','Admin']) AS d(name);

-- One wallet per department
INSERT INTO department_wallets (department_id)
SELECT department_id FROM departments;

-- 10 staff per department: 1 manager + 9 staff

INSERT INTO staff (company_id, department_id, full_name, email, role)
SELECT d.company_id, d.department_id,
       (ARRAY['Ada','Musa','Kemi','Tunde','Ngozi','Ibrahim','Chinedu','Aisha','Femi','Zainab'])[1 + floor(random()*10)::int]
       || ' ' ||
       (ARRAY['Obi','Bello','Adeyemi','Okafor','Sani','Eze','Balogun','Usman','Nwosu','Lawal'])[1 + floor(random()*10)::int],
       'staff' || d.department_id || '_' || s || '@company' || d.company_id || '.ng',
       CASE WHEN s = 1 THEN 'MANAGER' ELSE 'STAFF' END
FROM departments d
CROSS JOIN generate_series(1, 10) s;

-- One FINANCE officer and one ADMIN per company (no department)

INSERT INTO staff (company_id, department_id, full_name, email, role)
SELECT company_id, NULL::int, 'Finance Officer ' || company_id,
       'finance@company' || company_id || '.ng', 'FINANCE'
FROM companies
UNION ALL
SELECT company_id, NULL::int, 'Company Admin ' || company_id,
       'admin@company' || company_id || '.ng', 'ADMIN'
FROM companies;

-- 20 vendors per company (1,000 total)

INSERT INTO vendors (company_id, name, bank_name, account_number)
SELECT c.company_id,
       (ARRAY['PrintHub','SwiftCabs','CloudNaija','OfficeMart','PowerGen','FuelPoint',
              'NetLink','DeskPro','CleanServe','TechHub'])[1 + (v % 10)] || ' ' || v,
       (ARRAY['Access Bank','GTBank','Zenith Bank','First Bank','UBA'])[1 + (v % 5)],
       '2' || lpad((c.company_id * 100 + v)::text, 9, '0')
FROM companies c
CROSS JOIN generate_series(1, 20) v;

-- Quarterly budget allocations: 7 quarters per wallet (Jan 2025 to Jul 2026)

INSERT INTO budget_allocations
  (wallet_id, source_account_id, allocated_by, amount, period_start, period_end, allocated_at)
SELECT w.wallet_id, a.account_id, f.staff_id, 30000000,
       q::date, (q + interval '3 months' - interval '1 day')::date, q
FROM department_wallets w
JOIN departments d      ON d.department_id = w.department_id
JOIN company_accounts a ON a.company_id = d.company_id
JOIN staff f            ON f.company_id = d.company_id AND f.role = 'FINANCE'
CROSS JOIN generate_series(timestamptz '2025-01-01', timestamptz '2026-07-01', interval '3 months') q;

-- Lookup helpers for fast random picks (dropped automatically at COMMIT)

CREATE TEMP TABLE dept_staff ON COMMIT DROP AS
  SELECT department_id, array_agg(staff_id) AS ids
  FROM staff WHERE role = 'STAFF' GROUP BY department_id;

CREATE TEMP TABLE dept_manager ON COMMIT DROP AS
  SELECT department_id, staff_id
  FROM staff WHERE role = 'MANAGER';

CREATE TEMP TABLE company_vendors ON COMMIT DROP AS
  SELECT company_id, array_agg(vendor_id) AS ids
  FROM vendors GROUP BY company_id;

-- 200,000 expense requests (Jan 2025 to Sep 2026)

WITH reqs AS (
  SELECT g,
         1 + floor(random() * 300)::int AS wallet_id,
         timestamptz '2025-01-02'
           + random() * (timestamptz '2026-09-30' - timestamptz '2025-01-02') AS created_at,
         round((5000 + random() * 495000)::numeric, 2) AS amount,
         (ARRAY['TRAVEL','SOFTWARE','EQUIPMENT','FUEL','UTILITIES','OTHER'])[1 + floor(random()*6)::int] AS category,
         random() AS r
  FROM generate_series(1, 200000) g
)
INSERT INTO expense_requests
  (wallet_id, requested_by, vendor_id, amount, category, description, status, created_at)
SELECT r.wallet_id,
       ds.ids[1 + floor(random() * cardinality(ds.ids))::int],
       cv.ids[1 + floor(random() * cardinality(cv.ids))::int],
       r.amount, r.category,
       initcap(r.category) || ' expense #' || r.g,
       CASE WHEN r.r < 0.70 THEN 'PAID'
            WHEN r.r < 0.80 THEN 'APPROVED'
            WHEN r.r < 0.90 THEN 'REJECTED'
            ELSE 'PENDING' END,
       r.created_at
FROM reqs r
JOIN department_wallets w ON w.wallet_id = r.wallet_id
JOIN departments d        ON d.department_id = w.department_id
JOIN dept_staff ds        ON ds.department_id = d.department_id
JOIN company_vendors cv   ON cv.company_id = d.company_id;

-- Level 1 (manager) decisions for every non-pending request

INSERT INTO approvals (request_id, approver_id, approval_level, decision, decided_at)
SELECT e.request_id, m.staff_id, 1,
       CASE WHEN e.status = 'REJECTED' THEN 'REJECTED' ELSE 'APPROVED' END,
       e.created_at + interval '1 hour'
FROM expense_requests e
JOIN department_wallets w ON w.wallet_id = e.wallet_id
JOIN dept_manager m       ON m.department_id = w.department_id
WHERE e.status <> 'PENDING';

-- Level 2 (finance) approval for approved/paid requests above N100,000

INSERT INTO approvals (request_id, approver_id, approval_level, decision, decided_at)
SELECT e.request_id, f.staff_id, 2, 'APPROVED', e.created_at + interval '1 day'
FROM expense_requests e
JOIN department_wallets w ON w.wallet_id = e.wallet_id
JOIN departments d        ON d.department_id = w.department_id
JOIN staff f              ON f.company_id = d.company_id AND f.role = 'FINANCE'
WHERE e.status IN ('APPROVED','PAID') AND e.amount > 100000;

-- Payments for PAID requests
INSERT INTO payments (request_id, amount, reference, status, paid_at)
SELECT request_id, amount, 'PAY' || lpad(request_id::text, 10, '0'),
       'SUCCESSFUL', created_at + interval '2 days'
FROM expense_requests
WHERE status = 'PAID';

-- Receipts for PAID requests
INSERT INTO receipts (request_id, file_path, uploaded_at)
SELECT request_id, 'receipts/' || request_id || '.jpg', created_at + interval '3 hours'
FROM expense_requests
WHERE status = 'PAID';

-- One card per department manager
INSERT INTO cards (staff_id, wallet_id, masked_pan, spending_limit)
SELECT m.staff_id, w.wallet_id,
       '5399 **** **** ' || lpad((m.staff_id % 10000)::text, 4, '0'), 500000
FROM dept_manager m
JOIN department_wallets w ON w.department_id = m.department_id;

-- Ledger: allocations in, payments out, with a running balance per wallet
INSERT INTO wallet_transactions
  (wallet_id, txn_type, amount, balance_after, allocation_id, payment_id, reference, created_at)
SELECT wallet_id, txn_type, amount,
       SUM(CASE WHEN txn_type = 'ALLOCATION' THEN amount ELSE -amount END)
         OVER (PARTITION BY wallet_id ORDER BY created_at, sort_key
               ROWS UNBOUNDED PRECEDING),
       allocation_id, payment_id, reference, created_at
FROM (
  SELECT wallet_id, 'ALLOCATION' AS txn_type, amount, allocation_id,
         NULL::int AS payment_id, 'ALLOC' || allocation_id AS reference,
         allocated_at AS created_at, 0 AS sort_key
  FROM budget_allocations
  UNION ALL
  SELECT e.wallet_id, 'PAYMENT', p.amount, NULL::int, p.payment_id, p.reference,
         p.paid_at, 1
  FROM payments p
  JOIN expense_requests e ON e.request_id = p.request_id
) t;

-- Set each wallet's stored balance to its latest ledger balance
UPDATE department_wallets w
SET balance = t.balance_after
FROM (
  SELECT DISTINCT ON (wallet_id) wallet_id, balance_after
  FROM wallet_transactions
  ORDER BY wallet_id, created_at DESC, txn_id DESC
) t
WHERE w.wallet_id = t.wallet_id;

COMMIT;

-- Refresh planner statistics so execution plans are accurate
ANALYZE;

