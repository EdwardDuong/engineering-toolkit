# Engineering Operating Model

The rest of `docs/` explains individual principles and standards in isolation — what clean code
looks like, what a good migration looks like, what a good postmortem looks like. This folder is
different: it's the narrative sequence an experienced team actually follows for the five recurring
shapes of engineering work, start to finish, with the judgment calls made explicit at each step.

Read a topical doc to understand a single standard. Read a workflow here to understand how several
of those standards get applied together, in order, on a real piece of work.

| Workflow | Covers | Read this when |
|---|---|---|
| [`feature-development.md`](feature-development.md) | Discovery, requirements, technical design, implementation, testing, review, deployment | Building anything from a new capability to a small enhancement |
| [`bug-fix.md`](bug-fix.md) | Investigation, root cause analysis, fix, regression prevention | A defect has been reported and needs a real fix, not just a patch |
| [`database-change.md`](database-change.md) | Migration safety, backward compatibility, rollback strategy | Any schema change, migration, or significant query pattern change |
| [`api-change.md`](api-change.md) | Contract changes, versioning, security | Changing an existing endpoint, interface, or public contract |
| [`production-incident.md`](production-incident.md) | Detection, mitigation, communication, postmortem | Something is actively broken in production right now |

## How these relate to the rest of the toolkit

- Each workflow here cross-links to the specific `docs/` reference guides, `checklists/` gates,
  and `templates/` artifacts it draws on — this folder doesn't restate that guidance, it sequences
  it.
- [`feature-development.md`](feature-development.md) and [`bug-fix.md`](bug-fix.md) have sibling
  documents in [`../../.claude/workflows/`](../../.claude/workflows/) that encode the same
  sequence as an AI-agent-executable playbook (chaining `/plan`, `/implement`, `/test`, `/review`,
  and `/security-audit`). Read the docs here for the reasoning; use the `.claude/workflows/`
  versions when you want Claude Code to actually execute the sequence.
- [`production-incident.md`](production-incident.md) is the operational sequence version of
  [`../incident-response.md`](../incident-response.md) (standards) and
  [`../postmortem-guide.md`](../postmortem-guide.md) (postmortem structure) — read those two for
  the underlying definitions this workflow applies.
- [`database-change.md`](database-change.md) and [`api-change.md`](api-change.md) are the process
  view of [`../database-guidelines.md`](../database-guidelines.md) and
  [`../api-design-guide.md`](../api-design-guide.md) respectively — the reference docs define what
  "good" looks like; these workflows define the sequence of steps that gets you there safely.

## When a piece of work needs more than one workflow

Real work often combines these. A feature that includes a schema change follows
[`feature-development.md`](feature-development.md) as the outer sequence, with
[`database-change.md`](database-change.md) applied specifically to the migration steps inside it. A
bug fix that turns out to be actively harming users in production escalates mid-investigation from
[`bug-fix.md`](bug-fix.md) to [`production-incident.md`](production-incident.md), then returns to
[`bug-fix.md`](bug-fix.md)'s root-cause-analysis and regression-prevention steps once the incident
is mitigated. None of these workflows assume they're the only one in play — follow the outer
workflow for the shape of the work, and pull in the specific one that matches whatever sub-problem
you hit along the way.
