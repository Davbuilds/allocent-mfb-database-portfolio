-- Allocent MFB: execution plans for the five business queries
-- Run from the terminal with psql (the \qecho lines are psql commands).

\qecho '===== Q1: Staff member''s 20 most recent requests ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT request_id, amount, category, status, created_at
FROM expense_requests
WHERE requested_by = 2323
ORDER BY created_at DESC
LIMIT 20;

\qecho '===== Q2: Wallet statement for one month ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT txn_id, txn_type, amount, balance_after, reference, created_at
FROM wallet_transactions
WHERE wallet_id = 42
  AND created_at >= '2026-03-01' AND created_at < '2026-04-01'
ORDER BY created_at;

\qecho '===== Q3: Pending requests for one wallet ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT request_id, requested_by, amount, category, created_at
FROM expense_requests
WHERE wallet_id = 42 AND status = 'PENDING'
ORDER BY created_at;

\qecho '===== Q4: Spending per department for one company in one quarter ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT d.name AS department, count(*) AS payments, SUM(p.amount) AS total_spent
FROM payments p
JOIN expense_requests e   ON e.request_id = p.request_id
JOIN department_wallets w ON w.wallet_id = e.wallet_id
JOIN departments d        ON d.department_id = w.department_id
WHERE d.company_id = 7
  AND p.paid_at >= '2026-04-01' AND p.paid_at < '2026-07-01'
GROUP BY d.name
ORDER BY total_spent DESC;

\qecho '===== Q5: Top 5 vendors by total paid for one company ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT v.name, v.bank_name, count(*) AS payments, SUM(p.amount) AS total_paid
FROM payments p
JOIN expense_requests e ON e.request_id = p.request_id
JOIN vendors v          ON v.vendor_id = e.vendor_id
WHERE v.company_id = 7
GROUP BY v.vendor_id, v.name, v.bank_name
ORDER BY total_paid DESC
LIMIT 5;