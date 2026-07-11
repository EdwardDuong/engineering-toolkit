# Migration Planning

Guide an AI assistant through planning a migration (data, platform, or
framework version) with phased rollout, rollback points, and verification
gates at each phase.

## Purpose

Large migrations fail when they're planned as one big cutover instead of a
sequence of independently verifiable, reversible phases. This prompt forces
the plan to be phased from the start, with an explicit rollback point and
verification gate at every phase — so a problem discovered in phase 3
doesn't require unwinding phases 1 and 2 blind.

## When to use

- Planning a data migration (schema, datastore, or format change) affecting
  live data.
- Planning a platform migration (cloud provider, infrastructure, hosting
  model).
- Planning a framework/major-version migration affecting a large codebase.
- Any change too large or risky to do as a single atomic cutover.

## The prompt

```markdown
You are planning a migration. Produce a phased plan — do not propose a
single big-bang cutover unless you can justify why phasing genuinely isn't
possible for this specific case.

## Context
- What's migrating: {{migration_subject}} (e.g., "PostgreSQL 12 to 16,"
  "monolith auth module to a dedicated service," "REST API v1 clients to
  v2")
- Current state: {{current_state}}
- Target state: {{target_state}}
- Constraints (allowed downtime, must remain available during migration,
  deadline, team size): {{constraints}}
- Scale (data volume, traffic, number of consumers/clients affected):
{{scale}}

## Step 1 — Define phases
Break the migration into phases, each of which:
- Leaves the system in a working, deployable state at its end (not
  mid-migration and broken if work stops here).
- Is independently verifiable — you can confirm phase N succeeded before
  starting phase N+1.
- Is as small as practical; prefer more, smaller phases over fewer, large
  ones.

For each phase, state:
- What changes in this phase.
- Preconditions (what must be true/complete before this phase starts).
- The exit criteria that confirm this phase succeeded.

## Step 2 — Define rollback points
For each phase, state:
- Whether this phase is reversible, and the specific steps to reverse it.
- If a phase is NOT cleanly reversible (e.g., a data transformation
  applied in place), state that explicitly and propose how to make it
  reversible (dual-write, versioned data, keep-old-path-available) or
  document the accepted one-way risk.
- The maximum safe "soak time" in this phase before rollback becomes
  significantly harder (e.g., before old data referencing the prior format
  ages out, before too much new data accumulates in the new format only).

## Step 3 — Define verification gates
For each phase, specify concretely how to confirm it's safe to proceed to
the next phase:
- Automated checks (data consistency checks, integration tests, canary
  metrics) — not just "looks fine."
- Manual checks needed, if any, and who performs them.
- The specific metrics/signals that would indicate the phase failed and
  rollback should be triggered, with thresholds where possible.

## Step 4 — Plan for coexistence
For phases where old and new must coexist (e.g., dual-write period, old
and new clients both active, old and new schema both present):
- How is the coexistence period kept consistent (dual-write, sync job,
  feature flag routing)?
- What happens to writes/requests that hit the old path vs. new path
  during this window — is there a risk of divergence, and how is it
  detected/reconciled?

## Step 5 — Final plan summary
Produce a single phased timeline: phase name, what changes, exit
criteria, rollback plan, and estimated duration. Flag any phase carrying
higher risk than the others and why.
```

## Expected output

- A numbered, phased plan where each phase ends in a stable, deployable
  state.
- Explicit rollback steps (or a stated one-way risk with mitigation) per
  phase.
- Concrete verification gates with measurable exit criteria, not
  subjective checks.
- A coexistence/consistency plan for any dual-running period.
- A summary timeline highlighting the highest-risk phase.

## Tips & pitfalls

- Treat "we'll do it in a maintenance window" as a signal to look harder
  for a phased alternative — maintenance windows hide the same risks a
  big-bang cutover has, just with less time pressure to notice them.
- The most commonly skipped part of this plan is the "no clean rollback"
  case — push for an explicit answer rather than letting a phase go
  unaddressed.
- Verification gates without measurable thresholds ("check that it looks
  right") aren't gates — insist on specific checks or metrics.
- For the database-specific portions of a migration, cross-check with
  [`database-review.md`](database-review.md); for a version bump of a
  specific dependency, use [`dependency-upgrade.md`](dependency-upgrade.md)
  instead of this more general prompt.
