# Testing Strategy

This folder is this toolkit's complete testing documentation — moved here from a single top-level
`docs/testing-strategy.md` (now superseded) into a proper deep-dive layer, the same way
[`../security/`](../security/README.md) sits beneath `security-guide.md`. Every document avoids
restating textbook definitions in favor of the actual judgment calls and tradeoffs an experienced
engineer navigates: what "unit" really means and why that's contested, when the test pyramid's
shape should and shouldn't apply, and where each layer's discipline most commonly breaks down.

| Doc | Focus |
|---|---|
| [`testing-strategy.md`](testing-strategy.md) | The overview: what should and shouldn't be tested, the pyramid as a heuristic, coverage philosophy, maintainability, and CI integration. Start here. |
| [`unit-testing.md`](unit-testing.md) | What "unit" actually means (classicist vs. mockist), what belongs at this level, and where mocking discipline most commonly fails. |
| [`integration-testing.md`](integration-testing.md) | What a real boundary test verifies that unit tests structurally can't, and how to keep this layer narrow instead of letting it drift into e2e scope. |
| [`end-to-end-testing.md`](end-to-end-testing.md) | Why this layer is uniquely flaky, why it must stay small and critical-path-focused, and how to keep it that way. |
| [`test-review-checklist.md`](test-review-checklist.md) | The practical checklist for reviewing whether a specific test is actually good — distinct from confirming tests merely exist. |

## How this fits the rest of the toolkit

- [`../../.claude/commands/test.md`](../../.claude/commands/test.md) and
  [`../../prompts/generate-tests.md`](../../prompts/generate-tests.md) operationalize this strategy
  for a specific change.
- [`../../checklists/before-pull-request.md`](../../checklists/before-pull-request.md) gates on
  whether tests exist; [`test-review-checklist.md`](test-review-checklist.md) here gates on whether
  they're good.
- [`../../.claude/rules/tests-and-documentation.md`](../../.claude/rules/tests-and-documentation.md)
  states the non-negotiable rule (every behavior change ships with a test that fails without it);
  this folder is the reasoning and detail beneath that rule.
- None of these documents assume a specific language, framework, or test runner — examples use
  illustrative pseudocode, consistent with the rest of this toolkit.
