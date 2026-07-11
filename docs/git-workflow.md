# Git Workflow

A git workflow's job is to make "what's in production," "what's about to ship," and "what's still in
progress" unambiguous at all times. This doc covers the default branching model, commit hygiene, and
how to choose between rebase and merge.

## Default: trunk-based development with short-lived branches

This toolkit recommends **trunk-based development** as the default: a single long-lived branch
(commonly `main`) that is always kept releasable, with all work happening on short-lived feature
branches that merge back within a day or two.

Why this is the default:

- **Merge conflicts stay small.** The longer a branch lives, the more it diverges from trunk, and
  the more painful the eventual merge. Short-lived branches keep conflicts proportional to a day or
  two of team velocity, not a sprint's worth.
- **Continuous integration actually integrates continuously.** A branching model with long-lived
  feature or environment branches defers integration to the end, which is exactly when integration
  problems are most expensive to find.
- **It forces incremental delivery.** Large, long-lived branches encourage building an entire
  feature in isolation before anyone sees it. Trunk-based development pressures work to be broken
  into small, mergeable increments — see [`kiss-principle.md`](./kiss-principle.md) and
  [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md).
- **It pairs naturally with feature flags used sparingly.** Incomplete work can merge to trunk
  behind a flag rather than living on a branch — see the feature-flag stance in
  [`configuration-management.md`](./configuration-management.md).

### When an alternative model fits better

Trunk-based development assumes a team that can keep trunk releasable and has reasonably fast CI.
Deviate deliberately, and record the deviation (see [`adr-guide.md`](./adr-guide.md)), when:

- **Multiple release trains must ship independently** with different stabilization timelines (e.g.,
  regulated or client-specific release cadences) — a release-branch model (see
  [`branch-strategy.md`](./branch-strategy.md)) may fit better.
- **The team is small and distributed across time zones with little review overlap**, making
  same-day merges impractical — a longer-lived feature-branch model with GitHub-flow-style review
  may be more realistic, while still avoiding branches that live for weeks.
- **A large, genuinely indivisible change** (e.g., a foundational data model migration) cannot be
  safely delivered incrementally — an integration branch used for the shortest time possible is
  acceptable, with an explicit end date.

Whatever model is chosen, the invariant that must hold is: **trunk (or the designated stable branch)
is always deployable.** A workflow that regularly leaves trunk broken has failed regardless of what
it's called.

## Commit hygiene

- **Commits should be atomic.** Each commit should represent one coherent change that could, in
  principle, be reverted independently without breaking the build. "Fix bug and also reformat
  unrelated file" is two commits.
- **Commit messages follow [Conventional Commits](./conventional-commits.md)** — `type(scope):
  description` — so history is scannable and changelogs/version bumps can be generated from it.
- **Write commit messages for the reader six months from now**, not for yourself right now. "fix
  bug" tells a future `git blame` nothing; "fix(auth): reject expired refresh tokens instead of
  silently renewing them" tells them what changed and why it mattered.
- **Don't commit generated artifacts, secrets, or local environment files.** If one slips in, treat
  it as an incident-scale event for secrets specifically — rotate the credential, don't just remove
  the commit (git history is not a secure deletion mechanism).
- **Squash exploratory/WIP commits before merging**, keeping the final history readable, while
  preserving commits that represent genuinely separable logical steps if that aids future bisection.

## Rebase vs. merge

Both have a place; the choice depends on what the operation is for.

- **Rebase your own feature branch onto the latest trunk** before opening or updating a PR, to keep
  history linear and make the eventual merge trivial. Since the branch is yours and short-lived,
  rewriting its history is safe.
- **Never rebase a branch other people have already pulled from and built on**, including anything
  already merged to trunk. Rewriting shared history breaks everyone else's local state and any
  in-flight PRs based on it.
- **Merge (not rebase) into trunk**, using either a merge commit or a squash-merge depending on team
  preference — both preserve trunk's history as append-only, which is the property that matters for
  shared branches. Squash-merge is a reasonable default for typical feature work because it keeps
  trunk history at one commit per PR; preserve full commit history with a regular merge commit when
  the individual commits within a PR carry independent value (e.g., a multi-step migration you'd
  want to `git bisect` through).
- **`git pull --rebase` locally** (rather than the default merge-on-pull) keeps your own local
  history clean when syncing with trunk during a feature branch's life.

Rule of thumb: **rebase what's private, merge what's shared.**

## See also

- [`branch-strategy.md`](./branch-strategy.md) — naming conventions, protected branches, and release
  branches.
- [`conventional-commits.md`](./conventional-commits.md) — commit message format in detail.
- [`code-review-guide.md`](./code-review-guide.md) — what happens once a branch is ready for review.
