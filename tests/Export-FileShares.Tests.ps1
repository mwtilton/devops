Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-FileShares.ps1" -Force -ErrorAction Stop
Describe "Export-FileShares" -Tags "UNIT" {
    Mock Get-WmiObject {}
    Mock Export-CSV {}

    Context "Asserting mocks for getting shares" {
        Mock Get-WmiObject {return $true}
        Mock Export-CSV {}
        Mock Import-Csv {}

        Setup -Dir "Desktop\WorkingFolder"
        Setup -File "Desktop\WorkingFolder\Import.csv" "Name,Share,Location"

        Export-FileShares -path "TestDrive:\Desktop\WorkingFolder\Import.csv" -DestServer $env:COMPUTERNAME

        It "Exports the files shares to a csv" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Exist
        }
        It "has the columns" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should FileContentMatch ([regex]::Escape("Name,Share,Location"))
        }
        It "overwrites the share column" {
            $csv = Import-Csv "TestDrive:\Desktop\WorkingFolder\Import.csv"
            $csv | Should Not BeNullOrEmpty
        }
        It "The import.csv file is imported" {
            Assert-MockCalled -CommandName Import-Csv -Exactly 1
        }
        It "calls the wmi object" {
            Assert-MockCalled -CommandName Get-WmiObject -Exactly 1
        }
        It "calls export-csv"{
            Assert-MockCalled -CommandName Export-Csv -Exactly 1
        }

    }
}
