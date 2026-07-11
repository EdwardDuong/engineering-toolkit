# Root Cause Analysis

Root cause analysis is the discipline of finding the actual conditions that allowed an incident to
happen, deep enough that fixing them prevents recurrence — not just the first thing that broke, and
not a person to hold responsible.

## Why "root cause" is usually plural

Most real incidents are not caused by a single root cause but by a combination of contributing
factors that individually would not have caused an incident, and together did. A deploy introduced a
bug (factor one), the test suite didn't cover that code path (factor two), the monitoring for that
metric had too high a threshold to catch it quickly (factor three), and the on-call engineer wasn't
familiar enough with the runbook to mitigate quickly once paged (factor four). Naming only "a bug
was deployed" as the root cause and fixing only that misses three other places where a future,
different bug will slip through the same way. Good root cause analysis surfaces all the contributing
factors worth addressing, not just the most proximate one.

## 5 Whys

A simple technique for pushing past the first, most obvious explanation: ask "why" repeatedly, each
time addressing the answer to the previous question, until you reach something that's actually
actionable to fix — typically 4-6 iterations, not always exactly five.

Example:

1. Why did the checkout page return errors? → The payment service was rejecting requests.
2. Why was the payment service rejecting requests? → It had run out of database connections.
3. Why did it run out of database connections? → A new code path opened a connection per request and
   never closed it.
4. Why wasn't that caught before release? → The load test suite doesn't run long enough to exhaust
   the connection pool at normal request volume.
5. Why doesn't the load test suite run long enough? → It was originally scoped for burst-load
   testing only; nobody revisited it as a soak test after connection-pool-related incidents became a
   recurring pattern.

Notice the technique reached an actionable, systemic finding (the load test suite's scope, and the
process gap of not revisiting it after a relevant pattern emerged) rather than stopping at "an
engineer forgot to close a connection," which isn't something a fix can meaningfully target — see
[`postmortem-guide.md`](./postmortem-guide.md) on avoiding blame as the stopping point.

**Caution**: 5 Whys follows a single causal chain. It works well when there's genuinely one linear
path to the failure, and works poorly when the incident had multiple independent contributing
factors that a single chain of "why" questions won't surface — use the fishbone technique below when
the failure looks more like a convergence of several factors than a single chain.

## Fishbone / contributing-factors analysis

For incidents with multiple independent or interacting causes, map contributing factors across
categories rather than following one chain:

- **People/process** — was there a gap in training, an unclear or unfollowed procedure, an unclear
  ownership boundary?
- **Systems/technology** — what code, infrastructure, or tooling behaved unexpectedly or was missing
  a needed safeguard?
- **Detection** — how long did it take to notice, and could monitoring or alerting have caught it
  sooner (see [`observability-guide.md`](./observability-guide.md))?
- **Prevention** — what check (a test, a review step, an automated gate) could plausibly have caught
  this before it reached production?

For each contributing factor identified, ask whether addressing it would have prevented the
incident, reduced its impact, or sped up detection/recovery — factors that would do none of these
are context, not action items, and don't need a fix, just documentation in the postmortem for
completeness.

## Avoiding root-cause-as-blame

The most common way root cause analysis fails is stopping at a person instead of a system: "the
engineer made a mistake" is rarely a useful stopping point, because it implies the fix is "don't
make mistakes," which isn't actionable and doesn't prevent recurrence when the next person is under
the same conditions.

- **Ask what allowed the mistake to have impact, not just that a mistake happened.** People will
  always make mistakes; the systemic question is why the system didn't catch it — missing test
  coverage, no review requirement for that kind of change, no staged rollout that would have limited
  the blast radius. Those are all fixable; "be more careful" is not a durable fix.
- **Treat every "why" answer that names a person's individual action as incomplete, and push one
  level further.** "Because Alex deployed without running the full test suite" is not the end of the
  chain — ask why that was possible (was it not required by CI?) and why it wasn't caught before it
  caused impact (was there no staged rollout?).
- **This is not the same as excusing negligence.** If a genuine, willful violation of a known safety
  process occurred, that's a separate conversation from root cause analysis — but the vast majority
  of incidents are the result of reasonable people operating under incomplete information or systems
  with gaps, not negligence, and treating them as the former when they're the latter erodes the
  psychological safety that makes people willing to report and investigate incidents honestly in the
  first place.

## Where findings go

Root cause and contributing-factor findings feed directly into the postmortem document — see
[`../templates/POSTMORTEM.md`](../templates/POSTMORTEM.md) and
[`postmortem-guide.md`](./postmortem-guide.md) for how findings become tracked, owned action items
rather than a list of interesting observations that nobody follows up on.
