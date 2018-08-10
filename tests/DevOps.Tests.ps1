Get-Module DevOps | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\DevOps\DevOps -Force -ErrorAction Stop
Import-Module $env:WORKINGFOLDER\DevOps\DevOps\DevOps.Machine.ps1 -Force -ErrorAction Stop
Import-Module $env:WORKINGFOLDER\DevOps\Call-DevOps.ps1 -Force -ErrorAction Stop

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Describe "Unit testing for DevOps Module" -Tags 'WF'{

    InModuleScope DevOps {

        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            It "PS Script root exists" {
                $PSScriptRoot | Should Exist
            }
            It "can go to the functions folder" {
                $functionsFolder | Should Exist
            }
            It "should have the DevOps\Functions in the directory name" {
                $functionsFolder | Should BeLike "*\DevOps\Functions*"
            }
        }
        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                It "found $($_.name)" {
                    "$here\Functions\$($_.name)" | Should Be $true
                }

            }

        }
        Context "finds the functions" {
            $functionsFolder = $env:WORKINGFOLDER + "\DevOps\DevOps\Functions"
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                Context "importing $($_.name)" {
                    It "found $($_.name)" {
                        "$here\Functions\$($_.name)" | Should Be $true
                    }
                    It "should exist" {
                        $_.FullName | Should Exist
                    }
                    It "should have a function in it" {
                        $_.FullName | Should -FileContentMatchMultiline "Function"
                    }
                    It "should have some params" {
                        $_.FullName | Should -FileContentMatchMultiline "Param"
                    }
                    It "should have cmdletbinding" {
                        $_.FullName | Should -FileContentMatchMultiline "cmdletbinding"
                    }
                    It "dot sourcing does not throw when importing it" {
                        {. $_.FullName} | Should Not throw
                    }
                }


            }

        }
        Context "testing framework files" {

            It "DevOps folder exists" {
                "$($here)\DevOps" | Should be $true
            }
            It "DevOps Machine file exists" {
                "$($here)\DevOps\DevOps.Machine.ps1" | Should be $true
            }
            It "Tests folder exists" {
                "$($here)\Tests" | Should be $true
            }
            It "has a readme file" {
                "$($here)\readme.md" | Should be $true
            }
            It "has an .gitignore file" {
                "$($here)\.gitignore" | Should be $true
            }
            It "has a start-pester file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
            It "has a call DevOps file" {
                "$($here)\Call-DevOps.ps1" | Should be $true
            }
            It "has function folder" {
                "$($here)\Functions" | Should be $true
            }
        }
        Context "Testing if call file exists" {
            It "does return true, whatever that means" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should be $true
            }
            It "does exist apparently" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should Exist
            }
            It "not going to work without the env: Working folder" {
                {. "$($here)\Call-DevOps.ps1" } | Should throw
            }
        }
        Context "Testing folder locations" {
            It "imports the DevOps module" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("Import-Module `"`$env:USERPROFILE\Desktop\DevOps\DevOps`" -Force"))
            }
            It "has the working folder set to Desktop\Workingfolder" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("`$env:USERPROFILE\Desktop\WorkingFolder"))
            }
            It "does not contain any special env:" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("`$env:WORKINGFOLDER"))
            }
        }
    }
}


Describe "Unit Testing for Call file" -Tags "UNIT","CALL"{


    Context "Sets up the DevOps process" {

        Setup -Dir "Desktop"
        Setup -Dir "Desktop\WorkingFolder"

        Mock New-Item -ParameterFilter {$path -eq "TestDrive:\Desktop", $itemtype -eq "Directoy" }
        Mock New-Item -ParameterFilter {$path -eq "TestDrive:\Desktop\WorkingFolder", $itemtype -eq "Directoy" }

        Mock Import-Csv -ParameterFilter {$path -eq "TestDrive:\Desktop\WorkingFolder\Import.csv"}

        $importCSV = "TestDrive:\Desktop\WorkingFolder\Import.csv"

        It "has a testdrive folder" {
            "TestDrive:\" | Should Exist
        }
        It "test desktop folder should exist" {
            "TestDrive:\Desktop" | Should Exist
        }
        It "Creates the testdrive working folder on the desktop"{
            "TestDrive:\Desktop\WorkingFolder" | Should Exist
        }
        It "imports the csv file without throwing" {
            { Import-Csv $importCSV } | Should Not throw
        }
    }
    Context "Start Something" {
        $start = "Start-DCImport","Start-DCExport","Start-GPOExport","Start-DCImport","Start-OpenStack"
        $start | ForEach-Object {
            It "has the $_ wrapper" {
                "$env:WORKINGFOLDER\DevOps\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape($($_)))
            }
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

    $modules = "ActiveDirectory","GroupPolicy","DevOps"
    $modules | ForEach-Object{
        Context "Imports the $_ module" {
            It "gets the $_ module" {
                {Get-Module $_ -ErrorAction Stop}| Should Not throw
            }
            It "has the $_ module" {
                { Import-Module $_ -Force -ErrorAction Stop } | Should Not throw
            }
        }
    }
}
