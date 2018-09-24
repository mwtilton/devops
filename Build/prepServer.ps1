<#
Notes:
The modules to be installed are versioned to protect against future breaking changes.
This script must be run before configureServer.ps1.
#>
#Set-Location C:\Windows\System32\Sysprep
#.\sysprep.exe /generalize /oobe /shutdown
Update-Help -ErrorAction SilentlyContinue

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -Force

Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Force
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Force

Enable-PSRemoting -Force

Write-Host "You may now execute '.\configureServer.ps1'"
