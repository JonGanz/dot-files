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

function Install-Symlink {
    param (
        [string]$TargetPath, # That symlink's target; where the file really is.
        [string]$Path # Where Windows should think there is a file
    )

    if (Test-Path $Path) {
        if (Test-Symlink $Path) {
            $currentTarget = (Get-Item $Path).Target
            if ($currentTarget -eq $TargetPath) {
                return
            }
        }
        Remove-Item -Path $Path -Force
    }

    New-Item -ItemType SymbolicLink -Path $Path -Target $TargetPath
}

function Test-Symlink {
    param ([string]$Path)

    try {
        $file = Get-Item -Path $Path -Force -ErrorAction Stop
        return $file.Attributes -band [System.IO.FileAttributes]::ReparsePoint
    }
    catch {
        return $false
    }
}

function Install-WindowsTerminal {
    winget install -e --id Microsoft.WindowsTerminal
}

Export-ModuleMember -Function Set-TerminalConfig
