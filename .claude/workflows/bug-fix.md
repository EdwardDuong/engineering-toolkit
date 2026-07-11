# Workflow: Bug Fix

This is the end-to-end playbook for taking a bug report to a merged fix. The
sequence exists to prevent the most common failure mode in bug fixing:
patching a symptom instead of the cause, and shipping it without proof it
won't recur.

## 1. Triage: is this production-impacting?

Before investigating, determine whether the bug is currently affecting
production users or systems. If it is — active data corruption, an outage,
a security exposure, broken payments, or anything with ongoing user impact —
stop following this workflow linearly and escalate per
[docs/incident-response.md](../../docs/incident-response.md) first. Incident
response may require an immediate mitigation (rollback, feature flag, hotfix)
ahead of the careful root-cause process below. Once the incident is
stabilized, return to this workflow to do the fix properly and write it up.

For a non-production-impacting bug (caught in testing, reported by a user
but not actively harmful, found via code review), proceed directly with the
steps below.

## 2. Investigate with the investigate-bug command

Run `/investigate-bug` (defined in
[.claude/commands/investigate-bug.md](../commands/investigate-bug.md)) with
the bug description. This carries you through reproduction, isolation, and
root-cause analysis — don't skip straight to a fix based on a hunch about
what's wrong. A fix built on an unconfirmed cause frequently doesn't
actually fix anything, or fixes the visible symptom while the underlying
defect resurfaces elsewhere.

## 3. Apply root-cause analysis rigorously

The investigate-bug command references
[prompts/root-cause-analysis.md](../../prompts/root-cause-analysis.md) and
[docs/root-cause-analysis.md](../../docs/root-cause-analysis.md) — actually
use the method described there (repeated "why" questioning, tracing the
failure back through the call chain to where the wrong assumption or missing
check originates) rather than stopping at the first plausible-looking
explanation. A shallow root cause produces a shallow fix.

## 4. Fix and write the regression test together

Implement the fix and its regression test as one unit, not two separate
steps where the test is an afterthought. The regression test must fail
against the pre-fix code — verify this (temporarily revert the fix locally
and confirm the test catches it) before considering the fix complete. This
is non-negotiable per
[.claude/rules/tests-and-documentation.md](../rules/tests-and-documentation.md).

## 5. Check for the same defect pattern elsewhere

If the root cause is a pattern rather than a one-off typo (a missing
validation that could exist in similar code paths, a race condition in a
pattern used elsewhere, an off-by-one in a commonly-copied loop), search the
codebase for other instances of the same pattern. Fix or flag them — finding
a bug once and leaving three siblings in place is a near-guarantee of a
repeat report.

## 6. Self-review, then walk before-merge

Run `/review-pr` (defined in
[.claude/commands/review-pr.md](../commands/review-pr.md)) against the fix.
Before merging, walk
[checklists/before-merge.md](../../checklists/before-merge.md) to confirm CI
is green and the change is ready.

## 7. Close the loop

If this bug was reported by a user, filed as an incident, or tracked in an
issue, update that record with the root cause and fix summary — the person
who reported it (or the next engineer who hits something similar) should be
able to find out what actually happened, not just that "it's fixed."
