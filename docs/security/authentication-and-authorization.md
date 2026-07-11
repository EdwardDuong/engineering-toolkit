# Authentication and Authorization

Authentication answers "who is this?" Authorization answers "what are they allowed to do?" They
fail differently, they're tested differently, and — critically — a system can have flawless
authentication and still be completely broken if its authorization is wrong. Confusing the two, or
assuming one implies the other, is the single most common source of serious real-world security
incidents.

## Common vulnerabilities

**Authentication failures:**

- **Weak credential storage** — passwords stored in plaintext, reversibly encrypted, or hashed
  with a fast general-purpose hash (MD5, SHA-1, unsalted SHA-256) instead of a purpose-built
  password hashing algorithm designed to be slow and resistant to offline brute force.
- **Predictable or low-entropy session tokens** — a session identifier generated from a
  non-cryptographic random source, a timestamp, or a counter is guessable; only a cryptographically
  secure random source is safe for anything that grants access.
- **Sessions that don't actually end** — no server-side invalidation on logout (a client-side
  "forget the token" that leaves the token valid server-side), no expiry, or no invalidation on
  password change — meaning a stolen token remains useful indefinitely.
- **Rolling a custom authentication scheme** for a problem a well-reviewed standard already solves
  (OAuth 2.0/OIDC for delegated auth, a maintained library for password hashing) — custom crypto
  and custom auth logic are where subtle, exploitable mistakes hide longest, because they're
  exercised less than battle-tested standards.
- **Credential stuffing / brute force with no rate limit** — an authentication endpoint with no
  limit on failed attempts lets an attacker try a leaked password list against every account.

**Authorization failures:**

- **Insecure Direct Object Reference (IDOR)** — an endpoint that accepts a resource ID and
  fetches/modifies it without checking that the *authenticated caller* is allowed to access *that
  specific resource* — e.g., `GET /invoices/{id}` that returns any invoice for any logged-in user,
  not just the caller's own. This is the single most common real-world authorization bug, and the
  most common gap [`../../.claude/agents/security-engineer.md`](../../.claude/agents/security-engineer.md)
  is written to specifically catch.
- **Confusing "authenticated" with "authorized."** A check that verifies a valid session exists,
  applied to an action that also needs a per-resource or per-role check, silently grants access to
  anyone who's merely logged in.
- **Client-side-only authorization** — hiding a button or menu item in the UI for users without
  permission, with no corresponding server-side check, meaning the action is still reachable by
  calling the API directly.
- **Privilege escalation through mass assignment** — an update endpoint that blindly applies every
  field in a request body to a record, allowing a caller to set a field (e.g., `role: "admin"`)
  that was never meant to be client-settable.
- **Stale or overly broad roles** — a role system where "just give them admin, it's easier" has
  happened enough times that the role no longer maps to what someone actually needs, making the
  blast radius of any one compromised account far larger than necessary.

## Review questions

1. **For this endpoint or action: authenticated, or authorized?** State both explicitly. "Any
   logged-in user" and "only the resource's owner or an admin" are different requirements, and the
   code needs to reflect whichever one is actually intended.
2. **If I have a valid session as User A, can I access or modify User B's data by changing an ID
   in the request?** Try it. This single test catches most IDOR bugs directly.
3. **Is the authorization check server-side, on every request, or does it rely on the client not
   asking for something it shouldn't?**
4. **What happens to an existing session when the user's permissions change** (role downgraded,
   account suspended, password changed)? Is access revoked promptly, or does the old session stay
   valid until it naturally expires?
5. **Where are passwords/credentials hashed, with what algorithm, and who verified that choice is
   still considered strong?**
6. **Is there a rate limit or lockout on authentication attempts, and does it fail closed (deny)
   rather than open (allow) if the rate-limiting store is unavailable?**

## Examples

**Broken — IDOR, no ownership check:**
```
function getInvoice(request):
    invoiceId = request.params.id
    return database.invoices.findById(invoiceId)
    # Any authenticated user can read any invoice by guessing/incrementing IDs.
```

**Fixed — authorization checked per resource:**
```
function getInvoice(request):
    invoiceId = request.params.id
    invoice = database.invoices.findById(invoiceId)
    if invoice.ownerId != request.currentUser.id and not request.currentUser.isAdmin:
        return HTTP_403_FORBIDDEN
    return invoice
```

**Broken — mass assignment:**
```
function updateUser(request):
    database.users.update(request.currentUser.id, request.body)
    # If request.body includes {"role": "admin"}, the caller just promoted themselves.
```

**Fixed — explicit allow-list of client-settable fields:**
```
function updateUser(request):
    allowedFields = {"displayName", "email", "timezone"}
    updates = pick(request.body, allowedFields)
    database.users.update(request.currentUser.id, updates)
```

## Prevention strategies

- **Check authorization at the data-access layer, not just the route handler**, where practical —
  a check that lives close to the query is harder to accidentally bypass by adding a new route to
  the same resource later.
- **Default new endpoints to maximally restrictive**, and loosen deliberately — an endpoint that's
  accidentally too permissive is far more common than one that's accidentally too restrictive, so
  design the failure mode you're more likely to hit to be the safe one.
- **Use a well-reviewed password hashing algorithm** (a purpose-built, deliberately slow algorithm
  designed for credential storage) with a per-user salt, and re-hash on login if the configured
  work factor has increased since the credential was last hashed.
- **Prefer standard, delegated authentication protocols** (OAuth 2.0, OIDC, SAML) over rolling a
  custom scheme, and use a maintained library rather than a hand-rolled implementation even of a
  standard protocol — the standard's specification is easy to get subtly wrong in a fresh
  implementation.
- **Write an authorization test for every new resource type that asserts a non-owner is denied**,
  not just that an owner is allowed — a test suite that only checks the happy path never catches a
  missing authorization check.
- **Invalidate sessions server-side on logout, password change, and privilege downgrade** — a
  client that discards a token is not the same as a server that has revoked it.
- Run [`/security-audit`](../../.claude/commands/security-audit.md) on any new or changed endpoint;
  it explicitly checks "authentication required, and authorization checked per-resource" as a
  distinct pair, not a single combined check.
