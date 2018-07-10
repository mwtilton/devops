<##############################################################################
Setup

Notes:

##############################################################################>

Import-Module "env:WORKINGFOLDER\FilesFolders\root\*" -Force

$Path        = $env:WORKINGFOLDER  

Start-FilesFolders `
    -Path $Path
