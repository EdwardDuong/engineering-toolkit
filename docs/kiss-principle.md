# KISS — Keep It Simple

Simplicity is not the absence of features. It's the absence of unnecessary moving parts relative to
the problem actually being solved. KISS is a design discipline, not an excuse to under-engineer.

## What "simple" actually means

- **Simple** means the solution has no more concepts, layers, or degrees of freedom than the problem
  requires. A single well-named function is simpler than a configurable strategy pattern if there's
  only ever one strategy.
- **Simplistic** means the solution has fewer concepts than the problem actually requires, and the
  missing complexity resurfaces later as bugs, workarounds, or an outright rewrite. Skipping input
  validation because "the happy path is simpler" is simplistic, not simple — the complexity of
  handling bad input didn't disappear, it just moved to production.
- The goal is the simplest solution that still fully addresses the problem, including its edge cases
  — not the solution with the fewest lines of code today.

## Recognizing complexity creep

Complexity rarely arrives in one big jump. It accretes one "just this one exception" at a time, and
each individual addition looks reasonable in isolation.

Signals that complexity has crept past what the problem needs:

- **Configuration surface grows faster than actual use cases.** If a component has ten config flags
  and only two combinations are ever used in practice, the other eight are complexity with no
  offsetting benefit.
- **New engineers need a walkthrough before they can make a small change safely.** If understanding
  a component's basic behavior requires tribal knowledge, the design has outpaced what a fresh
  reader can reconstruct from the code.
- **The number of special cases in conditionals grows over time without the underlying problem
  changing.** Each `else if` for "just this one customer" or "just this one region" is a sign the
  abstraction no longer matches the domain, and patching it further will only compound the mismatch.
- **You need a diagram to explain a call path that used to be obvious.** That's not a documentation
  problem — it's evidence the flow itself has gotten too indirect.
- **Nobody can confidently say what happens if a step is removed.** In a simple system, removing a
  step has an obvious, local effect. In a complex one, it's unclear until you try it, which is a
  sign of hidden coupling (see [`architecture-principles.md`](./architecture-principles.md)).

## Keeping designs simple in practice

- Solve the problem in front of you, not the problem you imagine having in two years. Speculative
  complexity to handle a hypothetical future case is the same failure mode covered in more depth in
  [`yagni-principle.md`](./yagni-principle.md).
- Prefer straightforward, boring solutions over clever ones. A clever one-liner that saves five
  lines but requires the reader to reconstruct your reasoning is a net loss in a codebase more
  people will read than write.
- When a design has multiple ways to solve the same problem, prefer the one with fewer states to
  reason about, not the one with the fewest characters typed.
- Introduce a new layer of indirection only when it removes more complexity than it adds. Every
  layer has a fixed cost (another thing to trace through, another place a bug can hide) that must be
  paid for by a real benefit, not a theoretical one.
- Refactor toward simplicity continuously, not as a separate cleanup project. Complexity is cheapest
  to remove the moment after it was added, before other code has grown to depend on it.

## Simplicity vs. simplistic: a worked contrast

Consider handling a payment that might fail due to a network timeout.

- **Simplistic**: call the payment API once, assume success, move on. Fewer lines, but the system
  silently loses money on the timeouts it didn't handle. The complexity of failure handling wasn't
  eliminated — it was deferred to an on-call engineer at 2 a.m.
- **Over-engineered**: build a generic, pluggable retry framework with five configurable backoff
  strategies, circuit breaker thresholds exposed as runtime-tunable parameters, and a strategy
  registry — for a single payment call. Most of that flexibility will never be exercised and now has
  to be understood by everyone who touches this code.
- **Simple**: call the payment API with one sensible retry-with-backoff policy (see
  [`error-handling.md`](./error-handling.md)), log the outcome, and surface a clear failure to the
  caller if retries are exhausted. This fully addresses the actual problem (transient network
  failures) with the minimum machinery needed to do so.

## When simplicity trades off against other goals

- Simplicity can trade off against performance: the simplest correct implementation is not always
  the fastest one. Don't sacrifice simplicity for performance until profiling shows the simple
  version is actually the bottleneck — see [`performance-guide.md`](./performance-guide.md).
- Simplicity can trade off against flexibility: a system built for one use case is simpler than one
  built for ten, but breaks if an eleventh, genuinely necessary use case arrives. This is a judgment
  call, not a rule — see the "designing for change vs. over-designing" section of
  [`architecture-principles.md`](./architecture-principles.md).
- When in doubt, default to simple and add complexity when a real, observed requirement demands it.
  It is almost always cheaper to add a missing capability to a simple system than to remove an
  unnecessary one from a complex system.
