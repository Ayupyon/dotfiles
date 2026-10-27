#requires -Version 7.0
. "$PSScriptRoot/../scripts/install-common.ps1"

$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
$destination = if ($env:WEZTERM_CONFIG_FILE) { $env:WEZTERM_CONFIG_FILE } else { Join-Path $configRoot 'wezterm/wezterm.lua' }
Install-DotfilesLink "$PSScriptRoot/.wezterm.lua" $destination
