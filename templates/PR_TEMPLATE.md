<!--
Template: Pull Request Description
Use this when: opening a pull request and you want reviewers to have the context they need without
asking follow-up questions. Run through ../checklists/before-pull-request.md before requesting
review. A worked example: ../examples/good-pull-request.md
Many repos drop this into .github/pull_request_template.md so it auto-populates new PRs — see
../.github/PULL_REQUEST_TEMPLATE/pull_request_template.md for this repo's own copy.
-->

## Summary

<!-- What does this PR do, in 1-3 sentences? Assume the reviewer has not read the linked issue. -->

[Summary of the change.]

**Type:** [ ] Feature · [ ] Bug fix · [ ] Refactor (no behavior change) · [ ] Docs · [ ] Chore/CI

## Context

<!-- Why this change, why now. Link the issue, spec, or ADR this implements rather than
     re-explaining background that's already written down elsewhere. -->

[Link to the issue / FEATURE_SPEC.md / ADR.md / bug report this implements. If there's no linked
document, state the motivating context directly — a reviewer shouldn't have to reconstruct why this
change exists.]

## Problem

<!-- What specifically breaks, is missing, or is unsafe without this change. -->

[State the problem this PR solves, distinct from the summary above — this is the "why does this
diff need to exist" a reviewer checks the code against.]

## Decision

<!-- The approach taken. This is the section that saves reviewers the most time — call out any
     non-obvious decision so the reviewer isn't left reverse-engineering your reasoning from the
     diff alone. -->

[Explain the approach. What files/components does this touch, and why this shape? Flag anything
that deviates from the existing pattern in this codebase and say why.]

## Alternatives

<!-- What else was considered and rejected, if anything — even briefly. Not every PR needs this in
     depth (a one-line fix doesn't), but any nontrivial approach decision does, per
     ../.claude/rules/explain-tradeoffs.md. -->

[What else could have solved this problem, and why this approach was chosen instead. "N/A —
straightforward fix, no real alternative" is a fine answer for small changes; don't manufacture
alternatives that weren't genuinely considered.]

## Risks

<!-- Blast radius and what could go wrong, plus how it's contained. -->

- **Blast radius:** [what else could be affected by this change — a shared utility, a hot path, a
  public contract]
- **Breaking change:** [ ] Yes · [ ] No — if yes, link the deprecation/migration plan per
  ../docs/workflows/api-change.md or ../docs/workflows/database-change.md
- **Rollback plan:** [how this gets undone if it causes a problem in production — "revert this PR,
  no data migration involved" or the specific manual steps if it's more involved]

## Validation

<!-- What was actually run, not what should theoretically pass. -->

- [ ] Unit tests added/updated — [describe what's covered]
- [ ] Manually tested: [exact steps taken]
- [ ] Edge cases considered: [list — empty input, error paths, concurrent access if relevant]
- [ ] Security-relevant change: [ ] Yes, ran `/security-audit` · [ ] No

## Ownership

- **Author:** [name]
- **Reviewers requested:** [names — include a specialist per ../.claude/agents/ if this concentrates
  in one domain, e.g. database-engineer.md for a migration-heavy PR]
- **Related work:** [links to follow-up tickets this PR intentionally doesn't cover]

## Checklist

<!-- See the full pre-PR checklist: ../checklists/before-pull-request.md -->

- [ ] I have read and completed [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md)
- [ ] This PR is scoped to a single concern and is reasonably sized for review
- [ ] I have updated relevant documentation
