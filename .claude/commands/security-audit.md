---
description: Run a focused security review of a change, surface, or dependency set, producing scored findings with concrete remediations.
argument-hint: [change, file, surface, or system to audit]
---

Run a security audit of the following, adopting the
[`../agents/security-engineer.md`](../agents/security-engineer.md) persona for
the full duration of this review. This is not the abbreviated security check
that's part of every [`/review`](review.md) — this is the dedicated pass for
anything touching auth, input handling, secrets, dependencies, or data
access, and it does not skip a category to save time.

**Target**: $ARGUMENTS

## Process

1. **Map the trust boundaries.** Identify every point where data crosses
   from untrusted to trusted context: request bodies, query params, headers,
   file uploads, message queue payloads, webhook deliveries, CLI args, and
   config sourced from outside the process. Per
   [`../rules/security-awareness.md`](../rules/security-awareness.md), every
   one of these is untrusted until validated — list them explicitly rather
   than reviewing code linearly and hoping to notice them.

2. **Check each boundary against the relevant vulnerability class**, per
   [`../../docs/security-guide.md`](../../docs/security-guide.md):
   - **Injection** — is untrusted input ever concatenated into a query,
     command, template, or path without parameterization or escaping?
   - **Authentication and authorization** — is every new endpoint or
     action gated by the correct auth check, not just *an* auth check? A
     handler that verifies the caller is logged in but not that they're
     authorized for *this specific resource* is a common, serious gap.
   - **Secrets handling** — is any credential, API key, or token
     hardcoded, logged, or exposed in an error message or client-visible
     response, anywhere in the change, including tests and fixtures?
   - **Data exposure** — does any response, log line, or error message leak
     more than the caller is entitled to see (internal IDs, other users'
     data, stack traces with system detail, PII beyond what's needed)? See
     [`../../docs/logging-standards.md`](../../docs/logging-standards.md).
   - **Dependency risk** — does this change add or upgrade a dependency? If
     so, has it been vetted per
     [`../../docs/dependency-management.md`](../../docs/dependency-management.md),
     and is it pinned to a specific, verifiable version?

3. **Check for missing rather than broken controls.** The most common
   real-world security gap isn't a broken check, it's an absent one — a new
   endpoint that simply has no rate limiting, no input size limit, or no
   audit log where one is expected for a sensitive action. Explicitly ask,
   for each new capability introduced: "what stops this from being abused,
   and does that control actually exist yet?"

4. **Score each finding.** Use likelihood x impact per
   [`../../docs/risk-assessment.md`](../../docs/risk-assessment.md):
   - **Critical** — exploitable now, with meaningful impact (data breach,
     privilege escalation, remote code execution). Blocks merge.
   - **High** — exploitable under realistic but non-trivial conditions, or
     lower-impact but still meaningful. Blocks merge unless explicitly
     accepted and documented as a tracked risk.
   - **Medium** — a real weakness that raises the cost of a future
     exploit or violates defense-in-depth, without being independently
     exploitable today. Should be fixed, doesn't have to block this
     specific change if tracked.
   - **Low** — a hardening opportunity, not a live risk. Note it, don't
     let it stall the review.

5. **Give a concrete remediation for every finding**, not just a
   description of the problem — "validate this input" is not actionable on
   its own; "reject any `amount` that isn't a positive integer before it
   reaches the payment call, per the pattern in `docs/api-design-guide.md`"
   is.

## Output shape

A findings table (severity, location, description, remediation), ordered
Critical → High → Medium → Low, followed by an explicit go/no-go statement
against [`../../checklists/security-review.md`](../../checklists/security-review.md).
If this audit is being run as part of release preparation, the result feeds
directly into [`workflows/release.md`](../workflows/release.md).
