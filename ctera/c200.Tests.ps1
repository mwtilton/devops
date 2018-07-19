$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Unit testing c200" -Tags "Unit" {

    Context "Test the connection" {
        Mock Restart-Device -MockWith {"192.1.1.x"}
        It "does not use a valid IP" {

            {Test-Connection -ComputerName} | Should throw
        }
        It "can ping google" {
            Test-Connection "8.8.8.8" -Quiet -Count 1 | Should Be $true
        }
        It "Invalid Url for rest-method" {
            {Invoke-RestMethod -Uri } | Should throw
        }
        It "can ping the dev device" {
            Test-Connection "172.16.20.218" -Quiet -Count 1 | Should Be $true
        }
    }
    Context "Has valid API text" {
        $rebootXML = "<obj><att id=`"type`"><val>user-defined</val></att><att id=`"name`"><val>reboot</val></att></obj>"

        It "Hardcoded string contains reboot" {
            $rebootXML | Should Match "reboot"
        }


    }
    $values = "500","200","404"
<#
     $values | ForEach-Object{

        Context "Foreach-Object Restmethod returns $_ code" {
            Mock Invoke-RestMethod {
                "$_"
            }

            $result = Restart-Device

            It "returns $_" {
                $($result) | Should Be $($_)
            }
            It "should be a string" {
                $result.gettype() | Should beoftype System.Object
            }
            It "Should not be empty" {
                $result | Should not be ""
            }
            It "$_ should be a valid entry" {
                $_ | Should BeExactly $_
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
#>
    Foreach($value in $values){

        Context "Foreach Restmethod returns $value code" {
            Mock Invoke-RestMethod {
                "$value"
            }

            $result = Restart-Device

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
    Context "host is back up" {
        It "can ping the dev device after reboot" {
            Test-Connection "172.16.20.218" -Quiet -Count 1 | Should Be $true
        }

    }


}

Describe "Acceptance testing for c200" -tags "Acceptance" {
    Context "Gets a connection" {
        $gc = Get-Connection
        It "gets a status code of 200" {
            $gc | Should be 200
        }
    }
    Context "Invoking the rest-method" {
        $wbs = Start-Connection
        It "should not return null" {
            $wbs | Should not be $null
        }
        It "should not be 404" {
            $wbs[0] | Should not be 404
        }
        It "should return 200" {
            $wbs | Should be 200
        }
        It "Should not throw an error" {
            {$wbs} | Should -not throw
        }
    }

}
