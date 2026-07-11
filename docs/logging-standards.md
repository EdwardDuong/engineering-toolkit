# Logging Standards

Logs are the primary tool for understanding what a system actually did, after the fact, without
being able to re-run it. Inconsistent or noisy logs make that reconstruction slow exactly when speed
matters most — during an incident.

## Structured logging

- Log in a structured format (key-value pairs or JSON), not free-form text sentences.
  `event="payment_failed" order_id="..." reason="card_declined"` can be filtered, aggregated, and
  alerted on programmatically; `"Payment failed for order because card was declined"` can only be
  grepped, and inconsistently at that once phrasing drifts across the codebase.
- Every log entry should carry consistent baseline fields regardless of where it's emitted:
  timestamp (UTC, ISO 8601), severity level, service/component name, and a correlation ID (see
  below). Inconsistent baseline fields make cross-service log aggregation and querying unreliable.
- Log messages should be static/templated with data in fields, not string-interpolated into the
  message itself — `event="user_login_failed"` with a `user_id` field, not `f"login failed for
  {user_id}"`. This keeps the message stable and groupable across occurrences while the specific
  data remains queryable.

## Log levels

Use levels consistently so filtering by severity is meaningful, not noise:

- **ERROR** — something failed that requires attention; an operation did not complete as intended,
  and a human or automated system may need to act. Reserve for genuine failures, not
  expected/handled conditions.
- **WARN** — something unexpected happened but the system recovered or degraded gracefully (a retry
  succeeded, a fallback was used, a deprecated code path was hit). Worth noticing in aggregate, not
  worth waking someone up over a single occurrence.
- **INFO** — normal operational events worth recording for audit or understanding system behavior (a
  request was handled, a job started/completed, a state transition occurred). Should be useful to a
  human scanning logs to understand what the system is doing, without being overwhelming.
- **DEBUG** — detailed diagnostic information useful when actively investigating a specific issue,
  not meant to run at full volume in production continuously (or if it does, sampled/rate-limited).

A system where everything is logged at INFO (or everything at ERROR) has effectively no levels —
filtering by severity becomes useless, and the signal that should stand out during an incident is
buried in routine noise. Treat level misuse as a code review item, not a matter of individual taste.

## Correlation IDs

- Every request entering the system should be assigned (or should propagate, if already assigned
  upstream) a correlation ID that's attached to every log line produced while handling it, across
  every service it touches.
- Propagate the correlation ID across service boundaries explicitly (a header, a message attribute)
  — without this, reconstructing a single request's path through a distributed system means
  correlating logs by timestamp and guesswork, which doesn't scale past a handful of services.
- Include the correlation ID in error responses returned to callers (internal or external) where
  feasible, so a bug report or support ticket can be tied directly back to the exact log trail,
  instead of an engineer trying to find the right log entry by approximate time and description.
- This is the foundation that makes distributed tracing (see
  [`observability-guide.md`](./observability-guide.md)) possible — a correlation ID is effectively
  the minimum viable trace ID.

## What must never be logged

- **Secrets** — passwords, API keys, tokens, private keys, database connection strings with embedded
  credentials. If a secret could conceivably end up in a request body, header, or exception being
  logged, it must be explicitly redacted before logging, not logged "for now" and cleaned up later.
- **PII beyond what's operationally necessary** — full names, email addresses, phone numbers,
  physical addresses, government IDs, and similar should be omitted or masked/truncated unless
  there's a specific, justified operational need for that exact field in that exact log. Prefer
  logging an opaque internal identifier (a user ID) that can be looked up by someone with proper
  access, rather than the identifying data itself.
- **Payment and financial account details** — card numbers, bank account numbers. Even
  partial/masked versions should follow whatever compliance standard applies to the domain (e.g.,
  last-four-digits-only conventions), not an ad hoc masking scheme invented per log call site.
- **Full request/response bodies for sensitive endpoints** — logging an entire payload "for
  debugging" on an endpoint that handles authentication or payment data is a common way sensitive
  data ends up retained in log storage far longer, and with far less access control, than the
  primary datastore.

Treat "we might need it for debugging" as insufficient justification on its own for logging
sensitive data — the debugging value has to be weighed against the retention and access-control cost
of every log store now holding that data indefinitely. When in doubt, log the reference (an ID) and
make the underlying record retrievable through an access-controlled lookup instead of the primary
data itself.

## Retention and access

- Log retention should follow the same discipline as any other data retention — see the
  sensitive-data guidance in [`database-guidelines.md`](./database-guidelines.md). Logs are data,
  and unbounded log retention is unbounded exposure if the log store is ever compromised.
- Access to logs containing anything beyond routine operational data should be restricted and
  audited, not open to the entire engineering organization by default.

## See also

- [`observability-guide.md`](./observability-guide.md) — how logs fit alongside metrics and traces.
- [`security-guide.md`](./security-guide.md) — the broader sensitive-data handling principles this
  doc's redaction guidance draws from.
- [`incident-response.md`](./incident-response.md) — logs are usually the first thing an incident
  responder reaches for; standards followed consistently now are what make that fast later.
