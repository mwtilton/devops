$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1

############################################################################
#Import related functions

#.ExternalHelp FilesFolders.psm1-help.xml
function Test-FileLock {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$Path
    )

    $oFile = New-Object System.IO.FileInfo $Path

    if ((Test-Path -Path $Path) -eq $false) {
        return $false
    }

    try {
        $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        if ($oStream) {
        $oStream.Close()
        }
        $false
    } catch {
        # file is locked by a process.
        return $true
    }
}



function Get-OpenFiles {
    #openfiles /query /s fileserver01 /u matthewt | findstr /i /c:"LG-PST-BACKUPS"

    openfiles /query /s $args[0] /fo csv /V | Out-File -Force C:\temp\openfiles.csv
    $search = $args[1]
    Import-CSV C:\temp\openfiles.csv | Select "Accessed By", "Open Mode", "Open File (Path\executable)" | Where-Object {$_."Open File (Path\executable)" -match $search} | format-table -auto
    Remove-Item C:\temp\openfiles.csv
}


function Get-FilesFolders {
    Param(
        [Parameter(Mandatory=$false)]
        [String]
        $path = "$env:TEMP\FFTEST"
    )



    Begin{
        $getFilesFolders = Get-ChildItem $path -Recurse
        $getFilesFolders | ForEach-Object {
            <#
            $spaces = @()
            Write-Host $_.Length -ForegroundColor Cyan -NoNewline
            (1..$_.Length) | ForEach-Object {
                $spaces += " "
            }
            $spaces += "END"
            Write-Host $spaces -ForegroundColor Cyan
            Write-host ($_.FullName).Replace($path, $spaces) -ForegroundColor Red
            #>

            Write-host ($_.FullName).split("\")
            Write-Host $path -ForegroundColor Cyan
            Write-host ($_.FullName).Replace($path, "") -ForegroundColor Red
        }
    }

}

Function Get-FileShares {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $BackupPath # Path of the GPO GUID Folder under the main Backup Folder
    )
    $gpm = New-Object -ComObject GPMgmt.GPM
    $Constants = $gpm.getConstants()
    $GPMBackupDir = $gpm.GetBackupDir($BackupPath)
    $GPMSearchCriteria = $gpm.CreateSearchCriteria()
    $BackupList = $GPMBackupDir.SearchBackups($GPMSearchCriteria)

    ForEach ($GPMBackup in $BackupList)
    {
        [xml]$GPReport = Get-Content (Join-Path -Path $GPMBackup.BackupDir -ChildPath "$($GPMBackup.ID)\gpreport.xml")

        $gPLinks = $null
        $gPLinks = $GPReport.GPO.User.ExtensionData.Extension.DriveMapSettings.Drive.Properties | Select-Object label, path, letter, action | ? {($_.path -ne "")} | Sort-Object label
        $gpLinks | Foreach-Object {
            #Write-host ($_) -match "path\=\`""
            $_
            #Test-Path $_.path
        }
    }
    get-WmiObject -class Win32_Share -computer $DestServer | select name, path | ft
}
Function New-FileShares {
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
        Write-host "  [>]" -foregroundcolor DarkGray
        Write-host "Testing Server Shares" -foregroundcolor DarkGray


        Write-host $_.path -ForegroundColor red
        Try{
            New-item -Path $_.path -ItemType Directory -ErrorAction Stop | Out-null
        }
        Catch{
            If($_.exception.tostring().contains("already exists")){

            }
            elseif($_.exception.tostring().contains("A drive with the name")){
                Write-host "  [-]" -fore red -NoNewline
                Write-host "This is probably trying to create a new folder to the drive letter " -ForegroundColor DarkYellow -nonewline
                Write-host $_.targetobject -foregroundcolor White -nonewline
                Write-host " and this is not possible since it is a drive letter and not a valid folder location. This can be ignored but may need to be reviewed." -ForegroundColor DarkYellow

            }
            else {
                Write-Host $_.exception
            }
        }

    }
}

Function Export-SharesACL {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$csv,
        [parameter(Mandatory=$true)][string]$path
    )

    $importCSV = Import-CSV $csv
    $importCSV | Foreach-object {
        $Output = @()
        $Output += get-acl $_.path
        $Output += GCI $Path | ?{$_.PSIsContainer} | Get-ACL


    }
    $Output | sort PSParentPath| Select-Object @{Name="Path";Expression={$_.PSPath.Substring($_.PSPath.IndexOf(":")+2) }},@{Name="Type";Expression={$_.GetType()}},Owner -ExpandProperty Access | Export-Csv "$path\Exported-FileSharesACL.csv" -NoTypeInformation -Force
}
Function Export-FileShares {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$Path,
        [parameter(Mandatory=$true)][string]$DestServer
    )
    get-WmiObject -class Win32_Share -computer $DestServer | select name, path | Export-Csv "$path\Exported-FileShares.csv" -NoTypeInformation -Force
}

