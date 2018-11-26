Import-Module .\vmware.machine.ps1 -Force -ErrorAction Stop

<#
$server = Connect-CIServer "10.20.0.4" -port 9443
Get-Folder -Server $server -Name Folder


#Connect to VCD server
Connect-CIServer myvcloud.scalematrix.com

#Displays list of external networks for ease of use
#Get-ExternalNetwork | Select Name | ft

Get-Folder -Name Folder
#>

#Connect-CIServer "10.20.0.4"
#Connect-CIServer myvcloud.scalematrix.com

$PWord = ConvertTo-SecureString -String $vmware.password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmware.UserName, $PWord
#$vCenterCred = Get-Credential -Message "vCenter server or esxi credentials" -UserName $vmware.UserName

$vcenterServer = "10.20.0.4"
#myvcloud.scalematrix.com
Connect-viServer -server $vcenterServer -Credential $Credential

[math]::Round(((get-vm | Where-object{$_.PowerState -eq "PoweredOn" }).UsedSpaceGB | measure-Object -Sum).Sum)
[math]::Round(((get-vm | where-object{$_.PowerState -eq "PoweredOn" }).MemoryGB | Measure-Object -Sum).Sum ,0)