Import-Module $env:WORKINGFOLDER\Devops\ADFill\ADFill -Force -ErrorAction Stop

Describe "DCImport Unit Tests" -Tags "UNIT" {
    $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
    $testPath | ForEach-Object {
        Set-Content $testPath -value "my test text."
    }
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
            $testPath = "$testdrive\testfile.psm1","$testdrive\testfile.psm1"
            $testPath | ForEach-Object {
                Mock Get-ChildItem {return @{FullName = $_.FullName}}
                Mock ForEach-Object -MockWith {}
                Mock Get-Content {return "my test text."} -ParameterFilter {$path -eq $_.FullName}
                Mock Out-File {return $true} -ParameterFilter { $path -eq $_.FullName -and $destination -eq "$testdrive\Module\testfile.psm1"}
            }

            $result = Move-Modules -path $testdrive

            It "Calls the gci 1 time" {
                $Params = @{
                    CommandName = 'Get-ChildItem'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
            It "Files should be psm or psd files" {
                $result | ForEach-Object{
                    $result.FullName | Should belike "*.ps*1"
                }
            }
            It "file should exist" {
                $result | ForEach-Object {
                    $_.Name | Should not be $null
                    $_.FullName | Should Exist
                }
            }
            It "has the program module folder" {
                ($env:PSModulePath).Split(";")[1] | Should belike "c:\Program*"
            }
            It "returns something" {
                $result | Should -not -BeNullOrEmpty
            }
            It "calls get-content" {
                $Params = @{
                    CommandName = 'Get-Content'
                    Times = 2
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }
            It "calls out-file" {
                $Params = @{
                    CommandName = 'Out-File'
                    Times = 2
                    Exactly = $true
                }
                Assert-MockCalled @Params
            }

        }

    }

}
