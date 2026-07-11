<!--
Template: Architecture Decision Record (ADR)
Use this when: making a significant, hard-to-reverse architectural or technical decision — a new
system boundary, a significant dependency, a data model change, or anything where a future engineer
would reasonably ask "why did we do it this way?"
Guidance on writing good ADRs: ../docs/adr-guide.md
A worked example: ../examples/good-adr.md
Number ADRs sequentially (ADR-0001, ADR-0002, ...) and never delete or edit an Accepted one —
supersede it with a new ADR instead. See ../docs/adr-guide.md for why.
-->

# ADR-[NNNN]: [Short, specific statement of the decision, not the problem — "Use event sourcing for order processing," not "How should we handle order processing?"]

**Status:** [Proposed | Accepted | Rejected | Superseded by ADR-NNNN | Deprecated]
**Date:** [YYYY-MM-DD]
**Owner:** [Name — the person accountable for this decision]
**Approvers:** [Names or team — who signed off, required for Accepted status]

## Context

<!-- The situation forcing this decision. Constraints (technical, business, organizational,
     timeline) and assumptions. Write for a reader with zero memory of the discussion that led here.
     State facts, not the outcome you're about to argue for. -->

[What's true right now that makes this decision necessary? What existing system, constraint, or
requirement is driving it? Include numbers where they matter — current scale, growth rate, SLA
commitments, deadline.]

## Problem

<!-- The specific question this ADR answers, stated precisely enough that a reader could evaluate
     whether the Decision below actually answers it. -->

[State the problem as a question this ADR resolves, e.g., "How should the checkout service notify
the fulfillment service when an order is placed, given that fulfillment's API has no delivery
guarantee and checkout cannot block on it?" A vague problem statement produces a decision nobody
can evaluate.]

## Decision

<!-- What was actually decided, stated plainly. "We will..." Not a menu of options — the choice
     that was made. Implementation detail belongs here only if it's load-bearing for understanding
     the decision, not as a full design spec (that belongs in a linked TECHNICAL_DESIGN.md). -->

We will [state the decision in one clear sentence].

[Add the supporting detail a reader needs to understand what this means in practice — the shape of
the solution, not the full implementation.]

## Alternatives

<!-- Every alternative seriously evaluated, and the specific reason it was rejected. This is what
     saves a future reader from re-litigating an option that was already considered and ruled out —
     omitting an alternative someone will obviously suggest later is the most common ADR mistake. -->

### [Alternative 1 — name it by its approach, not "Option A"]

[What it was, and the specific, concrete reason it was rejected — not "didn't fit," but the actual
tradeoff: "would have required a synchronous call from checkout to fulfillment, adding fulfillment's
availability as a hard dependency of the checkout critical path."]

### [Alternative 2]

[Same structure. If there was genuinely only one reasonable approach, say so explicitly and explain
why — don't pad this section with strawman alternatives nobody considered seriously.]

### Do nothing / keep current state

[Almost always worth stating explicitly why the status quo isn't acceptable — this is the
alternative every decision implicitly competes against.]

## Risks

<!-- What this decision costs, not just what it buys. An ADR that only lists benefits is not a
     complete or trustworthy record — every real decision has a tradeoff. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Specific way this could go wrong] | [Low/Medium/High] | [Low/Medium/High] | [What reduces it, or "accepted" if none] |

[Include operational risk (harder to debug, new failure mode), organizational risk (new
dependency on another team), and reversal risk (what it costs to undo this later if it's wrong).]

## Validation

<!-- How you'll know this decision was right — or wrong — after the fact. A decision without a
     way to check its outcome can never be learned from. -->

- **Success looks like:** [a concrete, checkable signal — a metric, an absence of a specific
  failure mode, a measured latency/throughput target]
- **We'll revisit this decision if:** [the specific condition that would trigger re-evaluation —
  e.g., "fulfillment's queue depth regularly exceeds X" or "this pattern is proposed for a third
  use case with materially different requirements"]
- **Review checkpoint:** [when, if ever, this ADR gets revisited on a schedule rather than only
  when triggered by a problem]

## Ownership

<!-- Who is accountable for this decision now, and who to ask if a future reader has questions
     this document doesn't answer. -->

- **Decision owner:** [name — accountable for the decision holding up over time]
- **Implementation owner:** [name or team, if different from the decision owner]
- **Consulted:** [names/teams whose input shaped this decision]

## References

<!-- Links to related ADRs, the RFC that preceded this if one existed, issues, or external docs. -->

- [Related document, RFC, or discussion]
