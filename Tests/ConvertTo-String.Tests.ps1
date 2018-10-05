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
    Context "General Unit testing components" {
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
        It "shows the type returned from a get-item" {
            Mock Get-Item {return [System.Object]}
            Get-Item "WSMan:\localhost\Client\TrustedHosts" | Should beoftype [System.Object]
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

        $ConfigData.AllNodes | ForEach-Object {
            Mock Get-Credential { return @{username = "$($($_.NodeName) + "\Administrator")"}} -MockWith {$username -eq $($_.nodename + "\Administrator")}
            New-Variable -Name $_.NodeName -Value $($_.Nodename)
            It "Has a server name: $($_.Nodename)" {
                $_.NodeName | Should -Not -BeNullOrEmpty
            }
            It "$($_.Nodename)" {
                Get-Variable -Name $_.NodeName | Should -Not -BeNullOrEmpty
            }
            It "should get the credentials" {
                Set-Variable -Name $_.NodeName -Value (Get-Credential -UserName $($($_.NodeName) + "\Administrator") -Message "Hello")
                $creds | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "Copying files" {
        Setup -Dir "Modules"
        Setup -Dir "Modules\WindowsPowerShell"
        Setup -File "Modules\file.txt" "word"

        $Params =@{
            Path = "$testdrive\Modules\*"
            Destination = "$testdrive\Modules\WindowsPowerShell"
            ErrorAction = "SilentlyContinue"
            Recurse = $true
        }

        Copy-Item @Params #-Path "$testdrive\Modules\*" -Destination "$testdrive\Modules\WindowsPowershell\"

        $file = Get-ChildItem "$testdrive\Modules" | ? {!$_.psiscontainer}
        $file2 = Get-ChildItem "$testdrive\Modules\WindowsPowershell" | ? {!$_.psiscontainer}

        It "made the required files folders" {
            "$testdrive\Modules" | Should Exist
            "$testdrive\Modules\WindowsPowerShell" | Should Exist
            "$testdrive\Modules\file.txt" | Should Exist
        }
        It "Should have one file in the modules folder"{
            $file.Count | Should be 1
            $file.Name | Should be "file.txt"
        }
        It "Should have one file in the windows powershell folder"{
            $file2.Count | Should be 1
            $file2.Name | Should be "file.txt"
        }
        It "has contents" {
            Get-Content "$testdrive\Modules\file.txt" | Should Be "word"
        }
        It "copies stuff" {
            "$testdrive\Modules\WindowsPowerShell\file.txt" | Should Exist
        }
    }
}
