Update-Help -ErrorAction SilentlyContinue

Get-Service "Windows Search" | Set-service -StartupType Automatic | Start-Service

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Enable-PSRemoting -Force

Install-Module -Name xRemoteDesktopSessionHost -RequiredVersion 1.8.0.0 -Scope CurrentUser -Force
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Scope CurrentUser -Force
