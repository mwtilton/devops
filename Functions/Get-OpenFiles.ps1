function Get-OpenFiles {
    [CmdletBinding()]
    Param(

    )
    #openfiles /query /s fileserver01 /u matthewt | findstr /i /c:"LG-PST-BACKUPS"

    openfiles /query /s $args[0] /fo csv /V | Out-File -Force C:\temp\openfiles.csv
    $search = $args[1]
    Import-CSV C:\temp\openfiles.csv | Select "Accessed By", "Open Mode", "Open File (Path\executable)" | Where-Object {$_."Open File (Path\executable)" -match $search} | format-table -auto
    Remove-Item C:\temp\openfiles.csv
}
