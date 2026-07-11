# Performance Review Checklist

Run this for any change touching a hot path, a high-traffic endpoint, a data-processing pipeline, or anything with a stated latency/throughput requirement. Run by the change's author, ideally with a reviewer who knows the system's performance characteristics. Pair with [../prompts/performance-optimization.md](../prompts/performance-optimization.md) for a structured investigation.

## Baseline

- [ ] Current (pre-change) performance was actually measured, not assumed
- [ ] The measurement uses realistic data volume and shape, not a toy dataset
- [ ] A target or budget for latency/throughput/resource use is stated, not left implicit

## Hot paths

- [ ] Code on the hot path has been profiled, not optimized by guesswork
- [ ] Expensive operations (serialization, crypto, regex, reflection) on the hot path are justified or avoided
- [ ] Synchronous I/O on a path that could be async/batched has been reconsidered

## Data access

- [ ] No N+1 query pattern was introduced (one query per item in a loop)
- [ ] Queries touching large tables use appropriate indexes (see [database-review.md](database-review.md))
- [ ] Pagination or limits are applied to anything that could return unbounded results
- [ ] Caching is used where appropriate, with a defined invalidation strategy

## Resource use

- [ ] Memory use doesn't grow unbounded with input size or over the process lifetime
- [ ] Concurrency/parallelism limits are set explicitly (thread pools, connection pools, worker counts)
- [ ] Resource limits (timeouts, max payload size, rate limits) are considered for abuse and edge cases

## Verification

- [ ] Post-change measurement confirms the target is met, using the same method as the baseline
- [ ] Regression or load tests exist to catch future degradation, where the risk warrants it
