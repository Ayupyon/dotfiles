#requires -Version 7.0
. "$PSScriptRoot/../scripts/install-common.ps1"

Install-DotfilesLink "$PSScriptRoot/pwshconfig.d" (Join-Path $HOME '.config/pwsh/pwshconfig.d')
# Resolve Documents redirection (including OneDrive) through the actual profile path.
Install-DotfilesLink "$PSScriptRoot/Microsoft.PowerShell_profile.ps1" $PROFILE.CurrentUserCurrentHost
