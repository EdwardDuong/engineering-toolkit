# Architecture Decision Records (ADRs)

An Architecture Decision Record captures a single significant decision, the context that led to it,
and its consequences — written once the decision is made, as a durable record for every future
engineer who asks "why is this built this way?" instead of that answer living only in the memory of
whoever made the call.

## When to write one

Write an ADR for any decision that meets the [`architecture-review.md`](./architecture-review.md)
triggers — a new system boundary, a significant new dependency, a decision that's expensive to
reverse — or any decision where you can specifically imagine a future engineer being confused by the
current state and needing the reasoning to make sense of it.

Do not write an ADR for:

- Reversible, low-impact decisions (see the two-way door framing in
  [`decision-making.md`](./decision-making.md)) — the overhead outweighs the benefit, and a codebase
  with hundreds of ADRs for trivial decisions makes it harder to find the ones that actually matter.
- Implementation detail that's fully visible and self-explanatory by reading the code — an ADR is
  for decisions, not for narrating what the code already says clearly.

A useful calibration question: if this decision were reversed six months from now without anyone
reading a record of why it was made this way, would that be a costly mistake? If yes, write the ADR.

## Structure

Use [`../templates/adr.md`](../templates/adr.md), which follows the standard structure:

- **Title** — a short, specific statement of the decision, not the problem: "Use event sourcing for
  the order-processing subsystem," not "How should we handle order processing?"
- **Status** — Proposed, Accepted, Superseded, or Deprecated (see below). Always current, always
  visible without opening the full document.
- **Context** — what situation led to needing this decision: the forces at play, the constraints,
  the requirements that shaped what "good" looks like here. Written so a reader with no memory of
  the discussion understands why this was even a question.
- **Decision** — what was actually decided, stated plainly and unambiguously. Not a menu of options
  — the ADR records the choice that was made, not the deliberation (that belongs in an RFC, if one
  preceded this — see [`rfc-process.md`](./rfc-process.md)).
- **Consequences** — the results of the decision, both intended and any known tradeoffs accepted
  knowingly. An ADR that only lists benefits isn't a complete record — every real architectural
  decision costs something, and naming the cost is what makes the record trustworthy and useful for
  a future re-evaluation.

## Immutability of accepted ADRs: supersede, don't edit

Once an ADR's status is Accepted, its content — the context and decision as originally written —
should not be edited to reflect new information. This is the single most important discipline in
this doc, and the one most commonly violated by teams new to ADRs.

**Why**: an ADR is a historical record of what was decided and why, *at the time it was decided*. If
circumstances change and the decision needs to be revisited, editing the original ADR destroys the
historical context — a future reader trying to understand "why did we originally choose this" will
find a document that's been silently rewritten to match current thinking, with no trace of what was
actually true when the original decision was made. This is actively misleading, not just imprecise.

**Instead**: when a decision needs to change, write a **new** ADR that explicitly supersedes the old
one:

- The new ADR's context explains what changed since the original decision (new requirements, new
  information, the original assumptions turning out to be wrong).
- The new ADR's status is Accepted; the old ADR's status is updated to **Superseded by [new ADR
  reference]** — this is the one allowed edit to an accepted ADR: updating its status and adding a
  pointer, never rewriting its context or decision content.
- This produces a chain a future engineer can follow: why was X originally decided, why did that
  change, what's the current state — each step preserved rather than overwritten.

A **Deprecated** status (as opposed to Superseded) is appropriate when a decision is no longer
relevant — the component it applied to was removed, for instance — without a specific replacement
decision superseding it.

## Where ADRs live

Keep ADRs in the repository they describe, versioned alongside the code — see
[`documentation-standards.md`](./documentation-standards.md) on doc-as-code principles generally. A
numbered, chronological sequence (e.g., `0001-use-event-sourcing-for-orders.md`) makes the history
of decisions easy to browse in order and makes cross-referencing between ADRs (superseding, related
decisions) straightforward with a stable identifier.

## Writing a good one

See [`../examples/good-adr.md`](../examples/good-adr.md) for a fully worked example. The traits that
distinguish a good ADR from a weak one: it's specific rather than vague about what was decided, it
states real tradeoffs rather than only benefits, and it's short enough that a future reader will
actually read the whole thing rather than skimming past the part that would have answered their
question.
