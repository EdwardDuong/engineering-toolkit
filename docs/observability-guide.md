# Observability Guide

Observability is the ability to answer a question about your system's internal state that you didn't
anticipate asking in advance, using data the system already emits. Monitoring tells you *that*
something is wrong; observability is what lets you figure out *why*, without shipping new
instrumentation mid-incident.

## The three pillars

- **Logs** — discrete, timestamped records of specific events. Best for understanding exactly what
  happened for a specific request or entity. See [`logging-standards.md`](./logging-standards.md)
  for format and content standards.
- **Metrics** — numeric measurements aggregated over time (counters, gauges, histograms). Best for
  understanding trends, rates, and thresholds cheaply at scale — request rate, error rate, latency
  percentiles, queue depth, resource utilization. Cheap to store and query even at very high volume
  because they're pre-aggregated, but they can't tell you about one specific request.
- **Traces** — the path of a single request as it moves through multiple components/services, with
  timing for each step (spans). Best for understanding where time actually goes in a distributed
  operation and which downstream call is responsible for latency or failure. A trace is, in effect,
  a set of correlated log events plus timing, tied together by a shared identifier — see the
  correlation ID discussion in [`logging-standards.md`](./logging-standards.md).

No single pillar substitutes for the others. Metrics tell you latency spiked at 14:02; traces tell
you it was the third downstream call in the chain; logs tell you that specific call failed because
of a specific malformed input. Design instrumentation with all three in mind from the start of a
component's life, not bolted on reactively after the first incident that needed them.

## SLIs and SLOs

- A **Service Level Indicator (SLI)** is a specific, measured metric that reflects user-perceived
  quality — e.g., "percentage of requests served in under 300ms," "percentage of requests that
  return a successful status." Choose SLIs that reflect what a user actually experiences, not
  internal implementation metrics that happen to be easy to measure.
- A **Service Level Objective (SLO)** is a target threshold for an SLI over a time window — e.g.,
  "99.5% of requests succeed within 300ms, measured over a rolling 28 days." The SLO is the number
  that determines whether the system is healthy enough, not the raw SLI value at any single instant.
- Pick a small number of SLOs per user-facing capability — availability and latency are the
  near-universal starting pair. More than a handful per service usually means the SLOs aren't
  actually being used to make decisions, just accumulated.
- An SLO defines an **error budget**: the acceptable amount of failure within the window. When the
  error budget is being consumed faster than the window allows, that's the trigger to slow down
  risky changes and prioritize reliability work — a mechanism, not just a dashboard number. This
  connects directly to [`release-process.md`](./release-process.md): a service that has exhausted
  its error budget for the period is a legitimate reason to pause non-critical releases.

## Alert on symptoms, not causes

- **Alert on user-facing symptoms**: elevated error rate, latency breaching an SLO, a queue backing
  up past a threshold that will cause user-visible delay. These indicate something a user or
  downstream consumer is actually experiencing.
- **Do not alert on every possible internal cause independently.** A single root cause (a downstream
  dependency degrading) can trigger a dozen internal-cause alerts (connection pool near limit, retry
  rate up, CPU up, one specific endpoint slow) simultaneously — paging on all of them produces alert
  fatigue and buries the signal of what actually needs a human's attention. Alert once, on the
  symptom that matters to users, and use the other signals as diagnostic data available during
  investigation, not as separate pages.
- **Every alert that pages someone should be actionable.** If an alert fires and the correct
  response is always "nothing, this is expected, ignore it," that alert should be deleted or its
  threshold fixed, not left to erode trust in the alerting system generally — an on-call engineer
  who's been paged by noise ten times will be slower to react on the eleventh page that's real.
- **Tie alert severity to actual urgency.** Not every anomaly needs to wake someone up at 3 a.m. —
  see the severity framework in [`incident-response.md`](./incident-response.md) for calibrating
  what warrants immediate response versus next-business-day investigation.

## Instrumentation discipline

- Instrument at the boundary of every component: incoming request, outgoing call to a dependency,
  and any operation with a meaningfully variable cost (a database query, a batch job step).
- Emit metrics with bounded, known-cardinality labels. A label with unbounded cardinality (e.g., a
  raw user ID or full URL as a metric label) can silently overwhelm a metrics backend — use it in a
  log or trace instead, where high cardinality is expected and handled differently.
- Treat dashboards as a reviewed artifact, not a personal scratchpad — the primary operational
  dashboard for a service should be understandable by any on-call engineer, not only the person who
  built it.
- Validate new instrumentation actually fires and reports sensible values before relying on it
  during an incident — untested observability code is the worst time to discover a bug, because you
  find out exactly when you need the data most.

## See also

- [`logging-standards.md`](./logging-standards.md) — the detailed standard this doc's logging pillar
  draws from.
- [`incident-response.md`](./incident-response.md) — how alerts and dashboards feed into declaring
  and running an incident.
- [`engineering-metrics.md`](./engineering-metrics.md) — organizational/process metrics (DORA),
  distinct from the system-level SLIs covered here.
