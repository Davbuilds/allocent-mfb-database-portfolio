\echo '--- On the PRIMARY: pay R4 (NGN 60,000) ---'
SELECT pay_expense_request(4, 'PAY-R4') AS payment_id;
