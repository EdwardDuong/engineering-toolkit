# Testing Strategy

Tests exist to let you change code with confidence, not to satisfy a coverage dashboard. A test
suite that's green but doesn't catch real regressions is worse than no suite, because it
manufactures false confidence.

## The test pyramid

A healthy suite has more tests at cheaper, faster, more isolated levels and fewer at expensive,
slower, more integrated ones:

- **Unit tests** (the base, most numerous) — verify a single function, module, or class in
  isolation, with dependencies faked or stubbed. Fast (milliseconds), deterministic, and precise
  about what broke when they fail.
- **Integration tests** (the middle layer) — verify that two or more real components work together
  correctly: your code against a real database, a real message queue, or a real (not mocked) client
  of an internal service. Slower and more expensive to maintain, but catch the class of bug unit
  tests structurally can't (wrong SQL, a serialization mismatch, a misconfigured client).
- **End-to-end tests** (the top, fewest) — verify a full user-facing flow through the real (or
  near-real) system. Slowest, most brittle, most valuable for catching issues that only manifest
  when everything is wired together, and the most expensive to keep passing as the system evolves.

The shape matters because of the cost curve: a unit test that fails tells you almost exactly where
the bug is; an e2e test that fails tells you something is wrong somewhere in a long chain, and
debugging it starts from a much wider search space. Push verification as far down the pyramid as it
can meaningfully go, and reserve upper layers for what can only be verified there (real network
behavior, real timing, cross-service contracts).

An inverted pyramid — many slow e2e tests and few unit tests — is a common failure mode: the suite
takes a long time to run, flakes often (see below), and a single logic bug can require debugging
through several real systems to isolate.

## Coverage philosophy: meaningful coverage over percentage targets

A coverage percentage measures **lines executed by tests**, not **behavior verified**. A test that
calls a function and asserts nothing meaningful about the result inflates coverage while verifying
nothing. Chasing a coverage number as the primary goal produces exactly this kind of test.

- Prioritize covering **decision points and failure paths** — every branch, every error case, every
  boundary condition — over covering every line uniformly. A function with 100% line coverage but no
  test for its error path is under-tested where it matters most.
- Treat coverage as a **diagnostic**, not a **target**. A sudden drop in coverage on a change is
  worth asking about; a suite sitting at 82% instead of a mandated 90% is not inherently a problem
  if the missing 8% is genuinely low-risk code (generated boilerplate, trivial getters).
- New behavior should always ship with a test that would fail if the behavior were wrong. This is a
  stronger and more useful bar than "coverage didn't decrease."
- Be explicit in [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md)
  about what needs a test on every change, rather than relying on an aggregate percentage gate to
  catch gaps after the fact.

## Test data management

- **Unit tests** build their own minimal, in-memory fixtures — no shared database state, no
  dependency on data that happens to exist in some environment.
- **Integration and e2e tests** need realistic data without depending on production data. Use
  generated or seeded fixtures that are version-controlled and regenerable, not a snapshot of real
  user data (which also raises privacy concerns — see [`security-guide.md`](./security-guide.md) and
  [`logging-standards.md`](./logging-standards.md) on handling sensitive data).
- **Tests must not depend on shared mutable state** between runs or between each other. A test suite
  where test order matters, or where one test's leftover data affects another, will eventually
  produce failures that only reproduce in CI and waste hours of investigation.
- **Clean up what you create.** Any test that provisions data (a database row, a temp file, a queued
  message) is responsible for removing it, or running inside a transaction/sandbox that's discarded
  after the test — don't rely on a separate cleanup job to keep the test environment sane.

## Flaky test policy

A flaky test — one that fails intermittently without a corresponding code change — is a liability
that grows over time: engineers stop trusting the suite, start re-running failures instead of
investigating them, and eventually stop noticing when a flaky test is masking a real bug.

- **Quarantine, don't ignore.** A newly-flaky test should be marked as such (skipped in the blocking
  CI run, tracked separately) immediately, with an owner and a tracked issue — not left in the
  normal suite where it trains people to re-run failures without looking at them, and not silently
  deleted, which loses the coverage it provided.
- **Fix or delete within a defined window** (a sprint is a reasonable default). A quarantined test
  with no fix timeline becomes permanent dead weight.
- **Common causes to check first**: shared mutable state between tests, real time/clock dependence
  instead of a controllable clock, unbounded async waits instead of explicit synchronization,
  order-dependence, and reliance on external network calls that should have been stubbed.
- **Never respond to flakiness by adding a retry-until-pass wrapper** without first understanding
  why it's flaky — that hides the signal rather than fixing the cause, and a test that "passes
  eventually" isn't verifying anything reliably.

## See also

- [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md) — what test
  coverage a PR needs before review.
- [`performance-guide.md`](./performance-guide.md) — load and performance testing, which sits
  alongside but outside the correctness-focused pyramid above.
- [`../prompts/generate-tests.md`](../prompts/generate-tests.md) — a ready-to-use prompt for
  generating tests consistent with this strategy.
