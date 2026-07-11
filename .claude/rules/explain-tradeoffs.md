# Rule: Explain Tradeoffs

When you make a nontrivial decision, state the alternatives you considered
and why you chose this one. Silent decisions force every future reader —
reviewer, teammate, or your future self — to either trust you blindly or
re-derive the reasoning from scratch. Neither is acceptable for decisions
that matter.

## When this applies

A decision is nontrivial, and needs its tradeoffs stated, when it affects
any of:

- **Performance** — algorithmic choice, caching strategy, sync vs. async,
  batching vs. per-item processing.
- **Security** — authentication/authorization approach, input validation
  strategy, secret handling, third-party dependency trust.
- **Long-term maintainability** — data model shape, module boundaries,
  public API surface, choice of dependency, level of abstraction.
- Any point where a reasonable, competent engineer looking at the same
  problem might plausibly have chosen differently.

It does not apply to decisions with only one reasonable answer (there's no
tradeoff to explain if there was no real alternative).

## What to include

A tradeoff explanation doesn't need to be long. State, concisely:

- **The alternatives considered** — including the option of doing nothing,
  where relevant.
- **Why this one was chosen** — the specific factor that tipped it (existing
  precedent in the codebase, a measured performance requirement, a security
  constraint, a deadline that made the simpler option correct even if not
  ideal).
- **What you're giving up** — the cost of the chosen option, stated
  honestly, not just the benefits.

Put this in the PR description, commit message, or code comment closest to
the decision — wherever a future reader will actually see it. For decisions
significant enough to warrant a permanent record, write it up as an ADR
using [templates/ADR.md](../../templates/ADR.md); see
[docs/decision-making.md](../../docs/decision-making.md) for how to decide
which decisions deserve that level of permanence.

## Example

Weak (states a decision, no tradeoff):

> Used a queue to process uploads.

Sufficient (states the alternative and the reason):

> Used a queue (SQS) instead of processing uploads synchronously in the
> request handler, because upload processing can take 30+ seconds and the
> API has a 10s timeout. Tradeoff: adds eventual-consistency — the client
> polls for completion instead of getting a result inline — and a new
> operational dependency (the queue) to monitor.

The second version lets a reviewer evaluate the decision instead of just
accepting it, and gives the next engineer who touches this code the context
needed to know whether the tradeoff still holds.
