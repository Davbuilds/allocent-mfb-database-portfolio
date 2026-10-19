-- Demo 6B (isolation): REPEATABLE READ prevents the non-repeatable read
-- Same steps as Demo 6A, but the transaction reads from one snapshot.
-- Run setup_demo.sql first.

\qecho '===== Demo 6B: finance report under REPEATABLE READ ====='
BEGIN ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;

\qecho '--- First read ---'
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;

\prompt 'Now run demo6_session2.sql in window 2 (pays R4, NGN 60,000). When it finishes, press Enter here: ' go

\qecho '--- Second read, same transaction ---'
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;
COMMIT;

\qecho '--- After COMMIT: a new transaction sees the payment ---'
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;
\qecho '===== Both reads inside the transaction matched: one consistent snapshot ====='
