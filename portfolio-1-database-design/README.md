# Portfolio 1: Database Design and Modelling 
## Normalisation

### Starting point: an unnormalised expense sheet
Without a database design, Allocent's expenses might be tracked in one sheet:

| request_id | company_name | dept_name | requester_name | requester_email | vendor_name | vendor_account | amount | approvers | receipts |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Zenith Logistics | HR | Ada Obi | ada@zenith.ng | PrintHub | 0123456789 | 45,000 | Musa (Manager) | r1.jpg |
| 2 | Zenith Logistics | HR | Ada Obi | ada@zenith.ng | PrintHub | 0123456789 | 150,000 | Musa (Manager), Kemi (Finance) | r2.jpg, r3.jpg |

This design suffers from three anomalies:
- **Update anomaly:** if PrintHub changes its account number, every row
  mentioning PrintHub must be updated; missing one leaves conflicting data.
- **Insertion anomaly:** a new vendor or staff member cannot be recorded
  until an expense request involving them exists.
- **Deletion anomaly:** deleting Ada's only request would also delete the
  record that she exists.

### First Normal Form (1NF)
A table is in 1NF when every column holds a single atomic value and there
are no repeating groups. The `approvers` and `receipts` columns above hold
lists. In the Allocent schema, each approval is a separate row in
`approvals` and each receipt is a separate row in `receipts`, both linked
to their request through `request_id`. Every table has a primary key and
every column holds one value.

### Second Normal Form (2NF)
A table is in 2NF when it is in 1NF and no non-key column depends on only
part of a composite key. In `approvals`, the pair `(request_id,
approval_level)` uniquely identifies a row (enforced by
`uq_one_approval_per_level`). If `approvals` also stored the request's
`amount`, that value would depend on `request_id` alone, a partial
dependency. The amount is therefore kept only in `expense_requests`, and
the remaining columns in `approvals` (approver, decision, comment) depend
on the whole key. All tables also use single-column surrogate primary
keys, which avoids partial dependencies on the primary key.

### Third Normal Form (3NF)
A table is in 3NF when it is in 2NF and no non-key column depends on
another non-key column (a transitive dependency). In the sheet above,
`vendor_account` depends on `vendor_name`, not on `request_id`. In the
Allocent schema:
- Vendor details live in `vendors`; `expense_requests` stores only `vendor_id`.
- Requester details live in `staff`; `expense_requests` stores only `requested_by`.
- Company details live in `companies`; other tables store only `company_id`.
- `payments` deliberately has no `wallet_id`, because the wallet is
  reachable through `payments.request_id → expense_requests.wallet_id`.
  Storing it again would create a transitive dependency and a risk of the
  two values disagreeing.

### Deliberate denormalisation
Three design choices intentionally store derivable data, for practical reasons:
- **`department_wallets.balance`** could be calculated from the ledger, but
  is stored so balances can be read instantly, as in real banking systems.
  Consistency is protected by updating the balance and writing the ledger
  entry in the same transaction (see Portfolio 3).
- **`wallet_transactions.balance_after`** records the balance at the moment
  of each movement, giving an audit snapshot that does not need recalculating.
staff.company_id is derivable through the department, but is needed
  because ADMIN and FINANCE staff have no department. The composite foreign
  key `fk_staff_dept_same_company` guarantees it can never contradict the
  department's company.

## Keys and Constraints

**Primary keys:** every table uses an