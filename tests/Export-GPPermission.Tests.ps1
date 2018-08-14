Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-GPPermission.ps1" -Force -ErrorAction Stop

Describe "Export-GPPermission" -Tags "UNIT" {

    Setup -Dir "Desktop\WorkingFolder"

    $paramargs = @{
        SrceServer = "$env:COMPUTERNAME"
        SrceDomain = "$env:USERDNSDOMAIN"
        Path = "TestDrive:\Desktop\WorkingFolder"
    }

    Context "Mocking assertions for errors" {
        Mock Get-GPO {}
        Mock Get-ADObject {}

        #displayname
        It "should throw an exception" {
            $result = Export-GPPermission @paramargs -DisplayName "Accounting"
            { $result } | Should throw
        }
        It "should throw when no displayname param is set" {
            $result = Export-GPPermission @paramargs -all
            { $result } | Should throw
        }

        #all
        It "" -Skip {

        }
    }
    Context "Mocking Assertions for Truthsss"{
        Mock Get-GPO {}
        Mock Get-ADObject {}

        Export-GPPermission @paramargs

        It "the get-gpo should be called twice" {
            Assert-MockCalled -CommandName Get-GPO -Exactly 2 -Scope Context
        }
    }
}
