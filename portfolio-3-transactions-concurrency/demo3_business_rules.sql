-- Demo 3: business rules enforced inside the transaction
-- Run after setup_demo.sql (wallet 1 starts with NGN 200,000).

\echo '===== Rule 1: above NGN 100,000 needs finance (level 2) approval ====='
\echo '--- R3 is NGN 120,000 with manager approval only ---'
SELECT approval_level, decision FROM approvals WHERE request_id = 3;
BEGIN;
SELECT pay_expense_request(3, 'PAY-R3') AS payment_id;
COMMIT;

\echo '===== Rule 2: only APPROVED requests can be paid ====='
\echo '--- R5 is still PENDING ---'
BEGIN;
SELECT pay_expense_request(5, 'PAY-R5') AS payment_id;
COMMIT;

\echo '===== Rule 3: a request cannot be paid twice ====='
\echo '--- Pay R4 once (succeeds) ---'
BEGIN;
SELECT pay_expense_request(4, 'PAY-R4') AS payment_id;
COMMIT;
\echo '--- Pay R4 again (refused: already PAID) ---'
BEGIN;
SELECT pay_expense_request(4, 'PAY-R4-AGAIN') AS payment_id;
COMMIT;

\echo '===== Rule 4: finance approval unlocks the large request ====='
\echo '--- Finance (Kemi, staff 1) approves R3 at level 2, then R3 is paid ---'
INSERT INTO approvals (request_id, approver_id, approval_level, decision)
VALUES (3, 1, 2, 'APPROVED');
BEGIN;
SELECT pay_expense_request(3, 'PAY-R3') AS payment_id;
COMMIT;

\echo '--- Final state ---'
SELECT wallet_id, balance FROM department_wallets;
SELECT request_id, amount, status FROM expense_requests ORDER BY request_id;
SELECT payment_id, request_id, amount, reference FROM payments ORDER BY payment_id;