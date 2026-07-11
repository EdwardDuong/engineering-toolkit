# Engineering Metrics

Metrics should tell a team something true about how it's building and operating software, and should
change behavior for the better when acted on. Chosen poorly, they do the opposite: they get gamed,
they measure what's easy instead of what matters, and they distort behavior in ways that make the
underlying thing worse while making the number look better.

## What to measure: DORA metrics

The DORA (DevOps Research and Assessment) research program identified four metrics that correlate
strongly with high-performing software delivery, because they measure outcomes rather than activity:

- **Deployment frequency** — how often code is successfully deployed to production. Higher frequency
  correlates with smaller, lower-risk individual changes (see
  [`release-process.md`](./release-process.md)) and faster feedback loops — a team deploying daily
  learns whether a change was correct in hours; a team deploying monthly learns weeks later, after
  more has piled on top of the original change.
- **Lead time for changes** — the time from a code commit to that code running successfully in
  production. Short lead time means the gap between "an engineer had an idea" and "users benefit
  from it" is small, which is a direct measure of how much friction the delivery process itself
  imposes.
- **Change failure rate** — the percentage of deployments that cause a failure in production
  requiring remediation (a rollback, a hotfix, an incident). This measures whether the speed
  reflected in the first two metrics is coming at the cost of quality, or whether the team has
  genuinely made delivery both fast and safe.
- **Time to restore service (MTTR)** — how long it takes to recover from a production failure once
  one occurs. This measures the strength of the team's incident response (see
  [`incident-response.md`](./incident-response.md)) and observability (see
  [`observability-guide.md`](./observability-guide.md)), independent of how often failures happen in
  the first place.

These four together resist being gamed in isolation, because they check each other: a team could
inflate deployment frequency by shipping trivially small, low-value changes, but that alone doesn't
improve lead time for meaningful work, and if it comes at the cost of stability, change failure rate
reveals it. Track all four together, not any single one as a standalone target.

## What to deliberately avoid measuring

Some metrics look intuitively useful but produce worse behavior than not measuring anything at all:

- **Lines of code (written, or in a diff)** — rewards verbosity and penalizes the kind of aggressive
  simplification and deletion that's often the most valuable work an engineer can do (see
  [`kiss-principle.md`](./kiss-principle.md), [`dry-principle.md`](./dry-principle.md)). A large
  diff is not more valuable than a small one that solves the same problem more elegantly; measuring
  by line count actively incentivizes the wrong outcome.
- **Individual velocity or story points as an individual performance metric** — story points are a
  team-level relative estimation tool, not a comparable unit of individual output. Using them to
  rank or evaluate individuals incentivizes inflating estimates, avoiding hard/underestimated work,
  and gaming ticket sizing, all of which degrade the estimation process's usefulness for its actual
  purpose (team-level planning).
- **Number of commits or PRs** — trivially gameable by splitting work into more, smaller pieces than
  the work naturally warrants, and penalizes engineers whose work is inherently harder to fragment
  (deep investigation, complex design work) in favor of those doing high-volume, low-complexity
  changes.
- **Code review turnaround measured without context** — optimizing this in isolation incentivizes
  rubber-stamp approvals over genuinely careful review, which trades a visible metric improvement
  for an invisible quality regression that typically surfaces later as production incidents.
- **Any metric applied to compare individuals against each other** rather than to understand a team
  or system's health. Software engineering is highly collaborative and context-dependent; a metric
  stripped of that context and turned into an individual ranking almost always measures something
  other than what it claims to.

## Goodhart's Law

"When a measure becomes a target, it ceases to be a good measure." Any metric, once someone's
evaluation or incentives are tied directly to it, will eventually be optimized in ways that satisfy
the metric without satisfying the underlying goal the metric was meant to represent. This is not a
hypothetical risk — it is the default outcome of attaching stakes to a number without also
maintaining the judgment and context that number was originally a proxy for.

Practical guardrails against this:

- **Use metrics to inform investigation, not to be the final word.** A dip in deployment frequency
  is a prompt to ask why, not an automatic verdict that the team is underperforming — there could be
  a legitimate reason (a major, necessarily large piece of work in flight, a deliberate focus on
  paying down debt per [`technical-debt.md`](./technical-debt.md)).
- **Track metrics at the team or system level, not as an individual scorecard**, for exactly the
  reasons covered above — team-level metrics still incentivize gaming, but at least the gaming has
  to survive collective awareness and peer scrutiny, which individual metrics don't have.
- **Pair every metric with a qualitative check periodically** — a metrics dashboard reviewed
  alongside an actual conversation about what's happening on the ground catches drift a number alone
  would miss (e.g., change failure rate staying flat because failures are being under-reported, not
  because quality genuinely held).
- **Revisit whether a metric is still serving its purpose.** A metric introduced to solve a specific
  problem should be reconsidered once that problem is resolved — continuing to optimize for it
  indefinitely risks over-rotating on a solved problem at the expense of whatever matters now.
