<#
.SYNOPSIS
    repository-audit.ps1 - informational repository health report.

.DESCRIPTION
      - Counts files per top-level folder.
      - Flags empty directories.
      - Flags Markdown files under a rough minimum size (default: fewer
        than 5 lines), which are likely stubs.
      - Flags file names containing spaces.
      - Flags file names whose casing could collide on a
        case-insensitive filesystem (Windows/macOS) but not on a
        case-sensitive one (Linux/git), e.g. "Readme.md" next to
        "README.md" in the same directory, plus files with an
        uppercase extension (e.g. "FOO.MD").

    This is a report, not a gate: it always exits 0. Read the output to
    see whether anything needs attention.

.PARAMETER Path
    Optional. Directory to audit. Defaults to the current directory.

.EXAMPLE
    powershell -File scripts/repository-audit.ps1
    pwsh scripts/repository-audit.ps1 C:\path\to\repo

.NOTES
    Exit codes:
      0   Always, on a normal run (this tool is informational).
      2   Usage error (bad or missing path argument).

    This script is read-only: it never modifies or deletes any file.
#>

param(
    [string]$Path = "."
)

$ErrorActionPreference = 'Stop'
$MinMdLines = 5

try {
    $rootItem = Get-Item -LiteralPath $Path -ErrorAction Stop
    if (-not $rootItem.PSIsContainer) {
        Write-Error "repository-audit: error: '$Path' is not a directory"
        exit 2
    }
    $rootAbs = $rootItem.FullName.TrimEnd('\', '/')
}
catch {
    Write-Error "repository-audit: error: '$Path' is not a directory"
    exit 2
}

Write-Host "repository-audit: health report for '$rootAbs'"
Write-Host "================================================================"

$issues = 0

function Test-UnderGit([string]$FullName, [string]$RootAbs) {
    $rel = $FullName.Substring($RootAbs.Length).TrimStart('\', '/')
    return ($rel -eq '.git' -or $rel.StartsWith('.git\') -or $rel.StartsWith('.git/'))
}

# --- 1. File counts per top-level folder ---
Write-Host ""
Write-Host "Files per top-level folder:"
Write-Host ("  {0,-24} {1,8}" -f "FOLDER", "FILES")
Write-Host ("  {0,-24} {1,8}" -f "------", "-----")

$topTotal = 0
$topDirs = Get-ChildItem -LiteralPath $rootAbs -Directory -Force | Where-Object { $_.Name -ne '.git' } | Sort-Object Name
foreach ($d in $topDirs) {
    $count = (Get-ChildItem -LiteralPath $d.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { -not (Test-UnderGit $_.FullName $rootAbs) }).Count
    Write-Host ("  {0,-24} {1,8}" -f "$($d.Name)\", $count)
    $topTotal += $count
}

$rootFiles = (Get-ChildItem -LiteralPath $rootAbs -File -Force).Count
Write-Host ("  {0,-24} {1,8}" -f "(root files)", $rootFiles)
Write-Host "  --------------------------------"
Write-Host "  Total tracked files (excl. .git): $($topTotal + $rootFiles)"

# --- 2. Empty directories ---
Write-Host ""
Write-Host "Empty directories:"
$emptyCount = 0
$allDirs = Get-ChildItem -LiteralPath $rootAbs -Recurse -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-UnderGit $_.FullName $rootAbs) }
foreach ($d in $allDirs) {
    $hasChildren = (Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0
    if (-not $hasChildren) {
        $rel = $d.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
        Write-Host "  EMPTY: $rel\"
        $emptyCount++
        $issues++
    }
}
if ($emptyCount -eq 0) { Write-Host "  none found" }

# --- 3. Undersized Markdown files (likely stubs) ---
Write-Host ""
Write-Host "Markdown files with fewer than $MinMdLines lines (likely stubs):"
$stubCount = 0
$mdFiles = Get-ChildItem -LiteralPath $rootAbs -Recurse -File -Filter '*.md' -Force -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-UnderGit $_.FullName $rootAbs) }
foreach ($f in $mdFiles) {
    $lineCount = (Get-Content -LiteralPath $f.FullName | Measure-Object -Line).Lines
    if ($lineCount -lt $MinMdLines) {
        $rel = $f.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
        Write-Host "  STUB ($lineCount lines): $rel"
        $stubCount++
        $issues++
    }
}
if ($stubCount -eq 0) { Write-Host "  none found" }

# --- 4. File names containing spaces ---
Write-Host ""
Write-Host "File names containing spaces:"
$spaceCount = 0
$allFiles = Get-ChildItem -LiteralPath $rootAbs -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-UnderGit $_.FullName $rootAbs) }
foreach ($f in $allFiles) {
    if ($f.Name -match ' ') {
        $rel = $f.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
        Write-Host "  SPACE IN NAME: $rel"
        $spaceCount++
        $issues++
    }
}
if ($spaceCount -eq 0) { Write-Host "  none found" }

# --- 5. Casing issues: same-name collisions (case-insensitive) and
#        uppercase file extensions ---
Write-Host ""
Write-Host "File name casing issues:"
$casingCount = 0

$allDirsWithRoot = @($rootItem) + $allDirs
foreach ($d in $allDirsWithRoot) {
    $childFiles = Get-ChildItem -LiteralPath $d.FullName -File -Force -ErrorAction SilentlyContinue
    $seen = @{}
    foreach ($f in $childFiles) {
        $lower = $f.Name.ToLowerInvariant()
        if ($seen.ContainsKey($lower)) {
            $rel = $d.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
            if ([string]::IsNullOrEmpty($rel)) { $rel = '.' }
            Write-Host "  CASE COLLISION in ${rel}: '$($seen[$lower])' vs '$($f.Name)' differ only by case"
            $casingCount++
            $issues++
        }
        else {
            $seen[$lower] = $f.Name
        }
    }
}

foreach ($f in $allFiles) {
    $ext = $f.Extension
    if ($ext.Length -gt 1 -and $ext -cmatch '[A-Z]') {
        $rel = $f.FullName.Substring($rootAbs.Length).TrimStart('\', '/')
        Write-Host "  UPPERCASE EXTENSION: $rel"
        $casingCount++
        $issues++
    }
}

if ($casingCount -eq 0) { Write-Host "  none found" }

# --- Summary ---
Write-Host ""
Write-Host "================================================================"
if ($issues -eq 0) {
    Write-Host "repository-audit: no issues found."
}
else {
    Write-Host "repository-audit: $issues issue(s) flagged above. This report is informational only."
}

exit 0
