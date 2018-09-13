$parent = (get-item $PSScriptRoot).FullName
$select = "*prepGit*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\build\$select -tags "Git"
