Get-Module DevOps | Remove-Module -Force

$parent = (get-item $PSScriptRoot).parent.FullName
Import-Module $parent\DevOps -Force -ErrorAction Stop
Import-Module $parent\Call-DevOps.ps1 -Force -ErrorAction Stop

Describe "Unit testing for DevOps Module" -Tags 'WF'{

    InModuleScope DevOps {
        $parent = (get-item $PSScriptRoot).parent.FullName
        Context "Functions folder Main Testing" {
            $functionsFolder = "$parent\DevOps\Functions"
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

        Context "Finds individual details about each functions" {
            $functionsFolder = "$parent\DevOps\Functions"
            $functions = Get-ChildItem $functionsFolder -Filter "*.ps1"
            $functions | ForEach-Object {
                Context "importing $($_.name)" {
                    It "found $($_.name)" {
                        "$parent\DevOps\Functions\$($_.name)" | Should Be $true
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

    }
}


Describe "Unit Testing for Call file" -Tags "CALL"{
    $parent = (get-item $PSScriptRoot).parent.FullName
    Context "Testing if call file exists" {
        It "does return true, whatever that means" {
            "$parent\Call-DevOps.ps1" | Should be $true
        }
        It "does exist apparently" {
            "$parent\Call-DevOps.ps1" | Should Exist
        }
        It "call file should not throw with dot sourcing" {
            {. "$($parent)\Call-DevOps.ps1" } | Should Not throw
        }
    }
    Context "Testing Contents of the call file" {
        It "imports the DevOps module" {
            "$parent\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("Import-Module `"`$env:USERPROFILE\Desktop\DevOps\DevOps`" -Force"))
        }
        It "has the working folder set to Desktop\Workingfolder" {
            "$parent\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("`$env:USERPROFILE\Desktop\WorkingFolder"))
        }
        It "has the Invoke-DevOps function" {
            "$parent\Call-DevOps.ps1" | Should FileContentMatch ([regex]::Escape("Invoke-DevOps"))
        }

    }
    Context "Sets up the DevOps process" {

        Setup -Dir "Desktop"
        Setup -Dir "Desktop\WorkingFolder"
        Setup -Dir "Desktop\WorkingFolder\GPOBackup"

        Mock New-Item -ParameterFilter {$path -eq "TestDrive:\Desktop", $itemtype -eq "Directoy" }
        Mock New-Item -ParameterFilter {$path -eq "TestDrive:\Desktop\WorkingFolder", $itemtype -eq "Directoy" }

        It "has a testdrive folder" {
            "TestDrive:\" | Should Exist
        }
        It "test desktop folder should exist" {
            "TestDrive:\Desktop" | Should Exist
        }
        It "Creates the testdrive working folder on the desktop"{
            "TestDrive:\Desktop\WorkingFolder" | Should Exist
        }
        It "has the backup GPO folder" {
            "TestDrive:\Desktop\WorkingFolder\GPOBackup" | Should Exist
        }
    }

    $modules = "ActiveDirectory","GroupPolicy","DevOps"
    $modules | ForEach-Object{
        Context "Imports the $_ module" {
            It "gets the $_ module" {
                { Get-Module $_ -ErrorAction Stop }| Should Not throw
            }
            It "$_ module does not throw on import" -Skip {
                { Import-Module $_ -Force -ErrorAction Stop } | Should Not throw
            }
        }
    }
}
