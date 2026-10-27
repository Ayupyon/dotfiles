#requires -Version 7.0
# Run on Windows: pwsh -NoProfile -File ./tests/install.ps1
param([switch] $PlanOnly)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../scripts/install-common.ps1"

function Assert-True($Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

$testRoot = Join-Path $PSScriptRoot "tmp-$([guid]::NewGuid().ToString('N'))"
[IO.Directory]::CreateDirectory($testRoot) | Out-Null
try {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    foreach ($file in (Get-ChildItem -LiteralPath $repoRoot -Recurse -Filter '*.ps1' | Where-Object { $_.FullName -notmatch '[\\/]tests[\\/]tmp-' })) {
        $parseErrors = $null
        [void][Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$parseErrors)
        Assert-True (-not $parseErrors) "Parse error: $($file.FullName): $parseErrors"
    }

    # Capture every destination without writing to actual user configuration paths.
    $fixtureRepo = Join-Path $testRoot 'repository with spaces'
    [IO.Directory]::CreateDirectory((Join-Path $fixtureRepo 'scripts')) | Out-Null
    $plan = [Collections.Generic.List[object]]::new()
    foreach ($app in @('herdr', 'pwsh', 'starship', 'wezterm', 'code_agent')) {
        Copy-Item -LiteralPath (Join-Path $repoRoot $app) -Destination $fixtureRepo -Recurse
    }
    Copy-Item -LiteralPath (Join-Path $repoRoot 'install.ps1') -Destination $fixtureRepo
    Set-Content -LiteralPath (Join-Path $fixtureRepo 'scripts/install-common.ps1') -Value @'
function Install-DotfilesLink($Source, $Destination) {
    if (-not (Test-Path -LiteralPath $Source)) { throw "Missing source: $Source" }
    $plan.Add(@{ Source = [IO.Path]::GetFullPath($Source); Destination = $Destination })
}
'@
    Push-Location $testRoot
    try { & (Join-Path $fixtureRepo 'install.ps1') } finally { Pop-Location }
    $skillDirectories = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'code_agent/skills') -Directory -Force | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf
    })
    Assert-True ($plan.Count -eq (6 + $skillDirectories.Count)) 'Unexpected Windows installation plan'
    Assert-True ($plan[1].Destination -eq (Join-Path $HOME '.config/pwsh/pwshconfig.d')) 'Wrong pwsh module path'
    Assert-True ($plan[2].Destination -eq $PROFILE.CurrentUserCurrentHost) 'Wrong pwsh profile path'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'zsh/install.ps1'))) 'Unexpected Windows zsh installer'
    $codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
    Assert-True ($plan[5].Destination -eq (Join-Path $codexRoot 'AGENTS.md')) 'Wrong Codex global instructions path'
    foreach ($skillDirectory in $skillDirectories) {
        $skillDestination = Join-Path $HOME ".agents/skills/$($skillDirectory.Name)"
        $skillSource = Join-Path $fixtureRepo "code_agent/skills/$($skillDirectory.Name)"
        Assert-True (@($plan | Where-Object { $_.Destination -eq $skillDestination -and $_.Source -eq $skillSource }).Count -eq 1) "Wrong skill link: $($skillDirectory.Name)"
    }
    Write-Host 'PowerShell parsing and destination checks passed.'
    if ($PlanOnly) { return }

    $source = Join-Path $testRoot 'source file'
    $target = Join-Path $testRoot 'nested/target file'
    Set-Content -LiteralPath $source -Value 'repository'
    Install-DotfilesLink $source $target
    Assert-True ((Get-Item -LiteralPath $target).LinkType -eq 'SymbolicLink') 'Missing file symlink'
    function Read-Host { throw 'Unexpected confirmation for an existing correct link' }
    Install-DotfilesLink $source $target

    $conflict = Join-Path $testRoot 'existing file'
    Set-Content -LiteralPath $conflict -Value 'original'
    foreach ($reply in @('n', '', 'unexpected')) {
        $script:testReply = $reply
        function Read-Host { return $script:testReply }
        Install-DotfilesLink $source $conflict
        Assert-True ((Get-Content -LiteralPath $conflict) -eq 'original') 'Declined overwrite changed content'
    }

    function Read-Host { return 'yes' }
    Install-DotfilesLink $source $conflict
    $backups = @(Get-ChildItem -LiteralPath $testRoot -Filter 'existing file.dotfiles-backup-*')
    Assert-True ($backups.Count -eq 1) 'Expected exactly one backup'
    Assert-True ((Get-Content -LiteralPath $backups[0].FullName) -eq 'original') 'Backup content lost'

    $directorySource = Join-Path $testRoot 'source directory'
    $directoryTarget = Join-Path $testRoot 'target directory'
    [IO.Directory]::CreateDirectory($directorySource) | Out-Null
    [IO.Directory]::CreateDirectory($directoryTarget) | Out-Null
    Set-Content -LiteralPath (Join-Path $directoryTarget '.hidden') -Value 'keep'
    Install-DotfilesLink $directorySource $directoryTarget
    Assert-True ((Get-Item -LiteralPath $directoryTarget).LinkType -eq 'SymbolicLink') 'Missing directory symlink'
    $directoryBackup = @(Get-ChildItem -LiteralPath $testRoot -Filter 'target directory.dotfiles-backup-*')
    Assert-True (Test-Path -LiteralPath (Join-Path $directoryBackup[0].FullName '.hidden')) 'Directory backup lost hidden file'

    $broken = Join-Path $testRoot 'broken link'
    New-Item -ItemType SymbolicLink -Path $broken -Target (Join-Path $testRoot 'missing') | Out-Null
    Install-DotfilesLink $source $broken
    Assert-True ((Get-Content -LiteralPath $broken) -eq 'repository') 'Broken link was not replaced'

    $rollbackTarget = Join-Path $testRoot 'rollback'
    Set-Content -LiteralPath $rollbackTarget -Value 'restore me'
    function New-Item { throw 'Simulated link creation failure' }
    $failed = $false
    try { Install-DotfilesLink $source $rollbackTarget } catch { $failed = $true }
    Remove-Item Function:New-Item
    Assert-True $failed 'Link failure was not reported'
    Assert-True ((Get-Content -LiteralPath $rollbackTarget) -eq 'restore me') 'Failed creation did not restore original'

    Write-Host 'PowerShell installer checks passed.'
}
finally {
    Remove-Item Function:Read-Host -ErrorAction SilentlyContinue
    Remove-Item Function:New-Item -ErrorAction SilentlyContinue
    # Leave fixtures available for inspection; do not recursively delete symlinks.
    Write-Host "Test fixtures: $testRoot"
}
