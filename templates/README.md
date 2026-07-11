# Templates

Fill-in-the-blank artifacts for common engineering work. Copy the file you need into your project or issue tracker, fill in the `[bracketed placeholders]`, and delete the instructional comments as you go.

Several of these templates have a filled-in, worked example in [`examples/`](../examples/) — look there first if you want to see what "good" looks like before you start typing.

The nine templates central to this toolkit's decision-record discipline (`ADR.md` through `CODE_REVIEW.md` below) share a common backbone — **Context, Problem, Decision, Alternatives, Risks, Validation, Ownership** — so that once you know how to fill in one, you know the shape of all of them. The sections mean slightly different things per artifact (a bug report's "Decision" is the fix approach; a code review's is the verdict), but the underlying discipline is the same: state what's true, what's being decided, what else was considered, what could go wrong, how you'll know it worked, and who's accountable.

## Planning & Decisions

| Template | Use this when... |
|---|---|
| [`ADR.md`](ADR.md) | You're making a significant, hard-to-reverse architectural or technical decision and need to record the "why" for future readers. See [`../docs/adr-guide.md`](../docs/adr-guide.md). |
| [`rfc.md`](rfc.md) | You're proposing a design or approach that needs input and buy-in from others before work starts. See [`../docs/rfc-process.md`](../docs/rfc-process.md). |
| [`decision-log.md`](decision-log.md) | You made a small, low-stakes decision that's worth recording but doesn't warrant a full ADR. |
| [`risk-register.md`](risk-register.md) | You need to track and prioritize known risks to a project, system, or release. See [`../docs/risk-assessment.md`](../docs/risk-assessment.md). |

## Specs & Technical Design

| Template | Use this when... |
|---|---|
| [`FEATURE_SPEC.md`](FEATURE_SPEC.md) | A feature has been approved and needs a build-ready spec — acceptance criteria precise enough to implement from. See [`../docs/workflows/feature-development.md`](../docs/workflows/feature-development.md). |
| [`TECHNICAL_DESIGN.md`](TECHNICAL_DESIGN.md) | An approved feature or change has real design choices — data flow, component boundaries, new interfaces — worth writing down before implementing. |
| [`API_DESIGN.md`](API_DESIGN.md) | You're designing a new API surface or changing an existing contract significantly. See [`../docs/workflows/api-change.md`](../docs/workflows/api-change.md). |
| [`DATABASE_CHANGE.md`](DATABASE_CHANGE.md) | You're running a schema migration, index change, or significant new query pattern against production data. See [`../docs/workflows/database-change.md`](../docs/workflows/database-change.md). |

## Work Tracking

| Template | Use this when... |
|---|---|
| [`epic.md`](epic.md) | You're scoping a large body of work made up of multiple stories, spanning more than one release cycle. |
| [`user-story.md`](user-story.md) | You're writing a user-facing requirement for the backlog. References [`../docs/definition-of-done.md`](../docs/definition-of-done.md). |
| [`task.md`](task.md) | You're breaking a story down into a concrete, assignable unit of engineering work. |
| [`meeting-notes.md`](meeting-notes.md) | You need a consistent format for capturing discussion, decisions, and action items from a meeting. |

## Contribution & Review

| Template | Use this when... |
|---|---|
| [`project-readme.md`](project-readme.md) | You're starting a new project or service and need a README from scratch. |
| [`PR_TEMPLATE.md`](PR_TEMPLATE.md) | You're opening a pull request and want reviewers to have the context they need. Pairs with [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md). |
| [`CODE_REVIEW.md`](CODE_REVIEW.md) | A review needs a permanent, structured record beyond inline PR comments — an architecture, security, or other high-risk review. |
| [`BUG_REPORT.md`](BUG_REPORT.md) | You're filing a defect against existing behavior. See [`../docs/workflows/bug-fix.md`](../docs/workflows/bug-fix.md). |
| [`feature-request.md`](feature-request.md) | You're proposing new functionality for consideration, before it's approved and promoted to a `FEATURE_SPEC.md`. |

## Operations & Incidents

| Template | Use this when... |
|---|---|
| [`runbook.md`](runbook.md) | You're documenting a repeatable operational procedure for a service (deploys, failovers, maintenance). |
| [`incident-report.md`](incident-report.md) | An incident is currently in progress and you need a live-updating record of status and impact. |
| [`POSTMORTEM.md`](POSTMORTEM.md) | An incident has been resolved and you need a blameless retrospective. See [`../docs/postmortem-guide.md`](../docs/postmortem-guide.md), [`../docs/root-cause-analysis.md`](../docs/root-cause-analysis.md), and [`../docs/workflows/production-incident.md`](../docs/workflows/production-incident.md). |

## Release Management

| Template | Use this when... |
|---|---|
| [`release-notes.md`](release-notes.md) | You're publishing a specific version and need to communicate what changed to users. See [`../checklists/before-release.md`](../checklists/before-release.md). |
| [`changelog.md`](changelog.md) | You're maintaining an ongoing `CHANGELOG.md` for a project and need the standard structure. |
