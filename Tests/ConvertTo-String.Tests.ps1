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
            $ConfigData.Values[0] | Should -Be "pc01"
        }
        It "is an object at the node level" {
            $ConfigData.AllNodes.NodeName | Should beoftype [System.Object]
        }
        It "The $($ConfigData.AllNodes.NodeName[0]) server name is accurate" {
            $ConfigData.AllNodes.NodeName[0] | Should BeLike "pc01"
        }
    }
    Context "Unit testing function" {
        $result = ConvertTo-String -Object $ConfigData.AllNodes.NodeName

        It "returns a string object" {
            $result | Should beoftype [string]
        }
        It "converts the values to a string" {
            $result | Should -Not -BeNullOrEmpty
        }
        It "should have a server name in it" {
            $result | Should BeLike '"pc01,pc02"'
        }
        It "has a correct value" {
            $result[0] | Should Be "pc01"
        }
    }
}
