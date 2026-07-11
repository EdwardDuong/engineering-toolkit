# DRY — Don't Repeat Yourself

DRY says every piece of knowledge should have a single, unambiguous, authoritative representation in
a system. It is frequently misapplied as "never write similar-looking code twice," which is a
different and much weaker rule that causes real damage when followed too literally.

## What DRY actually targets

DRY is about **knowledge**, not **text**. Two pieces of code that happen to look alike are not
necessarily a DRY violation unless they represent the same underlying business rule or fact.

- If a tax calculation and a discount calculation both happen to multiply two numbers together
  today, that's coincidental similarity, not duplicated knowledge. They represent different rules
  that will diverge the moment either one changes.
- If the *same* validation rule — "an email address must contain exactly one `@`" — is implemented
  independently in three places, that's duplicated knowledge. When the rule changes (say, to support
  new address formats), someone has to remember to update all three, and eventually one gets missed.

The test is: **if this business rule changes, how many places need to change with it, and will
anyone remember all of them?** If the answer is "more than one, and there's no mechanism forcing
them to stay in sync," it's a DRY violation worth fixing. If the answer is "one, even though it
looks similar to code elsewhere," it isn't.

## The overapplication risk: DRY across the wrong boundary

The most common way DRY goes wrong is deduplicating code that looks similar but belongs to different
concerns or different rates of change. This creates **coupling** where none should exist — the
opposite of the maintainability DRY is supposed to buy you.

Example: an e-commerce system has an address validation function used during checkout and a
superficially similar one used during account signup. A well-intentioned engineer merges them into
one shared `validateAddress` function to avoid "duplication." Six months later, checkout needs to
allow PO boxes and signup needs to reject them. Now the shared function needs a flag (`allowPoBox:
boolean`), then another flag for the next divergent requirement, and eventually the "shared"
function is a tangle of conditionals serving two masters that were never actually the same rule —
they just started out looking similar by coincidence.

This is worse than the original duplication would have been, because:

- The two call sites are now coupled: a change intended for one accidentally risks breaking the
  other.
- The function's cyclomatic complexity has grown to accommodate two purposes, making it harder to
  reason about either one.
- Removing the coupling later (splitting them back apart) is now a riskier change than the original
  "duplication" ever was.

**Rule of thumb:** only deduplicate code that represents the same rule and is *owned by the same
team or the same reason for changing*. If two pieces of logic could plausibly diverge because
different people, teams, or business decisions govern them, keep them separate even if they
currently read identically. A small amount of duplicated code that stays simple and independently
changeable is usually cheaper than a shared abstraction that couples unrelated concerns.

## Applying DRY well

- Deduplicate constants and configuration values aggressively — a magic number or string repeated in
  five places with no semantic name attached is almost always a DRY violation with no
  counter-argument.
- Deduplicate business rules that are genuinely one rule, and put the single representation
  somewhere with an obvious name so the next person modifying that rule can find it without
  grepping.
- Be more cautious deduplicating behavior across module or service boundaries — see
  [`architecture-principles.md`](./architecture-principles.md) on the cost of coupling. Duplication
  *within* a single module's boundary is cheap to fix later; duplication that would require
  introducing a new cross-boundary dependency to remove is a bigger decision.
- When you're not sure whether two things are the same rule or coincidentally similar, wait. A
  little duplication now, revisited once a third case shows up and clarifies the actual pattern,
  tends to produce a better abstraction than deduplicating the first two instances you see — see
  [`yagni-principle.md`](./yagni-principle.md).

## DRY and technical debt

Unmanaged duplication of genuine business logic is a form of technical debt: it doesn't break
anything today, but every unsynchronized copy is a latent bug waiting for the day only some of them
get updated. Track known duplication that hasn't yet been consolidated the same way you'd track any
other debt — see [`technical-debt.md`](./technical-debt.md) — rather than either ignoring it
indefinitely or rushing to deduplicate before you understand whether the copies are really the same
rule.
