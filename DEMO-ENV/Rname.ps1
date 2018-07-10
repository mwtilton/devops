$name = Read-Host "New Server Name"
Rename-Computer -NewName "$name"

Add-Computer -DomainName anchorgeneral.local -ComputerName $PC -credential backoffice\ -force

restart-computer -confirm
