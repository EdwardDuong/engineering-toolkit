# RFC Process

A Request for Comments (RFC) is a written proposal for a significant decision, circulated for
structured feedback *before* the decision is finalized and implementation begins in earnest. Its
purpose is to surface disagreement and missing context while the decision is still cheap to change,
instead of after the code is written and changing course means throwing work away.

## When to write an RFC

Write an RFC when a decision is significant enough that getting broad, informed input before
committing is worth the overhead of writing one. Typical triggers:

- The decision meets the [`architecture-review.md`](./architecture-review.md) criteria — a new
  system boundary, a significant new dependency, a one-way door decision.
- The decision affects multiple teams, and their buy-in or awareness materially affects whether it
  will succeed.
- There is genuine, substantive uncertainty about the right approach, and the author expects (or
  wants) real debate, not rubber-stamp approval.
- A previous similar decision was made without enough input and caused friction or rework — a signal
  the next one in that area should go through a more structured process.

Don't write an RFC for decisions that are two-way doors (see
[`decision-making.md`](./decision-making.md)) or that don't genuinely need broader input — an RFC
written for a decision nobody disputes and nobody outside the immediate team needs to know about is
ceremony, and repeated ceremony trains people to skim RFCs rather than engage with them.

## RFC lifecycle

1. **Draft** — the author writes the proposal using [`../templates/rfc.md`](../templates/rfc.md):
   the problem being solved, the proposed approach, alternatives considered and why they were
   rejected, and the tradeoffs of the chosen approach stated honestly (an RFC that only presents
   upside is not trustworthy — every real design has tradeoffs, and naming them builds credibility
   rather than undermining it).
2. **Review** — the RFC is circulated to the relevant stakeholders (the team(s) affected, anyone
   with relevant architectural authority — see [`architecture-review.md`](./architecture-review.md))
   with an explicit comment period. Feedback is given the same way as code review: specific,
   actionable, and severity-marked as blocking or non-blocking (see
   [`code-review-guide.md`](./code-review-guide.md)) — a vague "not sure about this" comment on an
   RFC is as unhelpful as it is on a PR diff.
3. **Accepted / Rejected / Needs revision** — the RFC's owner (or the designated decision-maker per
   [`decision-making.md`](./decision-making.md) if consensus isn't reached) makes an explicit call.
   "Accepted" means the proposal, as written or as amended during review, is the plan going forward.
   "Rejected" means it isn't, with the reasoning recorded so the same idea isn't re-proposed without
   new information later. "Needs revision" means specific, named concerns must be addressed before a
   decision is made, not an indefinite limbo.
4. **Implemented** — once accepted, implementation proceeds, and the RFC is marked as implemented
   (optionally linking to the resulting code, or to an ADR — see [`adr-guide.md`](./adr-guide.md) —
   that captures the final decision more concisely for long-term reference, since an RFC document
   tends to be discursive while an ADR is meant to be a durable, scannable record).

An RFC that sits in "draft" or "review" indefinitely without a decision is worse than not writing
one — it signals the process doesn't actually produce outcomes, which discourages the next person
from investing the effort to write one. Every RFC should have an accountable owner who's responsible
for driving it to a decision within a reasonable timeframe, escalating per
[`decision-making.md`](./decision-making.md) if consensus doesn't form on its own.

## What makes an RFC effective

- **State the problem before the solution.** A reviewer who doesn't understand what problem is being
  solved can't meaningfully evaluate whether the proposed solution is a good one — this is the
  single most common gap in weak RFCs.
- **Present real alternatives, not straw men.** An RFC that presents one option and two
  obviously-inferior alternatives isn't inviting genuine debate, it's performing the appearance of
  consideration. If there was only really one reasonable approach, say so and explain why, rather
  than padding the document with alternatives nobody seriously considered.
- **Be honest about tradeoffs and open questions.** An RFC's credibility comes from acknowledging
  what it doesn't solve or what it costs, not from presenting the proposal as strictly beneficial
  with no downside.
- **Keep it as short as the decision allows.** A long RFC for a decision that could be stated in two
  pages doesn't demonstrate rigor — it makes the document harder to review carefully, which
  paradoxically produces worse feedback, not more.

## Relationship to ADRs

An RFC and an ADR serve different moments in the same decision's life: the RFC is the proposal and
debate that happens *before* a decision, capturing the alternatives considered and the discussion
that shaped the outcome. The ADR is the durable record of the decision *after* it's made, optimized
for a future reader who wants to know what was decided and why, not the full back-and-forth that got
there. Not every decision needs both — small architectural decisions often go straight to an ADR
without a separate RFC; significant ones benefit from an RFC first and a concise ADR afterward. See
[`adr-guide.md`](./adr-guide.md).
