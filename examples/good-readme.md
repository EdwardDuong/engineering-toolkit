# notification-service

This follows the structure of [`../templates/project-readme.md`](../templates/project-readme.md). It
illustrates what a concise, genuinely useful service README looks like once it's filled
in, as opposed to left as a scaffold.

---

Delivers user-facing notifications (email, SMS, push) on behalf of internal services,
with a single API, centralized preference/suppression enforcement, and asynchronous,
retryable delivery.

## Why this exists

Before this service, each product team called email/SMS/push providers directly from
their own backends. That meant retry logic, unsubscribe handling, and delivery tracking
were each implemented — and each buggy — independently, seven different times. This
service centralizes that into one integration point. See
[`good-architecture-doc.md`](good-architecture-doc.md) for the full design.

## Status

Stable. API v1 is production and used by checkout-service, auth-service, and
billing-service. See the [API reference](good-api-documentation.md) for the current
contract.

## Getting Started

### Prerequisites

- A recent LTS runtime for the platform's primary language (see `.tool-versions`)
- Access to the primary datastore (Postgres-compatible) and the message queue —
  local development uses containerized versions of both, started via the compose file
  below
- A sandbox API key for the email/SMS/push provider integrations (request from the
  Messaging Platform team's onboarding doc; production keys are never used locally)

### Setup

```bash
git clone <repository-url>
cd notification-service
cp .env.example .env        # fill in sandbox provider keys
docker compose up -d        # starts local datastore + queue
make install
make migrate
```

### Running locally

```bash
make run
```

The API is available at `http://localhost:8080`. A sample request:

```bash
curl -X POST http://localhost:8080/v1/notifications \
  -H "Authorization: Bearer $LOCAL_DEV_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "idempotency_key": "local-test-1",
        "template_id": "order-confirmation-v3",
        "channel": "email",
        "recipient": { "user_id": "usr_test" },
        "params": { "order_id": "1", "order_total": "9.99", "currency": "USD" }
      }'
```

### Running tests

```bash
make test          # unit tests
make test-integration   # requires docker compose services running
```

## Project Structure

```
/api            HTTP handlers and request validation
/delivery       channel-specific delivery workers (email, sms, push)
/templates      template rendering and schema validation
/preferences    preference cache and suppression list logic
/migrations     datastore schema migrations
```

## Configuration

All runtime configuration is via environment variables, documented in `.env.example`.
Secrets (provider API keys, datastore credentials) are never committed; local
development uses sandbox credentials, production credentials are injected by the
deployment platform's secret manager.

## Deployment

Deploys are triggered automatically on merge to the trunk branch after CI passes, following
[`../docs/release-process.md`](../docs/release-process.md). Each delivery worker pool
(email, SMS, push) can be deployed and rolled back independently of the API and of each
other, since they're isolated by design — see the architecture doc's failure-mode table.

## Observability

- Dashboards: delivery success/failure rate by channel, queue depth by channel, p95
  delivery-initiation latency.
- Alerts: failure rate above 2% sustained for 5 minutes, queue depth above 10,000 for
  any channel, datastore write error rate above 0.
- On-call runbook: see the internal runbook index (linked from the service's on-call
  handoff doc).

## Contributing

See [`../CONTRIBUTING.md`](../CONTRIBUTING.md) for general conventions. Before opening a
PR, run `make lint test`. PRs should follow
[`../templates/pull-request.md`](../templates/pull-request.md) — see
[`good-pull-request.md`](good-pull-request.md) for a worked example.

## Related Documents

- [Architecture](good-architecture-doc.md)
- [API reference](good-api-documentation.md)
- [ADR: async delivery via message queue](good-adr.md)
- [Postmortem: INC-2026-0341](good-postmortem.md)

## Owners

Messaging Platform team. Paged via the `notification-service` on-call rotation.

## License

Internal use only — not licensed for external distribution.
