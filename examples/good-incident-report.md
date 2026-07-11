# Incident Report: Elevated Email Delivery Failures — Notification Service

This follows the structure of [`../templates/incident-report.md`](../templates/incident-report.md).

**Incident ID:** INC-2026-0341
**Status:** Resolved
**Severity:** SEV-2
**Started:** 2026-06-03 09:14 UTC
**Resolved:** 2026-06-03 11:02 UTC
**Incident Commander:** Oskar Lindqvist
**Communications Lead:** Priya Ramanathan

## Summary

Between 09:14 and 11:02 UTC, approximately 38% of email notifications (order
confirmations, password resets, shipping updates) failed to send. Root cause was
exhaustion of the connection pool to our primary email provider after a provider-side
TLS certificate rotation invalidated cached connections without the pool detecting the
failure as retryable. SMS and push channels were unaffected.

## Impact

- **Affected users:** An estimated 41,000 users experienced a delayed or missing email
  notification during the window.
- **Affected notification types:** Order confirmations, password-reset emails,
  shipping-update emails. Password-reset failures were flagged as the highest-priority
  subset, since a failed reset directly blocks account access.
- **Not affected:** SMS and push channels delivered normally throughout. Notifications
  accepted by the API were not lost — they remained queued and were delivered
  automatically once the fix was deployed, so no notification was silently dropped, but
  many were delayed by up to two hours.
- **Customer-facing signal:** 116 support tickets referencing "didn't get my email"
  were filed during and shortly after the window.

## Timeline

All times UTC on 2026-06-03.

| Time | Event |
|---|---|
| 09:14 | Email delivery worker error rate begins climbing (from baseline ~0.2% to 12%, then higher). Automated alert fires on the `email_delivery_failure_rate` SLI. |
| 09:19 | On-call engineer (Oskar) acknowledges the page, begins investigating delivery worker logs. |
| 09:27 | Errors identified as TLS handshake failures against the email provider's SMTP relay, not application-level rejections. |
| 09:33 | SEV-2 declared. Incident channel opened. Priya joins as communications lead. |
| 09:41 | Provider status page checked — no reported provider-side incident at this time, which ruled out an obvious external cause and slowed initial diagnosis. |
| 09:58 | Hypothesis formed: provider rotated a TLS certificate and our connection pool is reusing now-invalid cached connections rather than establishing fresh ones on handshake failure. |
| 10:12 | Confirmed by forcing a connection pool flush on one delivery worker instance in isolation — error rate on that instance dropped to baseline immediately. |
| 10:20 | Fix identified: force a full connection pool recycle across all email delivery workers, plus a configuration change so handshake failures trigger connection eviction instead of retry-on-same-connection. |
| 10:31 | Status update posted to internal stakeholders: root cause identified, fix in progress, ETA ~30 minutes. |
| 10:47 | Pool recycle deployed to all delivery worker instances. Error rate begins dropping immediately. |
| 10:55 | Error rate back to baseline (<0.3%). Queue backlog (accumulated during the incident) draining normally. |
| 11:02 | Backlog fully drained, all delayed notifications delivered. Incident declared resolved. |

## Root Cause (preliminary)

The email provider rotated a TLS certificate on their SMTP relay endpoint at
approximately 09:12 UTC without a corresponding maintenance notice. Our delivery
workers' connection pool held long-lived, keep-alive connections established before the
rotation. Once the old certificate was invalidated, new handshakes on those pooled
connections failed — but the pool's retry logic treated the failure as transient and
retried against the *same* pooled (now-permanently-broken) connection rather than
evicting it and establishing a fresh one. This produced a growing fraction of failing
connections until enough of the pool was exhausted to affect over a third of traffic.

A full contributing-factor analysis and corrective actions are recorded in the companion
postmortem: [`good-postmortem.md`](good-postmortem.md).

## Current Status

Resolved. All notifications queued during the incident window were delivered
successfully by 11:02 UTC with no data loss. A permanent fix (evict-on-handshake-failure
connection pool behavior) has been deployed to production. Follow-up action items are
tracked in the postmortem.

## Communications Sent

- 09:33 — Internal incident channel opened, initial notice to stakeholder teams
  (Checkout Platform, Account Platform) that email delivery is degraded.
- 10:31 — Update: root cause identified, fix in progress.
- 11:05 — Resolution notice: incident resolved, all delayed notifications delivered,
  postmortem to follow within 5 business days per [`../docs/postmortem-guide.md`](../docs/postmortem-guide.md).
