<#
.SYNOPSIS
    release-check.ps1 - pre-release gate for this repository.

.DESCRIPTION
    Runs a small set of checks that should all pass before tagging a
    release, and prints a pass/fail summary suitable for CI or local
    use:
      1. CHANGELOG.md exists and has at least one released version
         entry (i.e. more than just an "[Unreleased]" heading).
      2. LICENSE exists and is non-empty.
      3. scripts/validate-markdown.ps1 passes.
      4. scripts/validate-links.ps1 passes.

.PARAMETER Path
    Optional. Repository root to check. Defaults to the current
    directory.

.EXAMPLE
    powershell -File scripts/release-check.ps1
    pwsh scripts/release-check.ps1 C:\path\to\repo

.NOTES
    Exit codes:
      0   All checks passed.
      1   One or more checks failed.
      2   Usage error (bad path argument, or sibling scripts missing).

    This script is read-only: it never modifies or deletes any file.
#>

param(
    [string]$Path = "."
)

$ErrorActionPreference = 'Stop'

try {
    $rootItem = Get-Item -LiteralPath $Path -ErrorAction Stop
    if (-not $rootItem.PSIsContainer) {
        Write-Error "release-check: error: '$Path' is not a directory"
        exit 2
    }
    $rootAbs = $rootItem.FullName.TrimEnd('\', '/')
}
catch {
    Write-Error "release-check: error: '$Path' is not a directory"
    exit 2
}

$scriptDir = $PSScriptRoot
$failures = 0

function Report-Pass([string]$Message) { Write-Host "PASS: $Message" }
function Report-Fail([string]$Message) {
    Write-Host "FAIL: $Message"
    $script:failures++
}

Write-Host "release-check: running pre-release checks against '$rootAbs' ..."
Write-Host "---"

# 1. CHANGELOG.md has a real released entry, not just [Unreleased].
$changelogPath = Join-Path $rootAbs 'CHANGELOG.md'
if (-not (Test-Path -LiteralPath $changelogPath -PathType Leaf)) {
    Report-Fail "CHANGELOG.md not found"
}
else {
    $hasRelease = $false
    $changelogLines = Get-Content -LiteralPath $changelogPath
    foreach ($line in $changelogLines) {
        if ($line -match '^##\s*\[([^\]]+)\]') {
            $version = $Matches[1]
            if ($version -ne 'Unreleased') {
                $hasRelease = $true
                break
            }
        }
    }

    if ($hasRelease) {
        Report-Pass "CHANGELOG.md has at least one released version entry"
    }
    else {
        Report-Fail "CHANGELOG.md has no released version entry (only [Unreleased], or no version headings at all)"
    }
}

# 2. LICENSE exists and is non-empty.
$licensePath = Join-Path $rootAbs 'LICENSE'
$licenseItem = Get-Item -LiteralPath $licensePath -ErrorAction SilentlyContinue
if ($null -ne $licenseItem -and $licenseItem.Length -gt 0) {
    Report-Pass "LICENSE exists and is non-empty"
}
else {
    Report-Fail "LICENSE is missing or empty"
}

# 3. validate-markdown.ps1
$validateMd = Join-Path $scriptDir 'validate-markdown.ps1'
if (-not (Test-Path -LiteralPath $validateMd -PathType Leaf)) {
    Report-Fail "scripts/validate-markdown.ps1 not found alongside release-check.ps1"
}
else {
    & powershell -NoProfile -File $validateMd $rootAbs
    if ($LASTEXITCODE -eq 0) {
        Report-Pass "validate-markdown.ps1"
    }
    else {
        Report-Fail "validate-markdown.ps1 reported hygiene violations (see output above)"
    }
}

Write-Host "---"

# 4. validate-links.ps1
$validateLinks = Join-Path $scriptDir 'validate-links.ps1'
if (-not (Test-Path -LiteralPath $validateLinks -PathType Leaf)) {
    Report-Fail "scripts/validate-links.ps1 not found alongside release-check.ps1"
}
else {
    & powershell -NoProfile -File $validateLinks $rootAbs
    if ($LASTEXITCODE -eq 0) {
        Report-Pass "validate-links.ps1"
    }
    else {
        Report-Fail "validate-links.ps1 reported broken links (see output above)"
    }
}

Write-Host "---"
Write-Host "release-check: summary"

if ($failures -gt 0) {
    Write-Host "release-check: FAIL - $failures check(s) failed. Not ready to release."
    exit 1
}

Write-Host "release-check: PASS - all checks passed. Ready to tag a release."
exit 0
