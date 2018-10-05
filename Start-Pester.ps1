$parent = (get-item $PSScriptRoot).FullName
$select = "*Set-HostsFile*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "UNIT"
