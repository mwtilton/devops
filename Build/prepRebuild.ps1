Function Start-PrepGit {

    $folder = New-Item -ItemType Directory -Path $env:USERPROFILE\Documents\GitHub
    Set-Location $Folder

    Start-Process "https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe"
    Read-Host "Holding for installation of git"

    Start-Process "https://www.mozilla.org/en-US/firefox/download/thanks/"
    Read-Host "Holding for installation of FireFox"

        Read-Host "Ready to clone DevOps Repo?"
    git clone "https://mwtilton@bitbucket.org/mwtilton/devops.git"

    Set-Location $gitFolder\DevOps

    . $gitFolder\DevOps\SetupGit\SetupGit.ps1
    Invoke-SetupGit

    git branch

    git branch build

    git branch -u origin/build

    git checkout build

    git pull

    #. "$gitFolder\Devops\Devops\Functions\Build\prepDomainController.ps1"

    Start-Process powershell_ise -ArgumentList "$gitFolder\Devops\Build\prepDomainController.ps1" -verb RunAs
}
