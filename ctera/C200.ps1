
. ".\C200.Machine.ps1"
$loginurl = $urls.loginurl
$rebooturl = $urls.rebooturl
Function Get-Connection {

    $wbreq = Invoke-WebRequest $devserverinfo.ipaddress -method get -UseBasicParsing

    return $wbreq.statuscode
}
Function Start-Connection {

    Try {
        Invoke-RestMethod -Uri $loginurl -ContentType application/x-www-form-urlencoded -Method POST -SessionVariable WebSession -ErrorAction stop

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

    [xml]$rebootXML = "<obj><att id=`"type`"><val>user-defined</val></att><att id=`"name`"><val>reboot</val></att></obj>"
    [hashtable]$body = @{
        j_username = $devserverinfo.j_username
        j_password = $devserverinfo.j_password
    }

    #login
    Invoke-RestMethod -Uri $loginurl -Body $body -ContentType "application/x-www-form-urlencoded" -Method POST -SessionVariable WebSession

    #reboot
    Invoke-RestMethod -Uri $rebooturl -Method 'post' -Body $rebootXML -ContentType text/xml -WebSession $websession

    do{
        "rebooting " + $devserverinfo.ipaddress
    }Until (!(Test-Connection $devserverinfo.ipaddress -Quiet -Count 1))

    ping $devserverinfo.ipaddress


}
