Get-DscConfigurationStatus -all | fl

Get-WinEvent -LogName "*DSC*" | ? {$_.leveldisplayname -notlike "*information*"} | Sort-Object -Property TimeCreated | fl | Out-File $env:USERPROFILE\Desktop\dsc.log -Force
