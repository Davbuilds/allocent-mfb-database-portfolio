-- Demo 4 (concurrency issue: lost update), SESSION 1
-- Run setup_demo.sql and demo4_unsafe_function.sql first.
-- Start this, then start demo4_session2.sql in a second terminal
-- within 10 seconds.

\qecho '===== Session 1: pay R1 (NGN 150,000) WITHOUT locking ====='
\timing on
SELECT pay_expense_request_unsafe(1, 'PAY-R1') AS payment_id;
