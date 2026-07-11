# Secrets Management

A secret is any value that grants access or proves identity, and would cause harm if an
unauthorized party obtained it — API keys, passwords, private keys, connection strings, signing
keys, and access tokens all qualify. [`../security-guide.md`](../security-guide.md) and
[`../configuration-management.md`](../configuration-management.md) state the core rule: never
commit a secret to source control. This document covers the mechanics of actually achieving that in
practice, and — because the rule gets broken anyway, in every organization, eventually — what to do
when it happens.

## Common vulnerabilities

- **Hardcoded secrets in source**, including in a "temporary" debug statement, a commented-out
  line, a test fixture, or a config file checked in "just for local dev" that later gets deployed
  as-is.
- **Secrets in shell history or CI logs** — passing a credential as a plain command-line argument
  (visible in process lists and shell history) or echoing an environment variable during a debug
  step, where CI logs are often more widely readable than the production system the secret
  protects.
- **Secrets baked into container images or build artifacts** — a credential present at build time
  (even briefly, even if later "removed") persists in that image layer's history and is
  recoverable by anyone who can pull the image.
- **Overly broad secret scope** — a single API key or service account credential shared across
  every environment (dev, staging, prod) or every service, so that a leak in the lowest-security
  environment compromises the highest.
- **Secrets that never rotate** — a credential created once and never changed has an unbounded
  window of usefulness to anyone who obtains it, whenever that happens to occur.
- **"Removed" secrets that are still live** — deleting a secret from the current file version
  doesn't remove it from git history; it remains fully recoverable by anyone who can access the
  repository's history, indefinitely, unless the underlying credential itself is rotated.
- **Secrets logged as a side effect** — an error handler or logging statement that dumps a full
  request object, config object, or exception context, inadvertently including a credential that
  was part of that object.

## Review questions

1. **Where does this secret actually live** — a secrets manager, environment variable injected at
   runtime, or something closer to the code than that?
2. **If this file were accidentally made public right now, what's the worst thing in it?** Apply
   this to config files, Docker images, and log output, not just source files.
3. **Does this credential distinguish between environments**, or is the same key used in dev,
   staging, and production? If a developer's laptop is compromised, what does that actually expose?
4. **When was this credential last rotated, and is there a process that ensures it happens again**,
   or did it happen once at creation and never since?
5. **Does anything log the full request, response, or config object** in a way that could
   inadvertently capture a secret traveling through it?
6. **If we found this secret committed in history today, do we have a clear, practiced process for
   rotating it** — or would the response be improvised under pressure?

## Examples

**Vulnerable — hardcoded credential:**
```
smtpClient = new SmtpClient(
  host: "smtp.example-provider.com",
  apiKey: "sk_live_51H8xJ2KZ9..."
)
```
This key is now in source control history permanently, readable by anyone with repository access,
past or present, regardless of whether the line is later deleted.

**Fixed — sourced from environment/secrets manager at runtime:**
```
smtpClient = new SmtpClient(
  host: config.get("SMTP_HOST"),
  apiKey: secretsManager.get("smtp-api-key")
)
```
The value is never present in source control; access to it is mediated by the secrets manager's own
access controls and audit log, and rotating it doesn't require a code change or deployment.

**Vulnerable — secret exposed via broad logging:**
```
function handleWebhook(request):
    logger.debug("Incoming webhook", request)  # logs full headers, including Authorization
    ...
```

**Fixed — explicit allow-list of what's logged:**
```
function handleWebhook(request):
    logger.debug("Incoming webhook", { path: request.path, eventType: request.body.type })
    ...
```

## Prevention strategies

- **Use a secrets manager or environment-injected configuration exclusively** — never a literal in
  source, even temporarily, even in a branch you don't intend to push. See
  [`../configuration-management.md`](../configuration-management.md) for the config-vs-code
  separation this depends on.
- **Run automated secrets scanning on every commit and every PR**, not as an occasional manual
  audit — catching a committed secret before merge is far cheaper than rotating it after it's
  already in history and possibly already pulled by CI, mirrors, or forks.
- **Scope every credential to the minimum it needs** — a separate credential per environment at
  minimum, and per service where practical, so a single leak has a bounded, knowable blast radius
  instead of an open-ended one.
- **Rotate on a schedule, not only on suspected compromise** — treat rotation as routine hygiene
  (see [`../dependency-management.md`](../dependency-management.md)'s update-cadence philosophy
  applied to credentials instead of packages), so the tooling and runbook for rotation are
  well-exercised before an incident forces you to use them under pressure.
- **If a secret is ever committed, rotate it — removing it from history is not sufficient.** A
  `git history rewrite` changes what's discoverable going forward; it does not undo the fact that
  the credential's value was exposed and may already be cloned, cached, mirrored, or scraped
  elsewhere. The credential itself must be invalidated and replaced. See
  [`../workflows/production-incident.md`](../workflows/production-incident.md) if the exposure
  requires a formal incident response.
- **Audit what gets logged**, explicitly allow-listing fields for anything that logs a
  request/response/config object wholesale, rather than trusting that no field in a large object
  will ever be sensitive.
