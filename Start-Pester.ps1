$parent = (get-item $PSScriptRoot).FullName
$select = "*Get-ServerWinEvents*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "UNIT"
