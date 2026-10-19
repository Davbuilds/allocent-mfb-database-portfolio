-- Demo 4 (concurrency issue: lost update), SESSION 2
-- Start within 20 seconds of demo4_session1.sql, in a second terminal.

\qecho '===== Session 2: pay R2 (NGN 150,000) WITHOUT locking ====='
\timing on
SELECT pay_expense_request_unsafe(2, 'PAY-R2') AS payment_id;
