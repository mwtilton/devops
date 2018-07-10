<##############################################################################
Setup

Notes:

##############################################################################>
#Import-Module "$env:WORKINGFOLDER\DevOps\FilesFolders\FilesFolders\FilesFolders.psm1" -Force -Verbose

Invoke-Pester -CodeCoverage $env:WORKINGFOLDER\DevOps\FilesFolders\FilesFolders\FilesFolders.psm1
