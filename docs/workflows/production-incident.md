# Production Incident Workflow

This is the sequence an experienced team actually follows from the moment something looks wrong in
production to the moment the postmortem is published — the lived, chronological version of
[`incident-response.md`](../incident-response.md)'s standards (severity levels, roles, timeline
discipline) and [`postmortem-guide.md`](../postmortem-guide.md)'s structure. Read those two for the
reference definitions; read this one for how the phases actually unfold in order and what an
experienced responder is thinking at each stage.

## Detection

An incident starts being handled the moment it's noticed — the gap between "the system broke" and
"someone noticed" is dead time that costs users, and closing that gap is mostly an investment made
long before any specific incident happens.

- The best detection is automated and symptom-based: an alert that fires on user-facing impact
  (error rate, latency, availability) rather than on an internal implementation detail that may
  fluctuate without anything actually being wrong — see
  [`observability-guide.md`](../observability-guide.md).
- When detection comes from a human (a support ticket, a user report, an engineer noticing
  something odd) rather than an alert, that's worth noting as a follow-up item later — a real
  incident detected only by a human report is a signal that alerting has a gap worth closing.
- The moment something is confirmed as a likely incident (not just a one-off blip), declare it
  explicitly and assign an incident commander — per
  [`incident-response.md`](../incident-response.md)'s severity framework — rather than letting
  several people investigate in an uncoordinated scramble. Explicit declaration is what turns
  "several people are looking at logs" into "there is one person who knows the current state and
  is making the calls."
- Assess severity honestly and immediately, and be willing to revise it as more is learned. A
  cautious "this might be Sev-2" that gets downgraded once the actual impact is understood costs
  little; an incident quietly treated as low-severity that turns out to be a full outage costs a
  lot of the time an experienced team can't get back.

## Mitigation

The goal of mitigation is to stop user impact, as fast as safely possible — even before the root
cause is fully understood. An experienced team does not wait for a complete diagnosis before acting
if a safe mitigation is available sooner.

- **Reach for the fastest safe lever first**: roll back the most recent deploy if the timing
  correlates, disable a feature flag, fail over to a healthy instance, shed load, or degrade
  gracefully rather than fail completely. A rollback that resolves the symptom is a legitimate
  mitigation even before the root cause is confirmed — see
  [`bug-fix.md`](bug-fix.md) on why careful root-cause work happens *after* the bleeding stops for
  anything actively harming users.
- **Prefer reversible mitigations under uncertainty.** If it's not yet clear what's wrong, a change
  that's easy to undo (toggling a flag, scaling up capacity) is safer to try than one that isn't
  (a manual data fix, an irreversible config change) — see the two-way-door framing in
  [`decision-making.md`](../decision-making.md), which applies under incident pressure exactly as much
  as it does to ordinary engineering decisions, arguably more so given the reduced time to think
  each option through.
- **If a database migration or schema change is implicated, mitigation must account for the
  asymmetry in [`database-change.md`](database-change.md)'s rollback strategy** — reverting the
  application code does not necessarily undo a data-level change, and treating it as if it does can
  make the incident worse, not better.
- Track every mitigation action taken, with a timestamp, as it happens — not reconstructed from
  memory afterward. This timeline is what makes the eventual postmortem accurate instead of a
  best-guess narrative.
- Confirm the mitigation actually worked (metrics recovering, error rate dropping) before declaring
  the incident mitigated — a mitigation that looks right but wasn't verified is how a "resolved"
  incident reopens an hour later.

## Communication

An incident that's being handled well but communicated badly still damages trust — stakeholders and
users experience uncertainty and silence as much as they experience the outage itself.

- **Internal communication**: the incident commander keeps a single, current source of truth
  (an incident channel, a status doc) that anyone can check without interrupting the people
  actively working the problem. Status updates go out on a predictable cadence (e.g., every 30
  minutes for a serious incident) even when the update is "still investigating, no new information"
  — silence reads as "nobody's working on this," even when the opposite is true.
- **External communication** (a status page, a customer-facing notice) states what's known plainly:
  what's affected, since when, and what users should expect — without speculating about root cause
  before it's confirmed, and without over-promising a resolution time that then slips.
- Use [`../../templates/incident-report.md`](../../templates/incident-report.md) as the live
  incident record — severity, status, impact, current actions, and a timeline log — updated
  throughout, not written up after the fact from memory.
- Communication responsibility is explicitly assigned, usually separate from whoever is doing the
  technical mitigation — the person fixing the problem should not also be the sole source of status
  updates; that's how both the fix and the updates get delayed.

## Postmortem

The incident isn't done when mitigation succeeds — it's done when the team understands why it
happened well enough to reduce the odds of it (or something like it) happening again, and that
understanding is written down.

- Apply [`root-cause-analysis.md`](../root-cause-analysis.md)'s method (5-Whys, contributing factors)
  now, with the full timeline available, rather than relying on the necessarily incomplete
  understanding formed during active mitigation. The proximate cause identified during mitigation
  ("the deploy caused it, we rolled it back") is rarely the full root cause.
- Write the postmortem as blameless, per [`postmortem-guide.md`](../postmortem-guide.md) and
  [`../../templates/POSTMORTEM.md`](../../templates/POSTMORTEM.md) — it exists to fix the system,
  not to assign fault to whoever was on call. A postmortem people are afraid to be honest in
  produces a sanitized timeline that misses the actual contributing factors.
- Include what went well, not just what went wrong — a postmortem that only lists failures misses
  half the information (what detection or mitigation mechanism worked as intended) and produces a
  discouraging document nobody wants to write the next one of honestly.
- Every action item gets a specific owner and a due date, tagged by what it actually does
  (**Prevent** this exact recurrence, **Detect** it faster next time, **Mitigate** its impact if it
  recurs) — a postmortem with vague, unowned action items ("improve monitoring") produces no actual
  change.
- Walk [`../../checklists/incident-review.md`](../../checklists/incident-review.md) and
  [`../../checklists/postmortem.md`](../../checklists/postmortem.md) before considering the
  incident closed, and share the finished postmortem broadly enough that the lesson generalizes
  beyond the team that happened to be on call.

## The pattern underneath all five phases

Detect fast, mitigate before you fully understand, communicate honestly throughout, and understand
deeply afterward — in that order, not reordered under pressure. The most common way an experienced
team's incident response goes wrong is skipping straight to root-cause investigation before
mitigating, because the investigation is intellectually engaging and the mitigation lever (a
rollback, a flag flip) feels like giving up on understanding the problem. It isn't — it's
recognizing that stopping user impact and understanding the system are different goals, and the
first one is more urgent every time.
