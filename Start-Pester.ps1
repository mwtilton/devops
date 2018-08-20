$parent = (get-item $PSScriptRoot).FullName
$select = "*Export-Ous*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "UNIT"
