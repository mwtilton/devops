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
