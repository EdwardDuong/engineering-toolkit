# Technical Debt

Technical debt is any gap between how a system currently works and how it would work if it were
built with the knowledge and time available today. Like financial debt, some of it is a reasonable
tool used deliberately, and some of it is a liability taken on carelessly — the difference matters
more than the existence of debt itself.

## Classifying debt

Debt varies along two independent dimensions: whether it was taken on deliberately, and whether it
was taken on for a sound reason.

- **Deliberate and prudent** — a conscious tradeoff made with good reason, usually to hit a real
  deadline or validate an assumption before investing further: "we're hardcoding this integration
  because we need to ship the demo Friday and don't yet know if this partnership will continue;
  we'll build it properly once it's confirmed." This is debt taken on with eyes open, for a reason
  that holds up under scrutiny.
- **Deliberate and reckless** — a conscious shortcut taken without a good enough reason to justify
  the risk: "we don't have time to write tests for this" on a payment-critical path, with no plan to
  add them later and no real time constraint that couldn't have accommodated it. This is
  corner-cutting rationalized as a tradeoff after the fact.
- **Inadvertent and prudent** — debt discovered only in hindsight, where the original decision was
  reasonable given what was known at the time: "we didn't know this data volume would grow 50x when
  we chose this data model." Nobody could have reasonably designed around information that didn't
  exist yet — this is a normal, expected byproduct of building real systems, not a failure.
- **Inadvertent and reckless** — debt from not knowing something the team should have known:
  building without applying established, well-known principles (see
  [`architecture-principles.md`](./architecture-principles.md),
  [`solid-principles.md`](./solid-principles.md)) that were available and applicable at the time,
  not because of a deliberate tradeoff but because of a skill or process gap.

This framework matters because the response differs by quadrant: deliberate-prudent debt needs a
plan to pay it down once its purpose is served; deliberate-reckless debt needs a conversation about
why corners were cut without justification; inadvertent-prudent debt needs no blame, just
prioritized remediation; inadvertent-reckless debt is a signal for training, review process, or
checklist gaps (see [`code-review-guide.md`](./code-review-guide.md)) rather than an individual
failing.

## Tracking debt

- **Record debt explicitly, at the moment it's incurred, not discovered later by someone confused
  about why the code looks the way it does.** A comment referencing a tracked issue, or an entry in
  a dedicated technical debt backlog, both work — what matters is that the debt is visible and
  searchable, not buried in someone's memory of a rushed decision six months ago.
- **Capture the reason it was taken on, not just that it exists.** "We hardcoded this because of the
  Friday deadline, and we should generalize it once the partnership is confirmed" is far more useful
  to a future reader than "TODO: fix this," which conveys urgency with zero context for deciding
  whether it's actually still relevant.
- **Track debt with the same rigor as any other backlog item** — visible, prioritized, not a
  separate informal list that only the person who wrote it remembers to check.

## Paying down debt without a dedicated framework mandate

Most teams don't need — and shouldn't adopt — a heavyweight, formally scheduled "debt sprint"
cadence as a blanket policy. Debt paydown works better woven into normal work:

- **Pay down debt opportunistically when touching the affected code anyway.** If a ticket requires
  modifying a module that's carrying known debt, and the paydown is small relative to the ticket, do
  it as part of the same change rather than filing a separate, likely-never-prioritized follow-up.
- **Escalate debt that's actively slowing the team down or creating recurring risk to a first-class
  prioritized item**, competing for the same prioritization attention as feature work, rather than
  something perpetually below the cut line. If a piece of debt has caused two incidents, that's
  evidence it belongs above ordinary feature work, not below it.
- **Make the cost of debt visible to whoever prioritizes work.** "This module has no tests, which is
  why the last three changes to it each took twice as long as expected and one caused a regression"
  is a much stronger prioritization argument than an abstract "we should really clean this up
  sometime."
- **Avoid the two failure modes at either extreme**: never paying down debt (it compounds — new work
  built on top of debt-laden code inherits the debt and adds its own, and velocity degrades
  gradually until it's a crisis) and paying down debt reflexively regardless of actual impact (a
  mandated debt-only sprint often ends up polishing code nobody was struggling with while genuinely
  painful debt elsewhere goes untouched, because "debt sprint" work gets picked by convenience
  rather than impact).

## Debt and this toolkit's other principles

Debt frequently originates from the failure modes covered elsewhere in this folder: duplicated logic
deduplicated across the wrong boundary (see [`dry-principle.md`](./dry-principle.md)), a design that
skipped necessary upfront thinking under time pressure (see
[`architecture-principles.md`](./architecture-principles.md)), or missing test coverage from a
rushed release (see [`testing-strategy.md`](./testing-strategy.md)). Recognizing which principle was
compromised when debt was incurred helps target the actual fix, not just a superficial cleanup that
leaves the underlying cause free to reproduce the same debt again.
