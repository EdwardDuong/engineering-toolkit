# Prompts

Copy-pasteable AI prompt templates for common engineering tasks. Each file
is a structured prompt you feed to an AI coding assistant (Claude Code,
Cursor, GitHub Copilot, or any other) alongside the relevant code/context —
not a script that runs, a piece of text that shapes how the assistant works
with you.

## How to use these

1. Open the prompt file for your task.
2. Copy the fenced prompt block.
3. Fill in every `{{placeholder}}` with specifics — a prompt with unfilled
   placeholders produces vague, generic output. The more concrete the
   fill-in, the more useful the response.
4. Paste the filled-in prompt into your AI assistant, alongside whatever
   file context, diffs, logs, or docs the prompt asks for.
5. Treat the assistant's output as a draft from a capable but
   context-limited collaborator: read it, push back where it's wrong or
   shallow, and iterate. These prompts are designed to make the assistant
   show its reasoning at each step so you can catch a wrong turn early
   rather than after a finished (and wrong) deliverable.

Each prompt file also documents the expected output shape and common
pitfalls specific to that task — read those sections before using the
prompt for the first time.

## Building

Prompts for writing new code or changing existing code.

- [`implement-feature.md`](implement-feature.md) — clarify requirements,
  propose an approach, then implement incrementally with tests and docs.
- [`refactor-code.md`](refactor-code.md) — restructure code safely in
  small, verifiable steps without changing behavior.
- [`generate-tests.md`](generate-tests.md) — generate tests that cover
  happy paths, edge cases, and error paths without testing implementation
  details.
- [`documentation-generation.md`](documentation-generation.md) — generate
  or update docs (API references, READMEs, runbooks) that stay accurate
  and non-redundant.

## Investigating

Prompts for understanding code or failures before acting on them.

- [`investigate-bug.md`](investigate-bug.md) — reproduce, gather evidence,
  and isolate a root cause before proposing a fix.
- [`root-cause-analysis.md`](root-cause-analysis.md) — blameless 5-Whys and
  contributing-factor analysis for an incident or defect, structured for a
  postmortem.
- [`code-explanation.md`](code-explanation.md) — explain unfamiliar code to
  a specific audience, covering purpose, data flow, and gotchas.
- [`legacy-code-analysis.md`](legacy-code-analysis.md) — characterize
  legacy code before modifying it: implicit contracts, missing coverage,
  safe seams for change.
- [`performance-optimization.md`](performance-optimization.md) —
  profiling-first performance investigation: baseline, evidenced
  bottleneck, then a targeted fix.

## Reviewing

Prompts for structured, AI-assisted review of code and designs.

- [`review-pull-request.md`](review-pull-request.md) — structured PR
  review across correctness, readability, tests, security, performance,
  and documentation.
- [`architecture-review.md`](architecture-review.md) — review a design/RFC/
  ADR for soundness, scalability, failure modes, and alternatives
  considered.
- [`security-review.md`](security-review.md) — review code or a design for
  security issues mapped to OWASP-style categories.
- [`database-review.md`](database-review.md) — review a schema change,
  migration, or query for backward compatibility, locking behavior, and
  indexing.

## Operating

Prompts for shipping, upgrading, and evolving systems safely over time.

- [`release-preparation.md`](release-preparation.md) — pre-release
  verification, changelog drafting, and rollback plan confirmation.
- [`migration-planning.md`](migration-planning.md) — plan a data,
  platform, or framework migration with phased rollout, rollback points,
  and verification gates.
- [`dependency-upgrade.md`](dependency-upgrade.md) — evaluate and perform
  a dependency upgrade: changelog review, blast-radius assessment, staged
  rollout.

## Related

- [`../checklists/`](../checklists/) — pass/fail gates to run before or
  after using these prompts (e.g., before coding, before a PR, before a
  release).
- [`../docs/`](../docs/) — the underlying engineering guides these prompts
  reference for standards and rationale.
- [`../templates/`](../templates/) — fill-in-the-blank output formats
  (ADR, PR description, runbook, postmortem) that several of these prompts
  feed into.
