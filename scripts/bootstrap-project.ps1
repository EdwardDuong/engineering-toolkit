<#
.SYNOPSIS
    bootstrap-project.ps1 - adopt this toolkit into another (host) project.

.DESCRIPTION
    Copies the toolkit's portable, non-toolkit-specific folders
    (.claude/, docs/, templates/, prompts/, checklists/, scripts/) from
    this repository into a target directory. Any file that already
    exists at the destination is left untouched and reported as
    skipped - this script never overwrites or deletes anything.

.PARAMETER TargetDirectory
    Required. Path to the host project that should receive a copy of
    the toolkit. Created if it does not already exist.

.EXAMPLE
    powershell -File scripts/bootstrap-project.ps1 C:\path\to\host-project
    pwsh scripts/bootstrap-project.ps1 ../host-project

.NOTES
    Exit codes:
      0   Completed (files copied and/or skipped as already present).
      1   Usage error (missing TargetDirectory argument).
      2   Target path invalid, or source/target resolve to the same tree.

    This script only copies and creates files/directories. It never
    deletes or overwrites existing files.
#>

param(
    [string]$TargetDirectory
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
    Write-Host "Usage: bootstrap-project.ps1 <target-directory>"
    Write-Host "  Copies .claude/, docs/, templates/, prompts/, checklists/, and"
    Write-Host "  scripts/ from this toolkit into <target-directory>, without"
    Write-Host "  overwriting any file that already exists there."
    exit 1
}

$sourceRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($sourceRoot)) {
    $sourceRoot = Split-Path -Parent $PSCommandPath | Split-Path -Parent
}

try {
    New-Item -ItemType Directory -Path $TargetDirectory -Force -ErrorAction Stop | Out-Null
    $targetRoot = (Resolve-Path -LiteralPath $TargetDirectory -ErrorAction Stop).ProviderPath.TrimEnd('\', '/')
}
catch {
    Write-Error "bootstrap-project: error: could not create target directory '$TargetDirectory'"
    exit 2
}

$sourceRootNorm = $sourceRoot.TrimEnd('\', '/')

if ($targetRoot -ieq $sourceRootNorm) {
    Write-Error "bootstrap-project: error: target directory is the toolkit's own repo root; refusing to copy onto itself"
    exit 2
}

$folders = @('.claude', 'docs', 'templates', 'prompts', 'checklists', 'scripts')

$copied = 0
$skipped = 0
$foldersFound = 0

Write-Host "bootstrap-project: copying toolkit folders from '$sourceRootNorm' into '$targetRoot' ..."

try {
    foreach ($folder in $folders) {
        $src = Join-Path $sourceRootNorm $folder
        if (-not (Test-Path -LiteralPath $src -PathType Container)) { continue }
        $foldersFound++

        $srcFiles = Get-ChildItem -LiteralPath $src -Recurse -File -ErrorAction Stop
        foreach ($srcFile in $srcFiles) {
            $relPath = $srcFile.FullName.Substring($src.Length).TrimStart('\', '/')
            $destFile = Join-Path (Join-Path $targetRoot $folder) $relPath
            $destDir = Split-Path -Parent $destFile

            if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }

            if (Test-Path -LiteralPath $destFile) {
                $skipped++
                Write-Host "SKIP (already exists): $folder\$relPath"
            }
            else {
                Copy-Item -LiteralPath $srcFile.FullName -Destination $destFile
                $copied++
                Write-Host "COPY: $folder\$relPath"
            }
        }
    }
}
catch {
    Write-Error "bootstrap-project: unexpected error: $($_.Exception.Message)"
    exit 2
}

Write-Host "---"

if ($foldersFound -eq 0) {
    Write-Error "bootstrap-project: error: none of the expected toolkit folders were found under '$sourceRootNorm'"
    exit 2
}

Write-Host "bootstrap-project: done. $copied file(s) copied, $skipped file(s) skipped (already present)."
Write-Host "bootstrap-project: no existing files in '$targetRoot' were modified or removed."
exit 0
