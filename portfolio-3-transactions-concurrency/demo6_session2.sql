-- Demo 6 (isolation), WINDOW 2
-- Run while window 1 is waiting at its prompt (in 6A or 6B).
-- Pays R4 (NGN 60,000) and commits straight away.

\qecho '===== Window 2: pay R4 (NGN 60,000) and commit ====='
SELECT pay_expense_request(4, 'PAY-R4') AS payment_id;
SELECT wallet_id, balance FROM department_wallets WHERE wallet_id = 1;
