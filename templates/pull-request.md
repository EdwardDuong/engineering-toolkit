<!--
Template: Pull Request Description
Use this when: opening a pull request and you want reviewers to have the context they need.
Run through ../checklists/before-pull-request.md before requesting review.
A worked example: ../examples/good-pull-request.md
Many repos can drop this into .github/pull_request_template.md so it auto-populates new PRs.
-->

## Summary

<!-- What does this PR do, in 1-3 sentences? Assume the reviewer has not read the linked issue. -->

[Summary of the change.]

## Type of Change

<!-- Check all that apply. -->

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Refactor (no functional change)
- [ ] Documentation
- [ ] Chore / tooling / CI

## Related Issue(s)

<!-- Link issues this PR closes or relates to. Use "Closes #123" so it auto-closes on merge. -->

Closes #[issue number]

## Approach

<!-- How did you solve the problem? Call out any non-obvious decisions, tradeoffs, or things you
     considered and rejected. This is the section that saves reviewers the most time. -->

[Explain the approach and any notable decisions.]

## Testing Performed

<!-- What did you actually run? Unit tests, manual testing steps, edge cases checked. -->

- [ ] Unit tests added/updated
- [ ] Manually tested: [describe steps]
- [ ] Edge cases considered: [list]

## Screenshots

<!-- Required for UI changes. Before/after is ideal. Delete this section if not applicable. -->

[Before/after screenshots or recordings, if applicable.]

## Rollback Plan

<!-- How would this be undone if it causes a problem in production? -->

[e.g., "Revert this PR — no data migrations involved" or describe manual rollback steps.]

## Checklist

<!-- See the full pre-PR checklist: ../checklists/before-pull-request.md -->

- [ ] I have read and completed [`../checklists/before-pull-request.md`](../checklists/before-pull-request.md)
- [ ] This PR is scoped to a single concern and is reasonably sized for review
- [ ] I have updated relevant documentation
