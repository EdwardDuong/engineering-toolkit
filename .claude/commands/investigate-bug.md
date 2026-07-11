---
description: Investigate a bug systematically — reproduce, isolate, root-cause, then propose a fix with a regression test.
argument-hint: [bug description, error message, or issue reference]
---

Investigate the following bug. Work through each stage in order — resist the
urge to jump straight to a fix before you've confirmed the actual cause.

**Bug**: $ARGUMENTS

## Process

1. **Reproduce.** Establish a reliable way to trigger the bug before doing
   anything else. If you can't reproduce it, say so explicitly and explain
   what you'd need (logs, environment details, repro steps) to move
   forward — don't guess at a fix for something you haven't observed.

2. **Isolate.** Narrow down the reproduction to the smallest input, code
   path, or condition that triggers it. Bisect if useful (recent commits,
   config changes, data conditions). Rule out red herrings before
   concluding.

3. **Root-cause, not symptom-patch.** Trace the failure to its actual
   origin, not just the line where it surfaces. Follow
   [prompts/root-cause-analysis.md](../../prompts/root-cause-analysis.md)
   and [docs/root-cause-analysis.md](../../docs/root-cause-analysis.md) for
   the method — ask "why" until you reach the actual defect (a wrong
   assumption, a missing validation, a race condition), not just the
   observable failure.

4. **Understand before fixing.** Apply
   `.claude/rules/understand-before-coding.md` to the code around the root
   cause — read it fully, understand its callers, and confirm your fix
   won't just move the bug elsewhere.

5. **Propose a fix.** Implement the smallest correct fix that addresses the
   root cause. Apply `.claude/rules/readability.md` and
   `.claude/rules/no-unnecessary-abstractions.md` — a bug fix is not license
   to redesign the surrounding code beyond what's needed.

6. **Add a regression test.** Per `.claude/rules/tests-and-documentation.md`,
   write a test that reproduces the bug and fails on the old code, then
   passes with your fix. A bug fix without a regression test is not
   considered complete.

7. **Check for the same bug elsewhere.** If the root cause is a pattern
   (e.g. a missing null check, an off-by-one, an unescaped input) rather
   than a one-off mistake, search for the same pattern elsewhere in the
   codebase and flag or fix other occurrences.

8. **Summarize.** State plainly: what the root cause was, why it happened,
   what the fix does, and what the regression test proves.

Report back with the root cause, the fix, and the regression test — not just
"fixed it."
