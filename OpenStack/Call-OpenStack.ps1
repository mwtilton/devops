<##############################################################################
Setup

Notes:
##############################################################################>
$workingfolder ="$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack-WorkingFolder"
New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
Set-Location $workingfolder

Import-Module "$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack" -Force -Verbose

Start-OpenStack -DestServer $OpenStackInfo.Compute
