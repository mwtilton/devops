Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\ConvertTo-String.ps1" -Force -ErrorAction Stop

Describe "ConvertTo-String" -Tag Unit {
    $ConfigData = @{
        AllNodes = @(

            @{
                NodeName = "pc01"
                ThisComputerName = "FileServer01"
                IPAddressCIDR = "192.168.1.2/24"
            }
            @{
                NodeName = "pc02"
                ThisComputerName = "APP01"
                IPAddressCIDR = "192.168.1.3/24"

            }
        )
    }
    Context "Hashtable Conversion" {
        It "Configdata is a hashtable" {
            $ConfigData | Should beoftype [Hashtable]
        }
        It "has values in it" {
            $ConfigData.Values | Should -Not -BeNullOrEmpty
        }
        It "has the right value at index value 0" {
            ($ConfigData.AllNodes.NodeName)[0] | Should -Be "pc01"
        }
        It "is an object at the node level" {
            $ConfigData.AllNodes.NodeName | Should beoftype [System.Object]
        }
        It "The $($ConfigData.AllNodes.NodeName[0]) server name is accurate" {
            $ConfigData.AllNodes.NodeName[0] | Should BeLike "pc01"
        }
    }
    Context "Unit testing function" {

        Mock Get-Item {}
        Mock Set-Item {}

        #$result = ConvertTo-String -Object $ConfigData.AllNodes.NodeName

        It "returns a string object" -Skip {
            $result | Should beoftype [string]
        }
        It "should not be null or empty" -Skip {
            $result | Should -Not -BeNullOrEmpty
        }
        It "should return an array of values" -Skip {
            ($result | Select *) | Should match "pc01","pc02"
        }
        It "has the specific values" -Skip {
            $result[0] | Should Be "pc01"
            $result[1] | Should Be "pc02"
            $result.Count | Should Be 2
        }
    }
    Context "Throwing tests with Mocking" {
        Mock Get-Item {return $null}
        Mock Set-Item {}

        $result = ConvertTo-String -Object $ConfigData.AllNodes.NodeName
        It "Set-item Doesn't throw with the returned result" {
            {$result} | Should -Not throw
        }
    }
}
