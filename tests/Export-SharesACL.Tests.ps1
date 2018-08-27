Import-Module "$env:WORKINGFOLDER\DevOps\DevOps\Functions\Export-SharesACL.ps1" -Force -ErrorAction Stop
Describe "Export-SharesACL" -Tags "UNIT" {



    Setup -Dir "Desktop\WorkingFolder"
    Setup -File "Desktop\WorkingFolder\Import.csv" "path,stuff"
    Context "Setting up tests" {
        It "has a working folder" {
            "TestDrive:\Desktop\WorkingFolder"
        }
    }
    Context "Mocking things" {
        Mock Get-Acl {}
        Mock Import-Csv {return $true}
        Mock Export-Csv {} -ParameterFilter {$append -eq $false}

        Export-SharesACL -Path "TestDrive:\Desktop\WorkingFolder" -Csv "TestDrive:\Desktop\WorkingFolder\Import.csv"

        It "imports some csv file" {
            Assert-MockCalled -CommandName Import-Csv -Exactly 1 -Scope Context
        }
        It "exports a csv" {
            Assert-MockCalled -CommandName Export-Csv -Exactly 1 -Scope Context
        }
        It "gets the ACL" {
            Assert-MockCalled -CommandName Get-ACL -Scope Context
        }
    }
    Context "Write-host stuff"{
        Mock Write-Host {}

        Export-SharesACL -Path "TestDrive:\Desktop\WorkingFolder" -Csv "TestDrive:\Desktop\WorkingFolder\Import.csv"
        It "writes some stuff to the console"{
            Assert-MockCalled -CommandName Write-Host -Exactly 0
        }
    }
}
