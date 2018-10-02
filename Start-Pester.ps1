$parent = (get-item $PSScriptRoot).FullName
$select = "*ConvertTo-String*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "UNIT"
