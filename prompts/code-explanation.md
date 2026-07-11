# Code Explanation

Guide an AI assistant to explain unfamiliar code to a specific audience —
covering purpose, data flow, and gotchas — at a chosen depth.

## Purpose

"Explain this code" without an audience or depth in mind tends to produce
either a line-by-line narration nobody needed or a shallow summary that
misses the part that actually matters. This prompt pins down who the
explanation is for and how deep to go, and requires surfacing the
non-obvious traps, not just describing the obvious flow.

## When to use

- Onboarding to an unfamiliar module, service, or codebase.
- Preparing to review a PR in an area you don't know well.
- Documenting tribal knowledge about a tricky piece of code before the
  person who understands it moves on or forgets.

## The prompt

```markdown
You are explaining code to help someone understand it, not just
summarizing what it does line by line. Tailor depth and focus to the
stated audience.

## Context
- Code to explain: {{code_or_path}}
- Audience: {{audience}} (e.g., "new team member with no context on this
  service," "reviewer evaluating a specific PR," "on-call engineer during
  an incident," "myself, revisiting this in six months")
- Depth requested: {{depth}} (e.g., "high-level overview," "deep dive
  including edge cases," "just enough to review this diff")
- Specific question driving this, if any: {{specific_question}}

## Structure

### 1. Purpose
In 2-4 sentences: what problem does this code solve, and why does it exist
(what would break or be missing without it)? Avoid restating the code in
prose — explain intent.

### 2. Data flow
Trace how data moves through this code:
- Entry points (what calls this, what triggers it).
- Key transformations or decisions along the way.
- Where it terminates (return value, side effect, downstream call).
Use a short list or simple diagram-in-text if the flow has more than 3-4
steps — don't narrate every line.

### 3. Key abstractions
Identify the 2-4 most important types, functions, or patterns a reader
needs to understand to follow this code, and explain each briefly. Skip
abstractions that are self-explanatory from their names.

### 4. Gotchas and non-obvious behavior
This is the most important section — do not skip or shorten it. Cover:
- Behavior that would surprise someone reading only the function/variable
  names (implicit ordering requirements, mutation of shared state, silent
  failure/swallowed errors, unexpected coupling to other modules).
- Assumptions the code makes about its inputs or environment that aren't
  enforced/validated.
- Historical context if inferable (comments, git history) explaining why
  something looks odd — "this looks wrong but exists because X."

### 5. Adjust for audience
- If audience is a new team member: connect this to the broader system —
  what else touches this, what to be careful about changing.
- If audience is a reviewer: focus on what's relevant to evaluating the
  specific diff, not the whole file's history.
- If audience is on-call: focus on operational behavior — failure modes,
  what a given error/log line means, what's safe to restart/retry.
- If depth is "high-level": compress to Purpose + Data flow only, skip
  abstractions/gotchas unless they're critical to a correct mental model.
```

## Expected output

- A short purpose statement in plain language, not restated code.
- A data-flow trace scoped to the requested depth.
- A gotchas section that surfaces genuinely non-obvious traps, not
  generic disclaimers.
- Framing adjusted to the stated audience, not a one-size-fits-all
  explanation.

## Tips & pitfalls

- If the explanation reads like a line-by-line transcript of the code,
  it's too shallow — ask specifically "what would surprise someone" to
  pull out the gotchas section.
- For on-call/incident use, ask for operational framing explicitly
  (log line meanings, safe retries) — a generic explanation is much less
  useful under time pressure.
- Set depth deliberately; "deep dive" on a large file produces
  low-signal output — scope to the specific function/path relevant to the
  question instead.
- For code you're about to modify rather than just understand, follow up
  with [`legacy-code-analysis.md`](legacy-code-analysis.md) to identify
  safe seams for change.
