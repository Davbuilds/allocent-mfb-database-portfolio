-- Allocent MFB: relational schema (PostgreSQL 18)
-- Re-runnable: drops existing tables first.

BEGIN;

DROP TABLE IF EXISTS receipts, cards, wallet_transactions, payments, approvals,
  expense_requests, vendors, budget_allocations, department_wallets,
  company_accounts, staff, departments, companies CASCADE;

-- 1. Companies (tenants)
CREATE TABLE companies (
  company_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         VARCHAR(150) NOT NULL,
  rc_number    VARCHAR(20)  NOT NULL UNIQUE,
  email        VARCHAR(150) NOT NULL UNIQUE,
  status       VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT chk_company_status CHECK (status IN ('ACTIVE','SUSPENDED','CLOSED')),
  CONSTRAINT chk_company_email  CHECK (email LIKE '%_@_%._%')
);

-- 2. Departments
CREATE TABLE departments (
  department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id    INT NOT NULL REFERENCES companies(company_id),
  name          VARCHAR(100) NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_dept_name_per_company UNIQUE (company_id, name),
  CONSTRAINT uq_dept_company UNIQUE (department_id, company_id)  -- supports same-company FK below
);

-- 3. Staff
CREATE TABLE staff (
  staff_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id    INT NOT NULL REFERENCES companies(company_id),
  department_id INT,  -- NULL for company-wide roles (ADMIN, FINANCE)
  full_name     VARCHAR(150) NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  phone         VARCHAR(20),
  role          VARCHAR(20) NOT NULL,
  status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Multi-tenant rule: a staff member's department must belong to their own company
  CONSTRAINT fk_staff_dept_same_company
    FOREIGN KEY (department_id, company_id)
    REFERENCES departments (department_id, company_id),
  CONSTRAINT chk_staff_role   CHECK (role IN ('ADMIN','FINANCE','MANAGER','STAFF')),
  CONSTRAINT chk_staff_status CHECK (status IN ('ACTIVE','INACTIVE')),
  -- Managers and regular staff must belong to a department
  CONSTRAINT chk_staff_dept_required
    CHECK (role IN ('ADMIN','FINANCE') OR department_id IS NOT NULL)
);

-- 4. Company accounts (main business account)
CREATE TABLE company_accounts (
  account_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id     INT NOT NULL REFERENCES companies(company_id),
  account_number CHAR(10) NOT NULL UNIQUE,
  balance        NUMERIC(15,2) NOT NULL DEFAULT 0,
  status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_account_number  CHECK (account_number ~ '^[0-9]{10}$'),
  CONSTRAINT chk_account_balance CHECK (balance >= 0),
  CONSTRAINT chk_account_status  CHECK (status IN ('ACTIVE','FROZEN','CLOSED'))
);

-- 5. Department wallets (one per department)
CREATE TABLE department_wallets (
  wallet_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  department_id INT NOT NULL UNIQUE REFERENCES departments(department_id),
  balance       NUMERIC(15,2) NOT NULL DEFAULT 0,
  status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_wallet_balance CHECK (balance >= 0),
  CONSTRAINT chk_wallet_status  CHECK (status IN ('ACTIVE','FROZEN'))
);

-- 6. Budget allocations
CREATE TABLE budget_allocations (
  allocation_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  wallet_id         INT NOT NULL REFERENCES department_wallets(wallet_id),
  source_account_id INT NOT NULL REFERENCES company_accounts(account_id),
  allocated_by      INT NOT NULL REFERENCES staff(staff_id),
  amount            NUMERIC(15,2) NOT NULL,
  period_start      DATE NOT NULL,
  period_end        DATE NOT NULL,
  allocated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_allocation_amount CHECK (amount > 0),
  CONSTRAINT chk_allocation_period CHECK (period_end > period_start)
);

-- 7. Vendors (owned by each company)
CREATE TABLE vendors (
  vendor_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id     INT NOT NULL REFERENCES companies(company_id),
  name           VARCHAR(150) NOT NULL,
  bank_name      VARCHAR(100) NOT NULL,
  account_number CHAR(10) NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_vendor_account CHECK (account_number ~ '^[0-9]{10}$'),
  CONSTRAINT uq_vendor_per_company UNIQUE (company_id, bank_name, account_number)
);

-- 8. Expense requests
CREATE TABLE expense_requests (
  request_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  wallet_id    INT NOT NULL REFERENCES department_wallets(wallet_id),
  requested_by INT NOT NULL REFERENCES staff(staff_id),
  vendor_id    INT NOT NULL REFERENCES vendors(vendor_id),
  amount       NUMERIC(15,2) NOT NULL,
  category     VARCHAR(30) NOT NULL,
  description  TEXT,
  status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_request_amount   CHECK (amount > 0),
  CONSTRAINT chk_request_category CHECK (category IN
    ('TRAVEL','SOFTWARE','EQUIPMENT','FUEL','UTILITIES','OTHER')),
  CONSTRAINT chk_request_status   CHECK (status IN
    ('PENDING','APPROVED','REJECTED','PAID'))
);

-- 9. Approvals (level 1 = manager, level 2 = finance)
CREATE TABLE approvals (
  approval_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  request_id     INT NOT NULL REFERENCES expense_requests(request_id),
  approver_id    INT NOT NULL REFERENCES staff(staff_id),
  approval_level SMALLINT NOT NULL,
  decision       VARCHAR(10) NOT NULL,
  comment        TEXT,
  decided_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_approval_level    CHECK (approval_level IN (1, 2)),
  CONSTRAINT chk_approval_decision CHECK (decision IN ('APPROVED','REJECTED')),
  CONSTRAINT uq_one_approval_per_level UNIQUE (request_id, approval_level)
);

-- 10. Payments (at most one per request)
CREATE TABLE payments (
  payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  request_id INT NOT NULL UNIQUE REFERENCES expense_requests(request_id),
  amount     NUMERIC(15,2) NOT NULL,
  reference  VARCHAR(30) NOT NULL UNIQUE,
  status     VARCHAR(20) NOT NULL DEFAULT 'SUCCESSFUL',
  paid_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_payment_amount CHECK (amount > 0),
  CONSTRAINT chk_payment_status CHECK (status IN ('SUCCESSFUL','FAILED','REVERSED'))
);

-- 11. Wallet transactions (ledger / audit trail)
CREATE TABLE wallet_transactions (
  txn_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  wallet_id     INT NOT NULL REFERENCES department_wallets(wallet_id),
  txn_type      VARCHAR(20) NOT NULL,
  amount        NUMERIC(15,2) NOT NULL,
  balance_after NUMERIC(15,2) NOT NULL,
  allocation_id INT REFERENCES budget_allocations(allocation_id),
  payment_id    INT REFERENCES payments(payment_id),
  reference     VARCHAR(30) NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_txn_type   CHECK (txn_type IN
    ('ALLOCATION','PAYMENT','TRANSFER_IN','TRANSFER_OUT','REVERSAL')),
  CONSTRAINT chk_txn_amount CHECK (amount > 0),
  CONSTRAINT chk_txn_balance_after CHECK (balance_after >= 0),
  -- Each ledger entry links to the right source record for its type
  CONSTRAINT chk_txn_source CHECK (
       (txn_type = 'ALLOCATION' AND allocation_id IS NOT NULL AND payment_id IS NULL)
    OR (txn_type IN ('PAYMENT','REVERSAL') AND payment_id IS NOT NULL AND allocation_id IS NULL)
    OR (txn_type IN ('TRANSFER_IN','TRANSFER_OUT') AND allocation_id IS NULL AND payment_id IS NULL)
  )
);

-- 12. Cards (light)
CREATE TABLE cards (
  card_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  staff_id       INT NOT NULL REFERENCES staff(staff_id),
  wallet_id      INT NOT NULL REFERENCES department_wallets(wallet_id),
  masked_pan     VARCHAR(19) NOT NULL,
  spending_limit NUMERIC(15,2) NOT NULL,
  status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  issued_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_card_masked CHECK (masked_pan ~ '^[0-9]{4} \*{4} \*{4} [0-9]{4}$'),
  CONSTRAINT chk_card_limit  CHECK (spending_limit > 0),
  CONSTRAINT chk_card_status CHECK (status IN ('ACTIVE','BLOCKED','EXPIRED'))
);

-- 13. Receipts (light)
CREATE TABLE receipts (
  receipt_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  request_id  INT NOT NULL REFERENCES expense_requests(request_id),
  file_path   VARCHAR(255) NOT NULL,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;