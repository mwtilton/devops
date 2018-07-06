<##############################################################################
NOTE:
    Must have exported all necessary items from Original Domain

##############################################################################>
$ActiveDirectory = "$env:USERPROFILE\Desktop\ActiveDirectory\ActiveDirectory"
$ActiveDirectoryWorkingDirectory = "$ActiveDirectory\WorkingFolder"
New-Item -ItemType Directory $ActiveDirectoryWorkingDirectory -ea SilentlyContinue
Set-Location $ActiveDirectoryWorkingDirectory

Import-Module ActiveDirectory
Import-Module $ActiveDirectory -Force -Verbose

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$SrceDomain  = $env:USERDNSDOMAIN
$SrceServer  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

###############################################################################
# IMPORT PROCESS
###############################################################################
Start-DCImport `
    -SrceDomain $SrceDomain `
    -SrceServer $SrceServer `
    -Path $Path
    
