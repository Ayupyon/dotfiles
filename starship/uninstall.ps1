#requires -Version 7.0
. "$PSScriptRoot/../scripts/uninstall-common.ps1"

$destination = if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { Join-Path $HOME '.config/starship.toml' }
Uninstall-DotfilesLink "$PSScriptRoot/starship.toml" $destination
