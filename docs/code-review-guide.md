# Code Review Guide

Code review is the primary place quality gets enforced in a working codebase — not because automated
checks don't matter, but because automated checks can't evaluate whether a design fits the problem.
This doc covers what to look for, how to give feedback, and how to keep review from becoming a
bottleneck.

## What review is for

- Catching correctness issues automated tests missed.
- Verifying the change matches the intent it claims (does it actually solve the ticket, not just
  compile).
- Spreading knowledge of the codebase across the team, so no single person is a bottleneck for a
  given area.
- Enforcing consistency with the principles in this toolkit (naming, boundaries, test coverage)
  before they drift.

Review is not the place to relitigate the overall approach for the first time — that belongs in
[`architecture-review.md`](./architecture-review.md) or an [`rfc-process.md`](./rfc-process.md)
discussion before implementation starts. If a reviewer's first comment on a PR is "why didn't you do
this a completely different way," that's a signal the design conversation happened too late, not a
normal review outcome.

## What reviewers should look for

In rough priority order:

1. **Correctness** — does the code do what it claims, including edge cases and error paths? Is there
   a test that would fail if the logic were wrong?
2. **Contracts and boundaries** — does the change respect the interfaces it touches, or does it
   quietly widen a boundary's assumptions? See
   [`architecture-principles.md`](./architecture-principles.md).
3. **Security** — does it introduce an injection risk, a missing authorization check, a secret in
   source? See [`../checklists/security-review.md`](../checklists/security-review.md) for anything
   security-sensitive.
4. **Test coverage of the actual change** — not a blanket percentage, but: is the new behavior
   verified, and are the failure modes verified? See [`testing-strategy.md`](./testing-strategy.md).
5. **Readability and naming** — can a reader unfamiliar with this specific change follow it? See
   [`clean-code.md`](./clean-code.md).
6. **Scope discipline** — does the PR do one coherent thing, or does it mix an unrelated refactor
   with a feature change, making both harder to review and to revert independently?
7. **Unnecessary complexity** — does the change introduce abstraction, configuration, or flexibility
   beyond what the current requirement needs? See [`yagni-principle.md`](./yagni-principle.md).

Use [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md) as the
author-side counterpart — most of what a reviewer would flag should already be self-checked before
the PR is opened.

## Review etiquette

- **Review the code, not the person.** "This function doesn't handle a null input" not "you forgot
  to handle null inputs." The distinction matters more than it sounds like it should — the second
  phrasing reads as a character judgment even when unintended.
- **Ask questions when you're unsure, don't assert.** "Is there a reason this doesn't use the
  existing retry helper?" invites context you might be missing. "This should use the existing retry
  helper" as a first message assumes you already have the full picture.
- **Explain the why behind a requested change.** "Move this to the boundary layer" is a demand.
  "Move this to the boundary layer — otherwise the validation rule lives in two places and they'll
  drift" is guidance the author can apply to their next PR without being told again.
- **Acknowledge good decisions, not just problems.** A review that's 100% criticism reads as
  adversarial even when every individual comment is fair. Calling out a good test case or a clean
  refactor costs one sentence and keeps review a collaborative process instead of a gate to get
  past.
- **Authors: don't take a request for changes personally, and don't argue defensively.** If a
  comment seems wrong, explain your reasoning once, clearly, and let the reviewer respond — don't
  dismiss it in the same breath you disagree with it.

## Giving actionable feedback

- Every comment should tell the author what to do next, or clearly be a question rather than an
  implicit demand. "This is confusing" is not actionable; "consider extracting this into a named
  function — it's doing three things" is.
- Suggest, when it's fast, rather than just critique — a one-line proposed diff resolves ambiguity
  faster than a paragraph of description.
- Batch comments into one review rather than trickling single comments over hours; a PR author
  re-reading their diff after every new comment can't make progress.

## Blocking vs. non-blocking comments

Mark every comment's severity explicitly so authors don't have to guess what's required to merge:

- **Blocking** — a correctness bug, a security issue, a contract violation, a missing test for new
  behavior. The PR should not merge until this is resolved.
- **Non-blocking / suggestion** — a style preference, a "nice to have" refactor, a question that
  doesn't change correctness. Prefix these clearly (e.g., "Nit:", "Non-blocking:", "Optional:") so
  the author can triage at a glance.

A review with ten comments and no severity markers forces the author to guess which ones gate the
merge, which either causes unnecessary rework or a missed real issue buried among nitpicks. When in
doubt about severity, ask rather than silently blocking or silently letting it through.

## Review SLAs

- **First response time**: a reviewer should give some response — even just "looking, will have
  comments by EOD" — within one business day of being requested. Silence is the most common cause of
  PRs going stale.
- **Full review turnaround**: aim for a complete first pass within one business day for normal-sized
  changes; same-day for urgent fixes.
- **Re-review after changes**: faster than the initial review — the reviewer already has context, so
  re-checking specific changes should take minutes, not another full day.
- Large PRs (multiple unrelated concerns, hundreds of lines mixing refactor and feature) don't get
  an SLA exception — they get sent back for splitting. A reviewer rushing a large PR to meet an SLA
  produces a review in name only.

## Review size discipline

- Small, focused PRs get better review quality — a reviewer can hold the whole change in their head.
  As a rough guide, PRs that meaningfully exceed a few hundred lines of actual logic change
  (excluding generated code, lockfiles, and pure renames) are worth splitting unless the change is
  genuinely atomic (e.g., a single mechanical rename across the codebase).
- If splitting isn't possible for a specific change, say so explicitly in the PR description and
  explain why — this saves the reviewer from repeatedly asking.

See [`../templates/PR_TEMPLATE.md`](../templates/PR_TEMPLATE.md) for the PR description template
that gives reviewers the context they need up front.
