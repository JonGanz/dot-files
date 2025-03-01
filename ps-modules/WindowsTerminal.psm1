function Set-OhMyPoshConfig {
    $targetPath = Join-Path `
        -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName `
        -ChildPath "dotfiles\ohmyposh\theme.omp.json"

    $terminalPath = Join-Path `
        -Path $env:LOCALAPPDATA `
        -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

    $settingsPath = Join-Path -Path $terminalPath -ChildPath "theme.omp.json"

    Install-Symlink `
        -TargetPath $targetPath `
        -Path $settingsPath
}

function Set-PowershellConfig {
    $targetPath = Join-Path `
        -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName `
        -ChildPath "dotfiles\powershell\Microsoft.PowerShell_5.x_profile.ps1"

    Install-Symlink `
        -TargetPath $targetPath `
        -Path $Profile
}

function Set-TerminalConfig {
    $terminalPath = Join-Path `
        -Path $env:LOCALAPPDATA `
        -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $settingsPath = Join-Path -Path $terminalPath -ChildPath "settings.json"
    $targetPath = Join-Path `
        -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName `
        -ChildPath "dotfiles\windows-terminal\settings.json"
    
    Install-Symlink `
        -TargetPath $targetPath `
        -Path $settingsPath

    $bgDestPath = Join-Path -Path $terminalPath -ChildPath "bg.jpg"
    $bgSourcePath = Join-Path `
        -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName `
        -ChildPath "dotfiles\windows-terminal\bg.jpg"

    Install-Symlink `
        -TargetPath $bgSourcePath `
        -Path $bgDestPath
}

Export-ModuleMember -Function Set-OhMyPoshConfig, Set-PowershellConfig, Set-TerminalConfig
