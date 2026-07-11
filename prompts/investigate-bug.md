# Investigate a Bug

Guide an AI assistant through reproducing a bug, gathering evidence, and
isolating the root cause — before it proposes any fix.

## Purpose

The most common failure mode when an AI "fixes" a bug is pattern-matching to
a plausible-looking cause and patching the symptom. This prompt enforces a
reproduce-gather-hypothesize-isolate sequence so the fix targets the actual
defect, not the first plausible explanation.

## When to use

- A bug report exists (from a user, monitoring alert, or failing test) and
  you need to find the actual cause before fixing it.
- The failure is intermittent, environment-specific, or hard to reproduce
  and you want a structured way to narrow it down.
- You want to avoid an AI assistant "fixing" the bug by guessing at a patch
  without confirming the mechanism.

## The prompt

```markdown
You are investigating a bug. Do not propose a fix until you have completed
Steps 1-4 and isolated a confirmed root cause.

## Context
- Bug report / symptom: {{bug_description}}
- How it was observed (error message, alert, user report): {{observation_source}}
- Environment (prod/staging/local, version, config): {{environment}}
- Relevant logs, stack traces, or error output:
{{logs_or_stack_trace}}
- Steps already tried (if any): {{prior_attempts}}

## Step 1 — Reproduce
Establish a minimal, reliable way to reproduce the issue:
- State the exact steps, inputs, or conditions that trigger it.
- If you cannot reproduce it directly, state what you *can* observe (logs,
  test failures, static analysis) and treat reproduction as an open task.
- Note whether it is deterministic, intermittent, or condition-dependent
  (load, timing, specific data, specific environment).

## Step 2 — Gather evidence
Before forming a hypothesis, collect and summarize:
- The exact error message(s) and full stack trace, not a paraphrase.
- The code path(s) involved, traced from entry point to failure point.
- Relevant recent changes (git blame / recent commits) touching that path.
- Any state (input data, config, timing, concurrency) present when it
  fails vs. when it doesn't.

## Step 3 — Form and test hypotheses
List 2-4 plausible hypotheses for the root cause, ranked by likelihood.
For each hypothesis:
- State what evidence would confirm it and what would rule it out.
- Check the evidence you already have, or specify the smallest test,
  log line, or experiment needed to check it.
- Explicitly rule out hypotheses that don't match the evidence — do not
  keep a disproven hypothesis "just in case."

## Step 4 — Isolate the root cause
State the confirmed root cause in one or two sentences, referencing the
specific line(s), condition, or interaction responsible. Distinguish this
from any contributing factors (e.g., missing validation that let bad data
reach the real bug).

If you cannot isolate a confirmed cause, say so explicitly rather than
proposing a speculative fix — state what additional evidence or access
would be needed.

## Step 5 — Propose a fix (only after Step 4)
Once the root cause is confirmed, propose a fix that addresses the cause,
not just the observed symptom. Note any related code paths that share the
same bug pattern and should be checked.
```

## Expected output

- A concrete reproduction path or an explicit statement of what evidence
  substitutes for one.
- A summarized evidence trail (errors, code path, recent changes, state).
- A ranked hypothesis list with confirm/rule-out reasoning per hypothesis.
- A one-to-two-sentence root cause statement, separated from any
  contributing factors.
- A fix proposal that traces back to the confirmed cause.

## Tips & pitfalls

- If the assistant proposes a fix before Step 4, stop it and ask it to
  finish the isolation step first.
- Paste real stack traces and log excerpts, not summaries — the exact text
  often contains the clue (line numbers, error codes, timing).
- Watch for hypotheses that get quietly abandoned without being ruled out —
  ask "what ruled that one out?" if the reasoning skips.
- For incidents that need a formal writeup after the fix, continue with
  [`root-cause-analysis.md`](root-cause-analysis.md).
