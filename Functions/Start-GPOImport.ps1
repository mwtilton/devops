Function Start-GPOImport {
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
        $Path,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $BackupPath,  # Path from GPO backup
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $MigTableCSVPath,
        [Parameter()]
        [Switch]
        $CopyACL
    )
    Write-host "Starting GPOImport" -ForegroundColor Yellow
    # Create the migration table
    # Capture the MigTablePath and MigTableCSVPath for use with subsequent cmdlets
    $MigTablePath = New-GPOMigrationTable -DestDomain $DestDomain -Path $Path -BackupPath $BackupPath -MigTableCSVPath $MigTableCSVPath

    # View the migration table

    #Write-host "View the migration table" -ForegroundColor Yellow
    #Show-GPOMigrationTable -Path $MigTablePath

    # Validate the migration table
    # No output is good.

    Write-host "Validate the migration table" -ForegroundColor Yellow
    Test-GPOMigrationTable -Path $MigTablePath

    Write-host "Removing Duplicate GPO's" -ForegroundColor Red
    # OPTIONAL
    # Remove any pre-existing GPOs of the same name in the destination environment
    # Use this for these scenarios:
    # - You want a clean import. Remove any existing policies of the same name first.
    # - You want to start over and import them again.
    # - Import-GPO will fail if a GPO of the same name exists in the target.
    Invoke-RemoveGPO -DestDomain $DestDomain -DestServer $DestServer -BackupPath $BackupPath

    Write-host "Invoking the GPOImport" -ForegroundColor Yellow
    # Import all from backup
    # This will fail for any policies that are missing migration table accounts in the destination domain.
    Invoke-ImportGPO -DestDomain $DestDomain -DestServer $DestServer -BackupPath $BackupPath -MigTablePath $MigTablePath -CopyACL

    Write-host "Importing WMI filters" -ForegroundColor Yellow
    # Import WMIFilters
    $impWMI = Import-WMIFilter -DestServer $DestServer -Path $BackupPath


    # Relink the WMI filters to the GPOs
    if($impWMI -eq $true){
        Write-host "Setting WMI filters" -ForegroundColor Yellow
        Set-GPWMIFilterFromBackup -DestDomain $DestDomain -DestServer $DestServer -BackupPath $BackupPath
    }
    elseif ($impWMI -eq $false) {

    }
    Else{
        Write-Warning "WMI Filter import returned nothing."
    }


    # Link the GPOs to destination OUs of same path
    # The migration table CSV is used to remap the domain name portion of the OU distinguished name paths.
    Write-host "Importing GPLinks" -ForegroundColor Yellow
    Import-GPLink -DestDomain $DestDomain -DestServer $DestServer -BackupPath $BackupPath -MigTableCSVPath $MigTableCSVPath
    #>
} # End Function
