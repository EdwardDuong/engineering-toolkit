# ADR-0007: Use an Asynchronous Message Queue for Cross-Service Notification Delivery

This follows the structure of [`../templates/ADR.md`](../templates/ADR.md).

**Status:** Accepted
**Date:** 2026-02-18
**Deciders:** Messaging Platform team (Priya Ramanathan, Oskar Lindqvist), with input from
Checkout Platform and Account Platform teams
**Related:** [`good-architecture-doc.md`](good-architecture-doc.md)

## Context

The notification service accepts requests from upstream services (checkout-service,
auth-service, billing-service, and others) and delivers them through external email, SMS,
and push providers. Today, the API handler calls the relevant provider synchronously
before returning a response to the caller.

This is causing three concrete problems:

1. **Availability coupling.** Our email provider had two partial outages in the last
   quarter (P50 latency spiking to 8s, then to a hard timeout). Because delivery is
   synchronous, checkout-service's order-confirmation call blocked on our provider call,
   which meant *our* provider's incident degraded *checkout-service's* checkout
   completion latency. That is an unacceptable blast radius for a non-critical-path
   notification.
2. **Retry storms.** When a provider call times out, some callers retry the whole
   request. Because the original call may have actually succeeded on the provider side
   just slowly, this produces duplicate sends — three teams have separately reported
   customers receiving the same email twice.
3. **No isolation between channels.** A slow SMS provider currently delays the thread
   pool that also serves email requests, because they share request-handling capacity.

We need a delivery architecture where accepting a notification request is fast and
reliable regardless of external provider health, and where a slow or failing channel
cannot degrade other channels or the callers' own request paths.

## Decision

We will decouple **acceptance** from **delivery** using an asynchronous message queue.

The API will validate the request, persist it, and publish a delivery job to a
channel-specific queue, then return a 202-style "accepted" response immediately. Separate
delivery worker pools — one per channel — will consume jobs from their queue, call the
external provider, and record the outcome. Callers that need delivery confirmation will
poll a status endpoint or subscribe to a webhook, rather than receiving it synchronously.

Idempotency keys, supplied by the caller and enforced at the API layer, will prevent the
retry-storm duplication problem independently of this change, but the queue-based design
is what removes the availability coupling and cross-channel interference.

## Consequences

**Positive:**

- Upstream callers are no longer exposed to provider latency or outages; a
  notification-service or provider incident can no longer cause a checkout-flow
  slowdown.
- Per-channel queues mean an SMS provider outage has zero effect on email delivery
  throughput.
- Retry and backoff logic now lives in exactly one place (the delivery workers) instead
  of being reimplemented, inconsistently, by every calling team.
- Queue depth becomes a clean, direct signal of delivery health that we can alert on.

**Negative / trade-offs:**

- Callers lose synchronous delivery confirmation. Any caller that genuinely needs to know
  "was this delivered" before proceeding (we don't currently have one, but might in the
  future) will need to poll or handle a webhook instead of reading a response body.
- The system now has an additional moving part (the queue) that must itself be operated,
  monitored, and capacity-planned.
- End-to-end delivery latency for the common case increases slightly — typically under a
  second in practice, but no longer zero — because of the extra queue hop. This is
  acceptable given our documented p95 delivery-initiation SLO of 30 seconds.
- Debugging a delivery issue now requires tracing across two hops (API write, then worker
  consumption) instead of one, so we are investing in a correlation ID that's threaded
  through both stages and surfaced on the operational dashboard.

## Alternatives Considered

- **Keep synchronous calls, add per-provider circuit breakers.** Would reduce blast
  radius somewhat but doesn't solve cross-channel interference (both providers still
  share the same request-handling thread pool) and doesn't remove the fundamental
  coupling between our uptime and the provider's uptime. Rejected as treating a symptom
  rather than the underlying design flaw.
- **Synchronous calls with a short timeout and background retry only on failure.**
  Reduces worst-case latency exposure but still means normal-case latency for every
  caller is bounded by provider latency, and doesn't address duplicate-send risk from
  ambiguous timeout outcomes. Rejected because it keeps the coupling for the common
  case, not just the failure case.
- **Dedicated queue per upstream caller instead of per channel.** Would give even finer
  isolation but multiplies operational complexity (dozens of queues instead of three) for
  a benefit we don't currently need — no caller has asked for delivery guarantees
  independent of the channel's own health. Revisit if a caller's traffic pattern
  actually threatens to starve others sharing a channel queue.
- **Do nothing, treat duplicate sends and latency coupling as caller-side bugs.**
  Rejected outright; the recurring incidents across three independent teams indicate a
  systemic issue in our API contract, not isolated caller mistakes.

## Follow-Ups

- Define and publish the webhook payload contract for delivery status (tracked
  separately; targeted for the same release).
- Establish queue-depth alerting thresholds per channel before this ships to
  production traffic.
