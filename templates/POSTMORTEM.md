<!--
Template: Blameless Postmortem
Use this when: writing up an incident after it's resolved — see ../docs/postmortem-guide.md for the
full philosophy and ../docs/workflows/production-incident.md for where this fits in the incident
lifecycle. This postmortem is blameless: it exists to fix the system, not to assign fault to
whoever was on call or made a call under incomplete information.
A worked example: ../examples/good-postmortem.md
-->

# Postmortem: [Incident name — specific, e.g. "Elevated Email Delivery Failures", not "Outage"]

**Incident ID:** [reference to the live incident report, e.g. INC-2026-0341]
**Date of incident:** [YYYY-MM-DD]
**Date of postmortem:** [YYYY-MM-DD]
**Author:** [Name]
**Reviewers:** [Names / team]

## Context

<!-- What system was affected and what it normally does — enough for a reader unfamiliar with this
     part of the system to understand the rest of the document. -->

[Briefly describe the affected system/service and its normal behavior, so the impact described
below is legible to a reader without prior context.]

## Problem

<!-- The incident itself: summary, impact, and timeline. This is the factual record, not yet the
     analysis. -->

**Summary:** [what happened, in two or three sentences a non-participant could understand]

**Impact:**
- [Quantified user/business impact — error rate, duration, number of users affected, revenue/data
  impact if applicable]
- [What was NOT affected, if relevant — scoping the blast radius accurately matters as much as
  describing it]

**Timeline:**
- **[HH:MM]** — [event]
- **[HH:MM]** — [detection]
- **[HH:MM]** — [key diagnostic moment]
- **[HH:MM]** — [mitigation applied]
- **[HH:MM]** — [confirmed resolved]

**Time to detect:** [duration] · **Time to mitigate:** [duration from detection]

## Decision

<!-- The mitigation and remediation decisions actually made — during the incident and immediately
     after. -->

**Mitigation chosen:** [what was actually done to stop user impact — rollback, flag flip,
failover, manual intervention — and why this was the fastest safe option available, per
../docs/workflows/production-incident.md's mitigation-before-full-diagnosis principle]

**Root cause (5-Whys):**
1. **Why did [proximate symptom] happen?** → [...]
2. **Why did that happen?** → [...]
3. **Why did that happen?** → [continue until reaching a systemic cause, not a human-blame dead end]

**Root cause:** [one clear statement of the systemic cause — a process gap, missing safeguard, or
design assumption that broke, not "an engineer made a mistake"]

## Alternatives

<!-- Other mitigation options considered during the incident, and why the chosen one was picked —
     documenting this in-the-moment reasoning is what lets the next incident responder learn from
     this one's judgment calls, not just its outcome. -->

### [Alternative mitigation considered]

[What else was on the table — e.g., "considered scaling up the worker pool instead of rolling
back, rejected because the root cause wasn't yet confirmed to be load-related and rollback was
faster to execute with more certainty."]

### Waiting for full root cause before acting

[Almost always worth noting explicitly why the team didn't wait for complete diagnosis before
mitigating — the tradeoff between speed and certainty that was made.]

## Risks

<!-- Contributing factors, and any residual risk that remains after the immediate fix. -->

**Contributing factors** (what made this worse, harder to detect, or harder to diagnose — distinct
from the root cause):
- [e.g., "no alert existed for this specific failure signature, only the aggregate metric"]
- [e.g., "the vendor's status page didn't reflect the issue, which delayed diagnosis"]

**What went well** (detection or response mechanisms that worked as intended — a postmortem that
only lists failures produces a discouraging document nobody wants to write the next one of
honestly):
- [...]

**Residual risk:** [what's still true after the immediate mitigation that the action items below
need to close — e.g., "the same generic retry-policy pattern likely exists in other services and
hasn't been audited yet"]

## Validation

<!-- How resolution was confirmed, and how the action items below will be verified as actually
     done, not just filed. -->

- **Confirmed resolved by:** [the specific signal that showed the incident was over — metrics
  returning to baseline, backlog drained, manual verification]
- **Action items:**

| Action | Type | Owner | Due date | Status |
|---|---|---|---|---|
| [Specific, ticketable action] | Prevent \| Detect \| Mitigate | [name] | [date] | [Not started/In progress/Done] |

<!-- Prevent = stops this exact failure from recurring. Detect = shortens time-to-detection if it
     recurs differently. Mitigate = reduces blast radius/severity if it recurs. Every action item
     needs an owner and a date — "improve monitoring" with no owner produces no actual change. -->

## Ownership

- **Incident commander (during the incident):** [name]
- **Postmortem author:** [name]
- **Action item owners:** [see table above]
- **Distribution:** [who this postmortem was shared with — should extend beyond the team that was
  on call, since the lesson usually generalizes]
