$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8';

oh-my-posh init pwsh --config "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\theme.omp.json" | Invoke-Expression

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Define some alias functions; required for aliases that include parameters.
function Alias-GitFetch {
    git fetch -p
}

function Alias-GitStatus {
    git status
}

function Alias-NeovimCurrentDirectory {
    nvim .
}

function Alias-NpmDev {
    npm run dev
}

function Alias-NpmFormat {
    npm run format
}

function Alias-NpmLint {
    npm run lint
}

function Alias-NpmTest {
    npm run test
}

function Alias-VSCodeCurrentDirectory {
    code .
}

function Cut-ReleaseBranch {
    param (
        [string]$Version
    )

    if (-not $Version) {
        Write-Error "You must provide a version number, e.g., 2024.46.0";
        return;
    }

    $branch = "release/$Version";
    $tag = "$Version";

    git fetch --prune;
    git branch $branch origin/develop;
    git tag $tag $branch;
    git push -u origin $branch;
    git push origin $tag;
}

function Merge-ReleaseBranch {
    param (
        [string]$Version
    )

    if (-not $Version) {
        Write-Error "You must provide a version number, e.g., 2024.46.0";
        return;
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($currentBranch -eq "HEAD") {
        Write-Error "Cannot merge branches while on detached HEAD";
        return;
    }

    $releaseBranch = "origin/release/$Version";

    git fetch --prune;
    git stash push -m "Stashing changes to $currentBranch before merging release $version";
    git checkout main;
    git reset --hard origin/main;
    git merge --ff-only $releaseBranch;
    git push origin main
    git checkout $currentBranch;
    git stash pop;
}

# Define aliases because I'm too lazy to type.
Set-Alias -Name ch -Value Alias-VSCodeCurrentDirectory
Set-Alias -Name dev -Value Alias-NpmDev
Set-Alias -Name format -Value Alias-NpmFormat
Set-Alias -Name g -Value git
Set-Alias -Name gf -Value Alias-GitFetch
Set-Alias -Name gst -Value Alias-GitStatus
Set-Alias -Name lint -Value Alias-NpmLint
Set-Alias -Name test -Value Alias-NpmTest
Set-Alias -Name vh -Value Alias-NeovimCurrentDirectory
