Function Import-OUs {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="Must be FQDN.")]
        [ValidateScript({$_ -like "*.*"})]
        [String]
        $DestDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $DestServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $CSVPath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path

    )

    $exportedOUs = "$path\Exported-OUs.csv"
    $csv      = @()
    $csv      = Import-Csv -Path $exportedOUs | select * | sort {($_.DistinguishedName).length}
    $ImportCSV = Import-CSV $CSVPath
    $ImportDomains  = $ImportCSV | Where-Object {$_.Type -eq "Domain"}
    #Write-Host $CSV -ForegroundColor Yellow
    Write-Host "[>] Checking: " -ForegroundColor DarkGray
    $csv | ForEach-Object {
        #Check if the OU exists
        #$search = "LDAP://" + $($item.GroupLocation) + "," + $($searchbase)
        #Write-Host $search
        #Write-Host "    [>] Original Name: " -ForegroundColor DarkGray -NoNewline
        Write-Host "    [>] " -ForegroundColor DarkGray -NoNewline
        Write-Host $_.name"" -ForegroundColor White -NoNewline
        #Write-Host "    [>] Original Path: " -ForegroundColor DarkGray -NoNewline
        #Write-host $_.DistinguishedName -ForegroundColor White
        #Write-Host " at path " -ForegroundColor DarkGray -NoNewline
        #Write-Host $_.DistinguishedName -ForegroundColor Red

        $SplitDistName = $_.DistinguishedName -split ','

        $newPath = @($SplitDistName.replace($SplitDistName[0], ""))
        $PathArray = @()
        For ($i=1;$i -lt $newPath.Length;$i++) {
            $index = ($newPath.Length - 1)
            #Write-Host "   "$i $newPath[$i] $index -ForegroundColor Red

            switch ($i) {

                {(($i -eq 1) -and ($index -gt 1) -and ($i -lt 2))} {
                    $PathArray += $newPath[$i]

                    break
                }
                {($i  -ge 1)} {

                    $PathArray += "," + $newPath[$i]
                    break
                }

                Default {
                    "Something else happened"
                }
            }

        }

        $joinPath = $PathArray -join ""

        #Write-Host "    [>] Setting Join Path: " -ForegroundColor DarkGray -NoNewline
        #Write-Host $joinPath -ForegroundColor Magenta
        ForEach ($d in $ImportDomains) {
            #$NewOUPath = ($_.DistinguishedName).Replace($d.Source, $d.Destination)

            #Write-Host "      [>] Replacing Source: " -ForegroundColor DarkGray -NoNewline
            #Write-Host $d.Source -ForegroundColor Magenta
            $NewOUPath = $joinPath.Replace($d.Source, $d.Destination)
            #Write-Host "      [>] With Destination: " -ForegroundColor DarkGray -NoNewline
            #Write-Host $d.Destination -ForegroundColor Magenta
            $newName = ($_.name).Replace($d.Source, $d.Destination)
        }
        #Write-Host "    [>] Setting New Path: " -ForegroundColor DarkGray -NoNewline
        #Write-Host $NewOUPath -ForegroundColor Magenta
        #Write-Host "    [>] Setting New Name for OU: " -ForegroundColor DarkGray -NoNewline
        #Write-Host $newName -ForegroundColor DarkGreen
        $newOUString = @("OU=" + $newName + "," + $NewOUPath)
        #Write-Host "    [>] Creating New OU string: " -ForegroundColor DarkGray -NoNewline
        #Write-Host $newOUString -ForegroundColor DarkGreen
        #Write-Host " at " -ForegroundColor DarkGray -NoNewline
        #Write-host $NewOUPath -ForegroundColor Magenta -NoNewline
        #Check if the Group already exists

        Try {

            $checkOU = Get-ADOrganizationalUnit -Filter "Name -like '$newName'"
            #Write-Host "    [>] Checking Original Path: " -ForegroundColor DarkGray -NoNewline
            #Write-Host $checkOU -ForegroundColor Red
            #Write-Host $checkOU -ForegroundColor White -NoNewline
        }
        Catch {
            If ($_.CategoryInfo.ToString().Contains('ObjectNotFound')) {
                Write-host ""
                Write-Host "      [+] " -NoNewline
                Write-Host $_.CategoryInfo -ForegroundColor White
            }

            elseif ($_.Exception.ToString().Contains("Directory object not found")) {
                Write-host " "
                Write-Host "        [-] " -ForegroundColor Red -NoNewline
                Write-host "There is an issue with the specified path. Check that the OU exists. " -ForegroundColor DarkYellow -NoNewline
                Write-Host $_.TargetObject -ForegroundColor White
            }

            Else {
                Write-Warning "An OU check error occurred:"
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }
        }

        Try{


            #Write-Host "    [>] New Path: " -ForegroundColor DarkGray -NoNewline
            #Write-Host $NewOUPath -ForegroundColor Red
            #Write-Host "    [>] Checking checking if they match: " -ForegroundColor DarkGray -NoNewline
            #Write-Host @($newOUString -like $checkOU) -ForegroundColor Red
            #Write-Host $newOUString -ForegroundColor Red



            If($newOUString -eq $checkOU){
                #Write-Host "    [+]" -ForegroundColor DarkGreen -NoNewline
                Write-Host $newOUString -ForegroundColor DarkGreen -NoNewline
                Write-Host " already exists! OU creation skipped!"
            }
            Else{

                New-ADOrganizationalUnit `
                    -Name $newName `
                    -ProtectedFromAccidentalDeletion $false `
                    -Path $NewOUPath `


                Write-Host "`r`n        [+] " -NoNewline
                Write-host $newOUString -ForegroundColor White -NoNewline
                Write-host " created!"
            }


        }
        Catch {

            If ($_.Exception.ToString().Contains("already exists")) {
                Write-Host "`r`n      [-] " -ForegroundColor Red -NoNewline
                Write-Host $newOUString -ForegroundColor White -NoNewline
                Write-Host " wasn't created and raised an exception! `r`n`t`tThere is an issue with the OU pathing. OU creation skipped!" -ForegroundColor Yellow

            }
            elseif ($_.Exception.ToString().Contains("Directory object not found")) {
                Write-Host "      [-] " -ForegroundColor Red -NoNewline
                Write-host "There is an issue with the specified path. Check that the OU exists. " -ForegroundColor DarkYellow -NoNewline
                Write-Host $_.TargetObject -ForegroundColor White
            }
            Else {
                Write-Host ""
                Write-Warning "An import error occurred:"
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }

        }
    }
}
