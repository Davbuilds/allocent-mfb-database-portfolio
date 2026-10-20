# AI Use Log

This log records where AI tools were used in this portfolio, what they were
used for, and how the output was checked.

| Date | Tool | Portfolio | What it was used for | How I verified it |
|---|---|---|---|---|
| 2026-10-15 | Claude Code (Claude Opus 5.5) | All | Audited the repository against the assessment brief checklist; found the main README had been emptied by an earlier commit and that `indexes_covering.sql` was empty | Checked the findings myself with `git show` and by opening the files |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 1 | Fixed README formatting; drafted the case study summary, ER entity table, keys and constraints table, design decisions, evidence and How to Run sections of the P1 README; wrote `constraint_tests.sql`; corrected `allocent_er.dbml` to show the composite foreign key and match `schema.sql` | Ran `schema.sql` and `constraint_tests.sql` on a fresh schema and confirmed the three expected errors and the successful control insert (`results/constraint_tests_output.txt`, screenshots); re-exported the ER diagram from the corrected DBML and checked it against `schema.sql` |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 2 | Recreated `indexes_covering.sql` from the index definitions in the README; switched `\echo` to `\qecho`; wrote `index_stats.sql`; updated How to Run; checked README figures against the saved plans and corrected the approvals row count, index usage counts and the explanation of usage counts | Checked `indexes_covering.sql` against `pg_indexes` in my database; generated `results/query_results.txt` and the row count, index usage and table size screenshots myself, and confirmed the README figures match them |
| 2026-10-17 to 2026-10-20 | Claude Code (Claude Opus 5.5) | 3 | Reviewed my `pay_function.sql`, `setup_demo.sql` and demos 1–3 and pointed out fixes (stray line in `demo2_rollback.sql`, mislabelled screenshot); added the frozen-wallet check to `pay_function.sql`; wrote `demo4_unsafe_function.sql`, the demo 4, 5 and 6 session scripts and `concurrency_check.sql`; drafted the P3 README | Ran every demo myself on the `allocent_p3` database, resetting with `setup_demo.sql` before each, and took all the screenshots; confirmed the lost update (expected -100,000 vs actual 50,000), the 23.4 s lock wait and the isolation results matched the README; reviewed the README |

## Work done without AI
- **Portfolio 1:** the case study, the schema design in `schema.sql`, the
  normalisation write-up and the ER model.
- **Portfolio 2:** the test data generator (`seed_data.sql`), the five
  business queries, the index design (`indexes.sql` and the covering index
  approach), and the Results, Analysis, Trade-offs and Key lessons sections
  of the README.
- **Portfolio 3:** the payment function `pay_expense_request` (locking,
  lock order and business rules), the demo data in `setup_demo.sql`, and
  demos 1–3 (commit, rollback, business rules).
