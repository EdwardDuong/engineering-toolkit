# Workflow: Feature Development

This is the end-to-end playbook for taking a feature from request to merged change. It chains
together the rules, commands, and agent personas that each cover one part of the journey — follow
it as a narrative, not just a checklist of links, and adapt the depth of each step to the size of
the feature.

## 1. Confirm the feature is ready to start

Before any design or code, walk [docs/definition-of-ready.md](../../docs/definition-of-ready.md)
against the request. A feature is not ready just because someone asked for it — it's ready when
the acceptance criteria are clear, dependencies are known, and there's enough context to design
against. If it isn't ready, the right move is to close the gap (ask clarifying questions, pin down
scope) before writing a line of code. Starting on an under-specified feature just moves the
ambiguity from "a conversation now" to "a rewrite later."

## 2. Plan before implementing

Run [`/plan`](../commands/plan.md) with the feature description. This produces the requirements,
assumptions, architecture impact, implementation steps, and risks in one reviewable document —
don't skip straight to code with the plan only in your head. If the architecture-impact step
identifies a new system boundary, a significant dependency, or a one-way-door decision, apply the
judgment in [agents/architect.md](../agents/architect.md) and write a design note from
[templates/ADR.md](../../templates/ADR.md), reviewed before implementation starts. For a small,
well-contained feature, the plan can be brief — a sentence of requirements, a short risk list — but
it should still exist as an explicit step, not be skipped entirely.

## 3. Implement against the approved plan

Run [`/implement`](../commands/implement.md) with the plan from step 2. That command carries you
through understanding the existing code, checking for logic to reuse, implementing with the
readability and no-unnecessary-abstractions rules applied, and writing tests and docs inline as
part of implementation — don't treat tests and docs as a separate phase tacked on at the end. Apply
the specialist lens from `agents/` that matches what the feature touches: a feature with an API
change uses [agents/backend-engineer.md](../agents/backend-engineer.md), a UI-facing feature uses
[agents/frontend-engineer.md](../agents/frontend-engineer.md), a schema change uses
[agents/database-engineer.md](../agents/database-engineer.md), and infrastructure changes use
[agents/devops-engineer.md](../agents/devops-engineer.md). Most features touch more than one — use
all that apply.

## 4. Work out the test strategy, then fill any gaps

Once the implementation is functionally complete, run [`/test`](../commands/test.md) against the
new code — not to generate cases blindly, but to reason explicitly about what needs coverage at
what level (unit, integration, end-to-end) per
[docs/testing/testing-strategy.md](../../docs/testing/testing-strategy.md), and to catch edge cases and error paths
that weren't exercised during implementation.

## 5. Security-audit if the feature touches a trust boundary

If the feature touches authentication, authorization, input handling, secrets, dependencies, or
data access, run [`/security-audit`](../commands/security-audit.md) before moving to review — don't
rely on the abbreviated security check inside `/review` for a change with real security surface.

## 6. Self-review before requesting human review

Run [`/review`](../commands/review.md) against your own diff before asking anyone else to look at
it, adopting [agents/reviewer.md](../agents/reviewer.md)'s checklist. Treat every blocking finding
as something to fix now — sending a diff to a human reviewer that you haven't reviewed yourself
wastes their time on issues you could have caught.

## 7. Walk the pull request checklist

Before opening the PR, walk
[checklists/before-pull-request.md](../../checklists/before-pull-request.md) in full. This covers
the mechanics self-review can miss: PR description quality, commit hygiene, CI status, linked
issues.

## 8. Address review feedback and walk the merge checklist

Once a human reviewer weighs in, address the feedback — and if you disagree with a piece of it,
explain your reasoning rather than silently overriding it (see
[.claude/rules/explain-tradeoffs.md](../rules/explain-tradeoffs.md)). Before merging, walk
[checklists/before-merge.md](../../checklists/before-merge.md) to confirm CI is green, required
approvals are in, and nothing was left unresolved in the review thread.

## When to shortcut this workflow

A one-line fix or trivial change doesn't need every step here in full force — the
definition-of-ready check might be a single mental confirmation, and `/plan`'s output might be two
sentences. What should never be skipped regardless of size: tests for the actual behavior change,
`/security-audit` if a trust boundary is touched, and a self-review pass before asking for human
review time.
