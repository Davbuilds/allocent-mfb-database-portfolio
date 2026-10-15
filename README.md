# Allocent MFB – Advanced Database Systems Portfolio

Course: MIT 8103 Advanced Database Systems (2026/2027, First Semester)
Student: David 

## Case Study
Allocent MFB is a fictional Nigerian digital microfinance bank that offers a
multi-tenant business banking platform for companies. Each company holds a
main business account, from which its finance team allocates budgets to
department wallets, for example ₦30,000 for HR and ₦400,000 for Development,
for a monthly or quarterly period. Staff submit spending requests against
their department's wallet, managers approve or reject them, and approved
payments go to vendors or billers, with the system blocking any payment that
would exceed the department's remaining budget. Many companies share the same
database, with each company's data isolated by a company identifier. The
platform is inspired by spend management products such as Ramp, Spendesk and
Bujeti, and follows the maker-checker approval principle used in corporate
banking.

### Users of the database
- Company admins: manage the company profile, departments and staff.
- Finance officers: allocate budgets, give second-level approval for large
  requests, and view company-wide reports.
-Department managers: approve or reject their department's requests.
- Staff:submit expense requests and upload receipts.
- 
Bank support and audit staff:** review activity and balances.

### Major data stored
Companies, departments, staff and roles, company accounts, department wallets,
budget allocations, vendors, expense requests, approvals, payments, a wallet
transaction ledger, staff cards and receipts.

### Key operations
- Allocate budgets from the company account to department wallets
- Submit expense requests against a department wallet
- Approve or reject requests (manager, plus finance above ₦100,000)
- Pay approved requests to vendors, debiting the wallet and writing the ledger
- Transfer budget between department wallets
- Reverse failed payments
- Report spending by department, vendor and period
- Audit wallet balances against the ledger

## Tools
- PostgreSQL 18 (pgAdmin 4 and psql)
- Docker
- MongoDB (Portfolio 4)

## Portfolio Contents
1. Database Design and Modelling(portfolio-1-database-design/)
2. Query Processing and Optimisation(portfolio-2-query-optimisation/)
3. Transactions and Concurrency(portfolio-3-transactions-concurrency/)
4. NoSQL and Advanced Data Models(portfolio-4-nosql/)
5. Distributed and Cloud Database Exercise(portfolio-5-distributed-cloud/)

