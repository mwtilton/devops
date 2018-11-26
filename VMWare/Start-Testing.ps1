Import-Module .\vmware.machine.ps1 -Force -ErrorAction Stop

$PWord = ConvertTo-SecureString -String $vmware.password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmware.UserName, $PWord

Connect-ViServer -server $vmware.server -Credential $Credential
$global:defaultviserver

[math]::Round(((get-vm | Where-object{$_.PowerState -eq "PoweredOn" }).UsedSpaceGB | measure-Object -Sum).Sum)
[math]::Round(((get-vm | where-object{$_.PowerState -eq "PoweredOn" }).MemoryGB | Measure-Object -Sum).Sum ,0)

Disconnect-ViServer $global:defaultviserver -Confirm:$false -Force