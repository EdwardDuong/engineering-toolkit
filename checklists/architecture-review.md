# Architecture Review Checklist

Run this for any change that introduces a new service, a new external dependency, a significant data model change, or a decision that will be expensive to reverse later. Run by the design's author together with reviewers who aren't already bought into the approach. Pair with [../docs/architecture-review.md](../docs/architecture-review.md) and record the decision using [../templates/ADR.md](../templates/ADR.md).

## Alternatives

- [ ] At least one credible alternative approach is documented, with why it was rejected
- [ ] The "do nothing" or "smallest possible change" option was explicitly considered
- [ ] The decision and its tradeoffs are recorded in an ADR, not only in someone's memory or a chat thread

## Failure modes

- [ ] Failure modes of each new component/dependency are identified (what happens when it's slow, down, or returns garbage)
- [ ] The system degrades gracefully or fails safely rather than cascading
- [ ] Retries, timeouts, and circuit breakers are specified for new external calls, not left at library defaults

## Scale & blast radius

- [ ] The design has been sanity-checked against expected scale (data volume, request rate, growth over 1-2 years)
- [ ] Blast radius of a failure is bounded — a single bad deploy or bad input can't take down unrelated systems
- [ ] Multi-tenant or shared-resource impact is considered (noisy neighbor, resource exhaustion)

## Compatibility & operability

- [ ] Backward compatibility is considered for any change to a public interface, schema, or protocol
- [ ] A migration path exists if the change isn't backward compatible
- [ ] The design can be observed, debugged, and rolled back using existing operational tooling
- [ ] Ownership of new components (who's on call for it) is clear before it ships
