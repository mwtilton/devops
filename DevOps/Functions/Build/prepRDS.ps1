Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
$RDSDSCFolder = "$env:USERPROFILE\Desktop"
New-Item -ItemType Directory -Name RDSDSC -Path $RDSDSCFolder
Install-Module -Name xRemoteDesktopSessionHost
