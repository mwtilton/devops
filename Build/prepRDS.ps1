Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
$RDSDSCFolder = "$env:USERPROFILE\Desktop"
New-Item -ItemType Directory -Name RDSDSC -Path $RDSDSCFolder

Update-Help -ErrorAction SilentlyContinue
#Enable-PSRemoting -Force

Install-Module -Name xRemoteDesktopSessionHost -RequiredVersion 1.8.0.0
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Force
