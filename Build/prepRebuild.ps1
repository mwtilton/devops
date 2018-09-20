Function Start-PrepRebuild {
    $path = "$env:USERPROFILE\Documents\Github"
    New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue
    Set-Location $path

    #Start-Process "https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe"
    #Read-Host "Holding for installation of git"
    Get-Process -Name git
    Try{
        git --version
    }
    Catch{
        "Git broke for some reason"
        break
    }

    Read-host "We good fam???"

    Start-Process "https://www.mozilla.org/en-US/firefox/download/thanks/"
    Read-Host "Holding for installation of FireFox"

    Write-Host $pwd.Path
    Read-Host "Ready to clone DevOps Repo?"
    git clone "https://mwtilton@bitbucket.org/mwtilton/devops.git"

    Set-Location $path\DevOps

    . $path\DevOps\SetupGit\SetupGit.ps1
    Invoke-SetupGit
    Read-Host "Ready to set the branch information?"
    git branch

    git branch build

    git branch -u origin/build

    git checkout build

    git pull

    #. "$gitFolder\Devops\Devops\Functions\Build\prepDomainController.ps1"

    Start-Process powershell_ise -ArgumentList "$gitFolder\Devops\Build\prepDomainController.ps1" -verb RunAs
}
