Function Import-GPLink {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $BackupPath, # Path of the GPO GUID Folder under the main Backup Folder
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $MigTableCSVPath # Path for migration table source for automatic migtable generation
    )
    $gpm = New-Object -ComObject GPMgmt.GPM
    $Constants = $gpm.getConstants()
    $GPMBackupDir = $gpm.GetBackupDir($BackupPath)
    $GPMSearchCriteria = $gpm.CreateSearchCriteria()
    $BackupList = $GPMBackupDir.SearchBackups($GPMSearchCriteria)

    $MigTableCSV = Import-CSV $MigTableCSVPath
    $MigDomains  = $MigTableCSV | Where-Object {$_.Type -eq "Domain"}


    #Testing for new domain names
    #Write-Host "Domain: "$DestDomain "server: "$DestServer.Split(".")[1] -ForegroundColor Black -BackgroundColor Yellow

    $n = 1

    ForEach ($GPMBackup in $BackupList)
    {

        #Write-Host ($GPMBackup | ConvertTo-Json)  -ForegroundColor White
        Write-host $n -NoNewline
        Write-host " [>] GPO: " -ForegroundColor DarkGray -NoNewline
        Write-host "$($GPMBackup.GPODisplayName)`r`n" -ForegroundColor White -NoNewline

        <#
        ID             : {2DA3E56D-061C-4CB7-95D8-DCA4D023ACF5}
        GPOID          : {F9A98B0E-12A3-4A1B-AFE9-97CEB089FEBE}
        GPODomain      : FOO.COM
        GPODisplayName : Desktop Super Powers
        Timestamp      : 1/14/2014 1:55:36 PM
        Comment        : Desktop Super Powers
        BackupDir      : C:\temp\Backup\
        #>

        [xml]$GPReport = Get-Content (Join-Path -Path $GPMBackup.BackupDir -ChildPath "$($GPMBackup.ID)\gpreport.xml")

        $gPLinks = $null
        $gPLinks = $GPReport.GPO.LinksTo | Select-Object SOMName, SOMPath, Enabled, NoOverride
        # There may not be any gPLinks in the source domain.
        $newGpLinks = $gPLinks | ConvertTo-Json

        #Write-Host $newGpLinks -ForegroundColor White
        $gPLinks | ForEach-Object {

            Write-Host "    [>] SOMPath" -ForegroundColor DarkGray -NoNewline
            #Write-Host $_.SOMPath -ForegroundColor Cyan

            $SplitSOMPath = $_.SOMPath -split '/'
            [array]::Reverse($SplitSOMPath)

            $ou = @()

            For ($i=0;$i -lt $SplitSOMPath.Length;$i++)
            {
                #Write-Host $i $SplitSOMPath[$i] ($SplitSOMPath.Length - 1) -ForegroundColor Red
                $index = ($SplitSOMPath.Length - 1)
                #Write-Host ((0 -le $index) -and ($i -eq 0))
                #Write-Host (($i -eq 0) -and ($index -gt 0) -and ($i -lt 1))
                switch ($i) {

                    {(($i -eq 0) -and ($index -gt 0) -and ($i -lt 1))} {
                        $ou += "OU=" + $SplitSOMPath[$i]
                        break
                    }
                    {(($i  -ge 1) -and ($i -lt $index))} {

                        $ou += ",OU=" + $SplitSOMPath[$i]
                        break
                    }
                    {(($i -ne 0) -and ($i -eq $index))} {

                        $ou += ",DC=" + $SplitSOMPath[$i].Split(".")[0] + ",DC=" + $SplitSOMPath[$i].Split(".")[1]
                        break
                    }
                    {(($i -eq 0) -and ($i -eq $index))} {

                        $ou += "DC=" + $SplitSOMPath[$i].Split(".")[0] + ",DC=" + $SplitSOMPath[$i].Split(".")[1]
                        break
                    }
                    Default {
                        "Something else happened"
                    }
                }


            }
            $finalOU = @($OU -join "")

            ForEach ($d in $MigDomains) {
                $DomainName = $finalOU.Replace($d.Source, $d.Destination)
                $newSOMName = ($_.SOMName).Replace($d.Source, $d.Destination)
            }

            Add-Member -InputObject $_ -MemberType NoteProperty -Name gPLinkDN -Value $DomainName
            $SOMPath = $null
            Try{
                $SOMPath = Get-ADObject -Server $DestServer -Identity $_.gPLinkDN -Properties gPLink
                If($SOMPath){
                    Write-host " gPLink location " -ForegroundColor DarkGray -NoNewline
                    Write-host $($_.gPLinkDN) -ForegroundColor White -NoNewline
                    # It is possible that the policy is already linked to the destination path.
                    try {

                        New-GPLink -Domain $DestDomain -Server $DestServer `
                            -Name $GPMBackup.GPODisplayName `
                            -Target $_.gPLinkDN `
                            -LinkEnabled $(If ($_.Enabled -eq 'true') {'Yes'} Else {'No'}) `
                            -Enforced $(If ($_.NoOverride -eq 'true') {'Yes'} Else {'No'}) `
                            -Order $(If ($SOMPath.gPLink.Length -gt 1) {$SOMPath.gPLink.Split(']').Length} Else {1}) `
                            -ErrorAction Stop | Out-Null
                        # We calculated the order by counting how many gPLinks already exist.
                        # This ensures that it is always linked last in the order.
                        Write-Host " created!"
                    }
                    catch {
                        If($_.Exception.ToString().Contains("already linked")){
                            Write-Host " already exists. Skipping!" -ForegroundColor DarkGreen
                        }
                        Else{

                            Write-host $_.Exception -ForegroundColor Yellow
                        }


                    }

                }
                Else{

                }

            }
            Catch {
                If($_.Exception.ToString().Contains("Directory object not found")){
                    Write-Host "`r`n      [-] " -ForegroundColor Red -NoNewline
                    Write-host "There is an issue with the specified path. Check that the OU exists. " -ForegroundColor DarkYellow -NoNewline
                    Write-Host $_.TargetObject -ForegroundColor White
                }
                Else{
                    Write-Host $_.Exception

                }
            }
        } # End SOMPathLoop

        $n++
    } # End Foreach GPMBackup

} #End Function
