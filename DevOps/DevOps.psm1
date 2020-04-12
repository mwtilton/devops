$PSDefaultParameterValues=@{'Write-host:BackGroundColor'='Black';'Write-host:ForeGroundColor'='Green'}
#requires -Version 5.1

Try{
    Import-Module $PSScriptRoot\DevOps.Machine.ps1 -Force -ErrorAction Stop
}
Catch {
    Write-Warning "A valid Machine file was not found and couldn't be loaded into the module"
}

############################################################################
#Import related functions
$functions = Get-ChildItem $PSScriptRoot\Functions -Filter "*.ps1"
$functions | ForEach-Object {
    Import-Module $PSScriptRoot\Functions\$($_.name) -Force
}
Export-ModuleMember *