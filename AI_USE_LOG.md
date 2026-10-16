# AI Use Log

This log records where AI tools were used in this portfolio, what they were
used for, and how the output was checked.

| Date | Tool | Portfolio | What it was used for | How I verified it |
|---|---|---|---|---|
| 2026-10-15 | Claude Code (Claude Opus 5.5) | All | Audited the repository against the assessment brief checklist; found the main README had been emptied by an earlier commit and that `indexes_covering.sql` was empty | Checked the findings myself with `git show` and by opening the files |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 1 | Fixed README formatting; drafted the case study summary, ER entity table, keys and constraints table, design decisions, evidence and How to Run sections of the P1 README; wrote `constraint_tests.sql`; corrected `allocent_er.dbml` to show the composite foreign key and match `schema.sql` | Ran `schema.sql` and `constraint_tests.sql` on a fresh schema and confirmed the three expected errors and the successful control insert (`results/constraint_tests_output.txt`, screenshots); re-exported the ER diagram from the corrected DBML and checked it against `schema.sql` |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 2 | Recreated `indexes_covering.sql` from the index definitions in the README; switched `\echo` to `\qecho`; wrote `index_stats.sql`; updated How to Run; checked README figures against the saved plans and corrected the approvals row count, index usage counts and the explanation of usage counts | Checked `indexes_covering.sql` against `pg_indexes` in my database; generated `results/query_results.txt` and the row count, index usage and table size screenshots myself, and confirmed the README figures match them |

## Work done without AI
- **Portfolio 1:** the case study, the schema design in `schema.sql`, the
  normalisation write-up and the ER model.
- **Portfolio 2:** the test data generator (`seed_data.sql`), the five
  business queries, the index design (`indexes.sql` and the covering index
  approach), and the Results, Analysis, Trade-offs and Key lessons sections
  of the README.
