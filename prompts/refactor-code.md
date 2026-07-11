# Refactor Code

Guide an AI assistant through a safe refactor: verify coverage first, change
structure in small verifiable steps, and preserve observable behavior.

## Purpose

Refactors fail silently when an AI assistant "improves" code and quietly
changes behavior along the way — a fixed edge case, a reordered side effect,
a widened error type. This prompt makes test coverage a precondition, forces
small steps, and requires any behavior change to be surfaced explicitly
rather than folded into the diff.

## When to use

- Cleaning up structure, naming, duplication, or an outdated pattern without
  intending to change behavior.
- Preparing code for an upcoming feature that the current structure makes
  awkward to add.
- Working in a legacy area where you're not fully confident tests would
  catch a regression (pair with [`legacy-code-analysis.md`](legacy-code-analysis.md)
  first).

## The prompt

```markdown
You are refactoring code. The primary constraint is that observable
behavior must not change unless explicitly called out. This is not a
feature change or a bug fix — treat any behavior difference as a defect in
the refactor unless I've asked for it.

## Context
- Code/module to refactor: {{target_code_or_path}}
- Motivation (why refactor now): {{motivation}}
- Known constraints (public API must not change, performance must not
  regress, etc.): {{constraints}}

## Step 1 — Confirm test coverage exists
Before changing any code:
- Identify the existing tests that exercise this code and summarize what
  behavior they lock in.
- Identify any behavior that is *not* currently covered by tests (edge
  cases, error paths, concurrency behavior, etc.).
- If coverage is insufficient to safely refactor, propose the minimal
  characterization tests needed first (see
  [`generate-tests.md`](generate-tests.md) for that step) and add them
  before touching the implementation.

Do not proceed to Step 2 until coverage is confirmed adequate or has been
added.

## Step 2 — Plan the refactor in small steps
Break the refactor into a sequence of small, independently verifiable
steps (e.g., extract function -> rename -> inline -> restructure). For
each step, state:
- What structural change it makes.
- Why it doesn't change behavior (e.g., "pure extraction, no logic
  change").

## Step 3 — Execute one step at a time
For each step:
1. Make the change.
2. Run (or state exactly how to run) the existing tests.
3. Confirm the tests still pass before moving to the next step.
Do not batch multiple structural changes into a single unverified step.

## Step 4 — Flag any behavior changes explicitly
If, during the refactor, you notice a behavior that seems wrong and are
tempted to "fix while you're in there" — stop. List it separately as an
observed issue with a proposed follow-up, but do not fix it as part of this
refactor unless I confirm I want that folded in.

## Step 5 — Summarize
After all steps, summarize:
- What structural changes were made and why.
- Confirmation that all pre-existing tests still pass unmodified (or, if a
  test had to change, an explicit explanation of why that test was testing
  implementation detail rather than behavior).
- Any behavior changes flagged in Step 4, kept separate from the refactor.
```

## Expected output

- A coverage assessment before any code changes.
- A numbered small-step plan, each step behavior-preserving by
  construction.
- Step-by-step diffs with a test-pass confirmation after each.
- A clearly separated list of any observed-but-not-fixed issues.
- A final summary distinguishing "structure changed" from "behavior
  changed" (which should be empty, or explicitly justified).

## Tips & pitfalls

- Never let "refactor" and "fix a bug I noticed" merge into one diff — file
  the bug fix separately using [`investigate-bug.md`](investigate-bug.md).
- If coverage is thin, resist the temptation to skip Step 1 "just this
  once" — that's exactly when silent behavior changes slip through.
- A test that breaks during refactoring is a signal, not noise: it means
  either the refactor changed behavior (bug) or the test was coupled to
  implementation detail (also worth fixing, but as a conscious decision,
  not incidentally).
- For legacy code with unclear or missing contracts, run
  [`legacy-code-analysis.md`](legacy-code-analysis.md) first to establish
  safe seams before refactoring.
