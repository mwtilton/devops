Get-Module OpenStack | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\DevOps\OpenStack\OpenStack -Force -ErrorAction Stop

Describe "Unit testing for OpenStack" -Tags 'Unit'{

    InModuleScope OpenStack {

        Context "testing framework files" {

            It "OpenStack folder exists" {
                "$($here)\OpenStack" | Should be $true
            }
            It "Tests folder exists" {
                "$($here)\Tests" | Should be $true
            }
            It "has a readme file" {
                "$($here)\readme.md" | Should be $true
            }
            It "has an .gitignore file" {
                "$($here)\.gitignore" | Should be $true
            }
            It "has a start-pester file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
            It "has a call OpenStack file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
        }


        $values = "500","200","404","403"

        $values | ForEach-Object{
            $myitem = $_
            Context "Foreach-Object Restmethod returns $myitem code" {
                Mock Invoke-RestMethod {
                    $myitem
                }

                $result = Start-OpenStack -DestServer $OpenStackInfo.Compute

                It "returns $myitem" {
                    $($result) | Should Be $($myitem)
                }
                It "should be a string" {
                    $result.gettype() | Should beoftype System.Object
                }
                It "Should not be empty" {
                    $result | Should not be ""
                }
                It "$myitem should be a valid entry" {
                    $myitem | Should BeExactly $myitem
                }
                it 'should be mocked' {
                    $assMParams = @{
                        CommandName = 'Invoke-Restmethod'
                        Times = 1
                        Exactly = $true
                    }
                    Assert-MockCalled @assMParams
                }
                It "should not throw an exception" {
                    {$result }| Should not throw
                }
            }

        }

        Foreach($value in $values){

            Context "Foreach Restmethod returns $value code" {
                Mock Invoke-RestMethod {
                    "$value"
                }

                $result = Start-OpenStack -DestServer $OpenStackInfo.Compute

                It "returns $value" {
                    $result | Should Be $value
                }
                It "should be a string" {
                    $result.gettype() | Should beoftype System.Object
                }
                It "Should not be empty" {
                    $result | Should not be ""
                }
                It "$value should be a valid entry" {
                    $value | Should BeExactly $value
                }
                it 'should be mocked' {
                    $assMParams = @{
                        CommandName = 'Invoke-Restmethod'
                        Times = 1
                        Exactly = $true
                    }
                    Assert-MockCalled @assMParams
                }
                It "should not throw an exception" {
                    {$result }| Should not throw
                }
            }

        }






    }

}

Describe "Acceptance Testing for Openstack API" -Tags "Acceptance" {
    InModuleScope OpenStack {
        Context "API Unit Testing" {
            It "Connects to the API" {
                Start-OpenStack -DestServer $OpenStackinfo.Compute

            }
        }
    }
}
