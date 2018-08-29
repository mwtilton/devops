Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-Module -Name xRemoteDesktopSessionHost
