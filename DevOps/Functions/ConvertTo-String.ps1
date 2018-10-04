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
    #Get-Item "WSMan:\localhost\Client\TrustedHosts" | Set-Item -Value $string -Force -Confirm:$false
}
