<##############################################################################
Setup

##############################################################################>
$ActiveDirectory = "$env:USERPROFILE\Desktop\ActiveDirectory\ActiveDirectory"
$ActiveDirectoryWorkingDirectory = "$ActiveDirectory\WorkingFolder"
New-Item -ItemType Directory $ActiveDirectoryWorkingDirectory -ea SilentlyContinue
Set-Location $ActiveDirectoryWorkingDirectory

Import-Module ActiveDirectory
Import-Module $ActiveDirectory -Force

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
