function Export-GPPermission {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            ParameterSetName="All")]
        [Switch]
        $All, # Backup all GPOs
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="DisplayName")]
        [String[]]
        $DisplayName, # Array of GPO DisplayNames to backup
        [Parameter(Mandatory=$true)]
        [String]
        $SrceDomain,
        [Parameter(Mandatory=$true)]
        [String]
        $SrceServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path
    )
    $GPO_ACEs = @()


    If ($All) {
        $DisplayName = Get-GPO -Server $SrceServer -Domain $SrceDomain -All |
            Select-Object -ExpandProperty DisplayName
    }

    ForEach ($Name in $DisplayName) {
        $GPO = Get-GPO -Server $SrceServer -Domain $SrceDomain -Name $Name
        # Using the NTSecurityDescriptor attribute instead of calling Get-ACL
        $ACL = (Get-ADObject -Identity $GPO.Path -Properties NTSecurityDescriptor |
            Select-Object -ExpandProperty NTSecurityDescriptor).Access

        $GPO_ACEs += $ACL | Select-Object `
                @{name='Name';expression={$Name}}, `
                @{name='Path';expression={$GPO.Path}}, `
                *
    }

    $GPO_ACEs | Export-CSV (Join-Path $Path GPPermissions.csv) -NoTypeInformation
}
