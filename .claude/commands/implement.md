---
description: Implement an approved plan or well-scoped change, enforcing clean code, tests, and documentation as part of the same change set — not as follow-up work.
argument-hint: [feature or fix description, or reference to a /plan output]
---

Implement the following, enforcing the three things that separate a finished
change from a change that merely compiles: clean code, tests, and
documentation. None of the three is optional, and none is deferred to a
follow-up ticket.

**Change**: $ARGUMENTS

## Process

1. **Confirm there's a plan.** If this change is larger than a small,
   contained fix and no plan exists yet, stop and run
   [`/plan`](plan.md) first — implementing against an unstated plan is how
   scope drifts silently. For a genuinely small change, proceed, but still
   state the approach in one or two sentences before touching code.

2. **Understand the code you're changing.** Apply
   [`../rules/understand-before-coding.md`](../rules/understand-before-coding.md)
   — read the surrounding code, its existing tests, and any relevant doc in
   `docs/` before modifying anything. Run the existing tests to establish a
   passing baseline before you change behavior, so a later failure is
   attributable to your change, not pre-existing breakage.

3. **Check for existing logic before writing new logic.** Apply
   [`../rules/no-duplicated-logic.md`](../rules/no-duplicated-logic.md) —
   search for an existing implementation, utility, or pattern that already
   solves this or part of this before writing a new one.

4. **Implement in small, ordered steps.** Follow the sequencing from
   `/plan` if one exists: data/interface changes first, then core logic,
   then integration/wiring, then edge cases and error handling. After each
   step, the codebase should be in a state you could stop at without leaving
   something broken.
   - **Clean code.** Apply [`../rules/readability.md`](../rules/readability.md)
     — prefer the boring, obvious implementation. Match existing patterns in
     the file and module; if you introduce a new pattern, state why (see
     [`../rules/explain-tradeoffs.md`](../rules/explain-tradeoffs.md)).
   - **No unnecessary abstraction.** Apply
     [`../rules/no-unnecessary-abstractions.md`](../rules/no-unnecessary-abstractions.md)
     — build the smallest correct thing for the requirement in front of you,
     not a generalized version of it.
   - **If this touches existing code that needs restructuring first**,
     refactor in a separate, clearly-labeled step with test coverage
     confirmed before you start — never mix a refactor and a behavior change
     in the same unreviewable step. See
     [`../../prompts/refactor-code.md`](../../prompts/refactor-code.md) for
     the full refactoring discipline if the restructuring is nontrivial.
   - **Security and performance are not an afterthought.** Apply
     [`../rules/security-awareness.md`](../rules/security-awareness.md) and
     [`../rules/performance-awareness.md`](../rules/performance-awareness.md)
     as you write each step, not as a pass at the end. If the change touches
     auth, input handling, secrets, dependencies, or data access, plan to run
     [`/security-audit`](security-audit.md) before this is done.
   - **Apply the relevant specialist lens** from `../agents/` for the domain
     you're touching — `backend-engineer.md`, `frontend-engineer.md`,
     `database-engineer.md`, or `devops-engineer.md` — and check the
     change against that agent's "Common Mistakes to Avoid" section before
     moving on.

5. **Tests.** Apply
   [`../rules/tests-and-documentation.md`](../rules/tests-and-documentation.md).
   Every behavior change ships with a test that fails without the change and
   passes with it — not just a test that happens to pass. Cover the edge
   cases and error paths identified during planning, not only the happy
   path. Use [`/test`](test.md) if you need to reason through what level
   (unit, integration, end-to-end) each case belongs at. Run the full
   relevant suite, not just the new tests, before calling this step done.

6. **Documentation.** Update the README, API docs, and any doc in `docs/`
   whose guidance this change affects, in the same change set. Add inline
   comments only where the *why* is non-obvious — well-named code already
   says what it does. A change that leaves a doc inaccurate is not finished.

7. **State tradeoffs.** For any nontrivial decision made along the way that
   wasn't already covered by the plan, document the alternatives considered
   and why this one was chosen — this becomes part of the change's
   description, not a private mental note.

8. **Self-review before presenting as done.** Walk
   [`../../checklists/before-pull-request.md`](../../checklists/before-pull-request.md)
   against the diff as if you were the reviewer, then run
   [`/review`](review.md) for a second, structured pass. Fix anything either
   surfaces before calling this complete — "done" means it would survive
   review, not that it compiles.
