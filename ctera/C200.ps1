Function Start-Connection {
    Try {
        Invoke-RestMethod -Uri "" -ContentType application/x-www-form-urlencoded -Method POST -SessionVariable WebSession
    }
    Catch {
        If($_.exception.tostring().contains("200")){
            $statuscode = 404
        }
        Elseif ($_.exception.tostring().contains("404")){
            $statuscode = 404
        }
        Elseif ($_.exception.tostring().contains("500")) {
            $statuscode = 500
        }
        Else{
            Write-host $_.exception -ForegroundColor red
        }
    }
    return $statuscode

}
Function Get-Connection {

    $wbreq = Invoke-WebRequest "" -method get -UseBasicParsing

    return $wbreq.statuscode
}

Function Restart-Device {

    $rebootXML = "<obj><att id=`"type`"><val>user-defined</val></att><att id=`"name`"><val>reboot</val></att></obj>"






    <#
    Invoke-RestMethod `

            -Method 'post'`
            -SessionVariable websession


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
    #>


}
