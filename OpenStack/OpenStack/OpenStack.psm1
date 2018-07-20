$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1
. "$PSScriptRoot\OpenStack.Machine.ps1"
############################################################################
#Import related functions

#.ExternalHelp OpenStack.psm1-help.xml
Function Start-OpenStack {
    Param (
        [Parameter(Mandatory=$true,HelpMessage="Must be FQDN.")]
        [ValidateScript({$_ -like "*.*"})]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path

    )
    Write-host "Starting OpenStack" -fore Yellow





} # End Function


