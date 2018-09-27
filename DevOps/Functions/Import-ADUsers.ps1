Function Import-ADUsers {
    [CmdletBinding()]
    Param(

    )

    $users = Import-csv "$env:USERPROFILE\Desktop\WorkingFolder\Import-IT.csv"

    $password = Read-Host "Set pw" -AsSecureString

    $users | ForEach-Object {

        $params = @{
            Name = $_.name
            SamAccountName = $_.samaccountname
            Title = "IT admin"
            Path = "CN=Users,DC=democloud,DC=local"
            Type = "user"
            AccountPassword = $password
            Enabled = $true
            ChangePasswordAtLogon = $false
            DisplayName = $_.Name
            GivenName = ($_.Name).Split(" ")[0]
            SurName = ($_.Name).Split(" ")[1]
            PasswordNeverExpires = $true
            Description = "IT Admin"
            UserPrincipalName = ("{0}{1}" -f $_.samaccountname,"@democloud.local")

        }

        New-ADUser @params
        $groups = "Domain Admins", "RD Users"
        $user = $_.samaccountname
        $groups | ForEach-Object {
            Add-ADGroupMember -Identity $_ -Members $user
        }


    }
}
