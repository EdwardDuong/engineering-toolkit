---
description: Produce a feature plan — requirements, assumptions, architecture impact, implementation steps, and risks — before any code is written.
argument-hint: [feature description, ticket reference, or requirement]
---

Produce a written plan for the following feature before writing any code. A
plan that skips a section below isn't a plan, it's a guess with extra steps —
every section exists because omitting it is how a straightforward-looking
feature turns into a mid-implementation surprise.

**Feature**: $ARGUMENTS

## Process

1. **Check readiness first.** Walk [`docs/definition-of-ready.md`](../../docs/definition-of-ready.md)
   against this feature. If acceptance criteria are missing, scope is
   ambiguous in a way that matters, or a dependency is unresolved, say so and
   either resolve the gap with the user or produce a plan that explicitly
   flags the open question rather than silently guessing at an answer.

2. **Requirements.** Restate the feature as concrete, verifiable acceptance
   criteria (Given/When/Then or bullet form). Separate what's explicitly in
   scope from what's explicitly out of scope — an unstated scope boundary is
   the single most common source of rework.

3. **Assumptions.** List every assumption being made to fill a gap in the
   request, flagged clearly as an assumption rather than a confirmed
   requirement. If an assumption is significant enough that being wrong
   about it would change the design, surface it as an open question instead
   of assuming silently.

4. **Architecture impact.** Determine whether this feature:
   - Fits entirely within existing boundaries and patterns (most features), or
   - Introduces or changes a system boundary, a significant new dependency,
     or a one-way-door decision per
     [`../../docs/architecture-review.md`](../../docs/architecture-review.md).
   For the latter, apply the judgment in
   [`../agents/architect.md`](../agents/architect.md) and note whether an
   ADR (see [`../../docs/adr-guide.md`](../../docs/adr-guide.md)) or RFC
   (see [`../../docs/rfc-process.md`](../../docs/rfc-process.md)) is
   warranted before implementation starts. If the feature touches a specific
   domain — data model, UI state, deployment topology — apply the relevant
   specialist lens from `../agents/` (`database-engineer.md`,
   `frontend-engineer.md`, `devops-engineer.md`) and note what that lens
   flags.

5. **Implementation steps.** Break the work into an ordered sequence of
   small, independently verifiable steps (data/interface changes first, then
   core logic, then integration points, then edge cases and error handling —
   see [`../commands/implement.md`](../commands/implement.md) for how this
   sequencing gets executed). Each step should be small enough that if it
   turned out wrong, the cost of discovering that is contained to just that
   step.

6. **Risks.** For each risk, state what could go wrong, how likely it is,
   and what the impact would be if it happened — not just a bare list of
   worries. Use the likelihood x impact framing in
   [`../../docs/risk-assessment.md`](../../docs/risk-assessment.md). Call out
   specifically:
   - What's uncertain enough that the plan might need to change once
     implementation starts.
   - What could make this harder to roll back than expected.
   - What's outside this feature's control (a dependency on another team, an
     external API's behavior) that the plan is currently trusting.

## Output shape

Present the plan in this order — Requirements, Assumptions, Architecture
Impact, Implementation Steps, Risks — as a single reviewable document. Stop
and present this plan for confirmation before moving to
[`/implement`](implement.md); do not begin writing code from a plan that
hasn't been reviewed, especially if step 4 identified a one-way-door
decision.
