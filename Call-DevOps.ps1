<##############################################################################
Setup

Notes:


##############################################################################>
$workingfolder ="$env:WORKINGFOLDER\DevOps\DevOps-WorkingFolder"
New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
Set-Location $workingfolder

Import-Module "$env:WORKINGFOLDER\DevOps\DevOps" -Force

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

New-FileShares `
    -DestServer $DestServer `
    -csv $sharefolderCSVPath

Import-SharesACL `
    -csv $shareACLCSVPath `
    -MigTableCSVPath $MigTableCSVPath



<##############################################################################
Setup

Notes:
##############################################################################>
#$workingfolder ="$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack-WorkingFolder"
#New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
#Set-Location $workingfolder

Import-Module "$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack" -Force
#$path = "$env:USERPROFILE\Documents\Tilt-openrc.txt"
$path = "$env:USERPROFILE\Documents\Tilt_ZeroStack_v3rc.txt"

#Start-OpenStack -DestServer $OpenStackInfo.Compute
Set-OpenRC $Path


<##############################################################################
Setup

Your working folder path should include a copy of this script, and a copy of
the GPOMigration.psm1 module file.

This example assumes that a backup will run under a source credential and server,
and the import will run under a destination credential and server.  Between these
two operations you will need to copy your working folder from one environment to
the other.

Modify the following to your needs:
 working folder path
 source domain and server
 destination domain and server
 the GPO DisplayName Where criteria to target your policies for migration
##############################################################################>
New-Item -ItemType Directory $env:USERPROFILE\Desktop\WorkingFolder -ea SilentlyContinue
Set-Location $env:USERPROFILE\Desktop\WorkingFolder

Import-Module GroupPolicy
Import-Module ActiveDirectory
Import-Module "$env:USERPROFILE\Desktop\GPOMigration\GPOMigration" -Force

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$SrceDomain  = $env:USERDNSDOMAIN
$SrceServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

$DisplayName = Get-GPO -All -Domain $SrceDomain -Server $SrceServer | Select-Object -ExpandProperty DisplayName

Start-GPOExport `
    -SrceDomain $SrceDomain `
    -SrceServer $SrceServer `
    -DisplayName $DisplayName `
    -Path $Path

###############################################################################
# END
###############################################################################


<##############################################################################

MigrationTableCSV file setup:

Source,Destination,Type
"OldDomain.FQDN","NewDomain.FQDN","Domain"
"OldDomainNETBIOSName","NewDomainNETBIOSName","Domain"
"\\foo\server","\\baz\server","UNC"

##############################################################################>
New-Item -ItemType Directory $env:USERPROFILE\Desktop\WorkingFolder -ea SilentlyContinue
Set-Location $env:USERPROFILE\Desktop\WorkingFolder

Import-Module GroupPolicy
Import-Module ActiveDirectory
Import-Module $env:USERPROFILE\Desktop\GPOMigration\GPOMigration -Force

# This path must be absolute, not relative
#$date = (get-date).ToString("mmddyyyy")
$Path        = $PWD  # Current folder specified in Set-Location above
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPOBackup-DemoCloud"
New-Item -ItemType Directory $BackupPath -ea SilentlyContinue

###############################################################################
# IMPORT PROCESS
###############################################################################
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
$MigTableCSVPath = "$env:USERPROFILE\Desktop\WorkingFolder\Import.csv"

Start-GPOImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath `
    -CopyACL


    <##############################################################################
Setup

##############################################################################>
$ADFill = "$env:USERPROFILE\Desktop\ADFill\ADFill"
$ActiveDirectoryWorkingDirectory = "$env:USERPROFILE\Desktop\ADFill\WorkingFolder"
New-Item -ItemType Directory $ActiveDirectoryWorkingDirectory -ea SilentlyContinue
Set-Location $ActiveDirectoryWorkingDirectory

Import-Module ActiveDirectory
Import-Module $ADFill -Force

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$SrceDomain  = $env:USERDNSDOMAIN
$SrceServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

Start-DCExport `
    -SrceDomain $SrceDomain `
    -SrceServer $SrceServer `
    -Path $Path

###############################################################################
# END
###############################################################################

<##############################################################################
NOTE:
    Must have exported all necessary items from Original Domain

##############################################################################>
$ADFill = "$env:USERPROFILE\Desktop\ADFill\ADFill"
$ActiveDirectoryWorkingDirectory = "$env:USERPROFILE\Desktop\WorkingFolder"
New-Item -ItemType Directory $ActiveDirectoryWorkingDirectory -ea SilentlyContinue
Set-Location $ActiveDirectoryWorkingDirectory

Import-Module ActiveDirectory
Import-Module $ADFill -Force

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
$CSVPath = "$ActiveDirectoryWorkingDirectory\Import.csv"

###############################################################################
# IMPORT PROCESS
###############################################################################
Start-DCImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -CSVPath $CSVPath `
    -Path $Path
