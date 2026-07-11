# Rule: Architecture First

Think through architecture and data flow before writing code. Code is the
easy part; deciding what the code should be responsible for, what it talks
to, and how data moves through it is the part that's expensive to redo.

## What "thinking through architecture" means in practice

Before the first line of implementation, be able to answer:

- What are the inputs, outputs, and side effects of this change?
- Which existing components does it touch, extend, or replace?
- Where does state live, and who owns it?
- What happens at the boundaries — errors, retries, partial failure,
  concurrent access?
- Does this change fit the existing architecture, or does it strain it? If
  it strains it, is that a signal the architecture needs to evolve, or that
  the change should be scoped differently?

You don't need a diagram in your head for a one-line fix. You do need one
for anything that introduces a new component, changes a data model, adds an
integration point, or affects more than one module.

## When to write a lightweight design note

Write a short design note (an ADR) before implementing when any of these are
true:

- The change introduces a new service, module, or subsystem.
- The change alters a data model or API contract that other code depends on.
- There are two or more viable approaches with real tradeoffs (performance
  vs. simplicity, consistency vs. availability, build vs. buy).
- The change is hard to reverse once shipped (schema migrations, public API
  shape, third-party dependency choice).
- A reviewer or teammate would reasonably ask "why this approach?" and the
  answer isn't obvious from the diff.

Use [templates/ADR.md](../../templates/ADR.md) as the starting structure and
follow [docs/adr-guide.md](../../docs/adr-guide.md) for how to scope and
write it. An ADR does not need to be long — a page that captures context,
options considered, decision, and consequences is enough.

## Sizing the effort to the change

Architecture-first does not mean design-doc-for-everything. Match the
rigor to the blast radius:

| Change type | Design effort |
|---|---|
| Typo fix, log message, one-line bug fix | None — just make the change. |
| New function/method within an existing module, no new dependencies | A sentence or two in the PR description explaining the approach. |
| New module, new dependency, changed public interface | A short design note in the PR description, or a mini-ADR if the decision is contested or non-obvious. |
| New subsystem, new service, schema change, cross-team contract | A full ADR before implementation starts, reviewed before code is written. |

If you're unsure which tier a change falls into, err toward writing the
sentence or two — it's cheap, and it forces you to notice if the "small"
change is actually bigger than it looked.

## Anti-patterns this rule prevents

- Discovering the data model is wrong halfway through implementation.
- Two components independently reinventing the same responsibility because
  no one mapped ownership up front.
- Architecture decisions made implicitly through whichever PR happened to
  need them first, with no record of why.
