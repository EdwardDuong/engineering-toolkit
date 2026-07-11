# Postmortem: Elevated Email Delivery Failures (INC-2026-0341)

This follows the structure of [`../templates/POSTMORTEM.md`](../templates/POSTMORTEM.md)
and the guidance in [`../docs/postmortem-guide.md`](../docs/postmortem-guide.md). This
postmortem is blameless: it exists to fix the system, not to assign fault to the people
who operated it under incomplete information.

**Incident:** [`good-incident-report.md`](good-incident-report.md) (INC-2026-0341)
**Date of incident:** 2026-06-03
**Date of postmortem:** 2026-06-06
**Author:** Oskar Lindqvist
**Reviewers:** Priya Ramanathan, Messaging Platform team

## Summary

For 108 minutes on 2026-06-03, roughly 38% of email notifications failed to send due to
our delivery workers' connection pool retrying handshakes against TLS connections that
had been invalidated by an unannounced provider-side certificate rotation. No
notifications were permanently lost — all were delivered once queued — but ~41,000 users
experienced delays of up to two hours, including a subset of time-sensitive
password-reset emails.

## Impact

- 38% email delivery failure rate, sustained for 108 minutes.
- ~41,000 users affected by delayed delivery.
- 116 support tickets filed.
- SMS and push channels unaffected; this was isolated to the email delivery worker pool.
- No permanent data loss — architecture change from [`good-adr.md`](good-adr.md) (queued,
  retryable delivery) meant every affected notification was still delivered once the fix
  landed.

## Timeline

See the full timeline in [`good-incident-report.md`](good-incident-report.md). Key
moments:

- **09:14** — Error rate begins climbing.
- **09:33** — SEV-2 declared.
- **09:41** — Provider status page checked clean, which delayed diagnosis by
  incorrectly ruling out a provider-side cause early on.
- **09:58–10:12** — Correct hypothesis formed and confirmed (stale pooled TLS
  connections not being evicted on handshake failure).
- **10:47** — Fix deployed.
- **11:02** — Fully resolved, backlog drained.

**Time to detect:** ~5 minutes (automated alert). **Time to identify root cause:** ~44
minutes from detection. **Time to mitigate:** ~35 minutes from root cause identification.

## Root Cause: Five Whys

1. **Why did 38% of emails fail to send?** Because delivery workers' TLS handshakes to
   the email provider's SMTP relay were failing.
2. **Why were the handshakes failing?** Because the provider rotated the relay's TLS
   certificate, and our workers were reusing pooled connections established under the
   old certificate.
3. **Why didn't the pool recover automatically once connections started failing?**
   Because the pool's retry logic treated handshake failure as a transient error and
   retried on the *same* pooled connection object instead of evicting it and opening a
   new one.
4. **Why did the connection pool's retry logic treat a handshake failure as
   connection-safe-to-reuse?** Because the pool was configured with a generic
   "retry on I/O error" policy that didn't distinguish handshake/certificate failures
   (which mean the connection itself is permanently unusable) from transient network
   blips (where reuse after backoff is reasonable).
5. **Why did that distinction not exist in the retry policy?** Because the connection
   pool configuration was inherited from a shared internal HTTP client library default,
   and no one on the team had reviewed whether its retry semantics were appropriate for
   long-lived SMTP connections specifically — it had never been exercised by a
   certificate rotation before this incident.

**Root cause:** The delivery workers' connection pool used a generic retry policy that
did not evict connections on TLS handshake failure, so a provider-side certificate
rotation caused a growing fraction of permanently broken pooled connections to be reused
and retried indefinitely rather than replaced.

## Contributing Factors

- The email provider did not announce the certificate rotation on their status page or
  via any channel we subscribe to, which removed an earlier opportunity to correlate the
  error spike with a known external change.
- We had no alert specifically for "handshake failure rate," only for the aggregate
  delivery failure rate, so the specific failure signature took longer to isolate than
  the failure itself took to detect.
- The connection pool's retry configuration had never been explicitly reviewed since it
  was adopted from a shared library default roughly a year earlier.

## What Went Well

- The automated SLI-based alert fired within five minutes of the error rate climbing,
  well inside our detection SLO.
- Because notification delivery is queued and retried by design (see
  [`good-adr.md`](good-adr.md)), no notification was permanently lost — the incident's
  user impact was delay, not data loss.
- Once the correct hypothesis was formed, confirmation and fix deployment were fast
  (under 50 minutes combined).

## What Went Poorly

- Initial time was spent checking the provider's public status page, which was clean and
  led the responder to (briefly) rule out a provider-side cause. This cost roughly 15
  minutes of investigation down a less productive path.
- The team had no visibility into handshake-failure rate specifically, only the coarser
  overall delivery failure rate, which made isolating the failure signature slower than
  it should have been.

## Action Items

| Action | Owner | Due date | Status |
|---|---|---|---|
| Change connection pool retry policy to evict and reconnect on TLS handshake failure rather than retrying the same connection | Oskar Lindqvist | 2026-06-10 | Done (deployed as part of incident mitigation) |
| Add a dedicated `handshake_failure_rate` metric and alert, split from generic delivery failure rate | Priya Ramanathan | 2026-06-20 | In progress |
| Audit all other long-lived connection pools in the platform (SMS provider, push provider, internal gRPC clients) for the same generic-retry-policy risk | Messaging Platform team | 2026-07-04 | Not started |
| Subscribe to the email provider's maintenance-notice mailing list, not just their status page, and route it to the on-call channel | Priya Ramanathan | 2026-06-13 | Done |
| Add a runbook entry for "email delivery failure rate spike" documenting the TLS-handshake-vs-transient-error diagnostic steps discovered during this incident | Oskar Lindqvist | 2026-06-20 | In progress |

## Lessons Learned

Generic, inherited defaults (like a shared HTTP client's retry policy) are a form of
untracked risk — they work fine until a specific failure mode they weren't designed for
occurs, and by then there's no record of anyone having made a deliberate choice about
them. The concrete follow-up is the audit action item above, but the general lesson is
that adopting a shared library default is itself a decision worth briefly recording, even
when — especially when — the default seems obviously reasonable at the time.
