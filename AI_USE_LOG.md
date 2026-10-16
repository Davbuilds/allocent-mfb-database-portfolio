# AI Use Log

This log records where AI tools were used in this portfolio, what they were
used for, and how the output was checked.

| Date | Tool | Portfolio | What it was used for | How I verified it |
|---|---|---|---|---|
| 2026-10-15 | Claude Code (Claude Opus 5.5) | All | Audited the repository against the assessment brief checklist; found the main README had been emptied by an earlier commit and that `indexes_covering.sql` was empty | Checked the findings myself with `git show` and by opening the files |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 1 | Fixed README formatting; drafted the case study, ER entity table, keys and constraints table, design decisions, evidence and How to Run sections of the P1 README; wrote `constraint_tests.sql` | _To complete: reviewed each statement against `schema.sql`, ran `constraint_tests.sql` and confirmed the three expected errors_ |
| 2026-10-16 | Claude Code (Claude Opus 5.5) | 2 | Recreated `indexes_covering.sql` from the index definitions in the README; switched `\echo` to `\qecho`; wrote `index_stats.sql`; updated How to Run | _To complete: reran the scripts from scratch and confirmed the plans match the README_ |

## Work done without AI
_To complete: e.g. choice of case study, schema design, choice of business
queries, index design from the execution plans, performance analysis._
