Allocent MFB – Advanced Database Systems Portfolio

Course: MIT 8103 Advanced Database Systems
Student:David Ajitena

 Case Study
Allocent MFB is a fictional Nigerian digital microfinance bank that offers a
business banking platform for companies. Each company holds a main business
account, from which its finance team allocates budgets to department wallets,
for example ₦30,000 for HR and ₦400,000 for Development, for a monthly or
quarterly period. Staff submit spending requests against their department's
wallet, managers approve or reject them, and approved payments go to vendors
or billers, with the system blocking any payment that would exceed the
department's remaining budget. The platform is multi-tenant: many companies
share the same database, with each company's data isolated by a company
identifier. It is inspired by real spend management products such as Ramp,
Spendesk and Bujeti, but is built directly into the bank, so department
wallets are bank-held balances.

Tools
- PostgreSQL 18
- Docker
- MongoDB 

 Portfolio Contents
1. Database Design and Modelling (portfolio-1-database-design/)
2. Query Processing and Optimisation(portfolio-2-query-optimisation/)
3. Transactions and Concurrency(portfolio-3-transactions-concurrency/)
4. NoSQL and Advanced Data Models (portfolio-4-nosql/)
5. Distributed and Cloud Database Exercise(portfolio-5-distributed-cloud/)