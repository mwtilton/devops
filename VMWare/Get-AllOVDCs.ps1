<#
$server = Connect-CIServer "10.20.0.4" -port 9443
Get-Folder -Server $server -Name Folder


#Connect to VCD server
Connect-CIServer myvcloud.scalematrix.com

#Displays list of external networks for ease of use
#Get-ExternalNetwork | Select Name | ft

Get-Folder -Name Folder
#>

Connect-VIServer -Menu