# Rule: No Unnecessary Abstractions

Don't introduce interfaces, factories, plugin systems, or configuration
layers for a single concrete need. Abstractions are supposed to reduce
cost; an abstraction built before it's needed usually increases it, because
it adds indirection without yet paying for itself.

## Recognizing premature abstraction

Signs an abstraction is premature rather than earned:

- There is exactly one implementation of an interface, and no concrete plan
  for a second.
- A factory or provider exists to construct one thing, one way.
- A config option exists to support a use case nobody has asked for yet
  ("just in case someone wants X").
- A generic/parameterized solution is built to solve a problem that today
  has one specific instance.
- You find yourself designing for "flexibility" without being able to name
  the second caller or the second use case that needs it.

None of this means abstractions are bad — it means they should be
introduced when a second concrete case actually demonstrates the shared
shape, not speculated in advance.

## The rule of three

A widely useful heuristic: don't extract a shared abstraction until you have
**three** real instances of the pattern.

- **First occurrence**: write it concretely, inline.
- **Second occurrence**: notice the duplication, but it's often still too
  early to know which parts are truly shared vs. coincidentally similar.
  Duplicate again if the shared shape isn't yet clear.
- **Third occurrence**: you now have enough evidence to see what actually
  varies and what doesn't. Extract the abstraction based on the real
  variation you've observed, not the variation you imagined.

This is a heuristic, not a hard law — if the second occurrence is obviously
and permanently identical in shape (e.g. the same CRUD pattern against a
known, fixed set of resources), extracting early is reasonable. The point is
to extract from evidence, not prediction.

## Practical guidance

- If you're about to write an interface with one implementation, write the
  concrete type instead. Add the interface when the second implementation
  actually arrives.
- If you're about to add a config flag for a hypothetical future need,
  don't. Add it when the need is real and specific.
- Prefer duplicating a small amount of logic over building a shared
  abstraction whose shape you're guessing at — duplication is easy to
  delete later; a wrong abstraction is expensive to unwind because callers
  accrete around it.
- When reviewing your own change, ask: "if I deleted this
  interface/factory/config layer and inlined the one real case, would
  anything be worse today?" If not, delete it.

See [docs/yagni-principle.md](../../docs/yagni-principle.md) for the broader
"you aren't gonna need it" principle this rule is grounded in, and
[docs/kiss-principle.md](../../docs/kiss-principle.md) for the complementary
case for simplicity over generality.
