
Function Start-DCImport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="Must be FQDN.")]
        [ValidateScript({$_ -like "*.*"})]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $CSVPath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path

    )
    Write-Host "Starting OU Import" -ForegroundColor Yellow
    Import-OUs -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath
    Write-host "Starting Group Import" -ForegroundColor Yellow
    Import-Groups -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath

} # End Function
