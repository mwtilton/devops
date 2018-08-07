<##############################################################################
Setup

Notes:
##############################################################################>
#$workingfolder ="$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack-WorkingFolder"
#New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
#Set-Location $workingfolder

Import-Module "$env:WORKINGFOLDER\DevOps\OpenStack\OpenStack" -Force
#$path = "$env:USERPROFILE\Documents\Tilt-openrc.txt"
$path = "$env:USERPROFILE\Documents\Tilt_ZeroStack_v3rc.txt"

#Start-OpenStack -DestServer $OpenStackInfo.Compute
Set-OpenRC $Path
