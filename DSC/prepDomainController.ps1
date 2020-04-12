<# Notes:
Goal - Prepare the server by connecting to the gallery,
installing the package provider, and installing the modules
required by the configuration.  Note that the modules to be installed
are versioned to protect against future breaking changes.

This script must be run before configureServer.ps1.

Disclaimer - This example code is provided without copyright and AS IS.
It is free for you to use and modify.

#>
Update-Help -ErrorAction SilentlyContinue

Get-Service "Windows Search" | Set-service -StartupType Automatic | Start-Service

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

#Enable-PSRemoting -Force

Install-PackageProvider -Name NuGet -Force

Install-Module ComputerManagementDsc -RequiredVersion 5.2.0.0
Install-Module NetworkingDSC -RequiredVersion 6.1.0.0
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0
Install-Module StorageDsc -RequiredVersion 4.1.0.0
Install-Module xSmbShare -RequiredVersion 2.1.0.0
Install-Module cNtfsAccessControl -RequiredVersion 1.3.1
Install-Module xActiveDirectory -RequiredVersion 2.21.0.0
Install-Module xDnsServer -RequiredVersion 1.11.0.0

Write-Host "You may now execute '.\buildDomainController.ps1'"
