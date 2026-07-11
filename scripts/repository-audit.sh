#!/usr/bin/env bash
#
# repository-audit.sh — informational repository health report.
#
# What it does:
#   - Counts files per top-level folder.
#   - Flags empty directories.
#   - Flags Markdown files under a rough minimum size (default: fewer
#     than 5 lines), which are likely stubs.
#   - Flags file names containing spaces.
#   - Flags file names whose casing could collide on a case-insensitive
#     filesystem (Windows/macOS) but not on a case-sensitive one
#     (Linux/git), e.g. "Readme.md" next to "README.md" in the same
#     directory, plus files with an uppercase extension (e.g. "FOO.MD").
#
# This is a report, not a gate: it always exits 0. Read the output to
# see whether anything needs attention.
#
# Usage:
#   sh scripts/repository-audit.sh [path-to-repo-root]
#   bash scripts/repository-audit.sh [path-to-repo-root]
#
#   path-to-repo-root   Optional. Directory to audit. Defaults to the
#                        current directory.
#
# Exit codes:
#   0   Always, on a normal run (this tool is informational).
#   2   Usage error (bad or missing path argument).
#
# This script is read-only: it never modifies or deletes any file.

set -uo pipefail

ROOT="${1:-.}"
MIN_MD_LINES=5

if [ ! -d "$ROOT" ]; then
  echo "repository-audit: error: '$ROOT' is not a directory" >&2
  exit 2
fi

ROOT_ABS="$(realpath -m "$ROOT")"

echo "repository-audit: health report for '$ROOT_ABS'"
echo "================================================================"

# --- 1. File counts per top-level folder ---
echo ""
echo "Files per top-level folder:"
printf '  %-24s %8s\n' "FOLDER" "FILES"
printf '  %-24s %8s\n' "------" "-----"

top_total=0
while IFS= read -r -d '' entry; do
  name="$(basename "$entry")"
  [ "$name" = ".git" ] && continue
  if [ -d "$entry" ]; then
    count="$(find "$entry" -type f -not -path '*/.git/*' | wc -l | tr -d ' ')"
    printf '  %-24s %8s\n' "$name/" "$count"
    top_total=$((top_total + count))
  fi
done < <(find "$ROOT_ABS" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

root_files="$(find "$ROOT_ABS" -mindepth 1 -maxdepth 1 -type f | wc -l | tr -d ' ')"
printf '  %-24s %8s\n' "(root files)" "$root_files"
echo "  --------------------------------"
echo "  Total tracked files (excl. .git): $((top_total + root_files))"

issues=0

# --- 2. Empty directories ---
echo ""
echo "Empty directories:"
empty_count=0
while IFS= read -r -d '' d; do
  rel="${d#"$ROOT_ABS"/}"
  echo "  EMPTY: $rel/"
  empty_count=$((empty_count + 1))
  issues=$((issues + 1))
done < <(find "$ROOT_ABS" -type d -not -path '*/.git*' -empty -print0)
[ "$empty_count" -eq 0 ] && echo "  none found"

# --- 3. Undersized Markdown files (likely stubs) ---
echo ""
echo "Markdown files with fewer than $MIN_MD_LINES lines (likely stubs):"
stub_count=0
while IFS= read -r -d '' f; do
  lines="$(wc -l < "$f" | tr -d ' ')"
  if [ "$lines" -lt "$MIN_MD_LINES" ]; then
    rel="${f#"$ROOT_ABS"/}"
    echo "  STUB ($lines lines): $rel"
    stub_count=$((stub_count + 1))
    issues=$((issues + 1))
  fi
done < <(find "$ROOT_ABS" -type f -name '*.md' -not -path '*/.git/*' -print0)
[ "$stub_count" -eq 0 ] && echo "  none found"

# --- 4. File names containing spaces ---
echo ""
echo "File names containing spaces:"
space_count=0
while IFS= read -r -d '' f; do
  rel="${f#"$ROOT_ABS"/}"
  echo "  SPACE IN NAME: $rel"
  space_count=$((space_count + 1))
  issues=$((issues + 1))
done < <(find "$ROOT_ABS" -type f -not -path '*/.git/*' -name '* *' -print0)
[ "$space_count" -eq 0 ] && echo "  none found"

# --- 5. Casing issues: same-name collisions (case-insensitive) and
#        uppercase file extensions ---
echo ""
echo "File name casing issues:"
casing_count=0

while IFS= read -r -d '' d; do
  # Build a map of lowercase(name) -> list of actual names in this dir.
  declare -A seen=()
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    lower="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"
    if [ -n "${seen[$lower]+x}" ]; then
      rel="${d#"$ROOT_ABS"/}"
      [ -z "$rel" ] && rel="."
      echo "  CASE COLLISION in $rel/: '${seen[$lower]}' vs '$base' differ only by case"
      casing_count=$((casing_count + 1))
      issues=$((issues + 1))
    else
      seen[$lower]="$base"
    fi
  done < <(find "$d" -mindepth 1 -maxdepth 1 -type f -print0)
  unset seen
done < <(find "$ROOT_ABS" -type d -not -path '*/.git*' -print0)

while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  ext="${base##*.}"
  if [ "$ext" != "$base" ] && [[ "$ext" =~ [A-Z] ]]; then
    rel="${f#"$ROOT_ABS"/}"
    echo "  UPPERCASE EXTENSION: $rel"
    casing_count=$((casing_count + 1))
    issues=$((issues + 1))
  fi
done < <(find "$ROOT_ABS" -type f -not -path '*/.git/*' -print0)

[ "$casing_count" -eq 0 ] && echo "  none found"

# --- Summary ---
echo ""
echo "================================================================"
if [ "$issues" -eq 0 ]; then
  echo "repository-audit: no issues found."
else
  echo "repository-audit: $issues issue(s) flagged above. This report is informational only."
fi

exit 0
