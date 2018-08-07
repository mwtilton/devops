$projectFolder = "$env:WORKINGFOLDER\DevOps"
Invoke-Pester $projectFolder\Tests -CodeCoverage $projectFolder\DevOps\DevOps.psm1 -tags CALL
