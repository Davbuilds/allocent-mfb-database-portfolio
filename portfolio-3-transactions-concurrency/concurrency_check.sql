-- Allocent MFB: state check after a concurrency demo
-- Compares the wallet balance with what the ledger says it should be.

\qecho '--- Wallet balance ---'
SELECT wallet_id, balance FROM department_wallets ORDER BY wallet_id;

\qecho '--- Requests R1 and R2 ---'
SELECT request_id, amount, status FROM expense_requests
WHERE request_id IN (1, 2) ORDER BY request_id;

\qecho '--- Payments made ---'
SELECT payment_id, request_id, amount, reference FROM payments ORDER BY payment_id;

\qecho '--- Ledger ---'
SELECT txn_id, txn_type, amount, balance_after, reference
FROM wallet_transactions ORDER BY txn_id;

\qecho '--- Consistency check: allocated - paid should equal the wallet balance ---'
SELECT w.wallet_id,
       COALESCE((SELECT SUM(amount) FROM budget_allocations a
                 WHERE a.wallet_id = w.wallet_id), 0) AS allocated,
       COALESCE((SELECT SUM(p.amount) FROM payments p
                 JOIN expense_requests e ON e.request_id = p.request_id
                 WHERE e.wallet_id = w.wallet_id), 0) AS paid,
       COALESCE((SELECT SUM(amount) FROM budget_allocations a
                 WHERE a.wallet_id = w.wallet_id), 0)
     - COALESCE((SELECT SUM(p.amount) FROM payments p
                 JOIN expense_requests e ON e.request_id = p.request_id
                 WHERE e.wallet_id = w.wallet_id), 0) AS expected_balance,
       w.balance AS actual_balance
FROM department_wallets w
ORDER BY w.wallet_id;
