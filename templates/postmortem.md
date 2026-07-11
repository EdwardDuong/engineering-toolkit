<!--
Template: Blameless Postmortem
Use this when: an incident has been resolved and you need a retrospective to understand and
prevent recurrence.
Guidance: ../docs/postmortem-guide.md and ../docs/root-cause-analysis.md
A worked example: ../examples/good-postmortem.md
This is blameless: focus on systems and processes, not individuals. Names appear only as
action item owners, not as causes.
-->

# Postmortem: [Incident Title]

| | |
|---|---|
| **Date of Incident** | [YYYY-MM-DD] |
| **Author(s)** | [Name(s)] |
| **Severity** | [SEV1 / SEV2 / SEV3 / SEV4] |
| **Status** | [Draft / Reviewed / Final] |

## Summary

<!-- 2-3 sentences: what happened, what caused it, how it was resolved. -->

[High-level summary of the incident.]

## Impact

<!-- Quantify: duration, users affected, revenue/SLA impact, data affected. -->

[Describe the impact in concrete, measurable terms.]

## Timeline

<!-- Pull from the live incident report if one exists. All times in a consistent timezone. -->

| Time (UTC) | Event |
|---|---|
| [HH:MM] | [Event] |

## Root Cause(s)

<!-- See ../docs/root-cause-analysis.md for technique guidance (e.g. 5 Whys). State the
     underlying cause, not just the trigger. -->

[Describe the root cause(s).]

## Contributing Factors

<!-- Secondary conditions that made the incident worse, more likely, or harder to detect —
     e.g. missing alerting, insufficient testing, unclear ownership. -->

- [Contributing factor]

## What Went Well

<!-- Detection speed, effective mitigation, good communication — reinforce what worked. -->

- [What worked well during the response]

## What Went Poorly

<!-- Be honest and specific. This is about the system/process, not blaming people. -->

- [What didn't work well]

## Action Items

<!-- Every item needs an owner and a due date. Track these to completion outside this document. -->

| Action | Owner | Due Date | Status |
|---|---|---|---|
| [Action item] | [Name] | [YYYY-MM-DD] | [Open] |

## Lessons Learned

<!-- Broader takeaways beyond the specific action items — patterns worth remembering. -->

[Summarize the key lessons for the team/org.]
