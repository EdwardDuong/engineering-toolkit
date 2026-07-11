# Documentation Generation

Guide an AI assistant to generate or update documentation from code — API
references, READMEs, runbooks — that stays accurate and non-redundant.

## Purpose

Generated documentation tends to either drift from the code immediately or
duplicate what's already better expressed in code/comments. This prompt
requires the assistant to verify against the actual current code, prefer
updating over duplicating, and state explicitly what it could not confirm.

## When to use

- Generating API reference docs from code (endpoints, functions, types).
- Writing or updating a README for a module/service/repo.
- Producing an operational runbook for a system.
- Auditing existing docs for drift against the current codebase.

## The prompt

```markdown
You are generating/updating documentation. Prioritize accuracy over
completeness — documentation that's wrong is worse than documentation
that's missing. Verify claims against the actual current code rather than
inferring from names or comments alone.

## Context
- Target: {{doc_type}} (API reference / README / runbook / other)
- Code or system to document: {{code_or_system}}
- Existing documentation to update, if any: {{existing_doc_path}}
- Intended audience: {{audience}}

## Step 1 — Verify against source
Before writing, confirm what the code actually does:
- For API/reference docs: read the actual function signatures, types,
  request/response shapes, error conditions — do not describe behavior
  the docstring/comment claims if the code doesn't match it. Flag any
  such mismatch you find.
- For a README: confirm setup/run instructions actually work as described
  (or state that you couldn't verify execution and it should be tested).
- For a runbook: confirm each operational step against the actual
  scripts/commands/dashboards it references, not a remembered or assumed
  version of them.

## Step 2 — Check for existing documentation first
- If documentation already exists for this code/system, update it in
  place rather than creating a parallel document. State what changed and
  why.
- If near-duplicate documentation exists elsewhere (a comment already
  explains this, another doc covers the same ground), consolidate or
  cross-link instead of repeating it.

## Step 3 — Write for the stated audience
- Match depth to the audience: a README for new contributors needs setup
  and mental model; an API reference for integrators needs contracts and
  edge cases; a runbook for on-call needs step-by-step actions under
  pressure, not background theory.
- Use concrete examples (real request/response, real command output)
  over abstract descriptions where possible.
- Keep it scannable: headings, short paragraphs, code blocks for anything
  meant to be copy-pasted.

## Step 4 — Flag gaps and uncertainty
- If you cannot confirm a behavior from the code (e.g., it depends on
  runtime configuration you don't have access to), say so explicitly
  rather than presenting a guess as fact.
- List anything intentionally left out of scope for this doc, so a
  reader/reviewer knows it wasn't missed by accident.
```

## Expected output

- Documentation content matching the target type and audience.
- An explicit note on what was verified against source vs. what
  couldn't be confirmed.
- If updating existing docs: a summary of what changed, not just a full
  replacement with no diff context.
- No content duplicating another doc without a cross-link/consolidation
  decision stated.

## Tips & pitfalls

- Watch for the assistant documenting what a function *name* or
  *docstring* implies rather than what the code actually does — these
  drift apart constantly and generated docs will silently inherit the
  drift unless explicitly told to verify.
- For runbooks especially, untested steps are dangerous — mark any
  unverified step clearly rather than presenting it with the same
  confidence as a verified one.
- Prefer fewer, well-maintained documents over many overlapping ones —
  consolidation is usually more valuable than a new file.
- See [`../docs/documentation-standards.md`](../docs/documentation-standards.md)
  for this repo's formatting and structure conventions.
