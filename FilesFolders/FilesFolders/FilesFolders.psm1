$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1

############################################################################
#Import related functions

#.ExternalHelp FilesFolders.psm1-help.xml
function Test-FileLock {
    [CmdletBinding()]
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


  
function Get-OpenFiles {
    #openfiles /query /s fileserver01 /u matthewt | findstr /i /c:"LG-PST-BACKUPS"
    
    openfiles /query /s $args[0] /fo csv /V | Out-File -Force C:\temp\openfiles.csv
    $search = $args[1]
    Import-CSV C:\temp\openfiles.csv | Select "Accessed By", "Open Mode", "Open File (Path\executable)" | Where-Object {$_."Open File (Path\executable)" -match $search} | format-table -auto
    Remove-Item C:\temp\openfiles.csv
}

function Get-FilesFolders {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -like "*.*"})]
        [String]
        $path
    )



    Begin{
        $getFilesFolders = Get-ChildItem $path -Recurse 
        $getFilesFolders | ForEach-Object {
            $_

        }
    }

}
