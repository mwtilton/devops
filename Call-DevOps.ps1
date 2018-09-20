##############################################################################
#
# Main
#
##############################################################################
#Paths
$BackupPath  = "$env:USERPROFILE\Desktop\WorkingFolder\GPOBackup\"
$workingfolder ="$env:USERPROFILE\Desktop\WorkingFolder"

#Folders
New-Item -ItemType Directory $workingfolder -ea SilentlyContinue
#Set-Location $workingfolder

#Modules
#Import-Module DevOps -Force
#Import-Module GroupPolicy -Force
#Import-Module ActiveDirectory -Force
#Import-Module "$env:USERPROFILE\Documents\Github\DevOps\DevOps" -Force

#Invoke-DevOps
