-- Allocent MFB: constraint tests
-- Run on a freshly created schema (schema.sql). Inserts two companies with one
-- department each, then attempts three inserts that must be rejected.
-- Each failing statement prints an ERROR; that error is the expected result.

-- Sample data: company 1 (Zenith Logistics) and company 2 (Bluewave Foods)
INSERT INTO companies (name, rc_number, email)
VALUES ('Zenith Logistics', 'RC100001', 'info@zenith.ng'),
       ('Bluewave Foods',   'RC100002', 'info@bluewave.ng');

INSERT INTO departments (company_id, name)
VALUES (1, 'HR'),            -- department 1 belongs to company 1
       (2, 'Operations');    -- department 2 belongs to company 2

INSERT INTO department_wallets (department_id, balance)
VALUES (1, 30000), (2, 50000);

-- Test 1: invalid company status (chk_company_status) -> must fail
INSERT INTO companies (name, rc_number, email, status)
VALUES ('Test Ltd', 'RC100003', 'info@test.ng', 'DORMANT');

-- Test 2: negative wallet balance (chk_wallet_balance) -> must fail
UPDATE department_wallets SET balance = -5000 WHERE wallet_id = 1;

-- Test 3: staff in company 2 placed in company 1's department
-- (fk_staff_dept_same_company) -> must fail
INSERT INTO staff (company_id, department_id, full_name, email, role)
VALUES (2, 1, 'Tunde Bello', 'tunde@bluewave.ng', 'STAFF');

-- Control: the same staff member in their own company's department succeeds
INSERT INTO staff (company_id, department_id, full_name, email, role)
VALUES (2, 2, 'Tunde Bello', 'tunde@bluewave.ng', 'STAFF');
