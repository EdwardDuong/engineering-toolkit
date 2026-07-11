<#
.SYNOPSIS
    validate-markdown.ps1 - check basic Markdown hygiene across the repo.

.DESCRIPTION
    For every *.md file (skipping .git/):
      - No trailing whitespace on a line, except an intentional
        two-space "hard line break" at end of line.
      - The file ends with exactly one trailing newline (not zero, not
        several).
      - No more than one blank line in a row.
      - ATX heading levels increment sensibly: a heading may drop to
        any shallower level, but may only get one level deeper than the
        previous heading (e.g. "#" directly followed by "###" is
        flagged).
      - No literal placeholder markers left behind: an unfinished-work
        marker, a premature "launching soon" notice, or placeholder
        filler text.

.PARAMETER Path
    Optional. Directory to scan. Defaults to the current directory.

.EXAMPLE
    powershell -File scripts/validate-markdown.ps1
    pwsh scripts/validate-markdown.ps1 C:\path\to\repo

.NOTES
    Exit codes:
      0   No hygiene violations found.
      1   One or more violations found (printed as file:line: message).
      2   Usage error (bad or missing path argument).

    This script is read-only: it never modifies or deletes any file.
#>

param(
    [string]$Path = "."
)

$ErrorActionPreference = 'Stop'

try {
    $rootItem = Get-Item -LiteralPath $Path -ErrorAction Stop
    if (-not $rootItem.PSIsContainer) {
        Write-Error "validate-markdown: error: '$Path' is not a directory"
        exit 2
    }
    $rootAbs = $rootItem.FullName.TrimEnd('\', '/')
}
catch {
    Write-Error "validate-markdown: error: '$Path' is not a directory"
    exit 2
}

# Forbidden placeholder markers. Only *.md files are scanned, so this
# script's own source is never checked against its own patterns.
$forbidden = @('TODO', 'Coming Soon', 'Lorem Ipsum')

$fenceOpenRegex = [regex]'^(```+|~~~+)'
$fenceCharAt0 = { param($s) if ($s.Length -gt 0) { $s.Substring(0, 1) } else { '' } }
$headingRegex = [regex]'^(#{1,6})[ \t]'

$violations = 0
$filesChecked = 0

Write-Host "validate-markdown: scanning Markdown files under '$rootAbs' ..."

try {
    $mdFiles = Get-ChildItem -LiteralPath $rootAbs -Recurse -File -Filter '*.md' -ErrorAction Stop |
        Where-Object { $_.FullName -notmatch '(^|[\\/])\.git([\\/]|$)' } |
        Sort-Object FullName

    foreach ($file in $mdFiles) {
        $filesChecked++
        $relFile = $file.FullName.Substring($rootAbs.Length).TrimStart('\', '/')

        $raw = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
        if ($null -eq $raw) { $raw = '' }

        # Split into lines without losing information about a trailing
        # newline (Get-Content -Raw preserves the exact file content).
        $normalized = $raw -replace "`r`n", "`n" -replace "`r", "`n"
        $lines = $normalized -split "`n"
        # If the file ends with "\n", the split produces one extra empty
        # trailing element; strip it so line numbering matches real lines.
        $endsWithNewline = $normalized.EndsWith("`n")
        if ($endsWithNewline -and $lines.Length -gt 0) {
            $lines = $lines[0..($lines.Length - 2)]
        }

        $blankRun = 0
        $prevHeadingLevel = 0
        $inFence = $false
        $fenceChar = ''

        for ($i = 0; $i -lt $lines.Length; $i++) {
            $lineNum = $i + 1
            $line = $lines[$i]

            $trimmed = $line.TrimStart(' ', "`t")

            if (-not $inFence) {
                if ($fenceOpenRegex.IsMatch($trimmed)) {
                    $inFence = $true
                    $fenceChar = & $fenceCharAt0 $trimmed
                }
            }
            else {
                $first = & $fenceCharAt0 $trimmed
                if ($first -eq $fenceChar -and $fenceOpenRegex.IsMatch($trimmed) -and $trimmed.TrimEnd(' ', "`t") -match '^(```+|~~~+)$') {
                    $inFence = $false
                    $fenceChar = ''
                }
            }

            # --- trailing whitespace (allow exactly one hard-break: two spaces) ---
            if ($line -match '[ \t]+$') {
                $trailing = $Matches[0]
                if ($trailing -ne '  ') {
                    $violations++
                    Write-Host "VIOLATION: ${relFile}:${lineNum}: trailing whitespace"
                }
            }

            # --- blank line run ---
            if ($line -eq '') {
                $blankRun++
                if ($blankRun -eq 2) {
                    $violations++
                    Write-Host "VIOLATION: ${relFile}:${lineNum}: more than one blank line in a row"
                }
            }
            else {
                $blankRun = 0
            }

            # --- heading level jumps (skip while inside a fenced code block) ---
            if (-not $inFence) {
                $hm = $headingRegex.Match($line)
                if ($hm.Success) {
                    $level = $hm.Groups[1].Value.Length
                    if ($prevHeadingLevel -gt 0 -and $level -gt ($prevHeadingLevel + 1)) {
                        $violations++
                        Write-Host "VIOLATION: ${relFile}:${lineNum}: heading level jumps from H${prevHeadingLevel} to H${level} (skipped a level)"
                    }
                    $prevHeadingLevel = $level
                }
            }

            # --- forbidden placeholder strings ---
            foreach ($marker in $forbidden) {
                if ($line.Contains($marker)) {
                    $violations++
                    Write-Host "VIOLATION: ${relFile}:${lineNum}: contains forbidden placeholder marker '$marker'"
                }
            }
        }

        # --- trailing newline hygiene ---
        if ($raw.Length -gt 0) {
            if (-not $endsWithNewline) {
                $violations++
                Write-Host "VIOLATION: ${relFile}: file does not end with a newline"
            }
            elseif ($normalized.EndsWith("`n`n")) {
                $violations++
                Write-Host "VIOLATION: ${relFile}: file ends with blank line(s) (more than one trailing newline)"
            }
        }
    }
}
catch {
    Write-Error "validate-markdown: unexpected error: $($_.Exception.Message)"
    exit 2
}

Write-Host "---"
Write-Host "validate-markdown: checked $filesChecked file(s)."

if ($violations -gt 0) {
    Write-Host "validate-markdown: FAIL - $violations violation(s) found."
    exit 1
}

Write-Host "validate-markdown: PASS - no hygiene violations found."
exit 0
