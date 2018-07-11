
$moduleFolder = "$env:WORKINGFOLDER\DevOps\ActiveDirectory"
Invoke-Pester $moduleFolder -CodeCoverage $moduleFolder\ActiveDirectory\ActiveDirectory.psm1
