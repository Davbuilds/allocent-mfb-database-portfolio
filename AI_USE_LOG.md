# AI Use Declaration

## My own work
The design and core implementation of each portfolio are my own:

- **Portfolio 1:** the case study, the schema design (`schema.sql`), the ER
  model and the normalisation write-up.
- **Portfolio 2:** the test data generator (`seed_data.sql`), the five
  business queries, the index design, and the analysis, trade-offs and key
  lessons in the README.
- **Portfolio 3:** the payment function `pay_expense_request` (locking, lock
  order and business rules), the demo data (`setup_demo.sql`) and demos 1–3.
- **Portfolio 4:** the MongoDB document design, the setup, insert and query
  scripts, and the first draft of the README, including the suitability
  argument.
- **Portfolio 5:** the primary/replica setup, the demo scripts and the
  README, including the consistency, CAP, sharding and cloud discussion.

I ran every script and demo myself and took all of the screenshots.

## AI tool used
**Claude Code (Claude Opus 5.5)**, used between 15 and 21 October 2026.

| Portfolio | What the AI tool was used for | How I reviewed and verified it |
|---|---|---|
| All | Checking the repository against the assessment brief; finding missing or broken files; rewording README text into a consistent voice (wording only) | Checked each finding by opening the files; compared reworded text with the previous versions using `git diff` |
| 1 | Drafting parts of the README (case study summary, entity table, keys and constraints table, design decisions, evidence, How to Run); writing `constraint_tests.sql`; correcting the DBML to show the composite foreign key | Ran the schema and constraint tests on a fresh database and confirmed the expected errors; re-exported the ER diagram and checked it against `schema.sql` |
| 2 | Recreating `indexes_covering.sql`; writing `index_stats.sql`; checking README figures against the saved plans and correcting three of them | Checked the covering indexes against `pg_indexes`; generated the query results and screenshots myself and confirmed the figures |
| 3 | Reviewing my scripts; adding the frozen-wallet check; writing the scripts for demos 4–6 (lost update, locking, isolation); drafting the README | Ran every demo myself and confirmed the results in the README (lost update, 23.4 s lock wait, isolation reads) |
| 4 | Reviewing my scripts; making IDs consistent and validation errors clearer; writing `04_explain.js`; fixing the README | Ran all four scripts and checked the README figures against the outputs |
| 5 | Cross-checking my setup and README; adding `.gitattributes` for LF line endings; fixing file encodings | Ran the setup and all three demos myself and confirmed replication and failover |

I remain responsible for all submitted work and can explain every part of it.
