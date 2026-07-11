---
description: Walk through release preparation end-to-end using the before-release checklist and release-preparation prompt.
argument-hint: [version/release identifier, optional]
---

Prepare the release: $ARGUMENTS

## Process

1. **Walk the release checklist.** Go through
   [checklists/before-release.md](../../checklists/before-release.md) item
   by item against the current state of the codebase — don't summarize from
   memory, actually verify each item (tests passing, changelog updated,
   version bumped, docs current, migrations reviewed, etc.).

2. **Follow the detailed release prompt.** Use
   [prompts/release-preparation.md](../../prompts/release-preparation.md)
   for the full procedure this command expands on, including how to
   validate the release candidate and what sign-offs are expected.

3. **Verify backward compatibility.** Apply
   `.claude/rules/backward-compatibility.md` to everything changed since
   the last release — confirm any breaking change is intentional,
   documented, and follows the deprecation policy in
   [docs/semantic-versioning.md](../../docs/semantic-versioning.md).

4. **Confirm docs and changelog are in sync with the code being released**,
   per `.claude/rules/tests-and-documentation.md` — a release with
   undocumented changes is not ready, regardless of test status.

5. **Surface anything blocking.** If the checklist reveals an unmet item
   (failing test, missing changelog entry, unresolved security finding,
   unreviewed breaking change), stop and report it rather than proceeding
   past it. Releasing with a known gap is a decision for the user to make
   explicitly, not one to make silently on their behalf.

6. **Summarize release readiness.** Report a clear go/no-go: what's
   confirmed ready, what (if anything) is blocking, and what the remaining
   steps are to cut the release.

This command hands off to the release workflow in
[.claude/workflows/release.md](../workflows/release.md) for the full
end-to-end sequence, including changelog and release notes generation.
