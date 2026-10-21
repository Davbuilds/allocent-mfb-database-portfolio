\echo '--- On the REPLICA: try to pay R1 (must be refused) ---'
SELECT pg_is_in_recovery() AS replica_is_standby;
SELECT pay_expense_request(1, 'PAY-R1');
