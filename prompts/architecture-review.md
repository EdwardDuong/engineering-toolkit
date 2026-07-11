# Architecture Review

Guide an AI assistant through reviewing a proposed design, RFC, or ADR for
soundness, scalability, failure modes, and alternatives considered.

## Purpose

Design reviews catch expensive mistakes cheaply — before code exists. This
prompt pushes the assistant past "looks reasonable" toward specifically
interrogating failure modes, scaling assumptions, and whether the proposal
actually considered alternatives or just documented the first idea.

## When to use

- Reviewing an RFC, ADR, or design doc before implementation starts.
- Sanity-checking your own design before circulating it for human review.
- Evaluating a significant architectural change (new service boundary, new
  datastore, new external dependency, cross-cutting pattern change).

## The prompt

```markdown
You are reviewing a proposed architecture/design. The goal is to find
soundness issues, unstated assumptions, and missing failure-mode analysis
before implementation begins — not to bikeshed naming or style.

## Context
- Design doc / RFC / ADR: {{design_doc_or_summary}}
- Problem it's solving: {{problem_statement}}
- Scale/scope expectations (traffic, data volume, team size, growth):
{{scale_expectations}}
- Constraints (existing systems it must integrate with, deadlines, team
  expertise): {{constraints}}

## Review dimensions

### 1. Problem fit
- Does the proposed design actually solve the stated problem?
- Is the problem itself well-defined, or is this a solution looking for a
  problem?

### 2. Alternatives considered
- What alternatives does the doc mention, and are the rejection reasons
  substantive (tradeoffs, constraints) or superficial?
- If no alternatives are documented, propose at least one plausible
  alternative and compare it against the chosen design.

### 3. Scalability
- Does the design hold up at the stated scale expectations? At 10x that
  scale?
- Identify the component most likely to become a bottleneck first, and
  why.

### 4. Failure modes
- Walk through what happens when each major dependency fails or is slow:
  network partition, downstream service outage, datastore unavailability,
  message loss/duplication.
- Is failure handled by design (retries, circuit breakers, fallbacks,
  idempotency) or left implicit?
- What is the blast radius of a failure in this component — does it
  degrade gracefully or cascade?

### 5. Operational concerns
- Observability: can an on-call engineer diagnose a problem in this system
  from logs/metrics/traces alone?
- Rollout/rollback: can this be deployed and reverted safely, in stages?
- Data migration or backward-compatibility implications, if any.

### 6. Complexity vs. value
- Is the complexity introduced proportional to the problem being solved?
- Does it introduce a new pattern, dependency, or paradigm the team will
  need to maintain long-term — is that cost acknowledged?

## Output format

**Strengths** — what the design gets right, briefly.

**Concerns**, each tagged by severity:
- **Blocking**: must be addressed before this should be approved.
- **Significant**: should be addressed or explicitly accepted as a
  tradeoff with reasoning.
- **Minor**: worth considering, not a gate.

**Missing analysis** — questions the doc doesn't answer that it should
before implementation starts.

**Recommendation** — approve / approve with changes / needs rework, with a
one-paragraph rationale.
```

## Expected output

- Findings organized by the six review dimensions, not a free-form
  reaction.
- Severity-tagged concerns, distinguishing blocking issues from minor
  notes.
- At least one alternative design considered, even if the doc didn't
  provide one.
- An explicit recommendation with rationale.

## Tips & pitfalls

- If the design doc is thin on failure modes, that gap is itself a
  finding — don't let the assistant fill in the blanks silently and
  approve based on its own assumptions.
- Push specifically on "what happens at 10x scale" — designs that work at
  current scale but fall over predictably at growth are the most common
  miss.
- Use alongside [`../checklists/architecture-review.md`](../checklists/architecture-review.md)
  for a structured pre-approval gate, and route the output into
  [`../templates/ADR.md`](../templates/ADR.md) if the decision needs to be
  recorded.
