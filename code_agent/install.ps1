#requires -Version 7.0
. "$PSScriptRoot/../scripts/install-common.ps1"

$codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
Install-DotfilesLink "$PSScriptRoot/AGENTS.md" (Join-Path $codexRoot 'AGENTS.md')

$skillsRoot = Join-Path $HOME '.agents/skills'
foreach ($skillDirectory in (Get-ChildItem -LiteralPath "$PSScriptRoot/skills" -Directory -Force | Sort-Object Name)) {
    if (Test-Path -LiteralPath (Join-Path $skillDirectory.FullName 'SKILL.md') -PathType Leaf) {
        Install-DotfilesLink $skillDirectory.FullName (Join-Path $skillsRoot $skillDirectory.Name)
    }
}
