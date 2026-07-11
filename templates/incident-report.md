<!--
Template: Live Incident Report
Use this when: an incident is currently in progress and you need a live-updating record of
status and impact. Once resolved, follow up with postmortem.md.
A worked example: ../examples/good-incident-report.md
Keep this updated in near-real-time during the incident — it's the source of truth for
stakeholders who aren't in the response channel.
-->

# Incident: [Short Title]

| | |
|---|---|
| **Severity** | [SEV1 / SEV2 / SEV3 / SEV4] |
| **Status** | [Investigating / Identified / Monitoring / Resolved] |
| **Start Time** | [YYYY-MM-DD HH:MM TZ] |
| **Incident Commander** | [Name] |
| **Communications Lead** | [Name, if applicable] |

## Impact

<!-- Who/what is affected, and how badly? Be specific: user counts, error rates, affected regions. -->

[Describe the user-facing and/or business impact.]

## Current Actions

<!-- What is actively being done right now to mitigate or resolve. Update as the response evolves. -->

[What the response team is doing right now.]

## Timeline

<!-- Append-only log, most recent entry at the bottom. Use UTC or a clearly stated timezone. -->

| Time (UTC) | Update |
|---|---|
| [HH:MM] | [Incident detected via alert X] |
| [HH:MM] | [Update] |

## Communications Sent

<!-- Record what was communicated externally/internally, when, and to whom. -->

| Time (UTC) | Channel | Summary |
|---|---|---|
| [HH:MM] | [Status page / Slack / email] | [Message sent] |

## Resolution

<!-- Fill in once resolved. -->

**Resolved at:** [YYYY-MM-DD HH:MM TZ]

[Brief description of the fix that resolved the incident.]

---

<!-- Once resolved, open a postmortem: postmortem.md, guided by ../docs/postmortem-guide.md -->
