#requires -Version 7.0
. "$PSScriptRoot/../scripts/install-common.ps1"

$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { $env:APPDATA }
if (-not $configRoot) { throw 'APPDATA is not set.' }
$destination = if ($env:HERDR_CONFIG_PATH) { $env:HERDR_CONFIG_PATH } else { Join-Path $configRoot 'herdr/config.toml' }
Install-DotfilesLink "$PSScriptRoot/config.toml" $destination
