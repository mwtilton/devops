$parent = (get-item $PSScriptRoot).FullName
$select = "*prepRebuild*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Build\$select -tags "GIT"
