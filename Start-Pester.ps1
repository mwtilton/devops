$parent = (get-item $PSScriptRoot).FullName
$select = "*New-PasswordNotification*"
Invoke-Pester "$parent\Tests\$select" -CodeCoverage $parent\DevOps\Functions\$select -tags "Password"
