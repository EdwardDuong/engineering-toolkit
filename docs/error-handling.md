# Error Handling

How a system responds to things going wrong says more about its engineering quality than how it
behaves on the happy path — the happy path is what everyone tests; error handling is what determines
whether a bad day stays a minor incident or becomes an outage.

## Fail-fast vs. graceful degradation

Both are legitimate strategies; the right one depends on what failing silently would cost versus
what stopping entirely would cost.

- **Fail-fast** — stop immediately and surface the error clearly when a precondition is violated or
  an invariant would otherwise be broken. Appropriate when continuing with bad state would cause
  worse downstream damage than stopping — e.g., refusing to process a payment if the amount can't be
  validated, rather than guessing.
- **Graceful degradation** — continue operating with reduced functionality when a non-critical
  dependency fails, rather than failing the entire request. Appropriate when partial functionality
  is genuinely better than none — e.g., a product page that omits personalized recommendations if
  the recommendation service is down, rather than failing to load the page at all.
- The failure mode to avoid on both ends: **silently continuing as if nothing happened** (masking a
  real failure with a default value with no record it occurred) and **failing an entire operation
  over a non-critical component** (treating an optional dependency as if it were required). Both are
  decisions, and both should be deliberate, not the accidental result of a broad try/catch or a
  missing check.
- Decide fail-fast vs. degrade **per dependency, based on whether it's on the critical path for the
  operation**, not as a single blanket policy for the whole system.

## Error propagation vs. swallowing

- **Never silently swallow an error** — catching an exception or checking an error return and doing
  nothing with it (no log, no re-throw, no explicit decision to ignore) destroys the information
  that something went wrong. The failure will resurface later, disconnected from its actual cause,
  and cost far more time to diagnose than it would have cost to handle at the source.
- **Propagate errors with enough context to be actionable** at the level that can actually act on
  them. A low-level function catching an error and re-throwing a generic "something went wrong"
  discards the information the caller needs to decide what to do. Wrap and add context as an error
  crosses a meaningful boundary (e.g., "failed to charge payment: card network timeout" is more
  useful three layers up than a bare timeout exception with no domain context).
- **Handle an error at the layer that knows what to do about it, not the layer that happened to
  catch it first.** A data-access function usually doesn't know whether a "record not found" should
  become a 404, a default value, or a retry — that's a decision for the layer that understands the
  business context.
- **Explicitly decide, and document, when it's correct to ignore an error.** Some failures genuinely
  don't matter (a non-critical analytics call failing shouldn't fail the user-facing request it's
  attached to) — but that should be a visible, commented decision, not an accidental omission
  indistinguishable from a bug.

## User-facing vs. internal error messages

- **Internal**: full detail — stack trace, exact failure point, internal identifiers, the specific
  dependency that failed. This goes to logs (see [`logging-standards.md`](./logging-standards.md))
  and internal monitoring, where the audience is engineers who need to diagnose the problem.
- **User-facing**: enough for the user to understand what happened and what to do next, without
  exposing implementation detail that's meaningless to them and potentially useful to an attacker
  (see [`security-guide.md`](./security-guide.md)). "We couldn't process your payment — please check
  your card details and try again" is useful; a raw database constraint violation message is not,
  and may leak schema information.
- **Correlate the two.** A user-facing error should include a reference (a correlation ID, an error
  reference code) that support or engineering can use to look up the full internal detail, so the
  sanitization for the user's benefit doesn't also blind whoever investigates the report.
- **Be honest about what the system knows.** Don't tell a user "please try again" if the error is
  deterministic and retrying will always fail the same way — that just wastes their time and
  generates support load. Distinguish retryable from non-retryable failure classes explicitly in the
  error contract — see [`api-design-guide.md`](./api-design-guide.md).

## Retries, backoff, and circuit breakers

- **Only retry operations that are safe to retry** — idempotent operations, or non-idempotent ones
  protected by an idempotency key (see [`api-design-guide.md`](./api-design-guide.md)). Retrying a
  non-idempotent operation blindly can cause duplicate side effects (double-charging, duplicate
  notifications).
- **Only retry failure classes that are plausibly transient** — a network timeout or a 503 is worth
  retrying; a validation error or a 404 will fail identically every time and retrying wastes time
  and load without any chance of success.
- **Use exponential backoff with jitter**, not a fixed retry interval. A fixed interval causes
  synchronized retry storms when many clients fail at the same moment (e.g., after a brief outage);
  jitter spreads the retries out so the recovering system isn't immediately hit with a coordinated
  spike from everyone at once.
- **Cap retry attempts and total retry duration explicitly.** Unbounded retries turn a transient
  failure into an indefinitely hanging operation and can quietly pile up resource usage (open
  connections, queued requests) behind the scenes.
- **Use a circuit breaker for calls to a dependency that's failing persistently**, not just
  occasionally. Once a dependency's failure rate crosses a threshold, stop calling it for a cooldown
  period and fail fast instead — this protects both your own system (not tying up resources on calls
  that are very likely to fail) and the struggling dependency (not adding retry-amplified load on
  top of whatever's already wrong with it).
- **Combine timeouts with retries deliberately.** A retry policy without a sane per-attempt timeout
  can multiply a single slow call into many slow calls stacked back to back, taking far longer to
  fail than a single attempt would have — set a timeout appropriate to the operation, not a default
  inherited from an unrelated part of the system.

## See also

- [`observability-guide.md`](./observability-guide.md) — how error rates and retry behavior should
  be surfaced as metrics.
- [`incident-response.md`](./incident-response.md) — what happens when error handling itself fails
  (cascading failures, retry storms) at production scale.
