# Assets

Shared static assets referenced from documentation across this
repository — currently just the project logo, used in the root
`README.md` header.

## Contents

| File        | Description                                              |
| ----------- | ---------------------------------------------------------- |
| `logo.svg`  | Wordmark lockup for "Engineering Toolkit". Uses `currentColor` for the mark so it adapts to light and dark backgrounds. |

## Adding more assets

- **Prefer SVG for anything drawable.** Diagrams, icons, and marks
  should be authored as `.svg` rather than exported as `.png` or
  `.jpg`. SVG is plain text, so it scales cleanly to any size, diffs
  meaningfully in pull requests, and can be edited without
  regenerating a binary.
- **Reserve raster formats (`.png`, `.jpg`) for actual photographs or
  screenshots** — content that cannot reasonably be represented as
  vector shapes. Even then, keep files small and crop to what is
  necessary.
- **Keep new marks theme-aware.** Where practical, use `currentColor`
  or a small, deliberate palette (rather than hard-coded black or
  white) so an asset placed in a Markdown file renders legibly on both
  light and dark backgrounds.
- **Name files descriptively and in lowercase-with-hyphens** (for
  example `architecture-overview.svg`), consistent with the rest of
  this repository, to avoid the casing collisions that
  `scripts/repository-audit.sh` flags.
- **Reference assets with a relative link** from the Markdown file that
  uses them (for example `../assets/logo.svg` from a file one level
  deep), so `scripts/validate-links.sh` can confirm the reference
  resolves.
