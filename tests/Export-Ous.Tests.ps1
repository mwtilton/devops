Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Ous.ps1" -Force -ErrorAction Stop

Describe "Export-Ous" {
    $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
    $testPath | ForEach-Object {
        Set-Content $testPath -value "my test text."
    }

    Context "Mocking getting the Organizational Units" {
        Mock Get-ADOrganizationalUnit {return $true} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
        It "should not be null" {
            {Get-ADOrganizationalUnit -Filter }| Should not be $null
        }
        It "should not be empty" {
            {Get-ADOrganizationalUnit -Filter}| Should not be ""
        }
        It "should not throw with wildcard" {
            {Get-ADOrganizationalUnit -Filter *}| Should not throw
        }
        It "should not throw with OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL" {
            {Get-ADOrganizationalUnit -Filter "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"} | Should not throw
        }
    }
    Context "Throwing unit tests" {
        Mock Mock Get-ADOrganizationalUnit {return $null} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
        It "will throw" {
            $getOU = Get-ADOrganizationalUnit -Filter "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"
            ($getOU -eq "OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL") | Should Be $true
        }
    }
}
