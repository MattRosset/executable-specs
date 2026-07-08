# Mirrors executable-specs/skills/* into ~/.claude/skills/.
#
# Run this after editing any skill in this repo (or after `git pull`) so the
# local Claude Code install picks up the change. There is no plugin/symlink
# mechanism today — this script is the sync until one exists (see PROPAGATION.md).

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "skills"
$dest = Join-Path $HOME ".claude\skills"

if (-not (Test-Path $source)) {
    throw "Source directory not found: $source"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null

Get-ChildItem -Path $source -Directory | ForEach-Object {
    $skillName = $_.Name
    $destSkillPath = Join-Path $dest $skillName
    Write-Host "Syncing $skillName..."
    if (Test-Path $destSkillPath) {
        Remove-Item -Path $destSkillPath -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $destSkillPath -Recurse -Force
}

Write-Host "Done. Synced skills: $((Get-ChildItem -Path $source -Directory).Name -join ', ')"
