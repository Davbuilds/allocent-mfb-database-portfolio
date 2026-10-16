-- Allocent MFB: index usage and size, and table vs index size
-- Used for the Trade-offs section of the README.

-- How often each custom index was used, and its size
SELECT indexrelname AS index_name,
       idx_scan     AS times_used,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'idx_%'
ORDER BY indexrelname;

-- Table size vs total index size for the large tables
SELECT relname AS table_name,
       pg_size_pretty(pg_table_size(relid))   AS table_size,
       pg_size_pretty(pg_indexes_size(relid)) AS index_size
FROM pg_stat_user_tables
WHERE relname IN ('expense_requests', 'payments', 'wallet_transactions')
ORDER BY relname;
