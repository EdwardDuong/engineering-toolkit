# Example Pull Request: Add Exponential Backoff Retry to Notification Delivery Worker

This follows the structure of [`../templates/pull-request.md`](../templates/pull-request.md).
It illustrates what a genuinely reviewable PR description looks like, as opposed to a
one-line "fixes bug" summary.

---

**Title:** Add exponential backoff with jitter to email delivery worker retries

**Related:** INC-2026-0341 · [`good-postmortem.md`](good-postmortem.md) · Action item
"change connection pool retry policy"

## Summary

Delivery workers currently retry a failed provider call immediately, up to 3 times, with
no delay between attempts. During the June 3rd incident (and in smaller-scale form on
previous provider blips), this produced retry bursts that arrived at the provider at the
worst possible moment — while it was already degraded — making recovery slower than
necessary. This PR replaces the immediate fixed-count retry with exponential backoff plus
jitter, and separately fixes the connection pool to evict a connection after a TLS
handshake failure instead of reusing it (the direct root cause of INC-2026-0341).

## Approach

- Replaced the hand-rolled retry loop in `delivery_worker.send()` with the shared
  `retry_with_backoff()` utility already used elsewhere in the platform, configured with
  a base delay of 200ms, a multiplier of 2, a cap of 10s, and ±20% jitter.
- Capped total retry attempts at 5 (previously 3) since each attempt is now
  meaningfully spaced out rather than immediate, so a slightly higher ceiling doesn't
  meaningfully increase worst-case latency.
- Changed the connection pool's error classifier so that `TLSHandshakeError` and
  `CertificateError` are treated as "connection unusable" (evict and open fresh) rather
  than "transient" (retry same connection) — this was the actual fix for the incident
  itself; the backoff change is the broader hardening it prompted.
- Added a `retry_attempt` label to the existing delivery metrics so we can distinguish
  first-attempt failures from retry failures on the dashboard going forward.
- Did **not** change SMS or push worker retry logic in this PR — they use a separate
  code path and are out of scope; tracked as a follow-up.

## Alternatives Considered

- **Circuit breaker instead of backoff.** Would more aggressively stop sending traffic to
  a clearly-down provider, but is a larger behavior change with its own failure modes
  (e.g., false-positive tripping on a brief blip) and wasn't necessary to address the
  specific incident. Considered as a future enhancement, not bundled into this fix.
- **Just raise the retry count without backoff.** Rejected — this would have made the
  retry-burst problem worse, not better, since more immediate retries arrive at the
  provider even faster.

## Testing Performed

- Unit tests added for the new backoff schedule (delay sequence, jitter bounds, max
  attempt enforcement) in `delivery_worker_test`.
- Unit test added asserting `TLSHandshakeError` triggers connection eviction, not reuse,
  in the connection pool's error classifier — this test would have caught the original
  root cause.
- Ran the existing delivery worker integration suite against a local mock provider
  configured to fail the first N requests, confirmed workers now recover with the
  expected spaced-out retry pattern instead of an immediate burst.
- Manually verified in staging by forcing the mock provider to return TLS handshake
  errors for 60 seconds and confirming the worker's error rate recovered within one
  polling interval of the fault clearing, with no manual pool restart required.
- Load-tested the backoff change at 2x normal traffic in staging to confirm the slightly
  higher max-attempt ceiling (5 vs. 3) doesn't cause queue depth to grow unbounded under
  sustained partial failure.

## Rollout / Rollback Plan

- Change is behind no feature flag — it's a strict improvement to existing retry
  behavior with no API or schema change, so it ships directly.
- Deploying to the email delivery worker pool first (already partially validated by the
  incident hotfix), then SMS and push worker pools in separate follow-up PRs once this
  pattern is confirmed stable for one week.
- **Rollback:** a straight revert of this PR restores the previous fixed-count immediate
  retry behavior. No data migration or backward-incompatible state is introduced, so
  rollback is a standard deploy-previous-version operation with no additional steps.
- Dashboards to watch post-deploy: `email_delivery_failure_rate`,
  `email_delivery_retry_attempt` (new), and queue depth for the email channel queue.

## Screenshots / Evidence

Staging dashboard showing retry attempts spaced per the new backoff schedule during the
forced-failure test (200ms, ~400ms, ~800ms, ~1.6s, ~3.2s, with jitter) — attached in the
PR's CI artifact bundle, not reproduced here.

## Checklist

- [x] Tests added/updated and passing
- [x] Postmortem action item linked (INC-2026-0341)
- [x] No new external dependencies introduced
- [x] Rollback plan documented above
- [x] Dashboards/alerts identified for post-deploy monitoring
