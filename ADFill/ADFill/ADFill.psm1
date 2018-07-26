$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1
Function Start-DCExport {
    Param (
        [Parameter(Mandatory=$false)]
        [String]
        $SrceDomain,
        [Parameter(Mandatory=$false)]
        [String]
        $SrceServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )
    Write-host "Starting OU Exports" -fore Yellow
    Export-OUs -Path $path
    Write-host "Starting Group Exports" -fore Yellow
    Export-Groups -Path $Path

} # End Function

############################################################################
#Export related functions
Function Export-Groups {
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )

    $Domain = $env:USERDNSDOMAIN
    $splitDomain = $Domain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedGroups = "$path\Exported-Groups.csv"
    Get-ADGroup -Properties * -Filter * -SearchBase $searchbase |  Export-Csv -Path $exportedGroups -NoTypeInformation

    Import-Csv $exportedGroups | % {$_.name } | ft

}
Function Export-OUs {
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )

    $Domain = $env:USERDNSDOMAIN
    $splitDomain = $Domain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedOUs = "$path\Exported-OUs.csv"
    Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Export-Csv -Path $exportedOUs -NoTypeInformation
    Import-Csv $exportedOUs | % {$_.name } | ft
}

############################################################################
#Import related functions

Function Start-DCImport {
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
    Write-Host "Starting OU Import" -ForegroundColor Yellow
    Import-OUs -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath
    #Write-host "Starting Group Import" -ForegroundColor Yellow
    #Import-Groups -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath

} # End Function

Function Import-Groups {

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
        Write-Host "   [>] " -ForegroundColor DarkGray -NoNewline
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
Function Import-OUs {
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
    Write-Host $CSV -ForegroundColor Yellow
    Write-Host "[>]Checking: " -ForegroundColor DarkGray
    $csv | ForEach-Object {
        #Check if the OU exists
        #$search = "LDAP://" + $($item.GroupLocation) + "," + $($searchbase)
        #Write-Host $search
        Write-Host "   [>] Original Name: " -ForegroundColor DarkGray -NoNewline
        Write-Host $_.name -ForegroundColor White
        Write-Host "   [>] Original Path: " -ForegroundColor DarkGray -NoNewline
        Write-host $_.DistinguishedName -ForegroundColor White
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

        Write-Host "   [>] Setting Join Path: " -ForegroundColor DarkGray -NoNewline
        Write-Host $joinPath -ForegroundColor Magenta
        ForEach ($d in $ImportDomains) {
            #$NewOUPath = ($_.DistinguishedName).Replace($d.Source, $d.Destination)
            Write-Host "      [>] Replacing Source: " -ForegroundColor DarkGray -NoNewline
            Write-Host $d.Source -ForegroundColor Magenta
            $NewOUPath = $joinPath.Replace($d.Source, $d.Destination)
            Write-Host "      [>] With Destination: " -ForegroundColor DarkGray -NoNewline
            Write-Host $d.Destination -ForegroundColor Magenta
        }
        Write-Host "   [>] Setting New Path: " -ForegroundColor DarkGray -NoNewline
        Write-Host $NewOUPath -ForegroundColor Magenta
        $newOUString = @("OU=" + $_.Name + "," + $NewOUPath)
        Write-Host "   [>] Creating New OU string: " -ForegroundColor DarkGray -NoNewline
        Write-Host $newOUString -ForegroundColor DarkGreen
        #Write-Host " at " -ForegroundColor DarkGray -NoNewline
        #Write-host $NewOUPath -ForegroundColor Magenta -NoNewline
        #Check if the Group already exists

        Try {

            $checkOU = Get-ADOrganizationalUnit -Filter "Name -like '$($_.Name)'"
            Write-Host "   [>] Checking Original Path: " -ForegroundColor DarkGray -NoNewline
            Write-Host $checkOU -ForegroundColor Red
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
                Write-Host "      [-] " -ForegroundColor Red -NoNewline
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


            Write-Host "   [>] New Path: " -ForegroundColor DarkGray -NoNewline
            Write-Host $joinPath -ForegroundColor Red
            Write-Host "   [>] Checking checking if they match: " -ForegroundColor DarkGray -NoNewline
            Write-Host @($newOUString -like $checkOU) -ForegroundColor Red
            #Write-Host $_.DistinguishedName -ForegroundColor Red



            If(@($newOUString -like $checkOU)){
                Write-Host $joinPath -ForegroundColor White -NoNewline
                Write-Host " already exists! OU creation skipped!"
            }
            Else{

                New-ADOrganizationalUnit `
                    -Name $_.name `
                    -ProtectedFromAccidentalDeletion $false `
                    -Path               $NewOUPath `


                Write-Host "      [+] " -ForegroundColor DarkGreen -NoNewline
                Write-host $NewOUPath -ForegroundColor White -NoNewline
                Write-host " created!" -ForegroundColor DarkGreen
            }


        }
        Catch {

            If ($_.Exception.ToString().Contains("already exists")) {
                Write-Host "      [-] " -ForegroundColor Red -NoNewline
                Write-Host $NewOUPath -ForegroundColor White -NoNewline
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

Function Invoke-OU {

    $OU = "Admin","Executive","HR","Marketing","Ops Manager","Service Accounts","Supervisor"
    $ou | ForEach-Object {
        New-ADOrganizationalUnit -name $_ -Path "OU=DemoCloud,DC=democloud,DC=local"
    }
}


Function IsAdmin {
    [OutputType([System.Boolean])]
    Param()

    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $principal.IsInRole($admin)

}
