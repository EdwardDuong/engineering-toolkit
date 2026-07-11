---
description: Review a diff or pull request against the code-review guide and before-merge checklist.
argument-hint: [PR number, branch name, or diff to review]
---

Review the following change: $ARGUMENTS

If a PR number or branch is given, fetch the actual diff rather than relying
on the description alone. Review the diff as a critical, senior reviewer
would — the goal is to catch real problems, not to rubber-stamp.

## Process

1. **Understand the change's intent** before critiquing it. Read the PR
   description / commit messages to understand what problem it's solving,
   then verify the diff actually solves that problem.

2. **Review against the standard.** Apply
   [docs/code-review-guide.md](../../docs/code-review-guide.md) systematically —
   correctness, readability, test coverage, security, performance,
   and consistency with existing patterns. Don't skim; read every changed
   line with intent.

3. **Cross-check against the rules.** Specifically look for violations of:
   - `.claude/rules/no-unnecessary-abstractions.md` — new interfaces/config
     with only one real use.
   - `.claude/rules/no-duplicated-logic.md` — logic that already exists
     elsewhere in the codebase.
   - `.claude/rules/tests-and-documentation.md` — behavior changes without
     matching test or doc updates.
   - `.claude/rules/security-awareness.md` — untrusted input handled
     unsafely, hardcoded secrets, missing authorization checks.
   - `.claude/rules/backward-compatibility.md` — breaking changes to public
     interfaces without deprecation.
   - `.claude/rules/explain-tradeoffs.md` — nontrivial decisions made
     without stated rationale.

4. **Walk the merge checklist.** Go through
   [checklists/before-merge.md](../../checklists/before-merge.md) against
   this change and call out anything unmet.

5. **Classify findings.** Separate feedback into:
   - **Blocking** — correctness bugs, security issues, missing tests for
     new behavior, breaking changes without a migration path.
   - **Should fix** — readability, minor design concerns, missed edge
     cases.
   - **Optional / nitpick** — style preferences, naming suggestions.

6. **Be specific.** For each finding, cite the file and line, explain the
   problem, and suggest a concrete fix or ask a concrete question — not
   "this could be better."

This command is the operational expansion of
[prompts/review-pull-request.md](../../prompts/review-pull-request.md) —
consult it for more detail on tone and depth expected of the review.

Report back a structured review: blocking issues first, then should-fix,
then optional, then an overall verdict (approve / approve with comments /
request changes).
