# Clean Code

Clean code is code that costs the next reader the least amount of effort to understand correctly.
"Next reader" includes you, six months from now, with no memory of why you wrote it this way.

## Naming

- Names should answer *what* and *why*, not *how*. `activeUserCount` is better than `count2`; a name
  describing the underlying data structure (`userList`) is worse than one describing its role
  (`pendingApprovals`), because the role survives a refactor from list to set and the type-based
  name doesn't.
- Prefer precise, slightly longer names over short, ambiguous ones inside anything with meaningful
  scope. Short names (`i`, `j`, `n`) are fine in a five-line loop and actively harmful in a
  fifty-line function.
- Booleans should read as predicates: `isValid`, `hasPermission`, `canRetry`. A boolean named
  `status` or `flag` forces every caller to go read the definition.
- Avoid names that lie. A function called `getUser` that also creates a user record on cache miss is
  a name that will mislead every future caller. Rename it or split it.
- Consistency beats personal preference. If the codebase uses `fetchX` for I/O-bound reads, don't
  introduce `retrieveY` in a new module for the same concept.

## Functions

- A function should do one thing at one level of abstraction. If you need the word "and" to describe
  what it does ("validates and saves and notifies"), it's three functions wearing a trenchcoat.
- Keep argument lists short. More than three or four parameters is usually a sign that a related
  group of values wants to be a single structured argument.
- Prefer returning values over mutating arguments passed in. Output via mutation is invisible at the
  call site and a common source of subtle bugs when the caller doesn't realize their data changed
  underneath them.
- Guard clauses over nested conditionals. Handle the exceptional/early-exit cases first and return,
  so the main logic isn't indented three levels deep inside an `if`.
- Function length is a symptom, not the disease. A 40-line function that does one coherent thing at
  one level of abstraction is fine. A 10-line function that mixes I/O, business logic, and
  formatting is not clean just because it's short.

## Comments: only explain the non-obvious why

The default should be that code explains itself through naming and structure. A comment is a signal
that the code alone could not carry the explanation — treat every comment as evidence you might want
to refactor instead.

- Do not comment *what* the code does if the code already says so. `// increment counter` above
  `counter++` is noise; it will drift out of sync with the code and add nothing when it doesn't.
- Do comment *why* when the reasoning is not recoverable from the code itself: a workaround for a
  specific bug in a dependency, a non-obvious ordering requirement, a business rule that looks like
  a mistake but isn't, a performance-motivated choice that trades away the "obvious" implementation.
- A comment justifying a decision should say enough that a future engineer doesn't "fix" the
  workaround back into the bug it was avoiding. Link to an issue, ADR, or incident if the context is
  long — see [`adr-guide.md`](./adr-guide.md).
- Delete comments that describe old behavior. A stale comment is worse than no comment, because it
  actively misdirects.
- TODO comments are allowed only if they reference an owner and a tracked issue. An unowned `//
  TODO: fix this later` is permanent clutter — nobody is accountable for it and it will outlive the
  person who wrote it.

## Formatting consistency

- Formatting is a solved problem: pick an automated formatter and linter, run it in CI, and never
  debate whitespace in review again. See `../.editorconfig` for the baseline formatting contract
  this toolkit assumes (indentation, line endings, charset) — every editor should honor it
  automatically.
- Consistency matters more than any individual formatting preference. A codebase with one imperfect
  style applied uniformly is easier to read than one with two "correct" styles mixed.
- Structural formatting (file layout, import ordering, where tests live relative to source) should
  also be consistent and, where possible, enforced by tooling rather than review comments.

## Code smells checklist

Use this during self-review before opening a pull request (see
[`../checklists/before-commit.md`](../checklists/before-commit.md)):

- **Long parameter lists** — more than 3–4 arguments; consider a structured argument or splitting
  the function.
- **Feature envy** — a function that reaches into another module's data more than its own; the logic
  probably belongs there instead.
- **Shotgun surgery** — a single conceptual change requires editing many unrelated files; usually a
  sign of missing abstraction or a concern spread across too many places.
- **God objects/modules** — a component that knows about or controls too much of the system; split
  along the separation-of-concerns lines in
  [`architecture-principles.md`](./architecture-principles.md).
- **Primitive obsession** — passing raw strings/numbers everywhere a domain concept (money, an email
  address, a duration) is meant instead of a type that enforces its own invariants.
- **Duplicate logic with drift** — the same rule implemented twice, already slightly inconsistent;
  see [`dry-principle.md`](./dry-principle.md).
- **Dead code** — unreachable branches, unused parameters, commented-out blocks kept "just in case."
  Delete it; version control remembers it for you.
- **Speculative generality** — configuration, strategy patterns, or plugin points built for a
  variation that doesn't exist yet; see [`yagni-principle.md`](./yagni-principle.md).
- **Deep nesting** — more than 2–3 levels of nested conditionals or loops; usually resolved with
  guard clauses or extracted functions.
- **Mixed levels of abstraction** — a function that manipulates raw bytes on one line and calls a
  high-level business function on the next; hard to skim because the reader can't hold one mental
  model of it.
