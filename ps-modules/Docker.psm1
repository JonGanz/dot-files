function Install-DockerDesktop {
    if (Get-Command docker.exe -ErrorAction SilentlyContinue) {
        Write-Host "Docker already installed." -ForegroundColor Green
        return
    }

    $TempDir = Join-Path -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName -ChildPath "_temp"
    if (-not (Test-Path $TempDir)) {
        New-Item -ItemType Directory -Path $TempDir | Out-Null
    }
    
    $ExePath = Join-Path -Path $TempDir -ChildPath "DockerDesktopInstall.exe"
    if (-not (Test-Path $ExePath)) {
        Start-BitsTransfer -Source "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -Destination $ExePath 
    }

    Start-Process $ExePath -Wait -ArgumentList 'install', '--accept-license', '--backend=wsl-2', '--always-run-service'
}

Export-ModuleMember -Function Install-DockerDesktop
