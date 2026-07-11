# Configuration Management

Configuration is anything that changes a system's behavior without changing its code. Treating
configuration with the same discipline as code — versioned, reviewed, environment-aware — is what
prevents "it worked in staging" from becoming a permanent mystery.

## Config vs. code separation

- **Anything that varies by environment, deployment, or operator decision is configuration; anything
  that defines the system's logic is code.** A timeout value, a feature flag, a connection string, a
  rate limit are configuration. The algorithm that uses that timeout is code. Conflating the two —
  hardcoding an environment-specific value into logic, or building logic that only exists to
  interpret a single configuration flag no one ever varies — makes both harder to change
  independently.
- **Configuration should be externalized from the deployable artifact.** The same build/artifact
  should be promotable across environments (dev, staging, production) unchanged, with only its
  configuration differing. Rebuilding an artifact per environment defeats the purpose of having a
  build pipeline that verifies exactly what will run in production — you'd be verifying something
  slightly different from what actually ships.
- **Validate configuration at startup, not at first use.** A missing or malformed required config
  value should fail the process immediately with a clear error, not surface as an obscure runtime
  error hours later when that code path first executes.

## Environment-specific configuration

- Structure configuration so environment-specific values (URLs, credentials, resource limits) are
  layered over a common base, rather than fully duplicated per environment — duplication here means
  a change to shared behavior has to be repeated correctly in every environment's copy, which drifts
  over time.
- Keep the set of things that differ between environments as small as deliberately possible. The
  more environments diverge in configuration, the less confidently a passing staging test predicts
  production behavior.
- Never let convenience defaults meant for local development leak into a shipped default — a debug
  flag, a permissive CORS setting, a verbose logging level that's fine locally can become a
  production liability if it's the code's default rather than an explicit override for local
  environments only.

## Secrets handling

- **Secrets are never stored in source control** — not in a config file, not in a "temporary"
  script, not in a comment, not in a `.env.example` with a real value instead of a placeholder. If a
  secret is accidentally committed, rotating the credential is mandatory (removing it from history
  alone doesn't undo potential exposure).
- **Secrets are injected at runtime** from a dedicated secrets manager or the deployment platform's
  secret-injection mechanism, not baked into a built artifact or container image.
- **Access to secrets is scoped and audited** — a service should be able to read only the secrets it
  needs, and access should be logged, so a compromised credential can be traced to how it was
  obtained.
- **Rotate secrets on a defined cadence**, not only reactively after a suspected compromise — see
  [`dependency-management.md`](./dependency-management.md) and
  [`security-guide.md`](./security-guide.md) for the broader posture this fits into.

## Feature flags: use sparingly, deliberately

Feature flags are a legitimate tool for a specific set of problems — decoupling deployment from
release, enabling staged rollouts, supporting quick kill-switches for risky changes. They are not a
general-purpose substitute for good branching or release practices, and this toolkit takes a
deliberately conservative stance on them, consistent with
[`../.claude/rules/no-unnecessary-abstractions.md`](../.claude/rules/no-unnecessary-abstractions.md):
a flag is a form of configuration-driven branching, and every flag left in place indefinitely is a
permanent doubling of the code paths that have to be reasoned about and tested.

Use a feature flag when:

- Merging incomplete work to trunk under [`git-workflow.md`](./git-workflow.md)'s trunk-based model,
  so the flag is hiding unfinished code, not offering a permanent choice.
- Staging a risky release with the ability to roll back instantly without a redeploy — see
  [`release-process.md`](./release-process.md).
- Running a genuine, time-boxed experiment where two variants need to coexist to gather data.

Avoid a feature flag when:

- It's being used as a substitute for a real configuration value that should just be an
  environment-specific setting (that's config, not a flag).
- It's expected to live indefinitely as a permanent way to vary behavior per customer or environment
  — at that point it's a first-class configuration option or a genuine product decision, and should
  be modeled as one explicitly, not left as a flag from a shipped feature that nobody ever cleaned
  up.
- Nobody has committed to removing it once its purpose (rollout, experiment) is complete. Every flag
  needs an owner and an expiration plan at the moment it's created, not as an afterthought once it's
  already forgotten in the codebase.

A codebase with dozens of long-lived, unowned flags is harder to reason about than one with none —
every reader has to mentally track which combinations of flags are actually possible in production,
most of which were never intended to be permanent. Treat flag removal as part of the definition of
done for the work the flag was introduced to support — see
[`definition-of-done.md`](./definition-of-done.md).

## See also

- [`git-workflow.md`](./git-workflow.md) — how flags support trunk-based development specifically.
- [`release-process.md`](./release-process.md) — flags as a rollback mechanism during staged
  rollouts.
- [`security-guide.md`](./security-guide.md) — the broader secrets and access-control posture this
  doc's secrets section draws from.
