# Release Preparation

Guide an AI assistant through pre-release verification, changelog drafting,
and rollback plan confirmation before a release goes out.

## Purpose

Releases fail when a step gets skipped under time pressure — an
unreviewed dependency change, a changelog that doesn't match what actually
shipped, or a rollback plan that was assumed rather than confirmed. This
prompt walks through verification, communication, and safety-net steps as
one sequence so none of them get silently dropped.

## When to use

- Preparing a release candidate (version bump, deploy, package publish) and
  want a systematic pre-flight check.
- Drafting release notes / a changelog entry from a set of merged changes.
- Confirming a rollback plan exists and is realistic before shipping,
  not after something goes wrong.

## The prompt

```markdown
You are preparing a release. Work through verification, changelog, and
rollback planning in order — do not treat the changelog as the only
deliverable.

## Context
- Release scope (version, what's included): {{release_scope}}
- Changes included since the last release (commit log, merged PRs, or
  ticket list): {{changes_list}}
- Deploy target and mechanism (package registry, container deploy, app
  store, etc.): {{deploy_target}}
- Known risks or areas of concern for this release: {{known_risks}}

## Step 1 — Pre-release verification
Review the set of changes and confirm:
- Every change has passing tests and, where applicable, has been through
  review.
- Any breaking changes are identified and flagged clearly (API changes,
  config changes, schema migrations, removed features).
- Any change requiring an operational step at deploy time (migration,
  feature flag toggle, config update, cache invalidation) is listed
  explicitly with the step required.
- Dependency changes included in this release have been checked for
  known vulnerabilities or breaking changes (see
  [`dependency-upgrade.md`](dependency-upgrade.md) if a major dependency
  bump is involved).

Flag anything that looks unready — do not silently include it in the "safe
to ship" summary.

## Step 2 — Draft the changelog
From the changes list, draft release notes that:
- Group changes by category (Breaking changes, Features, Fixes,
  Deprecations, Internal/Chore — omit empty categories).
- Describe each change from the user's/consumer's perspective (what
  changed for them), not the internal implementation.
- Call out breaking changes first and most prominently, with a migration
  note for anyone upgrading.
- Are accurate — do not include a change that isn't actually in this
  release's scope, and do not omit a breaking change to make the release
  look smaller.

## Step 3 — Confirm the rollback plan
For this specific release, state:
- The exact mechanism to roll back (revert deploy, previous version
  pin, feature flag disable) and how long it takes.
- Whether rollback is safe for *every* change in the release, or whether
  any change (e.g., a completed data migration) makes rollback partial or
  one-way — if so, state what the fallback is for that change
  specifically.
- What to monitor immediately post-release to decide whether a rollback is
  needed (error rates, specific metrics, alerts).

## Step 4 — Final go/no-go summary
Summarize: is this release ready to ship as scoped? List any item from
Steps 1-3 that must be resolved first, separate from items that are
acceptable known risks (with sign-off noted as a placeholder).
```

## Expected output

- A verification pass listing test/review status, breaking changes, and
  required operational steps at deploy time.
- A categorized, consumer-facing changelog draft.
- An explicit rollback plan, including any changes that make rollback
  partial or irreversible.
- A go/no-go summary separating blockers from accepted risks.

## Tips & pitfalls

- Irreversible steps (completed data migrations, deleted data, sent
  notifications) need a fallback plan stated explicitly, not just "we'll
  roll back" — rollback doesn't undo those.
- Don't let the changelog be drafted from commit messages alone if they're
  not user-facing — rewrite from the consumer's perspective.
- Use [`../checklists/before-release.md`](../checklists/before-release.md)
  as the final sign-off gate, and
  [`../templates/release-notes.md`](../templates/release-notes.md) as the
  target format for Step 2's output.
