-- Allocent MFB: indexes designed from the baseline execution plans

-- Q1: filter by requester, sort newest first, stop after 20.
-- A composite index in the same order as the query lets PostgreSQL read
-- the 20 newest rows directly, with no scan and no sort.
CREATE INDEX idx_requests_requester_created
  ON expense_requests (requested_by, created_at DESC);

-- Q2: one wallet's ledger entries within a date range, ordered by date.
-- Equality column first (wallet_id), range/sort column second (created_at).
CREATE INDEX idx_wallet_txn_wallet_created
  ON wallet_transactions (wallet_id, created_at);

-- Q3: pending requests for one wallet.
-- A partial index stores only PENDING rows (~10% of the table),
-- so it is small, fast, and cheap to maintain.
CREATE INDEX idx_requests_pending_wallet
  ON expense_requests (wallet_id, created_at)
  WHERE status = 'PENDING';

-- Q4: find all requests for a company's wallets.
-- Also a foreign-key index, which speeds up joins on wallet_id generally.
CREATE INDEX idx_requests_wallet
  ON expense_requests (wallet_id);

-- Q5: find all requests for a company's vendors (foreign-key index).
CREATE INDEX idx_requests_vendor
  ON expense_requests (vendor_id);

-- Q4 support: departments are filtered by company (foreign-key index).
CREATE INDEX idx_departments_company
  ON departments (company_id);

-- Refresh statistics so the planner knows about the new indexes
ANALYZE;