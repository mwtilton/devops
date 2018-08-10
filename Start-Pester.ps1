$parent = (get-item $PSScriptRoot).FullName
$select = "*DevOps*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "UNIT"
