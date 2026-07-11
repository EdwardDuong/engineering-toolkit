---
description: Generate tests for existing or new code, matched to the project's testing strategy.
argument-hint: [file, function, or feature to generate tests for]
---

Generate tests for: $ARGUMENTS

## Process

1. **Determine the right level of test.** Consult
   [docs/testing-strategy.md](../../docs/testing-strategy.md) to decide
   whether this needs unit, integration, or end-to-end coverage (often
   more than one). Match the existing test conventions in the codebase
   (framework, file layout, naming) rather than introducing a new pattern.

2. **Read the code under test in full**, per
   `.claude/rules/understand-before-coding.md`, including its current
   callers and any existing tests, so new tests complement rather than
   duplicate what's already covered.

3. **Identify what needs coverage:**
   - The primary/happy path.
   - Edge cases: empty input, boundary values, maximum sizes, unusual but
     valid input.
   - Error paths: invalid input, failures of dependencies, timeouts.
   - Any behavior implied by the code's branches — every meaningful branch
     should have at least one test that exercises it.
   - Regression cases, if this is for a bug fix — the test must fail
     against the old (buggy) behavior.

4. **Write tests that assert behavior, not implementation.** A test should
   verify observable outcomes (return value, side effect, state change),
   not internal implementation details that are free to change under
   refactoring. Tests coupled to implementation details cause false
   failures during legitimate refactors and provide false confidence.

5. **Name tests descriptively.** A test name should describe the scenario
   and expected outcome well enough that a failure report alone tells you
   what broke, without opening the test body.

6. **Keep tests independent and deterministic.** No shared mutable state
   between tests, no reliance on execution order, no untamed randomness or
   real wall-clock time/network calls unless that's specifically what's
   being tested (and then, isolate and control it explicitly).

7. **Run the new tests** to confirm they pass against current correct
   behavior, and — where practical — temporarily break the implementation
   to confirm the test actually fails when it should (a test that can't
   fail isn't verifying anything).

This command is the operational expansion of
[prompts/generate-tests.md](../../prompts/generate-tests.md) — consult it
for more detail on framework-specific patterns and mocking guidance.

Report back a summary of what scenarios are now covered and any gaps you
identified but didn't cover (and why).
