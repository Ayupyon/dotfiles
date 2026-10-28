#requires -Version 7.0
# Run on Windows: pwsh -NoProfile -File ./tests/uninstall.ps1
param([switch] $PlanOnly)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../scripts/uninstall-common.ps1"

function Assert-True($Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

function Assert-Absent([string] $Path) {
    Assert-True (-not (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue)) "Entry remains: $Path"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-uninstall-$([guid]::NewGuid().ToString('N'))"
[IO.Directory]::CreateDirectory($testRoot) | Out-Null
$originalHome = $HOME
$originalProfile = $PROFILE
$environmentNames = @('APPDATA', 'XDG_CONFIG_HOME', 'HERDR_CONFIG_PATH', 'STARSHIP_CONFIG', 'WEZTERM_CONFIG_FILE', 'CODEX_HOME')
$originalEnvironment = @{}
foreach ($name in $environmentNames) { $originalEnvironment[$name] = [Environment]::GetEnvironmentVariable($name) }

try {
    foreach ($file in (Get-ChildItem -LiteralPath $repoRoot -Recurse -Filter '*.ps1' | Where-Object { $_.FullName -notmatch '[\\/]tests[\\/]tmp-' })) {
        $parseErrors = $null
        [void][Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$parseErrors)
        Assert-True (-not $parseErrors) "Parse error: $($file.FullName): $parseErrors"
    }

    $fixtureRepo = Join-Path $testRoot 'repository with spaces'
    [IO.Directory]::CreateDirectory((Join-Path $fixtureRepo 'scripts')) | Out-Null
    foreach ($app in @('herdr', 'pwsh', 'starship', 'wezterm', 'code_agent')) {
        Copy-Item -LiteralPath (Join-Path $repoRoot $app) -Destination $fixtureRepo -Recurse
    }
    Copy-Item -LiteralPath (Join-Path $repoRoot 'install.ps1'), (Join-Path $repoRoot 'uninstall.ps1') -Destination $fixtureRepo
    Copy-Item -LiteralPath (Join-Path $repoRoot 'scripts/install-common.ps1') -Destination (Join-Path $fixtureRepo 'scripts')

    # Override only test-process destinations, including the read-only HOME variable.
    Set-Variable -Name HOME -Value (Join-Path $testRoot 'home') -Force -Scope Script
    $PROFILE = [pscustomobject]@{ CurrentUserCurrentHost = (Join-Path $HOME 'redirected Documents/profile.ps1') }
    foreach ($name in $environmentNames) { [Environment]::SetEnvironmentVariable($name, $null) }
    $env:APPDATA = Join-Path $HOME 'AppData/Roaming'

    $plan = [Collections.Generic.List[object]]::new()
    Set-Content -LiteralPath (Join-Path $fixtureRepo 'scripts/uninstall-common.ps1') -Value @'
$ErrorActionPreference = 'Stop'
function Uninstall-DotfilesLink($Source, $Destination) {
    $plan.Add(@{ Source = [IO.Path]::GetFullPath($Source); Destination = $Destination })
    if ($simulateFailure -and $Source -match '[\\/]herdr[\\/]') { throw 'Simulated failure' }
}
'@
    Push-Location $testRoot
    try { & (Join-Path $fixtureRepo 'uninstall.ps1') } finally { Pop-Location }
    Assert-True ($plan.Count -eq 6) 'Unexpected Windows uninstallation plan'
    Assert-True ($plan[0].Destination -eq (Join-Path $env:APPDATA 'herdr/config.toml')) 'Wrong herdr destination'
    Assert-True ($plan[1].Destination -eq (Join-Path $HOME '.config/pwsh/pwshconfig.d')) 'Wrong pwsh module destination'
    Assert-True ($plan[2].Destination -eq $PROFILE.CurrentUserCurrentHost) 'Wrong pwsh profile destination'
    Assert-True ($plan[3].Destination -eq (Join-Path $HOME '.config/starship.toml')) 'Wrong starship destination'
    Assert-True ($plan[4].Destination -eq (Join-Path $HOME '.config/wezterm/wezterm.lua')) 'Wrong wezterm destination'
    Assert-True ($plan[5].Destination -eq (Join-Path $HOME '.codex/AGENTS.md')) 'Wrong Codex destination'

    $plan.Clear()
    $script:simulateFailure = $true
    $failed = $false
    try { & (Join-Path $fixtureRepo 'uninstall.ps1') } catch { $failed = $true }
    $script:simulateFailure = $false
    Assert-True $failed 'Global uninstaller did not report failure'
    Assert-True ($plan.Count -eq 6) 'Global uninstaller stopped after failure'
    Write-Host 'PowerShell parsing, destination, and failure checks passed.'
    if ($PlanOnly) { return }

    Copy-Item -LiteralPath (Join-Path $repoRoot 'scripts/uninstall-common.ps1') -Destination (Join-Path $fixtureRepo 'scripts/uninstall-common.ps1') -Force
    $source = Join-Path $testRoot 'source file'
    $target = Join-Path $testRoot 'target file'
    Set-Content -LiteralPath $source -Value 'repository'
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Uninstall-DotfilesLink $source $target
    Assert-Absent $target
    Uninstall-DotfilesLink $source $target
    Assert-True ((Get-Content -LiteralPath $source) -eq 'repository') 'Source file changed'

    Set-Content -LiteralPath $target -Value 'original'
    Uninstall-DotfilesLink $source $target
    Assert-True ((Get-Content -LiteralPath $target) -eq 'original') 'Regular file changed'
    $directory = Join-Path $testRoot 'regular directory'
    [IO.Directory]::CreateDirectory($directory) | Out-Null
    Uninstall-DotfilesLink $source $directory
    Assert-True (Test-Path -LiteralPath $directory -PathType Container) 'Regular directory removed'

    $unrelated = Join-Path $testRoot 'unrelated link'
    New-Item -ItemType SymbolicLink -Path $unrelated -Target $source | Out-Null
    Uninstall-DotfilesLink (Join-Path $testRoot 'another source') $unrelated
    Assert-True ((Get-Item -LiteralPath $unrelated -Force).LinkType -eq 'SymbolicLink') 'Unrelated link removed'
    $missing = Join-Path $testRoot 'missing source'
    $broken = Join-Path $testRoot 'broken link'
    New-Item -ItemType SymbolicLink -Path $broken -Target $missing | Out-Null
    Uninstall-DotfilesLink $source $broken
    Assert-True ((Get-Item -LiteralPath $broken -Force).LinkType -eq 'SymbolicLink') 'Unrelated broken link removed'
    Uninstall-DotfilesLink $missing $broken
    Assert-Absent $broken

    $relative = Join-Path $testRoot 'relative link'
    New-Item -ItemType SymbolicLink -Path $relative -Target 'source file' | Out-Null
    Uninstall-DotfilesLink $source $relative
    Assert-Absent $relative
    $directorySource = Join-Path $testRoot 'source directory'
    $directoryTarget = Join-Path $testRoot 'directory link'
    [IO.Directory]::CreateDirectory($directorySource) | Out-Null
    Set-Content -LiteralPath (Join-Path $directorySource '.hidden') -Value 'keep'
    New-Item -ItemType SymbolicLink -Path $directoryTarget -Target $directorySource | Out-Null
    Uninstall-DotfilesLink $directorySource $directoryTarget
    Assert-Absent $directoryTarget
    Assert-True ((Get-Content -LiteralPath (Join-Path $directorySource '.hidden')) -eq 'keep') 'Directory source contents changed'

    foreach ($caseName in @('default', 'xdg', 'overrides')) {
        Set-Variable -Name HOME -Value (Join-Path $testRoot "$caseName/home") -Force -Scope Script
        $PROFILE = [pscustomobject]@{ CurrentUserCurrentHost = (Join-Path $HOME 'redirected Documents/profile.ps1') }
        foreach ($name in $environmentNames) { [Environment]::SetEnvironmentVariable($name, $null) }
        $env:APPDATA = Join-Path $HOME 'AppData/Roaming'
        if ($caseName -ne 'default') { $env:XDG_CONFIG_HOME = Join-Path $HOME 'config with spaces' }
        if ($caseName -eq 'overrides') {
            $env:HERDR_CONFIG_PATH = Join-Path $HOME 'custom/herdr.toml'
            $env:STARSHIP_CONFIG = Join-Path $HOME 'custom/starship.toml'
            $env:WEZTERM_CONFIG_FILE = Join-Path $HOME 'custom/wezterm.lua'
            $env:CODEX_HOME = Join-Path $HOME 'codex directory'
        }
        Push-Location $testRoot
        try { & (Join-Path $fixtureRepo 'install.ps1') } finally { Pop-Location }
        $installedLinks = @(Get-ChildItem -LiteralPath $HOME -Recurse -Force | Where-Object { $_.LinkType -eq 'SymbolicLink' } | ForEach-Object { $_.FullName })
        Assert-True ($installedLinks.Count -gt 0) 'No configuration links installed'
        $skillsRoot = Join-Path $HOME '.agents/skills'
        Set-Content -LiteralPath (Join-Path $skillsRoot 'personal') -Value 'personal'
        $unrelatedSkill = Join-Path $skillsRoot 'unrelated'
        New-Item -ItemType SymbolicLink -Path $unrelatedSkill -Target $source | Out-Null
        $removedSkill = Join-Path $skillsRoot 'removed'
        New-Item -ItemType SymbolicLink -Path $removedSkill -Target (Join-Path $fixtureRepo 'code_agent/skills/removed') | Out-Null
        $backup = "$($PROFILE.CurrentUserCurrentHost).dotfiles-backup-test"
        Set-Content -LiteralPath $backup -Value 'backup'

        & (Join-Path $fixtureRepo 'uninstall.ps1')
        foreach ($installedLink in $installedLinks) { Assert-Absent $installedLink }
        Assert-Absent $removedSkill
        Assert-True ((Get-Content -LiteralPath $backup) -eq 'backup') 'Backup changed'
        Assert-True ((Get-Content -LiteralPath (Join-Path $skillsRoot 'personal')) -eq 'personal') 'Personal skill changed'
        Assert-True ((Get-Item -LiteralPath $unrelatedSkill -Force).LinkType -eq 'SymbolicLink') 'Unrelated skill link removed'
        & (Join-Path $fixtureRepo 'uninstall.ps1')
        Assert-True (Test-Path -LiteralPath (Join-Path $fixtureRepo 'pwsh/Microsoft.PowerShell_profile.ps1')) 'Repository source removed'
    }
    Write-Host 'PowerShell uninstaller checks passed.'
}
finally {
    Set-Variable -Name HOME -Value $originalHome -Force -Scope Script
    $PROFILE = $originalProfile
    foreach ($name in $environmentNames) { [Environment]::SetEnvironmentVariable($name, $originalEnvironment[$name]) }
    # Leave fixtures available for inspection without recursively deleting links.
    Write-Host "Test fixtures: $testRoot"
}
