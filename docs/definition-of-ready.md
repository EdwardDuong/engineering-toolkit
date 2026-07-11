# Definition of Ready

A work item is "ready" when an engineer can start it without needing to stop partway through to go
ask clarifying questions that should have been answered before it entered a sprint or work queue.
Definition of Ready is the counterpart to [`definition-of-done.md`](./definition-of-done.md) — done
defines the finish line, ready defines the start line, and a team that only defines one of the two
ends up with either half-finished work or work that stalls immediately after being picked up.

## Why this matters

Work that starts before it's ready doesn't actually save time — it moves the clarification cost from
planning (cheap, async, low-stakes) to implementation (expensive, blocking, often discovered mid-PR
when it's more disruptive to unwind). A ticket that says "improve checkout performance" with no
further detail will produce a different outcome depending on which engineer picks it up and what
they guess "improve" means, which is a planning failure, not an execution one.

## Criteria before work starts

A work item should satisfy all of the following before it's pulled into active development:

- **Clear acceptance criteria.** What observable outcome proves this is done? "Users can filter
  orders by date range, inclusive of both endpoints, defaulting to the last 30 days" is testable.
  "Add filtering to orders" is not.
- **Scoped and sized.** The work has been broken down enough that one engineer (or one small pair)
  can estimate it with reasonable confidence. If nobody can size it, it's not a ticket yet — it's a
  research spike, and should be labeled as one with its own, narrower goal ("determine feasibility
  of X," not "build X").
- **Dependencies identified.** Any other team, system, data migration, or external API this work
  depends on is named, and — if it isn't ready itself — that's flagged before the work starts, not
  discovered mid-implementation.
- **Design or approach agreed for anything non-trivial.** A work item that requires an architectural
  decision (new service boundary, new external dependency, data model change) should point to the
  relevant ADR or RFC (see [`adr-guide.md`](./adr-guide.md), [`rfc-process.md`](./rfc-process.md))
  rather than leaving the approach to be improvised during implementation.
- **Testability is understood.** It's clear, before coding starts, roughly how this will be verified
  — unit tests, an integration test, a manual QA pass, a canary rollout. If nobody can articulate
  how you'd know this works, the requirement probably isn't concrete enough yet either.
- **No open questions blocking a start.** Any question that would stop the engineer partway through
  has been asked and answered already. It's fine for details to be discovered during implementation
  — it's not fine for the core requirement to be ambiguous.

## What "ready" does not require

- It does not require a fully detailed technical design for small or well-understood work — that
  would just move waste from "ready" to "planning." Match the rigor of readiness criteria to the
  size and risk of the work; see [`risk-assessment.md`](./risk-assessment.md) for how to judge that.
- It does not require the work item to be perfectly estimated to the hour — sizing confidence, not
  precision, is the bar.
- It does not require zero ambiguity about implementation detail. The *what* and *why* must be
  clear; the *exact how* can be left to the engineer doing the work, within the boundaries set by
  [`architecture-principles.md`](./architecture-principles.md).

## Who enforces this

Readiness is a shared responsibility between whoever writes the ticket and whoever pulls it into
active work:

- The person creating the work item should self-check against this list before handing it off.
- The engineer picking up the work has both the right and the responsibility to push a work item
  back if it fails these criteria, before starting — not halfway through, when the cost of the gap
  has already been paid.
- In a planning or refinement session, use this list explicitly as the exit criteria for a ticket
  being considered "plannable" for an upcoming cycle.

## Templates that support readiness

- [`../templates/user-story.md`](../templates/user-story.md) and
  [`../templates/task.md`](../templates/task.md) have sections structured around these criteria
  (acceptance criteria, dependencies, sizing) so filling out the template largely produces a ready
  ticket.
- [`../templates/epic.md`](../templates/epic.md) for work large enough to need its own breakdown
  into several ready child tickets before any of them starts.

## Relationship to Definition of Done

Ready and Done are two ends of the same lifecycle, and they should be consistent with each other: if
Done requires a specific kind of test coverage, Ready should require that the testability of the
work is understood up front, not discovered as a surprise requirement at merge time. Review both
docs together when either one changes.
