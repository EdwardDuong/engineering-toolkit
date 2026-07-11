# Integration Testing

The name "integration test" is used loosely enough across the industry to be nearly meaningless
without a definition — some teams use it for anything slower than a unit test, including full user
journeys. This document uses it narrowly and deliberately: **a test that verifies your code's
actual behavior against one real collaborator across a genuine architectural boundary** — a
database, a message queue, a filesystem, an internal service's real client — while keeping
everything else about the test as narrow and fast as a unit test.

That narrowness is the point. An integration test that also exercises three unrelated services and
a full HTTP round trip through a load balancer isn't a bigger integration test — it's an end-to-end
test with a misleading name, and it should be recognized, run, and gated as one (see
[`end-to-end-testing.md`](end-to-end-testing.md)).

## What integration tests verify that unit tests structurally cannot

Unit tests, per [`unit-testing.md`](unit-testing.md)'s recommended classicist style, fake anything
crossing a real architectural boundary — which means they cannot, by construction, catch a defect
that only exists in the real interaction with that boundary:

- **Query correctness against a real engine** — a hand-written or ORM-generated query that's
  syntactically valid but returns the wrong rows, has an unexpected N+1 pattern, or behaves
  differently under a real query planner than the mental model assumed. See
  [`../database-guidelines.md`](../database-guidelines.md).
- **Serialization/deserialization fidelity** — a message that round-trips correctly through your
  in-memory objects but loses precision, changes type, or breaks on a real wire format
  (JSON number precision, timezone handling, a schema evolution mismatch).
- **Client configuration correctness** — an HTTP client, database driver, or queue client that's
  configured with the wrong timeout, the wrong connection pool size, or the wrong retry policy only
  fails against something with real latency and real failure modes; a unit test with a faked client
  can't surface a misconfiguration in the real one.
- **Contract agreement between two components you own** — does the producer of a message and the
  consumer of it actually agree on its shape, right now, not just according to each side's
  independently-maintained assumption of what the other expects?

## What should not be tested at this level

- **Business logic edge cases already covered by unit tests.** If a validation rule has ten edge
  cases, don't re-enumerate all ten against a real database — cover the logic exhaustively at the
  unit level, and use one or two representative cases here to confirm the logic and the real
  collaborator actually connect correctly. Duplicating exhaustive logic coverage at this slower
  layer is pure cost with no corresponding benefit.
- **Full user journeys spanning multiple services.** That's end-to-end scope — see
  [`end-to-end-testing.md`](end-to-end-testing.md). An integration test verifies one boundary at a
  time; a test that hops across three services to verify a single outcome has smuggled e2e scope
  into a layer that's supposed to stay fast and precise.
- **Third-party service behavior you don't control**, tested by calling the real, live external
  service. This produces a flaky, slow, sometimes-costly test that fails whenever the third party
  has a bad day, unrelated to whether your code is correct. Use a realistic local double (a
  containerized version of the real dependency, a recorded-response fixture, or a contract test
  against the third party's published contract) instead — see "Test doubles at this layer" below.

## Test doubles at this layer

The central judgment call in integration testing is *what to fake and what to run for real*:

- **Run for real**: anything you're specifically trying to verify the interaction with — if the
  test exists to verify query correctness, run a real database (an ephemeral, containerized
  instance is usually the right default — fast to start, fully real behavior, disposable).
- **Fake or use a recorded double**: a third-party service you don't control and can't run
  locally — record its real responses once (a contract/cassette-style fixture) and replay them,
  rather than calling the live service on every test run. Refresh the recording deliberately when
  the third party's contract changes, not silently.
- **A fully in-memory fake database is a unit test, not an integration test**, even if it satisfies
  the same interface as the real one — an in-memory fake almost never has the same query semantics,
  transaction behavior, or failure modes as the real engine, and a test passing against the fake
  tells you nothing reliable about behavior against the real thing. If the goal is to verify actual
  database interaction, use the actual database (containerized), not a same-shaped substitute.

## Maintainability

- **Isolate test data per test**, even against a shared containerized dependency — use
  transactions that roll back, unique namespacing per test, or a freshly seeded instance per test
  run, so tests don't leak state into each other. Order-dependent integration tests are one of the
  most common sources of "fails only in CI, passes locally" reports.
- **Keep setup/teardown symmetric and automatic.** A test that provisions a queue topic or a
  database schema should tear it down itself (or run inside a mechanism that guarantees cleanup),
  not rely on a human remembering to clean up after a failed run leaves state behind.
- **Version and review fixture/recorded-response data like code.** A stale recorded response for a
  third-party integration silently drifts from reality and can mask an actual contract change;
  treat refreshing it as a deliberate, reviewed action, not something that happens accidentally.
- **Name the boundary being tested explicitly** (`OrderRepository_Postgres_test`, not just
  `OrderRepositoryTest`) — this makes it obvious at a glance what's real and what's faked in a given
  test, without needing to read the setup code.

## CI integration

Integration tests are more expensive than unit tests and need deliberate infrastructure, which
makes their CI story a real design decision, not a default:

- **Containerize dependencies for CI** (a real database, a real queue) rather than depending on a
  shared, persistent test environment — a shared environment accumulates state pollution across
  runs and becomes a source of flakiness that's hard to attribute to any specific change.
- **Run integration tests on every PR if they're fast enough** (parallelized containerized
  dependencies usually keep this layer in the low minutes) — the value of catching a boundary defect
  before merge is high enough to justify the extra time in most cases, distinct from the
  much-higher cost/value tradeoff of full e2e suites.
- **Watch for shared-resource contention under parallelization** — if many test workers hit the
  same containerized database instance concurrently, tests can interfere with each other in ways
  that look like flakiness but are actually a parallelization/isolation bug in the test setup, not
  in the code under test. Prefer one dependency instance per worker, or strict per-test data
  isolation, over a single shared instance under load.
- **Track this layer's runtime separately from the unit suite's.** A slow integration suite creeping
  upward over time is easy to miss if it's bundled into a single "tests" CI step with a suite that's
  supposed to stay fast — separate timing makes the trend visible.
