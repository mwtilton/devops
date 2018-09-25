Function Import-SharesACL {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$csv,
        [parameter(Mandatory=$true)][string]$MigTableCSVPath
    )
    $MigTableCSV = Import-CSV $MigTableCSVPath
    $MigDomains  = $MigTableCSV | Where-Object {$_.Type -eq "Domain"}

    $importCSV = Import-CSV $csv | ? {$_.path -notlike "*c:\*"}
    $importCSV | Foreach-object {
        Write-host "  [>] Checking " -ForegroundColor DarkGray -NoNewline
        Write-host $_.path -ForegroundColor White
        Try{
            Resolve-Path $_.path -erroraction stop | Out-null
        }
        Catch{
            Write-host "RP error" -foregrouncolor Red
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
        }
        Write-host "    [>] Changing Domain for " -ForegroundColor DarkGray -NoNewline
        Write-host $_.IdentityReference -ForegroundColor White -NoNewline
        Write-host " to " -ForegroundColor DarkGray -NoNewline


        ForEach ($d in $MigDomains) {
            $UserName = ($_.IdentityReference).Replace($d.Source, $d.Destination)
        }

        Write-Host $UserName -ForegroundColor White

        Try{
            $Acl = Get-Acl $_.path
            #$acl.Access
            Write-host "    [+] " -NoNewline
            Write-host "Acl " -ForegroundColor DarkGreen -NoNewline
            Write-host $newFullControl -ForegroundColor White -NoNewline
            Write-host " has been collected!" -ForegroundColor DarkGreen
        }
        Catch{
            Write-host "Get-Acl error" -foregroundcolor Red
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
        }

        Try{
            $value = 268435456
            If($_.FileSystemRights -eq $value){
                $newFullControl = ($_.FileSystemRights).Replace("$value","FullControl")
            }
            Else{
                $newFullControl = $_.FileSystemRights
            }

            #Write-host "Identity --- "$newFullControl
            #Write-host @($UserName, $newFullControl, "$($_.InheritanceFlags)", "$($_.PropagationFlags)", "$($_.AccessControl)") -ForegroundColor Cyan
            #$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($username, "$($_.FileSystemRights)","$($_.InheritanceFlags)", "$($_.PropagationFlags)", "$($_.AccessControlType)")


            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($username, $newFullControl,$_.InheritanceFlags, $_.PropagationFlags, $_.AccessControlType)
            $Acl.SetAccessRule($Ar)
            Write-host "    [+] " -NoNewline
            Write-host "Acl " -ForegroundColor DarkGreen -NoNewline
            Write-host $newFullControl -ForegroundColor White -NoNewline
            Write-host " has been set!" -ForegroundColor DarkGreen
        }
        Catch{
            If($_.Exception.ToString().contains("Some or all identity")){
                Write-host "    [-]" -fore red -NoNewline
                Write-host "This is probably due to the invalid username " -ForegroundColor DarkYellow -nonewline
                Write-host $username -ForegroundColor White -NoNewline
                Write-host " which does not exist on the domain." -ForegroundColor DarkYellow
                Write-host "    It looks like an individual user account and should not be applied to a folder permission" -ForegroundColor DarkYellow
            }
            Else{
                Write-host "New-Object error" -foregroundcolor Red
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }

        }
        Try{
            Set-ACL -path $_.path -AclObject $Acl -ErrorAction Stop
        }
        Catch{
            Write-host "Set acl error" -ForegroundColor Red
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
        }
        <#
        Try{
            Write-host "    [>] Checking" -ForegroundColor DarkGray -NoNewline
            $finalACL = Get-Acl $_.path
            $finalACL.Access
        }
        Catch{
            Write-host "Get acl error" -ForegroundColor Red
            $_ | fl * -force
            $_.InvocationInfo.BoundParameters | fl * -force
            $_.Exception
        }
        #>

    }

}
