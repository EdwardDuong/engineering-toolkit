---
description: Perform a safe, behavior-preserving refactor in small reviewable steps with test coverage established first.
argument-hint: [code/module to refactor and the goal of the refactor]
---

Refactor the following, without changing observable behavior:
$ARGUMENTS

A refactor that changes behavior is not a refactor — it's an untested
rewrite wearing a refactor's name. Follow this process to keep it safe.

## Process

1. **Establish test coverage first.** Before changing any code, check
   whether the code you're about to refactor has adequate test coverage
   (see `docs/testing-strategy.md`). If it doesn't, write characterization
   tests that pin down current behavior *before* touching the
   implementation — you need a way to know if you accidentally changed
   behavior. Run the existing suite to confirm it's green as a baseline.

2. **State the goal.** Be explicit about what this refactor is for
   (readability, removing duplication, enabling an upcoming change,
   reducing complexity) and what it is explicitly not for (no behavior
   changes, no scope creep into "while I'm here" fixes — file those
   separately).

3. **Plan small, reviewable steps.** Break the refactor into a sequence of
   small changes, each of which:
   - Keeps the code in a working, tested state.
   - Is independently reviewable and, ideally, independently revertable.
   - Moves toward the goal without trying to get there in one leap.

   Prefer well-known safe refactoring moves (extract function, rename,
   inline, move, introduce parameter object) applied one at a time over a
   single large rewrite.

4. **Refactor incrementally, verifying at each step.** After each small
   step, run the tests. If a step breaks a test, that's either a bug in the
   refactor (fix it) or a sign the "characterization" test was actually
   testing an implementation detail rather than real behavior (fix the
   test, but be honest about which it is).

5. **Apply the standing rules as you go.** `.claude/rules/readability.md`
   and `.claude/rules/no-unnecessary-abstractions.md` apply directly here —
   a refactor is exactly where over-engineering tends to creep in under the
   banner of "cleaning up."

6. **Verify behavior is unchanged at the end.** Run the full relevant test
   suite once more, and if the change is significant, describe how you'd
   manually verify equivalence (e.g. comparing output on representative
   inputs before/after) even if that verification isn't automated.

7. **Update docs only where they described the internal structure you
   changed** — a pure refactor shouldn't need behavior-facing doc changes,
   but internal architecture notes or comments describing the old structure
   need updating per `.claude/rules/tests-and-documentation.md`.

This command is the operational expansion of
[prompts/refactor-code.md](../../prompts/refactor-code.md) — consult it for
more detail and worked examples of safe refactoring sequences.

Report back the sequence of steps taken and confirmation that tests passed
at each step.
