
Function Reset-PWAtLogon{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $ou

    )
    $users = Get-UsersInOu -ou $ou
    $users | Foreach-object {

        Set-ADuser -identity $_.samaccountname -changepasswordatlogon $true
    }
}
