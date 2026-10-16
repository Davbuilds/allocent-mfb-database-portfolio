-- Allocent MFB: covering indexes (second optimisation round)
-- Run after indexes.sql. Covering indexes store extra columns in the index
-- (INCLUDE) so PostgreSQL can answer from the index alone (Index Only Scan)
-- without visiting the table.

-- Q5: a company's vendors' requests are scattered across almost every page
-- of expense_requests, so the plain vendor index was ignored. Including
-- request_id lets the join to payments be fed from the index alone.
CREATE INDEX idx_requests_vendor_cover
  ON expense_requests (vendor_id) INCLUDE (request_id);

-- Q4 and Q5: look up a payment by request and read its date and amount
-- without visiting the payments table.
CREATE INDEX idx_payments_request_cover
  ON payments (request_id) INCLUDE (paid_at, amount);

-- Index-only scans rely on the visibility map, so refresh it and the
-- planner statistics. (VACUUM cannot run inside a transaction block.)
VACUUM ANALYZE expense_requests;
VACUUM ANALYZE payments;
