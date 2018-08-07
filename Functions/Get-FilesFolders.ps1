function Get-FilesFolders {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [String]
        $path = "$env:TEMP\FFTEST"
    )



    Begin{
        $getFilesFolders = Get-ChildItem $path -Recurse
        $getFilesFolders | ForEach-Object {
            <#
            $spaces = @()
            Write-Host $_.Length -ForegroundColor Cyan -NoNewline
            (1..$_.Length) | ForEach-Object {
                $spaces += " "
            }
            $spaces += "END"
            Write-Host $spaces -ForegroundColor Cyan
            Write-host ($_.FullName).Replace($path, $spaces) -ForegroundColor Red
            #>

            Write-host ($_.FullName).split("\")
            Write-Host $path -ForegroundColor Cyan
            Write-host ($_.FullName).Replace($path, "") -ForegroundColor Red
        }
    }

}
