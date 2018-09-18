$parent = (get-item $PSScriptRoot).FullName
$select = "*Get-CredCheck*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\build\$select -tags "UNIT"
