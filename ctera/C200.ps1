Function Restart-Device {

    Measure-Command {

    Set-Location "$env:USERPROFILE\Desktop"

    $ipaddress = Read-Host "Enter device IP address"
    try{
        Test-Connection $ipaddress -Quiet -ea stop
        Write-host "$ipaddress is up" -BackgroundColor Black -ForegroundColor Green
    }
    catch{
        Write-Warning "$ipaddress is not up and running."
    }

    $cred = Get-Credential
    $credUser = $cred.UserName
    $credPassword = $cred.GetNetworkCredential().password

    $body = (Get-Content -Path ".\reboot.txt")


    $url = "http://$ipaddress/admingui/api/login?username=$credUser&password=$credPassword"
    Invoke-RestMethod -Uri $url -Method 'post' -SessionVariable websession


    Write-Warning "Attempting reboot on $ipaddress"

    $rebooturl = "http://$ipaddress/admingui/api/status/device"
    Invoke-RestMethod -Uri $rebooturl -Method 'post' -Body $body -ContentType text/xml -WebSession $websession

    Clear-Variable -Name credPassword -Scope Global

    do{
        "rebooting $ipaddress"
    }Until (!(Test-Connection $ipaddress -Quiet -Count 1))

    ping $ipaddress
    }



}
Restart-Device
