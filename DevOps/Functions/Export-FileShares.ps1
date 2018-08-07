Function Export-FileShares {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$Path,
        [parameter(Mandatory=$true)][string]$DestServer
    )
    get-WmiObject -class Win32_Share -computer $DestServer | select name, path, Description | Export-Csv "$path\Exported-FileShares.csv" -NoTypeInformation -Force
}
