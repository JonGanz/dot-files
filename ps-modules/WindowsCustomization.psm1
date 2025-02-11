function Install-Registry {
    param (
        [string]$FilePath
    )

    Start-Process reg -Wait -ArgumentList 'import', $FilePath
    Write-Host "Imported registry changes from $FilePath" -ForegroundColor Green
}

Export-ModuleMember -Function Install-Registry
