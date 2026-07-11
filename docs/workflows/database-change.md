# Database Change Workflow

Schema changes are the one category of change where "just revert it" often doesn't mean what it
means everywhere else in software — data written under a new schema doesn't un-write itself when
the code rolls back. This workflow is how an experienced team ships a schema change without
learning that the hard way. It's the process view of
[`database-guidelines.md`](../database-guidelines.md)'s principles and the operating sequence
[`../../.claude/agents/database-engineer.md`](../../.claude/agents/database-engineer.md) applies
to any change touching the data layer.

## Migration Safety

A migration is safe when it can run against a live, traffic-serving system without corrupting
data, blocking writes for longer than the team has decided is acceptable, or requiring the old and
new application code to never coexist.

- **Sequence as expand, migrate, contract — never as one step.** Add the new schema element
  (nullable column, new table) first and deploy it alongside code that doesn't yet depend on it
  (expand). Backfill or dual-write as needed once both schema versions can coexist (migrate). Only
  after the old code path is fully retired, remove the old schema element (contract). Collapsing
  these into a single deploy is the single most common cause of a migration-induced outage, because
  it assumes old and new code never run simultaneously — in a rolling deployment, they always do
  for some window.
- **Know the lock behavior before running it, not after.** The same-looking migration can be
  instant on one database engine and a full table rewrite that locks writes for minutes on another,
  or depend heavily on table size. Check the actual behavior against production-scale data, not
  just a small local or staging copy where the problem is invisible.
- **Test the migration against a realistic copy of production data**, not just a clean seeded
  database. Real data has the nulls, duplicates, and edge-case values a hand-written test fixture
  doesn't, and those are exactly what a migration is most likely to trip on.
- **Batch large backfills** rather than running them as a single unbounded operation — a backfill
  that touches millions of rows in one transaction holds locks and contends with live traffic for
  the entire duration; chunked, throttled backfills keep the system responsive while the migration
  completes.

## Backward Compatibility

Because schema and application code deploy independently in most real systems, a migration must
work correctly against *both* the old and new application code for the entire rollout window.

- Before writing the migration, explicitly answer: "if the old code runs against the new schema,
  does it still work? If the new code runs against the old schema, does it still work?" A migration
  that requires "yes" to only one of those isn't ready to ship yet — it needs an intermediate step.
- Adding a column is safe by default if it's nullable or has a default; removing or renaming a
  column is not safe until every consumer (including the application code being replaced) has
  stopped reading or writing it — treat schema elements with the same deprecate-before-remove
  discipline as a public API (see [`api-change.md`](api-change.md) and
  [`../../.claude/rules/backward-compatibility.md`](../../.claude/rules/backward-compatibility.md)).
- Widening a value's meaning (a status field gaining a new valid value, a nullable column becoming
  meaningful) is usually safe; narrowing it (removing a valid value, adding a constraint that
  existing rows might violate) requires checking existing data against the new constraint before
  the constraint is enforced, not after.
- If application code and schema must change together in a way that can't be sequenced safely
  (rare, but it happens), that's a signal to slow down and design an explicit multi-step rollout
  rather than accepting the risk of a simultaneous change.

## Rollback Strategy

Code rollback and data rollback are not the same operation, and an experienced team knows which
one a given migration actually needs before it's deployed, not while an incident is active.

- **A migration that has only added schema (the expand phase) is trivially safe to roll back** —
  the old code never used the new element, so reverting the code deploy leaves the schema harmlessly
  ahead of what's being read.
- **A migration that has changed or removed existing data is not safely reversible by a code
  rollback alone.** If the new code has already transformed, backfilled over, or deleted data in a
  way the old code's assumptions don't account for, rolling back the code does not restore the data
  to its prior state. Know this asymmetry before deploying — it changes how cautious the rollout
  needs to be, not just what happens if something goes wrong.
- Where the risk warrants it, keep a verified backup or point-in-time recovery capability
  confirmed *before* a destructive migration runs, and confirm the restore path actually works
  (per the "a rollback that hasn't been tested is a hypothesis" principle in
  [`../../.claude/agents/devops-engineer.md`](../../.claude/agents/devops-engineer.md)) rather than
  assuming the backup system works because it's supposed to.
- For any migration where rollback is asymmetric or nontrivial, state the rollback plan explicitly
  before deploying — not as a formality, but because "how do we undo this" is a much worse question
  to be answering for the first time during an incident than during planning. See
  [`production-incident.md`](production-incident.md) for what happens if a migration is the cause
  of one.

## Where this fits in review

A database change should be reviewed through
[`../../.claude/agents/database-engineer.md`](../../.claude/agents/database-engineer.md)'s
checklist in addition to ordinary code review, and walked against
[`../../checklists/database-review.md`](../../checklists/database-review.md) before it ships. A
migration is architecture-review material (see
[`architecture-review.md`](../architecture-review.md)) when it touches a widely-depended-on table or
changes an established data ownership boundary — treat it with the same deliberation as any other
one-way-door decision.
