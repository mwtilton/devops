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
    Write-host "Starting Group Exports" -fore Yellow
    Export-Groups -Path $Path
    Write-host "Starting OU Exports" -fore Yellow
    Export-OUs -Path $path
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
    Write-host "Starting DC Import" -ForegroundColor Yellow
    Write-host "Starting Group Import" -ForegroundColor Yellow
    Import-Groups -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath
    Write-Host "Starting OU Import" -ForegroundColor Yellow
    Import-OUs -Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath
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
        #Write-Host $joinPath.Replace("LandGraphics", $DestDomain.Split(".")[0])

        ForEach ($d in $ImportDomains) {
            $DomainName = $joinPath.Replace($d.Source, $d.Destination)
        }
        #Write-Host $DomainName -ForegroundColor Red -NoNewline
        #Check if the Group already exists

        Try
        {

            $checkGroup = Get-ADGroup $_.Name
            #Write-Host $checkGroup -ForegroundColor White -NoNewline
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
            #New-ADGroup -Name $_.name -GroupScope $_.GroupType -Path $DomainName
            #Write-Host $checkGroup -ForegroundColor Red
            #Write-Host $_.DistinguishedName -ForegroundColor Red

            #Write-Host @($DomainName -like $checkGroup) -ForegroundColor Red
            <#
            If(@($DomainName -like $checkGroup)){
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
                -Path               $DomainName `
                -Description        $_.Description

            Write-Host "      [+] " -ForegroundColor DarkGreen -NoNewline
            Write-host $_.name -ForegroundColor White -NoNewline
            Write-host " created!" -ForegroundColor DarkGreen



        }
        Catch{

            If ($_.Exception.ToString().Contains("already exists")) {
                Write-Host " already exists! Group creation skipped!"

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
    $csv      = Import-Csv -Path $exportedOUs
    $ImportCSV = Import-CSV $CSVPath
    $ImportDomains  = $ImportCSV | Where-Object {$_.Type -eq "Domain"}

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
        #Write-Host $joinPath.Replace("LandGraphics", $DestDomain.Split(".")[0])

        ForEach ($d in $ImportDomains) {
            $DomainName = $joinPath.Replace($d.Source, $d.Destination)
        }
        #Write-Host $DomainName -ForegroundColor Red -NoNewline
        #Check if the Group already exists
        <#
        Try
        {

            $checkGroup = Get-ADGroup $_.Name
            #Write-Host $checkGroup -ForegroundColor White -NoNewline
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
            #New-ADGroup -Name $_.name -GroupScope $_.GroupType -Path $DomainName
            #Write-Host $checkGroup -ForegroundColor Red
            #Write-Host $_.DistinguishedName -ForegroundColor Red

            #Write-Host @($DomainName -like $checkGroup) -ForegroundColor Red

            If(@($DomainName -like $checkGroup)){
                Write-Host $joinPath -ForegroundColor White -NoNewline
                Write-Host " already exists! Group creation skipped!"
            }
            Else{

            New-ADGroup `
                -Name $_.name `
                -SamAccountName     $_.SamAccountName `
                -GroupCategory      $_.GroupCategory `
                -GroupScope         $_.GroupScope `
                -DisplayName        $_.DisplayName `
                -Path               $DomainName `
                -Description        $_.Description

            Write-Host "      [+] " -ForegroundColor DarkGreen -NoNewline
            Write-host $_.name -ForegroundColor White -NoNewline
            Write-host " created!" -ForegroundColor DarkGreen



        }
        Catch{

            If ($_.Exception.ToString().Contains("already exists")) {
                Write-Host " already exists! Group creation skipped!"

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
