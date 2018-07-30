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
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPO Backup LANDGRAPHICS.LOCAL 2018-07-26-09-40-46"
New-Item -ItemType Directory $BackupPath -ea SilentlyContinue

###############################################################################
# IMPORT PROCESS
###############################################################################
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
$MigTableCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Import.csv"

Import-FileShares `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath
