# Root Cause Analysis

Guide an AI assistant through a blameless, structured root cause analysis of
an incident or recurring defect, producing a writeup suitable for a
postmortem.

## Purpose

A good RCA explains *why the system allowed the failure*, not just what line
of code was wrong. This prompt applies 5-Whys and contributing-factor
analysis, keeps the framing blameless (systems and processes, not
individuals), and produces a structured document rather than a narrative
that trails off after the technical fix.

## When to use

- After an incident is resolved (or a recurring defect is finally
  understood) and you need a formal writeup.
- You want to distinguish the proximate cause from the underlying systemic
  causes that let it happen.
- You are feeding output into [`../templates/postmortem.md`](../templates/postmortem.md)
  and want the analysis section pre-structured.

## The prompt

```markdown
You are writing a blameless root cause analysis. The goal is to understand
the system and process conditions that allowed this to happen, not to
assign fault to a person or team. Do not name individuals; refer to roles,
systems, or processes.

## Context
- Incident / defect summary: {{incident_summary}}
- Timeline of events (detection, escalation, mitigation, resolution):
{{timeline}}
- Impact (users affected, duration, severity): {{impact}}
- Confirmed technical root cause (if already known from investigation): {{known_root_cause}}

## Step 1 — Proximate cause
State the immediate, technical trigger of the incident in one or two
sentences. This is the "what broke," not the "why it was allowed to break."

## Step 2 — 5-Whys
Starting from the proximate cause, ask "why" repeatedly (typically 4-6
times) until you reach a systemic factor — a process gap, missing
safeguard, or design assumption — rather than stopping at "a person made a
mistake." Show the full chain:
1. Why did [proximate cause] happen? -> ...
2. Why did *that* happen? -> ...
(continue until the chain reaches a process/system-level cause, not a
human-blame dead end)

## Step 3 — Contributing factors
Separately from the causal chain, list contributing factors that made the
incident worse, harder to detect, or harder to resolve — even if they
didn't directly cause it. Consider:
- Detection: How long until this was noticed? What would have caught it
  sooner?
- Escalation/response: Did the right people/systems get involved quickly?
- Blast radius: What amplified the impact (lack of isolation, no feature
  flag, no rate limiting)?
- Prevention gaps: What check, test, review step, or safeguard should have
  existed but didn't?

## Step 4 — What went well
List anything that worked as intended (monitoring that fired correctly, a
runbook that was followed, a rollback that worked) — an RCA that only lists
failures produces defensive reactions, not improvement.

## Step 5 — Action items
Propose concrete, assignable action items, each tagged by type:
- **Prevent**: stops this exact failure from recurring.
- **Detect**: shortens time-to-detection if it recurs in a different form.
- **Mitigate**: reduces blast radius/severity if it recurs.
Each action item should have a clear owner placeholder and be specific
enough to be tracked as a ticket (not "improve monitoring" but "add
alerting on {{specific_metric}} exceeding {{threshold}}").

## Constraints
- Stay blameless throughout: describe what the system/process allowed, not
  who made an error.
- Do not stop the 5-Whys at the first human action — human actions are
  themselves usually enabled by a process or system gap; keep going.
- Distinguish clearly between the causal chain (Step 2) and contributing
  factors (Step 3) — don't merge them into one list.
```

## Expected output

- A one-to-two-sentence proximate cause statement.
- A numbered 5-Whys chain ending in a systemic cause.
- A separate contributing-factors list grouped by detection/escalation/
  blast-radius/prevention.
- A "what went well" section.
- An action-item list tagged Prevent/Detect/Mitigate with owner
  placeholders.

## Tips & pitfalls

- If the chain stops at "engineer forgot to X," push for one more "why" —
  what made that easy to forget (no lint rule, no checklist, no default)?
- Don't skip Step 4 — it isn't filler, it's what keeps the RCA process
  trusted enough that people report incidents honestly.
- Feed the finished analysis into [`../templates/postmortem.md`](../templates/postmortem.md)
  for the full incident document, and see
  [`../docs/root-cause-analysis.md`](../docs/root-cause-analysis.md) for the
  underlying methodology and when 5-Whys vs. fault-tree analysis fits
  better.
- For an in-progress bug rather than a resolved incident, use
  [`investigate-bug.md`](investigate-bug.md) first to isolate the cause.
