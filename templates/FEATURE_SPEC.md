<!--
Template: Feature Specification
Use this when: a feature has been approved for build (see feature-request.md for the lighter-weight
intake form used before approval) and needs a build-ready spec — precise enough that an engineer who
wasn't in the room for discovery can implement it without re-deriving scope from a conversation.
Related: ../docs/workflows/feature-development.md (the full discovery-through-deployment sequence
this spec sits inside), ../docs/definition-of-ready.md (the bar this spec must clear before work
starts), feature-request.md (the intake form this spec is promoted from once approved).
-->

# Feature Spec: [Feature name — specific, not "Improve X"]

**Status:** [Draft | Ready for build | In progress | Shipped]
**Owner:** [Name — accountable for scope and delivery]
**Target release:** [version, date, or "next available" if uncommitted]

## Context

<!-- Why this, why now. The business or user signal that justifies spending engineering time here,
     not a restatement of the feature itself. -->

[What evidence says this is worth building now — user research, support ticket volume, a metric
trending the wrong way, a competitive gap, a dependency another team is blocked on. Cite the actual
evidence, not "users have asked for this."]

## Problem

<!-- The precise user or business problem this solves, stated so specifically that a reader could
     evaluate whether the feature below actually solves it. -->

[State the problem, not the solution. "Users abandon checkout at a 23% rate on the payment step,
and support tickets show 40% of those cite not trusting the payment form" is a problem. "We need a
better payment form" is not — it's already halfway to a solution without justifying which one.]

## Decision

<!-- What's being built, precisely — the shape of the solution, its scope, and explicitly what's
     out of scope. This is the section a build engineer works from. -->

**We will build:** [concrete description of the feature as it will actually behave]

**Acceptance criteria:**
- [ ] [Given/When/Then or verifiable bullet — specific enough to be a pass/fail test, not an
      aspiration. "The export completes within 24 hours for accounts under 10GB" not "exports are
      fast."]
- [ ] [...]

**Explicitly out of scope:** [what a reasonable reader might assume is included but isn't — this
list prevents the most common source of mid-build scope creep]

**Dependencies:** [other teams, systems, or in-flight work this depends on, and their current
status]

## Alternatives

<!-- Other ways this problem could have been solved, and why this specific scope was chosen over
     them — including narrower and broader versions of the same idea. -->

### [Narrower version of this feature]

[What a smaller version would look like, and why the team chose to build more (or why this spec
*is* the narrower version and a broader one was explicitly deferred).]

### [A different approach to the same problem]

[A genuinely different solution shape that was considered, and the specific reason it lost —
cost, timeline, doesn't generalize, conflicts with an existing pattern.]

### Do nothing

[Why the problem in the Problem section isn't acceptable to leave unaddressed right now.]

## Risks

<!-- What could make this feature fail to deliver its intended value, or cost more than expected. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Delivery risk — e.g., depends on an API another team hasn't shipped yet] | [L/M/H] | [L/M/H] | [...] |
| [Adoption risk — e.g., users may not discover this without a UI change out of scope] | [L/M/H] | [L/M/H] | [...] |
| [Technical risk — e.g., requires a schema change with migration risk, see database-change.md] | [L/M/H] | [L/M/H] | [...] |

## Validation

<!-- How the team will know, after shipping, whether this actually solved the Problem stated above
     — not just whether it shipped. -->

- **Pre-launch:** [test strategy reference — see ../docs/testing/testing-strategy.md — and any beta/staged
  rollout plan]
- **Success metric:** [the specific, measurable signal that indicates the problem is improving —
  tied directly back to the evidence cited in Context, e.g., "checkout abandonment on the payment
  step drops below 15% within 30 days of full rollout"]
- **Check-in date:** [when the team will actually look at the metric above and decide whether this
  worked, was neutral, or needs iteration]

## Ownership

- **Spec owner:** [name — accountable for scope decisions during build]
- **Engineering lead:** [name or team building this]
- **Stakeholders:** [names/teams who need to be informed of scope changes or slips]
- **Reviewers:** [who signs off that this spec is ready per ../docs/definition-of-ready.md]
