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
                it "should be mocked 1 times" {
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
            } #End Context
        } # End Foreach
        Context "Machine File seccuessfully imported" {
            It "Contains a hashtable" {
                $OpenStackinfo | Should beoftype [Hashtable]

            }
            It "has values" {
                $OpenStackinfo.Values | Should not be $null
            }
            It "has keys" {
                $OpenStackinfo.Keys | Should not be $null
            }
            $OpenStackinfo | ForEach-Object {
                It "has some keys" {

                    $_.Keys | Should not be $null
                }
                It "has some values" {

                    $_.Values | Should not be $null
                }
                It "the values should have an HTTP address in it" {
                    $_.Values | Should BeLike "*http*://*"
                }

            }
        }#End Context
        Context "Hitting the API" {
            $OpenStackinfo | ForEach-Object {

            }



        }
    } #End Inmodule scope

} #End Describe

