# Rule: No Duplicated Logic

Search for existing implementations before writing new logic. Reimplementing
something that already exists elsewhere in the codebase — often slightly
differently — is one of the most common sources of drift, inconsistent
behavior, and hard-to-find bugs.

## Before writing new logic

- Search the codebase for existing functions, modules, or utilities that
  already do what you're about to write, or something close to it. Search by
  behavior ("parse a date range"), not just by the exact name you'd give it.
- Check adjacent modules and shared/common/util directories, which are where
  this kind of logic tends to accumulate.
- If you find something close but not exact, prefer extending or
  parameterizing the existing implementation over forking it — provided the
  extension doesn't itself become a premature abstraction (see
  [no-unnecessary-abstractions.md](no-unnecessary-abstractions.md)).
- If you deliberately decide not to reuse an existing implementation, say
  why in the PR description. "I didn't reuse X because Y" is one sentence
  and saves a reviewer from having to ask.

## When duplication is acceptable

Not all duplication is debt. It's a reasonable, sometimes correct, choice
when:

- **Decoupling bounded contexts.** Two services or modules that should be
  able to evolve independently (different teams, different deploy
  cadences, different domain meaning of "the same" data) are often better
  off with their own copy than a shared dependency that couples their
  release cycles.
- **The similarity is coincidental, not essential.** Two pieces of logic
  that look alike today but represent different concepts (e.g. two
  different domain objects that happen to both have a `name` and `status`
  field) will diverge as the domains evolve. Sharing code here creates a
  false coupling.
- **The shared abstraction would need conditionals to serve both callers.**
  If "reusing" the logic means adding `if caller == X` branches, that's not
  reuse — it's a merged implementation pretending to be one thing. Prefer
  two clear implementations over one branchy one.

## When duplication is technical debt

Duplication is a liability, not a stylistic choice, when:

- The duplicated logic encodes a business rule, calculation, or validation
  that must stay consistent (e.g. pricing, permission checks, data
  validation). Two copies will drift, and the drift is a bug waiting to be
  found by a user, not a test.
- The duplication exists only because the original implementation wasn't
  discovered, not because of a deliberate decoupling decision.
- The duplicated code is already showing signs of divergence (one copy got a
  bug fix the other didn't).

When you knowingly leave duplication behind for decoupling reasons, note it
briefly (comment or PR description) so it isn't mistaken for an oversight
later. When you find duplication that is technical debt but out of scope for
your current change, record it — see
[docs/technical-debt.md](../../docs/technical-debt.md) for how to log it
rather than silently ignoring it.

See [docs/dry-principle.md](../../docs/dry-principle.md) for the fuller
treatment of don't-repeat-yourself and its limits.
