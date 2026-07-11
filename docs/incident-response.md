# Incident Response

An incident is any event where a system's behavior deviates from expectation badly enough that it
needs a coordinated, time-boxed response rather than normal-priority work. This doc covers how to
recognize one, how to run one, and the roles that make a response effective instead of chaotic.

## When to declare an incident

Declare early — the cost of declaring an incident that turns out to be minor is a few minutes of
coordination overhead; the cost of not declaring one that turns out to be serious is lost response
time exactly when it matters most. As a default trigger, declare an incident when any of the
following is true:

- A user-facing capability is unavailable or significantly degraded (elevated error rate, latency
  breaching SLO, a critical flow failing) for real users, not just in a test environment.
- Data integrity is in question — data may have been lost, corrupted, or exposed to unauthorized
  access.
- A security control has failed or a breach is suspected.
- Multiple people are already independently investigating the same symptom — that's a sign it needs
  to be coordinated formally rather than duplicated informally across several people who don't know
  about each other.

When in doubt, declare. It is always cheaper to stand an incident down early once it's understood to
be minor than to coordinate a late, ad hoc response to something that was silently escalating.

## Severity levels

Calibrate severity to actual impact, and revisit it as the incident evolves — initial severity is
often a guess based on incomplete information.

- **SEV1 (critical)** — widespread outage or data-integrity/security event affecting most or all
  users, or any event with irreversible consequences (data loss, financial impact, safety impact).
  Requires immediate, all-hands-as-needed response regardless of time of day.
- **SEV2 (major)** — significant degradation or a critical flow broken for a meaningful subset of
  users, without full outage. Requires prompt response during or shortly after declaration, not
  deferred to normal business hours if declared off-hours.
- **SEV3 (minor)** — limited-impact issue, a non-critical flow degraded, or a critical flow degraded
  for a very small subset of users. Handled with urgency but generally within normal working hours
  unless it's trending toward a higher severity.
- **SEV4 (low)** — a real bug or issue that doesn't materially affect users, tracked and fixed
  through normal work rather than the incident process at all.

Severity should be assigned by the incident commander (below) based on impact, not by whoever is
most alarmed or most calm about it — a consistent rubric prevents severity from drifting with who
happens to notice first.

## Roles

- **Incident Commander (IC)** — owns the response. Coordinates who's doing what, makes the call on
  severity and when to escalate or stand down, and is the single point of decision-making authority
  for the duration of the incident. The IC does not have to be the most senior engineer present or
  the person who found the issue — it's a role, not a rank, and can be handed off explicitly if the
  initial IC needs to step back.
- **Communications lead** — owns updates to stakeholders (internal leadership, support, status page,
  affected customers as appropriate), on a predictable cadence, so the IC and responders aren't
  repeatedly interrupted to answer "what's the status" from people outside the response. For
  lower-severity incidents this may be the same person as the IC; for SEV1/SEV2 it should be a
  separate person.
- **Responders** — the engineers actively investigating and mitigating. Report status and findings
  to the IC rather than acting unilaterally on major decisions (like a rollback or a customer-facing
  communication) without the IC's awareness, so the IC maintains an accurate picture of what's been
  tried and what's in flight.

Roles are explicitly assigned, not assumed. The first engineer to notice an incident is not
automatically the IC forever — if a more available or more contextually appropriate person can take
it, hand it off deliberately and announce the handoff so everyone knows who's currently driving.

## Timeline discipline

- Start a timeline the moment an incident is declared — timestamped entries for what was observed,
  what was tried, what changed, and when. This is not bureaucracy for its own sake; it's the raw
  material the postmortem (see [`postmortem-guide.md`](./postmortem-guide.md)) depends on, and
  reconstructing it from memory afterward is unreliable and slow.
- Log actions taken, not just observations — "restarted service X at 14:32" is as important to
  capture as "error rate spiked at 14:28," because a later responder or the postmortem needs to know
  what's already been tried.
- Keep the timeline in one shared, real-time location visible to all responders, not scattered
  across private messages — a responder joining mid-incident should be able to read the timeline and
  get up to speed without re-asking questions already answered.

## Communication during an incident

- Update stakeholders on a predictable cadence (e.g., every 30 minutes for SEV1) even if the update
  is "still investigating, no new information" — silence during an incident is read as either
  "nothing is happening" or "it's worse than we're saying," neither of which is good for trust.
- Be factual and avoid speculation in external communication — state what's known to be affected and
  what's being done, not a guess at root cause before it's actually confirmed.
- Don't let communication overhead slow down the actual mitigation — the communications lead role
  exists specifically so responders can stay focused on fixing the problem.

## Standing down

An incident is over when the immediate user-facing impact is mitigated — not necessarily when the
underlying root cause is fully fixed. Standing down should be an explicit call by the IC, with a
clear statement of current state (fully resolved vs. mitigated with follow-up required) so nobody is
left assuming a bigger fix already happened when only a mitigation has.

## After the incident

Every SEV1 and SEV2 (and any SEV3 with useful lessons) gets a postmortem — see
[`postmortem-guide.md`](./postmortem-guide.md) — and, where the cause isn't already obvious, a
structured investigation using [`root-cause-analysis.md`](./root-cause-analysis.md). Use
[`../templates/incident-report.md`](../templates/incident-report.md) to capture the incident record
itself.
