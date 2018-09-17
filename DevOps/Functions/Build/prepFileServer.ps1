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
Install-Module xSmbShare -RequiredVersion 2.1.0.0
Install-Module StorageDsc -RequiredVersion 4.1.0.0
Install-Module cNtfsAccessControl -RequiredVersion 1.3.1
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0

Enable-PSRemoting -Force

Write-Host "You may now execute '.\buildFileServer.ps1'"

<#
Get-Partition -DriveLetter 'C' | Resize-Partition -Size 32GB
New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter 'E'
Format-Volume -DriveLetter 'E' -FileSystem NTFS -NewFileSystemLabel 'Data' -Full -Force
#>
