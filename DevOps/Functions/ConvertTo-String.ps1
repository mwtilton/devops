function ConvertTo-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$object
    )
    $string = @()
    $object | ForEach-Object {
        $string += $_
    }
    return [string]$string
}
