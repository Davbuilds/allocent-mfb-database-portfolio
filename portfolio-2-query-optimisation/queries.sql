-- Allocent MFB: Portfolio 2 business queries

-- Q1. A staff member's 20 most recent expense requests (staff "My Requests" screen)
SELECT request_id, amount, category, status, created_at
FROM expense_requests
WHERE requested_by = 2323
ORDER BY created_at DESC
LIMIT 20;

-- Q2. Wallet statement: all ledger entries for one wallet in one month
SELECT txn_id, txn_type, amount, balance_after, reference, created_at
FROM wallet_transactions
WHERE wallet_id = 42
  AND created_at >= '2026-03-01' AND created_at < '2026-04-01'
ORDER BY created_at;

-- Q3. Pending requests awaiting a manager's decision for one department wallet
SELECT request_id, requested_by, amount, category, created_at
FROM expense_requests
WHERE wallet_id = 42 AND status = 'PENDING'
ORDER BY created_at;

-- Q4. Spending per department for one company in one quarter (finance report)
SELECT d.name AS department, count(*) AS payments, SUM(p.amount) AS total_spent
FROM payments p
JOIN expense_requests e   ON e.request_id = p.request_id
JOIN department_wallets w ON w.wallet_id = e.wallet_id
JOIN departments d        ON d.department_id = w.department_id
WHERE d.company_id = 7
  AND p.paid_at >= '2026-04-01' AND p.paid_at < '2026-07-01'
GROUP BY d.name
ORDER BY total_spent DESC;

-- Q5. Top 5 vendors by total paid for one company (vendor analysis)
SELECT v.name, v.bank_name, count(*) AS payments, SUM(p.amount) AS total_paid
FROM payments p
JOIN expense_requests e ON e.request_id = p.request_id
JOIN vendors v          ON v.vendor_id = e.vendor_id
WHERE v.company_id = 7
GROUP BY v.vendor_id, v.name, v.bank_name
ORDER BY total_paid DESC
LIMIT 5;