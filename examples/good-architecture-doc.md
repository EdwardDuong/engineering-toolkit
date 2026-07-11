# Architecture: Notification Service

**Status:** Living document — last reviewed 2026-05-12
**Owners:** Messaging Platform team
**Related:** [`good-adr.md`](good-adr.md) · [`../docs/architecture-principles.md`](../docs/architecture-principles.md)

## Context and Goals

The notification service is the single system responsible for delivering user-facing
notifications — order updates, security alerts, marketing opt-ins — across email, SMS,
and push channels. Before this service existed, each of the seven product teams called
provider APIs directly from their own backends, which meant retry logic, template
rendering, and unsubscribe handling were each implemented (and each buggy) seven
different ways.

Goals for this system:

- **One integration point.** Any internal service sends a single `POST /v1/notifications`
  request; this service owns provider selection, formatting, and delivery.
- **At-least-once delivery** for transactional notifications (order confirmations,
  password resets), with idempotency so retries don't double-send.
- **Respect user preferences and suppression lists** in one place, so opt-outs and legal
  holds can't be bypassed by a team that forgot to check them.
- **Observable delivery state.** Any support engineer should be able to answer "did this
  notification reach the user?" without reading application logs.

## Non-Goals

- This service does not compose notification *content* beyond template substitution — it
  is not a marketing campaign builder or a rich CMS.
- It does not guarantee real-time (sub-second) delivery. The SLO is p95 delivery
  initiation under 30 seconds; this is a reliability-first system, not a low-latency one.
- It does not own the customer's contact-preference *UI* — it only enforces preferences
  that other systems write into the shared preference store.

## High-Level Components

```
                     ┌─────────────────┐
  Upstream services  │   API Gateway    │
  (checkout-service, ├─────────────────┤
   auth-service, ...) │  Notification    │──▶ writes ──▶ ┌───────────────┐
        │            │  API (stateless) │               │  Primary       │
        └───POST────▶│                  │◀──reads───────│  datastore     │
                     └────────┬─────────┘               │  (requests,    │
                              │ publishes                │  templates,    │
                              ▼                          │  prefs cache)  │
                     ┌─────────────────┐                 └───────────────┘
                     │  Message queue   │
                     │  (delivery jobs) │
                     └────────┬─────────┘
                              ▼
                   ┌──────────────────────┐
                   │  Delivery workers     │
                   │  (per-channel pools:  │
                   │   email / sms / push) │
                   └──────────┬────────────┘
                              ▼
                   ┌──────────────────────┐
                   │  External providers   │
                   │  (email, SMS, push     │
                   │   gateways)            │
                   └──────────────────────┘
```

- **Notification API** — a thin, stateless HTTP layer. Validates the request, checks
  suppression/preference state, persists a `notification_request` record, and enqueues a
  delivery job. It does not talk to providers directly.
- **Primary datastore** — a Postgres-like relational store holding notification requests,
  their delivery status, message templates, and a read-through cache of user preferences
  (source of truth for preferences lives in the account service; we cache to avoid a
  synchronous cross-service call on the hot path).
- **Message queue** — decouples acceptance from delivery. One queue per channel so a
  slow SMS provider can't back up email delivery.
- **Delivery workers** — channel-specific worker pools that consume jobs, render the
  final payload from a template, call the external provider, and write the resulting
  status (`sent`, `failed`, `bounced`) back to the datastore.
- **Status webhook receiver** — a small internal endpoint that ingests asynchronous
  delivery receipts (bounces, opens) from providers and updates request status.

## Key Design Decisions

- **Async delivery via a queue, not synchronous provider calls.** Provider APIs are
  slower and less reliable than our own uptime target. Decoupling acceptance from
  delivery means a caller gets a fast, reliable "accepted" response even during a
  provider outage. See [`good-adr.md`](good-adr.md) for the full rationale.
- **One queue per channel.** Early load testing showed a single shared queue let SMS
  provider slowness starve email delivery entirely (head-of-line blocking on a FIFO
  queue). Per-channel queues isolate that failure mode at a small cost in operational
  surface area.
- **Idempotency keys are mandatory on the API.** Callers must supply a client-generated
  `idempotency_key`; the API deduplicates on it for 24 hours. This was a direct response
  to checkout-service's retry-on-timeout behavior, which previously caused duplicate
  order-confirmation emails.
- **Preferences are cached, not looked up live.** A synchronous call to the account
  service on every notification would make this service's availability a function of a
  dependency it doesn't own. We accept up to five minutes of staleness on preference
  changes in exchange for that isolation, refreshed via an event feed from the account
  service.
- **Templates are versioned and immutable once published.** A template in flight through
  the queue must render identically regardless of edits made after it was enqueued, so a
  notification always references a specific template version, not "latest."

## Data Flow

1. An upstream service calls `POST /v1/notifications` with a template ID, recipient
   reference, channel hint, and idempotency key.
2. The API checks the idempotency key, checks the cached suppression/preference state
   for the recipient, and persists a `notification_request` row with status `accepted`.
3. A delivery job referencing that row is published to the channel-specific queue.
4. A delivery worker picks up the job, renders the template with the supplied
   parameters, calls the appropriate external provider, and updates the row to `sent` or
   `failed` (with a retry re-enqueued on transient failure — see below).
5. If the provider later reports a bounce or delivery failure asynchronously, the status
   webhook receiver updates the row to `bounced` and, for hard bounces, writes a
   suppression entry so future sends to that address are blocked automatically.

## Failure Modes and Mitigations

| Failure mode | Mitigation |
|---|---|
| External provider is down or rate-limiting | Delivery workers apply exponential backoff with jitter and requeue; after a configured max-attempt threshold the request is marked `failed` and surfaced on the operational dashboard rather than retried indefinitely. |
| Message queue backlog grows during a provider outage | Per-channel queue depth is an alerting SLI; sustained backlog pages the on-call engineer before user-visible SLA breach. |
| Preference cache is stale, notification sent after a user opted out | Preference change events carry a strict ordering guarantee per user; worst-case staleness window is bounded and documented (five minutes) so it is a known, accepted trade-off rather than a silent bug. |
| Duplicate delivery from an upstream retry | Idempotency key deduplication at the API layer rejects duplicate `notification_request` creation within a 24-hour window. |
| A bad template deploy renders broken output | Templates are versioned and validated against a schema at publish time; a request always pins a specific template version, so a bad new version affects only requests created after it, and can be rolled back independently of the delivery pipeline. |
| Datastore primary becomes unavailable | The API fails closed (returns 503) rather than accepting requests it can't durably record — losing acceptance availability is preferable to silently dropping notifications. |

## Open Questions

- Whether push notification delivery should move to its own dedicated worker pool
  sized independently of email/SMS, given its materially different traffic shape
  (bursty, campaign-driven) — tracked as a follow-up ADR candidate.
- Long-term retention policy for `notification_request` history is still under
  discussion with the data governance group.
