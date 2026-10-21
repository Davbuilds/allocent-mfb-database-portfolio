\echo '--- On the REPLICA: the payment has arrived ---'
SELECT pg_is_in_recovery() AS replica_is_standby;
SELECT wallet_id, balance FROM department_wallets;
SELECT payment_id, request_id, amount, reference FROM payments;
