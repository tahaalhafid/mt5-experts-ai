param(
    [switch]$WhatIfOnly
)

$ErrorActionPreference = "Stop"

function Normalize-GitPath {
    param([string]$Path)
    return ($Path -replace "\\", "/").Trim()
}

function Test-ForbiddenPath {
    param([string]$Path)
    $p = Normalize-GitPath $Path
    $name = [System.IO.Path]::GetFileName($p)
    $ext = [System.IO.Path]::GetExtension($p).ToLowerInvariant()

    if($ext -in @(".mq5", ".mqh", ".ex5", ".log", ".zip", ".json", ".jsonl")) { return $true }
    if($name -like "*.bak_*") { return $true }
    if($p -match "(^|/)MQL5/Files/AI(/|$)") { return $true }
    if($p -match "(^|/)Files/AI(/|$)") { return $true }
    return $false
}

function Test-DocsPath {
    param([string]$Path)
    $p = Normalize-GitPath $Path
    $name = [System.IO.Path]::GetFileName($p)
    $ext = [System.IO.Path]::GetExtension($p).ToLowerInvariant()

    if(Test-ForbiddenPath $p) { return $false }
    if($ext -eq ".md") { return $true }
    if($name -in @("AGENTS.md", "OPERATION_GUARDRAILS.md", "CLAUDE.md", "README.md")) { return $true }
    return $false
}

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if([string]::IsNullOrWhiteSpace($repoRoot)) {
    throw "Not inside a Git repository."
}
Set-Location -LiteralPath $repoRoot

$preStaged = @(& git diff --cached --name-only --diff-filter=ACMRTD)
$preStagedForbidden = @($preStaged | Where-Object { -not (Test-DocsPath $_) })
if($preStagedForbidden.Count -gt 0) {
    Write-Error ("Refusing docs checkpoint because non-doc files are already staged:`n" + ($preStagedForbidden -join "`n"))
    exit 2
}

$changed = @(& git diff --name-only --diff-filter=ACMRTD)
$untracked = @(& git ls-files --others --exclude-standard)
$candidates = @($changed + $untracked | ForEach-Object { Normalize-GitPath $_ } | Sort-Object -Unique)
$docsCandidates = @($candidates | Where-Object { Test-DocsPath $_ })

if($docsCandidates.Count -eq 0 -and $preStaged.Count -eq 0) {
    Write-Output "No docs changes to checkpoint"
    exit 0
}

if($docsCandidates.Count -gt 0) {
    if($WhatIfOnly) {
        Write-Output "Docs changes that would be staged:"
        $docsCandidates | ForEach-Object { Write-Output $_ }
        exit 0
    }
    & git add -- $docsCandidates
    if($LASTEXITCODE -ne 0) {
        throw "git add failed for docs checkpoint candidates."
    }
}

$staged = @(& git diff --cached --name-only --diff-filter=ACMRTD)
$stagedForbidden = @($staged | Where-Object { -not (Test-DocsPath $_) })
if($stagedForbidden.Count -gt 0) {
    Write-Error ("Refusing docs checkpoint because non-doc files are staged after docs add:`n" + ($stagedForbidden -join "`n"))
    exit 3
}

if($staged.Count -eq 0) {
    Write-Output "No docs changes to checkpoint"
    exit 0
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
& git commit -m "docs: archive markdown checkpoint $timestamp"
if($LASTEXITCODE -ne 0) {
    throw "git commit failed for docs checkpoint."
}
