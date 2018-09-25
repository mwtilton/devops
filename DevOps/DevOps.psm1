$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1
#. "$PSScriptRoot\DevOps.Machine.Ps1"
Try{
    Import-Module $PSScriptRoot\DevOps.Machine.ps1 -Force -ErrorAction Stop
}
Catch {
    Write-Warning "A valid Machine file was not found and couldn't be loaded into the module"
}


############################################################################
#Import related functions
$functions = Get-ChildItem $PSScriptRoot\Functions -Filter "*.ps1"
$functions | ForEach-Object {
    #Write-Host $_.Name
    Import-Module $PSScriptRoot\Functions\$($_.name) -Force
}
Export-ModuleMember *


<#

. $PSScriptRoot\function-Get-PodcastData.ps1
. $PSScriptRoot\function-Get-PodcastMedia.ps1
. $PSScriptRoot\function-Get-PodcastImage.ps1
. $PSScriptRoot\function-ConvertTo-PodcastHtml.ps1
. $PSScriptRoot\function-ConvertTo-PodcastXml.ps1
. $PSScriptRoot\function-Write-PodcastHtml.ps1
. $PSScriptRoot\function-Write-PodcastXML.ps1
. $PSScriptRoot\function-Get-NoAgenda.ps1

Export-ModuleMember Get-NoAgenda
Export-ModuleMember Get-PodcastData
#>
