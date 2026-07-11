# Checklists

Practical, copy-into-any-project checklists that gate each stage of the development lifecycle. Each one is a short, run-through-it-yourself (or run-through-it-as-an-agent) list of yes/no items — not essays. Pick the ones relevant to your workflow; delete the rest.

## Lifecycle gates

Run these in order as a change moves from idea to production.

| Stage | Checklist | Description |
|---|---|---|
| Coding | [before-coding.md](before-coding.md) | Confirm requirements and approach before writing code. |
| Commit | [before-commit.md](before-commit.md) | Verify a change is clean, scoped, and safe to commit. |
| Push | [before-push.md](before-push.md) | Verify a local branch is safe to push to a shared remote. |
| Pull Request | [before-pull-request.md](before-pull-request.md) | Verify a PR is complete and ready for review. |
| Merge | [before-merge.md](before-merge.md) | Verify a PR is actually ready to merge. |
| Release | [before-release.md](before-release.md) | Verify a version is ready to ship to users. |
| Production | [production-readiness.md](production-readiness.md) | Verify a service or feature is ready to run in production. |

## Specialized reviews

Run these when a change touches the corresponding risk area, in addition to the lifecycle gates above.

| Review | Checklist | Description |
|---|---|---|
| Performance | [performance-review.md](performance-review.md) | Verify a change won't degrade latency, throughput, or resource use. |
| Security | [security-review.md](security-review.md) | Verify a change doesn't introduce security weaknesses. |
| Architecture | [architecture-review.md](architecture-review.md) | Verify a design decision is sound before it's hard to reverse. |
| Database | [database-review.md](database-review.md) | Verify a schema or data change is safe to apply. |
| Incident | [incident-review.md](incident-review.md) | Run through an active production incident. |
| Postmortem | [postmortem.md](postmortem.md) | Verify a postmortem is blameless, complete, and actionable. |

## How to use these

- Treat unchecked items as blockers, not suggestions — if an item doesn't apply, strike it through with a one-line reason instead of silently skipping it.
- AI agents operating autonomously should run the relevant checklist before declaring a task complete and report which items were checked, skipped, or failed.
- These checklists assume nothing about language, framework, or cloud provider. Adapt the specifics (e.g., "run the linter") to your project's actual tooling.
