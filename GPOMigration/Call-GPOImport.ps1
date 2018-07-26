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
$date = (get-date).ToString("mmddyyyy")
$Path        = $PWD  # Current folder specified in Set-Location above
$BackupPath  = ""
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
