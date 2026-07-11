# Security Review

Guide an AI assistant through a security review of code or a design, mapped
loosely to OWASP-style categories: injection, authN/authZ, secrets handling,
and dependency vulnerabilities.

## Purpose

Security issues are cheapest to catch before merge, and an AI assistant can
systematically check categories a rushed human review skips. This prompt
structures the review around concrete, well-known vulnerability classes
instead of a vague "check for security issues" pass that tends to miss
everything but the obvious.

## When to use

- Reviewing code that handles user input, authentication, authorization,
  or sensitive data.
- Reviewing a design/RFC for security implications before implementation
  (pair with [`architecture-review.md`](architecture-review.md)).
- As a dedicated pass on a PR, separate from general code review, when the
  change touches auth, payments, PII, or external-facing surfaces.

## The prompt

```markdown
You are performing a security review of the code/design below. Work
through each category systematically. For every finding, state the
concrete exploit scenario, not just "this could be a risk" — if you can't
articulate how it would be exploited, note it as a lower-confidence
observation rather than a finding.

## Context
- Code / design under review: {{code_or_design}}
- What it does and who can access it (public internet, authenticated
  users, internal-only, admin-only): {{access_context}}
- Data handled (PII, credentials, payment info, none): {{data_sensitivity}}

## Review categories

### 1. Injection
- SQL/NoSQL/command/LDAP injection: is user input concatenated into
  queries/commands, or properly parameterized?
- Cross-site scripting (XSS): is user-controlled data rendered without
  encoding/escaping?
- Deserialization of untrusted data.

### 2. Authentication & authorization
- Are authentication checks present on every new endpoint/action that
  needs them?
- Authorization: does the code check that the authenticated user is
  *allowed* to access this specific resource (not just that they're
  logged in) — look specifically for IDOR (insecure direct object
  reference) patterns.
- Session/token handling: expiration, invalidation, secure storage.

### 3. Secrets & sensitive data handling
- Hardcoded credentials, API keys, or tokens in code or config.
- Secrets logged, included in error messages, or exposed in client-side
  code.
- Sensitive data transmitted or stored without appropriate encryption.

### 4. Input validation & output encoding
- Is input validated (type, length, format, range) before use, not just
  before display?
- Is output properly encoded for its context (HTML, URL, shell, etc.)?

### 5. Dependency risk
- New or updated dependencies: any known CVEs at the version pinned?
- Are dependencies pulled from trusted sources with integrity
  verification (lockfiles, checksums)?

### 6. Other common issues
- CSRF protection on state-changing requests.
- Rate limiting / abuse protection on sensitive or expensive operations.
- Error messages that leak internal details (stack traces, system paths,
  query structure) to end users.
- Insecure defaults (permissive CORS, disabled TLS verification, verbose
  debug modes reachable in production).

## Output format

For each finding:
- **Category**: which of the above.
- **Severity**: Critical / High / Medium / Low, with brief justification.
- **Location**: file/line or design component.
- **Exploit scenario**: concretely, how this would be abused.
- **Remediation**: specific fix, not just "validate input."

End with a summary: total findings by severity, and whether any Critical/
High findings should block merge/approval.
```

## Expected output

- Findings organized by category, each with a concrete exploit scenario
  and severity.
- A remediation suggestion specific enough to act on directly.
- A summary count by severity and an explicit merge/approval
  recommendation.

## Tips & pitfalls

- Reject vague findings ("this might be insecure") — ask for the concrete
  exploit path or downgrade it to a low-confidence note.
- Authorization bugs (IDOR-style — checking "logged in" instead of
  "allowed to access *this* resource") are the most commonly missed
  category in casual review; give it explicit attention.
- Don't treat this as a substitute for dependency scanning tools or SAST —
  it's a structured human/AI reasoning pass, use it alongside automated
  tooling, not instead of it.
- See [`../docs/security-guide.md`](../docs/security-guide.md) for this
  repo's security baseline and [`../checklists/security-review.md`](../checklists/security-review.md)
  for the pre-merge gate this review feeds into.
