\echo '--- Primary is down. The REPLICA still serves reads ---'
SELECT wallet_id, balance FROM department_wallets;
\echo '--- Promote the replica to primary ---'
SELECT pg_promote() AS promoted;
SELECT pg_is_in_recovery() AS still_standby;
