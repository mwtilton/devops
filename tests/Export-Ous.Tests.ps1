Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Ous.ps1" -Force -ErrorAction Stop

Describe "Export-Ous" -Tags "UNIT" {
    Setup -Dir "Desktop\WorkingFolder"


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
    Context "Throwing unit tests" {
        Mock Get-ADOrganizationalUnit {return $null}
        Export-Ous
        It "will throw" {

        }
    }
}
