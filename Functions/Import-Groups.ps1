
Function Import-Groups {
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

    $exportedGroups = "$path\Exported-Groups.csv"
    $csv      = @()
    $csv      = Import-Csv -Path $exportedGroups
    $ImportCSV = Import-CSV $CSVPath
    $ImportDomains  = $ImportCSV | Where-Object {$_.Type -eq "Domain"}

    #Get Domain Base
    <#
    $searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }

    Write-Host $searchbase
    #Loop through all items in the CSV
    ForEach ($item In $csv)
    #>
    Write-Host "[>]Checking: " -ForegroundColor DarkGray
    $csv | ForEach-Object {
        #Check if the OU exists
        #$search = "LDAP://" + $($item.GroupLocation) + "," + $($searchbase)
        #Write-Host $search
        Write-Host "    [>] " -ForegroundColor DarkGray -NoNewline
        Write-Host $_.name -ForegroundColor White -NoNewline
        #Write-Host " at path " -ForegroundColor DarkGray -NoNewline
        #Write-Host $_.DistinguishedName -ForegroundColor White

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


        ForEach ($d in $ImportDomains) {
            $NewOUPath = $joinPath.Replace($d.Source, $d.Destination)
        }
        #Write-Host $NewOUPath -ForegroundColor Red -NoNewline
        #Check if the Group already exists

        Try
        {

            $checkOU = Get-ADGroup $_.Name
            #Write-Host $checkOU -ForegroundColor White -NoNewline
        }
        Catch
        {
            If ($_.CategoryInfo.ToString().Contains('ObjectNotFound')) {
                Write-host ""
                Write-Host "      [+] " -NoNewline
                Write-Host $_.CategoryInfo -ForegroundColor White
            }
            Else {
                Write-Warning "A group check error occurred:"
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }
        }

        Try{
            #Create the group if it doesn't exist
            #New-ADGroup -Name $_.name -GroupScope $_.GroupType -Path $NewOUPath
            #Write-Host $checkOU -ForegroundColor Red
            #Write-Host $_.DistinguishedName -ForegroundColor Red

            #Write-Host @($NewOUPath -like $checkOU) -ForegroundColor Red
            <#
            If(@($NewOUPath -like $checkOU)){
                Write-Host $joinPath -ForegroundColor White -NoNewline
                Write-Host " already exists! Group creation skipped!"
            }
            Else{
            #>
            New-ADGroup `
                -Name $_.name `
                -SamAccountName     $_.SamAccountName `
                -GroupCategory      $_.GroupCategory `
                -GroupScope         $_.GroupScope `
                -DisplayName        $_.DisplayName `
                -Path               $NewOUPath `
                -Description        $_.Description

            Write-Host "      [+] " -ForegroundColor DarkGreen -NoNewline
            Write-host $NewOUPath -ForegroundColor White -NoNewline
            Write-host " created!" -ForegroundColor DarkGreen



        }
        Catch{

            If ($_.Exception.ToString().Contains("already exists")) {
                Write-Host " already exists! Group creation skipped!"

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

        #>
    }


}
