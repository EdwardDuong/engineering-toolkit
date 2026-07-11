# Security Principles

[`../security-guide.md`](../security-guide.md) states this toolkit's secure-by-default principles
in a few paragraphs — deny by default, least privilege, validate at every boundary, fail closed,
defense in depth. This document is the deeper layer underneath: the mental model an application
security engineer actually applies when those principles meet a real design or a real diff, with
the vulnerability patterns, review questions, and prevention strategies that make the principles
concrete rather than aspirational.

Read [`../security-guide.md`](../security-guide.md) first if you haven't. Read this folder when
you need to go deeper on a specific area: authentication and authorization
([`authentication-and-authorization.md`](authentication-and-authorization.md)), the supply chain
([`dependency-management.md`](dependency-management.md)), credentials
([`secrets-management.md`](secrets-management.md)), or systematic risk analysis
([`threat-modeling.md`](threat-modeling.md)) — with
[`secure-development-checklist.md`](secure-development-checklist.md) tying them together into a
single SDLC-spanning checklist.

## The mental model

Security engineering is risk management, not perfection-seeking. There is no such thing as a
system with zero vulnerabilities — there is a system where the cost of exploitation exceeds the
value of what's being protected, for every realistic attacker. Three ideas follow from that:

- **Think in terms of an attacker with a goal, not an abstract checklist.** "Is this endpoint
  vulnerable to SQL injection" is a narrower question than "if I were trying to read other users'
  data through this API, what would I try first?" The second framing catches classes of problems
  the first misses, because real attackers don't limit themselves to a fixed vulnerability
  taxonomy.
- **The weakest link determines the actual security level**, not the average control. A system
  with excellent encryption and a trivially guessable admin password is not "mostly secure" — it's
  as insecure as the weakest control an attacker can reach. Review effort should go to the weakest
  plausible link, not evenly across every control.
- **Security debt compounds like any other technical debt, but its cost is often invisible until
  exploited.** A missing authorization check doesn't slow anyone down in daily development the way
  a messy module does — it sits silently until someone finds it. This asymmetry is why security
  review can't be skipped under the same "we'll clean it up later" reasoning that's sometimes
  defensible for other technical debt (see [`../technical-debt.md`](../technical-debt.md)).

## Common vulnerabilities

These aren't specific bugs — they're the recurring *shapes* of security failure that show up
across almost every category in this folder, worth recognizing as patterns:

- **Confusing "possible" with "intended."** A system that technically allows an action (the code
  path exists and doesn't error) is not the same as a system that was designed to allow it. Most
  real vulnerabilities are unintended capabilities the code happens to permit, not deliberately
  malicious features.
- **Trusting a boundary that isn't actually enforced.** Assuming a request came from a trusted
  source because it "should" have gone through a particular code path, when nothing actually
  prevents a caller from reaching the sensitive code directly.
- **Security controls that degrade silently.** A rate limiter that fails open when its backing
  store is unavailable, a certificate check that's skipped in a debug code path that shipped to
  production, a feature flag meant for testing that disables an auth check.
- **Defense that exists in exactly one place.** A single control protecting something valuable,
  with no second layer — see defense in depth in [`../security-guide.md`](../security-guide.md).
  When that one control has a bug, there's nothing left standing between an attacker and the asset.

## Review questions

Ask these of any design or change, before reaching for a vulnerability-class checklist — they
surface the shape of the risk before you enumerate specific failure modes:

1. **What's the asset, precisely?** Not "user data" broadly — the specific thing being protected
   (a password hash, a payment credential, the ability to impersonate another user).
2. **What would make this interesting to attack?** If there's no plausible reason an attacker
   would target this, say so explicitly rather than skipping the question — but be honest about
   whether that's actually true or just convenient to believe.
3. **What's the realistic blast radius if the weakest control here fails?** One record, one
   account, every account, the whole system's integrity.
4. **Is there a second layer, or does this rely on exactly one control holding?** If it's one
   control, is that a deliberate, accepted tradeoff or an oversight?
5. **Would this still be safe if a well-intentioned engineer made a small mistake elsewhere in the
   system?** Security that only works if every other part of the codebase is also perfect is
   fragile by construction.

## Prevention strategies

- **Push security decisions as early as possible in the lifecycle.** A design-time threat model
  (see [`threat-modeling.md`](threat-modeling.md)) costs a conversation; the same gap found in
  production review costs an incident. See
  [`secure-development-checklist.md`](secure-development-checklist.md) for what this looks like at
  each stage.
- **Prefer safe-by-construction mechanisms over disciplined-by-convention ones.** A parameterized
  query API that makes injection structurally impossible beats a coding guideline that says
  "always escape input" — the former doesn't depend on every future engineer remembering correctly
  every time.
- **Make the secure path the easy path.** If doing the secure thing requires more effort than the
  insecure shortcut, engineers under deadline pressure will eventually take the shortcut — invest
  in tooling and defaults that make security free, not just documented.
- **Review security-relevant changes with a dedicated pass, not folded into general code review.**
  Use [`/security-audit`](../../.claude/commands/security-audit.md) and the persona in
  [`../../.claude/agents/security-engineer.md`](../../.claude/agents/security-engineer.md) for
  anything touching auth, input handling, secrets, dependencies, or data access — a general
  reviewer skimming for security issues alongside everything else misses what a dedicated pass
  catches.
