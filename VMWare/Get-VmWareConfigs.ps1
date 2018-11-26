<#
Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false -scope user
Set-PowerCLIConfiguration -DefaultVIServerMode Single -Confirm:$false -scope session

Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false -Scope AllUsers
#>

Get-PowerCLIConfiguration
Get-PowerCLIVersion

#Get-Folder -Server $server -Name Folder

#Get-ExternalNetwork | Select Name | ft
#Get-Folder -Name Folder

Write-host "Open Connections"
Write-host $global:defaultviserver -ForegroundColor Red