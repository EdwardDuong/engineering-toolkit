# Database Review

Guide an AI assistant through reviewing a schema change, migration, or query
for safety: backward compatibility, locking behavior, and indexing.

## Purpose

Database changes are among the hardest to safely undo in production — a bad
migration can lock a table for minutes, break a running deploy, or corrupt
data at scale. This prompt forces explicit reasoning about lock behavior,
rollout compatibility, and index impact before a migration is considered
safe to ship.

## When to use

- Reviewing a schema migration (new column, index, constraint, table
  change) before it runs against production.
- Reviewing a new or modified query for performance/locking impact,
  especially on high-traffic tables.
- Planning a change that must be backward-compatible during a rolling
  deploy (old and new code running simultaneously).

## The prompt

```markdown
You are reviewing a database change for production safety. Assume this
will run against a live system with concurrent reads/writes and that the
deploy is rolling (old and new application code may run simultaneously
against the same schema for a period).

## Context
- Migration / schema change / query: {{migration_or_query}}
- Database engine and version: {{db_engine_version}}
- Approximate table size(s) affected (row count, if known): {{table_size}}
- Deploy model (rolling deploy, maintenance window, blue/green):
{{deploy_model}}
- Current indexes on affected table(s), if known: {{existing_indexes}}

## Review dimensions

### 1. Backward compatibility
- If this is a rolling deploy: will the *old* application code still work
  correctly against the *new* schema, and vice versa, during the rollout
  window?
- Does this change require a multi-step migration (e.g., add nullable
  column -> backfill -> add NOT NULL constraint -> remove old column in a
  later release) rather than a single destructive step?
- Does it rename or remove anything still referenced by running code?

### 2. Locking behavior
- Does this migration acquire a table-level lock, and for how long is that
  lock expected to be held given the table size?
- Does the database engine/version support this change online
  (non-blocking), or does it require an explicit online-migration
  strategy (e.g., shadow table, `pt-online-schema-change`,
  engine-native online DDL)?
- For the query under review: does it hold locks longer than necessary
  (missing `LIMIT`, unindexed `WHERE`/`JOIN` causing full scans under a
  lock, long-running transaction wrapping unrelated work)?

### 3. Indexing
- Are new columns used in `WHERE`, `JOIN`, `ORDER BY`, or uniqueness
  constraints properly indexed?
- Does adding this index itself risk a long lock (and if so, is it created
  concurrently/online where the engine supports it)?
- Are there now-redundant indexes this change should also remove?

### 4. Data integrity
- Constraints (foreign keys, uniqueness, not-null) — do they match the
  actual data currently in the table, or will the migration fail/reject
  existing rows?
- For backfills: is the backfill batched (to avoid a single giant
  transaction/lock) and idempotent (safe to re-run if interrupted)?

### 5. Rollback
- Can this migration be rolled back safely if the deploy is reverted? What
  happens to data written under the new schema if the old schema is
  restored?
- Is the rollback plan the reverse migration, or does it require a
  separate strategy (e.g., because a destructive step already ran)?

## Output format

**Findings**, each tagged:
- **Blocking**: unsafe to run as-is (would lock/break production).
- **Needs staging**: should be split into multiple deploy-safe steps.
- **Advisory**: safe but worth noting (missing index opportunity, etc.).

**Recommended migration plan**: the concrete sequence of steps (single
migration, or phased across N releases) to make this safe.

**Rollback plan**: what to do if this needs to be reverted after
deployment.
```

## Expected output

- Findings tagged Blocking / Needs staging / Advisory, each explained in
  terms of lock behavior, compatibility, or data integrity.
- A concrete, possibly multi-step migration plan rather than a single
  "run this" statement when the change is unsafe as one step.
- An explicit rollback plan.

## Tips & pitfalls

- Adding a `NOT NULL` column without a default, or a new unique constraint
  on a large existing table, are the two most common ways this goes wrong
  — give both explicit scrutiny.
- For rolling deploys, always check both directions of compatibility (old
  code + new schema, and new code + old schema) — reviews often only check
  one.
- If table size is unknown, ask for it rather than assuming small — lock
  duration and online-DDL necessity depend entirely on scale.
- See [`../docs/database-guidelines.md`](../docs/database-guidelines.md)
  for this repo's migration conventions and
  [`../checklists/database-review.md`](../checklists/database-review.md)
  for the pre-merge gate.
