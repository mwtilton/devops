$name = Read-Host "New Server Name"
Rename-Computer -NewName "$name"
$Domain = Read-Host "Enter in new Domain Name: "
Add-Computer -DomainName $Domain -ComputerName $name -credential -force
restart-computer -confirm
