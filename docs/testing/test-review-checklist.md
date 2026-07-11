# Test Review Checklist

[`../../checklists/before-pull-request.md`](../../checklists/before-pull-request.md) asks whether
tests were added or updated. It doesn't ask whether those tests are actually good — a suite can
have 100% of that box checked and still be worthless. This checklist is for the second question:
reviewing the tests themselves, not just confirming their presence. Run it whenever a diff includes
new or changed tests, as part of the same review pass covered by
[`../../.claude/agents/reviewer.md`](../../.claude/agents/reviewer.md) and
[`/review`](../../.claude/commands/review.md).

## Does it verify real behavior?

- [ ] The test would fail if the change it's meant to cover were reverted. This is the single most
      important check and the one most often skipped — verify it directly (temporarily revert the
      change locally and confirm the test catches it), don't assume it from the test's presence.
- [ ] The assertion checks an actual outcome (a return value, a resulting state, a side effect a
      caller could observe) rather than only that some internal method was called — see
      [`unit-testing.md`](unit-testing.md)'s "where mocking goes wrong."
- [ ] The test's name accurately describes the behavior it verifies — a reader should be able to
      understand what broke from the test name and failure message, without reading the test body.
- [ ] The test doesn't assert something so broad or so loose that it would still pass with a wrong
      implementation (e.g., asserting a response is "not null" when the actual requirement is a
      specific value).

## Is it at the right pyramid level?

- [ ] The test is at the cheapest level that can actually verify the behavior — see
      [`testing-strategy.md`](testing-strategy.md)'s pyramid discussion. A behavior fully coverable
      with a unit test shouldn't be verified with an integration or e2e test instead.
- [ ] A test labeled "unit" doesn't secretly depend on a real external boundary (database, network,
      filesystem) — see [`unit-testing.md`](unit-testing.md) on tests that misclassify themselves.
- [ ] A test labeled "integration" tests one real boundary, not several chained together — see
      [`integration-testing.md`](integration-testing.md) on integration-scope creep into e2e
      territory.
- [ ] A new e2e test is for a genuinely critical path, not a case that could have been caught more
      cheaply at a lower level — see [`end-to-end-testing.md`](end-to-end-testing.md)'s discipline
      on keeping this layer small and high-signal.

## Does it cover what actually matters?

- [ ] Edge cases and boundary conditions relevant to the change are covered, not just the primary
      happy path.
- [ ] Error and failure paths are covered where the change introduces or touches one — a dependency
      failing, invalid input, a timeout.
- [ ] If this is a bug fix, the test reproduces the original bug and is confirmed to fail against
      the pre-fix code — see [`../workflows/bug-fix.md`](../workflows/bug-fix.md).
- [ ] Coverage isn't padded with low-value tests (trivial getters, framework behavior, third-party
      correctness) that inflate a coverage number without reducing real risk — see
      [`testing-strategy.md`](testing-strategy.md)'s "what should not be tested."

## Is it maintainable?

- [ ] One clear behavior per test — a test with "and" in its intent is a candidate to split.
- [ ] Test setup is readable at the point of use; a shared builder or fixture doesn't hide values
      the test's outcome actually depends on.
- [ ] The test doesn't depend on shared mutable state, execution order, or leftover data from
      another test.
- [ ] Mocking is proportionate — not so heavy that the test verifies its own mock wiring instead of
      real behavior (see [`unit-testing.md`](unit-testing.md)), and not so light that a genuinely
      external, non-deterministic dependency is left unfaked.

## Is it a flakiness risk?

- [ ] No fixed-duration sleep waiting for an async condition — an explicit poll/wait-for-condition
      is used instead, per [`end-to-end-testing.md`](end-to-end-testing.md)'s flakiness mitigation.
- [ ] No dependency on wall-clock time or system time without a controllable/injectable clock.
- [ ] No dependency on a live third-party service the test doesn't control — a recorded fixture or
      local double is used instead, per [`integration-testing.md`](integration-testing.md).
- [ ] Test data is isolated per test/run, not shared in a way that concurrent or repeated runs could
      corrupt.

## Does it fit CI correctly?

- [ ] The test runs at the CI stage appropriate to its cost and layer — see
      [`testing-strategy.md`](testing-strategy.md)'s CI integration section — not bundled into a
      "fast" suite it doesn't belong in, or left out of CI entirely.
- [ ] If this test is genuinely expensive or inherently non-deterministic in a way that can't be
      fully engineered away, that's been made an explicit, reviewed decision (a separate slower
      suite, a documented flakiness tolerance) rather than an unstated fact discovered later.

## Using this checklist

Not every item applies to every test — a five-line unit test for a pure function doesn't need the
full walk-through a new e2e flow does. Use judgment on depth, but don't skip the first section
("does it verify real behavior") for anything: a test that fails that check isn't providing the
value its presence implies, regardless of how well it scores on everything else.
