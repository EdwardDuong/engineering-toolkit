---
description: Review a diff or change for correctness, maintainability, security, and performance before it ships.
argument-hint: [diff, PR reference, or file/change to review]
---

Review the following change across all four dimensions below. A review that
only checks "does this work" and skips the other three is incomplete —
maintainability, security, and performance problems are exactly the ones
that don't show up as a failing test today and become expensive later.

**Change**: $ARGUMENTS

## Process

1. **Correctness.** Adopt the [`../agents/reviewer.md`](../agents/reviewer.md)
   persona for this pass. Verify:
   - The change does what it claims to do, including the edge cases and
     error paths, not just the stated happy path.
   - Tests actually exercise the new behavior (would they fail if the
     change were reverted?), per
     [`../../docs/testing/testing-strategy.md`](../../docs/testing/testing-strategy.md).
   - No existing behavior silently changed as a side effect — check the
     blast radius, not just the lines touched.

2. **Maintainability.** Check against
   [`../../docs/code-review-guide.md`](../../docs/code-review-guide.md) and
   [`../rules/readability.md`](../rules/readability.md):
   - Naming, structure, and pattern consistency with the surrounding code.
   - Whether any new abstraction is earning its cost — apply
     [`../rules/no-unnecessary-abstractions.md`](../rules/no-unnecessary-abstractions.md).
   - Whether documentation and comments were updated per
     [`../rules/tests-and-documentation.md`](../rules/tests-and-documentation.md),
     and whether nontrivial decisions have a stated rationale per
     [`../rules/explain-tradeoffs.md`](../rules/explain-tradeoffs.md).

3. **Security.** Apply the lens in
   [`../agents/security-engineer.md`](../agents/security-engineer.md) at
   least at a first-pass level for every change; run the dedicated
   [`/security-audit`](security-audit.md) command instead of this
   abbreviated pass for anything touching auth, input handling, secrets,
   dependencies, or data access. At minimum, check:
   - All external input is validated or safely handled — see
     [`../rules/security-awareness.md`](../rules/security-awareness.md).
   - No secret, credential, or token is hardcoded anywhere in the diff,
     including in test fixtures and comments.
   - No new dependency was added without a reason to trust it — see
     [`../../docs/dependency-management.md`](../../docs/dependency-management.md).

4. **Performance.** Apply
   [`../rules/performance-awareness.md`](../rules/performance-awareness.md)
   and [`../../docs/performance-guide.md`](../../docs/performance-guide.md):
   - Any obviously worse algorithmic complexity than necessary (N+1 queries,
     unbounded loops over external data, synchronous I/O on a hot path).
   - Whether a performance-sensitive change has evidence (a benchmark, a
     profile) behind it rather than an unverified assumption — flag
     unmeasured claims either way, whether optimistic or pessimistic.

5. **Domain-specific pass.** If the change concentrates in one domain, add
   that specialist's checklist from `../agents/` — `backend-engineer.md`,
   `frontend-engineer.md`, `database-engineer.md`, or `devops-engineer.md`
   — on top of the four passes above. A schema migration reviewed only
   through the general lens above will miss migration-specific risk that
   [`../agents/database-engineer.md`](../agents/database-engineer.md)'s
   checklist exists specifically to catch.

## Output shape

Report findings grouped by the four dimensions above, each finding marked
**blocking** (must be fixed before merge) or **non-blocking** (worth raising,
doesn't gate this change), per the etiquette in
[`../../docs/code-review-guide.md`](../../docs/code-review-guide.md). For
each blocking finding, state the concrete failure scenario it causes, not
just that something "looks wrong" — a review comment without a scenario is
not actionable. Close by confirming or denying whether the change meets
[`../../checklists/before-merge.md`](../../checklists/before-merge.md) and
[`../../docs/definition-of-done.md`](../../docs/definition-of-done.md).
