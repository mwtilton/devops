<##############################################################################
Setup

Notes:

##############################################################################>
#Import-Module "$env:WORKINGFOLDER\DevOps\FilesFolders\FilesFolders\FilesFolders.psm1" -Force -Verbose
#Invoke-Pester $moduleFolder -CodeCoverage $moduleFolder\FilesFolders\FilesFolders.psm1

$moduleFolder = "$env:USERPROFILE\Desktop\FilesFolders\FilesFolders"

#Import-Module GroupPolicy
#Import-Module ActiveDirectory
Import-Module $moduleFolder -Force


# This path must be absolute, not relative
#$date = (get-date).ToString("mmddyyyy")
$Path        = $PWD  # Current folder specified in Set-Location above
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPOBackup-DemoCloud\"
New-Item -ItemType Directory $BackupPath -ea SilentlyContinue
New-Item -ItemType Directory "$env:USERPROFILE\Desktop\WorkingFolder" -ea SilentlyContinue

###############################################################################
# IMPORT PROCESS
###############################################################################
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "fileserver01"
$sharefolderCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Exported-FileShares.csv"
$shareACLCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Exported-FileSharesACL.csv"
$MigTableCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Import.csv"
<#
====================================================
[+] Creating/Getting Functions
Get-FileShares `
    -DestServer $DestServer `
    -BackupPath $BackupPath

New-FileShares `
    -DestServer $DestServer `
    -csv $sharefolderCSVPath

====================================================
[+] Exporting Functions
Export-FileShares `
    -destserver $DestServer `
    -path $env:USERPROFILE\Desktop\WorkingFolder
Export-SharesACL `
    -csv $sharefolderCSVPath `
    -Path $env:USERPROFILE\Desktop\WorkingFolder
====================================================
[+] Importing

Import-SharesACL `
    -csv $shareACLCSVPath `
    -MigTableCSVPath $MigTableCSVPath

#>
Get-FileShares `
    -DestServer $DestServer `
    -BackupPath $BackupPath
