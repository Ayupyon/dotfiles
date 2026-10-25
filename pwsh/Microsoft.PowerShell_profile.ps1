$CONFIG_HOME = Join-Path $HOME ".config/pwsh/pwshconfig.d"

if (Test-Path -LiteralPath $CONFIG_HOME -PathType Container) {
    foreach ($configScript in (Get-ChildItem -LiteralPath $CONFIG_HOME -Filter "*.ps1" -File | Sort-Object Name)) {
        . $configScript.FullName
    }
}
