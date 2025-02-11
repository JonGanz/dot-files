function Install-Fonts {
    # Setup directories to hold font downloads / extracted fonts.
    $TempDir = Join-Path -Path (Get-Item $MyInvocation.PSCommandPath).DirectoryName -ChildPath "_temp"
    if (-not (Test-Path $TempDir)) {
        New-Item -ItemType Directory -Path $TempDir | Out-Null
    }
    
    $TempFontDir = Join-Path -Path $TempDir -ChildPath "fonts"
    if (-not (Test-Path $TempFontDir)) {
        New-Item -ItemType Directory -Path $TempFontDir | Out-Null
    }

    $TempFontExtDir = Join-Path -Path $TempFontDir -ChildPath "fonts"
    if (-not (Test-Path $TempFontExtDir)) {
        New-Item -ItemType Directory -Path $TempFontExtDir | Out-Null
    }

    # Download the fonts.
    $ZipPath = Join-Path -Path $TempFontDir -ChildPath "JetBrainsMono.zip"
    if (-not (Test-Path $ZipPath)) {
        Start-BitsTransfer -Source "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip" -Destination $ZipPath
        
        # Extract the zip files.
        Expand-Archive -Path $ZipPath -DestinationPath $TempFontExtDir -Force
    }

    $fontFiles = Get-ChildItem -Path $fontFolder -Filter *.ttf -Recurse

    # Install the fonts
    foreach ($fontFile in $fontFiles) {
        if (Get-ItemProperty -Name $fontFile.BaseName -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts") {
            Write-Host "$($fontFile.Name) already installed."
            continue;
        }
        
        $destinationPath = [System.IO.Path]::Combine($env:WINDIR, "Fonts", $fontFile.Name)
        
        Copy-Item -Path $fontFile.FullName -Destination $destinationPath -Force
        New-ItemProperty -Name $fontFile.BaseName -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name
        Write-Host "Installed font $($fontFile.Name)... " -ForegroundColor Green
    }
}

Export-ModuleMember -Function Install-Fonts
