---
description: Implement a feature end-to-end, from requirements check through self-review, following engineering-toolkit norms.
argument-hint: [feature description or ticket reference]
---

Implement the following feature end-to-end, following the process below.
Don't skip steps to save time — each one exists because skipping it is how
half-finished features ship.

**Feature**: $ARGUMENTS

## Process

1. **Understand the requirement.** Restate what's being asked in your own
   words, including what's explicitly out of scope. If the request is
   ambiguous in a way that matters (see
   `.claude/rules/understand-before-coding.md` for the ask-vs-assume
   guidance), ask before proceeding.

2. **Check readiness.** Walk `docs/definition-of-ready.md` against this
   feature. If it isn't ready (missing acceptance criteria, unresolved
   dependency, unclear scope), say so and either resolve the gap or flag it
   before writing code.

3. **Design before implementing.** Apply
   `.claude/rules/architecture-first.md` — size the design effort to the
   change. For anything beyond a trivial change, sketch the approach (data
   flow, components touched, new interfaces) before writing implementation
   code. Write a design note using `templates/adr.md` if the change
   warrants one.

4. **Understand the existing code.** Apply
   `.claude/rules/understand-before-coding.md` — read the surrounding code,
   its tests, and relevant docs before modifying anything. Run existing
   tests to establish a baseline.

5. **Check for existing logic.** Apply
   `.claude/rules/no-duplicated-logic.md` — search for an existing
   implementation before writing new logic.

6. **Implement.** Write the smallest correct implementation of the design
   from step 3. Apply `.claude/rules/no-unnecessary-abstractions.md` (don't
   build for hypothetical future cases) and
   `.claude/rules/readability.md` (prefer clear, boring code). Apply
   `.claude/rules/security-awareness.md` and
   `.claude/rules/performance-awareness.md` as you go, not as an afterthought.

7. **Test.** Add or update tests per `.claude/rules/tests-and-documentation.md`
   and `docs/testing-strategy.md`. New behavior needs a new test that fails
   without your change. Run the full relevant test suite, not just the new
   tests.

8. **Update docs.** Update README, API docs, and any affected doc per
   `.claude/rules/tests-and-documentation.md`. Add inline comments only
   where the *why* is non-obvious.

9. **State tradeoffs.** If you made any nontrivial decision along the way,
   document the alternatives considered per
   `.claude/rules/explain-tradeoffs.md`, in the PR description.

10. **Self-review.** Before presenting the change as done, walk
    `checklists/before-pull-request.md` against your own diff as if you were
    the reviewer. Fix anything it surfaces before calling this complete.

This command is the operational expansion of
[prompts/implement-feature.md](../../prompts/implement-feature.md) — consult
that file for the fuller prompt this is derived from if you need more detail
on any step.
