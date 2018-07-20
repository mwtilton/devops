$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$ip = "172.16.20.218"
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
            Test-Connection $ip -Quiet -Count 1 | Should Be $true
        }
    }
    Context "Has valid API text" {
        $rebootXML = "<obj><att id=`"type`"><val>user-defined</val></att><att id=`"name`"><val>reboot</val></att></obj>"

        It "Hardcoded string contains reboot" {
            $rebootXML | Should Match "reboot"
        }
        It "is text/html" {
            $rebootXML.GetType() | Should be [text/html]
        }

    }
    $values = "500","200","404"

    $values | ForEach-Object{
        $myitem = $_
        Context "Foreach-Object Restmethod returns $myitem code" {
            Mock Invoke-RestMethod {
                $myitem
            }

            $result = Restart-Device

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
            Test-Connection $ip -Quiet -Count 1 | Should Be $true
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
    Context "Starting the connection" {
        $wbs = Start-Connection
        It "should not return null" {
            $wbs | Should not be $null
        }
        It "should not be 404" {
            $wbs[0] | Should not be 404
        }
        It "Should not throw an error" {
            {$wbs} | Should -not -Throw
        }

    }
    Context "device is down" {

        It "is down" {
            Restart-Device
            (Test-Connection $ip -Quiet -Count 1) | Should Be $false
        }
    }
    Context "host is back up" {

        It "can loop ping the device" {
            do{
                "rebooting $ip"
            }Until (!(Test-Connection $ip -Quiet -Count 1))

            (Test-Connection $ip -Quiet -Count 1) | Should Be $true

        }
        It "can ping the dev device after reboot" {

            (Test-Connection $ip -Quiet -Count 1) | Should Be $true
        }

    }


}
