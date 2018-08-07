
Function Set-UsersPassword {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $ou

    )
    $NewPassword = (Read-Host "Provide New Password" -AsSecureString)
    $users = Get-UsersInOu -ou $ou
    $users | Foreach-object {
        Set-ADAccountPassword -Identity $_.samaccountname -Reset -NewPassword $NewPassword
    }

}
