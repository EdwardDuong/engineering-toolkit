# Legacy Code Analysis

Guide an AI assistant to characterize legacy code before modifying it:
identify implicit contracts, missing test coverage, and safe seams for
change.

## Purpose

Legacy code — code without adequate tests, unclear ownership of intent, or
behavior nobody fully remembers the reason for — is where AI-assisted
changes are riskiest. This prompt applies a characterization-first approach:
understand what the code actually guarantees today (not what it should do)
before touching it, so a change doesn't silently break a behavior something
downstream depends on.

## When to use

- About to modify code with thin or no test coverage and unclear original
  intent.
- Inheriting ownership of a module and need to understand its real
  behavior, not just its documented behavior.
- Planning a refactor or feature addition in an area where "just change
  it and see what breaks" is too risky (production-critical, no staging
  parity, expensive to roll back).

## The prompt

```markdown
You are characterizing legacy code before it gets modified. The goal is to
understand what this code *actually does* today — including behavior that
looks accidental — not what it was probably intended to do. Treat current
behavior as the source of truth until proven otherwise, because callers may
depend on it even if it looks like a bug.

## Context
- Code to characterize: {{code_or_path}}
- Why it's being touched now: {{motivation}}
- What you already know about its history/intent (comments, commit
  history, tribal knowledge): {{known_context}}

## Step 1 — Map implicit contracts
Identify what this code guarantees to its callers, whether documented or
not:
- Inputs it assumes are always valid/present, and what happens if they
  aren't (crash, silent wrong result, defensive handling).
- Side effects beyond the obvious return value (mutation of shared state,
  logging, caching, events emitted).
- Ordering or timing assumptions (must be called after X, assumes
  single-threaded access, assumes idempotency or lack thereof).
- Error handling behavior: what does it actually do on failure today
  (swallow, propagate, retry, partial-apply)? This is often different from
  what a docstring claims.

## Step 2 — Identify callers and dependents
- List what currently calls or depends on this code, directly and (as far
  as can be determined) indirectly.
- For each significant caller, note whether it depends on the code's
  *documented* behavior or on some *incidental* behavior (a specific
  error message string, a particular ordering, a side effect that looks
  unintentional).

## Step 3 — Assess test coverage
- What is currently tested, and what behavior from Step 1 is *not*
  covered by any test?
- Specifically flag: is the "accidental" or surprising behavior identified
  in Step 1 covered by a test, or does it only exist as an assumption in
  someone's head (or in this analysis)?

## Step 4 — Identify safe seams
A "seam" is a point where behavior could be changed, tested, or replaced
without modifying the surrounding code. Identify:
- Existing seams (function boundaries, interfaces, injected dependencies)
  that would let a change be made and verified in isolation.
- Places where no seam exists and one would need to be introduced (e.g.,
  extracting a function, introducing a parameter/interface) purely to make
  the code testable — note this as a prerequisite step, not part of the
  eventual behavior change.

## Step 5 — Recommend a path forward
Given Steps 1-4, recommend:
- What characterization tests should be added first (to lock in current
  behavior, including the "accidental" parts, before anything changes).
- Which seam to use for the intended change.
- Any behavior from Step 1 that looks like a bug and should be flagged to
  a human for a decision (fix it now vs. preserve it vs. fix separately) —
  do not decide this unilaterally.
```

## Expected output

- An implicit-contract inventory: inputs, side effects, ordering
  assumptions, real (not documented) error behavior.
- A caller/dependent map noting reliance on documented vs. incidental
  behavior.
- A coverage gap list, specifically flagging untested surprising behavior.
- Identified seams, and any seam that needs to be introduced first.
- A recommended path forward, with any suspected bugs surfaced for a human
  decision rather than silently fixed.

## Tips & pitfalls

- Resist the urge to have the assistant "fix" surprising behavior during
  this step — characterization is about understanding, not judging;
  decisions about what to preserve vs. fix belong to a human with context.
- Incidental behavior that callers depend on (a specific error string, a
  particular ordering) is a legitimate part of the contract until it's
  deliberately changed — don't let it get classified as "just a bug."
- Once characterization is done, hand off to
  [`generate-tests.md`](generate-tests.md) to lock in the identified
  contract, then [`refactor-code.md`](refactor-code.md) or
  [`implement-feature.md`](implement-feature.md) for the actual change.
- See [`../docs/technical-debt.md`](../docs/technical-debt.md) for how
  this fits into the broader approach to legacy and debt-laden code in
  this toolkit.
