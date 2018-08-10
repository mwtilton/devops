##############################################################################
#
# Main
#
##############################################################################
#Paths
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPOBackup-DemoCloud\"
$workingfolder ="$env:USERPROFILE\Desktop\WorkingFolder"

#Folders
New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
#Set-Location $workingfolder

#Modules
#Import-Module DevOps -Force
#Import-Module GroupPolicy -Force
#Import-Module ActiveDirectory -Force
#Import-Module "$env:USERPROFILE\Desktop\DevOps\DevOps" -Force

#Invoke-DevOps
