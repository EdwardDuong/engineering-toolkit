#!/usr/bin/env bash
#
# validate-links.sh — check that every relative Markdown link in the repo
# points at a file (or directory) that actually exists.
#
# What it does:
#   Walks every *.md file in the target tree (skipping .git/), extracts
#   inline Markdown links of the form [text](path) and image links of the
#   form ![alt](path), ignores links with a URI scheme (http://, https://,
#   mailto:, etc.) and anchor-only links (#section), resolves the remaining
#   relative paths against the directory of the file that contains them
#   (or against the repo root if the link starts with "/"), and reports any
#   link whose target does not exist on disk. Text inside fenced code
#   blocks (``` or ~~~) and inline code spans (`...`) is ignored, since
#   Markdown link syntax shown there as an example is literal text, not
#   a real link.
#
# Usage:
#   sh scripts/validate-links.sh [path-to-repo-root]
#   bash scripts/validate-links.sh [path-to-repo-root]
#
#   path-to-repo-root   Optional. Directory to scan. Defaults to the
#                        current directory.
#
# Exit codes:
#   0   No broken links found.
#   1   One or more broken links found (printed as file:line: link).
#   2   Usage error (bad or missing path argument).
#
# This script is read-only: it never modifies or deletes any file.

set -euo pipefail

ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "validate-links: error: '$ROOT' is not a directory" >&2
  exit 2
fi

ROOT_ABS="$(realpath -m "$ROOT")"

broken=0
checked=0

# Print a leading progress note so the tool doesn't look "stuck" on big repos.
echo "validate-links: scanning Markdown files under '$ROOT_ABS' ..."

while IFS= read -r -d '' file; do
  dir="$(dirname "$file")"
  line_num=0
  in_fence=0
  fence_char=""

  while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    line_num=$((line_num + 1))
    # Normalize away a trailing CR in case a file has CRLF endings.
    line="${raw_line%$'\r'}"

    # --- fenced code block tracking (``` or ~~~); skip link scanning
    # while inside one, since example syntax there is literal text. ---
    trimmed="${line#"${line%%[![:space:]]*}"}"
    if [ "$in_fence" -eq 0 ]; then
      if [[ "$trimmed" =~ ^(\`\`\`+|~~~+) ]]; then
        in_fence=1
        fence_char="${trimmed:0:1}"
        continue
      fi
    else
      first_char="${trimmed:0:1}"
      if [ "$first_char" = "$fence_char" ] && [[ "$trimmed" =~ ^(\`\`\`+|~~~+)[[:space:]]*$ ]]; then
        in_fence=0
        fence_char=""
      fi
      continue
    fi

    # --- mask inline code spans (`...`) so link-like syntax shown as a
    # literal example (e.g. the text `[text](path)`) is not treated as
    # a real link. ---
    line_for_links="$line"
    scan="$line"
    while [[ "$scan" =~ \`[^\`]+\` ]]; do
      whole_span="${BASH_REMATCH[0]}"
      mask="$(printf '%*s' "${#whole_span}" '' | tr ' ' '_')"
      line_for_links="${line_for_links/"$whole_span"/$mask}"
      scan="${scan/"$whole_span"/}"
    done

    # Extract every [..](..) occurrence on this line (also matches the
    # image form ![..](..), which is intentional: image paths should
    # resolve too). Pure-bash extraction (no grep/sed subprocess per
    # line) so this stays fast on repos with thousands of lines.
    remaining="$line_for_links"
    while [[ "$remaining" =~ \[[^][]*\]\(([^()[:space:]]+)\) ]]; do
      link="${BASH_REMATCH[1]}"
      whole_match="${BASH_REMATCH[0]}"
      # Advance past this match so the next iteration finds the next one.
      remaining="${remaining#*"$whole_match"}"

      # Ignore links with a URI scheme (http:, https:, mailto:, ftp:, etc.).
      if [[ "$link" =~ ^[A-Za-z][A-Za-z0-9+.-]*: ]]; then
        continue
      fi

      # Ignore anchor-only links (#some-section).
      case "$link" in
        '#'*) continue ;;
      esac

      # Strip a trailing #anchor or ?query fragment, if present.
      target_path="${link%%#*}"
      target_path="${target_path%%\?*}"

      # Basic percent-decoding for the common "%20" (space) case.
      target_path="${target_path//%20/ }"

      [ -z "$target_path" ] && continue

      checked=$((checked + 1))

      if [ "${target_path:0:1}" = "/" ]; then
        resolved="$(realpath -m "$ROOT_ABS$target_path")"
      else
        resolved="$(realpath -m "$dir/$target_path")"
      fi

      if [ ! -e "$resolved" ]; then
        broken=$((broken + 1))
        rel_file="${file#"$ROOT_ABS"/}"
        echo "BROKEN: ${rel_file}:${line_num}: [$link] -> $resolved"
      fi
    done
  done < "$file"
done < <(find "$ROOT_ABS" -type f -name '*.md' -not -path '*/.git/*' -print0)

echo "---"
echo "validate-links: checked $checked link(s)."

if [ "$broken" -gt 0 ]; then
  echo "validate-links: FAIL — $broken broken link(s) found."
  exit 1
fi

echo "validate-links: PASS — no broken links found."
exit 0
