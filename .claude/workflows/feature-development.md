# Workflow: Feature Development

This is the end-to-end playbook for taking a feature from request to merged
change. It chains together the rules, commands, and checklists that each
cover one part of the journey — follow it as a narrative, not just a
checklist of links, and adapt the depth of each step to the size of the
feature.

## 1. Confirm the feature is ready to start

Before any design or code, walk
[docs/definition-of-ready.md](../../docs/definition-of-ready.md) against the
request. A feature is not ready just because someone asked for it — it's
ready when the acceptance criteria are clear, dependencies are known, and
there's enough context to design against. If it isn't ready, the right move
is to close the gap (ask clarifying questions, pin down scope) before
writing a line of code. Starting on an under-specified feature just moves
the ambiguity from "a conversation now" to "a rewrite later."

## 2. Think through the architecture before implementing

Apply [.claude/rules/architecture-first.md](../rules/architecture-first.md).
For anything beyond a trivial addition, work out the data flow, the
components touched, and the shape of any new interface before writing
implementation code. If the feature introduces a new subsystem, changes a
data model, or has multiple viable approaches with real tradeoffs, write a
short design note from [templates/adr.md](../../templates/adr.md) — reviewed
before implementation starts, not after. For a small, well-contained
feature, a sentence or two in the PR description is enough; don't manufacture
ceremony the change doesn't need.

## 3. Implement using the implement-feature command

Run `/implement-feature` (defined in
[.claude/commands/implement-feature.md](../commands/implement-feature.md))
with the feature description. That command carries you through
understanding the existing code, checking for logic to reuse, implementing
with the readability and no-unnecessary-abstractions rules applied, and
writing the first pass of tests and docs inline as part of implementation —
don't treat tests and docs as a separate phase tacked on at the end.

## 4. Fill any test gaps with generate-tests

Once the implementation is functionally complete, run `/generate-tests`
(defined in
[.claude/commands/generate-tests.md](../commands/generate-tests.md))
against the new code to catch edge cases and error paths that weren't
covered during implementation. Cross-check against
[docs/testing-strategy.md](../../docs/testing-strategy.md) for the coverage
bar this project expects for the kind of code you wrote (unit vs.
integration vs. end-to-end).

## 5. Self-review with review-pr before requesting human review

Run `/review-pr` (defined in
[.claude/commands/review-pr.md](../commands/review-pr.md)) against your own
diff before asking anyone else to look at it. Treat every blocking finding
as something to fix now — sending a diff to a human reviewer that you
haven't reviewed yourself wastes their time on issues you could have caught.

## 6. Walk the pull request checklist

Before opening the PR, walk
[checklists/before-pull-request.md](../../checklists/before-pull-request.md)
in full. This covers the mechanics self-review can miss: PR description
quality, commit hygiene, CI status, linked issues.

## 7. Address review feedback and walk the merge checklist

Once a human reviewer weighs in, address the feedback — and if you disagree
with a piece of it, explain your reasoning rather than silently overriding
it (see [.claude/rules/explain-tradeoffs.md](../rules/explain-tradeoffs.md)).
Before merging, walk
[checklists/before-merge.md](../../checklists/before-merge.md) to confirm
CI is green, required approvals are in, and nothing was left unresolved in
the review thread.

## When to shortcut this workflow

A one-line fix or trivial change doesn't need every step here in full force
— the definition-of-ready check might be a single mental confirmation, and
the design step might be skipped entirely. What should never be skipped
regardless of size: tests for the actual behavior change, and a self-review
pass before asking for human review time.
