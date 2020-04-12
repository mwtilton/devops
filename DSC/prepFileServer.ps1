<#
Notes:
The modules to be installed are versioned to protect against future breaking changes.
This script must be run before configureServer.ps1.
#>
#Set-Location C:\Windows\System32\Sysprep
#.\sysprep.exe /generalize /oobe /shutdown
Update-Help -ErrorAction SilentlyContinue

Get-Service "Windows Search" | Set-service -StartupType Automatic | Start-Service

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Enable-PSRemoting -Force

Install-PackageProvider -Name NuGet -Force

Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Scope CurrentUser -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Scope CurrentUser -Force
Install-Module xSmbShare -RequiredVersion 2.1.0.0 -Scope CurrentUser -Force
Install-Module StorageDsc -RequiredVersion 4.1.0.0 -Scope CurrentUser -Force
Install-Module cNtfsAccessControl -RequiredVersion 1.3.1 -Scope CurrentUser -Force
Install-Module xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Scope CurrentUser -Force

Get-Partition -DriveLetter 'C' | Resize-Partition -Size 22GB
New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter 'E'
$Edrive = Get-Partition -DriveLetter 'E'
sleep 1
Format-Volume -DriveLetter $Edrive.DriveLetter -FileSystem NTFS -NewFileSystemLabel 'Data' -Force -Confirm:$false

Write-Host "You may now execute '.\buildFileServer.ps1'"
