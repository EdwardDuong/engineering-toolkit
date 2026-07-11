# Unit Testing

"A unit test verifies a single unit of code in isolation" is the definition everyone learns and the
definition that causes the most disagreement in practice, because "unit" and "isolation" are both
doing more work than the sentence lets on. This document takes a position and explains the
reasoning, rather than repeating the ambiguous textbook line.

## What "unit" actually means

Two long-standing schools of thought disagree, and the disagreement has real consequences for how
you write tests, not just terminology:

- **The classicist (Detroit school) view**: a "unit" is a unit of *behavior*, which may span
  several collaborating objects or functions, as long as they're not crossing a genuine
  architectural boundary (a network call, a database, the filesystem, another service). A test in
  this school exercises a small cluster of real, in-process collaborators together and only fakes
  what's actually external or non-deterministic.
- **The mockist (London school) view**: a "unit" is a single class or function, and every one of
  its collaborators — even other in-process objects you wrote — is replaced with a mock, so the
  test verifies that unit's logic and its *interactions* with collaborators in complete isolation.

Neither is simply "correct." The classicist style produces tests that survive refactors better
(since it doesn't care how the cluster of collaborators is internally wired, only what it does) but
gives less precise failure localization when something breaks deep inside the cluster. The mockist
style gives precise, single-unit failure localization and is well suited to designing an interface
before its implementation exists, but produces tests that are more brittle to internal restructuring
and can devolve into asserting "mock A was called with these arguments" rather than verifying real
behavior — see "Where mocking goes wrong" below.

**This toolkit's default recommendation**: lean classicist. Fake or stub true external
dependencies (network, filesystem, database, wall-clock time, randomness) and let small clusters of
your own in-process code run for real together. Reserve heavy, London-style mocking for cases where
a collaborator is genuinely expensive, non-deterministic, or not yet built — not as the default
mode for every test. This produces a suite that changes less often for reasons unrelated to actual
behavior change, which is the property that keeps a suite trustworthy over years, not just at
launch.

## What should be tested at this level

- **Business logic and decision points** — calculations, validation rules, state transitions,
  conditional branches. This is where unit tests earn the most value per test, because this is
  where a codebase's actual risk concentrates.
- **Edge cases and boundary conditions** that are cheap to enumerate here and expensive to
  enumerate at higher levels — empty input, maximum/minimum values, unexpected types, boundary
  values on either side of a comparison.
- **Error handling logic** — does the code do the right thing when a collaborator (real or faked)
  returns an error, throws, or returns an unexpected shape?
- **Public behavior of a module**, exercised through its actual public interface — not through
  reaching into internals.

## What should not be tested at this level

- **Anything that requires faking so much of the surrounding system that the test no longer
  resembles how the code is actually used.** If setting up a unit test requires ten mocks wired
  together precisely, the unit under test is very likely too large or too coupled — that's a design
  signal, not just a testing inconvenience.
- **Integration behavior disguised as a unit test.** A "unit test" that spins up a real database
  connection, even an in-memory one, to verify a repository's query logic is an integration test —
  see [`integration-testing.md`](integration-testing.md) — and should be named, run, and gated as
  one, not counted toward "fast unit suite" numbers it doesn't actually belong in.
- **The specific sequence of calls to a collaborator**, unless the *order* of those calls is itself
  the behavior being verified (rare). Asserting "method X was called before method Y" when the
  actual requirement is just "both eventually happened" overspecifies the test and makes it fail on
  a harmless reordering.
- **Getters, setters, and other code with no independent logic.** See
  [`testing-strategy.md`](testing-strategy.md)'s "what should not be tested" for the general
  principle; it applies most literally at this level.

## Where mocking goes wrong

The most common unit-testing failure mode is a test that mocks every collaborator so thoroughly
that it stops verifying behavior and starts verifying that the mocks were configured and called the
way the test author already expected — which means the test can never fail for the reason it
exists to catch (the code doing the wrong thing), only for the reason it shouldn't (the internal
wiring changed).

**Symptom**: a refactor that provably preserves behavior (verified by manual testing, by higher-level
tests, by code review) breaks a dozen unit tests anyway, because they asserted internal call
sequences rather than outcomes.

**Fix**: assert on the *outcome* a caller would observe (the return value, the resulting state, a
message actually sent) rather than on *how* the unit produced that outcome, wherever the outcome is
observable at all. Reserve interaction-based assertions ("was this called") for the cases where the
interaction genuinely *is* the contract — e.g., verifying that a payment is actually submitted to a
payment gateway, where the side effect has no other observable trace within the test's reach.

## Examples

**Over-specified — coupled to implementation, not behavior:**
```
test "processes an order":
    mockPricingEngine.expectCalledWith(order.items)
    mockInventoryService.expectCalledWith(order.items, order.warehouseId)
    mockNotifier.expectCalledExactlyOnceWith(order.customerId)

    processOrder(order, mockPricingEngine, mockInventoryService, mockNotifier)

    verifyAllMocksCalledInOrder()
    # Breaks if the implementation reorders these calls or introduces a new
    # collaborator, even if the actual order-processing behavior is unchanged.
```

**Outcome-focused — survives internal restructuring:**
```
test "processes an order":
    order = anOrderWith(items: [item(price: 10, qty: 2)])

    result = processOrder(order, realPricingEngine, fakeInventoryService, fakeNotifier)

    assertEqual(result.total, 20)
    assertEqual(result.status, "confirmed")
    assertTrue(fakeNotifier.wasNotified(order.customerId))
    # Verifies what a caller actually cares about: the computed total, the
    # resulting status, and that notification happened — not the exact
    # sequence of internal calls that produced them.
```

## Maintainability

- **Arrange-Act-Assert (or Given-When-Then) structure, consistently**, so any reader can scan a
  test and immediately identify setup, the action under test, and the expectation — inconsistent
  structure across a suite slows every future reader down, cumulatively.
- **One behavior per test.** A test with "and" in its description (`testValidatesInputAndSavesRecord`)
  is usually two tests wearing one name; split it so a failure points at exactly one broken
  behavior.
- **Prefer real, simple value objects over mocks wherever the collaborator is cheap and
  deterministic.** A plain data object doesn't need to be mocked; only mock what's genuinely
  expensive, external, or non-deterministic.
- **Keep test setup readable at the point of use.** A shared factory/builder for constructing test
  data is fine and often good; a shared builder that hides the specific values a given test actually
  depends on (forcing the reader to open the builder to understand what's being tested) works
  against the test's own clarity.

## CI integration

Unit tests are the layer with no excuse not to run on every push and gate every PR — they should
be fast enough (seconds, not minutes, for the full suite in most codebases) that there's no
meaningful cost to running all of them, every time. If the unit suite is slow enough that engineers
are tempted to skip running it locally before pushing, that's a signal worth treating as seriously
as any other performance regression — see [`../performance-guide.md`](../performance-guide.md)'s
profiling-before-optimizing discipline, applied to the test suite itself.
