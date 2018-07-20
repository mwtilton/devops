Function Get-Connection {

    $wbreq = Invoke-WebRequest "http://172.16.20.218/" -method get -UseBasicParsing

    return $wbreq.statuscode
}
Function Start-Connection {
    Try {
        Invoke-RestMethod -Uri "http://172.16.20.218/admingui/login.html?j_username=tilt&j_password=develop1" -ContentType application/x-www-form-urlencoded -Method POST -SessionVariable WebSession -ErrorAction stop

    }
    Catch {

        if ($_.exception.tostring().contains("404")){
            $statuscode = 404
        }
        Elseif ($_.exception.tostring().contains("500")) {
            $statuscode = 500
        }
        Else{
            Write-host $_.exception -ForegroundColor red
        }
        return $statuscode
    }
    If($statuscode -eq $null) {
        return $websession
    }
    else{

    }

}


Function Restart-Device {
    $ipaddress = "172.16.20.218"
    [xml]$rebootXML = "<obj><att id=`"type`"><val>user-defined</val></att><att id=`"name`"><val>reboot</val></att></obj>"
    [hashtable]$body = @{
        j_username = "tilt"
        j_password = "develop1"
    }

    Invoke-RestMethod -Uri "http://$ipaddress/admingui/api/login" -Body $body -ContentType "application/x-www-form-urlencoded" -Method POST -SessionVariable WebSession

    $rebooturl = "http://$ipaddress/admingui/api/status/device"
    Invoke-RestMethod -Uri $rebooturl -Method 'post' -Body $rebootXML -ContentType text/xml -WebSession $websession

    do{
        "rebooting $ipaddress"
    }Until (!(Test-Connection $ipaddress -Quiet -Count 1))

    ping $ipaddress


}
