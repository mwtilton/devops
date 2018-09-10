Get-DscConfigurationStatus -all | fl

Get-WinEvent -LogName "*DSC*" | ? {$_.leveldisplayname -notlike "*information*"} | Sort-Object -Property TimeCreated | fl | Out-File $env:USERPROFILE\Desktop\dsc.log -Force

<#
New-Item -ItemType Directory -Path C:\logs -ErrorAction SilentlyContinue
(Get-WinEvent -ListLog *desired*,*dsc*).LogName |
Where-Object {$_ -notlike "*admin*"} |
ForEach-Object {
    wevtutil export-log /overwrite:true $_ "C:\logs\$($env:COMPUTERNAME)_$($_.Replace('/','-')).evtx"
}
'System','Application' | ForEach-Object {
    wevtutil export-log /overwrite:true $_ "C:\logs\$($env:COMPUTERNAME)_$($_).evtx"
}
If ((Get-WindowsFeature DSC-Service).Installed) {
    Get-ChildItem 'C:\Program Files\WindowsPowerShell\DscService' > C:\logs\DscService.txt
    Copy-Item -Path 'C:\inetpub\wwwroot\PSDSCPullServer\web.config' -Destination C:\logs
}
$PSVersionTable > C:\logs\PSVersionTable.txt
Compress-Archive -Path C:\logs\*.evtx,C:\logs\*.config,C:\logs\*.txt `
    -DestinationPath "C:\logs\$($env:COMPUTERNAME)_DSC_Logs.zip" -Update
#>

function Get-DSCConfig{
    Param($computer=$env:COMPUTERNAME)

    Get-CimClass -cn $computer MSFT_DSCMetaConfiguration -name root/Microsoft/Windows/DesiredStateConfiguration|
        Select-Object -ExpandProperty CimClassProperties
}

Get-DSCConfig omega | select name


# Servers with desktop experience
$servers = (Get-ADComputer -properties OperatingSystem -F {OperatingSystem -like "*Server*"}|select -exp Name)
$Servers|%{ Import-module servermanager ; $inst = ((Get-WindowsFeature -ComputerName $_ -name desktop-experience).Installed); if($inst) { write-host "Installed on $_" } }
