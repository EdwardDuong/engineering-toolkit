# Conventional Commits

A structured commit message format that makes history machine-readable: changelogs, semantic version
bumps, and release notes can all be generated from commit messages that follow this spec, instead of
hand-written after the fact.

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

- **type** — required. Describes the kind of change (see allowed types below).
- **scope** — optional. The area of the codebase affected, in parentheses: `(auth)`, `(billing)`,
  `(api)`. Omit if the change is broad or scope isn't meaningful.
- **description** — required. Imperative mood, lowercase, no trailing period: `add retry logic`, not
  `Added retry logic.` or `Adds retry logic.`
- **body** — optional. Explains *why*, not just *what* — the diff already shows what changed. Wrap
  at a reasonable line length; separate from the subject line with a blank line.
- **footer** — optional. Used for `BREAKING CHANGE:` notices, issue references (`Closes #123`), and
  co-author trailers.

## Allowed types

| Type | Meaning | Triggers version bump? |
|---|---|---|
| `feat` | A new feature, user-visible or API-visible | MINOR |
| `fix` | A bug fix | PATCH |
| `perf` | A performance improvement with no behavior change | PATCH |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none |
| `docs` | Documentation-only changes | none |
| `test` | Adding or correcting tests | none |
| `chore` | Tooling, build config, dependency bumps with no source change | none |
| `style` | Formatting, whitespace — no logic change | none |
| `ci` | CI/CD pipeline configuration changes | none |
| `revert` | Reverts a previous commit | matches the reverted commit's type |

Keep this list closed. Adding new types on an ad hoc basis defeats the purpose of a shared,
tool-parseable vocabulary — if a new category seems necessary, agree on it as a team and update this
doc.

## Breaking changes

A breaking change is indicated one of two ways, and either is sufficient — using both is fine and
often clearer:

- A `!` after the type/scope: `feat(api)!: remove deprecated v1 endpoints`
- A `BREAKING CHANGE:` footer with a description of the break and, where possible, a migration path:

```
feat(api)!: require idempotency key on payment creation

BREAKING CHANGE: POST /payments now returns 400 if no
Idempotency-Key header is present. Clients must generate
a UUID per logical payment attempt.
```

Any breaking change triggers a MAJOR version bump — see
[`semantic-versioning.md`](./semantic-versioning.md). Never bury a breaking change inside a `fix` or
`chore` commit; mislabeling it means automated tooling (and human changelog readers) will miss it.

## Examples

```
feat(checkout): support partial refunds

fix(auth): reject expired refresh tokens instead of silently renewing them

perf(search): batch index lookups to cut p99 latency by ~40%

docs(readme): correct outdated setup instructions

refactor(pricing): extract discount calculation into its own module

chore(deps): bump http client library to latest patch release

feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: all v1 REST endpoints have been removed.
Migrate to the equivalent v2 endpoint; see the migration guide.
```

## How this drives automation

- **Changelog generation**: a release tool groups commits by type (Features, Fixes, Performance,
  etc.) and renders them into `CHANGELOG.md` automatically, instead of relying on someone to
  remember to write release notes by hand.
- **Version bump selection**: the highest-impact commit type since the last release determines
  whether the next release is MAJOR, MINOR, or PATCH — see
  [`semantic-versioning.md`](./semantic-versioning.md) for the exact rule.
- **Release notes**: `../templates/release-notes.md` can be populated largely from grouped commit
  messages, with human editing for clarity rather than starting from a blank page.

## Enforcement

- Lint commit messages in CI (or via a local commit-msg hook) against the spec so malformed messages
  are caught before merge, not discovered when changelog generation breaks.
- PR titles should also follow the format if the team squash-merges PRs, since the PR title becomes
  the commit message on trunk in that workflow — see [`git-workflow.md`](./git-workflow.md).
