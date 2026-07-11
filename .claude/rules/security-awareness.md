# Rule: Security Awareness

Treat all external input as untrusted, avoid the well-known classes of
injection and access-control bugs, never hardcode secrets, and flag
security-relevant changes for extra review. This is the same baseline of
awareness this agent applies to its own actions — apply it equally to the
code it writes.

## Treat all external input as untrusted

"External input" is anything that originates outside the trust boundary of
the code currently executing: HTTP request bodies, query params, headers,
cookies, file uploads, CLI arguments, environment variables set by a
caller, data read from a database that another process writes to, responses
from third-party APIs, and output from other services in the system.

- Validate shape, type, and range before using input, not after.
- Never assume a value is safe because "the frontend already validates it"
  — client-side validation is a UX convenience, not a security control.
  Server-side (or equivalent trust-boundary-side) validation is mandatory.
- Encode/escape output for the context it's rendered in (HTML, SQL,
  shell, URL) rather than trying to sanitize input generically.

## Avoid the common injection classes

Be specifically alert to the OWASP Top 10-style categories:

- **Injection** (SQL, NoSQL, command, LDAP) — use parameterized
  queries/prepared statements and typed APIs, never string-concatenate
  untrusted input into a query or shell command.
- **Broken access control** — check authorization on every request that acts
  on a resource, not just authentication. Verify the acting user is allowed
  to act on *this specific* resource, not just that they're logged in.
- **Cross-site scripting (XSS)** — escape untrusted data before rendering it
  into HTML/JS contexts; prefer frameworks' built-in escaping over manual
  string building.
- **Insecure deserialization** — don't deserialize untrusted data into
  types/objects that can execute code or side effects as a byproduct of
  deserialization.
- **Server-side request forgery (SSRF)** — validate and restrict
  destinations before making a server-side request driven by user input
  (e.g. "fetch this URL" features).
- **Sensitive data exposure** — don't log secrets, tokens, passwords, or PII
  in plaintext; don't return more fields in an API response than the caller
  needs.

## Never hardcode secrets

- No API keys, passwords, tokens, private keys, or connection strings in
  source, config files committed to the repo, or commit messages.
- Use the project's secret-management mechanism (environment variables
  sourced from a secret store, a secrets manager, injected config) — never
  a literal in code, even "temporarily."
- If you find a secret already committed in the codebase, don't just remove
  it going forward — flag it, because the secret is compromised in history
  and needs rotation, not just deletion.

## Flag security-relevant changes for extra review

A change is security-relevant if it touches: authentication, authorization,
session/token handling, cryptography, input parsing/validation, secret
handling, dependency additions/upgrades, file/network access, or anything
processing user-supplied data. For these:

- Call out explicitly in the PR description that the change is
  security-relevant and what was considered.
- Walk [checklists/security-review.md](../../checklists/security-review.md)
  before requesting review, and don't skip it under time pressure — this is
  exactly the category of change where skipped review shows up later as an
  incident.
- Prefer requesting review from someone with security context when the
  project has that option.

See [docs/security-guide.md](../../docs/security-guide.md) for the full
project security standard.
