
Function Export-OUs {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )

    $Domain = $env:USERDNSDOMAIN
    $splitDomain = $Domain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedOUs = "$path\Exported-OUs.csv"
    Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Export-Csv -Path $exportedOUs -NoTypeInformation
    Import-Csv $exportedOUs | % {$_.name } | ft
}
