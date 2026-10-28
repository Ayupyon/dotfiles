#requires -Version 7.0
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) {
    throw 'Use the .sh uninstallers on Linux and macOS.'
}

function Uninstall-DotfilesLink {
    param(
        [Parameter(Mandatory)][string] $Source,
        [Parameter(Mandatory)][string] $Destination
    )

    $Source = [IO.Path]::GetFullPath($Source)
    $Destination = [IO.Path]::GetFullPath($Destination)
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
        $linkTarget = $existing.Target
        if (-not [IO.Path]::IsPathRooted($linkTarget)) {
            $linkTarget = Join-Path (Split-Path -Parent $Destination) $linkTarget
        }
        # Do not resolve the source: broken managed links can still be removed.
        if ([IO.Path]::GetFullPath($linkTarget) -eq $Source) {
            Remove-Item -LiteralPath $Destination -Force
            Write-Host "Unlinked: $Destination"
            return
        }
    }

    Write-Host "Skipped (not a managed link): $Destination"
}
