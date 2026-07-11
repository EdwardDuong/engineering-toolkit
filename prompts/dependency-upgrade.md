# Dependency Upgrade

Guide an AI assistant through evaluating and performing a dependency
upgrade: changelog/breaking-change review, blast-radius assessment, and
staged rollout.

## Purpose

Dependency upgrades range from trivial patch bumps to changes that ripple
through an entire codebase. This prompt requires the assistant to actually
read what changed (not assume semver compliance), map what in the codebase
is affected, and stage the rollout — instead of bumping a version number and
hoping the test suite catches everything.

## When to use

- Upgrading a major or minor version of a library/framework with a
  non-trivial changelog.
- Responding to a security advisory that requires an upgrade.
- Batch-upgrading multiple dependencies and needing a way to evaluate risk
  per-dependency rather than all-at-once.

## The prompt

```markdown
You are evaluating and performing a dependency upgrade. Do not assume
semantic versioning guarantees are honored — verify against the actual
changelog/release notes and, where it matters, the actual diff.

## Context
- Dependency: {{dependency_name}}
- Current version: {{current_version}}
- Target version: {{target_version}}
- Reason for upgrading (routine, security advisory, needed for a new
  feature, forced by another dependency): {{upgrade_reason}}
- How this dependency is used in the codebase (core to many modules,
  isolated to one area, dev-only): {{usage_context}}

## Step 1 — Review what changed
- Read the changelog/release notes for every version between current and
  target, not just the target version's notes — intermediate breaking
  changes are easy to miss when jumping multiple versions.
- Identify: breaking changes, deprecations (things that still work now but
  will break in a future version), security fixes, and behavior changes
  that aren't strictly "breaking" per semver but could still affect this
  codebase (changed defaults, changed error types/messages, performance
  characteristics).
- If release notes are sparse or missing, note that explicitly as
  increased risk and consider diffing the source directly for the
  affected surface.

## Step 2 — Assess blast radius
- Search the codebase for every usage of this dependency's API surface
  that touches something identified as changed in Step 1.
- For each affected usage, state whether it needs a code change to remain
  correct, or is unaffected.
- Check transitive impact: does this dependency's upgrade force or
  conflict with versions of other dependencies (peer dependencies, lock
  file conflicts)?
- Estimate overall blast radius: isolated (one module), moderate (a few
  call sites across modules), or broad (widely used core dependency,
  changes ripple through most of the codebase).

## Step 3 — Plan the upgrade
Based on blast radius:
- **Isolated/moderate**: propose the direct code changes needed alongside
  the version bump, in one reviewable change.
- **Broad**: propose a staged plan — e.g., upgrade behind a flag/adapter
  first, migrate call sites incrementally, remove the old path last. State
  the stages explicitly rather than proposing one massive diff.
- For a security-driven upgrade with breaking changes: assess whether a
  minimal-diff patch/backport is available as a faster mitigation while the
  full upgrade is staged separately.

## Step 4 — Update and verify
- Apply the version bump and any required code changes identified in Step
  2.
- Run the full test suite and specifically exercise the areas flagged as
  affected in Step 2, not just a general test pass.
- Check for new deprecation warnings introduced by the upgrade (even if
  tests pass, deprecation warnings indicate future work needed).

## Step 5 — Summarize
State: what changed, what code was updated as a result, what was verified,
any deprecations now present that should be tracked as follow-up work, and
the recommended rollout approach (immediate, staged, canary) given the
blast radius assessed in Step 2.
```

## Expected output

- A changelog-derived list of breaking changes, deprecations, and
  relevant behavior changes across the full version range.
- A blast-radius assessment tied to actual codebase usages, not a generic
  guess.
- A staged plan when blast radius is broad, a direct plan when it's
  narrow.
- Verification results targeted at the affected areas, plus a summary of
  new deprecation warnings.

## Tips & pitfalls

- Never trust "should be a safe upgrade, it's semver-minor" without
  actually reading the notes — many ecosystems don't enforce semver
  strictly, and "minor" upgrades break things regularly in practice.
- Deprecation warnings that appear after an upgrade are easy to ignore
  because nothing fails today — track them as follow-up work rather than
  letting them accumulate silently.
- For a dependency with broad blast radius, resist bundling the upgrade
  with unrelated changes in the same PR — it makes a regression much
  harder to bisect.
- See [`../docs/dependency-management.md`](../docs/dependency-management.md)
  for this repo's policy on update cadence, lock file discipline, and
  vulnerability response SLAs.
