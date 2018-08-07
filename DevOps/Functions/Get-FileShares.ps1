Function Get-FileShares {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$false)]
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
