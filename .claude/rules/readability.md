# Rule: Readability Over Cleverness

Prefer readable, boring code over clever code. Code is read far more often
than it is written, usually by someone (including future-you) who doesn't
have the context you had when you wrote it. Optimize for that reader.

"Clever" here means: relies on a non-obvious language trick, packs several
operations into one expression to be terse, or requires the reader to hold
several layers of indirection in their head to understand what happens at
runtime. None of that is inherently wrong, but it has to earn its keep —
and usually the boring version is just as fast to write and much cheaper to
maintain.

## Naming

- Names should say what a thing *is* or *does*, not how it's implemented.
  `activeUsers`, not `list1` or `filteredData`.
- Prefer a longer, precise name over a short, ambiguous one. `retryCount`
  beats `n`. Exceptions: well-established idioms (`i` in a tight loop, `err`
  for an error) are fine because they're unambiguous in context.
  - Avoid names that lie or go stale — a variable called `pendingOrders`
  that also includes cancelled ones will mislead the next reader.
- Booleans read as a yes/no question: `isValid`, `hasPermission`,
  `canRetry` — not `valid`, `check`, `flag`.

## Function size and shape

- A function should do one thing at one level of abstraction. If you need
  "and" to describe what it does, it's a candidate to split.
- Prefer several small, named functions over one long function with section
  comments dividing it into phases — the names replace the comments and are
  independently testable.
- No hard line-count rule, but if a function no longer fits on one screen,
  that's a prompt to look for a natural seam, not a hard requirement to
  split.

## Cyclomatic complexity

- Watch nesting depth as a proxy for complexity: more than 2–3 levels of
  nested conditionals/loops is a signal to extract a function or invert a
  condition with an early return.
- Prefer guard clauses / early returns over deeply nested `if`s.
- A function with many branches handling genuinely distinct cases is
  sometimes irreducibly complex (e.g. a state machine transition table) —
  in that case, make the branching structure as flat and explicit as
  possible (a lookup table, a switch) rather than nested conditionals.

## Practical check

Before finishing a change, reread the diff as if you were a teammate seeing
it for the first time with none of the context you have now. If any line
makes you pause to work out what it does, either simplify it or add a
comment explaining the *why* it's shaped that way (see
[tests-and-documentation.md](tests-and-documentation.md) for comment
guidance).

See [docs/clean-code.md](../../docs/clean-code.md) for the fuller treatment
of these principles with more examples.
