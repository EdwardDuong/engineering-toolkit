# Postmortem Guide

A postmortem is how an organization converts an incident from a bad day into a durable improvement.
Done well, it's the single highest-leverage reliability activity a team does — it costs a few hours
and, if the resulting action items actually get done, prevents a category of future incidents rather
than just the one that already happened.

## Blameless philosophy

- **The goal is understanding the system, not judging the people involved.** A postmortem that
  identifies "who's at fault" produces defensiveness, incomplete information (people self-censor
  when they expect blame), and a fix aimed at the wrong level — see the discussion in
  [`root-cause-analysis.md`](./root-cause-analysis.md) of why "a person made a mistake" is rarely a
  useful stopping point.
- **Assume good faith and reasonable action given the information available at the time.** Anyone
  involved in the incident was doing what seemed reasonable with the context and tools they had in
  the moment — the postmortem's job is to understand what about that context or those tools let a
  reasonable action lead to a bad outcome, and fix that.
- **This is a cultural commitment, not just a document format.** A postmortem template with
  "blameless" in the title doesn't make a meeting blameless if the actual conversation names and
  criticizes individuals. Facilitators should redirect blame-framed statements ("Alex should have
  caught this") toward system-framed ones ("what would have caught this regardless of who was
  involved") in real time.
- **Blameless does not mean consequence-free for genuine negligence** — a rare, separate case (see
  [`root-cause-analysis.md`](./root-cause-analysis.md)) that should be handled outside the
  postmortem process, not conflated with it.

## Structure

A postmortem, using [`../templates/postmortem.md`](../templates/postmortem.md), should cover:

- **Summary** — a short, factual description of what happened and its impact, readable by someone
  with no context in under a minute.
- **Timeline** — the reconstructed sequence of events from detection through resolution, pulled from
  the real-time incident log kept during the response (see
  [`incident-response.md`](./incident-response.md)) — not reconstructed from memory afterward, which
  is unreliable.
- **Impact** — concretely: what was affected, for how long, and how many users/requests/dollars, to
  whatever precision is knowable. Vague impact statements ("some users were affected") undersell or
  oversell the severity depending on who's reading, and don't help prioritize the resulting action
  items against other work.
- **Root cause and contributing factors** — the output of the analysis in
  [`root-cause-analysis.md`](./root-cause-analysis.md), stated at the systemic level.
- **What went well** — genuinely include this, not as a courtesy. Understanding what worked (fast
  detection, a runbook that was accurate, an escalation that went smoothly) is as valuable as
  understanding what didn't, and it reinforces the practices worth continuing.
- **Action items** — the concrete output; see below.

## Timeline reconstruction

- Build the timeline from actual logged evidence — the shared incident log, monitoring/alerting
  timestamps, deploy logs, chat history — rather than participants' memory, which compresses and
  reorders events under stress.
- Include the time between when the problem started, when it was detected, when it was diagnosed,
  and when it was mitigated — these four intervals (time-to-detect, time-to-diagnose,
  time-to-mitigate) are individually useful for finding where the response was slow, in a way a
  single "incident duration" number obscures.
- Note decision points explicitly — not just "what happened" but "what was decided and why," since a
  future reader trying to understand whether a similar decision should be made differently next time
  needs the reasoning, not just the outcome.

## Action item follow-through

This is where most postmortem processes fail — not in writing the document, but in actually doing
what it says.

- **Every action item has a single named owner and a due date**, not a diffuse "the team"
  responsibility that nobody feels individually accountable for.
- **Action items are triaged by expected impact, like any other backlog item** — not treated as
  automatically higher priority than all other work just because they came out of an incident, but
  also not silently deprioritized indefinitely just because the incident is no longer top of mind.
  Use [`risk-assessment.md`](./risk-assessment.md) to weigh a given action item's priority honestly
  against the likelihood and impact of recurrence without it.
- **Track action items to completion visibly** — in the same tracker as other engineering work, not
  in a postmortem document that nobody reopens. A recurring review (e.g., a standing agenda item to
  check open postmortem action items) catches ones that are stalling before they're forgotten
  entirely.
- **If an action item repeatedly gets deprioritized, that itself is a signal worth surfacing** —
  either it wasn't actually as important as it seemed at the time (fine, close it explicitly with
  that reasoning recorded) or the team is systematically under-investing in reliability work
  relative to feature work (not fine, and worth raising explicitly rather than letting it happen by
  a thousand small deprioritizations).

## Sharing and learning

- Postmortems should be broadly readable within the engineering organization by default, not
  restricted to the immediate team — the whole point is that other teams can learn from a failure
  mode before they hit it themselves.
- Periodically review a set of past postmortems together (a quarterly reliability review is a
  reasonable cadence) looking for recurring themes across incidents — the same contributing factor
  showing up in multiple, seemingly unrelated postmortems is a strong signal of a systemic gap worth
  addressing directly rather than incident by incident.

See [`../examples/good-postmortem.md`](../examples/good-postmortem.md) for a fully worked example of
what this looks like in practice.
