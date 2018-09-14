<#
Notes:
The modules to be installed are versioned to protect against future breaking changes.
This script must be run before configureServer.ps1.
#>
#Set-Location C:\Windows\System32\Sysprep
#sysprep.exe /generalize /oobe
Update-Help -ErrorAction SilentlyContinue

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -Force

Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Force
Install-Module -Name MSFT_xSmbShare -ModuleVersion 2.1.0.0
Install-Module -ModuleName StorageDsc -ModuleVersion 1.7.0.0

Enable-PSRemoting -Force

Write-Host "You may now execute '.\buildFileServer.ps1'"

<#
Get-Partition -DriveLetter 'C' | Resize-Partition -Size 32GB
New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter 'E'
Format-Volume -DriveLetter 'E' -FileSystem NTFS -NewFileSystemLabel 'Data' -Full -Force
#>
