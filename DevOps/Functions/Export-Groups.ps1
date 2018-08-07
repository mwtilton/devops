Function Export-Groups {
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

    $exportedGroups = "$path\Exported-Groups.csv"
    Get-ADGroup -Properties * -Filter * -SearchBase $searchbase |  Export-Csv -Path $exportedGroups -NoTypeInformation

    Import-Csv $exportedGroups | % {$_.name } | ft

}
