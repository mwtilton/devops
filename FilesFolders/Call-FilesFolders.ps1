<##############################################################################
Setup

Notes:


##############################################################################>
New-Item -ItemType Directory $env:USERPROFILE\Desktop\FilesFoldersWorkingFolder -ea SilentlyContinue
Set-Location $env:USERPROFILE\Desktop\FilesFoldersWorkingFolder

Import-Module "$env:USERPROFILE\Desktop\FilesFolders\FilesFolders" -Force

# This path must be absolute, not relative
$Path        = $PWD  # Current folder specified in Set-Location above
$SrceServer  = $env:COMPUTERNAME
$SrceDomain  = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"

Start-FilesFolders `
    -SrceDomain $SrceDomain `
    -SrceServer $SrceServer `
    -Path $Path
    
###############################################################################
# END
###############################################################################

