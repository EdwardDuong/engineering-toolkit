<#
.SYNOPSIS
    validate-links.ps1 - check that every relative Markdown link in the
    repo points at a file (or directory) that actually exists.

.DESCRIPTION
    Walks every *.md file in the target tree (skipping .git/), extracts
    inline Markdown links of the form [text](path) and image links of
    the form ![alt](path), ignores links with a URI scheme (http://,
    https://, mailto:, etc.) and anchor-only links (#section), resolves
    the remaining relative paths against the directory of the file that
    contains them (or against the repo root if the link starts with
    "/"), and reports any link whose target does not exist on disk.
    Text inside fenced code blocks (``` or ~~~) and inline code spans
    (`...`) is ignored, since Markdown link syntax shown there as an
    example is literal text, not a real link.

.PARAMETER Path
    Optional. Directory to scan. Defaults to the current directory.

.EXAMPLE
    powershell -File scripts/validate-links.ps1
    pwsh scripts/validate-links.ps1 C:\path\to\repo

.NOTES
    Exit codes:
      0   No broken links found.
      1   One or more broken links found (printed as file:line: link).
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
        Write-Error "validate-links: error: '$Path' is not a directory"
        exit 2
    }
    $rootAbs = $rootItem.FullName.TrimEnd('\', '/')
}
catch {
    Write-Error "validate-links: error: '$Path' is not a directory"
    exit 2
}

Write-Host "validate-links: scanning Markdown files under '$rootAbs' ..."

$linkRegex = [regex]'\[[^\[\]]*\]\(([^()\s]+)\)'
$schemeRegex = [regex]'^[A-Za-z][A-Za-z0-9+.\-]*:'
$fenceOpenRegex = [regex]'^(```+|~~~+)'
$codeSpanRegex = [regex]'`[^`]+`'

$broken = 0
$checked = 0

try {
    $mdFiles = Get-ChildItem -LiteralPath $rootAbs -Recurse -File -Filter '*.md' -ErrorAction Stop |
        Where-Object { $_.FullName -notmatch '(^|[\\/])\.git([\\/]|$)' } |
        Sort-Object FullName

    foreach ($file in $mdFiles) {
        $dir = Split-Path -Parent $file.FullName
        $relFile = $file.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
        $lines = Get-Content -LiteralPath $file.FullName -ErrorAction Stop

        $inFence = $false
        $fenceChar = ''

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $lineNum = $i + 1
            $line = $lines[$i]
            $trimmed = $line.TrimStart(' ', "`t")

            # --- fenced code block tracking; skip link scanning while
            # inside one, since example syntax there is literal text. ---
            if (-not $inFence) {
                if ($fenceOpenRegex.IsMatch($trimmed)) {
                    $inFence = $true
                    $fenceChar = $trimmed.Substring(0, 1)
                    continue
                }
            }
            else {
                $first = if ($trimmed.Length -gt 0) { $trimmed.Substring(0, 1) } else { '' }
                if ($first -eq $fenceChar -and $fenceOpenRegex.IsMatch($trimmed) -and $trimmed.TrimEnd(' ', "`t") -match '^(```+|~~~+)$') {
                    $inFence = $false
                    $fenceChar = ''
                }
                continue
            }

            # Mask inline code spans (`...`) so link-like syntax shown as
            # a literal example (e.g. the text `[text](path)`) is not
            # treated as a real link.
            $lineForLinks = $codeSpanRegex.Replace($line, { param($m) '_' * $m.Value.Length })

            foreach ($match in $linkRegex.Matches($lineForLinks)) {
                $link = $match.Groups[1].Value

                # Ignore links with a URI scheme (http:, https:, mailto:, etc.).
                if ($schemeRegex.IsMatch($link)) { continue }

                # Ignore anchor-only links (#some-section).
                if ($link.StartsWith('#')) { continue }

                # Strip a trailing #anchor or ?query fragment, if present.
                $targetPath = $link -replace '#.*$', '' -replace '\?.*$', ''

                # Basic percent-decoding for the common "%20" (space) case.
                $targetPath = $targetPath -replace '%20', ' '

                if ([string]::IsNullOrEmpty($targetPath)) { continue }

                $checked++

                if ($targetPath.StartsWith('/')) {
                    $joined = Join-Path $rootAbs $targetPath.TrimStart('/')
                }
                else {
                    $joined = Join-Path $dir $targetPath
                }
                $resolved = [System.IO.Path]::GetFullPath($joined)

                if (-not (Test-Path -LiteralPath $resolved)) {
                    $broken++
                    Write-Host "BROKEN: ${relFile}:${lineNum}: [$link] -> $resolved"
                }
            }
        }
    }
}
catch {
    Write-Error "validate-links: unexpected error: $($_.Exception.Message)"
    exit 2
}

Write-Host "---"
Write-Host "validate-links: checked $checked link(s)."

if ($broken -gt 0) {
    Write-Host "validate-links: FAIL - $broken broken link(s) found."
    exit 1
}

Write-Host "validate-links: PASS - no broken links found."
exit 0
