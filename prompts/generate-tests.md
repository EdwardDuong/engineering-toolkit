# Generate Tests

Guide an AI assistant to generate meaningful tests covering happy paths,
edge cases, and error paths — without testing implementation details.

## Purpose

AI-generated test suites often look thorough while testing very little:
lots of assertions on mocked internals, near-zero coverage of edge cases,
and tests so tightly coupled to implementation that any refactor breaks
them for no behavioral reason. This prompt steers toward
behavior-focused tests that stay useful over time.

## When to use

- Adding test coverage to new or existing code that lacks it.
- Generating characterization tests before a refactor (pair with
  [`refactor-code.md`](refactor-code.md)).
- Reviewing whether an existing test suite actually covers what it claims
  to.

## The prompt

```markdown
You are generating tests for the code below. Optimize for tests that catch
real regressions and stay valid across internal refactors — not for
maximizing line coverage or asserting on internal structure.

## Context
- Code under test: {{code_or_path}}
- Test framework/conventions already in use in this repo: {{test_framework}}
- Public contract (function signature, API endpoint, expected behavior):
{{contract_description}}

## Step 1 — Identify the contract
Before writing tests, state the observable contract you are testing:
inputs, outputs, side effects, and error conditions — as a caller would
see them, not internal implementation steps.

## Step 2 — Enumerate cases
List the cases to cover, grouped as:
- **Happy path**: typical valid inputs and their expected outputs.
- **Edge cases**: boundary values (empty, zero, max, min, single-element,
  duplicate, unicode/encoding where relevant), unusual-but-valid inputs.
- **Error paths**: invalid input, missing required data, downstream
  failures (network/database/timeout where applicable), and how the code
  is expected to fail (specific exception/error type, error message,
  status code — not just "it throws something").
- **Concurrency/state cases**, if applicable: repeated calls, ordering
  dependencies, shared-state mutation.

Flag any case you can't determine the expected behavior for — ask rather
than guessing what "should" happen.

## Step 3 — Write the tests
For each case in Step 2, write a test that:
- Has a name describing the behavior being verified, not the
  implementation ("returns 404 when the resource doesn't exist," not
  "test_function_2").
- Asserts on observable outputs/effects (return value, thrown error, state
  change, emitted event, HTTP response) — not on internal method calls,
  private fields, or mock call counts unless the interaction itself *is*
  the contract (e.g., verifying a required side-effecting call happened).
- Is independent of other tests and doesn't rely on execution order.
- Uses realistic test data, not placeholder values that obscure what's
  being tested.

## Step 4 — Report gaps
After generating tests, state:
- Any case from Step 2 you were unable to write a test for, and why
  (missing seam, requires infrastructure not available in unit scope).
- Any part of the contract that remains untested and should be covered at
  a different test level (integration/e2e).
```

## Expected output

- A short contract statement before any test code.
- A categorized list of cases (happy/edge/error/concurrency).
- Test code matching the repo's existing framework and conventions, with
  behavior-descriptive names.
- A gaps/limitations note at the end, not silently omitted coverage.

## Tips & pitfalls

- Reject tests that assert `expect(mockFn).toHaveBeenCalledWith(...)` as
  the *entire* test for anything other than genuinely side-effecting calls
  (sending an email, writing to a queue) — that's testing implementation,
  not behavior.
- Watch for tests generated to satisfy a coverage percentage rather than
  verify behavior — a test with no meaningful assertion is worse than no
  test, because it creates false confidence.
- If the contract itself is unclear, that's a signal the code needs
  clarification before it needs tests — don't let the AI infer a contract
  from implementation quirks.
- See [`../docs/testing-strategy.md`](../docs/testing-strategy.md) for
  guidance on which test level (unit/integration/e2e) a given case belongs
  at, and this repo's coverage philosophy.
