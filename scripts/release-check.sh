#!/usr/bin/env bash
#
# release-check.sh — pre-release gate for this repository.
#
# What it does:
#   Runs a small set of checks that should all pass before tagging a
#   release, and prints a pass/fail summary suitable for CI or local
#   use:
#     1. CHANGELOG.md exists and has at least one released version
#        entry (i.e. more than just an "[Unreleased]" heading).
#     2. LICENSE exists and is non-empty.
#     3. scripts/validate-markdown.sh passes.
#     4. scripts/validate-links.sh passes.
#
# Usage:
#   sh scripts/release-check.sh [path-to-repo-root]
#   bash scripts/release-check.sh [path-to-repo-root]
#
#   path-to-repo-root   Optional. Repository root to check. Defaults to
#                        the current directory.
#
# Exit codes:
#   0   All checks passed.
#   1   One or more checks failed.
#   2   Usage error (bad path argument, or sibling scripts missing).
#
# This script is read-only: it never modifies or deletes any file.

set -euo pipefail

ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "release-check: error: '$ROOT' is not a directory" >&2
  exit 2
fi

ROOT_ABS="$(realpath -m "$ROOT")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

failures=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures + 1)); }

echo "release-check: running pre-release checks against '$ROOT_ABS' ..."
echo "---"

# 1. CHANGELOG.md has a real released entry, not just [Unreleased].
CHANGELOG="$ROOT_ABS/CHANGELOG.md"
if [ ! -f "$CHANGELOG" ]; then
  fail "CHANGELOG.md not found"
else
  has_release=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]*\[([^]]+)\] ]]; then
      version="${BASH_REMATCH[1]}"
      if [ "$version" != "Unreleased" ]; then
        has_release=1
        break
      fi
    fi
  done < "$CHANGELOG"

  if [ "$has_release" -eq 1 ]; then
    pass "CHANGELOG.md has at least one released version entry"
  else
    fail "CHANGELOG.md has no released version entry (only [Unreleased], or no version headings at all)"
  fi
fi

# 2. LICENSE exists and is non-empty.
LICENSE_FILE="$ROOT_ABS/LICENSE"
if [ -s "$LICENSE_FILE" ]; then
  pass "LICENSE exists and is non-empty"
else
  fail "LICENSE is missing or empty"
fi

# 3. validate-markdown.sh
VALIDATE_MD="$SCRIPT_DIR/validate-markdown.sh"
if [ ! -f "$VALIDATE_MD" ]; then
  fail "scripts/validate-markdown.sh not found alongside release-check.sh"
else
  if bash "$VALIDATE_MD" "$ROOT_ABS"; then
    pass "validate-markdown.sh"
  else
    fail "validate-markdown.sh reported hygiene violations (see output above)"
  fi
fi

echo "---"

# 4. validate-links.sh
VALIDATE_LINKS="$SCRIPT_DIR/validate-links.sh"
if [ ! -f "$VALIDATE_LINKS" ]; then
  fail "scripts/validate-links.sh not found alongside release-check.sh"
else
  if bash "$VALIDATE_LINKS" "$ROOT_ABS"; then
    pass "validate-links.sh"
  else
    fail "validate-links.sh reported broken links (see output above)"
  fi
fi

echo "---"
echo "release-check: summary"

if [ "$failures" -gt 0 ]; then
  echo "release-check: FAIL — $failures check(s) failed. Not ready to release."
  exit 1
fi

echo "release-check: PASS — all checks passed. Ready to tag a release."
exit 0
