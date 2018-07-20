Get-Module OpenStack | Remove-Module -Force
Import-Module $env:WORKINGFOLDER\DevOps\OpenStack\OpenStack -Force -ErrorAction Stop

Describe "Unit testing for OpenStack" -Tags 'Unit'{

    InModuleScope OpenStack {

        Context "testing framework files" {

            It "OpenStack folder exists" {
                "$($here)\OpenStack" | Should be $true
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
            It "has a call OpenStack file" {
                "$($here)\start-pester.ps1" | Should be $true
            }
        }

    }

}
