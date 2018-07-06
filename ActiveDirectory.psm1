Function Export-Groups {


    $Domain = $env:USERDNSDOMAIN
    $splitDomain = $Domain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedGroups = "$env:USERPROFILE\Desktop\Exported-Groups.csv"
    $Groups = Get-ADGroup -Properties * -Filter * -SearchBase $searchbase | select name | Export-Csv -Path $exportedGroups -NoTypeInformation

    gc $exportedGroups

}


Function Import-Groups {

    
}
