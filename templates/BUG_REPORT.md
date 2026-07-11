<!--
Template: Bug Report
Use this when: filing a defect against existing behavior. For the fuller investigation process this
report feeds into, see ../docs/workflows/bug-fix.md and ../prompts/investigate-bug.md.
A filed bug report often starts with only the top sections filled in (Context, Problem) — the
Decision, Risks, and Validation sections get completed during triage and fix, not necessarily by
the reporter. That's expected; leave them marked accordingly rather than guessing.
-->

# Bug: [Specific, searchable summary — "Export fails for accounts with >10k records", not "Export broken"]

**Status:** [Reported | Triaged | In progress | Fixed | Won't fix]
**Severity:** [Critical | High | Medium | Low — see ../checklists/incident-review.md if this is
actively affecting production]
**Reporter:** [Name]
**Assignee:** [Name, once triaged]

## Context

<!-- Environment and circumstances the bug was observed in — precise enough that reproduction
     doesn't depend on guessing what was different about this case. -->

- **Environment:** [production | staging | local — version/commit if relevant]
- **When first observed:** [date/time, and whether this is new or has always been broken]
- **Frequency:** [always | intermittent (X% of attempts) | happened once]
- **Related recent changes:** [any deploy, config change, or migration around the time this
  started — a large fraction of bugs are regressions from a specific, findable change]

## Problem

<!-- Expected vs. actual behavior, with exact reproduction steps. This is the section that
     determines whether anyone else can reproduce this without asking the reporter follow-up
     questions. -->

**Steps to reproduce:**
1. [Exact step — include specific input values, not "a large file," but "a 50MB CSV with 12,000 rows"]
2. [...]

**Expected behavior:** [what should happen]

**Actual behavior:** [what actually happens — exact error message, status code, or incorrect
output, not a paraphrase]

**Evidence:** [logs, stack trace, screenshot, or request/response — the raw evidence, not a
summary of it]

## Decision

<!-- Filled in during triage/fix: the root cause and the chosen fix approach. -->

**Root cause:** [filled in after investigation per ../docs/root-cause-analysis.md — not the
symptom, the systemic reason the symptom was possible. Leave as "Under investigation" until
confirmed; don't guess here.]

**Fix approach:** [what's being changed, and why this addresses the root cause above rather than
just the symptom]

## Alternatives

<!-- Other fixes considered during triage, and why the chosen one was picked. -->

### [Quick mitigation, if one exists]

[e.g., a config change or feature flag that stops user impact immediately — note whether this was
applied as a stopgap ahead of the proper fix, per ../docs/workflows/bug-fix.md.]

### [A more thorough fix than the one chosen]

[If the root cause pointed to something larger than this bug is worth fixing right now, note the
broader fix that was considered and explicitly deferred — record it in
../docs/technical-debt.md rather than silently dropping it.]

## Risks

<!-- What the fix itself could break, and how far this bug's pattern might extend. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Fix introduces a regression elsewhere] | [L/M/H] | [L/M/H] | [...] |
| [Same defect pattern exists in similar code paths] | [L/M/H] | [L/M/H] | [Searched for: yes/no — list any siblings found] |

## Validation

<!-- Proof the fix actually fixes it, not just that it compiles. -->

- **Regression test:** [describe the test added — confirm it fails against the pre-fix code before
  considering this done, per ../.claude/rules/tests-and-documentation.md]
- **Manually verified:** [exact steps used to confirm the fix in the environment where the bug was
  originally observed]
- **Confirmed no regression in:** [related functionality checked to make sure the fix didn't break
  something else]

## Ownership

- **Reporter:** [name]
- **Triager:** [name — confirmed severity and assignment]
- **Fix owner:** [name]
- **Verifier:** [name who confirmed the fix, ideally not the same person who wrote it]
