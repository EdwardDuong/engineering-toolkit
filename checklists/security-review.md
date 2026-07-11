# Security Review Checklist

Run this for any change touching authentication, authorization, user input, external data, secrets, or dependencies. Run by the change's author, with a reviewer who can push back independently. Pair with [../prompts/security-review.md](../prompts/security-review.md) and [../docs/security-guide.md](../docs/security-guide.md) for deeper guidance, and [../docs/security/](../docs/security/README.md) for a practitioner-level treatment of any section below.

## Input handling

- [ ] All input crossing a trust boundary (user input, external API responses, file uploads, query params) is validated
- [ ] Validation happens on the server/service side, not only in the client
- [ ] Output is encoded/escaped appropriately for its context (HTML, SQL, shell, log lines) to prevent injection
- [ ] File uploads are restricted by type and size, and are not executed or served as-is from a trusted path

## AuthN / AuthZ

<!-- Deeper guidance, patterns, and worked examples (including IDOR, the most common real-world
     authorization bug): ../docs/security/authentication-and-authorization.md -->

- [ ] Every new endpoint or action enforces authentication where required
- [ ] Authorization checks the acting user's permission for the specific resource, not just that they're logged in
- [ ] Object-level access is checked (a user can't reach another user's data by changing an ID)
- [ ] Default-deny is the posture for new roles or permission checks, not default-allow

## Secrets & data

<!-- Deeper guidance on prevention and incident response if a secret is exposed:
     ../docs/security/secrets-management.md -->

- [ ] No secrets, keys, or credentials are hardcoded or committed
- [ ] Secrets are loaded from a secrets manager or environment, not config files in version control
- [ ] Sensitive data (PII, credentials, tokens) is not logged in plaintext
- [ ] Sensitive data at rest and in transit is encrypted per project standard

## Dependencies & privilege

<!-- Supply-chain-attack lens (typosquatting, dependency confusion, unpinned CI actions):
     ../docs/security/dependency-management.md -->

- [ ] New dependencies have been checked for known vulnerabilities (SCA/dependency scan)
- [ ] New dependencies are from a trustworthy source and pinned to a specific version
- [ ] The change requests the minimum permissions/scopes needed (least privilege), not broad access "to be safe"
- [ ] Service accounts, API keys, or tokens created for this change are scoped narrowly and have an owner
