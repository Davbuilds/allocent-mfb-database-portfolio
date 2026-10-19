-- Allocent MFB: safe payment function
-- Pays an approved expense request in one transaction, enforcing:
--   1. the request exists and is APPROVED (not already PAID)
--   2. a manager (level 1) approval exists
--   3. requests above NGN 100,000 also have a finance (level 2) approval
--   4. the requester belongs to the wallet's department
--   5. the wallet is ACTIVE (not FROZEN)
--   6. the wallet has enough funds
-- Rows are locked with FOR UPDATE (request first, then wallet) so concurrent
-- calls cannot overspend or pay the same request twice.

CREATE OR REPLACE FUNCTION pay_expense_request(p_request_id INT, p_reference TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  r           expense_requests%ROWTYPE;
  w           department_wallets%ROWTYPE;
  v_new_bal   NUMERIC(15,2);
  v_payment   INT;
BEGIN
  -- Lock the request so no one else can pay it at the same time
  SELECT * INTO r FROM expense_requests
  WHERE request_id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Request % does not exist', p_request_id;
  END IF;

  IF r.status <> 'APPROVED' THEN
    RAISE EXCEPTION 'Request % cannot be paid: status is %', p_request_id, r.status;
  END IF;

  -- Rule: manager (level 1) approval required
  IF NOT EXISTS (SELECT 1 FROM approvals
                 WHERE request_id = r.request_id
                   AND approval_level = 1 AND decision = 'APPROVED') THEN
    RAISE EXCEPTION 'Request % has no manager approval', p_request_id;
  END IF;

  -- Rule: above NGN 100,000 also needs finance (level 2) approval
  IF r.amount > 100000 AND NOT EXISTS (SELECT 1 FROM approvals
                 WHERE request_id = r.request_id
                   AND approval_level = 2 AND decision = 'APPROVED') THEN
    RAISE EXCEPTION 'Request % (NGN %) needs finance approval above NGN 100,000',
      p_request_id, r.amount;
  END IF;

  -- Rule: requester must belong to the wallet's department
  IF NOT EXISTS (SELECT 1 FROM staff s
                 JOIN department_wallets dw ON dw.department_id = s.department_id
                 WHERE s.staff_id = r.requested_by
                   AND dw.wallet_id = r.wallet_id) THEN
    RAISE EXCEPTION 'Requester % does not belong to wallet %''s department',
      r.requested_by, r.wallet_id;
  END IF;

  -- Lock the wallet so concurrent payments queue up instead of overspending
  SELECT * INTO w FROM department_wallets
  WHERE wallet_id = r.wallet_id
  FOR UPDATE;

  -- Rule: a frozen wallet cannot make payments
  IF w.status <> 'ACTIVE' THEN
    RAISE EXCEPTION 'Wallet % is % and cannot make payments', w.wallet_id, w.status;
  END IF;

  IF w.balance < r.amount THEN
    RAISE EXCEPTION 'Insufficient funds: wallet % has NGN %, request % needs NGN %',
      w.wallet_id, w.balance, p_request_id, r.amount;
  END IF;

  v_new_bal := w.balance - r.amount;

  -- All four changes happen together, or not at all
  UPDATE department_wallets SET balance = v_new_bal WHERE wallet_id = w.wallet_id;

  INSERT INTO payments (request_id, amount, reference)
  VALUES (r.request_id, r.amount, p_reference)
  RETURNING payment_id INTO v_payment;

  INSERT INTO wallet_transactions
    (wallet_id, txn_type, amount, balance_after, payment_id, reference)
  VALUES (w.wallet_id, 'PAYMENT', r.amount, v_new_bal, v_payment, p_reference);

  UPDATE expense_requests SET status = 'PAID' WHERE request_id = r.request_id;

  RETURN v_payment;
END;
$$;