<#
Notes:
The modules to be installed are versioned to protect against future breaking changes.
This script must be run before configureServer.ps1.
#>
#Set-Location C:\Windows\System32\Sysprep
#sysprep.exe /generalize /oobe
#Update-Help

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -Force

Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Force
#Install-Module xStorage

Write-Host "You may now execute '.\configureServer.ps1'"
