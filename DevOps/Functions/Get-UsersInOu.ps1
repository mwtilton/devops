
Function Get-UsersInOu{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $ou

    )
    $users = Get-ADUser -SearchBase "OU=$($OU),dc=$($OU),dc=Local" -Filter * | select name, samaccountname, distinguishedname
    return $users
}
