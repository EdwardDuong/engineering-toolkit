# Architecture Review

Architecture review is a deliberate checkpoint for changes significant enough that getting the
design wrong would be expensive to unwind — distinct from ordinary code review, which happens on
every change and evaluates implementation quality rather than structural fit.

## When a change needs architecture review

Not every change does — requiring it universally would either bottleneck routine work or, more
likely, train people to treat it as a rubber stamp. Trigger architecture review when a change has
any of:

- **Introduces or changes a system boundary** — a new service, a new integration point between
  existing components, a change to which component owns a given piece of data. See
  [`architecture-principles.md`](./architecture-principles.md) on why boundaries are the
  load-bearing structure worth extra scrutiny.
- **Introduces a significant new external dependency** — a new database technology, a new
  third-party platform the system now depends on for a critical function, anything that becomes hard
  to remove once adopted.
- **Is a one-way door decision** per the framing in [`decision-making.md`](./decision-making.md) —
  expensive or impossible to reverse once shipped.
- **Scores high risk** per [`risk-assessment.md`](./risk-assessment.md), specifically on the impact
  axis — a change with a large blast radius benefits from more eyes before it ships, regardless of
  how confident the author is.
- **Sets a precedent** other teams are likely to follow — the first use of a new pattern, framework,
  or approach in the codebase deserves scrutiny precisely because it's likely to be copied
  uncritically by the next several changes that resemble it.

A useful heuristic: if the honest answer to "would this be expensive to redo if we got it wrong" is
yes, it needs architecture review. If the answer is "we'd just refactor it, mildly annoying but not
a big deal," ordinary code review is sufficient.

## What reviewers evaluate

- **Fit with existing architecture** — does this follow or deliberately, explicitly diverge from
  established patterns and principles (see
  [`architecture-principles.md`](./architecture-principles.md),
  [`solid-principles.md`](./solid-principles.md))? A deliberate divergence is fine if justified; an
  accidental one usually indicates the author wasn't aware of the existing pattern, which is worth
  surfacing before it ships, not after three more changes have copied it.
- **Boundary and contract soundness** — are the interfaces this change introduces or modifies
  well-defined, versioned appropriately (see [`api-design-guide.md`](./api-design-guide.md)), and
  owned unambiguously?
- **Coupling introduced** — does this change increase coupling between components that should stay
  independent, or introduce a dependency that will be hard to remove later? See the coupling
  discussion in [`architecture-principles.md`](./architecture-principles.md).
- **Necessity of the complexity** — is every piece of the proposed design earning its cost against a
  real, current requirement, or does it include speculative flexibility that isn't yet justified?
  See [`yagni-principle.md`](./yagni-principle.md).
- **Operational readiness** — has the proposal considered how this will be observed, deployed, and
  rolled back in production (see [`observability-guide.md`](./observability-guide.md),
  [`release-process.md`](./release-process.md)), not just how it will be built?
- **Alternatives considered** — did the author evaluate more than one approach, and is the reasoning
  for the chosen one documented well enough that a future reader understands why the alternatives
  were rejected, not just that they existed?

## Review process

1. **Author writes up the proposal** before implementation is far along — an RFC (see
   [`rfc-process.md`](./rfc-process.md)) for anything requiring broad input and debate, or a lighter
   design note for something more contained but still significant enough to warrant review.
2. **Reviewers evaluate against the criteria above**, asking clarifying questions and raising
   concerns as specific, actionable feedback — the same etiquette as code review (see
   [`code-review-guide.md`](./code-review-guide.md)) applies: critique the design, not the author.
3. **Concerns are resolved before implementation proceeds at scale.** It's reasonable to prototype
   or spike before or during review to answer a specific open question, but committing to full-scale
   implementation before architecture review has converged risks sunk-cost pressure overriding
   legitimate concerns raised during review.
4. **The decision and its reasoning are recorded** — via an ADR (see
   [`adr-guide.md`](./adr-guide.md)) once the design is settled, so the outcome of the review is
   discoverable by anyone who wasn't in the room.

Use [`../checklists/architecture-review.md`](../checklists/architecture-review.md) as the concrete,
run-through checklist for conducting a specific review, and
[`../prompts/architecture-review.md`](../prompts/architecture-review.md) for an AI-assisted first
pass over a design before it goes to human reviewers.

## Keeping this from becoming a bottleneck

- Scope review to what actually needs it — see the triggers above — rather than gatekeeping every
  change through the same heavyweight process.
- Set a clear turnaround expectation for architecture review, similar in spirit to the SLAs in
  [`code-review-guide.md`](./code-review-guide.md), so it doesn't become a black hole a proposal
  disappears into for weeks.
- Prefer async written review (an RFC with comments) over requiring a live meeting for every review
  — meetings don't scale with the number of proposals, and a well-written proposal with async
  feedback is often faster end-to-end and leaves a better record than a synchronous discussion that
  has to be separately minuted.
