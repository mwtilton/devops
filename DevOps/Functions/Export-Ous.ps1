
Function Export-OUs {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $SrceDomain,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )

    $splitDomain = $SrceDomain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedOUs = "$path\Import.csv"
    Get-ADOrganizationalUnit -Filter 'Name -like "*"' -SearchBase $searchbase | Export-Csv -Path $exportedOUs -NoTypeInformation
    Import-Csv $exportedOUs | % {$_.name } | ft
}
