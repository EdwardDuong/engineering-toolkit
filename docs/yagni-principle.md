# YAGNI — You Aren't Gonna Need It

YAGNI says: don't build a capability until something in front of you actually requires it. Not
"might require," not "would be nice to have ready" — requires, right now, for a concrete piece of
work.

## The failure mode YAGNI prevents

Speculative generality: building configuration points, abstraction layers, or extensibility hooks
for variation that doesn't exist yet, based on a guess about what might be needed later.

The guess is usually wrong in one of two ways:

- **The variation never materializes**, and the abstraction sits there forever as unexercised
  complexity — a config flag with one valid value, an interface with exactly one implementation, a
  plugin system with exactly one plugin. Every future engineer still has to read through and
  understand the abstraction, even though it never earned its cost.
- **The variation materializes differently than guessed**, and the abstraction has to be reworked
  anyway — except now the rework also has to preserve backward compatibility with the speculative
  version, which is strictly more expensive than building the real thing fresh would have been.

Either way, guessing ahead of evidence tends to cost more than waiting and building the real thing
once you know what it actually needs to do.

## What YAGNI does not mean

YAGNI is not an argument against architecture, against thinking ahead, or against writing correct
code the first time. It specifically targets *unrequested flexibility*, not necessary rigor.

- Handling a known error case is not speculative — it's a real requirement. Skipping it isn't YAGNI,
  it's a bug waiting to happen.
- Choosing a data model that won't need a breaking migration for the features already on the roadmap
  is not speculative — it's ordinary competent design.
- Writing a function with a single, concrete implementation instead of an injectable interface is
  YAGNI-compliant *if* nothing today needs a second implementation. It is not a violation of good
  design — a single concrete implementation is simpler to read, and you can extract an interface
  later in minutes if a second implementation ever actually arrives.

## How YAGNI interacts with architecture-first

This toolkit also advocates for deliberate upfront architecture (see
[`architecture-principles.md`](./architecture-principles.md)). Those two positions are not in
tension once the distinction is precise:

- **Upfront architecture** decides things that are expensive to change later and where you already
  have enough information to decide well: service boundaries, data ownership, the primary
  integration contract between components, the consistency model. Getting these wrong is costly
  regardless of when you notice, so it's worth thinking about them before writing code.
- **Speculative generality** decides things that are cheap to change later and where you don't yet
  have enough information to decide well: exactly how many payment providers to support, whether a
  rule engine needs five configurable strategies or one hardcoded rule, whether a component needs a
  plugin architecture.

The test: **is this expensive to retrofit, and do we already have enough evidence to get it right?**
If yes to both, decide it now — that's architecture. If either answer is no, defer it — that's
YAGNI.

A concrete example: deciding that a service owns its own data and communicates with others only
through a defined API is architecture, worth deciding before the first line of code, because
retrofitting that boundary after two services have started sharing a database is expensive. Deciding
whether that API needs to support three authentication schemes when you have exactly one client
today is speculative — defer it until a second client with different auth requirements actually
shows up.

## Applying YAGNI in review

- If a pull request introduces an abstraction (interface, config flag, plugin point, strategy
  pattern), the reviewer should be able to point to at least one existing concrete case beyond the
  one being implemented right now that needs it. "We might need this later" is not sufficient
  justification — see [`code-review-guide.md`](./code-review-guide.md).
- Prefer the smallest change that solves the actual ticket. If a broader generalization becomes
  necessary later, it is usually a small, well-informed refactor rather than a large rewrite,
  because by then you know the real shape of the requirement.
- Extracting an abstraction after the second or third concrete need appears (sometimes called the
  "rule of three") is a reasonable default threshold, not a hard law — use judgment when the cost of
  waiting is unusually high.

## Machine-enforced version

This toolkit includes a corresponding rule for AI coding agents at
[`../.claude/rules/no-unnecessary-abstractions.md`](../.claude/rules/no-unnecessary-abstractions.md),
which encodes the same "no abstraction without a second concrete case" discipline so that
AI-generated code doesn't quietly reintroduce speculative generality at a pace human review can't
keep up with.
