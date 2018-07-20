<##############################################################################
Setup

Notes:


##############################################################################>
$workingfolder ="$env:WORKINGFOLDER\OpenStack\OpenStack-WorkingFolder"
New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
Set-Location $workingfolder

Import-Module "$env:WORKINGFOLDER\OpenStack\OpenStack" -Force

