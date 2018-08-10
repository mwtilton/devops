$parent = (get-item $PSScriptRoot).parent.FullName
Import-Module $parent\DevOps\DevOps.Machine.ps1 -Force -ErrorAction Stop
Import-Module "$parent\DevOps\Functions\Invoke-DevOps.ps1" -Force -ErrorAction Stop

Describe "Unit Tests for Invoke-DevOps" -Tags "UNIT" {
    $parent = (get-item $PSScriptRoot).parent.FullName
    Context "Wrappers, Parameters, Variables" {
        $start = "Start-DCImport","Start-DCExport","Start-GPOExport","Start-DCImport"
        $start | ForEach-Object {
            It "has the $_ wrapper" {
                "$parent\DevOps\Functions\Invoke-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        $parameters = "DestServer","GPOBackuppath","MigTableCSV","DestDomain","Importcsv"
        $parameters | ForEach-Object {
            It "has the $_ parameter" {
                "$parent\DevOps\Functions\Invoke-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        $variables = "SrceDomain","SrceServer","BackupPath"
        $variables | ForEach-Object {
            It "has the $_ variable" {
                "$parent\DevOps\Functions\Invoke-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }

    }
    Context "Mocking Import CSV Headers" {
        Setup -Dir "Desktop\WorkingFolder"
        $importCSV = Setup -File "Desktop\WorkingFolder\Import.csv" "Source,Domain" -PassThru

        Mock Import-Csv {"Source,Domain"} -ParameterFilter {$path -eq $importCSV }

        It "has an import csv file" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Exist
        }
        It "has contents" {
            Get-Content "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Be "Source,Domain"
        }
        It "can import the file without throwing" {
            { Import-Csv $importCSV -ErrorAction Stop } | Should Not throw
        }
        It "the csv file exists" {
            $importCSV | Should Exist
        }
        It "should not be null or empty" {
            Import-Csv $importCSV | Should Not BeNullOrEmpty
        }
        $headers = "Source,Domain"
        It "imports the csv file" {
            Import-Csv $importCSV | Should Be $headers
        }

    }
    Context "Import Machine Files" {

        It "has values" {
            $DevOpsInfo.Values | Should not be $null
        }
        It "has keys" {
            $DevOpsInfo.Keys | Should not be $null
        }
        $DevOpsInfo | ForEach-Object {
            It "has the key: $($_.Keys)" {

                $_.Keys | Should not be $null
            }
            It "has with the value: $($_.Values)" {

                $_.Values | Should not be $null
            }

        }
    }#End Machine File Context
}

Describe "Acceptance tests for Invoke-DevOps" -Tags "Acceptance" {
    $parent = (get-item $PSScriptRoot).parent.FullName
    Context "Testing the Start functions parameters" {
        Mock Start-DCExport {} -ParameterFilter {$path -eq $parent}

        $result = Invoke-DevOps -Job Import
        It "does not throw when invoked" {
            { $result } | Should Not throw
        }
        $functions = "Start-DCExport"
        $functions | ForEach-Object {

            It "has the start option" {
                Assert-MockCalled -CommandName $_ -Exactly 1
            }
            It "does not throw" {

            }
        }

    }
}
