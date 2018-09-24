function Get-OpenFiles {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$false)]
        [String]
        $search
    )

    openfiles /query /s $DestServer /fo csv /V | Out-File -Force $env:TEMP\openfiles.csv

    Import-CSV $Env:TEMP\openfiles.csv | Select "Accessed By", "Open Mode", "Open File (Path\executable)" | Where-Object {$_."Open File (Path\executable)" -match $search} | format-table -auto
    Remove-Item $Env:TEMP\openfiles.csv
}
