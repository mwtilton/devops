Function Update-VMHost
(
    [Parameter(Mandatory=$True,Position=0)][String]$VMHost,
    [Parameter(Mandatory=$False,Position=1)][String]$UpdateProfile='ESXi-5.5.0-20170904001-standard',
    [Parameter(Mandatory=$False,Position=2)][String]$TargetBuild='6480324'
)
{
    #Get Start time, VM host object and EsxCli object for host
    $StartTime = Get-Date
    $VMHostObj = Get-VMHost $VMHost -ErrorAction Stop
    $EsxCli = Get-EsxCli -VMHost $VMHost  -V2 -ErrorAction Stop
    
    #Check Update revision of host, abort if same revision or higher    
    If ($VMHostObj.Build -lt $TargetBuild)
    {
        Write-host -ForegroundColor Cyan ($VMHostObj.Name + " needs to be updated (Target: " + $VMHostObj.Build + " Installed: " + $TargetBuild + ")")
    }
    else
    {
        Write-host -ForegroundColor Yellow ($VMHostObj.Name + " is already on the target build revision or newer - Aborting (Target: " + $VMHostObj.Build + " Installed: " + $TargetBuild + ")")
        Return
    }
    
    #Check if host in maintenance mode, place in maintenance mode if not
    If ($VMHostObj.ConnectionState -NE 'Maintenance')
    {
        write-host -ForegroundColor Cyan "Placing host $VMHost in to maintenance mode"
        $Null = If ((Set-VMHost -VMHost $VMHostObj -State Maintenance).ConnectionState -eq "Maintenance")
        {
            Write-Host -foregroundcolor Green "Host has entered maintenance mode"
        }
        else
        {
            Write-Host -foregroundcolor Red "Host has failed to enter Maintenance Mode. Check status and place in Maintenance Mode manually."
            Return
        }
    }
    else
    {
        write-host -ForegroundColor Yellow "Host $VMHost is already in maintenance mode, proceeding with update."
    }

    #Capture narrower EsxCli object, create argument set for firewall, populate arguments
    $FWRules = $EsxCli.network.firewall.ruleset
    $FWArgs = $FWRules.set.CreateArgs()
    $FWArgs.enabled = $True
    $FWArgs.rulesetid = 'httpClient'
    #Enable http firewall rule and check for success
    If ($FWRules.set.invoke($FWArgs))
    {
        write-host -foregroundcolor Green "Firewall rule enabled"
    }
    else
    {
        write-host -foregroundcolor red "Failed to enable firewall rule"
        return
    }

    #Create update argument set and populate with correct profile from parameters
    $UpdateArgs = $EsxCli.software.profile.update.createargs()
    $UpdateArgs.depot = 'https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml'
    $UpdateArgs.profile = $UpdateProfile
    #Invoke update and capture return for verification
    Write-Host -foregroundcolor Cyan "Beginning update on host $VMHost"
    $UpdateReturn = $EsxCli.software.profile.update.invoke($UpdateArgs)
    
    #Update Firewall args, disable http rule, check for success
    $FWArgs.enabled = $False
    If ($FWRules.set.invoke($FWArgs))
    {
        write-host -foregroundcolor Green "Firewall rule disabled"
    }
    else
    {
        write-host -foregroundcolor red "Failed to disable firewall rule"
        return
    }

    #Process UpdateReturn message - if successful, restart host
    if ($UpdateReturn.Message -eq "The update completed successfully, but the system needs to be rebooted for the changes to be effective."`
    -or $UpdateReturn.Message -eq "Host is not changed.")
    {
        write-host -ForegroundColor Green "Update completed on $VMHost - Restarting host..."
        $Null = Restart-VMHost -VMHost $VMHostObj -Confirm:$False
    }
    else
    {
        write-host -ForegroundColor Red "Update failed for $VMHost - Aborting..."
        Return
    }

    #Wait for up to 900 seconds for host to reboot
    $Timeout = (get-date).addseconds(900)
    Write-Host -ForegroundColor Cyan "Waiting for host $VMHost to restart for up to 900 seconds..."
    While ((Get-VMHost -Name $VMHost | Get-View).summary.runtime.boottime -lt $StartTime -and (get-date) -lt $Timeout)
    {
        Write-Progress -Activity "Waiting for host reboot" -PercentComplete (100+"{0:N0}" -f (((get-date)-$Timeout).TotalSeconds/9))
        start-sleep -seconds 10      
    }
    Write-Progress -Activity "Waiting for host reboot" -Completed

    #Get an updated copy of VMHost object
    $VMHostObj = Get-VMHost $VMHost -ErrorAction Stop

    #Verify host has rebooted by comparing host boot time to StartTime
    If (($VMHostObj | Get-View).summary.runtime.boottime -gt $StartTime)
    {
        Write-Host -ForegroundColor Green "Host has restarted, removing from maintenance mode"
    }
    else
    {
        Write-Host -ForegroundColor Red "Host has not restarted within the timeout period. Check host status manually."
        Return
    }

    #Remove host from maintenance mode
    $null = If ((Set-VMHost -VMHost $VMHostObj -State Connected).ConnectionState -eq "Connected")
    {
        Write-Host -foregroundcolor Green "Host has exited maintenance mode"
    }
    else
    {
        Write-Host -foregroundcolor Red "Host has failed to exit maintenance mode after update/reboot. Check status manually."
        Return
    }

    #Verify host build matches expected version
    If ($VMHostObj.Build -eq $TargetBuild)
    {
        Write-host -ForegroundColor Cyan ($VMHostObj.Name + " has been successfully updated (Target: " + $TargetBuild + " Installed: " + $VMHostObj.Build + ")")
    }
    else
    {
        Write-host -ForegroundColor Red (($VMHostObj.Name + " has been failed it's update (Target: " + $TargetBuild + " Installed: " + $VMHostObj.Build + ")"))
        Return
    }
    
    ((get-date)-$StartTime) | % {Write-Host -ForegroundColor Green ("Update completed in {0:hh}:{0:mm}:{0:ss} for host $VMHost" -f $_)}
}



