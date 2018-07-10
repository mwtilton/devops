<##############################################################################
Setup

Notes:

##############################################################################>
#Import-Module "$env:WORKINGFOLDER\DevOps\FilesFolders\FilesFolders\FilesFolders.psm1" -Force -Verbose

$moduleFolder = "$env:WORKINGFOLDER\DevOps\FilesFolders"
Invoke-Pester $moduleFolder -CodeCoverage $moduleFolder\FilesFolders\FilesFolders.psm1
