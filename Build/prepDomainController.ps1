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

Enable-PSRemoting -Force

Install-PackageProvider -Name NuGet -Force

Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Scope CurrentUser -Force
Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Scope CurrentUser -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Scope CurrentUser -Force
Install-Module xDnsServer -RequiredVersion 1.9.0.0 -Scope CurrentUser -Force
Install-Module xActiveDirectory -RequiredVersion 2.16.0.0 -Scope CurrentUser -Force

Write-Host "You may now execute '.\buildDomainController.ps1'"
