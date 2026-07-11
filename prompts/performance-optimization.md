# Performance Optimization

Guide an AI assistant through a profiling-first performance investigation:
establish a baseline, find the bottleneck with evidence, then propose a
targeted fix.

## Purpose

The default failure mode for AI-assisted performance work is guessing —
rewriting a loop, adding caching, or "optimizing" code that wasn't actually
the bottleneck. This prompt requires a measured baseline and evidence of
where time/resources actually go before any change is proposed, and
requires expected impact to be stated so it can be checked afterward.

## When to use

- A specific performance complaint exists (slow endpoint, high latency,
  high resource usage) and you need to find the actual bottleneck.
- Before optimizing anything "because it looks slow" — this prompt is
  designed to resist that instinct.
- Evaluating whether a proposed optimization is worth its complexity cost.

## The prompt

```markdown
You are investigating a performance issue. Do not propose an optimization
until you have established a baseline and identified the bottleneck with
evidence. Premature optimization based on assumption, not measurement, is
explicitly out of scope for this task.

## Context
- Performance complaint: {{performance_issue}}
- Where it's observed (endpoint, function, job, query): {{location}}
- Current measured behavior, if known (latency, throughput, resource
  usage): {{current_metrics}}
- Target/acceptable performance, if defined: {{target_metrics}}
- Profiling/tracing tools available in this environment: {{available_tools}}

## Step 1 — Establish a baseline
Before changing anything:
- State the current measured performance (latency percentiles,
  throughput, CPU/memory/IO usage, query time) — from real data if
  available, or specify exactly what to measure and how if it isn't yet
  captured.
- State the conditions under which this was measured (load level, data
  volume, environment) so the baseline is reproducible.
- If no baseline exists yet, treat producing one as the first deliverable,
  not an optional nice-to-have.

## Step 2 — Identify the bottleneck with evidence
- Use profiling/tracing data (flame graphs, query plans, APM traces, timing
  logs) to identify where time or resources are actually spent — not where
  it looks like they should be spent.
- State the specific hot path: function, query, network call, or resource
  contention point, with supporting evidence (percentage of total time,
  call count, resource delta).
- Rule out red herrings explicitly: if something looked suspicious but the
  evidence doesn't support it being the bottleneck, say so.

## Step 3 — Propose an optimization
For the confirmed bottleneck only:
- Propose a specific change (algorithmic change, query/index change,
  caching, batching, parallelism, reduced allocation, etc.).
- State the expected impact quantitatively where possible ("reduces N+1
  queries from ~200 to 1," "expected to cut p95 latency by roughly X%
  based on the profile").
- State the tradeoff: added complexity, memory/storage cost, staleness (for
  caching), or maintainability impact.
- Explicitly flag if the expected impact is small relative to the
  complexity added — that's a signal not to do it.

## Step 4 — Verify
After implementing, state how to re-measure using the same conditions as
the baseline, and compare before/after numbers directly. Confirm the
optimization achieved the expected impact — if it didn't, say so rather
than declaring success by assumption.

## Constraints
- Do not propose optimizing code that isn't confirmed to be on the hot
  path, even if it "looks inefficient."
- Do not trade correctness or readability for a marginal, unmeasured gain.
```

## Expected output

- A stated, reproducible baseline (real numbers or an explicit plan to
  capture them).
- A bottleneck identification backed by profiling/tracing evidence, with
  red herrings explicitly ruled out.
- An optimization proposal with quantified expected impact and stated
  tradeoffs.
- A verification step comparing before/after under the same conditions.

## Tips & pitfalls

- If the assistant proposes a fix before Step 2's evidence is in hand,
  push back — "where in the profile does this show up?" is a fair
  question to ask before accepting any change.
- Watch for optimizations justified by intuition ("this should be faster")
  rather than the actual profile — intuition about performance is wrong
  often enough that it isn't a substitute for measurement.
- Small, unmeasured "while I'm in here" optimizations are a common way
  this task scope-creeps — keep the change scoped to the confirmed
  bottleneck.
- See [`../docs/performance-guide.md`](../docs/performance-guide.md) for
  profiling tool recommendations and this repo's performance baselines.
