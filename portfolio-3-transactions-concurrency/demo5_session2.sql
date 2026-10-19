-- Demo 5 (control mechanism: row locking with FOR UPDATE), SESSION 2
-- Start while session 1 is waiting at its prompt. This session will wait
-- on the wallet lock, then re-read the balance after session 1 commits.

\qecho '===== Session 2: pay R2 (NGN 150,000) WITH locking ====='
\timing on
SELECT pay_expense_request(2, 'PAY-R2') AS payment_id;
