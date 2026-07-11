# Rule: Understand Before Coding

Read the surrounding code, its tests, and any relevant docs before modifying
it. Changes made without understanding the existing system are how bugs,
regressions, and duplicated logic get introduced.

## What to read before touching code

- **The code you're changing**, in full — not just the function you intend
  to edit, but its callers, its callees, and the module it lives in.
- **Its existing tests.** Tests document intended behavior more reliably
  than comments do. If a behavior isn't covered by a test, treat that as a
  gap to note, not permission to assume it doesn't matter.
- **Relevant docs.** Check `docs/` for standards that apply
  (architecture, testing, security) and any in-repo documentation for the
  specific area (module READMEs, ADRs, API docs).
- **Recent history.** A quick look at recent commits/blame on the file can
  surface why the code is shaped the way it is — a workaround for a bug, a
  deliberate performance choice, a compatibility constraint.

## How to verify your understanding

Don't treat a read-through as sufficient on its own — confirm it:

- **Trace call sites.** Find every place that calls the function or uses the
  module you're about to change. Understand what each caller expects.
- **Run the existing tests first**, before making any change, to establish a
  known-good baseline. If they don't pass on a clean checkout, that's
  important context to surface before you start, not after.
- **Restate the behavior in your own words** (in your working notes or the
  PR description) — if you can't explain what the code currently does and
  why, you don't understand it well enough to change it safely.
- For anything nontrivial, make the smallest possible change first and
  observe its effect (add a log, run a targeted test, use a debugger) rather
  than reasoning purely from reading.

## When to ask the user vs. proceed with a documented assumption

Ask the user when:

- The requirement itself is ambiguous and reasonable people could implement
  it differently in ways that matter (data retention, security posture,
  user-facing behavior).
- The change would be effectively irreversible if you guessed wrong (schema
  migration, public API, deleting data).
- You've searched and can't find the context you need (no docs, no tests, no
  clear precedent) and guessing wrong would be expensive to unwind.

Proceed with a documented assumption when:

- The ambiguity is small and low-risk, and a reasonable default exists (e.g.
  matching the convention used elsewhere in the same codebase).
- Blocking on an answer would stall trivial progress and the assumption is
  easy to correct later.
- State the assumption explicitly in the PR description or commit message
  so a reviewer can catch it if it's wrong — never bury it silently.

When in doubt, the cost of a clarifying question is almost always lower than
the cost of building on a wrong assumption.
