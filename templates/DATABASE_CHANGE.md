<!--
Template: Database Change
Use this when: any schema migration, index change, or significant new query pattern against
production data — anything in scope for ../checklists/database-review.md.
Related: ../docs/database-guidelines.md, ../docs/workflows/database-change.md (the full
expand/migrate/contract sequence this template records), ../.claude/agents/database-engineer.md.
-->

# Database Change: [Short description — "Add index on orders.customer_id", not "DB update"]

**Status:** [Draft | In review | Approved | Migrated]
**Owner:** [Name]
**Target table(s):** [table names]
**Estimated production data volume affected:** [row count / table size — this drives the risk
assessment below]

## Context

<!-- The current schema state relevant to this change, and what's driving the need for it. -->

[Describe the current shape of the affected table(s) and the query pattern, growth, or requirement
that makes this change necessary. Include current row count and growth rate if the change's safety
depends on scale.]

## Problem

<!-- The specific technical problem this change solves. -->

[What can't the current schema support — a missing index causing slow queries above some
threshold, a data integrity gap, a new feature's data requirement? State it with evidence (a query
plan, a measured latency) where possible, not "this seems slow."]

## Decision

<!-- The migration itself, sequenced per the expand/migrate/contract discipline in
     ../docs/workflows/database-change.md. -->

**Migration type:** [add column | add index | add table | backfill | drop column | change
constraint | other]

**Sequencing:**
1. **Expand:** [schema addition that's safe to deploy alongside currently-running code —
   e.g., add nullable column, add new table]
2. **Migrate:** [backfill or dual-write step, if any, and how it's throttled/batched to avoid
   contending with live traffic]
3. **Contract:** [removal of the old schema element, only after the old code path is fully
   retired — state what confirms the old path is retired]

**DDL:**
```sql
[The actual migration statement(s), or a description if the migration tool generates them]
```

**Backward compatibility confirmed for this window:**
- [ ] Old application code still works correctly against the new schema mid-rollout
- [ ] New application code still works correctly if it runs against the pre-migration schema
      briefly during deploy

## Alternatives

<!-- Other ways to solve the Problem above, including non-migration alternatives. -->

### [Alternative schema shape]

[What it was and why this one was chosen instead — e.g., "considered a separate lookup table
instead of a new column, rejected because the 1:1 relationship doesn't warrant the join cost for a
field queried on every read."]

### Application-level workaround (no migration)

[Whether solving this without a schema change was considered, and why it wasn't sufficient —
migrations should be the deliberate choice, not the default.]

## Risks

<!-- Specific to database changes: lock behavior, rollback asymmetry, and data integrity. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Lock contention — e.g., migration locks table for duration X at current size] | [L/M/H] | [L/M/H] | [Run during low-traffic window / use online schema change tool / batch it] |
| [Rollback asymmetry — e.g., backfill is not reversible without a restore] | [L/M/H] | [L/M/H] | [State explicitly what "rollback" actually means for this migration] |
| [Data integrity — e.g., existing rows may violate a new constraint] | [L/M/H] | [L/M/H] | [Audit query run before enforcing constraint] |

## Validation

<!-- How this migration was verified safe before running against production. -->

- **Tested against:** [a production-scale copy of the data, not just a clean seed — confirms the
  migration's actual lock duration and behavior with real data shape, nulls, and duplicates]
- **Query plan verified:** [for a new index or query pattern, confirm the index is actually used
  by the query it's meant to support]
- **Rollback tested:** [confirm the rollback path actually works, per the "a rollback that hasn't
  been tested is a hypothesis" principle — for a migration with asymmetric rollback, state what was
  verified instead: a tested restore-from-backup procedure, for instance]
- **Monitoring in place:** [what will show if this migration is causing problems in production —
  query latency, lock wait time, replication lag]

## Ownership

- **Migration owner:** [name — runs and is accountable for this migration]
- **Reviewer:** [name — reviewed per ../.claude/agents/database-engineer.md's checklist]
- **On-call notified:** [confirm whoever is on-call during the migration window knows it's
  happening and what to watch for]
