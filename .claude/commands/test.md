---
description: Work out a test strategy — what to cover and at what level — before writing tests, then implement it.
argument-hint: [feature, change, or existing code to develop a test strategy for]
---

Determine what actually needs testing here and at what level, before writing
a single test case. Generating tests without a strategy produces coverage
that looks complete on a dashboard and misses the failure mode that actually
ships — this command exists to prevent that.

**Target**: $ARGUMENTS

## Process

1. **Establish the test pyramid shape for this change.** Per
   [`../../docs/testing/testing-strategy.md`](../../docs/testing/testing-strategy.md),
   decide, explicitly:
   - What belongs at the unit level — pure logic, edge cases, error paths
     that don't require real collaborators.
   - What belongs at the integration level — behavior that only manifests
     with a real dependency (a database, a queue, another service's
     contract) involved.
   - What, if anything, belongs at the end-to-end level — a user-visible
     flow where the integration between components is the thing actually
     being verified, not the components individually.
   Most changes should be unit-heavy; if this one isn't, state why.

2. **Enumerate what must be covered, not just what's easy to cover.**
   - The stated acceptance criteria from `/plan`, if one exists.
   - Edge cases: empty input, maximum/minimum boundaries, unexpected types,
     concurrent access if relevant.
   - Error paths: what happens when a dependency fails, times out, or
     returns something malformed — not just the success path.
   - Regression coverage: if this is a bug fix, a test that reproduces the
     original bug and fails without the fix (see
     [`../../prompts/root-cause-analysis.md`](../../prompts/root-cause-analysis.md)
     if the bug's root cause isn't already understood).

3. **Decide what NOT to test, and say so.** Testing implementation details
   (private internals, exact call counts to a mock with no behavioral
   consequence) produces brittle tests that break on refactors without
   catching real bugs. State explicitly what's being left untested and why
   — usually because it's already covered at a different level, or because
   it's not behavior a consumer can observe.

4. **Write the tests.** Each test should have a name that states the
   behavior being verified, not the method being called. A test that fails
   should tell the reader what's broken without them needing to read the
   test's internals.

5. **Verify the tests actually test something.** For each new test, confirm
   it fails if you revert the change it's meant to cover (or temporarily
   break the logic it's testing) — a test that passes both before and after
   the fix isn't verifying anything. This step is not optional; skipping it
   is the single most common way meaningless tests enter a codebase.

6. **Check flaky-test risk.** Per `docs/testing/testing-strategy.md`'s flaky test
   policy — any test with real-time dependencies, unmocked network calls, or
   order-dependent state should be flagged and fixed before it's added, not
   merged with a known intermittent-failure risk.

## Output shape

Present the strategy (pyramid-level breakdown, what's covered, what's
explicitly excluded and why) before the test code itself. If this strategy
surfaces a gap in the plan or implementation — an edge case nobody
considered — stop and flag it rather than silently writing a test for
behavior that doesn't exist yet.
