Import-Module .\vmware.machine.ps1 -Force -ErrorAction Stop

<#
Get-Folder -Server $server -Name Folder

Get-ExternalNetwork | Select Name | ft
Get-Folder -Name Folder
#>


$PWord = ConvertTo-SecureString -String $vmware.password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmware.UserName, $PWord
#$vCenterCred = Get-Credential -Message "vCenter server or esxi credentials" -UserName $vmware.UserName

Connect-viServer -server $vmware.server -Credential $Credential

[math]::Round(((get-vm | Where-object{$_.PowerState -eq "PoweredOn" }).UsedSpaceGB | measure-Object -Sum).Sum)
[math]::Round(((get-vm | where-object{$_.PowerState -eq "PoweredOn" }).MemoryGB | Measure-Object -Sum).Sum ,0)

Disconnect-CiServer -Server $vmware.server