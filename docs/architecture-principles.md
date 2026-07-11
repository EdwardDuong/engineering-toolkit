# Architecture Principles

Architecture is the set of decisions that are expensive to reverse. Everything else is
implementation detail that a good refactor can fix in an afternoon. This doc covers the principles
that keep those expensive decisions sound.

## Separation of concerns

Every module, service, or layer should have one reason to change. When a component handles
validation, persistence, and business rules together, a change to any one of those forces you to
re-verify all three.

- Draw boundaries around **what changes together**, not around technical layers for their own sake.
  A "utils" layer that nothing else can be inferred about is not separation of concerns — it's a
  junk drawer.
- A boundary is only real if it's enforced. If any module can reach across a "separated" concern and
  call into another's internals, the separation is documentation, not architecture.
- Prefer separating by business capability over separating by technical role (e.g., "billing" over
  "database access layer") once a system has more than a handful of components. Technical-role
  layering tends to spread a single feature change across every layer.

## Explicit boundaries and contracts

A boundary without a contract is just a suggestion.

- Define what crosses a boundary explicitly: function signatures, message schemas, API contracts.
  Implicit contracts ("everyone knows this field is never null") break the first time someone who
  doesn't know joins the team.
- Contracts should describe behavior, not implementation. A queue consumer's contract is "processes
  messages of shape X, is safe to retry, does not require ordering" — not "reads from this specific
  queue implementation."
- Version contracts deliberately. See [`api-design-guide.md`](./api-design-guide.md) for how to
  evolve an interface without breaking its consumers.
- Validate at the boundary, trust internally. Re-validating the same invariant five layers deep in
  the call stack is a sign the boundary isn't trusted, which usually means it isn't well-defined.

## Favor composition over deep hierarchies

Composition — building behavior by combining small, independent pieces — degrades better than
inheritance-style hierarchies or deeply nested control flow.

- A hierarchy commits you to a taxonomy up front. Real systems' categorizations shift; composition
  lets you recombine pieces instead of restructuring a tree.
- Prefer dependency injection (passing in what a component needs) over a component reaching out and
  constructing or locating its own dependencies. It makes the component's real requirements visible
  and testable.
- This applies beyond object-oriented code: a pipeline of small, composable functions or a set of
  independently deployable services follows the same logic as composed objects. The principle is
  about how behavior is assembled, not about a specific language feature.

## Designing for change vs. over-designing

The hardest architectural judgment call is knowing how much flexibility to build in before you need
it.

- Design for the change that is likely, not the change that is merely conceivable. "We might add a
  second database vendor" is not a reason to build a database abstraction layer if there has never
  been a second vendor in this organization's history.
- The cost of under-designing is a refactor. The cost of over-designing is a permanent tax: every
  future engineer pays the cost of understanding the abstraction, whether or not it was ever
  exercised. Under-designing is usually the cheaper mistake to have made.
- A good signal that abstraction is warranted: you already have two or three concrete cases that
  need to vary, not zero. See [`yagni-principle.md`](./yagni-principle.md) for the failure mode of
  guessing ahead of evidence, and
  [`../.claude/rules/no-unnecessary-abstractions.md`](../.claude/rules/no-unnecessary-abstractions.md)
  for the machine-enforced version of this rule.
- Some upfront design is not the same as speculative generality. Deciding your service boundaries,
  your data ownership model, and your primary integration contracts before writing code is
  architecture. Building five configurable strategies for a rule that has one implementation is not
  — it's a guess dressed up as foresight.

## The cost of coupling

Coupling is not inherently bad — a system with zero coupling does nothing, because nothing calls
anything else. The goal is to make coupling deliberate and cheap to change, not to eliminate it.

- **Afferent coupling** (who depends on you) determines your blast radius when you make a breaking
  change. High afferent coupling means every interface change needs a migration plan, not just a
  code change.
- **Efferent coupling** (what you depend on) determines your fragility. High efferent coupling means
  your component breaks whenever any of its dependencies do.
- Temporal coupling — assuming operations happen in a specific order without enforcing it — is one
  of the most common silent architecture failures. If step B must follow step A, make that a
  type-level or contract-level guarantee, not a comment.
- Coupling through shared mutable state (a shared database table two services both write to, a
  shared in-memory cache) is the hardest kind to see and the hardest to remove later. Prefer owning
  data behind one component and exposing it through a contract.

## How architectural decisions get recorded

Principles are only useful if the decisions that apply them are written down somewhere a future
engineer can find. This toolkit uses two mechanisms:

- **[`adr-guide.md`](./adr-guide.md)** — Architecture Decision Records, for capturing a single
  decision, its context, and its consequences after the decision is made.
- **[`rfc-process.md`](./rfc-process.md)** — Request for Comments, for proposing and debating a
  decision before it's made, when the decision is significant enough to need broader input.

A decision that changes a system boundary, introduces a new external dependency, or is hard to
reverse should produce at least one of these two artifacts. See
[`architecture-review.md`](./architecture-review.md) for how to decide whether a change needs one.
