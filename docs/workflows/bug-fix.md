# Bug Fix Workflow

Most bad bug fixes aren't the result of a bad engineer — they're the result of skipping straight
from "here's a bug report" to "here's a patch" without the two steps in between that determine
whether the patch actually fixes anything: confirming what's really happening, and confirming why.
This is how an experienced team closes that gap.

The AI-agent-executable version of this sequence lives at
[`../../.claude/workflows/bug-fix.md`](../../.claude/workflows/bug-fix.md); this doc explains the
judgment behind each step.

## Investigation

The goal of investigation is a reliable reproduction and a clear description of the actual
(not assumed) behavior — before anyone proposes a fix.

- **Reproduce it before theorizing about it.** A bug that can't be reproduced can't be confirmed
  fixed. If it's intermittent, gather enough instances (logs, traces, user reports with timestamps)
  to characterize the pattern — "happens sometimes" is not yet a bug report an engineer can act on;
  "happens on the third retry after a specific upstream timeout" is.
- **Separate what's observed from what's assumed.** A bug report often arrives pre-diagnosed
  ("the cache is stale") when what was actually observed is narrower ("the page shows old data").
  Go back to the raw observation and re-derive the likely cause rather than inheriting someone
  else's unverified theory.
- **Gather evidence systematically**: exact reproduction steps, the expected vs. actual behavior,
  environment details, relevant logs or stack traces, and — critically — what changed recently in
  the area, since a large fraction of bugs are regressions from a specific, findable change. See
  [`../../prompts/investigate-bug.md`](../../prompts/investigate-bug.md) for a structured version of
  this pass.
- **Determine severity and blast radius before going further.** If this is actively affecting
  production — data corruption, an outage, broken payments, a security exposure — stop this
  workflow and escalate per [`../production-incident.md`](production-incident.md) first. Careful
  root-cause work happens after the bleeding stops, not instead of stopping it.

## Root Cause Analysis

A confirmed reproduction answers "what's happening." Root cause analysis answers "why the system
allowed it to happen" — and an experienced team treats those as genuinely different questions.

- Apply repeated "why" questioning (5-Whys) starting from the proximate, technical trigger,
  continuing until the chain reaches a systemic cause — a missing check, a wrong assumption baked
  into the design, a gap in test coverage — not a human-blame dead end like "someone made a
  mistake." See [`../root-cause-analysis.md`](../root-cause-analysis.md) for the full method and
  [`../../prompts/root-cause-analysis.md`](../../prompts/root-cause-analysis.md) for a structured
  prompt version.
- Distinguish the root cause from contributing factors. The root cause is what made the failure
  possible; contributing factors are what made it worse, harder to detect, or harder to diagnose
  (no test covering this path, no alert on this failure mode, a misleading error message that sent
  investigation down the wrong path first).
- Resist stopping at the first plausible explanation. The first "why" answer is often correct but
  shallow — "the function threw an error" is true and useless; "the function assumed the input was
  always non-null because every existing caller happened to guarantee that, and a new caller
  didn't" is a root cause a fix can actually address.
- If the root cause turns out to be domain-specific, bring in the matching lens:
  [`../../.claude/agents/database-engineer.md`](../../.claude/agents/database-engineer.md) for a
  data-layer cause, [`../../.claude/agents/devops-engineer.md`](../../.claude/agents/devops-engineer.md)
  for a deployment or infrastructure cause, and so on.

## Fix

The fix should address the root cause identified above, not just make the reported symptom stop
appearing — a patch that only suppresses the visible symptom leaves the underlying defect in place
to resurface differently later.

- Write the smallest correct fix that addresses the actual root cause — this is not license to fix
  everything adjacent that looks wrong; a bug fix that balloons into an unrelated refactor is
  harder to review and harder to revert if something's wrong with it.
- If the root cause reveals something bigger than this one instance is worth fixing right now
  (a systemic gap, a pattern used in many places), fix this instance, and record the broader issue
  explicitly per [`../technical-debt.md`](../technical-debt.md) rather than silently expanding
  scope or silently ignoring what you just learned.
- If the fix is genuinely uncertain in its side effects — touching a poorly-understood or
  poorly-tested area — treat the surrounding code with the caution in
  [`../../prompts/legacy-code-analysis.md`](../../prompts/legacy-code-analysis.md) before changing
  it further than necessary.

## Regression Prevention

A bug fix without a way to catch the bug coming back isn't finished — it's a patch that will need
to be rediscovered the next time this exact failure happens.

- Write a regression test as part of the same change as the fix, not as a follow-up. The test must
  fail against the pre-fix code — verify this directly (temporarily revert the fix and confirm the
  test catches it) rather than assuming a test that merely exists must be correct. This is
  non-negotiable per
  [`../../.claude/rules/tests-and-documentation.md`](../../.claude/rules/tests-and-documentation.md).
- Search for the same defect pattern elsewhere in the codebase if the root cause was a pattern
  rather than a one-off typo — a missing validation, a race condition shape, an off-by-one in a
  commonly-copied loop. Finding one instance and leaving siblings in place all but guarantees a
  near-identical report soon.
- If the contributing factors included a detection gap (no alert, no test coverage at the right
  level, a misleading error message), close that gap too — the regression test prevents this exact
  bug from recurring silently; the detection fix prevents the *next* related bug from going
  unnoticed as long this one did.
- Close the loop: update whatever tracked the original report (a ticket, an incident record) with
  the root cause and fix summary, so the next person who hits something similar can find out what
  actually happened rather than re-investigating from scratch.
