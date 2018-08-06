Function Start-OpenStack {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer

    )
    Write-host "Starting OpenStack" -fore Yellow


    Invoke-RestMethod -uri $DestServer -Method GET





} # End Function
