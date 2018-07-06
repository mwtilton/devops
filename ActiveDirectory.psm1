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
    Export-Groups
} # End Function


############################################################################
#Export related functions
Function Export-Groups {
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

    $Domain = $env:USERDNSDOMAIN
    $splitDomain = $Domain.Split(".")
    $searchbase = "DC=" + $splitDomain[0] + ",DC=" + $splitDomain[1]

    $exportedGroups = "$env:USERPROFILE\Desktop\Exported-Groups.csv"
    $Groups = Get-ADGroup -Properties * -Filter * -SearchBase $searchbase |  Export-Csv -Path $exportedGroups -NoTypeInformation

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
        $Path,
        
    )
    Write-host "Starting DC Import" -fore Yellow
    

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
        $Path,
        
    )


}
