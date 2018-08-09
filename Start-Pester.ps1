$projectFolder = "$env:WORKINGFOLDER\DevOps"
Invoke-Pester $projectFolder\Tests\*DevOps* -CodeCoverage $projectFolder\DevOps\DevOps.psm1 -tags "Call"
