Function Import-GPPermission {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
        [String[]]
        $DisplayName,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $MigTablePath
    )

    $MigTable = Show-GPOMigrationTable -Path $MigTablePath |
        Select-Object *, `
            @{name='SourceName';expression={($_.Source -split '@')[0]}}, `
            @{name='SourceDomain';expression={($_.Source -split '@')[1]}}, `
            @{name='DestinationName';expression={($_.Destination -split '@')[0]}}, `
            @{name='DestinationDomain';expression={($_.Destination -split '@')[1]}}

    $GPO_ACEs_CSV = Import-Csv $Path |
        Select-Object *, `
            @{name='IDName';expression={($_.IdentityReference -split '\\')[-1]}}, `
            @{name='IDDomain';expression={($_.IdentityReference -split '\\')[0]}}


    ForEach ($Name in $DisplayName) {

        Write-host "  [+] Importing GPO Permissions: " -NoNewline
        Write-host $Name -ForegroundColor White

        $GPO = Get-GPO -Domain $DestDomain -Server $DestServer -DisplayName $Name

        ForEach ($ACE in ($GPO_ACEs_CSV | Where-Object {$_.Name -eq $Name})) {

            Write-host "     [>]" -ForegroundColor DarkGray -NoNewline
            Write-host "Setting " -ForegroundColor DarkGray -NoNewline
            Write-host $($ACE.IDName) -ForegroundColor White -NoNewline
            Write-Host " GPO permission for " -NoNewline
            Write-host $Name -ForegroundColor White

            # Find the CSV ACE identity name in the MigTable
            # Possible zero or one matches, should not be multiple
            $MigID = $MigTable | Where-Object {$_.SourceName -eq $ACE.IDName}

            # If entry, then attempt to set it
            If ($MigID) {
                # Find the AD object based on the type listed in the MigTable
                $ADObject = $null

                Try {
                    Switch ($MigID.Type) {
                        'Unkown'          {$ADObject = $null; break}
                        'User'            {$ADObject = Get-ADUser -Identity $MigID.DestinationName -Server $MigID.DestinationDomain; break}
                        'Computer'        {$ADObject = Get-ADComputer -Identity $ACE.IDName -Server $DestDomain; <# Special handling #>; break}
                        'GlobalGroup'     {$ADObject = Get-ADGroup -Identity $MigID.DestinationName -Server $MigID.DestinationDomain; break}
                        'LocalGroup'      {$ADObject = Get-ADGroup -Identity $MigID.DestinationName -Server $MigID.DestinationDomain; break}
                        'UniversalGroup'  {$ADObject = Get-ADGroup -Identity $MigID.DestinationName -Server "$($MigID.DestinationDomain):3268"; break}
                        'Free Text or SID' {"found free text"}
                        Default           {$ADObject = $null; break}
                    }

                }
                Catch {
                    # AD object not found. Warning written below.
                    $_ | fl * -force
                    $_.InvocationInfo.BoundParameters | fl * -force
                    $_.Exception
                }
                Try{
                    Write-Host "        [+] ADObject found for " -ForegroundColor DarkGreen -NoNewline
                    Write-host $($ADObject.Name) -ForegroundColor White -NoNewline
                    Write-Host " Writing permission." -ForegroundColor DarkGreen

                    # Same effect as using Get-ACL "AD:\..."
                    $acl = $GPO | Select-Object -ExpandProperty Path | Get-ADObject -Properties NTSecurityDescriptor | Select-Object -ExpandProperty NTSecurityDescriptor

                    $ObjectType = [GUID]$($ACE.ObjectType)
                    $InheritedObjectType = [GUID]$($ACE.InheritedObjectType)
                    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                        $ADObject.SID, $ACE.ActiveDirectoryRights, $ACE.AccessControlType, $ObjectType, `
                        $ACE.InheritanceType, $InheritedObjectType
                    $acl.AddAccessRule($ace)

                    # Commit the ACL
                    Set-Acl -Path "AD:\$($GPO.Path)" -AclObject $acl
                }
                Catch {
                    Write-Host "        [-] ADObject not found. ACE not set for: " -ForegroundColor Red
                    Write-Host "            [>]" -ForegroundColor DarkGray -NoNewline
                    Write-host $($ACE.IDName) -ForegroundColor White
                    Write-Host "            [>]" -ForegroundColor DarkGray -NoNewline
                    Write-Host  $Name -ForegroundColor White
                    $_ | fl * -force
                    $_.InvocationInfo.BoundParameters | fl * -force
                    $_.Exception
                }

            }
            Else {
            # Else, attempt to set without migration table translation (ie. CREATOR OWNER, etc.)

                #Write-host "        [=] Setting ACE without migration table translation: " -ForegroundColor Yellow
                #Write-host "       [>] $Name" -ForegroundColor DarkGray -NoNewline
                #Write-host ""$($ACE.IDName) -ForegroundColor White


                $sid = $null
                Try {
                    $sid = (New-Object System.Security.Principal.NTAccount($ACE.IDName)).Translate([System.Security.Principal.SecurityIdentifier])
                }
                Catch {
                    Write-Warning "Error.  Cannot set: '$($ACE.IDName)' on '$Name'"
                }
                Try {
                    If ($sid) {

                        # Same effect as using Get-ACL "AD:\..."
                        $acl = $GPO | Select-Object -ExpandProperty Path | Get-ADObject -Properties NTSecurityDescriptor | Select-Object -ExpandProperty NTSecurityDescriptor

                        $ObjectType = [GUID]$($ACE.ObjectType)
                        $InheritedObjectType = [GUID]$($ACE.InheritedObjectType)
                        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                            $sid, $ACE.ActiveDirectoryRights, $ACE.AccessControlType, $ObjectType, `
                            $ACE.InheritanceType, $InheritedObjectType
                        $acl.AddAccessRule($ace)

                        # Commit the ACL
                        Set-Acl -Path "AD:\$($GPO.Path)" -AclObject $acl
                    }
                    Else{

                    }
                }
                Catch {
                    $_ | fl * -force
                    $_.InvocationInfo.BoundParameters | fl * -force
                    $_.Exception
                }


            }

        } # End ForEach ACE
        # Force the ACL changes to SYSVOL
        $GPO.MakeAclConsistent()
    } # End ForEach DisplayName
} # End Function
