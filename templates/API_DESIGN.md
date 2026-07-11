<!--
Template: API Design
Use this when: designing a new API surface, or changing an existing one significantly enough to
need a reviewable contract before implementation — not every endpoint addition needs this, but any
change classified as breaking (or ambiguous) under ../docs/workflows/api-change.md does.
Related: ../docs/api-design-guide.md, ../docs/workflows/api-change.md, ../docs/semantic-versioning.md,
../.claude/commands/security-audit.md.
-->

# API Design: [API or endpoint name]

**Status:** [Draft | In review | Approved | Shipped]
**Owner:** [Name]
**API version:** [e.g., v2, or "new" for a first version]

## Context

<!-- What this API is for, who calls it (internal service, external integrator, first-party client),
     and what currently exists if this changes an existing contract. -->

[Describe the consumers of this API and what they need from it. If this changes an existing
contract, state the current contract and who's known to depend on it.]

## Problem

<!-- The specific capability gap or contract flaw this API design addresses. -->

[What can't a consumer currently do, or do safely/efficiently, that this API design enables? If
this is fixing a contract problem (ambiguous error handling, missing pagination, a leaky
abstraction), state the concrete failure mode it causes today.]

## Decision

<!-- The actual contract: endpoints, request/response shape, versioning approach, and error
     semantics. Precise enough to implement and to review for backward compatibility. -->

**Endpoints:**

```
[METHOD] /path/to/resource
```

**Request:**
```json
{
  "field": "type — description, required/optional, validation constraint"
}
```

**Response (success):**
```json
{
  "field": "type — description"
}
```

**Response (error):** [error shape, following the project's standard error contract per
../docs/api-design-guide.md — status code, error code, message field]

**Versioning approach:** [how this fits ../docs/semantic-versioning.md and
../docs/workflows/api-change.md — new version path, additive-only change, or a breaking change with
a stated deprecation plan for the old contract]

**Idempotency:** [is this operation safe to retry? How — an idempotency key, natural idempotency
(GET, PUT-by-ID), or explicitly not idempotent and why that's acceptable here]

**Pagination / limits:** [if the response can grow unbounded, the pagination mechanism and any
rate limit or payload size limit]

## Alternatives

<!-- Other contract shapes considered, and why this one was chosen. -->

### [Alternative shape — e.g., a single endpoint with a mode flag instead of two endpoints]

[What it was, and the specific reason it was rejected — e.g., "conflates two operations with
different auth requirements into one endpoint, making the authorization check harder to reason
about and test."]

### [Alternative versioning approach, if relevant]

[e.g., "considered an additive-only change instead of a new version, but the response shape change
for existing consumers is ambiguous enough under ../.claude/rules/backward-compatibility.md to
treat as breaking."]

## Risks

<!-- What this contract could get wrong, especially around consumers and security. -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Breaking an existing consumer that wasn't identified] | [L/M/H] | [L/M/H] | [...] |
| [New endpoint expands attack surface — e.g., new unauthenticated-by-default path] | [L/M/H] | [L/M/H] | [...] |
| [Response shape leaks more data than intended to some consumers] | [L/M/H] | [L/M/H] | [...] |

## Validation

<!-- How the contract is verified correct and safe before and after shipping. -->

- **Security review:** run [`/security-audit`](../.claude/commands/security-audit.md) — required
  for any new or changed endpoint per ../.claude/agents/security-engineer.md; confirm
  authentication and per-resource authorization explicitly, not assumed from a shared middleware.
- **Contract testing:** [how the request/response shape is verified against this spec —
  schema validation, contract tests, or example-based tests]
- **Backward-compat verification:** [for a changed contract, how existing consumers were confirmed
  unaffected — a consumer-driven contract test, a staged rollout with monitoring, or an explicit
  list of consumers who confirmed compatibility]
- **Consumer sign-off:** [for a breaking change, who from each known consumer confirmed they can
  migrate on the proposed timeline]

## Ownership

- **API owner:** [name/team — accountable for this contract's stability going forward]
- **Reviewers:** [names — should include a security review per the Validation section above]
- **Consumers to notify:** [teams/systems that need to know about this change, and how they'll be
  notified — changelog entry, direct message, deprecation header]
