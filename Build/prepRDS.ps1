Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Update-Help -ErrorAction SilentlyContinue

Enable-PSRemoting -Force

Install-Module -Name xRemoteDesktopSessionHost -RequiredVersion 1.8.0.0 -Force
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Force
