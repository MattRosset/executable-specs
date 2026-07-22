# Mirrors executable-specs/skills/* into ~/.claude/skills/.
#
# THIS IS NOT THE INSTALL PATH. To use these skills, install the plugin:
#   /plugin marketplace add MattRosset/executable-specs
#   /plugin install executable-specs
#
# This script is the author-side mirror, for editing a skill in this repo and
# picking it up locally without a reinstall. It OVERWRITES any same-named skill
# directory under ~/.claude/skills/ — and names like "research" or "run" collide
# easily — so it asks before replacing one. Pass -Force to skip the prompt.

param([switch]$Force)

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "skills"
$dest = Join-Path $HOME ".claude\skills"

if (-not (Test-Path $source)) {
    throw "Source directory not found: $source"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null

$synced = @()
$skipped = @()

Get-ChildItem -Path $source -Directory | ForEach-Object {
    $skillName = $_.Name
    $destSkillPath = Join-Path $dest $skillName

    if ((Test-Path $destSkillPath) -and (-not $Force)) {
        # Only prompt for a directory this repo did not put there.
        $marker = Join-Path $destSkillPath ".synced-from-executable-specs"
        if (-not (Test-Path $marker)) {
            Write-Warning "~/.claude/skills/$skillName already exists and was not created by this script."
            Write-Host "  Overwriting would delete it. Skipping. Re-run with -Force to replace it." -ForegroundColor Yellow
            $skipped += $skillName
            return
        }
    }

    Write-Host "Syncing $skillName..."
    if (Test-Path $destSkillPath) {
        Remove-Item -Path $destSkillPath -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $destSkillPath -Recurse -Force
    New-Item -ItemType File -Path (Join-Path $destSkillPath ".synced-from-executable-specs") -Force | Out-Null
    $synced += $skillName
}

if ($synced.Count -gt 0) { Write-Host "Synced: $($synced -join ', ')" }
if ($skipped.Count -gt 0) {
    Write-Host "Skipped (pre-existing, not ours): $($skipped -join ', ')" -ForegroundColor Yellow
    Write-Host "Nothing was deleted." -ForegroundColor Yellow
}
