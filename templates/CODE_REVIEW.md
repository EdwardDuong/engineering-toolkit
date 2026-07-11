<!--
Template: Code Review Record
Use this when: a review needs a permanent, structured record beyond inline PR comments — a
high-risk change, a dedicated architecture or security review, or any review run through
../.claude/commands/review.md or ../.claude/commands/security-audit.md where the findings should be
captured as a document, not scattered across PR comment threads. For ordinary PRs, inline comments
against ../checklists/before-pull-request.md are usually sufficient — reach for this template when
the change's risk warrants a durable record of what was checked and why it passed or didn't.
Related: ../docs/code-review-guide.md, ../.claude/agents/reviewer.md.
-->

# Code Review: [PR/change name]

**Reviewer:** [Name]
**Date:** [YYYY-MM-DD]
**PR/diff reviewed:** [link]
**Review type:** [Standard | Architecture | Security | Database | Domain-specialist — matching the
../.claude/agents/ persona applied, if any]

## Context

<!-- What's being reviewed and why this review is happening at this level of formality. -->

[Link to the PR, the FEATURE_SPEC.md or ADR.md it implements, and state why this review is being
recorded formally rather than as inline PR comments — e.g., "touches the authentication
middleware," "first use of the new event-sourcing pattern from ADR-0012."]

## Problem

<!-- What the change under review claims to solve — the reviewer restates this to confirm they
     understood the intent correctly before evaluating whether the implementation delivers it. -->

[Restate, in the reviewer's own words, what problem this change is meant to solve. If this doesn't
match the author's stated intent, that mismatch is itself a finding — surface it before going
further into the diff.]

## Decision

<!-- The review verdict and the reasoning behind it — not just "approved," but why. -->

**Verdict:** [Approved | Approved with non-blocking comments | Changes requested | Rejected]

**Reasoning:** [the specific basis for this verdict — e.g., "correctness and security are sound;
two non-blocking maintainability suggestions below" or "blocking: the new endpoint has no
authorization check on the resource-ownership level, only session validity"]

## Alternatives

<!-- Approaches the reviewer considered suggesting instead of what's in the diff, if any — this
     is what separates a review that engaged with the design from one that only checked syntax. -->

[If the reviewer would have approached this differently, state the alternative and why it wasn't
raised as blocking (a legitimate stylistic difference) or why it was (a real correctness/
maintainability concern). If the chosen approach is clearly the right one and no alternative is
worth raising, say so explicitly rather than leaving this section implicitly empty.]

## Risks

<!-- Findings, by dimension, each marked blocking or non-blocking per ../docs/code-review-guide.md.
     A finding without a concrete failure scenario is not actionable — state what breaks and under
     what condition, not just that something "looks wrong." -->

| Finding | Dimension | Severity | Failure scenario |
|---|---|---|---|
| [Specific issue] | Correctness \| Maintainability \| Security \| Performance | Blocking \| Non-blocking | [Concrete inputs/conditions → wrong outcome] |

## Validation

<!-- What the reviewer actually did to verify the change, not just read the diff. -->

- [ ] Traced through the stated edge cases and error paths, not just the happy path
- [ ] Confirmed new/updated tests would fail without the change (spot-checked, not assumed)
- [ ] Ran the change locally / in a test environment: [describe, or state why not applicable]
- [ ] Checked against [`../.claude/agents/reviewer.md`](../.claude/agents/reviewer.md)'s checklist
- [ ] For a security-relevant change, checked against
      [`../.claude/agents/security-engineer.md`](../.claude/agents/security-engineer.md) or ran a
      full [`/security-audit`](../.claude/commands/security-audit.md)
- [ ] For a domain-specific change, applied the matching specialist checklist (e.g.
      [`../.claude/agents/database-engineer.md`](../.claude/agents/database-engineer.md) for a
      migration)

## Ownership

- **Reviewer:** [name]
- **Author:** [name]
- **Re-review owner:** [name — if changes were requested, who re-reviews once addressed; often but
  not always the same reviewer]
- **Escalation:** [if the author and reviewer disagree and can't resolve it, who breaks the tie —
  see ../docs/decision-making.md]
