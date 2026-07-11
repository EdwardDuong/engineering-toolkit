# Rule: Tests and Documentation Ship With the Change

Every behavior change ships with updated tests and updated docs in the same
change set. A change that alters behavior without a test proving it is
unverified. A change that alters behavior without updating the docs that
describe it is a lie waiting to be discovered by the next reader.

"Same change set" means the same commit or pull request — not a follow-up,
not a ticket filed for later. If tests or docs can't be finished in this
change, the change isn't done.

## What counts as a required test update

- New behavior needs a new test that fails without the change and passes
  with it.
- Changed behavior needs its existing test(s) updated to assert the new,
  correct behavior — not deleted, not skipped.
- Bug fixes need a regression test that reproduces the bug and would fail on
  the old code.
- Edge cases and error paths touched by the change need coverage, not just
  the happy path.

Follow [docs/testing/testing-strategy.md](../../docs/testing/testing-strategy.md) for what
level of test (unit, integration, end-to-end) is appropriate for the change,
and confirm you've met the bar in
[docs/definition-of-done.md](../../docs/definition-of-done.md) before
considering the work finished.

## What "updated docs" means concretely

Documentation is not one thing — check each of these for whether the change
touches it:

- **README** — if the change affects setup, usage, configuration, or public
  behavior described in a README, update it.
- **API docs** — if the change adds, removes, or alters a public function
  signature, endpoint, CLI flag, or config option, the reference docs for it
  must reflect the new contract.
- **Inline comments** — add or update a comment only where the *why* is
  non-obvious (a workaround, a non-obvious constraint, a deliberate
  tradeoff). Do not add comments that restate *what* the code does; prefer
  making the code itself clearer instead. Remove comments that are now
  stale or contradict the new behavior — a wrong comment is worse than no
  comment.
- **Architecture/design docs** — if the change alters a documented design
  decision, update the relevant doc or note that it supersedes a prior ADR.

See [docs/documentation-standards.md](../../docs/documentation-standards.md)
for the full standard on tone, structure, and where each kind of
documentation belongs.

## Checking yourself before calling a change complete

Ask, honestly:

- If someone reverted my source change but kept my test change, would the
  test fail? (If not, the test isn't testing the behavior.)
- If someone read only the docs, would they now have an accurate picture of
  the new behavior? (If not, the docs aren't done.)
- Did I update docs and tests in this change, or am I planning to "come back
  to it"? ("Coming back to it" is how documentation debt accumulates —
  treat it as not done.)
