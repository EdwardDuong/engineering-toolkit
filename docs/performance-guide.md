# Performance Guide

Performance work done without measurement is guessing. This guide covers how to set performance
expectations, how to find real bottlenecks instead of assumed ones, and the anti-patterns that cause
the most common production slowdowns.

## Performance budgets

A performance budget is an agreed, explicit threshold for a metric that matters to users or to
system stability — set before you need it, not improvised after a complaint.

- Define budgets in terms users or downstream systems actually experience: p50/p95/p99 latency for a
  request path, time-to-first-byte, job completion time, memory ceiling per instance — not internal
  implementation metrics nobody outside the team understands.
- Set budgets per critical path, not one global number. A background batch job and a user-facing
  checkout request have very different acceptable latencies; a single blanket target either
  over-constrains the batch job or under-protects checkout.
- A budget is a gate, not a suggestion: a change that would blow the budget needs either a justified
  exception (recorded, see [`adr-guide.md`](./adr-guide.md)) or doesn't ship as-is.
- Revisit budgets periodically against actual user expectations and competitive context — a budget
  set two years ago against different traffic patterns or hardware may no longer reflect what
  "acceptable" means today.

## Profile before optimizing

Intuition about where time goes in a system is frequently wrong, especially past a codebase's early
stages. The discipline is:

1. **Measure first.** Use a profiler, tracing, or targeted timing instrumentation to find where time
   and resources actually go, under conditions that resemble production (data volume, concurrency)
   as closely as practical.
2. **Identify the actual bottleneck**, not the most suspicious-looking code. The function that
   "feels slow" to read is frequently not the one consuming the most time; the one making a
   synchronous call to an external system usually is.
3. **Optimize the bottleneck, then re-measure.** Optimizing a path that wasn't the bottleneck can
   still pass code review (it's not wrong, exactly) while delivering zero user-visible improvement —
   the fastest way to burn a sprint on invisible work.
4. **Stop when the budget is met.** Continuing to optimize past the point where the metric that
   matters is satisfied trades engineering time and code clarity for a gain nobody will notice — see
   [`kiss-principle.md`](./kiss-principle.md) on the cost of unnecessary complexity, which premature
   or excessive optimization routinely introduces (unclear code in exchange for a speedup below the
   noise floor).

Optimizing without profiling first is the single most common way engineering time gets spent with no
measurable outcome. If you can't point to a profile, trace, or benchmark justifying a
performance-motivated change, the change is speculative.

## Common anti-patterns

- **N+1 queries** — issuing one query to fetch a list, then one additional query per item in the
  list to fetch related data, instead of fetching the related data in bulk. This is invisible in
  development with small datasets and catastrophic in production with real ones; it's the single
  most common data-layer performance bug across virtually every stack.
- **Unbounded loops and unbounded result sets** — processing or fetching "all of X" with no limit,
  page size, or cutoff. Fine at 100 records, a production incident at 10 million. Always paginate or
  bound anything whose size is determined by user or external data, not by a constant you control.
- **Synchronous I/O on hot paths** — blocking a request-handling thread/process on a network call,
  disk write, or external API when the volume of concurrent requests could exhaust the available
  workers. Prefer async I/O, background processing, or explicit timeouts and backpressure on any hot
  path that talks to an external system.
- **Missing or wrong indexes** — a query that's correct but scans far more data than it needs to
  because the underlying store has no index supporting its access pattern. See
  [`database-guidelines.md`](./database-guidelines.md).
- **Chatty inter-service calls** — a single logical operation that fans out into many small network
  calls to other services instead of one batched call, multiplying latency by network round-trip
  count instead of doing the work once.
- **Unbounded caching or no caching where repeated computation is expensive** — both extremes cause
  problems: no caching re-does expensive work every time; unbounded caching grows memory until the
  process is killed. Bound cache size and eviction explicitly.
- **Premature serialization/deserialization** — converting data between formats repeatedly across a
  call chain instead of once at the boundary, especially costly for large payloads processed
  multiple times.

## Load and performance testing

- Test at a load that resembles realistic peak, not just realistic average — average load rarely
  breaks a system; peak load (a sale event, a retry storm, a batch job overlapping normal traffic)
  does.
- Include a soak/sustained-load test in addition to a burst test — some failure modes (memory leaks,
  connection pool exhaustion, gradual queue backup) only appear after sustained load, not an
  instantaneous spike.
- Test failure and degraded conditions, not just the happy path at scale — what happens to latency
  and error rate when a downstream dependency is slow or unavailable under load, not just when
  everything is healthy.
- Run performance tests against an environment as close to production configuration as feasible
  (comparable hardware/instance sizing, comparable data volume) — a load test against an undersized
  or over-provisioned environment produces numbers that don't transfer.
- Automate performance regression detection where the budget is critical enough to warrant it — a
  scheduled or CI-gated benchmark that fails the build (or pages someone) when a budget is breached
  catches regressions before they reach production, rather than relying on someone noticing a
  dashboard drift.

## See also

- [`../checklists/performance-review.md`](../checklists/performance-review.md) — the review
  checklist for performance-sensitive changes.
- [`../prompts/performance-optimization.md`](../prompts/performance-optimization.md) — a structured
  prompt for investigating and fixing a specific performance problem.
- [`observability-guide.md`](./observability-guide.md) — how ongoing performance is monitored in
  production, not just tested pre-release.
