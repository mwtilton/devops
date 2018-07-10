$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1

############################################################################
#Import related functions

#.ExternalHelp FilesFolders.psm1-help.xml
Function Start-FilesFolders {
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
    Write-host "Starting FilesFolders" -fore Yellow
    # Create the migration table
    # Capture the MigTablePath and MigTableCSVPath for use with subsequent cmdlets
    New-FilesFolders -DestDomain $DestDomain -Path $Path -BackupPath $BackupPath -MigTableCSVPath $MigTableCSVPath

    # View the migration table
    Write-host "View FilesFolders" -fore Yellow
    Show-FilesFolders -Path $MigTablePath

    # Validate the migration table
    # No output is good.
    Write-host "Validate FilesFolders" -fore Yellow
    Test-FilesFolders

    
} # End Function



function Test-FileLock {
    param (
      [parameter(Mandatory=$true)][string]$Path
    )
  
    $oFile = New-Object System.IO.FileInfo $Path
  
    if ((Test-Path -Path $Path) -eq $false) {
      return $false
    }
  
    try {
      $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  
      if ($oStream) {
        $oStream.Close()
      }
      $false
    } catch {
      # file is locked by a process.
      return $true
    }
  }
  
  openfiles /query /s fileserver01 /u matthewt | findstr /i /c:"LG-PST-BACKUPS"
  
  function Get-OpenFiles {
      cls
      openfiles /query /s $args[0] /fo csv /V | Out-File -Force C:\temp\openfiles.csv
      $search = $args[1]
      Import-CSV C:\temp\openfiles.csv | Select "Accessed By", "Open Mode", "Open File (Path\executable)" | Where-Object {$_."Open File (Path\executable)" -match $search} | format-table -auto
      Remove-Item C:\temp\openfiles.csv
  }
