#!/usr/bin/env bash
#
# bootstrap-project.sh — adopt this toolkit into another (host) project.
#
# What it does:
#   Copies the toolkit's portable, non-toolkit-specific folders
#   (.claude/, docs/, templates/, prompts/, checklists/, scripts/) from
#   this repository into a target directory. Any file that already
#   exists at the destination is left untouched and reported as
#   skipped — this script never overwrites or deletes anything.
#
# Usage:
#   sh scripts/bootstrap-project.sh <target-directory>
#   bash scripts/bootstrap-project.sh <target-directory>
#
#   target-directory   Required. Path to the host project that should
#                        receive a copy of the toolkit. Created if it
#                        does not already exist.
#
# Exit codes:
#   0   Completed (files copied and/or skipped as already present).
#   1   Usage error (missing target-directory argument).
#   2   Target path invalid, or source/target resolve to the same tree.
#
# This script only copies and creates files/directories. It never
# deletes or overwrites existing files.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bootstrap-project.sh <target-directory>" >&2
  echo "  Copies .claude/, docs/, templates/, prompts/, checklists/, and" >&2
  echo "  scripts/ from this toolkit into <target-directory>, without" >&2
  echo "  overwriting any file that already exists there." >&2
  exit 1
fi

TARGET_RAW="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$TARGET_RAW" 2>/dev/null || {
  echo "bootstrap-project: error: could not create target directory '$TARGET_RAW'" >&2
  exit 2
}

TARGET_ROOT="$(cd "$TARGET_RAW" && pwd)"

if [ "$TARGET_ROOT" = "$SOURCE_ROOT" ]; then
  echo "bootstrap-project: error: target directory is the toolkit's own repo root; refusing to copy onto itself" >&2
  exit 2
fi

FOLDERS=(".claude" "docs" "templates" "prompts" "checklists" "scripts")

copied=0
skipped=0
folders_found=0

echo "bootstrap-project: copying toolkit folders from '$SOURCE_ROOT' into '$TARGET_ROOT' ..."

for folder in "${FOLDERS[@]}"; do
  src="$SOURCE_ROOT/$folder"
  [ -d "$src" ] || continue
  folders_found=$((folders_found + 1))

  while IFS= read -r -d '' srcfile; do
    relpath="${srcfile#"$src"/}"
    destfile="$TARGET_ROOT/$folder/$relpath"
    destdir="$(dirname "$destfile")"
    mkdir -p "$destdir"

    if [ -e "$destfile" ]; then
      skipped=$((skipped + 1))
      echo "SKIP (already exists): $folder/$relpath"
    else
      cp "$srcfile" "$destfile"
      copied=$((copied + 1))
      echo "COPY: $folder/$relpath"
    fi
  done < <(find "$src" -type f -print0)
done

echo "---"

if [ "$folders_found" -eq 0 ]; then
  echo "bootstrap-project: error: none of the expected toolkit folders were found under '$SOURCE_ROOT'" >&2
  exit 2
fi

echo "bootstrap-project: done. $copied file(s) copied, $skipped file(s) skipped (already present)."
echo "bootstrap-project: no existing files in '$TARGET_ROOT' were modified or removed."
exit 0
