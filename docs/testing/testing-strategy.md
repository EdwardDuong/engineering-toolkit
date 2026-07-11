# Testing Strategy

Tests exist to let you change code with confidence, not to satisfy a coverage dashboard. A test
suite that's green but doesn't catch real regressions is worse than no suite, because it
manufactures false confidence — someone ships on the strength of a passing suite that was never
actually capable of catching the class of bug that just reached production.

This document is the overview and the decision framework. The three documents beside it —
[`unit-testing.md`](unit-testing.md), [`integration-testing.md`](integration-testing.md), and
[`end-to-end-testing.md`](end-to-end-testing.md) — go deep on each layer: what it verifies that
the others structurally can't, what belongs there and what doesn't, and how to keep it
maintainable. [`test-review-checklist.md`](test-review-checklist.md) is the practical checklist for
reviewing whether a specific test is actually pulling its weight.

## What should be tested

Test **behavior that matters to a consumer of the code** — a caller, a user, another team's
service — not the implementation detail of how that behavior is achieved. Concretely, prioritize:

- **Decision points and branches** — every conditional, every branch, every place the code chooses
  between two or more outcomes. This is where bugs concentrate, and where a missing test leaves the
  largest blind spot.
- **Boundary and edge conditions** — empty collections, maximum/minimum values, off-by-one
  boundaries, the first and last item in a sequence. Bugs cluster at boundaries far more than the
  even distribution a line-coverage number implies.
- **Error and failure paths** — what happens when a dependency times out, returns malformed data,
  or the input is invalid. A codebase with thorough happy-path coverage and no failure-path
  coverage is under-tested exactly where production incidents come from.
- **Public contracts** — a function, API, or module's documented or implied guarantees to its
  callers. If callers depend on it, a test should verify it holds.
- **Regressions** — any bug that reached production gets a test that reproduces it and fails
  without the fix, permanently, so the same defect can't recur silently. See
  [`../workflows/bug-fix.md`](../workflows/bug-fix.md).

## What should not be tested

This section exists because "test everything" is not free advice — every test is a maintenance
liability that must earn its keep by catching real bugs, and testing the wrong things produces a
large, slow, brittle suite that still misses the failures that matter. Don't test:

- **The language or framework itself.** A test asserting that a list's `append` method adds an
  element, or that a framework's router calls the handler you registered, verifies code you didn't
  write and that's already tested by its own maintainers. It adds maintenance cost with no
  corresponding risk reduction.
- **Trivial delegation.** A function that does nothing but call another function with the same
  arguments and return its result has no independent behavior to verify — testing it duplicates the
  test of the thing it calls, for zero additional coverage.
- **Private implementation detail, as its own target.** If a test can only be written by reaching
  into a component's internals (a private method, an internal data structure), it's coupled to
  *how* the behavior is achieved, not *what* the behavior is — the test will break on a valid
  refactor that changes nothing a real caller could observe. Test through the public interface;
  let internal restructuring happen without touching the test.
- **Third-party libraries' correctness.** Trust that a well-established dependency does what its
  own documentation and test suite claim. Test *your integration with it* (did you call it
  correctly, do you handle what it returns) — see [`integration-testing.md`](integration-testing.md)
  — not its internal behavior.
- **Exact wording of a log message or a comment.** These change often and carry no contract; a test
  asserting an exact string here breaks on every harmless copy edit and teaches engineers to treat
  test failures as noise.
- **Configuration that's declarative and machine-checked another way.** A schema or type system
  that already guarantees a field's shape doesn't need a redundant unit test proving the same
  guarantee — spend that effort on behavior the type system can't express.

## The test pyramid, and why it's a heuristic, not a law

A healthy suite has more tests at cheaper, faster, more isolated levels and fewer at expensive,
slower, more integrated ones — the shape is justified by a cost curve, not by convention:

- **Unit tests** (the base, most numerous) — verify a single, focused unit of behavior in
  isolation. Milliseconds per test, deterministic, and precise about what broke when one fails. See
  [`unit-testing.md`](unit-testing.md) for what "unit" actually means and why that's more contested
  than it sounds.
- **Integration tests** (the middle layer) — verify that your code and a real collaborator (a
  database, a queue, an internal service's actual client) work together correctly. Slower, and they
  catch a class of bug unit tests structurally cannot: wrong SQL, a serialization mismatch, a
  misconfigured client, a contract two services silently disagree on. See
  [`integration-testing.md`](integration-testing.md).
- **End-to-end tests** (the top, fewest) — verify a full, real user-facing flow through the real (or
  near-real) system. Slowest, most brittle, and reserved for what genuinely can't be verified any
  other way. See [`end-to-end-testing.md`](end-to-end-testing.md).

**Why this is a heuristic and not a fixed ratio**: the pyramid encodes a cost/feedback tradeoff —
push verification as far down as it can meaningfully go, because a failing unit test tells you
almost exactly where the bug is, while a failing e2e test tells you something is wrong somewhere in
a long chain. That reasoning holds regardless of architecture. The *exact shape* doesn't. A system
built primarily as thin orchestration over other services' contracts may reasonably lean more
heavily on contract/integration-level tests than a computation-heavy monolith with rich internal
logic, because there's comparatively little standalone logic to unit-test and comparatively more
risk sitting at the boundaries. Treat "pyramid-shaped" as "cheap, fast, precise tests dominate; slow
brittle ones are reserved for what only they can verify," not as a mandated 70/20/10 split applied
uniformly regardless of what the system actually is.

An **inverted pyramid** — many slow e2e tests and few unit tests — is a common and genuinely
costly failure mode, usually arising because e2e tests feel more "real" and higher-confidence to
write, while unit tests around legacy or poorly-decoupled code feel awkward to set up. The suite
takes a long time to run, flakes often (see below), and a single logic bug requires debugging
through several real systems to isolate — the opposite of what a fast, precise test suite is for.

## Coverage philosophy: meaningful coverage over percentage targets

A coverage percentage measures **lines executed by tests**, not **behavior verified**. A test that
calls a function and asserts nothing meaningful about the result inflates coverage while verifying
nothing.

- Prioritize covering decision points and failure paths — see "What should be tested" above — over
  covering every line uniformly.
- Treat coverage as a **diagnostic**, not a **target**. A sudden drop on a specific change is worth
  asking about; a suite sitting at 82% instead of a mandated 90% is not inherently a problem if the
  missing 8% is genuinely low-risk (generated boilerplate, trivial getters).
- New behavior should always ship with a test that would fail if the behavior were wrong — a
  stronger and more useful bar than "coverage didn't decrease." See
  [`test-review-checklist.md`](test-review-checklist.md) for how to actually verify a test meets
  this bar rather than assuming it from its presence.
- Be explicit in [`../../checklists/before-pull-request.md`](../../checklists/before-pull-request.md)
  about what needs a test on every change, rather than relying on an aggregate percentage gate to
  catch gaps after the fact.

## Maintainability

A test suite is a codebase in its own right, and it rots the same way production code does if it
isn't actively maintained with the same discipline:

- **Test behavior, not implementation** (restated here because it's the single largest driver of
  suite maintainability) — a suite coupled to internal structure breaks on every refactor
  regardless of whether the refactor changed any observable behavior, which trains engineers to
  treat test failures as noise to silence rather than signal to investigate.
- **One clear reason to fail, per test.** A test asserting five unrelated things fails for an
  ambiguous reason and forces the reader to dig through assertion output to find out which of the
  five actually broke. Prefer several small, precisely-named tests over one broad one.
- **Name tests by the behavior they verify**, not the method under test — `rejectsWithdrawalOverBalance`
  tells a reader what broke from the test name alone; `testWithdraw2` doesn't.
- **Minimize shared mutable fixtures.** Tests that share setup are cheaper to write but couple
  unrelated tests together — a change to shared fixture data can silently break tests that have
  nothing to do with what changed, in ways that are hard to trace back to the actual cause.
- **Don't over-mock.** A test that mocks so much of its own dependency graph that it's really just
  asserting the mocks were called correctly has stopped testing behavior and started testing the
  mock setup — see the classicist-vs-mockist tension covered in
  [`unit-testing.md`](unit-testing.md).
- **Delete tests that no longer earn their keep**, deliberately — a test for behavior that's been
  removed, or a redundant test that duplicates coverage another test already provides, is pure
  maintenance cost. Treat test deletion with the same intentionality as test creation, not as
  something that only happens accidentally when a merge conflict is easier to resolve by deleting.

## CI integration

How tests run is a design decision, not an afterthought bolted on once the suite exists:

- **Fast feedback gates the common path; slow feedback gates the risky path.** Unit and most
  integration tests should run, and block, on every push/PR — they're cheap enough that there's no
  good reason not to. Full end-to-end suites are often better run on a separate cadence (post-merge,
  nightly, or pre-release) where their cost and flakiness don't block every change — see
  [`end-to-end-testing.md`](end-to-end-testing.md) for when this tradeoff is justified.
- **Parallelize and shard** as the suite grows — a suite that takes 40 minutes serially trains
  engineers to context-switch away and lose the tight feedback loop that makes tests valuable in the
  first place. Sharding by historical duration (not just file count) keeps shards balanced.
- **Cache what's safe to cache** (dependency installation, build artifacts) but never cache test
  *results* across code changes — a green run from a stale cache is a false signal indistinguishable
  from a real pass until it silently isn't.
- **Treat CI-only failures as a signal, not a nuisance.** A test that passes locally and fails
  intermittently in CI is very often exposing a real concurrency, timing, or environment-dependence
  bug in the code, not "just CI being flaky" — see the flaky test policy below before assuming it's
  the test's fault.
- **Required vs. advisory checks should be a deliberate choice.** Blocking merge on a suite with
  known flakiness trains engineers to force-merge past red CI, which defeats the purpose of the gate
  entirely — get flakiness under control before making a check required, not after.

## Test data management

- **Unit tests** build their own minimal, in-memory fixtures — no shared database state, no
  dependency on data that happens to exist in some environment.
- **Integration and e2e tests** need realistic data without depending on production data. Use
  generated or seeded fixtures that are version-controlled and regenerable, not a snapshot of real
  user data (which also raises privacy concerns — see [`../security-guide.md`](../security-guide.md)
  and [`../logging-standards.md`](../logging-standards.md) on handling sensitive data).
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

- [`../../checklists/before-pull-request.md`](../../checklists/before-pull-request.md) — what test
  coverage a PR needs before review.
- [`../performance-guide.md`](../performance-guide.md) — load and performance testing, which sits
  alongside but outside the correctness-focused pyramid above.
- [`../../.claude/commands/test.md`](../../.claude/commands/test.md) and
  [`../../prompts/generate-tests.md`](../../prompts/generate-tests.md) — for working out a test
  strategy for a specific change and generating the tests consistent with it.
