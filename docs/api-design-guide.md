# API Design Guide

An API is a promise. Once something depends on it, every change has to either honor the existing
promise or explicitly break it with warning. This guide applies to any interface between components
— a REST API, an RPC service, a message schema, or a library's public function signatures — the
underlying design concerns are the same regardless of transport.

## Design for stability first

- **Design the contract before the implementation.** Sketch the shape of requests, responses, and
  error cases before writing the code that fulfills them — it's far cheaper to change a sketch than
  a shipped interface. See [`rfc-process.md`](./rfc-process.md) for interfaces significant enough to
  warrant a written proposal first.
- **Expose the minimum surface that solves the problem.** Every field, parameter, and endpoint you
  publish is a promise you now have to keep. Unused flexibility exposed "just in case" (see
  [`yagni-principle.md`](./yagni-principle.md)) becomes permanent surface area you can't remove
  without a breaking change.
- **Model the domain, not the current implementation.** An interface that exposes internal storage
  details (a field that's really a database column name, an endpoint shaped around one specific
  query) breaks the moment the implementation changes, even though the actual contract with
  consumers didn't need to.

## Versioning

- Version the contract explicitly, not implicitly. Whether via a URL path segment, a header, or a
  schema version field, consumers need an unambiguous way to know which version of the contract
  they're speaking, and you need a way to run more than one version simultaneously during a
  migration.
- Prefer additive, backward-compatible changes within a version — see
  [`semantic-versioning.md`](./semantic-versioning.md) for what counts as breaking. Most evolution
  (new optional fields, new endpoints) doesn't require a new version at all.
- When a breaking change is unavoidable, support both the old and new version concurrently for a
  defined deprecation window, communicated in advance, rather than cutting over instantly. See
  [`../.claude/rules/backward-compatibility.md`](../.claude/rules/backward-compatibility.md) for
  this toolkit's default stance on how conservative to be here.
- Deprecation should be observable, not just documented: return a deprecation warning (a header, a
  field, a logged notice) so consumers still on the old version can detect it programmatically, not
  only by reading a changelog they may never see.

## Error contracts

- Errors are part of the contract, not an afterthought. Define a consistent error shape (a stable
  set of fields: an error code, a human-readable message, optionally a machine-actionable detail)
  used across every endpoint or method, not a different ad hoc shape per failure.
- Distinguish **client errors** (bad request, not found, unauthorized — the caller can fix this)
  from **server errors** (something broke on your side — the caller can retry but can't fix the
  cause) unambiguously, using whatever mechanism your protocol provides (status code ranges,
  explicit error categories in a response body).
- Error codes/identifiers should be stable and documented — a consumer should be able to branch on
  the error code programmatically, not have to pattern-match on a human-readable message string that
  might get reworded.
- Never leak internal implementation detail in an error surfaced to an external consumer (stack
  traces, internal hostnames, raw database errors) — see [`security-guide.md`](./security-guide.md).
  Log the full detail internally; return a sanitized, actionable message externally.

## Idempotency

- Any operation that might reasonably be retried (which is most operations, given that networks
  fail) should define its idempotency behavior explicitly: is calling it twice with the same input
  safe, or does it double-apply?
- For operations with side effects that must not double-apply (creating a payment, sending a
  notification), support an idempotency key supplied by the caller, so a retried request with the
  same key is recognized and returns the original result instead of repeating the effect.
- Document idempotency behavior per-operation, not as a blanket assumption — a read is naturally
  idempotent, a "create" typically is not without an explicit key, and a "delete" is usually
  idempotent in effect (the resource ends up absent either way) but implementations sometimes get
  this wrong by erroring on a second call instead of treating it as a no-op.

## Pagination

- Any endpoint or method that can return an unbounded number of results must paginate, with a
  bounded default page size — see the unbounded-result-set anti-pattern in
  [`performance-guide.md`](./performance-guide.md).
- Prefer cursor-based pagination over offset-based for anything backed by frequently-changing data —
  offset pagination skips or duplicates items when rows are inserted or deleted between pages, which
  cursor-based pagination avoids by construction.
- Make the total-count-availability explicit rather than implied — computing an exact total can be
  expensive at scale; decide and document whether it's provided, approximate, or omitted, rather
  than letting consumers assume a total is always cheap and accurate.

## Backward compatibility

- The default posture is: existing consumers must continue working across MINOR and PATCH releases
  without any change on their part. This is the practical meaning of the SemVer contract described
  in [`semantic-versioning.md`](./semantic-versioning.md).
- Additive changes (new optional field, new endpoint, new enum value guarded by documented
  unknown-value handling) are safe. Anything that changes the meaning or required shape of existing
  surface is not, regardless of how small the change looks in the diff.
- When you must remove or change something, prefer a phased approach: add the new shape alongside
  the old, migrate consumers, deprecate the old with a clear timeline, then remove it in a MAJOR
  release — never removed in the same release it was deprecated in, unless there are provably zero
  consumers (verified, not assumed).
- Treat your own internal consumers with the same discipline as external ones once more than one
  team depends on an interface — "it's just our other service" is how internal APIs quietly become
  as brittle as external ones, without the version discipline that would have protected them.
