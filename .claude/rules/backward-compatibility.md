# Rule: Backward Compatibility

Treat every change to a public interface — API, CLI, config format, schema,
exported library function — as potentially breaking until proven otherwise.
Consumers you can't see (other teams, external users, other services) are
depending on the current behavior, even the parts of it that look
accidental.

## Evaluating whether a change is breaking

A change is breaking if any existing, reasonable caller could stop working
or start behaving differently because of it. Concretely, watch for:

- Removing or renaming a public function, endpoint, field, CLI flag, or
  config key.
- Changing the type, shape, or meaning of an input or output.
- Changing default behavior that callers may be relying on implicitly.
- Making a previously optional parameter required, or vice versa in a way
  that changes semantics.
- Tightening validation that previously-valid inputs now fail.
- Changing error behavior (a call that used to succeed now throws, or an
  error type/code changes).
- Changing timing/ordering guarantees that callers may depend on even if
  those guarantees were never explicitly documented.

A change is *not* breaking if it only adds new, optional capability without
altering any existing path — new optional parameter with a default that
reproduces old behavior, new endpoint, new field additive to a response.

When it's ambiguous, assume it's breaking. The cost of treating a safe
change as breaking (a bit of extra ceremony) is much lower than the cost of
treating a breaking change as safe (a broken consumer in production).

## Deprecation before removal

Don't remove or change a public interface directly. Deprecate first:

1. **Announce** the deprecation — mark it in code (deprecation annotation,
   docstring, warning) and in docs/changelog, stating what replaces it.
2. **Give a migration path.** State the replacement clearly enough that a
   caller can move without guessing, ideally with an example.
3. **Give a deprecation window.** How long depends on the interface's reach
   and the project's versioning policy — see
   [docs/semantic-versioning.md](../../docs/semantic-versioning.md) for how
   this project scopes breaking changes to major versions.
4. **Remove only after the window has passed**, and call the removal out
   explicitly in the changelog as a breaking change.

Exceptions: security fixes may require breaking a contract immediately.
When that happens, still document what broke and why, and provide the
clearest migration guidance you can under the circumstances — speed doesn't
excuse silence.

## Dependencies

Backward compatibility also runs in the other direction: upgrading a
dependency can itself be a breaking change for your project. Before bumping
a dependency's major version, check its changelog for breaking changes and
follow [docs/dependency-management.md](../../docs/dependency-management.md)
for how this project vets and stages dependency upgrades.
