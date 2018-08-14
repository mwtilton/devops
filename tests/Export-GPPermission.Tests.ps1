Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-GPPermission.ps1" -Force -ErrorAction Stop

Describe "Export-GPPermission" -Tags "UNIT" {
    Mock Get-GPO {}
    Mock Get-ADObject {}

    Setup -Dir "Desktop\WorkingFolder"
    $paramargs = @{
        SrceServer = "$env:COMPUTERNAME"
        SrceDomain = "$env:USERDNSDOMAIN"
        Path = "TestDrive:\Desktop\WorkingFolder"
    }
    Context "Mocking assertions for errors" {

        It "should throw an exception" {
            $result = Export-GPPermission
            {$result} | Should throw
        }
        It "should throw when no displayname param is set" {
            $result = Export-GPPermission @paramargs
            { $result } | Should throw
        }
    }
    Context "Mocking Assertions for Truthsss" {
        Mock Get-GPO {}

        Export-GPPermission @paramargs -all -displayname "dsa"

        It "the get-gpo should be called twice" {
            Assert-MockCalled -CommandName Get-GPO -Exactly 2 -Scope Context
        }
    }
}
