#"C:\Users\Administrator\Desktop\DefaultGPO.xml"
Get-GPO -all | % {$GPOPath = "C:\GPOBackup\" + $_.DisplayName
if (!(test-path $GPOPath)){
    New-Item -ItemType Directory -Path $GPOPath
}
Backup-GPO -name $_.DisplayName -Path $GPOPath}

