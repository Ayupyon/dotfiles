#requires -Version 7.0
. "$PSScriptRoot/../scripts/uninstall-common.ps1"

$codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
Uninstall-DotfilesLink "$PSScriptRoot/AGENTS.md" (Join-Path $codexRoot 'AGENTS.md')

# Inspect installed entries so removed repository skills can also be unlinked.
$skillsRoot = Join-Path $HOME '.agents/skills'
if (Test-Path -LiteralPath $skillsRoot -PathType Container) {
    foreach ($skillLink in (Get-ChildItem -LiteralPath $skillsRoot -Force | Sort-Object Name)) {
        if ($skillLink.LinkType -eq 'SymbolicLink') {
            Uninstall-DotfilesLink (Join-Path "$PSScriptRoot/skills" $skillLink.Name) $skillLink.FullName
        }
    }
}
