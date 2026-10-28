#requires -Version 7.0
. "$PSScriptRoot/../scripts/uninstall-common.ps1"

Uninstall-DotfilesLink "$PSScriptRoot/pwshconfig.d" (Join-Path $HOME '.config/pwsh/pwshconfig.d')
Uninstall-DotfilesLink "$PSScriptRoot/Microsoft.PowerShell_profile.ps1" $PROFILE.CurrentUserCurrentHost
