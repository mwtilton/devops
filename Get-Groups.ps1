$env:USERDNSDOMAIN
$Groups = Get-ADGroup -Properties * -Filter * -SearchBase "DC=ourcompany,DC=Com" 
Foreach($G In $Groups)
{
    Write-Host $G.Name
    Write-Host "-------------"
    $G.Members
}
