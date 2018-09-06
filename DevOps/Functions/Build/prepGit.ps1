Set-Location $env:USERPROFILE\Documents
$gitFolder = New-Item -ItemType Directory GitHub
Set-Location $gitFolder

. .\SetupGit\SetupGit.ps1
Invoke-SetupGit

git clone "https://mwtilton@bitbucket.org/mwtilton/sm-web.git"

git branch

git branch build

git branch -u origin/build

git checkout build

git pull

. ".\$gitFolder\Devops\Devops\Functions\Build\prepDomainController.ps1"

Start-Process powershell_ise -ArgumentList "$gitFolder\Devops\Devops\Functions\Build\prepDomainController.ps1" -verb RunAs
#reboot???
