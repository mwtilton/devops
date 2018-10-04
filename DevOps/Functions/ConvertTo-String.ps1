function ConvertTo-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$object
    )
    [array]$string = @()
    $object | ForEach-Object {
        $string += $_
    }
    $path = Get-Item "WSMan:\localhost\Client\TrustedHosts"
    Set-Item -Path $path -Value $string -Force -Confirm:$false
}
