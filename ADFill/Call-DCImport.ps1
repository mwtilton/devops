<##############################################################################
NOTE:
    Must have exported all necessary items from Original Domain

##############################################################################>
$ADFill = "$env:USERPROFILE\Desktop\ADFill\ADFill"
$ActiveDirectoryWorkingDirectory = "$env:USERPROFILE\Desktop\ADFill\WorkingFolder"
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
