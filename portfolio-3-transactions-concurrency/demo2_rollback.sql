-- Demo 2: ROLLBACK
-- Run after setup_demo.sql (wallet 1 starts with NGN 200,000).

\echo '===== Part A: manual ROLLBACK ====='
\echo '--- Before ---'
SELECT wallet_id, balance FROM department_wallets;

BEGIN;
SELECT pay_expense_request(1, 'PAY-R1') AS payment_id;
\echo '--- Inside the transaction: payment made but not committed ---'
SELECT wallet_id, balance FROM department_wallets;
ROLLBACK;

\echo '--- After ROLLBACK: everything undone ---'
SELECT wallet_id, balance FROM department_wallets;
SELECT request_id, status FROM expense_requests WHERE request_id = 1;
SELECT count(*) AS payments FROM payments;

\echo '===== Part B: automatic rollback on error ====='
\echo '--- Pay R1 (NGN 150,000) and commit ---'
BEGIN;
SELECT pay_expense_request(1, 'PAY-R1') AS payment_id;
COMMIT;
SELECT wallet_id, balance FROM department_wallets;

\echo '--- Try to pay R2 (NGN 150,000) with only NGN 50,000 left ---'
BEGIN;
SELECT pay_expense_request(2, 'PAY-R2') AS payment_id;
COMMIT;

\echo '--- After the failed payment: R2 unpaid, balance unchanged ---'
SELECT wallet_id, balance FROM department_wallets;
SELECT request_id, status FROM expense_requests WHERE request_id IN (1, 2) ORDER BY request_id;
SELECT payment_id, request_id, amount FROM payments;

\echo '===== Part C: the CHECK constraint as a final safety net ====='
\echo '--- A direct update that bypasses the function ---'
UPDATE department_wallets SET balance = balance - 150000 WHERE wallet_id = 1;
SELECT wallet_id, balance FROM department_wallets;
