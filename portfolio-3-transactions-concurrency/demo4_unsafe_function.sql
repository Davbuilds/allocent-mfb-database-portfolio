-- Allocent MFB: UNSAFE payment function (for Demo 4 only, never for real use)
-- Same steps as pay_expense_request, but:
--   * no FOR UPDATE locks, so two sessions can read the same balance
--   * a 10-second pause between reading the balance and writing it, to make
--     the race easy to reproduce by hand in two terminals
-- The new balance is calculated from the value read at the start, so a
-- second session can overwrite the first session's update (a lost update).

CREATE OR REPLACE FUNCTION pay_expense_request_unsafe(p_request_id INT, p_reference TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  r           expense_requests%ROWTYPE;
  w           department_wallets%ROWTYPE;
  v_new_bal   NUMERIC(15,2);
  v_payment   INT;
BEGIN
  -- Read the request and wallet WITHOUT locking them
  SELECT * INTO r FROM expense_requests WHERE request_id = p_request_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Request % does not exist', p_request_id;
  END IF;

  IF r.status <> 'APPROVED' THEN
    RAISE EXCEPTION 'Request % cannot be paid: status is %', p_request_id, r.status;
  END IF;

  SELECT * INTO w FROM department_wallets WHERE wallet_id = r.wallet_id;

  IF w.balance < r.amount THEN
    RAISE EXCEPTION 'Insufficient funds: wallet % has NGN %, request % needs NGN %',
      w.wallet_id, w.balance, p_request_id, r.amount;
  END IF;

  RAISE NOTICE 'Request %: read wallet balance NGN %, paying NGN %',
    p_request_id, w.balance, r.amount;

  -- Simulate processing time (e.g. calling the bank's payment API)
  PERFORM pg_sleep(10);

  -- Write a balance calculated from the (possibly out-of-date) value read above
  v_new_bal := w.balance - r.amount;

  UPDATE department_wallets SET balance = v_new_bal WHERE wallet_id = w.wallet_id;

  INSERT INTO payments (request_id, amount, reference)
  VALUES (r.request_id, r.amount, p_reference)
  RETURNING payment_id INTO v_payment;

  INSERT INTO wallet_transactions
    (wallet_id, txn_type, amount, balance_after, payment_id, reference)
  VALUES (w.wallet_id, 'PAYMENT', r.amount, v_new_bal, v_payment, p_reference);

  UPDATE expense_requests SET status = 'PAID' WHERE request_id = r.request_id;

  RAISE NOTICE 'Request %: set wallet balance to NGN %', p_request_id, v_new_bal;

  RETURN v_payment;
END;
$$;
