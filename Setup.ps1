$Modules = Get-ChildItem -Path ".\ps-modules" -Filter *.psm1 -File
foreach ($Module in $Modules) {
    Import-Module $Module.FullName -Force
}

########################################
# Get WSL installed with our distro of choice.
########################################
Initialize-WSL -Distro "Ubuntu-22.04"


########################################
# Applications.
########################################
Install-DockerDesktop
Install-Chocolatey
Install-WindowsApps
Uninstall-UnnecessaryWindowsApps
# Stop-OneDrive


########################################
# Personalization
########################################
if (((Get-CimInstance -ClassName Win32_OperatingSystem).Caption) -like "*Windows 11*") {
    Install-Registry -FilePath (Get-Item ".\Windows11.reg").FullName
}

Install-Fonts
Set-TerminalConfig
Set-OhMyPoshConfig
Set-PowershellConfig


# TODO: Git config
# TODO: WSL config to limit resources
# TODO: SSH keys
