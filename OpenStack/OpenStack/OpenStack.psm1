$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1
. "$PSScriptRoot\OpenStack.Machine.ps1"
############################################################################
#Import related functions

#.ExternalHelp OpenStack.psm1-help.xml
Function Start-OpenStack {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer

    )
    Write-host "Starting OpenStack" -fore Yellow

    Invoke-RestMethod -uri $DestServer -Method GET



} # End Function


