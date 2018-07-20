$projectFolder = "$env:WORKINGFOLDER\DevOps\OpenStack\"
Invoke-Pester $projectFolder\Tests -CodeCoverage $projectFolder\OpenStack\OpenStack.psm1
