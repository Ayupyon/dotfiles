#requires -Version 7.0
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Use uninstall.sh on Linux and macOS.' }

$failed = @()
foreach ($app in @('herdr', 'pwsh', 'starship', 'wezterm', 'code_agent')) {
    Write-Host "`nUninstalling $app configuration..."
    try {
        & "$PSScriptRoot/$app/uninstall.ps1"
    }
    catch {
        Write-Warning "${app}: $($_.Exception.Message)"
        $failed += $app
    }
}
if ($failed.Count) {
    throw "Uninstallation failed for: $($failed -join ', ')"
}
