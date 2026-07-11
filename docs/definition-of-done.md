# Definition of Done

"Done" is ambiguous by default, and ambiguity about done is one of the most common sources of
rework, surprise scope, and trust erosion between engineering and everyone downstream of it. This
doc defines a concrete, checkable bar that applies to every work item unless explicitly scoped down
for a specific case (and that scoping-down should itself be visible, not silent).

## Why a single definition matters

Without a shared definition, "done" quietly means different things to different people: the engineer
means "code complete," the reviewer means "merged," the product owner means "in production and
verified," and QA means "tested." Each of them is right about their own piece and wrong about the
whole, and the gaps between those definitions are where bugs escape to production and where "didn't
we already finish this?" conversations come from.

## Criteria before work is considered complete

A work item is Done when **all** of the following are true — not aspirationally true, verifiably
true:

- **Code implements the acceptance criteria** from the work item, as agreed in
  [`definition-of-ready.md`](./definition-of-ready.md). If the criteria turned out to be wrong or
  incomplete during implementation, the ticket (or a follow-up) reflects the update — not silently
  divergent code.
- **Automated tests cover the new/changed behavior**, including the failure paths, not just the
  happy path. See [`testing/testing-strategy.md`](./testing/testing-strategy.md) for what "meaningful coverage"
  means here.
- **Code has been reviewed and approved** per [`code-review-guide.md`](./code-review-guide.md), with
  all blocking comments resolved.
- **CI is green** — linting, tests, security scans, and any other required checks pass on the final
  version being merged, not an earlier version of the branch.
- **Documentation is updated** for anything the change affects: public API docs, runbooks,
  architecture docs, READMEs. See [`documentation-standards.md`](./documentation-standards.md).
  Undocumented behavior change is not done, it's deferred work wearing a "done" label.
- **The change is deployed (or ready to deploy) and verified in a real environment**, not just
  merged to trunk. "Merged" and "done" are not synonyms — merged code that hasn't shipped or been
  verified hasn't delivered the value the ticket exists to deliver. What "verified" means scales
  with risk: a manual smoke check for low-risk changes, a monitored canary or staged rollout for
  higher-risk ones (see [`release-process.md`](./release-process.md)).
- **Observability exists for the new behavior where relevant** — if this introduces a new failure
  mode or a new critical path, there's a log, metric, or alert that would surface it going wrong.
  See [`observability-guide.md`](./observability-guide.md).
- **No known regressions were introduced**, or any accepted ones are explicitly tracked (see
  [`technical-debt.md`](./technical-debt.md)) rather than silently shipped.

Use [`../checklists/before-merge.md`](../checklists/before-merge.md) as the operational checklist
that enforces this at the PR stage, and
[`../checklists/before-release.md`](../checklists/before-release.md) for the release-level
counterpart.

## Scaling Definition of Done to risk

Not every change carries the same weight, and applying the full bar uniformly either slows down
trivial changes or — more dangerously — trains the team to skip steps on everything because the full
checklist felt disproportionate for a typo fix. Scale deliberately:

- **Trivial changes** (typo fixes, comment updates, dependency patch bumps with no behavior change)
  can reasonably skip the observability and staged-rollout criteria, but still require review and
  passing CI.
- **Standard feature work** gets the full checklist above.
- **High-risk changes** (data migrations, security-sensitive code, anything touching payment or
  auth) add the criteria from [`risk-assessment.md`](./risk-assessment.md) and may require
  architecture review (see [`architecture-review.md`](./architecture-review.md)) before Done is even
  reachable.

The scaling rule itself should be explicit and agreed by the team, not decided ad hoc per PR —
otherwise "this one's simple, we can skip review" becomes a routinely-invoked escape hatch rather
than a genuine exception.

## What Done is not

- Done is not "I'm confident it works." Confidence without verification (tests, review, staged
  rollout) is a guess, not a completion state.
- Done is not "the ticket is closed." A ticket can be closed prematurely; the criteria above are
  what should gate the closing, not the other way around.
- Done is not permanent. A change that later causes a regression or gets reverted doesn't
  retroactively un-happen — but treat the recurrence as a signal that the Definition of Done had a
  gap (missing test category, missing observability) and fix the definition, not just the individual
  bug.

## Ownership

Whoever is closing the work item is responsible for confirming every criterion, not assuming someone
else checked. In team settings, the reviewer approving the PR is a second checkpoint, not the only
one — a green checklist filled out reflexively without verifying each item defeats the purpose of
having one.
