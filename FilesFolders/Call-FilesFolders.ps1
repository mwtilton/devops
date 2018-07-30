<##############################################################################
Setup

Notes:

##############################################################################>
#Import-Module "$env:WORKINGFOLDER\DevOps\FilesFolders\FilesFolders\FilesFolders.psm1" -Force -Verbose
#Invoke-Pester $moduleFolder -CodeCoverage $moduleFolder\FilesFolders\FilesFolders.psm1

$moduleFolder = "C:\Users\mwtilton\Desktop\FilesFolders\FilesFolders"

Import-Module GroupPolicy
Import-Module ActiveDirectory
Import-Module $moduleFolder -Force


# This path must be absolute, not relative
#$date = (get-date).ToString("mmddyyyy")
$Path        = $PWD  # Current folder specified in Set-Location above
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPO Backup 2018-07-30-08-23-59\"
New-Item -ItemType Directory $BackupPath -ea SilentlyContinue

###############################################################################
# IMPORT PROCESS
###############################################################################
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "fileserver01"
$MigTableCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Import.csv"

Import-FileShares `
    -DestServer $DestServer `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath
