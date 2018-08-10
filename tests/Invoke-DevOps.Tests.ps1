$parent = (get-item $PSScriptRoot).parent.FullName
Import-Module $parent\DevOps\DevOps.Machine.ps1 -Force -ErrorAction Stop
Import-Module "$parent\DevOps\Functions\Invoke-DevOps.ps1" -Force -ErrorAction Stop

Describe "Invoke-DevOps" -Tags "UNIT" {
    Context "Wrappers, Parameters, Variables, Invoker" {
        $start = "Start-DCImport","Start-DCExport","Start-GPOExport","Start-DCImport","Start-OpenStack"
        $start | ForEach-Object {
            It "has the $_ wrapper" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        $parameters = "DestServer","GPOBackuppath","MigTableCSV","DestDomain","Importcsv"
        $parameters | ForEach-Object {
            It "has the $_ parameter" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        $variables = "SrceDomain","SrceServer","BackupPath"
        $variables | ForEach-Object {
            It "has the $_ variable" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        It "Invokes the DevOps Process" {
            "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("Invoke-DevOps"))
        }
    }
    Context "Import CSV Headers" {
        Setup -Dir "Desktop\WorkingFolder"
        $importCSV = Setup -File "Desktop\WorkingFolder\Import.csv" "Source,Domain" -PassThru

        It "has an import csv file" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Exist
        }
        It "has contents" {
            Get-Content "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Be "Source,Domain"
        }
        It "can import the file without throwing" {
            { Import-Csv "TestDrive:\Desktop\WorkingFolder\Import.csv" -ErrorAction Stop } | Should Not throw
        }
        $headers = "Source,Domain"
        It "has: $headers for headers" {
            #$csv = Import-Csv $importCSV
            # | Should Be $true
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
