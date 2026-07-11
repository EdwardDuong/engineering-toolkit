# Workflow: Release

This is the end-to-end playbook for cutting a release, from readiness check through the published
changelog. Follow it in order — each step depends on the one before it being genuinely complete,
not assumed complete.

## 1. Walk the before-release checklist first, not last

Start with [checklists/before-release.md](../../checklists/before-release.md) rather than treating
it as a final rubber stamp. Walking it early surfaces blockers (failing tests, unmerged
dependencies, unresolved security findings, missing changelog entries) while there's still time to
address them, instead of discovering them the moment someone wants to cut the release.

## 2. Run a security audit of everything since the last release

Run [`/security-audit`](../commands/security-audit.md) scoped to the full set of changes since the
last release, not just the most recent one — a security-relevant change from three weeks ago that
was individually reviewed can still combine with a more recent change to create a new gap. Treat any
Critical or High finding as a release blocker per
[docs/risk-assessment.md](../../docs/risk-assessment.md); a Medium or Low finding can ship with the
release if it's explicitly tracked, not silently deferred.

## 3. Confirm backward compatibility and documentation currency

Verify backward compatibility of everything since the last release per
[.claude/rules/backward-compatibility.md](../rules/backward-compatibility.md) — every breaking
change must be identified and intentional, not discovered by a consumer after the release ships.
Confirm docs are in sync with the code being released; a release that ships a behavior change with
stale documentation is not actually done per
[docs/definition-of-done.md](../../docs/definition-of-done.md). This step reports a clear go/no-go
— do not proceed past a "no-go" without an explicit decision from the user to accept the known gap.

## 4. Follow the detailed release process

Once steps 1–3 report ready, follow [docs/release-process.md](../../docs/release-process.md) for
the mechanics specific to this project: how versions are bumped, what branches/tags are involved,
how the release artifact is built and validated, and what approvals are required before publishing.
If the release involves an infrastructure or deployment topology change, apply
[agents/devops-engineer.md](../agents/devops-engineer.md)'s judgment on rollout strategy and
rollback readiness before publishing.

## 5. Generate release notes

Use [templates/release-notes.md](../../templates/release-notes.md) as the structure for the
release notes. Populate it from the actual set of changes included in the release — organize by
user-facing impact (new features, fixes, breaking changes, deprecations) rather than by commit
order. Every breaking change identified in step 3 must be called out explicitly here, with
migration guidance, not buried in a generic "misc changes" line.

## 6. Update the changelog

Update `CHANGELOG.md` at the repo root with an entry for this release, consistent with the format
of prior entries. The changelog entry and the release notes should tell a consistent story — the
changelog is the permanent historical record, the release notes are the announcement; they
shouldn't contradict each other.

## 7. Publish and verify

Complete the publish steps defined in [docs/release-process.md](../../docs/release-process.md),
then verify the published artifact/package/deployment actually reflects what was intended (correct
version number, correct contents) rather than assuming the publish step succeeded silently.

## 8. Close the loop

If this release resolves tracked issues, deprecation timelines, or incident follow-ups, update
those records to point at the released version. A release isn't fully done until the people
waiting on it can find out it shipped.
