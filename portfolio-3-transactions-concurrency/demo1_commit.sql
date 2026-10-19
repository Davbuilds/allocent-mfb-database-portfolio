-- Demo 1: COMMIT
-- Pay request R4 (NGN 60,000, manager-approved, under the finance threshold).

\echo '--- Before ---'
SELECT wallet_id, balance FROM department_wallets;

BEGIN;
SELECT pay_expense_request(4, 'PAY-R4') AS payment_id;
COMMIT;

\echo '--- After ---'
SELECT wallet_id, balance FROM department_wallets;
SELECT request_id, amount, status FROM expense_requests WHERE request_id = 4;
SELECT payment_id, request_id, amount, reference FROM payments;
SELECT txn_id, txn_type, amount, balance_after, reference
FROM wallet_transactions ORDER BY txn_id;