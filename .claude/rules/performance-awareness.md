# Rule: Performance Awareness

Consider algorithmic complexity and I/O cost as you write code, especially
in hot paths. Performance is cheapest to get right at design time and most
expensive to retrofit after the fact — not because fixing it is hard, but
because by then behavior has been built on top of the slow version.

This is not a mandate to micro-optimize everything. It's a mandate to not be
accidentally, needlessly wasteful, and to know the difference between code
where performance matters and code where it doesn't.

## What to consider by default

- **Algorithmic complexity.** Know the Big-O of the code you write,
  especially for anything operating on collections that can grow. An O(n²)
  operation on a list that's always 5 items is fine; the same code applied
  to user-generated data is a latent incident.
- **I/O cost.** Database queries, network calls, and file I/O are orders of
  magnitude more expensive than in-memory operations. Watch for:
  - N+1 query patterns (a query inside a loop that could be one batched
    query).
  - Redundant calls to the same external service for data that doesn't
    change within the operation.
  - Fetching more data than needed (unbounded queries, missing pagination,
    `SELECT *` where specific columns would do).
- **Hot paths deserve more scrutiny.** Code that runs on every request, in a
  tight loop, or at high volume warrants more care than code that runs once
  at startup or in an admin-only, low-traffic path. Know which kind of code
  you're writing before deciding how much this matters.

## When to profile vs. when to trust judgment

- **Trust judgment** for: obvious algorithmic choices (don't use a linear
  scan when a hash lookup is natural and available), avoiding N+1 queries,
  not doing redundant work inside a loop. These don't need measurement to
  justify — they're free or near-free to get right the first time.
- **Profile before optimizing** when: the "obvious" fix would add real
  complexity (caching, batching, denormalization, async processing) and you
  don't yet have evidence that the current code is actually a bottleneck.
  Don't pay complexity cost for a performance problem you haven't confirmed
  exists.
- **Never guess on a claimed regression.** If a change is suspected of
  causing a performance regression, measure before and after rather than
  reasoning about it in the abstract — intuition about performance is
  wrong often enough that it isn't a substitute for a number.

## Practical check

Before finishing a change that touches a loop, a query, or a hot path, ask:
does this do more work than necessary for the common case? If yes, is that
because the simple version is genuinely necessary, or because it wasn't
considered? The former is fine; the latter is worth five minutes to fix now
rather than as an incident later.

See [docs/performance-guide.md](../../docs/performance-guide.md) for
project-level performance standards, budgets, and profiling tooling.
