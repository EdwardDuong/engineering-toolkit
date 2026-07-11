#!/usr/bin/env bash
#
# validate-markdown.sh — check basic Markdown hygiene across the repo.
#
# What it does, per *.md file (skipping .git/):
#   - No trailing whitespace on a line, except an intentional two-space
#     "hard line break" at end of line.
#   - The file ends with exactly one trailing newline (not zero, not
#     several, i.e. no blank line(s) dangling at end of file).
#   - No more than one blank line in a row.
#   - ATX heading levels increment sensibly: a heading may drop to any
#     shallower level, but may only get one level deeper than the
#     previous heading (e.g. "#" directly followed by "###" is flagged).
#   - No literal placeholder markers left behind: an unfinished-work
#     marker, a premature "launching soon" notice, or placeholder filler
#     text, none of which belong in a production-quality repo.
#
# Usage:
#   sh scripts/validate-markdown.sh [path-to-repo-root]
#   bash scripts/validate-markdown.sh [path-to-repo-root]
#
#   path-to-repo-root   Optional. Directory to scan. Defaults to the
#                        current directory.
#
# Exit codes:
#   0   No hygiene violations found.
#   1   One or more violations found (printed as file:line: message).
#   2   Usage error (bad or missing path argument).
#
# This script is read-only: it never modifies or deletes any file.

set -euo pipefail

ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "validate-markdown: error: '$ROOT' is not a directory" >&2
  exit 2
fi

ROOT_ABS="$(realpath -m "$ROOT")"

# Forbidden placeholder markers. Only *.md files are scanned, so this
# script's own source is never checked against its own patterns.
FORBIDDEN_1="TODO"
FORBIDDEN_2="Coming Soon"
FORBIDDEN_3="Lorem Ipsum"

violations=0
files_checked=0

echo "validate-markdown: scanning Markdown files under '$ROOT_ABS' ..."

while IFS= read -r -d '' file; do
  files_checked=$((files_checked + 1))
  rel_file="${file#"$ROOT_ABS"/}"

  line_num=0
  blank_run=0
  prev_heading_level=0
  in_fence=0
  fence_char=""

  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    line_num=$((line_num + 1))
    line="${raw_line%$'\r'}"

    # --- fenced code block tracking (``` or ~~~) — pure bash, no subshells ---
    trimmed="${line#"${line%%[![:space:]]*}"}"
    if [ "$in_fence" -eq 0 ]; then
      if [[ "$trimmed" =~ ^(\`\`\`+|~~~+) ]]; then
        in_fence=1
        fence_char="${trimmed:0:1}"
      fi
    else
      first_char="${trimmed:0:1}"
      if [ "$first_char" = "$fence_char" ] && [[ "$trimmed" =~ ^(\`\`\`+|~~~+)[[:space:]]*$ ]]; then
        in_fence=0
        fence_char=""
      fi
    fi

    # --- trailing whitespace (allow exactly one hard-break: two spaces) ---
    if [[ "$line" =~ [[:space:]]+$ ]]; then
      trailing="${BASH_REMATCH[0]}"
      if [ "$trailing" != "  " ]; then
        violations=$((violations + 1))
        echo "VIOLATION: ${rel_file}:${line_num}: trailing whitespace"
      fi
    fi

    # --- blank line run ---
    if [ -z "$line" ]; then
      blank_run=$((blank_run + 1))
      if [ "$blank_run" -eq 2 ]; then
        violations=$((violations + 1))
        echo "VIOLATION: ${rel_file}:${line_num}: more than one blank line in a row"
      fi
    else
      blank_run=0
    fi

    # --- heading level jumps (skip while inside a fenced code block) ---
    if [ "$in_fence" -eq 0 ] && [[ "$line" =~ ^(#{1,6})[[:space:]] ]]; then
      level=${#BASH_REMATCH[1]}
      if [ "$prev_heading_level" -gt 0 ] && [ "$level" -gt $((prev_heading_level + 1)) ]; then
        violations=$((violations + 1))
        echo "VIOLATION: ${rel_file}:${line_num}: heading level jumps from H${prev_heading_level} to H${level} (skipped a level)"
      fi
      prev_heading_level=$level
    fi

    # --- forbidden placeholder strings (fixed substrings, no regex needed) ---
    if [ "${line/$FORBIDDEN_1/}" != "$line" ]; then
      violations=$((violations + 1))
      echo "VIOLATION: ${rel_file}:${line_num}: contains forbidden placeholder marker '${FORBIDDEN_1}'"
    fi
    if [ "${line/$FORBIDDEN_2/}" != "$line" ]; then
      violations=$((violations + 1))
      echo "VIOLATION: ${rel_file}:${line_num}: contains forbidden placeholder marker '${FORBIDDEN_2}'"
    fi
    if [ "${line/$FORBIDDEN_3/}" != "$line" ]; then
      violations=$((violations + 1))
      echo "VIOLATION: ${rel_file}:${line_num}: contains forbidden placeholder marker '${FORBIDDEN_3}'"
    fi
  done < "$file"

  # --- trailing newline hygiene ---
  if [ -s "$file" ]; then
    last_byte="$(tail -c 1 "$file")"
    if [ -n "$last_byte" ]; then
      violations=$((violations + 1))
      echo "VIOLATION: ${rel_file}: file does not end with a newline"
    else
      last2hex="$(tail -c 2 "$file" | od -An -tx1 | tr -d ' \n')"
      if [ "$last2hex" = "0a0a" ]; then
        violations=$((violations + 1))
        echo "VIOLATION: ${rel_file}: file ends with blank line(s) (more than one trailing newline)"
      fi
    fi
  fi
done < <(find "$ROOT_ABS" -type f -name '*.md' -not -path '*/.git/*' -print0)

echo "---"
echo "validate-markdown: checked $files_checked file(s)."

if [ "$violations" -gt 0 ]; then
  echo "validate-markdown: FAIL — $violations violation(s) found."
  exit 1
fi

echo "validate-markdown: PASS — no hygiene violations found."
exit 0
