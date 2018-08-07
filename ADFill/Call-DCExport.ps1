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
