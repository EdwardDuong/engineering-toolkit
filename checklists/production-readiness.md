# Production Readiness Checklist

Run this before a new service, feature, or significant change first runs in production, or before an existing one takes meaningfully more traffic. Owned by the team operating the system. This is broader than a release checklist — it asks "can we operate this," not just "did it ship correctly."

## Observability

- [ ] Logging, metrics, and tracing are in place per [../docs/observability-guide.md](../docs/observability-guide.md)
- [ ] Key business and system metrics are visible on a dashboard, not just in raw logs
- [ ] Logs contain enough context (request IDs, user/tenant IDs where appropriate) to debug a single failed request

## Alerting

- [ ] Alerts exist for symptoms that matter to users (error rate, latency, saturation), not just infrastructure noise
- [ ] Alert thresholds have been tuned to avoid known false-positive conditions
- [ ] Alerts route to the team that can actually act on them

## Operations

- [ ] A runbook exists covering common failure modes and how to respond
- [ ] Load and capacity have been considered for expected and peak traffic
- [ ] Rollback has actually been tested, not just documented
- [ ] Resource limits (CPU, memory, connections, rate limits) are configured, not left at defaults
- [ ] Dependencies (databases, queues, third-party APIs) have documented failure behavior (timeout, retry, circuit breaker)

## Security & readiness

- [ ] Security review is complete for anything new-surface-area (see [security-review.md](security-review.md))
- [ ] On-call is briefed on what's launching and knows how to reach someone with deep context if needed
- [ ] Access controls (who can deploy, who can access data) are set to least privilege
