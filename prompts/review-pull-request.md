# Review a Pull Request

Guide an AI assistant through a structured PR review covering correctness,
readability, tests, security, performance, and documentation.

## Purpose

An unstructured "review this PR" prompt tends to produce either a wall of
nitpicks or a rubber stamp. This prompt forces the assistant to evaluate a
fixed set of dimensions, separate blocking issues from suggestions, and
produce findings that map directly onto PR comments.

## When to use

- Getting an AI-assisted first pass before or alongside human review.
- Reviewing your own PR before requesting review, to catch issues early.
- Reviewing a large or unfamiliar diff where a structured pass helps avoid
  missing a dimension (security is the one people skip under time
  pressure).

## The prompt

```markdown
You are reviewing a pull request. Evaluate it across the dimensions below.
Be specific — reference file names and line numbers/hunks, not general
impressions. Distinguish blocking issues from optional suggestions.

## Context
- PR diff / changed files: {{diff_or_paths}}
- PR description / linked ticket: {{pr_description}}
- Anything the author specifically wants feedback on: {{focus_areas}}

## Review dimensions

### 1. Correctness
- Does the code do what the PR description claims?
- Are there logic errors, off-by-one issues, incorrect assumptions about
  inputs, or unhandled edge cases?
- Do changes match the stated acceptance criteria, if any?

### 2. Readability & maintainability
- Is the code clear without needing the author's context?
- Naming, function size, duplication, consistency with existing patterns
  in this codebase.
- Would a new team member understand this in six months?

### 3. Test coverage
- Are the changes covered by tests, including edge cases and error paths?
- Do the tests assert real behavior, or just exercise code without
  meaningful assertions?
- Are any existing tests weakened, skipped, or deleted without
  justification?

### 4. Security
- Input validation, injection risks, authN/authZ checks on new
  endpoints/actions, secrets handling, dependency changes.
- Treat this dimension seriously even if the PR isn't "security-related" —
  most vulnerabilities enter through ordinary feature work.

### 5. Performance
- Any new N+1 queries, unbounded loops/allocations, blocking calls on hot
  paths, or missing pagination/limits on new data access.
- Only flag as blocking if there's a concrete, evidenced concern — not
  speculative micro-optimization.

### 6. Documentation
- Are public APIs, config options, or behavior changes reflected in docs,
  comments, or changelogs?
- Is the PR description itself sufficient for a future reader (via git
  blame/history) to understand why this change was made?

## Output format
Structure findings as:

**Blocking issues** (must be resolved before merge)
- `path/to/file.ext:line` — description, why it's blocking, suggested fix.

**Suggestions** (non-blocking, author's discretion)
- `path/to/file.ext:line` — description, rationale.

**Questions** (need author clarification, not clearly right or wrong)
- description of what's unclear and why it matters.

**Summary**
One paragraph: overall assessment and recommendation (approve / approve
with comments / request changes), and why.
```

## Expected output

- Findings grouped into Blocking / Suggestions / Questions, each tied to a
  specific file and location.
- A one-paragraph summary with an explicit recommendation.
- No dimension silently skipped — if a dimension genuinely has no findings,
  it should say so rather than being omitted.

## Tips & pitfalls

- If the assistant returns only style nitpicks, re-prompt it to focus on
  Correctness and Security first — those are the dimensions worth a
  human's attention most.
- Don't let "Suggestions" balloon into a rewrite of the author's style
  choices; keep it to things that matter for maintainability, not
  preference.
- Cross-check output against [`../docs/code-review-guide.md`](../docs/code-review-guide.md)
  for this repo's review standards, and run
  [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md)
  yourself before requesting review, not after.
