<!--
This is the GitHub-consumed PR template for the engineering-toolkit repo
itself. It mirrors the structure of templates/pull-request.md, which is the
generic PR template this toolkit provides for *consumer* projects to reuse.
-->

## Summary

<!-- What does this PR change, and why? 1-3 sentences. -->

## Type of Change

- [ ] New content (doc, template, prompt, checklist, or example)
- [ ] Update to existing content (correction, clarification, expansion)
- [ ] New or updated script (`scripts/`)
- [ ] Claude Code configuration (`.claude/`)
- [ ] Repository infrastructure (`.github/`, root config files)
- [ ] Breaking change (renames or removes a file other repos may reference)

## Related Issue

<!-- Closes #123, or "N/A" -->

## How Has This Been Tested?

- [ ] Ran `scripts/validate-links.sh` (or `.ps1`) locally — no broken
      relative links
- [ ] Ran `scripts/validate-markdown.sh` (or `.ps1`) locally — no lint
      errors
- [ ] For scripts: ran the script manually and confirmed expected
      behavior on affected platform(s)
- [ ] For new files: added an entry to the relevant folder's `README.md`
      index

## Checklist

See [`checklists/before-pull-request.md`](../../checklists/before-pull-request.md)
for the full gate. At minimum:

- [ ] Content is complete — no placeholders, "TODO", or "Coming Soon"
- [ ] Filenames use kebab-case
- [ ] Cross-links use relative Markdown paths and resolve correctly
- [ ] New file is indexed in its folder's `README.md`
- [ ] Content is language/framework-agnostic (or explicitly scoped if not)
- [ ] Tone and structure match sibling files in the same folder
