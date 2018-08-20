Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Ous.ps1" -Force -ErrorAction Stop

Describe "Export-Ous" -Tags "UNIT" {
    Setup -Dir "Desktop\WorkingFolder"
    Setup -File "Desktop\WorkingFolder\Import.csv"
    $path = "TestDrive:\Desktop\WorkingFolder"
    Context "Setup Tests" {
        It "has a valid path" {
            $path | Should Not BeNullOrEmpty
        }
    }
    Context "Mocking getting the Organizational Units" {
        Mock Get-ADOrganizationalUnit {return $true} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
        It "should not be null or empty" {
            {Get-ADOrganizationalUnit -Filter }| Should Not BeNullOrEmpty
        }
        It "should not throw with wildcard" {
            {Get-ADOrganizationalUnit -Filter *}| Should not throw
        }
        It "should not throw with OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL" {
            {Get-ADOrganizationalUnit -Filter "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"} | Should not throw
        }
    }
    Context "Mocking unit tests" {
        Mock Get-ADOrganizationalUnit {return @{Name = "DemoCloud"}}
        Mock Export-Csv {return $true}

        Export-Ous -SrceDomain $env:USERDOMAIN -Path $path
        It "has the workingfolder" {
            "TestDrive:\Desktop\WorkingFolder" | Should Exist
        }
        It "Calls the Get-ADOU one time" {
            Assert-MockCalled -CommandName Get-ADOrganizationalUnit -Exactly 1 -Scope Context
        }
    }
    Context "Throwing tests" {
        Mock Get-ADOrganizationalUnit {return @{Name = "DemoCloud"}}
        Mock Export-Csv {}

        It "doesn't throw with a domain and path selected" {
            {Export-Ous -SrceDomain $env:USERDOMAIN -Path $path} | Should Not throw

        }
    }
}
