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

Add-PSSnapin VMware.VimAutomation.core
Add-PSSnapin VMware.VimAutomation.Vds
 $vCenterCred = Get-Credential -Message "vCenter server or esxi credentials"
 $vcenterServer = "10.20.0.4"
 #myvcloud.scalematrix.com
 Connect-viServer -server $vcenterServer -Credential $vCenterCred

#[math]::Round(((get-vm | Where-object{$_.PowerState -eq "PoweredOn" }).UsedSpaceGB | measure-Object -Sum).Sum)