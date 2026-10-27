#requires -Version 7.0
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Use install.sh on Linux and macOS.' }

$failed = @()
foreach ($app in @('herdr', 'pwsh', 'starship', 'wezterm', 'code_agent')) {
    Write-Host "`nInstalling $app configuration..."
    try {
        & "$PSScriptRoot/$app/install.ps1"
    }
    catch {
        Write-Warning "${app}: $($_.Exception.Message)"
        $failed += $app
    }
}
if ($failed.Count) {
    throw "Installation failed for: $($failed -join ', ')"
}
