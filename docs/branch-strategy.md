# Branch Strategy

Concrete naming and protection rules that implement the model chosen in
[`git-workflow.md`](./git-workflow.md). Consistent naming makes tooling (CI triggers, changelog
generation, auto-linking to tickets) possible without special-casing.

## Branch naming convention

```
<type>/<ticket-id>-<short-description>
```

- `type` matches the [Conventional Commits](./conventional-commits.md) type most representative of
  the branch: `feature`, `fix`, `chore`, `refactor`, `docs`, `perf`, `test`.
- `ticket-id` is the tracker reference (e.g., `PROJ-1234`), when the team uses one. Omit if there's
  genuinely no tracked ticket, but that should be rare enough to be notable.
- `short-description` is a few hyphenated words, enough to identify the branch in a list without
  opening it.

Examples:

```
feature/PROJ-1421-add-webhook-retries
fix/PROJ-1503-null-pointer-on-empty-cart
chore/dependency-bump-q3
refactor/PROJ-1288-extract-pricing-module
```

Avoid personal-name or date-based branch names (`edward-wip`, `fix-jan15`) — they carry no
information about content and don't sort or search usefully once the branch list grows.

## Protected branches

At minimum, protect:

- **The trunk/main branch** — no direct pushes; all changes land via reviewed pull request; required
  status checks (CI, linting, tests) must pass before merge.
- **Active release branches** (see below) — same protections, since they represent code on its way
  to or already in production.

Protection rules should enforce, not just recommend:

- At least one approving review before merge (more for changes touching security-sensitive or
  high-blast-radius areas — see [`architecture-review.md`](./architecture-review.md)).
- Required CI checks passing (tests, linting, security scans) — see
  [`../checklists/before-merge.md`](../checklists/before-merge.md).
- No force-pushes to protected branches, ever. A force-push to trunk rewrites history everyone else
  has already built on top of.
- Linear history preference (squash or rebase merges) if the team has chosen that model in
  [`git-workflow.md`](./git-workflow.md), to keep `git bisect` and changelog generation reliable.

## When to cut a release branch

Under trunk-based development, most releases ship directly from trunk and don't need a dedicated
branch. Cut a release branch when:

- **Stabilizing a release requires ongoing fixes while trunk keeps moving** — e.g., a release
  candidate is in QA or a staged rollout while new feature work continues to merge to trunk. The
  release branch lets you cherry-pick fixes onto the stabilizing version without freezing trunk.
- **Multiple versions must be supported in parallel** — e.g., a previous major version still
  receives security patches after a new major version has shipped.
- **A regulated or client-specific release process requires a frozen, auditable snapshot** distinct
  from ongoing development.

Release branch naming: `release/<version>` (e.g., `release/2.4.x` for an ongoing maintenance line,
`release/2.4.0` for a single frozen candidate, depending on whether the branch needs to accept
further patch commits).

Once a release branch's version is no longer supported, delete it rather than leaving it to
accumulate as a source of confusion about which branches are actually live — the tag or release
artifact remains the permanent record, not the branch.

See [`release-process.md`](./release-process.md) for what happens on a release branch between cut
and ship, and [`semantic-versioning.md`](./semantic-versioning.md) for how the version number itself
is decided.

## Branch lifetime

- Feature/fix branches: target merge within 1–3 days of creation. If a branch is still open after a
  week, treat that as a signal to either split the work or check in on what's blocking it — see the
  branch-lifetime discussion in [`git-workflow.md`](./git-workflow.md).
- Delete branches immediately after merge. A stale branch list makes it hard to tell what's actually
  in progress versus abandoned, and clutters autocomplete/tooling for everyone.
- CI should flag (not necessarily block) branches open longer than a configured threshold, so
  long-lived branches are visible rather than silently accumulating drift.
