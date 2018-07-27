Import-Module $env:WORKINGFOLDER\Devops\ADFill\ADFill -Force -ErrorAction Stop

Describe "DCImport Unit Tests" -Tags "UNIT" {
    InModuleScope ADFill {

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
        Context "Moving Modules Unit testing" {
            Mock Get-ChildItem {return "$env:USERPROFILE\Desktop\ADFill\ADFill\ADFill.psm1"} -Verifiable
            Mock Get-ChildItem {return "$env:USERPROFILE\Desktop\ADFill\ADFill\ADFill.psd1"} -Verifiable
            $result = Move-Modules -path "$env:USERPROFILE\Desktop"
            It "Calls the gci 1 time" {
                $Params = @{
                    CommandName = 'Get-ChildItem'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
            It "Looks in the users desktop" {
                $result | Should belike "*.ps*1"
            }
            It "has the program module folder" {
                ($env:PSModulePath).Split(";")[1] | Should belike "c:\Program*"
            }

        }
        Context "Copy's the module to the users module folder" {
            Mock Copy-Item {return $true} -ParameterFilter { $path -eq "$testdrive\testfile.psm1" -and $destination -eq "$testdrive\Module\testfile.psm1"}
            It "calls copy-item" {
                $Params = @{
                    CommandName = 'Copy-Item'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
        }

    }

}
