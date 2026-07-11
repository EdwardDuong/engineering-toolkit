# Feature Development Workflow

This is how an experienced team takes a feature from "someone has an idea" to "it's running in
production and we know it works" — not the idealized version, the version that accounts for the
fact that requirements are usually incomplete, the first design is usually wrong in some small way,
and the work isn't done when the code merges.

This doc is the narrative version of the sequence; [`../../.claude/workflows/feature-development.md`](../../.claude/workflows/feature-development.md)
is the same sequence written as an AI-agent-executable playbook, chaining `/plan`, `/implement`,
`/test`, `/review`, and `/security-audit`. Read this one to understand *why* the sequence is shaped
this way; use that one when you want an AI assistant to actually execute it.

## Discovery

Before there's a ticket, there's usually a problem someone believes is worth solving. Discovery is
the (often skipped) step of confirming that belief before committing engineering time to it.

An experienced team asks, in roughly this order:

1. **Is this problem real and current, or assumed?** A feature request driven by one loud
   stakeholder's guess about what users want is a different thing from one backed by support
   tickets, usage data, or a direct user request pattern. Weight the response accordingly — this
   doesn't mean ignoring stakeholder judgment, it means knowing which kind of evidence you're
   acting on.
2. **Does something already solve this?** Check for an existing capability, config option, or
   workaround before assuming new code is needed — see
   [`../../.claude/rules/no-duplicated-logic.md`](../../.claude/rules/no-duplicated-logic.md). A
   surprising fraction of "feature requests" are really "this already exists and nobody found it"
   or "this is a five-minute config change," not a build.
3. **What's the cost of being wrong?** If the shape of the right solution is genuinely unclear, a
   time-boxed spike or prototype that's explicitly thrown away afterward is cheaper than a full
   implementation built on a guess. If the shape is well understood (a well-precedented feature,
   similar to three things already built), skip straight to requirements — spiking a known
   pattern is wasted motion.
4. **Who else does this affect?** A feature that looks self-contained from one team's view can
   have real impact on another team's system, roadmap, or on-call load. Surface this now, not
   after the design is finalized — see [`decision-making.md`](../decision-making.md) on escalating
   ownership, not just visibility, for anything crossing a team boundary.

Discovery ends when the team can state the problem in one or two sentences that a stakeholder would
recognize as accurate, and has a rough sense of whether this is a day of work or a quarter of work.

## Requirements

Discovery answers "should we build this"; requirements answer "what, precisely, are we building."

- Convert the discovery-stage problem statement into concrete, verifiable acceptance criteria —
  Given/When/Then or an equivalent bullet form. "Users can export their data" is not a requirement;
  "a user can request an export of their own account data in CSV format, and receives it within 24
  hours via email" is.
- Separate what's explicitly in scope from what's explicitly out of scope. The out-of-scope list
  is not bureaucracy — it's what prevents the feature from silently growing mid-implementation as
  each new "while we're at it" idea gets folded in.
- Check readiness explicitly against [`definition-of-ready.md`](../definition-of-ready.md) before
  treating requirements as final. A requirement with an unresolved dependency or an ambiguous edge
  case isn't ready, even if it's written down.
- Involve whoever will actually use or be affected by the feature in confirming the requirements,
  not just whoever requested it — a requirement confirmed only by the requester frequently misses
  a real constraint the affected users or systems would have caught immediately.

## Technical Design

Not every feature needs a design document; every feature deserves a design *decision*, even if
that decision is "this fits existing patterns, no new design needed" — see
[`architecture-first.md`](../../.claude/rules/architecture-first.md) for how to size the effort.

- **Small, well-precedented feature**: a sentence or two on approach in the PR description is
  enough. Don't manufacture a design doc the change doesn't need.
- **Feature with real design choices**: work out data flow, components touched, and the shape of
  any new interface before writing implementation code. If there are genuinely two or more viable
  approaches with real tradeoffs, write them down and state which was chosen and why — see
  [`../../.claude/rules/explain-tradeoffs.md`](../../.claude/rules/explain-tradeoffs.md).
- **Feature that introduces a new system boundary, a significant dependency, or a one-way-door
  decision**: this needs the judgment in
  [`../../.claude/agents/architect.md`](../../.claude/agents/architect.md) and a recorded decision
  — an RFC first if it needs broad input (see [`rfc-process.md`](../rfc-process.md)), an ADR once
  decided (see [`adr-guide.md`](../adr-guide.md)). Reviewed *before* implementation starts, when
  the design is still cheap to change.

An experienced team treats the design step as cheap insurance, not overhead — the earlier a bad
approach is caught, the less code has to be thrown away.

## Implementation

Implementation is where the design becomes real, and where an experienced team's discipline shows
most clearly in the small decisions: what order to build things in, when to stop and reconsider,
and what "done" actually means for each step.

- Build in small, ordered, independently-verifiable steps — data/interface changes first, then
  core logic, then integration points, then edge cases and error handling. Each step should leave
  the codebase in a state you could stop at without leaving something broken.
- Match existing patterns in the surrounding code before introducing a new one; a new pattern needs
  a stated reason, not just preference — see
  [`clean-code.md`](../clean-code.md) and [`readability.md`](../../.claude/rules/readability.md).
- If part of the change requires restructuring existing code first, do that as a separate,
  clearly-labeled refactor with test coverage confirmed beforehand — never mix a refactor and a
  behavior change in the same unreviewable step.
- Security and performance are addressed as each piece is built, not swept for at the end — see
  [`security-guide.md`](../security-guide.md) and [`performance-guide.md`](../performance-guide.md).
- Apply the specialist lens for whatever the feature actually touches:
  [`backend-engineer.md`](../../.claude/agents/backend-engineer.md),
  [`frontend-engineer.md`](../../.claude/agents/frontend-engineer.md),
  [`database-engineer.md`](../../.claude/agents/database-engineer.md), or
  [`devops-engineer.md`](../../.claude/agents/devops-engineer.md) — most non-trivial features touch
  more than one.

## Testing

Testing that happens only after implementation "feels done" tends to test what was easy to test,
not what actually needed coverage. An experienced team treats the test strategy as a design
question, not a final chore.

- Decide the test pyramid shape for this specific change per
  [`testing/testing-strategy.md`](../testing/testing-strategy.md): what belongs at unit level, what requires a real
  collaborator (integration), and whether anything genuinely needs end-to-end coverage.
- Cover the acceptance criteria from the requirements step explicitly, plus the edge cases and
  error paths identified during design — not just the happy path a demo would show.
- For every new test, confirm it actually fails if the change is reverted. A test that passes both
  with and without the change under test isn't coverage.
- Decide explicitly what's *not* being tested and why — usually because it's covered at a
  different level already, not because it was hard to test.

## Review

Review is the last checkpoint before the change becomes everyone's baseline, and an experienced
team treats it as a real gate, not a formality on the way to merge.

- Self-review against [`code-review-guide.md`](../code-review-guide.md) and
  [`before-pull-request.md`](../../checklists/before-pull-request.md) before requesting a human
  reviewer's time — a diff sent for review that the author hasn't reviewed themselves wastes the
  reviewer's attention on issues the author could have caught.
- A human reviewer evaluates correctness, maintainability, security, and performance — see
  [`../../.claude/agents/reviewer.md`](../../.claude/agents/reviewer.md) — and marks findings
  blocking or non-blocking explicitly, so the author isn't left guessing what gates the merge.
- Disagreement is resolved by explaining reasoning, not by silently overriding a reviewer's comment
  or silently deferring to it without understanding why — both erode the value of review over time.
- Before merge, confirm [`before-merge.md`](../../checklists/before-merge.md): required approvals
  obtained, CI green on the current commit, nothing left unresolved in the thread.

## Deployment

A feature isn't done when it merges — it's done when it's running in production, behaving as
intended, and the team knows that, not assumes it.

- Match the rollout strategy to the change's risk, per
  [`../../.claude/agents/devops-engineer.md`](../../.claude/agents/devops-engineer.md): a
  low-risk, well-tested change can deploy directly; a higher-risk one warrants a feature flag,
  canary, or progressive rollout that contains the blast radius automatically.
- Confirm observability exists *before* the feature carries real traffic — see
  [`observability-guide.md`](../observability-guide.md) and
  [`production-readiness.md`](../../checklists/production-readiness.md) — not after the first
  silent failure reveals the gap.
- Know the rollback path before you need it. If the deployment includes a database migration,
  rollback is asymmetric — see [`database-change.md`](database-change.md) — and that asymmetry
  needs to be understood before deploying, not discovered mid-incident.
- Verify the deployed behavior directly (the actual endpoint, the actual UI, the actual job
  running) rather than assuming the pipeline's green checkmark means the feature works as intended.

## What "done" actually means

A feature is done when: it meets the acceptance criteria from requirements, it has tests that
would catch a regression, its documentation is accurate, it has been reviewed and approved, it is
running in production, and someone has verified it behaves as intended there. Any earlier point is
progress, not completion — see [`definition-of-done.md`](../definition-of-done.md).
