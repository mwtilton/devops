<##############################################################################
NOTE:
    Must have exported all necessary items from Original Domain

##############################################################################>
$ActiveDirectory = "$env:USERPROFILE\Desktop\ActiveDirectory\ActiveDirectory"
$ActiveDirectoryWorkingDirectory = "$ActiveDirectory\WorkingFolder"
New-Item -ItemType Directory $ActiveDirectoryWorkingDirectory -ea SilentlyContinue
Set-Location $ActiveDirectoryWorkingDirectory

Import-Module ActiveDirectory
Import-Module $ActiveDirectory -Force

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$DestDomain  = $env:USERDNSDOMAIN
$DestServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

###############################################################################
# IMPORT PROCESS
###############################################################################
Start-DCImport `
    -DestDomain $DestDomain `
    -DestServer $DestServer `
    -Path $Path
