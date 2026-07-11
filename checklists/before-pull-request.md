# Before Pull Request Checklist

Run this before opening a PR (or moving it out of draft), by the PR author. A PR is a request for someone else's time — this checklist exists to make sure that time is spent reviewing the change, not reconstructing context the author already had.

## Description

- [ ] PR description is complete, following [../templates/PR_TEMPLATE.md](../templates/PR_TEMPLATE.md)
- [ ] The "why" is explained, not just the "what" (link to the ticket/issue if one exists)
- [ ] Linked issue or ticket is referenced (e.g., `Closes #123`)
- [ ] Screenshots, recordings, or sample output are attached for user-visible changes

## Content

- [ ] Tests are added or updated for the behavior being changed
- [ ] Documentation is updated for any user-facing or API-facing change
- [ ] No unrelated changes are bundled in (split them into a separate PR)
- [ ] Breaking changes are called out explicitly in the description

## Self-review

- [ ] The full diff was read top to bottom by the author before requesting review
- [ ] Obvious nitpicks (naming, dead code, leftover comments) were fixed before asking a human to find them
- [ ] Risk areas are called out for reviewers so they know where to focus

## CI

- [ ] All required CI checks are green
- [ ] Flaky or skipped checks are explained in the PR description, not silently ignored
- [ ] Reviewers (and any required code owners) are assigned
