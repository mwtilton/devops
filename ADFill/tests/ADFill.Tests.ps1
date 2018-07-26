Import-Module $env:WORKINGFOLDER\Devops\ADFill\ADFill -Force -ErrorAction Stop

Describe "DCImport Unit Tests" -Tags "UNIT" {
    InModuleScope ADFill {

        Context "Mocking getting the Organizational Units" {
            Mock Get-ADOrganizationalUnit {return $true} -ParameterFilter {$filter -eq "Name -like 'OU=DEMOCLOUD,DC=DEMOCLOUD,DC=LOCAL'"}
            It "should not be null" {
                Get-ADOrganizationalUnit | Should not be $null
            }
            It "should not be empty" {
                Get-ADOrganizationalUnit | Should not be ""
            }
        }


    }

}
