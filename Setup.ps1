$Modules = Get-ChildItem -Path ".\ps-modules" -Filter *.psm1 -File
foreach ($Module in $Modules) {
    Import-Module $Module.FullName -Force
}

Initialize-WSL -Distro "Ubuntu-22.04"
Install-DockerDesktop
Install-Chocolatey
Install-WindowsApps

# TODO: oh-my-posh
# TODO: Git config; is there a way to use a different username/email based on parent directory or anything?
# TODO: Powershell Profile
# TODO: sysinternal
# TODO: Windows Registry Settings
# TODO: SSH keys?
# TODO: fonts
# TODO: WSL config to limit resources
# TODO: We should still get VS Code setup anyways....
