#requires -Version 7.0
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) {
    throw 'Use the .sh installers on Linux and macOS.'
}

function Install-DotfilesLink {
    param(
        [Parameter(Mandatory)][string] $Source,
        [Parameter(Mandatory)][string] $Destination
    )

    $sourceItem = Get-Item -LiteralPath $Source -Force
    $Source = $sourceItem.FullName
    $Destination = [IO.Path]::GetFullPath($Destination)
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
        $linkTarget = $existing.Target
        if (-not [IO.Path]::IsPathRooted($linkTarget)) {
            $linkTarget = Join-Path (Split-Path -Parent $Destination) $linkTarget
        }
        if ([IO.Path]::GetFullPath($linkTarget) -eq $Source) {
            Write-Host "Already linked: $Destination"
            return
        }
    }

    $backup = $null
    if ($existing) {
        $answer = Read-Host "Replace $Destination with a link to ${Source}? [y/N]"
        if ($answer -notmatch '^(?i:y|yes)$') {
            Write-Host "Skipped: $Destination"
            return
        }
        $backup = "$Destination.dotfiles-backup-$(Get-Date -Format yyyyMMddHHmmss)-$([guid]::NewGuid().ToString('N'))"
        Rename-Item -LiteralPath $Destination -NewName (Split-Path -Leaf $backup)
        Write-Host "Backup: $backup"
    }

    try {
        $parent = Split-Path -Parent $Destination
        [IO.Directory]::CreateDirectory($parent) | Out-Null
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
        Write-Host "Linked: $Destination -> $Source"
    }
    catch {
        if ($backup) {
            Move-Item -LiteralPath $backup -Destination $Destination
        }
        throw "Failed to link $Destination. Enable Windows Developer Mode or run pwsh as administrator. $($_.Exception.Message)"
    }
}
