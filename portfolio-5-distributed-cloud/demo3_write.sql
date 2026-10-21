\echo '--- The NEW primary accepts writes ---'
INSERT INTO approvals (request_id, approver_id, approval_level, decision)
VALUES (3, 1, 2, 'APPROVED');
SELECT pay_expense_request(3, 'PAY-R3') AS payment_id;
SELECT wallet_id, balance FROM department_wallets;
