# Secure Development Checklist

[`../../checklists/security-review.md`](../../checklists/security-review.md) is the single go/no-go
gate you run before shipping a security-sensitive change. This document is broader: a practical
walk through every stage of the development lifecycle where a security decision actually gets made
— most security debt is created long before that final gate, at design and coding time, where it's
far cheaper to prevent than to catch later.

## Common vulnerabilities (by the stage that actually introduces them)

Most guides list vulnerability classes flat, as if they're all discovered at the same point in the
lifecycle. They aren't — knowing *when* a class of bug typically gets introduced is what makes this
checklist actionable rather than a wall of things to remember all at once:

- **Introduced at design time**: missing authorization model, no defined trust boundaries, a data
  flow that exposes more than necessary by construction (e.g., a "get everything" internal API
  reused directly as a public endpoint).
- **Introduced at coding time**: injection (SQL, command, template), unsafe deserialization,
  hardcoded secrets, missing input validation, insecure defaults.
- **Introduced at integration time**: a new dependency with known vulnerabilities, a
  misconfigured third-party service, overly broad API scopes requested from an integration.
- **Introduced at deployment/config time**: verbose error pages left on in production, default
  credentials unchanged, an internal admin panel accidentally exposed to the public internet,
  overly permissive CI/CD permissions.

## Stage-by-stage checklist

### Design

- [ ] The asset being protected and its trust boundaries are explicitly identified — see
      [`threat-modeling.md`](threat-modeling.md) for anything touching auth, payments, or
      sensitive data.
- [ ] Authorization model is decided before implementation starts: who can do what, to which
      resources, and how that's checked — not deferred to "we'll figure it out while coding."
- [ ] Data classification is explicit: what's sensitive (PII, credentials, financial data) and
      what handling that requires (encryption, retention limits, logging exclusions).
- [ ] New external dependencies or integrations are vetted per
      [`dependency-management.md`](dependency-management.md) before being adopted, not after.

### Coding

- [ ] All external input is validated at the boundary where it enters the system — never trusted
      because "the client already checks it."
- [ ] No query, command, or interpreted string is built by concatenating untrusted input;
      parameterized/prepared mechanisms are used throughout.
- [ ] No secret, credential, or token appears in source, config files, comments, or test fixtures
      — see [`secrets-management.md`](secrets-management.md).
- [ ] Authorization is checked per-resource on every request that acts on one, not just "is this
      user logged in" — see [`authentication-and-authorization.md`](authentication-and-authorization.md).
- [ ] Error handling fails closed: a failed security check (auth lookup errors, permission check
      times out) denies access, it doesn't proceed as if the check passed.

### Review

- [ ] A dedicated security pass ran — [`/security-audit`](../../.claude/commands/security-audit.md)
      or the checklist in [`../../checklists/security-review.md`](../../checklists/security-review.md)
      — for anything touching auth, input handling, secrets, dependencies, or data access.
- [ ] Every new or changed endpoint, job, or entry point was checked for authorization, not
      assumed to inherit it correctly from a shared middleware.
- [ ] Findings are scored by realistic likelihood and impact, per
      [`../risk-assessment.md`](../risk-assessment.md), not treated as uniformly urgent or
      uniformly dismissible.

### Pre-release

- [ ] Dependency vulnerability scan is clean, or every open finding is a tracked, accepted risk
      with an owner and a due date — not silently ignored.
- [ ] Secrets scanning ran against the diff and the commit history of the change, not just the
      final file contents.
- [ ] Production configuration was reviewed separately from code — default credentials, debug
      flags, verbose error output, exposed admin surfaces.
- [ ] Rollback plan exists for anything that could need an emergency revert, per
      [`../workflows/production-incident.md`](../workflows/production-incident.md).

### Post-deploy

- [ ] Monitoring/alerting exists for the security-relevant failure modes of this change (auth
      failures spiking, unusual access patterns), not just its functional health.
- [ ] Access logs are actually reviewable if an incident requires them later — confirm logging
      captures what an investigation would need, per [`../logging-standards.md`](../logging-standards.md).

## Review questions

Ask these at any stage, as a fast gut-check before reaching for the full checklist above:

1. Has this been checked by someone other than the person who wrote it?
2. If this were reviewed by someone actively looking for a way to abuse it, what would they try
   first — and does this checklist actually cover that?
3. What in this change would we most regret not having reviewed carefully, if it turned out to be
   the cause of an incident six months from now?

## Prevention strategies

- **Shift checks left to the stage that actually introduces the risk**, per the table above,
  rather than relying entirely on a single pre-release gate to catch everything — a gate is a
  backstop, not a substitute for catching design-time gaps at design time.
- **Automate what's checkable by a machine** (secrets scanning, dependency vulnerability scanning,
  static analysis for known injection patterns) so human review time goes to the judgment calls a
  tool can't make — authorization model soundness, blast radius assessment, whether a "known
  limitation" is actually acceptable.
- **Make this checklist a living document.** When an incident's root cause turns out to be a gap
  this checklist didn't cover, add it — see
  [`../workflows/production-incident.md`](../workflows/production-incident.md)'s postmortem action
  items — so the same class of gap doesn't need to be rediscovered the same way twice.
