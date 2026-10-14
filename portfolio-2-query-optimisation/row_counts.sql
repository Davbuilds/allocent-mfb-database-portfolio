SELECT 'companies' AS table_name, count(*) FROM companies
UNION ALL SELECT 'departments', count(*) FROM departments
UNION ALL SELECT 'staff', count(*) FROM staff
UNION ALL SELECT 'vendors', count(*) FROM vendors
UNION ALL SELECT 'expense_requests', count(*) FROM expense_requests
UNION ALL SELECT 'approvals', count(*) FROM approvals
UNION ALL SELECT 'payments', count(*) FROM payments
UNION ALL SELECT 'wallet_transactions', count(*) FROM wallet_transactions;