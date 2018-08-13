$parent = (get-item $PSScriptRoot).parent.FullName
#Import-Module $parent\DevOps\DevOps.Machine.ps1 -Force -ErrorAction Stop
Import-Module "$parent\DevOps\Functions\Invoke-DevOps.ps1" -Force -ErrorAction Stop
Import-Module "$parent\DevOps\DevOps.psm1" -Force -ErrorAction Stop

Describe "Unit Tests for Invoke-DevOps" -Tags "UNIT" {
    $parent = (get-item $PSScriptRoot).parent.FullName
    Context "Wrappers, Parameters, Variables" {
        $start = "Start-DCImport","Start-DCExport","Start-GPOExport","Start-DCImport"
        $start | ForEach-Object {
            It "has the $_ wrapper" {
                "$parent\DevOps\Functions\Invoke-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
        }
        $parameters = "DestServer","GPOTemplate","CSVPath","DestDomain","Importcsv"
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

        It "has values" -Skip{
            $DevOpsInfo.Values | Should not be $null
        }
        It "has keys" -Skip {
            $DevOpsInfo.Keys | Should not be $null
        }
        $DevOpsInfo | ForEach-Object {
            It "has the key: $($_.Keys)" -Skip{

                $_.Keys | Should not be $null
            }
            It "has with the value: $($_.Values)" -Skip {

                $_.Values | Should not be $null
            }

        }
    }#End Machine File Context
}

Describe "Unit testing Start functions for Invoke-DevOps" -Tags "Unit" {
    $parent = (get-item $PSScriptRoot).parent.FullName
    Context "Testing the Start functions parameters" {
        $WorkingFolderPath = "$env:USERPROFILE\Desktop\WorkingFolder"

        $SourceDomain  = "democloud.local"
        $SourceServer  = "dc01.democloud.local"
        $GPODisplayName = "Accounting"

        $DestinationDomain = "democloud.local"
        $DestinationDomain = "dc01.democloud.local"
        Setup -Dir "Desktop\WorkingFolder"
        Setup -Dir "Desktop\WorkingFolder\GPOBackup"
        Setup -File "Desktop\WorkingFolder\Import.csv" "Source,Domain"

        Mock Get-GPO {return $GPODisplayName } #-ParameterFilter { $All -eq $true, $Domain -eq $SourceDomain, $Server -eq $SourceServer}

        #Exports
        Mock Start-DCExport {} #-ParameterFilter { $path -eq $WorkingFolderPath }
        Mock Start-GPOExport {} #-ParameterFilter { $path -eq $WorkingFolderPath, $SrceDomain -eq $SourceDomain, $SrceServer -eq $SourceServer, $DisplayName -eq $GPODisplayName }

        #Imports
        Mock Start-DCImport {} #-ParameterFilter { $path -eq $WorkingFolderPath, $DestDomain -eq $DestinationDomain } #-Path $Path -DestDomain $DestDomain -DestServer $DestServer -CSVPath $CSVPath
        Mock Start-GPOImport {} #-ParameterFilter {$CSVpath -eq "TestDrive:\Desktop\WorkingFolder\Import.csv"}

        $result = Invoke-DevOps -Job Import
        It "should have an import csv" {
            "TestDrive:\Desktop\WorkingFolder\Import.csv" | Should Exist
        }
        It "does not throw when invoked" {
            { $result } | Should Not throw
        }
        $functions = "Get-GPO","Start-DCExport","Start-DCImport","Start-GPOExport","Start-GPOImport"
        $functions | ForEach-Object {

            It "the $_ function gets called" {
                Assert-MockCalled -CommandName $_ -Exactly 1
            }

        }

    }
}
