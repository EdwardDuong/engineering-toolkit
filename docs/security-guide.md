# Security Guide

Security is a property of the whole system, not a feature bolted on before release. This guide
covers secure-by-default design principles, the vulnerability classes worth deliberate defense
against, and a lightweight approach to threat modeling that fits into normal engineering work rather
than requiring a separate specialist track for every change.

## Secure-by-default principles

- **Deny by default, allow explicitly.** Access control, network exposure, and permissions should
  start closed and be deliberately opened, not start open and be locked down reactively after
  something is discovered exposed.
- **Least privilege everywhere** — a service, a credential, or a user should have exactly the access
  it needs to do its job and no more. A background job that only reads data should hold a read-only
  credential, even if a read-write one would also "work."
- **Validate at every trust boundary**, not just at the outermost edge. Data crossing from an
  external client, a lower-trust service, or user input is untrusted until validated, regardless of
  how many layers it's already passed through — see the boundary discussion in
  [`architecture-principles.md`](./architecture-principles.md).
- **Fail closed.** When a security check errors out (a permissions lookup times out, an auth token
  can't be validated), the default behavior should be to deny access, not to proceed as if the check
  passed. A system that fails open turns every downstream outage into an authorization bypass.
- **Assume breach for defense in depth.** Don't rely on a single control (e.g., network perimeter
  alone) to protect sensitive data — layer controls (authentication, authorization, encryption,
  monitoring) so that one control failing doesn't mean total compromise.

## Common vulnerability classes to defend against

- **Injection** (SQL, command, template, log injection) — never build a query, command, or
  interpreted string by concatenating untrusted input. Use parameterized queries, prepared
  statements, or an equivalent mechanism that keeps data and code separated by construction, not by
  careful escaping that's easy to get wrong once and never revisit.
- **Broken authentication and session handling** — credentials and session tokens must be generated
  with cryptographically secure randomness, transmitted only over encrypted channels, and
  invalidated on logout/expiry/password change. Don't roll a custom authentication scheme when a
  well-reviewed standard exists for the same problem.
- **Broken access control** — the most common real-world vulnerability class in practice: verifying
  a user is authenticated is not the same as verifying they're authorized for the specific resource
  being accessed. Check authorization on every request that touches a specific resource,
  server-side, never relying on the client to only request things it's allowed to see.
- **Secrets management** — no credential, API key, or token is ever committed to source control,
  hardcoded in a config file checked into the repo, or logged. Use a secrets manager or
  environment-injected configuration; see
  [`configuration-management.md`](./configuration-management.md). If a secret is ever committed,
  rotating it is mandatory — removing it from history is not sufficient, since it may already be
  cloned or cached elsewhere.
- **Dependency vulnerabilities** — third-party code runs with the same trust as your own. See
  [`dependency-management.md`](./dependency-management.md) for vetting and update cadence; run
  automated vulnerability scanning on dependencies as part of CI, not as an occasional manual audit.
- **Sensitive data exposure** — data classified as sensitive (credentials, PII, financial data,
  health data) must be encrypted in transit and at rest, and excluded from logs, error messages, and
  analytics events. See [`logging-standards.md`](./logging-standards.md).
- **Security misconfiguration** — default credentials left unchanged, verbose error messages leaking
  stack traces or internal paths to end users, unnecessary services or ports exposed. Configuration
  should be reviewed with the same rigor as code, not treated as an afterthought outside the review
  process.
- **Insecure deserialization / unsafe parsing of untrusted input** — parsing untrusted data with a
  format or library that can execute code or exhaust resources as a side effect of parsing (not just
  as a result of the parsed values) is a distinct and often underestimated risk; prefer safe,
  restrictive parsers for any format accepting untrusted input.

## Lightweight threat modeling

Full formal threat modeling (attack trees, STRIDE analysis for every component) doesn't scale to
every change. Apply a lightweight version proportional to risk:

For any change that touches authentication, authorization, payment, or handles sensitive data, ask
explicitly before implementing:

1. **What is this protecting?** Name the asset — a credential, a customer record, money,
   availability of the system itself.
2. **Who could want to compromise it, and how?** Not exhaustively — just the realistic top few
   vectors (a malicious API caller, a compromised dependency, an insider with excess access).
3. **What's the blast radius if it's compromised?** One user's data, all users' data, the ability to
   impersonate any user, financial loss directly.
4. **What control prevents or limits each vector?** If there's no control, that's the gap to close
   before shipping, not after.

This is a five-minute conversation for most changes and a longer one for genuinely high-risk changes
— it does not require a dedicated security engineer to run, though one should be looped in when the
blast radius is large or the domain is unfamiliar. Escalate to a full
[`architecture-review.md`](./architecture-review.md) when the answer to question 3 is severe.

## Where this connects

- [`../checklists/security-review.md`](../checklists/security-review.md) — the concrete checklist to
  run through before shipping anything security-sensitive.
- [`../prompts/security-review.md`](../prompts/security-review.md) — a structured prompt for an
  AI-assisted security pass over a change.
- [`incident-response.md`](./incident-response.md) — what happens when a security control fails
  despite this guidance; a security incident follows the same severity and response discipline as
  any other incident, with additional care around disclosure and credential rotation.
