# Decision-Making

Not every decision deserves the same process. The single biggest lever for making engineering
decisions efficiently is correctly sorting them by how expensive they are to reverse — and applying
heavyweight deliberation only to the ones that actually warrant it.

## Reversible vs. irreversible decisions

- **Two-way door (reversible) decisions** — if the decision turns out to be wrong, the cost of
  reversing it is low: you change it and move on with minor, contained cost. Choosing a variable
  name, picking an internal library function's signature on a component nothing else depends on yet,
  trying a new tool for one team's workflow.
- **One-way door (irreversible or expensive-to-reverse) decisions** — if the decision turns out to
  be wrong, undoing it is costly, slow, or impossible: a public API contract once external consumers
  depend on it, a data model that would require a large migration to change, a choice of core data
  store, deleting data, a security or compliance posture that other systems have been built
  assuming.

The practical implication: **two-way door decisions should be made quickly, by the person or small
group closest to the work, without requiring broad consensus.** Applying a heavyweight review
process to a reversible decision doesn't reduce risk meaningfully (the downside was already small) —
it just slows the team down and trains people to see process as friction rather than protection,
which erodes willingness to use it when it actually matters.

**One-way door decisions deserve genuinely more deliberation**: broader input, explicit
documentation of the reasoning (see [`adr-guide.md`](./adr-guide.md) and
[`rfc-process.md`](./rfc-process.md)), and often a higher bar for who can approve them (see below).
The extra time spent here is time well spent, because the cost of getting it wrong is
disproportionately higher than the cost of the extra deliberation.

Most decisions are two-way doors more often than they feel like at the time — a natural bias is to
overestimate irreversibility because undoing something feels effortful in the moment, even when it's
objectively cheap relative to the decision's actual stakes. Calibrate against a genuine question:
"if this turns out wrong in three months, what does fixing it actually cost?" — not "would it be
annoying to redo this."

## Who decides

- **Default to the person or team closest to the work and most directly accountable for its
  outcome.** They have the most context and bear the most direct consequence of the decision being
  wrong, which is usually the strongest available signal for good judgment.
- **Escalate ownership, not just visibility, for decisions that cross team boundaries** — a decision
  that affects another team's system or roadmap needs that team as a genuine participant in making
  it, not just informed after the fact. Informing people of a decision that affects them, without
  giving them a chance to shape it, produces resentment and rework when they push back later, which
  costs more time than involving them up front would have.
- **For one-way door decisions with organization-wide impact**, involve whoever holds architectural
  authority (see [`architecture-review.md`](./architecture-review.md)) — but keep the deciding group
  as small as the decision's actual scope requires. A decision that only affects one service's
  internals doesn't need every team's sign-off just because it's technically irreversible;
  irreversibility and blast radius are related but distinct — assess both.

## Escalation paths

- **Escalate when a decision is stuck**, not preemptively for every disagreement. Healthy debate
  that's converging doesn't need escalation; debate that's genuinely deadlocked, or where the people
  involved lack the authority or context to resolve it themselves, does.
- **A clear escalation path removes the ambiguity of "who breaks the tie."** Define, ahead of time,
  who has final say when a decision crosses team boundaries and consensus isn't reached in a
  reasonable timeframe (e.g., the relevant engineering lead or architecture group) — deciding this
  in the moment, under the pressure of an actual disagreement, tends to produce worse outcomes and
  more friction than having it settled in advance.
- **Time-box deliberation on two-way door decisions explicitly** — set a decision deadline up front,
  and if consensus hasn't formed by then, the accountable owner decides and the team moves forward.
  A two-way door decision that's still being debated after the time-box has expired has, in
  practice, become more expensive than just picking a reasonable option and adjusting later if
  needed.
- **For one-way door decisions, the escalation path should be known before deliberation starts**,
  not improvised once people disagree — see [`rfc-process.md`](./rfc-process.md) for how a proposal
  moves from draft through review to a decision with a clear owner.

## Recording decisions

Any decision above the two-way-door threshold should leave a trace a future engineer can find:

- **[`adr-guide.md`](./adr-guide.md)** for a specific architectural decision, once made.
- **[`rfc-process.md`](./rfc-process.md)** for proposing and debating a decision before it's made,
  when the decision is significant enough to need structured input from multiple people.

A decision with real consequences and no record forces every future "why is it built this way"
question to rely on institutional memory, which degrades the moment the people involved change teams
or leave — see [`documentation-standards.md`](./documentation-standards.md) on why architecture
decisions specifically must be documented.
