# Before Merge Checklist

Run this immediately before merging a PR, by whoever clicks merge (often the author, sometimes a maintainer). This is the last gate before the change becomes everyone's baseline — treat it as a hard stop, not a formality.

## Review

- [ ] Required number of approvals obtained from the appropriate reviewers/code owners
- [ ] Every review comment is resolved — either addressed in code or answered with a stated reason it wasn't
- [ ] No outstanding "request changes" review is still active
- [ ] Reviewers actually reviewed the current diff, not an earlier version, if changes were made after approval

## Technical state

- [ ] CI is green on the latest commit (not a stale run from before the last push)
- [ ] No merge conflicts with the target branch
- [ ] Branch is up to date enough that the merge won't silently reintroduce a bug already fixed upstream

## Definition of done

- [ ] Change meets [../docs/definition-of-done.md](../docs/definition-of-done.md)
- [ ] Any follow-up work that was deferred during review is captured as a tracked ticket, not just a comment thread
- [ ] Merge strategy (squash/rebase/merge commit) matches project convention
