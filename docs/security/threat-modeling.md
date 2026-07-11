# Threat Modeling

[`../security-guide.md`](../security-guide.md) gives a four-question lightweight threat model
suitable for most changes. This document expands on when that's enough, when it isn't, and how to
run a more structured pass (STRIDE) for the changes that warrant it — with a worked example.

Threat modeling is not a security-team-only activity. It's a design step, most effective run by the
engineer building the system with domain knowledge of what it actually does, ideally with a second
perspective (a peer, or [`/security-audit`](../../.claude/commands/security-audit.md)) to catch
blind spots the builder is too close to see.

## When lightweight is enough, and when it isn't

Use the four-question version from [`../security-guide.md`](../security-guide.md) for most
changes. Escalate to a structured STRIDE pass when any of these are true:

- The change introduces a new trust boundary or system boundary (see
  [`../architecture-review.md`](../architecture-review.md)'s triggers — the same threshold that
  calls for architecture review usually calls for a structured threat model too).
- The system handles payment data, authentication credentials, or regulated data (health, financial,
  data covered by a specific compliance regime).
- The blast radius question in the lightweight model comes back "severe" — full account
  compromise, cross-tenant data exposure, financial loss.
- This is the first time a new pattern (a new integration type, a new class of external caller) is
  being introduced, since whatever gap exists here is likely to be copied by everything that
  follows it.

## STRIDE, applied practically

STRIDE is a mnemonic for six threat categories. For each component or data flow in the system under
review, ask whether each category applies:

- **Spoofing** — can an attacker convincingly pretend to be someone or something they're not (a
  user, another service, a trusted caller)?
- **Tampering** — can data be modified in a way that isn't detected, in transit or at rest?
- **Repudiation** — can an action be taken without leaving a reliable, attributable record — could
  someone plausibly deny having done it?
- **Information disclosure** — can data be exposed to someone not entitled to see it?
- **Denial of service** — can the system, or a specific resource within it, be made unavailable to
  legitimate users?
- **Elevation of privilege** — can an actor gain more access than they were granted?

Run this component-by-component and data-flow-by-data-flow rather than for the system as a whole
at once — "is this vulnerable to spoofing" is nearly unanswerable for an entire system, but very
answerable for "can a caller of this specific internal API convincingly claim to be a different
service."

## Common vulnerabilities threat modeling catches early

- **Missing trust boundaries** — a data flow diagram often reveals that data crosses from
  untrusted to trusted context somewhere nobody had explicitly noticed, because the crossing
  happens inside a component that "obviously" only receives internal traffic (until a future
  change adds a new caller).
- **Implicit trust in "internal" callers** — the single most common finding in a first threat
  model: a service assumes every caller reaching it is already authenticated/authorized because
  it's not directly internet-facing, when in fact any compromised component on the same network
  could reach it too.
- **Single points of authorization failure** — a design where one check, in one place, is the only
  thing preventing a wide-blast-radius action, discovered by tracing what happens if that one
  check has a bug or is bypassed.
- **Undetectable tampering** — data that travels or is stored without integrity verification,
  where a modification would go unnoticed until it causes a downstream failure or is exploited.

## Review questions

1. **Draw or describe the actual data flow — where does data enter, where does it get stored,
   where does it leave?** A threat model without an accurate data flow is guessing.
2. **At each point data crosses a boundary, what verifies it's coming from where it claims to come
   from?**
3. **If an attacker fully controlled the least-trusted component in this flow, what's the worst
   thing they could do to the most-trusted one?**
4. **Which STRIDE categories were considered and explicitly ruled out, versus not considered at
   all?** A model that only lists the threats that were found, with no record of what was
   deliberately ruled out and why, can't be trusted by a future reviewer to have been thorough.
5. **What's the cheapest mitigation that closes the highest-severity gap found**, and is it being
   applied before this ships or deliberately deferred as a tracked risk?

## Worked example

**System**: a notification delivery service that accepts a request from internal services
("send this user an email/SMS/push") and delivers it via third-party providers — the same system
used as the running example in [`../../examples/good-architecture-doc.md`](../../examples/good-architecture-doc.md).

**Data flow**: `checkout-service → notification-service API → message queue → delivery workers →
third-party provider (email/SMS/push) → end user`.

**STRIDE pass on the `checkout-service → notification-service API` boundary:**

- **Spoofing**: could a compromised or malicious internal service call the notification API
  claiming to be `checkout-service`? → Mitigation: service-to-service authentication (mutual TLS or
  signed service tokens), not just "it's on the internal network."
- **Tampering**: could the notification payload be modified in transit within the internal
  network? → Mitigation: internal traffic encrypted in transit even though it's "internal."
- **Repudiation**: if a notification was sent that shouldn't have been, can we determine which
  caller requested it? → Mitigation: every request logged with the authenticated caller identity,
  not just the notification content.
- **Information disclosure**: does the API response leak more than the caller needs (e.g.,
  internal delivery-worker routing detail)? → Reviewed: response is minimal by design.
- **Denial of service**: can one caller's burst of requests exhaust the queue or worker pool for
  every other caller? → Mitigation: per-caller rate limiting and queue isolation.
- **Elevation of privilege**: can a caller request a notification "on behalf of" an arbitrary
  internal service by setting a field in the request? → Mitigation: caller identity comes from the
  authenticated service token, never from a client-supplied field.

This is the level of specificity a useful threat model produces: a named boundary, a named
category, a concrete answer, and either a mitigation or an explicit, reasoned "not applicable."

## Prevention strategies

- **Threat model at design time, using [`../../templates/TECHNICAL_DESIGN.md`](../../templates/TECHNICAL_DESIGN.md)'s
  Risks section as the place this analysis gets recorded**, not as a separate document nobody
  reads alongside the design it applies to.
- **Keep the threat model alive as the system changes** — a threat model written once at launch
  and never revisited misses every new trust boundary introduced by later features; revisit it at
  the same trigger points that call for architecture review.
- **Prefer a structured pass with a documented "ruled out" list over an unstructured brainstorm** —
  the discipline of explicitly working through STRIDE per boundary catches gaps an open-ended
  "what could go wrong" conversation tends to miss, because it forces coverage rather than
  following whatever's top of mind.
- **Feed findings directly into [`secure-development-checklist.md`](secure-development-checklist.md)'s
  design-stage items** and, for anything that can't be fully mitigated before shipping, into
  [`../risk-assessment.md`](../risk-assessment.md) as an explicitly tracked and owned risk.
