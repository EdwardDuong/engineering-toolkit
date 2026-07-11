# Examples

Every file in this folder is a worked example — a template from [`templates/`](../templates/)
filled in completely, for a realistic (fictional) scenario, so you can see what "good"
looks like before you write your own. None of these are blank scaffolds; treat them as
reference output, not something to copy verbatim.

All examples share one continuous fictional scenario for coherence: **notification-service**,
an internal service that delivers email, SMS, and push notifications on behalf of other
backend services (such as a fictional `checkout-service`). The architecture doc, ADR, API
reference, incident report, postmortem, pull request, and README all describe the same
system at different points in its life, and cross-link to each other where it's natural —
the incident report and postmortem describe the same event, and the pull request
implements one of the postmortem's action items.

## Index

| Example | Illustrates | Template |
|---|---|---|
| [`good-architecture-doc.md`](good-architecture-doc.md) | A living architecture document for the notification service: components, key design decisions, data flow, and failure modes. | See [`../docs/architecture-principles.md`](../docs/architecture-principles.md) |
| [`good-adr.md`](good-adr.md) | An Architecture Decision Record for choosing asynchronous, queue-based delivery over synchronous provider calls. | [`../templates/adr.md`](../templates/adr.md) |
| [`good-api-documentation.md`](good-api-documentation.md) | A complete API reference for the notification service's HTTP endpoints, including request/response examples and error codes. | See [`../docs/api-design-guide.md`](../docs/api-design-guide.md) |
| [`good-incident-report.md`](good-incident-report.md) | A live-incident-style report for a real-time email delivery outage, with a timeline and impact assessment. | [`../templates/incident-report.md`](../templates/incident-report.md) |
| [`good-postmortem.md`](good-postmortem.md) | A blameless postmortem for the same incident: five-whys root cause, contributing factors, and owned action items. | [`../templates/postmortem.md`](../templates/postmortem.md) |
| [`good-pull-request.md`](good-pull-request.md) | A pull request description implementing one of the postmortem's action items, with testing and rollback plans. | [`../templates/pull-request.md`](../templates/pull-request.md) |
| [`good-readme.md`](good-readme.md) | A concise, genuinely useful service README for the notification-service repository itself. | [`../templates/project-readme.md`](../templates/project-readme.md) |

## How to use these

- Reading one in isolation should be enough to understand its scenario — you don't need
  to read all seven to make sense of any one of them.
- If you're about to fill in a template and aren't sure how much detail is expected, open
  the matching example first. The level of specificity here (concrete numbers,
  named failure modes, real trade-offs) is the bar, not an exaggeration of it.
- These are intentionally verbose relative to what a fast-moving team might write in
  practice. Treat them as the "what good looks like fully worked out" version; it's
  always easier to trim a thorough example down than to pad a thin one out.
