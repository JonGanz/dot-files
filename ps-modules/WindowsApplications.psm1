function Install-WindowsApps {
    winget install -e --id Audacity.Audacity
    winget install -e --id GIMP.GIMP
    winget install -e --id Git.Git
    winget install -e --id Inkscape.Inkscape
    winget install -e --id JanDeDobbeleer.OhMyPosh -s winget
    winget install -e --id Microsoft.PowerToys
    winget install -e --id Microsoft.VisualStudioCode
    winget install -e --id Microsoft.WindowsTerminal
    winget install -e --id Obsidian.Obsidian
    winget install -e --id Spotify.Spotify
    winget install -e --id VideoLAN.VLC
    choco install 7zip -y
    choco install sysinternals -y
}

function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey was just installed; Please restart your computer and run the script again" -ForegroundColor Green
        exit
    }

    Write-Host "Chocolatey already installed." -ForegroundColor Green
}

function Uninstall-UnnecessaryWindowsApps {
    Get-AppXPackage Disney.* | Remove-AppXPackage
    Get-AppXPackage Microsoft.549981C3F5F10 | Remove-AppXPackage # Cortana 3.2111.12605.0
    Get-AppXPackage Microsoft.BingWeather | Remove-AppXPackage
    Get-AppXPackage Microsoft.GetHelp | Remove-AppXPackage
    Get-AppXPackage Microsoft.Getstarted | Remove-AppXPackage
    Get-AppXPackage Microsoft.MicrosoftSolitaireCollection | Remove-AppXPackage
    Get-AppXPackage Microsoft.MicrosoftStickyNotes | Remove-AppXPackage
    Get-AppXPackage Microsoft.MixedReality.Portal | Remove-AppXPackage
    Get-AppXPackage Microsoft.Office.OneNote | Remove-AppXPackage
    Get-AppXPackage Microsoft.People | Remove-AppXPackage
    Get-AppXPackage Microsoft.SkypeApp | Remove-AppXPackage
    Get-AppXPackage Microsoft.Wallet | Remove-AppXPackage
    Get-AppXPackage Microsoft.WindowsFeedbackHub | Remove-AppXPackage
    Get-AppxPackage MicrosoftWindows.Client.WebExperience | Remove-AppxPackage # Widgets
    Get-AppXPackage Microsoft.WindowsMaps | Remove-AppXPackage
    Get-AppXPackage Microsoft.YourPhone | Remove-AppXPackage
    Get-AppXPackage Microsoft.ZuneMusic | Remove-AppXPackage
    Get-AppXPackage Microsoft.ZuneVideo | Remove-AppXPackage

    Write-Host "Uninstalled unnecessary default apps..." -ForegroundColor Green
}

function Stop-OneDrive {
    PS onedrive | Stop-Process -Force
    Start-Process "$env:windir\SysWOW64\OneDriveSetup.exe" "/uninstall"
}

function Update-WindowsApps {
    winget upgrade --all
    choco upgrade chocolatey
}

Export-ModuleMember -Function Install-WindowsApps, Uninstall-UnnecessaryWindowsApps, Stop-OneDrive, Install-Chocolatey, Update-WindowsApps, Install-ChocoApps
