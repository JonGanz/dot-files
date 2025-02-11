# Ensure WSL2 is installed.
function Test-WSL {
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Installing WSL..." -ForegroundColor Yellow
        wsl --install --no-distribution
    }

    $env:WSL_UTF8 = 1
    $defaultVersion = wsl --status 2>&1 | Select-String "Default Version: 2"
    if (-not $defaultVersion) {
        Write-Host "Setting WSL2 as default version..." -ForegroundColor Yellow
        wsl --set-default-version 2
    }
}

function Update-WSL {
    Write-Host "Updating WSL..." -ForegroundColor Yellow
    wsl --update
}

function Install-WSLDistro {
    param (
        [string]$Distro
    )

    $env:WSL_UTF8 = 1
    $installedDistros = wsl --list --verbose | Select-String $Distro
    if (-not $installedDistros) {
        Write-Host "Installing $Distro..." -ForegroundColor Yellow
        wsl --install -d $Distro
    }
    else {
        Write-Host "$Distro is already installed." -ForegroundColor Green
    }
}

function Initialize-WSL {
    param (
        [string]$Distro
    )

    Test-WSL
    Update-WSL
    Install-WSLDistro -Distro $Distro
    wsl --set-default $Distro
    Write-Host "WSL2 setup complete with $Distro." -ForegroundColor Green
}

Export-ModuleMember -Function Test-WSL, Update-WSL, Install-WSLDistro, Initialize-WSL
