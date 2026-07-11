# Semantic Versioning

A version number should tell a consumer, without reading a changelog, whether it's safe to upgrade.
Semantic Versioning (SemVer) is the convention this toolkit uses to make that true:
`MAJOR.MINOR.PATCH`.

## The rule

Given a version `MAJOR.MINOR.PATCH`:

- **MAJOR** increments when you make an incompatible/breaking change — something that could break an
  existing consumer without them changing their own code.
- **MINOR** increments when you add functionality in a backward-compatible way — new capability, but
  nothing existing stops working.
- **PATCH** increments when you make a backward-compatible bug fix — behavior gets closer to what
  was documented/intended, nothing that depended on the old (buggy) behavior should break, by
  definition.

Incrementing a more significant number resets the ones to its right: `1.4.9` followed by a breaking
change becomes `2.0.0`, not `2.4.9`.

## What counts as breaking

Breaking is defined from the consumer's point of view, not the implementer's. Ask: **could
reasonable, spec-compliant existing usage stop working because of this change?**

Typically breaking:

- Removing or renaming a public function, endpoint, field, or configuration option.
- Changing a function's required parameters, an endpoint's required request shape, or a message
  schema in an incompatible way.
- Changing the meaning of an existing field or return value (even without changing its type).
- Tightening validation that previously accepted input now rejected.
- Changing default behavior that consumers were reasonably relying on.

Typically not breaking:

- Adding a new optional field, parameter, or endpoint.
- Adding a new enum value, *if* consumers are documented to handle unknown values gracefully (if
  they aren't, this is breaking in practice even though it looks additive).
- Fixing a bug where the old behavior was clearly unintended and undocumented, though judgment is
  required — see the note below.

The undocumented-behavior fix is the most common gray area: if enough consumers have come to depend
on a bug's behavior, fixing it is breaking *in practice* even if it's a PATCH by the letter of the
spec. When that's plausible, treat it as a MAJOR change or ship the fix behind a migration path
rather than a silent PATCH — see
[`../.claude/rules/backward-compatibility.md`](../.claude/rules/backward-compatibility.md) for the
toolkit's stance on this tradeoff.

## Pre-release and build metadata

- **Pre-release**: append a hyphen and identifiers to mark a version as not yet stable —
  `1.5.0-alpha.1`, `1.5.0-rc.2`. Pre-release versions have lower precedence than the associated
  normal version (`1.5.0-rc.1 < 1.5.0`) and are not expected to satisfy compatibility promises;
  consumers pinning to a pre-release are opting into instability.
- **Build metadata**: append a plus and identifiers for build-specific information that doesn't
  affect precedence — `1.5.0+build.42`, `1.5.0+sha.5114f85`. Two versions differing only in build
  metadata are considered equal for ordering purposes; don't rely on it for comparison logic.
- Use pre-release tags for anything shipped to a subset of users for validation before a general
  release — see [`release-process.md`](./release-process.md) for how this fits into staged rollouts.

## Version 0.x.y

`0.x.y` is explicitly exempt from the compatibility promise — anything may change at any time,
including breaking changes in a MINOR or even PATCH bump. This is intentional: it gives a new
component room to find its real API shape before committing to stability. Move to `1.0.0`
deliberately, as a signal to consumers that the public contract is now stable and covered by the
normal MAJOR/MINOR/PATCH guarantees — not automatically after some arbitrary amount of time or
usage.

## How this connects to commit conventions

If commits follow [`conventional-commits.md`](./conventional-commits.md), the next version number
can be derived mechanically instead of guessed at release time:

- Any commit with a `BREAKING CHANGE:` footer or `!` marker since the last release → next version is
  MAJOR.
- Otherwise, any `feat` commit → next version is MINOR.
- Otherwise, any `fix` or `perf` commit → next version is PATCH.
- Otherwise (only `docs`, `chore`, `test`, `style`, `ci`, `refactor`) → no release needed, or a
  PATCH if the team prefers to ship those on their own cadence.

## Declaring breaking changes responsibly

A MAJOR bump is not, by itself, sufficient communication. Pair it with:

- A clear entry in `../templates/release-notes.md` explaining what broke and why.
- A migration path wherever feasible — what a consumer needs to change, ideally with a before/after
  example.
- Advance deprecation warnings in the prior MINOR release when possible, so consumers have notice
  before the MAJOR bump lands rather than being surprised by it. See
  [`api-design-guide.md`](./api-design-guide.md) for how to design and communicate a deprecation
  window.
