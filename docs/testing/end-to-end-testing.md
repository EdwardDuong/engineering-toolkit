# End-to-End Testing

End-to-end (e2e) tests verify a real, complete user-facing flow through the real (or as-close-to-real
as practical) system — the only layer that can catch a defect that exists purely in how multiple,
independently-correct components are wired together. They're also the slowest, most brittle, and
most expensive layer to maintain, which makes disciplined scope the entire game: an e2e suite that's
allowed to grow without that discipline becomes a slow, flaky, low-signal tax on every release
rather than the high-confidence safety net it's meant to be.

## What e2e tests verify uniquely

- **Real cross-component wiring** — that the actual deployed configuration of services, routing,
  and integration points produces the right outcome, not just that each component is individually
  correct in isolation (which unit and integration tests already establish).
- **Real timing and concurrency behavior** — race conditions, real network latency, real
  asynchronous propagation delay — that a component-level test with faked or containerized
  dependencies can approximate but not fully replicate.
- **The actual contract the user experiences** — for a UI, the real rendered page and real
  interaction; for an API consumer, the actual deployed response shape end to end, including
  infrastructure layers (a gateway, a CDN, an auth proxy) that component-level tests don't traverse.
- **Critical business flows working end to end after a deploy** — the strongest signal available
  that a release is actually safe to ship, for the small number of flows where "actually safe to
  ship" is worth this test's cost to verify directly.

## What should not be tested at this level

This is where discipline matters most, because e2e tests *feel* like the most trustworthy layer
(they exercise the "real" system) and that feeling tempts teams into using them as a catch-all —
which is the single most common and most costly e2e-testing mistake:

- **Edge cases and error paths already covered at lower levels.** If a validation rule's ten edge
  cases are covered by unit tests, don't re-verify all ten by driving a real browser or a real API
  client through the full stack — that's redundant coverage at 100-1000x the cost per case, with a
  much higher flakiness risk per case too.
- **Anything that doesn't require the full system to be wired together to verify.** If a test could
  be written at the integration level (one real boundary) and still catch the defect it's meant to
  catch, write it there — reserve e2e scope for what genuinely requires the whole system.
- **Exhaustive coverage of every user path.** An e2e suite's job is to cover the *critical* paths —
  the handful of flows where a regression would be a genuine incident (checkout completing, login
  succeeding, a payment processing) — not to exhaustively mirror every unit test's edge case at the
  UI layer. A large, slow, low-signal e2e suite is a common and expensive anti-pattern; a small,
  fast, high-signal one is the goal.
- **UI layout/visual detail**, unless the test suite specifically includes visual regression testing
  as a distinct, separately-run mechanism — a functional e2e test asserting exact pixel positions or
  incidental styling breaks on every harmless design tweak and teaches engineers to treat e2e
  failures as noise.

## Flakiness: why this layer is uniquely prone to it, and what to do about it

E2E tests fail intermittently more often than any other layer, for structural reasons worth
understanding rather than just tolerating:

- **Real timing means real races.** An element that usually renders within 200ms but occasionally
  takes 800ms under load will flake any test that doesn't explicitly wait for the actual readiness
  condition rather than a fixed sleep.
- **Real network means real transient failures.** A test hitting a real (even if test-environment)
  network path can hit a genuine transient blip unrelated to the code under test.
- **Shared test environments accumulate state.** An e2e suite running against a shared staging
  environment can be affected by other tests, other deployments, or leftover data from a previous
  run that a fully isolated unit or integration test would never encounter.

**Mitigation, in priority order:**
1. **Wait for explicit readiness conditions**, never a fixed sleep — poll for the actual state
   (an element present, a response received, a job's status field changing) with a timeout, not
   `sleep(2)` and hope.
2. **Isolate test data per run** where at all possible — a fresh account, a fresh order, a
   uniquely-namespaced record — rather than relying on shared fixtures that other tests or other
   runs might mutate concurrently.
3. **Retry the *test run*, not silently swallow the failure** — if a flake is confirmed
   environmental (verified, not assumed) after investigation, a bounded retry at the CI level is a
   reasonable mitigation; retrying without ever investigating whether the flake reveals a real bug is
   not, per [`testing-strategy.md`](testing-strategy.md)'s flaky test policy.
4. **Quarantine anything that can't be stabilized quickly**, with an owner and a deadline, exactly as
   described in [`testing-strategy.md`](testing-strategy.md) — a known-flaky e2e test left in the
   blocking suite is worse than not having it, because it trains engineers to ignore red CI.

## Maintainability

- **Use a page-object or API-object abstraction layer**, not raw selectors or raw request-building
  scattered across every test — when a UI element's selector or an API's request shape changes,
  fixing it in one place should fix every test that depends on it, not require a find-and-replace
  across dozens of files.
- **Keep each e2e test's assertion narrow to the flow it's meant to verify.** A checkout e2e test
  should assert that checkout completed and the order exists — it shouldn't also assert on
  unrelated account-settings behavior just because the test happens to pass through a page where
  that's visible.
- **Treat e2e test count as a cost to actively manage, not a coverage metric to maximize.** Before
  adding a new e2e test, ask whether the same risk could be caught at a cheaper layer — this
  question, asked consistently, is what keeps the suite small and high-signal instead of growing
  without bound.
- **Review and prune regularly.** A flow that's been removed from the product, or a test that's
  been superseded by a better one covering the same risk, should be deleted — an e2e suite
  accumulates unnoticed dead weight faster than any other layer because each individual test looks
  valuable in isolation.

## CI integration

E2E tests justify a different CI relationship than unit and integration tests, and pretending
otherwise (blocking every PR on the full e2e suite) is a common source of slow, painful CI:

- **Run the critical-path subset on every PR if it's fast and stable enough**; run the fuller suite
  post-merge, nightly, or as a pre-release gate — per
  [`testing-strategy.md`](testing-strategy.md)'s CI integration guidance on fast-vs-risky feedback
  loops. Blocking merge on the full, slow suite trains engineers to batch changes to avoid paying the
  cost repeatedly, which works against the fast, frequent-integration norm this toolkit otherwise
  recommends (see [`../git-workflow.md`](../git-workflow.md)).
- **Run against an environment that's representative but isolated** — a dedicated ephemeral
  environment per run, or careful namespacing within a shared one — so failures are attributable to
  the change under test, not to interference from concurrent runs.
- **Alert distinctly on e2e failures vs. unit/integration failures** in CI reporting — because e2e
  failures need a different triage instinct (is this a real regression, a real flake, or a stale
  test?) than a unit test failure usually does.
- **Track pass-rate trend over time, not just pass/fail on the latest run.** A suite that's
  "usually green" but fails 1 run in 15 has a real flakiness problem that a single day's green
  build will hide — trend data surfaces it before it erodes trust in the suite entirely.
