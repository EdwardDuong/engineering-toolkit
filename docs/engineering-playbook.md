# Engineering Playbook

This is the doc a new engineer reads first, and the one a tech lead re-reads when deciding what to
adopt next. It explains what "good engineering" means in this toolkit, how the pieces fit together,
and — most importantly — how to adopt them without grinding a team to a halt.

## What this toolkit is

A language-agnostic, framework-agnostic operating system for software engineering: docs, templates,
checklists, prompts, and scripts that a team copies into a repository and adapts. It is not a
methodology you buy into wholesale (not Scrum, not SAFe, not a specific branching model mandated
from on high). It is a set of defaults that are good enough to use unmodified and specific enough to
save you from re-litigating the same process questions on every project.

The toolkit assumes:

- Engineers are trusted professionals. Process exists to reduce ambiguity and rework, not to police
  people.
- Documentation is a deliverable, not an afterthought. A change without documentation is an
  unfinished change.
- Consistency beats individual optimization. A slightly-worse-for-you convention that the whole team
  follows beats a perfect-for-you one nobody else understands.
- Everything here is a starting point. Teams are expected to adapt thresholds (coverage targets, SLA
  hours, severity definitions) to their context and record the adaptation, not silently diverge from
  it.

## The philosophy in one paragraph

Good engineering is the product of small, verifiable decisions made consistently: a clear boundary
here, a written-down rationale there, a test before the merge, a blameless review after the
incident. None of these individually is hard. What's hard is doing them consistently under deadline
pressure, and that's what a shared toolkit buys you — nobody has to personally remember every good
habit, because the habit is encoded in a checklist, a template, or a default that's easier to follow
than to skip.

## How the pieces fit together

The docs in this folder fall into five layers, and they build on each other:

1. **Principles** (`architecture-principles.md`, `clean-code.md`, `solid-principles.md`,
   `kiss-principle.md`, `yagni-principle.md`, `dry-principle.md`) — how to think about code and
   design. These are timeless and apply whether you're writing a script or a distributed system.
2. **Process & Workflow** (`git-workflow.md`, `branch-strategy.md`, `conventional-commits.md`,
   `semantic-versioning.md`, `documentation-standards.md`, `definition-of-ready.md`,
   `definition-of-done.md`) — how work flows from idea to shipped artifact.
3. **Quality & Review** (`code-review-guide.md`, `testing-strategy.md`, `performance-guide.md`,
   `security-guide.md`, `api-design-guide.md`, `database-guidelines.md`) — how correctness and
   maintainability get verified before and during review.
4. **Reliability & Operations** (`logging-standards.md`, `observability-guide.md`,
   `error-handling.md`, `configuration-management.md`, `dependency-management.md`,
   `release-process.md`, `incident-response.md`, `root-cause-analysis.md`, `postmortem-guide.md`) —
   how the system behaves and gets fixed once it's running.
5. **Governance & Decision-Making** (`technical-debt.md`, `risk-assessment.md`,
   `decision-making.md`, `architecture-review.md`, `rfc-process.md`, `adr-guide.md`,
   `engineering-metrics.md`) — how decisions get made, recorded, and measured over time.

Sitting on top of all five is **[`workflows/`](workflows/README.md)** — the operating model. Each
topical doc above explains one standard in isolation; `workflows/` is where those standards get
applied together, in order, on a real piece of work: a feature shipped from discovery through
deployment, a bug fixed from investigation through regression prevention, a database migration
sequenced safely, an API contract changed without breaking a caller, a production incident handled
from detection through postmortem. Read a topical doc to understand a standard; read a workflow to
understand how an experienced team actually executes it.

These layers are not independent chapters — they're cross-linked deliberately. `dry-principle.md`
links to `technical-debt.md` because unmanaged duplication becomes debt.
`architecture-principles.md` links to `adr-guide.md` and `rfc-process.md` because principles are
useless if the decisions that apply them aren't recorded anywhere. `code-review-guide.md` links to
`../checklists/before-pull-request.md` and `../templates/PR_TEMPLATE.md` because guidance without
an artifact to apply it to doesn't change behavior.

The companion folders complete the loop:

- `templates/` — the fill-in-the-blank artifacts (ADRs, RFCs, PRs, postmortems, runbooks).
- `checklists/` — the go/no-go gates at each stage of the software lifecycle.
- `prompts/` — ready-to-use prompts for AI-assisted engineering tasks (implementing a feature,
  investigating a bug, reviewing a PR) that encode the same standards as the docs.
- `examples/` — worked examples of a "good" version of each key artifact, so "write a good ADR"
  isn't left to interpretation.
- `.claude/rules/` — machine-enforced versions of a subset of these principles, for teams using AI
  coding agents.
- `.claude/agents/` and `.claude/commands/` — specialized personas and slash commands that give
  Claude Code the same domain judgment described here, and `.claude/workflows/` — the
  AI-agent-executable counterparts to `docs/workflows/feature-development.md` and
  `docs/workflows/bug-fix.md`, for teams that want an assistant to actually run the sequence.

## How to adopt this toolkit incrementally

Do not try to adopt all 37 docs, 17 templates, and 13 checklists in one sprint. That guarantees
rejection. Adopt in layers, each one cheap enough to stick before you add the next.

### Phase 1 — the load-bearing three (week 1)

Start with exactly three docs:

1. **[`git-workflow.md`](./git-workflow.md)** — agree on branching model and commit hygiene. This is
   infrastructure everything else depends on.
2. **[`code-review-guide.md`](./code-review-guide.md)** — agree on what a review is for and how
   feedback is given. This is where quality actually gets enforced day to day.
3. **[`definition-of-done.md`](./definition-of-done.md)** — agree on what "finished" means. Without
   this, every other process is negotiable per-ticket.

These three cover the highest-frequency, highest-friction interactions on a team: how code gets
branched, how it gets reviewed, and when it's allowed to be called done. Get consensus on these
before adding anything else — they will surface most of the disagreements a team has about "how we
work" on their own.

### Phase 2 — closing the loop on quality (weeks 2–4)

Once phase 1 is routine, add:

- [`testing-strategy.md`](./testing-strategy.md) and
  [`checklists/before-pull-request.md`](../checklists/before-pull-request.md)
- [`definition-of-ready.md`](./definition-of-ready.md) (the other half of "done" — knowing when work
  is actually startable)
- [`conventional-commits.md`](./conventional-commits.md) and
  [`branch-strategy.md`](./branch-strategy.md) as refinements of the git workflow

This phase is about making quality gates predictable rather than ad hoc — the same checks happen the
same way on every change.

### Phase 3 — architecture and decisions (months 2–3)

Once the team has shipped several changes under the phase 1–2 process, introduce decision-recording:

- [`adr-guide.md`](./adr-guide.md) and [`rfc-process.md`](./rfc-process.md) for architectural
  decisions
- [`architecture-principles.md`](./architecture-principles.md) and
  [`architecture-review.md`](./architecture-review.md)
- [`technical-debt.md`](./technical-debt.md) to start naming and tracking what phase 1–2 didn't have
  time to fix

Introducing ADRs too early produces empty ceremony — teams write ADRs for decisions nobody will
revisit. Introduce this once there's a real backlog of "why did we do it this way" questions that a
written record would have answered.

### Phase 4 — operational maturity (ongoing)

Add reliability practices as the system reaches production stakes:

- [`observability-guide.md`](./observability-guide.md),
  [`logging-standards.md`](./logging-standards.md), [`error-handling.md`](./error-handling.md)
- [`incident-response.md`](./incident-response.md),
  [`root-cause-analysis.md`](./root-cause-analysis.md),
  [`postmortem-guide.md`](./postmortem-guide.md)
- [`release-process.md`](./release-process.md) and
  [`../checklists/production-readiness.md`](../checklists/production-readiness.md)

There is no fixed timeline for phase 4 — introduce a specific doc when its absence has already
caused pain (e.g., write the incident response process after the first real incident makes clear
nobody knew who was in charge, not speculatively beforehand).

### Phase 5 — governance and measurement (once the team has scaled)

The last layer to add, useful once a team is large enough that decisions cross more than one working
group:

- [`decision-making.md`](./decision-making.md) for escalation paths
- [`risk-assessment.md`](./risk-assessment.md) for changes with real blast radius
- [`engineering-metrics.md`](./engineering-metrics.md) to measure health without gaming incentives

A five-person team does not need a decision escalation matrix. A fifty-person team does. Introduce
governance docs when coordination cost — not process anxiety — makes them necessary.

## What "adoption" actually means

Copying a file into a repo is not adoption. A doc is adopted when:

- It's linked from onboarding material and new engineers are pointed to it in their first week.
- At least one artifact (a PR, an ADR, an incident) has actually been produced using its guidance.
- The team has revisited it once and either confirmed it still fits or adapted it — a doc nobody has
  ever disagreed with is a doc nobody has actually read.

## When to deviate

Every threshold in this toolkit (coverage percentages, SLA hours, severity tiers) is a default, not
a law. Deviate when the context warrants it, but record the deviation the same way you'd record any
other architectural decision — see [`adr-guide.md`](./adr-guide.md). A silent deviation is how
toolkits rot into documents nobody trusts.

## Where to go next

- Building a new service or feature? Start with
  [`architecture-principles.md`](./architecture-principles.md) and
  [`definition-of-ready.md`](./definition-of-ready.md).
- Setting up how the team collaborates day to day? Start with [`git-workflow.md`](./git-workflow.md)
  and [`code-review-guide.md`](./code-review-guide.md).
- Preparing for production? Start with
  [`../checklists/production-readiness.md`](../checklists/production-readiness.md) and
  [`observability-guide.md`](./observability-guide.md).
- Just had an incident? Start with [`incident-response.md`](./incident-response.md) and
  [`postmortem-guide.md`](./postmortem-guide.md).
