Function Start-DCExport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )
    Write-host "Starting OU Exports" -fore Yellow
    Export-OUs -Path $path
    Write-host "Starting Group Exports" -fore Yellow
    Export-Groups -Path $Path

} # End Function
