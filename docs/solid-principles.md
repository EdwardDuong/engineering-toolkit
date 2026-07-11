# SOLID Principles

SOLID originated as guidance for class-based object-oriented design, but each principle is really
about managing change and coupling — and that generalizes to functions, modules, services, and APIs
regardless of paradigm. This doc states each principle generically and gives a short
language-agnostic example.

## Single Responsibility Principle (SRP)

**A unit of code should have one reason to change.**

"Responsibility" means an axis of change driven by a single actor or concern — not "does one line of
work." A module that both calculates pricing and formats receipts has two responsibilities: pricing
rules change when the business changes pricing; formatting changes when the presentation team
changes layout. Coupling them means a presentation change risks breaking pricing logic.

```
# Before: one function, two reasons to change
function processOrder(order):
    total = order.items.sum(item -> item.price * item.quantity)
    total = applyDiscounts(total, order.customer)
    print("Receipt for " + order.customer.name + ": $" + total)
    return total

# After: pricing and presentation separated
function calculateTotal(order):
    total = order.items.sum(item -> item.price * item.quantity)
    return applyDiscounts(total, order.customer)

function renderReceipt(order, total):
    print("Receipt for " + order.customer.name + ": $" + total)
```

This applies beyond classes: a microservice that owns both "compute recommendations" and "send
marketing email" has the same problem at a coarser grain.

## Open/Closed Principle (OCP)

**A unit should be open for extension but closed for modification.** New behavior should be addable
without editing and re-verifying existing, working code.

This does not mean "add an extension point for everything" (that's speculative generality — see
[`yagni-principle.md`](./yagni-principle.md)). It means: when a variation point is real and
recurring, expose it as a seam rather than a chain of conditionals that every new case has to edit.

```
# Before: every new payment method edits this function
function chargePayment(method, amount):
    if method == "card": chargeCard(amount)
    else if method == "wallet": chargeWallet(amount)
    else if method == "bank_transfer": chargeBankTransfer(amount)
    # adding PayPal means editing this function again

# After: new payment methods register a handler; this function doesn't change
function chargePayment(handler, amount):
    handler.charge(amount)
```

The threshold for applying OCP is evidence: you've already added two or three variants and each one
required editing the same conditional. Apply it retroactively once that pattern shows up, not
preemptively for a single case.

## Liskov Substitution Principle (LSP)

**Anything that claims to implement a contract must be substitutable for that contract without
surprising the caller.** A specialization that narrows preconditions, widens postconditions, or
throws in cases the base contract didn't promise breaks every caller that trusted the contract.

```
# Contract: withdraw(amount) succeeds if amount <= balance
function withdraw(account, amount):
    if amount > account.balance:
        raise InsufficientFunds
    account.balance -= amount

# Violation: a "FrozenAccount" that claims the same contract but
# rejects ALL withdrawals, not just over-balance ones — callers that
# only handle InsufficientFunds now break unexpectedly.
function withdraw(frozenAccount, amount):
    raise AccountFrozen  # not part of the original contract
```

This generalizes to any interface: an HTTP endpoint that claims to be idempotent but isn't, or a
queue consumer that claims to be safe to retry but has side effects on failure, both violate LSP at
the API level even with no classes involved.

## Interface Segregation Principle (ISP)

**Consumers should not be forced to depend on parts of an interface they don't use.** A wide
interface with many unrelated methods forces every implementer to stub out methods it has no
meaningful behavior for, and forces every consumer to take on dependencies (and mock surface, in
tests) it doesn't need.

```
# Before: one wide interface
interface Worker:
    doWork()
    takeBreak()
    fileTaxes()

# Machines don't file taxes; forcing them to implement it is a smell.

# After: split by actual consumer need
interface Workable:
    doWork()

interface Payable:
    fileTaxes()
```

At an API level, this is why a single "God endpoint" that returns every field any consumer might
ever want is worse than several purpose-shaped endpoints or a query mechanism that lets each
consumer ask for what it needs.

## Dependency Inversion Principle (DIP)

**Depend on abstractions, not on concrete, low-level implementations — and let the direction of
dependency point toward stable, high-level policy, not toward volatile detail.** This is distinct
from "dependency injection" (a mechanism); DIP is about which direction the dependency arrow points.

```
# Before: high-level policy depends directly on a concrete low-level detail
function sendWelcomeEmail(user):
    smtpClient = new SmtpClient("smtp.internal:25")
    smtpClient.send(user.email, "Welcome!")

# After: high-level policy depends on an abstraction; the concrete
# implementation is provided from outside
function sendWelcomeEmail(user, notifier):
    notifier.send(user.email, "Welcome!")
```

The business rule ("send a welcome message on signup") should not need to change if the delivery
mechanism changes from SMTP to a queue-based notification service. Inverting the dependency is what
makes that possible without touching the policy code — and it's what makes the policy testable
without a real network call.

## Why this still matters outside OOP

None of these principles requires classes, inheritance, or interfaces in the strict language-feature
sense. SRP applies to functions and services. OCP applies to plugin systems and configuration-driven
pipelines. LSP applies to any implementation of a shared contract, including HTTP APIs. ISP applies
to any interface, including a REST resource or a message schema. DIP applies to any layering between
policy and mechanism, including functional dependency injection via closures or passed-in effects.
Read "class" as "unit of behavior with a boundary" throughout, and the principles hold in any
paradigm. See [`architecture-principles.md`](./architecture-principles.md) for how these connect to
boundary and coupling design more broadly.
