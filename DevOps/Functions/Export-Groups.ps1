Function Export-Groups {
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

    $exportedGroups = "$path\Import.csv"
    Get-ADGroup -Properties * -Filter * -SearchBase $searchbase | Export-Csv -Path $exportedGroups -NoTypeInformation

    Import-Csv $exportedGroups | Select-Object {$_.name } | ft

    <#
        Import-Csv file.csv |
        Select-Object *,@{Name='column3';Expression={'setvalue'}} |
        Export-Csv file.csv -NoTypeInformation
    #>
}
