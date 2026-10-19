-- Demo 6A (isolation): READ COMMITTED allows a non-repeatable read
-- Window 1: a finance officer reads wallet 1's balance twice in ONE transaction
-- while a payment commits in window 2. Run setup_demo.sql first.

\qecho '===== Demo 6A: finance report under READ COMMITTED ====='
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

\qecho '--- First read ---'
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;

\prompt 'Now run demo6_session2.sql in window 2 (pays R4, NGN 60,000). When it finishes, press Enter here: ' go

\qecho '--- Second read, same transaction ---'
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;
COMMIT;
\qecho '===== The two reads differ: the report saw the other payment mid-transaction ====='
