$Modules = Get-ChildItem -Path ".\ps-modules" -Filter *.psm1 -File
foreach ($Module in $Modules) {
    Import-Module $Module.FullName -Force
}

Initialize-WSL -Distro "Ubuntu-22.04"

Install-DockerDesktop

Install-Chocolatey
Install-WindowsApps

Uninstall-UnnecessaryWindowsApps
# Stop-OneDrive

if (((Get-CimInstance -ClassName Win32_OperatingSystem).Caption) -like "*Windows 11*") {
    Install-Registry -FilePath (Get-Item ".\Windows11.reg").FullName
}

Install-Fonts

Set-TerminalConfig

# TODO: oh-my-posh
# TODO: Git config; is there a way to use a different username/email based on parent directory or anything?
# TODO: WSL config to limit resources
# TODO: Powershell Profile
# TODO: Terminal config
# TODO: SSH keys?
