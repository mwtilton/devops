#Fatal Error Handling
Try{
    If($_.Exception.ToString().Contains("something")){
        Write-Host " already exists. Skipping!" -ForegroundColor DarkGreen
    }
    Else{

        Write-host $_.Exception -ForegroundColor Yellow
    }
}
Catch{
    $_ | fl * -force
    $_.InvocationInfo.BoundParameters | fl * -force
    $_.Exception
}

#one line error thrower
if ($?) {throw}

#runAs Admin stuffs
#R equires -RunAsAdministrator
