# Implement a Feature

Guide an AI assistant through implementing a new feature from a vague request to
a tested, documented change — clarifying scope before any code is written.

## Purpose

Most low-quality AI-generated code isn't a coding failure, it's a
requirements failure: the assistant guessed at scope, skipped edge cases, or
picked an approach nobody agreed to. This prompt forces an explicit
clarify-propose-implement sequence so the engineer stays the decision-maker
and the AI does the legwork.

## When to use

- Starting a new feature, endpoint, UI flow, or capability from a ticket or
  informal request.
- The request is underspecified (most are) and you want the AI to surface
  ambiguity instead of silently resolving it.
- You want a design tradeoff discussion before code exists, not a
  post-hoc review of a finished diff.

## The prompt

```markdown
You are implementing a feature in this codebase. Follow this sequence and do
not skip steps.

## Context
- Feature request: {{feature_description}}
- Related ticket / spec (if any): {{ticket_link_or_text}}
- Relevant files or modules: {{relevant_paths}}
- Constraints (performance, compatibility, deadlines): {{constraints}}

## Step 1 — Clarify requirements
Before writing any code, restate the feature as a set of concrete acceptance
criteria (Given/When/Then or bullet form). Explicitly list:
- What is in scope and out of scope.
- Inputs, outputs, and edge cases you can infer from the codebase.
- Any assumptions you are making, flagged clearly as assumptions.
- Open questions that block implementation, if any.

Stop and present this to me before proceeding if there are open questions I
need to answer.

## Step 2 — Propose an approach
Propose 1-3 implementation approaches. For each, state:
- The rough shape of the change (files touched, new abstractions if any).
- Tradeoffs: complexity, performance, blast radius, consistency with
  existing patterns in this codebase.
- Your recommendation and why.

Wait for my confirmation of the approach before writing implementation code.

## Step 3 — Implement incrementally
Once the approach is confirmed, implement in small, reviewable steps rather
than one large diff:
1. Data/interface changes first (types, schemas, function signatures).
2. Core logic.
3. Wiring/integration points.
4. Error handling and edge cases identified in Step 1.

After each step, briefly state what changed and why.

## Step 4 — Tests
Add or update tests covering the acceptance criteria from Step 1, including
edge cases and failure paths, not just the happy path.

## Step 5 — Documentation
Update any docs, comments, or changelogs that reference the changed
behavior. Do not leave stale documentation describing the old behavior.

## Constraints
- Match existing code style, patterns, and naming in this repo — do not
  introduce a new pattern without calling it out explicitly in Step 2.
- Do not silently expand scope beyond the agreed acceptance criteria.
- If you discover the agreed approach is wrong partway through, stop and
  flag it rather than quietly changing direction.
```

## Expected output

- A written acceptance-criteria list and open-questions block (Step 1),
  presented before code.
- A short options-and-recommendation writeup (Step 2), presented before
  code.
- Incremental diffs with a one-line rationale per step.
- New/updated tests mapped to the acceptance criteria.
- Doc/comment updates in the same change, not deferred.

## Tips & pitfalls

- If the AI jumps straight to code, stop it and ask for Steps 1-2 first —
  re-paste the prompt if needed.
- Fill in `{{constraints}}` even when informal ("must not break the public
  API", "no new dependencies") — unstated constraints get violated.
- Pair this with [`../checklists/before-coding.md`](../checklists/before-coding.md)
  as a final gate before Step 3, and [`../docs/definition-of-ready.md`](../docs/definition-of-ready.md)
  if the request came in without a clear spec.
- For a change large enough to need a design record, use
  [`architecture-review.md`](architecture-review.md) on the proposal from
  Step 2 before implementing.
