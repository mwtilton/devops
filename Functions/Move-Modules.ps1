Function Move-Modules {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path

    )
    $modulePath = ($env:PSmodulePath).split(";")[1]
    $getModules = Get-ChildItem -path $path -recurse | ? {$_.extension -like "*.ps*1"}
    $getmodules | Foreach-Object {
        $newFileLocation = $modulepath + $_.Name
        (Get-content $_.fullname) | Out-file $newFileLocation -encoding default
    }
    return $getmodules
}
