-- Demo 5 (control mechanism: row locking with FOR UPDATE), SESSION 1
-- Run setup_demo.sql first. Session 1 pays R1 inside an open transaction,
-- so it keeps the wallet row locked until you press Enter.

\qecho '===== Session 1: pay R1 (NGN 150,000) WITH locking ====='
\timing on
BEGIN;
SELECT pay_expense_request(1, 'PAY-R1') AS payment_id;
\prompt 'Session 1 holds the wallet lock. Start demo5_session2.sql, wait about 10 seconds, then press Enter to COMMIT: ' go
COMMIT;
\qecho '===== Session 1: committed ====='
