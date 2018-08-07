Function New-FileShares {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $csv # Path of the GPO GUID Folder under the main Backup Folder
    )

    $importCSV = Import-csv $csv | ? {$_.path -ne ""}
    $importcsv | Foreach-object {
        Write-host "  [>]" -foregroundcolor DarkGray -NoNewline
        Write-host "Creating Shares for " -foregroundcolor DarkGray -NoNewline
        Write-host $_.path -ForegroundColor White -NoNewline

        Try{
            New-item -Path $_.path -ItemType Directory -ErrorAction Stop | Out-null
            Write-host "  [+]" -NoNewline
            Write-host $_.Name -ForegroundColor White -NoNewline
            Write-host " folder has been created." -ForegroundColor DarkGreen

        }
        Catch{
            If($_.exception.tostring().contains("already exists")){

            }
            elseif($_.exception.tostring().contains("A drive with the name")){
                Write-host "`r`n    [-]" -fore red -NoNewline
                Write-host "This is probably trying to create a new folder to the drive letter " -ForegroundColor DarkYellow -nonewline
                Write-host $_.targetobject -foregroundcolor White -nonewline
                Write-host " and this is not possible since it is a drive letter and not a valid folder location. This can be ignored but may need to be reviewed." -ForegroundColor DarkYellow

            }
            else {
                Write-Host $_.exception
            }
        }
        Try{
            New-SmbShare –Name $_.Name -Path $_.Path –Description $_.Description -ErrorAction Stop
            Write-host "  [+]" -NoNewline
            Write-host $_.Name -ForegroundColor White -NoNewline
            Write-host " is now being shared." -ForegroundColor DarkGreen
        }
        Catch{
            If($_.exception.tostring().contains("already been shared")){
                Write-Host " has already been shared. Skipped!"
            }
            elseif($_.exception.tostring().contains("directory does not exist")){
                Write-host "`r    [-]" -fore red -NoNewline
                Write-host "This is probably trying to create a new share and this is not possible since the target folder does not exist, is an empty string or a null value." -ForegroundColor DarkYellow

            }
            else{
                Write-host "`rFileshare creation error" -ForegroundColor Red
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }

        }

    }
}
