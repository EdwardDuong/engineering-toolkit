# Database Guidelines

Data outlives code. A service can be rewritten in a weekend; a schema mistake or a bad migration can
take months to fully recover from, because by the time it's noticed, real data has already been
shaped by it. These guidelines apply across relational and non-relational stores — the underlying
concerns (safe change, access patterns, transactional correctness, retention) are the same
regardless of which kind of store you're using.

## Schema change safety

- **Every schema change should be backward-compatible with the currently-deployed code**, not just
  with the code being deployed next. During a rolling deploy, old and new code run simultaneously
  against the same schema — a change that only the new code understands will break the old code
  still running.
- **Expand-contract as the default pattern for anything non-trivial**: add the new structure (new
  column, new table, new field) without removing the old one; deploy code that writes to both and
  reads from the new one with fallback; backfill existing data; deploy code that only uses the new
  structure; only then remove the old structure, in a separate, later change. Collapsing these steps
  into one migration is what turns a routine schema change into an outage.
- **Never repurpose an existing field for a new meaning.** Add a new field instead. Reusing a column
  means every historical row and every piece of code that ever referenced the old meaning is now
  ambiguous, and there's no way to tell which meaning a given row's value was written under.
- **Additive changes (new nullable column, new table, new index) are low-risk and can generally ship
  without a special process.** Anything that removes, renames, or changes the type/constraints of an
  existing structure is high-risk and should go through the same rigor as any other
  high-blast-radius change — see [`risk-assessment.md`](./risk-assessment.md) — with a tested
  rollback plan.
- **Test migrations against a realistic data volume and shape**, not an empty or toy dataset. A
  migration that runs in milliseconds against a thousand test rows can take hours and lock a table
  against production traffic at real scale.
- **Long-running migrations on live tables should avoid locking the table for the full duration** —
  use whatever online-migration or batched-write mechanism your store supports rather than a single
  blocking operation, especially for anything touching a high-traffic table.

## Indexing discipline

- Every query pattern that runs in production, especially on a hot path, should be backed by an
  index that supports it — see the missing-index anti-pattern in
  [`performance-guide.md`](./performance-guide.md).
- Indexes are not free: each one adds write overhead and storage cost. Don't add an index
  speculatively for a query pattern that doesn't exist yet (see
  [`yagni-principle.md`](./yagni-principle.md)) — add it when the query exists and profiling shows
  it needs one.
- Review and remove unused indexes periodically. An index nothing queries through still costs every
  write that touches its table, with no offsetting benefit.
- Composite index column order matters — put the columns used in equality filters before those used
  in range filters or sorts, matching your store's actual query planner behavior; verify with an
  execution plan rather than assuming.

## Transaction boundaries

- A transaction should map to a single logical operation that must succeed or fail atomically — not
  "everything this request happens to touch." An overly broad transaction holds locks longer than
  necessary and increases contention; an overly narrow one risks leaving data in an inconsistent
  state if a later step fails.
- Be explicit about isolation level requirements per operation rather than accepting the store's
  default everywhere without thinking about it — some operations need strict consistency (e.g.,
  decrementing inventory), others tolerate eventual consistency (e.g., a denormalized read-only
  view), and treating both the same either wastes performance or risks a race condition.
- Never hold a transaction open across a network call to another system (an external API, another
  service). A slow or stalled external call now holds database locks for as long as that call takes,
  which can cascade into a broader outage under load.
- For operations spanning multiple independently-owned data stores (e.g., two services each owning
  their own database), a single ACID transaction usually isn't available — use an explicit pattern
  (saga, outbox) for eventual consistency with compensating actions, rather than assuming atomicity
  that doesn't actually exist across the boundary.

## Data retention

- Define a retention policy per data category, not one blanket policy for the entire store —
  operational logs, user-generated content, and financial records typically have different legal,
  business, and cost-driven retention requirements.
- Deletion should be a deliberate, auditable process (soft-delete with a defined hard-delete
  schedule, or an explicit purge job), not an incidental side effect of unrelated code, and not left
  to accumulate forever by default either — unbounded retention is its own liability, both for
  storage cost and for the blast radius of a future data breach.
- Sensitive data (PII, credentials, payment details) should have the shortest retention consistent
  with legal and business need, and be excluded from long-lived backups and logs wherever possible —
  see [`logging-standards.md`](./logging-standards.md) and
  [`security-guide.md`](./security-guide.md).
- Test that deletion actually removes data from every place it's replicated to — a primary
  datastore, search indexes, caches, backups, and downstream analytics pipelines can all retain a
  copy after the "source of truth" has deleted it, which defeats the purpose of a retention policy
  if unaccounted for.

## Review and ownership

Schema changes affecting a shared or high-traffic table should go through
[`../checklists/database-review.md`](../checklists/database-review.md) before merging, and
significant changes to a system's data model are exactly the kind of decision
[`adr-guide.md`](./adr-guide.md) exists to record — a future engineer asking "why is this table
shaped this way" should be able to find the answer.
