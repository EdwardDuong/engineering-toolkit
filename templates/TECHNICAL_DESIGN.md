<!--
Template: Technical Design Document
Use this when: implementing an approved feature or change whose design has real choices to make —
data flow, component boundaries, new interfaces — but that doesn't rise to the level of a full RFC
(rfc.md, for decisions needing broad multi-team input before they're made) or a single ADR (ADR.md,
for one specific, narrow decision). A technical design covers the full solution shape for one
change; an ADR usually documents one decision inside a design like this one.
Related: ../docs/architecture-principles.md, ../docs/workflows/feature-development.md ("Technical
Design" step), ../.claude/agents/architect.md, ../.claude/rules/architecture-first.md.
-->

# Technical Design: [Change name]

**Status:** [Draft | In review | Approved | Implemented]
**Author:** [Name]
**Reviewers:** [Names — should include at least one reviewer not already bought into the approach]
**Related spec/ADR:** [link to FEATURE_SPEC.md or ADR.md this design implements, if any]

## Context

<!-- The system as it exists today, to the extent it's relevant to this design. What components are
     involved, what they currently do, and what constraint or requirement makes a design decision
     necessary here. -->

[Describe the relevant current-state architecture — existing components, data flow, and any
constraint (performance, compatibility, team ownership boundary) that shapes what's possible. A
reader unfamiliar with this part of the system should finish this section oriented enough to
follow the Decision section.]

## Problem

<!-- The specific technical problem this design solves — precise enough that the Decision section
     below can be checked against it. -->

[What, technically, needs to happen that the current system can't do, or can't do safely/correctly
/at the required scale? Distinguish this from the *business* problem in a linked FEATURE_SPEC.md —
this is the engineering problem that spec's acceptance criteria imply.]

## Decision

<!-- The actual design: components touched or added, data flow, new interfaces/contracts, and the
     sequence of implementation. This is the section a second engineer should be able to implement
     from without re-deriving the approach. -->

**Approach:** [one-paragraph summary of the chosen design]

**Components:**
- [Component/service touched] — [what changes about it]
- [New component, if any] — [its responsibility, and why it's a new component rather than added to
  an existing one — see ../docs/architecture-principles.md on boundary placement]

**Data flow:** [describe the request/data path through the system — a sequence description or
diagram; ASCII is fine if it's clearer than prose]

**Interfaces/contracts:** [any new or changed API, event schema, or function signature that other
components depend on — link to ../templates/API_DESIGN.md if this design includes a public API
change significant enough to warrant its own document]

**Data model changes:** [any schema change this design requires — link to
../templates/DATABASE_CHANGE.md for the migration plan if so]

**Implementation sequence:** [the order pieces will be built and deployed — data/interface changes
first, then core logic, then integration, per ../docs/workflows/feature-development.md]

## Alternatives

<!-- Other designs seriously considered, and the specific technical reason each was rejected. -->

### [Alternative design 1]

[What it was and its specific tradeoff — e.g., "would avoid the new service but requires the
existing monolith to take a synchronous dependency on a third-party API with no SLA, which the team
already agreed to stop doing per ADR-0012."]

### [Alternative design 2]

[Same structure. Include the option of a smaller, incremental version of the chosen design if one
exists — sometimes the honest alternative to "the full design" is "half of it, now, with the rest
deferred," and that tradeoff deserves stating.]

## Risks

<!-- Technical risk this design introduces, distinct from the delivery/adoption risk that belongs
     in a FEATURE_SPEC.md. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Performance risk — e.g., new synchronous call adds latency to a hot path] | [L/M/H] | [L/M/H] | [...] |
| [Migration/rollout risk — e.g., requires coordinated deploy of two services] | [L/M/H] | [L/M/H] | [...] |
| [Operational risk — e.g., new failure mode not covered by existing alerts] | [L/M/H] | [L/M/H] | [...] |

## Validation

<!-- How this design will be verified correct before and after it ships. -->

- **Test strategy:** [what's covered at unit/integration/end-to-end level per
  ../docs/testing-strategy.md, and anything this design specifically needs — a load test, a
  migration dry-run against production-scale data]
- **Rollout plan:** [direct deploy, feature flag, canary, or staged rollout — per
  ../.claude/agents/devops-engineer.md — matched to this design's actual risk level]
- **Rollback plan:** [how this gets undone if it's wrong in production, and any asymmetry — e.g.,
  a schema change that isn't cleanly reversible, see ../docs/workflows/database-change.md]
- **Done means:** [the specific, observable condition that confirms this design is working as
  intended in production, not just that it deployed]

## Ownership

- **Design owner:** [name — accountable for the design holding up during implementation]
- **Implementers:** [names/team actually building this]
- **Approvers:** [who needs to sign off before implementation starts — see
  ../docs/architecture-review.md for when this rises to formal architecture review]
