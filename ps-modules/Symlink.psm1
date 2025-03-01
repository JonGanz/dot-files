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

Export-ModuleMember -Function Install-Symlink, Test-Symlink
