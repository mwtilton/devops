Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-FileShares.ps1" -Force -ErrorAction Stop
Describe "Export-FileShares" -Tags "UNIT" {
    Mock Get-WmiObject {}
    Mock Export-CSV {}
    Mock Import-Csv {}

    Setup -Dir "Desktop\WorkingFolder"
    Setup -File "Desktop\WorkingFolder\Import.csv" "Name,Share,Location"

    Context "Asserting mocks for getting shares" {
        Mock Get-WmiObject {return $true}

        Export-FileShares -path "TestDrive:\Desktop\WorkingFolder\Import.csv" -DestServer $env:COMPUTERNAME

        It "Exports the files shares to a csv" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Exist
        }
        It "has the columns" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should FileContentMatch ([regex]::Escape("Name,Share,Location"))
        }
        It "calls the wmi object" {
            Assert-MockCalled -CommandName Get-WmiObject -Exactly 1 -Scope Context
        }
        It "calls export-csv"{
            Assert-MockCalled -CommandName Export-Csv -Exactly 1 -Scope Context
        }
        It "The import.csv file is imported" -Skip {
            Assert-MockCalled -CommandName Import-Csv -Exactly 1 -Scope Context
        }

    }
    Context "Asserting mocks for null object returned" {
        Mock Get-WmiObject {return $null}

        $result = Export-FileShares -path "TestDrive:\Desktop\WorkingFolder\Import.csv" -DestServer $env:COMPUTERNAME

        It "should not export a csv file" {
            Assert-MockCalled -CommandName Export-CSV -Exactly 0 -Scope Context
        }
        It "should not throw if returned null" {
            {$result} | Should Not throw
        }
    }
    Context "Asserting mocks for false objects" {
        Mock Get-WmiObject {}

        $result = Export-FileShares -path "TestDrive:\Desktop\WorkingFolder\Import.csv" -DestServer $env:COMPUTERNAME

        It "should still append the csv" {
            Assert-MockCalled -CommandName Export-Csv -Exactly 1 -Scope Context
        }
    }
}
