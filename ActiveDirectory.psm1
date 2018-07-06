$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1
Function Start-DCExport {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $SrceDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $SrceServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path  # Working path to store files
    )
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
        $Path
        
    )
    Write-host "Starting DC Import" -fore Yellow
    Import-Groups -Path $Path -DestDomain $DestDomain -DestServer $DestServer

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
        $Path
        
    )
    
    $exportedGroups = "$path\Exported-Groups.csv"
    $csv      = @()
    $csv      = Import-Csv -Path $exportedGroups
    
    
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
        Write-Host "   [>]" -ForegroundColor DarkGray -NoNewline
        Write-Host $_.name -ForegroundColor White -NoNewline
        Write-Host " at path " -ForegroundColor DarkGray -NoNewline
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

        $joinPath = @($PathArray -join "")
        Write-Host $joinPath -ForegroundColor White
        
        #Check if the Group already exists
        Try
        {
            Get-ADGroup $_.Name | Out-Null
            Write-Host "      [--]" -ForegroundColor Yellow -NoNewline
            Write-host $_.Name -ForegroundColor White -NoNewline
            Write-Host " already exists! Group creation skipped!" -ForegroundColor Yellow
        }
        Catch
        {
            If ($_.CategoryInfo.ToString().Contains('ObjectNotFound')) {
                
                Write-Host "      [>]" -NoNewline
                Write-Host $_.CategoryInfo -ForegroundColor White
            } 
            Else {
                "An import error occurred:"
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }
        }
        
        Try{
            #Create the group if it doesn't exist
            #New-ADGroup -Name $_.name -GroupScope $_.GroupType -Path $_.DistinguishedName
            
            New-ADGroup `
                -Name $_.name `
                -SamAccountName     $_.SamAccountName `
                -GroupCategory      $_.GroupCategory `
                -GroupScope         $_.GroupScope `
                -DisplayName        $_.DisplayName `
                -Path               $joinPath `
                -Description        $_.Description

            Write-Host "      [+]" -ForegroundColor DarkGreen -NoNewline
            Write-host $_.name -ForegroundColor White -NoNewline
            Write-host " created!" -ForegroundColor DarkGreen
            
        }
        Catch{
            If ($_.Exception.ToString().Contains('0x8007000D')) {
                $_.Exception
                
            } 
            Else {
                Write-Warning "An import error occurred:"
                $_ | fl * -force
                $_.InvocationInfo.BoundParameters | fl * -force
                $_.Exception
            }
        }
        
        
    }
        

}
