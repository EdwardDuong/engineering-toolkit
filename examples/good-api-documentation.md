# Notification Service API Reference

This follows the guidance in [`../docs/api-design-guide.md`](../docs/api-design-guide.md).

**Base URL:** `https://api.internal.example/notifications/v1`
**Status:** Stable (v1)

## Overview

The Notification API accepts requests to deliver a notification to a user over email,
SMS, or push, and exposes read endpoints for checking delivery status. It is an internal
service — callers are other backend services within the organization, not end users or
third parties.

All request and response bodies are JSON. All timestamps are ISO 8601 UTC
(`2026-07-11T14:32:05Z`).

## Authentication

Callers authenticate with a service-to-service bearer token issued by the internal
identity provider:

```
Authorization: Bearer <service-token>
```

Tokens are scoped per calling service (e.g. `checkout-service`) and are tied to a rate
limit and an allowlist of template IDs that service is permitted to send. Requests using
templates outside a token's allowlist are rejected with `403 forbidden_template`, even if
the caller is otherwise authenticated correctly — this prevents one team's compromised
token from being used to send arbitrary notifications on another team's behalf.

## Endpoints

### `POST /notifications`

Submit a notification for delivery. Returns immediately once the request is durably
recorded and enqueued; delivery itself happens asynchronously.

**Request:**

```json
{
  "idempotency_key": "chk-8841203-order-confirmed",
  "template_id": "order-confirmation-v3",
  "channel": "email",
  "recipient": {
    "user_id": "usr_9f31ab"
  },
  "params": {
    "order_id": "8841203",
    "order_total": "84.50",
    "currency": "USD",
    "estimated_delivery": "2026-07-15"
  }
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `idempotency_key` | string | yes | Caller-generated. Deduplicated for 24 hours; a retry with the same key returns the original result without re-sending. |
| `template_id` | string | yes | Must be a published, active template version the caller's token is scoped to. |
| `channel` | string | yes | One of `email`, `sms`, `push`. Must be a channel the template supports. |
| `recipient.user_id` | string | yes | Internal user identifier. The service resolves the actual address/number/device token itself — callers never pass raw contact info. |
| `params` | object | no | Template substitution variables. Validated against the template's declared schema; unknown or missing required fields return `422`. |

**Response — `202 Accepted`:**

```json
{
  "notification_id": "ntf_6b21e9d4",
  "status": "accepted",
  "created_at": "2026-07-11T14:32:05Z"
}
```

**Response — `409 Conflict`** (idempotency key reused with a different payload):

```json
{
  "error": "idempotency_key_conflict",
  "message": "idempotency_key chk-8841203-order-confirmed was already used with a different request body.",
  "original_notification_id": "ntf_6b21e9d4"
}
```

### `GET /notifications/{notification_id}`

Fetch the current delivery status of a previously submitted notification.

**Response — `200 OK`:**

```json
{
  "notification_id": "ntf_6b21e9d4",
  "status": "sent",
  "channel": "email",
  "template_id": "order-confirmation-v3",
  "created_at": "2026-07-11T14:32:05Z",
  "sent_at": "2026-07-11T14:32:11Z",
  "attempts": 1
}
```

`status` transitions through `accepted` → `sending` → one of `sent`, `bounced`,
`failed`, or `suppressed` (blocked by a user preference or suppression list — this is a
terminal, non-retryable state).

### `GET /notifications`

List notifications, filterable by recipient, status, or time range. Primarily used by
internal support tooling.

**Query parameters:** `user_id`, `status`, `channel`, `since`, `until`, `limit` (default
50, max 200), `cursor` (opaque pagination token returned in the previous response's
`next_cursor` field).

**Response — `200 OK`:**

```json
{
  "results": [
    { "notification_id": "ntf_6b21e9d4", "status": "sent", "channel": "email", "created_at": "2026-07-11T14:32:05Z" }
  ],
  "next_cursor": "eyJvZmZzZXQiOjUwfQ=="
}
```

## Error Codes

| HTTP status | Error code | Meaning |
|---|---|---|
| 400 | `malformed_request` | Request body failed JSON schema validation. |
| 401 | `unauthenticated` | Missing or invalid bearer token. |
| 403 | `forbidden_template` | Caller's token is not scoped to the requested `template_id`. |
| 404 | `notification_not_found` | No notification exists with the given ID, or it belongs to a different caller. |
| 409 | `idempotency_key_conflict` | The idempotency key was reused with a different request body. |
| 422 | `invalid_params` | `params` did not satisfy the template's declared parameter schema. |
| 429 | `rate_limited` | Caller exceeded its per-token rate limit. `Retry-After` header is set. |
| 503 | `service_unavailable` | The service could not durably persist the request (e.g. datastore unavailable) and is failing closed rather than accepting an unrecorded request. |

## Rate Limits

Each service token is limited to 500 requests/second sustained, 1,000/second burst.
Limits are returned on every response via `X-RateLimit-Limit`, `X-RateLimit-Remaining`,
and `X-RateLimit-Reset` headers.

## Versioning

The API is versioned in the URL path (`/v1`). Breaking changes (removing a field,
changing a field's type, changing error semantics) will only ship under a new version
path; `v1` is guaranteed stable. Additive, backward-compatible changes (new optional
fields, new enum values in non-exhaustive contexts) may ship to `v1` without a version
bump, consistent with [`../docs/api-design-guide.md`](../docs/api-design-guide.md).
Deprecated versions are supported for a minimum of six months after the successor version
ships, announced in the internal API changelog.
