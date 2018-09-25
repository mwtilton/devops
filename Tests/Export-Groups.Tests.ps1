Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-Groups.ps1" -Force -ErrorAction Stop

Describe "Export-Groups" -Tags "UNIT" {

    Setup -Dir "Desktop\WorkingFolder"

    $path = "TestDrive:\Desktop\WorkingFolder"

    Context "Asserting Mocks" {

        Setup -File "Desktop\WorkingFolder\Import.csv"

        Mock Get-ADGroup { return $true }
        Mock Export-csv -MockWith { return $null }
        Mock Import-Csv {}

        Export-Groups -path $path -SrceDomain $env:USERDNSDOMAIN

        It "has the workingfolder" {
            $path | Should Exist
        }
        It "gets the ad groups" {
            Assert-MockCalled -CommandName Get-ADGroup -Exactly 1 -Scope Context
        }
        It "it calls the export csv" {
            Assert-MockCalled -CommandName Export-csv -Exactly 1 -Scope Context
        }
        It "has an exported csv file" {

            "$path\Import.csv" | Should Exist
        }
        It "shows the found groups" {
            Assert-MockCalled -CommandName Import-Csv -Exactly 1 -Scope Context
        }

    }
}
