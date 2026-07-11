# Documentation Index

This folder is the narrative and reference layer of the engineering toolkit. Templates, checklists,
and prompts tell you *what to fill in* and *what to verify*; these docs tell you *why the process
exists and how to apply it well*. Everything here is written to be copied into any codebase, in any
language, on any cloud, unmodified.

**New to this toolkit?** Read [`engineering-playbook.md`](./engineering-playbook.md) first. It
explains the overall philosophy and gives you an incremental adoption path instead of a wall of
process to swallow at once.

## Operating Model

The topical sections below explain individual principles and standards. [`workflows/`](workflows/)
is different — it's the narrative, end-to-end sequence an experienced team actually follows for the
five recurring shapes of engineering work, with the judgment calls made explicit at each step.

| Doc | Description |
|---|---|
| [`workflows/README.md`](workflows/README.md) | Index and how the five workflows relate to each other and to the rest of the toolkit. |
| [`workflows/feature-development.md`](workflows/feature-development.md) | Discovery, requirements, technical design, implementation, testing, review, deployment. |
| [`workflows/bug-fix.md`](workflows/bug-fix.md) | Investigation, root cause analysis, fix, regression prevention. |
| [`workflows/database-change.md`](workflows/database-change.md) | Migration safety, backward compatibility, rollback strategy. |
| [`workflows/api-change.md`](workflows/api-change.md) | Contract changes, versioning, security. |
| [`workflows/production-incident.md`](workflows/production-incident.md) | Detection, mitigation, communication, postmortem. |

## Principles

Foundational thinking that informs every other document in this folder.

| Doc | Description |
|---|---|
| [`engineering-playbook.md`](./engineering-playbook.md) | The narrative entry point: what "good engineering" means here and how to adopt this toolkit incrementally. |
| [`architecture-principles.md`](./architecture-principles.md) | Separation of concerns, explicit boundaries, composition over inheritance, designing for change without over-designing. |
| [`clean-code.md`](./clean-code.md) | Naming, function design, comment philosophy, formatting consistency, a working code-smells checklist. |
| [`solid-principles.md`](./solid-principles.md) | SRP, OCP, LSP, ISP, DIP explained generically, with pseudocode examples that apply beyond class-based OOP. |
| [`kiss-principle.md`](./kiss-principle.md) | Keeping designs simple, recognizing complexity creep, and the difference between simple and simplistic. |
| [`yagni-principle.md`](./yagni-principle.md) | Avoiding speculative generality, and how it coexists with deliberate upfront architecture. |
| [`dry-principle.md`](./dry-principle.md) | Don't Repeat Yourself, and the coupling risk of deduplicating across the wrong abstraction boundary. |

## Process & Workflow

How work moves from an idea to shipped code.

| Doc | Description |
|---|---|
| [`git-workflow.md`](./git-workflow.md) | Trunk-based development as the default, commit hygiene, rebase vs. merge policy. |
| [`branch-strategy.md`](./branch-strategy.md) | Branch naming, protected branches, and when to cut a release branch. |
| [`conventional-commits.md`](./conventional-commits.md) | The commit message spec that drives changelogs and semantic version bumps. |
| [`semantic-versioning.md`](./semantic-versioning.md) | MAJOR.MINOR.PATCH rules, pre-release and build metadata, declaring breaking changes. |
| [`documentation-standards.md`](./documentation-standards.md) | What must be documented, doc-as-code practices, and keeping docs from going stale. |
| [`definition-of-ready.md`](./definition-of-ready.md) | The bar a work item must clear before it enters development. |
| [`definition-of-done.md`](./definition-of-done.md) | The bar a work item must clear before it's considered complete. |

## Quality & Review

How correctness, maintainability, and interface quality get verified.

| Doc | Description |
|---|---|
| [`code-review-guide.md`](./code-review-guide.md) | What reviewers look for, review etiquette, actionable feedback, blocking vs. non-blocking comments. |
| [`testing-strategy.md`](./testing-strategy.md) | The test pyramid, coverage philosophy, test data management, flaky test policy. |
| [`performance-guide.md`](./performance-guide.md) | Performance budgets, profiling before optimizing, common anti-patterns, load testing. |
| [`security-guide.md`](./security-guide.md) | Secure-by-default design, common vulnerability classes, lightweight threat modeling. |
| [`api-design-guide.md`](./api-design-guide.md) | Designing stable interfaces: versioning, error contracts, idempotency, pagination. |
| [`database-guidelines.md`](./database-guidelines.md) | Safe schema migrations, indexing discipline, transaction boundaries, data retention. |

### Application Security deep dive

[`security-guide.md`](./security-guide.md) above states this toolkit's security principles in a
page. [`security/`](security/README.md) is the practitioner-level layer beneath it — six documents
written from an application security engineer's perspective, each with common vulnerabilities,
review questions, worked examples, and prevention strategies.

| Doc | Description |
|---|---|
| [`security/README.md`](security/README.md) | Index and how this folder relates to `security-guide.md` and the rest of the toolkit. |
| [`security/security-principles.md`](security/security-principles.md) | The AppSec mental model: risk-based thinking, attacker framing, recurring failure shapes. |
| [`security/secure-development-checklist.md`](security/secure-development-checklist.md) | A stage-by-stage checklist from design through post-deploy. |
| [`security/authentication-and-authorization.md`](security/authentication-and-authorization.md) | AuthN vs. AuthZ, credential storage, and the IDOR pattern behind most real-world authorization bugs. |
| [`security/dependency-management.md`](security/dependency-management.md) | The supply-chain-attack lens on dependencies, including a real finding fixed in this repo's own CI. |
| [`security/secrets-management.md`](security/secrets-management.md) | How secrets get committed by accident, and why removing one from history isn't enough. |
| [`security/threat-modeling.md`](security/threat-modeling.md) | STRIDE applied practically, with a fully worked example. |

## Reliability & Operations

How systems are run, observed, and kept healthy in production.

| Doc | Description |
|---|---|
| [`logging-standards.md`](./logging-standards.md) | Structured logging, log levels, correlation IDs, what must never be logged. |
| [`observability-guide.md`](./observability-guide.md) | Logs, metrics, and traces; SLIs/SLOs; alerting on symptoms instead of causes. |
| [`error-handling.md`](./error-handling.md) | Fail-fast vs. graceful degradation, error propagation, retries and backoff. |
| [`configuration-management.md`](./configuration-management.md) | Config vs. code separation, secrets handling, and a deliberately conservative feature-flag stance. |
| [`dependency-management.md`](./dependency-management.md) | Vetting, updating, and retiring third-party dependencies safely. |
| [`release-process.md`](./release-process.md) | Release cadence models, the release checklist entry point, rollback strategy. |
| [`incident-response.md`](./incident-response.md) | Severity levels, incident roles, timeline discipline, when to declare an incident. |
| [`root-cause-analysis.md`](./root-cause-analysis.md) | 5 Whys, contributing-factor analysis, and avoiding root-cause-as-blame. |
| [`postmortem-guide.md`](./postmortem-guide.md) | Blameless postmortem structure, timeline reconstruction, action item follow-through. |

## Governance & Decision-Making

How decisions get made, recorded, and revisited.

| Doc | Description |
|---|---|
| [`technical-debt.md`](./technical-debt.md) | Classifying debt, tracking it, and paying it down without a heavyweight framework. |
| [`risk-assessment.md`](./risk-assessment.md) | Lightweight likelihood x impact scoring and when a change needs one. |
| [`decision-making.md`](./decision-making.md) | Reversible vs. irreversible decisions, decision ownership, escalation paths. |
| [`architecture-review.md`](./architecture-review.md) | When a change needs architecture review and what reviewers evaluate. |
| [`rfc-process.md`](./rfc-process.md) | When to write an RFC and its lifecycle from draft to implemented. |
| [`adr-guide.md`](./adr-guide.md) | Architecture Decision Records: structure, when to write one, and immutability once accepted. |
| [`engineering-metrics.md`](./engineering-metrics.md) | DORA metrics and what to deliberately avoid measuring. |

## Conventions used across these docs

- Headings use `##` consistently so tables of contents render the same way in every renderer.
- Every doc is self-contained: you should be able to read one in isolation and understand it, though
  cross-links point to related material.
- Links to `templates/`, `checklists/`, `prompts/`, and `examples/` use relative paths (e.g.
  `../templates/ADR.md`) so this folder works whether it lives at a repo root or is vendored into a
  subdirectory.
- None of these docs name a specific language, framework, or cloud vendor as a requirement.
  Illustrative examples may mention one, but the guidance itself is portable.
