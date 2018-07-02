<##############################################################################

MigrationTableCSV file setup:

Source,Destination,Type
"OldDomain.FQDN","NewDomain.FQDN","Domain"
"OldDomainNETBIOSName","NewDomainNETBIOSName","Domain"
"\\foo\server","\\baz\server","UNC"

##############################################################################>
New-Item -ItemType Directory $env:USERPROFILE\Desktop\GPOMigrationWorkingFolder -ea SilentlyContinue
Set-Location $env:USERPROFILE\Desktop\GPOMigrationWorkingFolder

Import-Module GroupPolicy
Import-Module ActiveDirectory
Import-Module $env:USERPROFILE\Desktop\GPOMigration\GPOMigration -Force

# This path must be absolute, not relative
$date = (get-date).ToString("mmddyyyy")
$Path        = $PWD  # Current folder specified in Set-Location above
$BackupPath  = "C:\Users\Administrator\Desktop\GPOMigrationWorkingFolder\GPO Backup.domain.local 2018-07-02-12-55-21\"
New-Item -ItemType Directory $BackupPath -ea SilentlyContinue 

###############################################################################
# IMPORT PROCESS
###############################################################################
$DestDomain  = .domain.local'
$DestServer  = 'dc01.domain.local'
$MigTableCSVPath = "$env:USERPROFILE\Desktop\GPOMigration\MigTable_sample.csv"

Start-GPOImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path `
    -BackupPath $BackupPath `
    -MigTableCSVPath $MigTableCSVPath `
    -CopyACL
