Function Export-SharesACL {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$csv,
        [parameter(Mandatory=$true)][string]$path
    )
    #csv is the exported file shares from Export-FileShares
    $importCSV = Import-CSV $csv
    $importCSV | Foreach-object {
        Try{
            $Output = @()
            $Output += get-acl $_.path
            $Output += GCI $Path | ?{$_.PSIsContainer} | Get-ACL
            $Output | sort PSParentPath| Select-Object @{Name="Path";Expression={$_.PSPath.Substring($_.PSPath.IndexOf(":")+2) }},@{Name="Type";Expression={$_.GetType()}},Owner -ExpandProperty Access | Export-Csv "$path\Exported-FileSharesACL.csv" -NoTypeInformation -Force -append

        }
        Catch{
            If($_.exception.ToString().contains("The argument is null")){
                Write-host "  [-]" -fore red -NoNewline
                Write-host "This is probably due to an invalid or empty string" -ForegroundColor DarkYellow -nonewline
                Write-host $_.targetobject -foregroundcolor White

            }
            elseif($_.exception.ToString().contains("drive with the name")){
                Write-host "  [-]" -fore red -NoNewline
                Write-host "This is probably trying to access the drive letter " -ForegroundColor DarkYellow -nonewline
                Write-host $_.targetobject -foregroundcolor White -nonewline
                Write-host " and this is not possible since it is a drive letter and not a valid folder location. This can be ignored but may need to be reviewed." -ForegroundColor DarkYellow
            }
            Else{

            }
        }

    }

}
