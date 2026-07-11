# API Change Workflow

An API is a promise to callers you frequently can't see and can't coordinate with directly — other
teams, other services, external integrators, a mobile client that won't update for weeks. This
workflow is how an experienced team changes an API without breaking a caller who was reasonably
relying on the contract as it stood. It's the process view of
[`api-design-guide.md`](../api-design-guide.md)'s principles, applied specifically to the moment of
*changing* an existing contract rather than designing a new one.

## Contract Changes

The first step of any API change is classifying it correctly — most disputes about whether a
change is "safe" come from skipping this classification and going straight to intuition.

- **Additive and non-breaking**: a new optional field in a response, a new endpoint, a new optional
  request parameter with a default that reproduces the old behavior. These can ship without a
  version bump or migration coordination, but should still be reviewed for whether they're
  precedent-setting (see [`architecture-review.md`](../architecture-review.md)).
- **Breaking, even when it doesn't look like it**: removing or renaming a field, changing a field's
  type or meaning, tightening validation that previously-valid requests now fail, changing default
  behavior a caller might depend on, changing error codes or error shape, or changing
  timing/ordering guarantees — even ones that were never explicitly documented but that a
  reasonable caller could have relied on. See
  [`../../.claude/rules/backward-compatibility.md`](../../.claude/rules/backward-compatibility.md)
  for the full test: when it's ambiguous whether a change is breaking, treat it as breaking. The
  cost of extra ceremony on a safe change is much lower than the cost of a broken consumer in
  production.
- **State the contract change explicitly before implementing it** — what the old behavior was, what
  the new behavior is, and every consumer (internal service, external integrator, a specific
  client version) that's known to depend on the old behavior. A contract change implemented without
  this list is a contract change that will surprise someone.

## Versioning

Once a change is classified as breaking, versioning is how old and new contracts coexist long
enough for callers to migrate on their own schedule instead of everyone's schedule being forced by
yours.

- Follow [`semantic-versioning.md`](../semantic-versioning.md) for how the change is declared: a
  breaking API change is a MAJOR version change (for a versioned API) or requires an explicit new
  API version path (`/v2/...`) or equivalent versioning mechanism for a networked API where clients
  can't easily pin a dependency version the way a library consumer can.
- **Deprecate before removing, always.** Announce the deprecation (in the API response itself where
  possible — a deprecation header or field — plus documentation and changelog), state the
  replacement clearly enough that a caller can migrate without guessing, and give a deprecation
  window appropriate to how widely the endpoint is used and how quickly its known consumers can
  realistically move. An internal endpoint with two known callers on the same team can deprecate
  fast; a public API with unknown external consumers needs much longer.
- Run both versions simultaneously for the full deprecation window, and monitor actual usage of
  the deprecated version — don't remove it on a calendar date if traffic to it hasn't dropped to
  zero (or to an explicitly accepted residual level) yet. Removing a version that's still receiving
  real traffic converts a planned deprecation into an unplanned outage for whoever was still
  calling it.
- For a security fix that must break a contract immediately (see the
  [Security](#security) section below), the normal deprecation window doesn't apply — but document
  what broke and why as clearly as time allows; urgency doesn't excuse silence.

## Security

Every API change is a change to the system's attack surface, whether or not it looks
security-related on its face — a new field can be a new place for injection, a loosened validation
rule can be a new bypass, a new endpoint can be a new unauthenticated path if the auth check isn't
copied correctly from its neighbors.

- **Re-verify authentication and authorization on every new or changed endpoint explicitly** — don't
  assume a shared middleware or framework default covers it correctly for this specific resource.
  The most common real gap is authorization checked at the "is this user logged in" level but not
  the "is this user allowed to act on *this specific* resource" level. See
  [`../../.claude/agents/security-engineer.md`](../../.claude/agents/security-engineer.md).
- **Validate every new or changed input at the boundary**, regardless of what a client-side check
  already does — see [`../../.claude/rules/security-awareness.md`](../../.claude/rules/security-awareness.md).
  A relaxed validation rule ("we'll accept a wider range of values now") needs the same scrutiny as
  a new endpoint, because it's exactly as much a change to what the system will process.
- **Check what a changed response now exposes.** A field added for one legitimate consumer's
  convenience can inadvertently expose data to every other consumer of the same endpoint who
  wasn't supposed to see it — review response shape changes for exposure, not just for whether
  they're technically additive.
- **Run [`/security-audit`](../../.claude/commands/security-audit.md) before shipping any API
  change that touches authentication, authorization, input handling, or data access** — the
  abbreviated security check inside ordinary review is not a substitute for the dedicated pass on
  a change to the system's actual surface area.

## Coordinating the rollout

A breaking API change is rarely just a code change — it's a coordination problem with whoever
depends on the old contract.

- Identify known consumers before shipping, and give them a concrete migration path (updated docs,
  a code example, a clear timeline) rather than a bare announcement that something is changing.
- For external or loosely-coupled consumers where a full list isn't knowable, rely on the
  versioning and deprecation-window discipline above rather than assuming direct coordination is
  possible — the version coexistence period *is* the coordination mechanism when you can't reach
  every caller directly.
- Track deprecated-version usage as a real, visible metric (see
  [`observability-guide.md`](../observability-guide.md)) so the decision to finally remove it is made
  on evidence, not on a calendar guess.
