# Dependency Management (Security Lens)

[`../dependency-management.md`](../dependency-management.md) covers the full lifecycle of a
dependency — vetting, update cadence, lockfiles, deprecation. This document is narrower and
deeper: the supply-chain attack surface a dependency introduces, which is a distinct risk from
"is this package well-maintained." A dependency can be actively maintained, widely used, and still
be the exact vector an attacker uses to reach your system — often *because* it's widely used and
trusted without a second look.

## A finding from this repository

This toolkit's own CI workflows (`.github/workflows/lint.yml` and `link-check.yml`) pinned
`actions/checkout` to the mutable tag `@v4` rather than an immutable commit SHA — found during the
review that produced this document, and fixed as part of it (now pinned to
`actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1`). This is worth keeping as a
concrete example rather than deleting the evidence: a mutable version tag can be re-pointed — by the
publisher under normal use, or by an attacker who compromises the publisher's account — to a
different commit than the one you reviewed and trusted, and your CI will pull whatever the tag
currently points to on every run, with no diff for anyone to review. Pinning to a commit SHA makes
what actually runs immutable and auditable; the trailing `# v4.3.1` comment keeps it human-readable
without reintroducing the mutability.

## Common vulnerabilities

- **Typosquatting** — a malicious package published under a name deceptively close to a popular
  one (`reqeusts` instead of `requests`), relying on a developer's typo or misremembered name
  during manual installation.
- **Dependency confusion** — when an internal, private package name is also claimed on a public
  registry, a misconfigured build can pull the public (attacker-controlled) version instead of the
  intended internal one, because many package managers default to preferring the higher version
  number regardless of source.
- **Compromised maintainer accounts or build pipelines** — an attacker gains publish access to a
  legitimate, previously-trustworthy package (via credential theft, a phished maintainer, or a
  compromised CI pipeline) and ships a malicious version under the real project's name and
  reputation. This is more dangerous than typosquatting because it doesn't require the victim to
  make a mistake — the trusted name itself becomes the attack vector.
- **Unpinned or loosely pinned versions** — a manifest or workflow that accepts a version range or
  a mutable tag (`^2.0.0`, `latest`, `@v4`) will pull whatever currently satisfies that constraint,
  which may not be what was reviewed when the dependency was adopted. See the finding above.
- **Malicious or vulnerable transitive dependencies** — a direct dependency you vetted carefully
  can still pull in a compromised or vulnerable package several levels deep that never went through
  the same scrutiny.
- **Build-time code execution** — many package ecosystems run arbitrary install/build scripts by
  default, meaning simply *installing* a malicious package (not even using it) can execute
  attacker-controlled code on the machine running the install — a developer's laptop or, worse, a
  CI runner with access to secrets.

## Review questions

1. **Is this dependency pinned to an immutable reference** (a specific version with a lockfile
   entry, or a commit SHA for something like a CI action), or to something that can silently change
   underneath us?
2. **If this dependency's publish credentials were compromised today, what could a malicious
   version do** — what does it run with access to (secrets, network, filesystem), and at what
   stage (install time vs. runtime)?
3. **Do we actually review dependency updates, or do they merge automatically with no human
   looking at what changed?** Automated patch updates are reasonable (see
   [`../dependency-management.md`](../dependency-management.md)'s update cadence guidance) but
   should still be gated by CI and, for anything with elevated access, a diff review.
4. **Does our CI pipeline's dependency installation step have access to secrets it doesn't need?**
   A compromised dependency executing during a build only matters as much as what that build
   process can reach.
5. **When did we last actually look at what a security scan flagged**, versus letting findings
   accumulate unreviewed in a dashboard nobody checks?

## Examples

**Vulnerable — mutable reference, exactly what this repo had:**
```yaml
- uses: actions/checkout@v4
```
The tag `v4` can be moved to point at a different commit at any time, by the publisher or by
anyone who compromises the publisher's account. Your workflow will run whatever it currently
points to, silently.

**Fixed — pinned to an immutable commit:**
```yaml
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1
```
The SHA cannot be repointed. Upgrading is a deliberate, reviewable diff (new SHA, updated comment)
instead of an invisible change that happens automatically.

**Vulnerable — unpinned package manifest range:**
```json
{ "dependencies": { "some-library": "^2.0.0" } }
```
Without a committed lockfile, this installs whatever the latest `2.x.x` release is at install
time — potentially a version published minutes ago that nobody on the team has seen.

**Fixed — lockfile committed, range still expresses intent:**
The manifest can still declare `^2.0.0` to express "any compatible 2.x is acceptable," but the
committed lockfile pins the *exact* resolved version actually installed, and that lockfile only
changes through a reviewed diff — see [`../dependency-management.md`](../dependency-management.md)'s
lockfile discipline.

## Prevention strategies

- **Pin anything that executes** — CI actions, container base images, install scripts fetched via
  URL — to an immutable digest or commit SHA, not a mutable tag, exactly as fixed in this repo's
  own workflows above.
- **Commit and enforce lockfiles** in CI (fail the build if the lockfile is out of sync with the
  manifest) so "what's declared" and "what's actually installed" can never silently diverge.
- **Run automated dependency vulnerability scanning on every build**, not periodically — see
  [`../dependency-management.md`](../dependency-management.md)'s scanning cadence guidance — and
  extend the same scanning to CI/CD pipeline dependencies (actions, base images), not just
  application-level packages.
- **Restrict what a build process can reach.** A dependency install step doesn't need production
  secrets; scope CI credentials and network access to what each stage of the pipeline actually
  requires, so a compromised dependency's blast radius is contained.
- **Prefer ecosystems and tooling that support provenance/attestation** (verifying a package was
  actually built from the source it claims to be, by the process it claims) where available, as a
  stronger guarantee than "the name and version look right."
- **Treat a security advisory about a dependency you use as an out-of-band, urgent action** — see
  [`../dependency-management.md`](../dependency-management.md)'s "security patches apply
  out-of-band" guidance — rather than folding it into the next regular update cycle.
